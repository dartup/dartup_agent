// Copyright (c) 2015, Ole Martin Gjersvik. All rights reserved. Use of this
// source code is governed by a BSD-style license that can be found in the
// LICENSE file.

library dartup_agent;

import 'dart:async';
import 'dart:io';
import 'dart:convert';

import 'package:postgresql/postgresql.dart';

part 'src/process.dart';

main() async {
  if (Platform.environment['FAKE'] == '1') {
    fakeRun = true;
  }

  Stream<Site> sites = assignNames(getFromDB()).asBroadcastStream();

  List<Future> work = [writeNginxConf(sites).then(startNgnix)];
  work.addAll(await sites.map(runSite).toList());

  await Future.wait(work);
}

Future runSite(Site site) =>
    addUser(site).then(cloneGit).then(pubGet).then(startServer);

class Site {
  String name = '';
  String gitUrl = '';
  Map<String, String> envVars = {};
  String user = 'nobody';
  int port = 0;
}

/// Loads Site data from an Postgres Database.
///
/// It looks for connection parameters in an environmental variable called
/// POSTGRES_URI. And interets it as an Uri. Then the main site information is
/// in the X table with the site environment vriables being in an Y table.
///
/// Will get all the sites that are not evil.
Stream<Site> getFromDB() async* {
  var con = await connect(Platform.environment['POSTGRES_URI']);
  var result = await con
      .query('SELECT name,giturl,envvar FROM site where evil = false;');
  yield* result.map((Row r) => new Site()
    ..name = r.name
    ..gitUrl = r.giturl
    ..envVars.addAll(r.envvar));
}

/// Add linux username and port number to sites.
///
/// At this early stage make it simple and dumb.
Stream<Site> assignNames(Stream<Site> sites) {
  var i = 1;
  return sites.map((s) {
    s.user = 'user$i';
    s.port = 8000 + i;
    i += 1;
    return s;
  });
}

/// Writes Nginx config files.
Future<String> writeNginxConf(Stream<Site> sites) {
  return sites.map((site) {
    return '''
server {
  listen 80;
  server_name ${site.name}.dartup.io;
  location / {
    proxy_pass       http://localhost:${site.port};
    proxy_set_header Host      \$host;
    proxy_set_header X-Real-IP \$remote_addr;
  }
}
  ''';
  }).join('\n');
}

/// Save the config and start Nginx.
///
/// Save the config file to /etc/nginx/conf.d/dartup.conf
Future startNgnix(String conf) async {
  var file = new File('/etc/nginx/conf.d/dartup.conf');
  await file.writeAsString(conf);
  print('Written /etc/nginx/conf.d/dartup.conf');

  var result = await run('nginx', []);
  print('Ngnix started');
  print(result.stdout);
  print(result.stderr);
}

/// Add the user in Site.user
Future<Site> addUser(Site site) async {
  var result = await run('useradd', [site.user]);
  print('Created user: ${site.user}');
  print(result.stdout);
  print(result.stderr);
  return site;
}

/// Get only the tip of git repository. For now there is no need to get the hole
/// thing.
Future<Site> cloneGit(Site site) async {
  var exec = 'git clone --depth 1 ${site.gitUrl} project';
  var result = await run('runuser', ['-l', site.user, '-c', exec]);
  print('Git clone git: ${site.gitUrl}');
  print(result.stdout);
  print(result.stderr);
  return site;
}

/// Just run pub get.
Future<Site> pubGet(Site site) async {
  var exec = 'cd project; pub get';
  var result = await run('runuser', ['-l', site.user, '-c', exec]);
  print('Git pubGet');
  print(result.stdout);
  print(result.stderr);
  return site;
}

/// Sets up the environment variables and starts the server finally.
Future<Site> startServer(Site site) async {
  var env = {
    'DARTUP': '1',
    'DARTUP_PORT': site.port.toString(),
    'DARTUP_ADDRESS': '127.0.0.1',
    'DARTUP_DOMAIN': '${site.name}.dartup.io'
  };
  var str = env.keys.map((e) => '$e=${env[e]}').join(' ');
  var exec = 'cd project; $str dart bin/server.dart';
  var process = await start('runuser', ['-l', site.user, '-c', exec]);
  print('Started ${site.name}');
  process.stdout.transform(UTF8.decoder).listen(print);
  process.stderr.transform(UTF8.decoder).listen(print);
  return site;
}
