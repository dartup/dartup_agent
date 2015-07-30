// Copyright (c) 2015, Ole Martin Gjersvik. All rights reserved. Use of this
// source code is governed by a BSD-style license that can be found in the
// LICENSE file.

library dartup_agent;

import 'dart:async';
import 'dart:io';
import 'dart:convert';

import 'package:postgresql/postgresql.dart';

part 'src/process.dart';
part 'src/server.dart';
part 'src/site.dart';
part 'src/user.dart';
part 'src/webproxy.dart';

Map<String,Site> sites = {};

main() async {
  if (Platform.environment['FAKE'] == '1') {
    fakeRun = true;
  }

  Stream<Site> stream = getFromDB();
  stream = runSites(stream);

  await webServer();
  await writeNginxConf(stream).then(startNgnix);
}

/// Loads Site data from an Postgres Database.
///
/// It looks for connection parameters in an environmental variable called
/// POSTGRES_URI. Then the main site information is in the site table.
///
/// Will get all the sites that are not evil.
Stream<Site> getFromDB() async* {
  var con = await connect(Platform.environment['POSTGRES_URI']);
  var result = await con
      .query('SELECT name,giturl,envvar FROM site where evil = false;');
  yield* result.map((Row r) => new Site(r.name, r.giturl, r.envvar));
}

/// Add linux username and port number to sites.
///
/// At this early stage make it simple and dumb.
Stream<Site> runSites(Stream<Site> stream) {
  var i = 1;
  return stream.map((Site s) {
    s.user = new User('user$i');
    s.port = 8000 + i;
    s.start();
    i += 1;
    sites[s.name] = s;
    return s;
  });
}

/// Writes Nginx config files.
Future<String> writeNginxConf(Stream<Site> sites) async {
  var s = '''
server {
  listen 80;
  server_name dartup.io;
  location / {
    proxy_pass       http://localhost:8000;
    proxy_set_header Host      \$host;
    proxy_set_header X-Real-IP \$remote_addr;
  }
}
  ''';

  return s + await sites.map((site) {
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
  if (fakeRun == false) {
    var file = new File('/etc/nginx/conf.d/dartup.conf');
    await file.writeAsString(conf);
  }else{
    print(conf);
  }
  print('Written /etc/nginx/conf.d/dartup.conf');

  var result = await runProcess('nginx', []);
  print('Ngnix started');
  print(result.stdout);
  print(result.stderr);
}
