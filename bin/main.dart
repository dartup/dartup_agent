// Copyright (c) 2015, <your name>. All rights reserved. Use of this source code
// is governed by a BSD-style license that can be found in the LICENSE file.

import 'dart:async';
import 'dart:io';

import 'package:postgresql/postgresql.dart';
import 'package:stack_trace/stack_trace.dart';

main() async {
  List sites = await assignNames(getFromDB()).toList();

  await startNgnix(writeNgnixConf(sites));

  await Future.wait(sites.map(runSite));
}

Future runSite(Site site) => addUser(site).then(cloneGit).then(pubGet).then(startServer);

class Site{
  String name = '';
  String gitUrl = '';
  Map<String,String> envVars = {};
  String user = 'nobody';
  int port = 0;
}

/// Loads Site data from an Postgres Database.
///
/// It looks for connection parameters in an environmental variable called POSTGRES_URI. And interets it as an Uri.
/// Then the main site information is in the X table with the site environment vriables being in an Y table.
///
/// Will get all the sites that are not evil.
Stream<Site> getFromDB() async*{
  var con = await connect(Platform.environment['POSTGRES_URI']);
  var result = await con.query('SELECT name,giturl,envvar FROM site where evil = false;');
  yield* result.map((Row r) => new Site()
    ..name = r.name
    ..gitUrl = r.giturl
    ..envVars.addAll(r.envvar));
}

/// @todo add meat.
Stream<Site> assignNames(Stream<Site> sites){
  var i = 1;
  return sites.map((s){
    s.user = 'user$i';
    s.port = 8000 + i;
    i += 1;
    return s;
  });
}

/// @todo add meat.
String writeNgnixConf(List<Site> sites){
  return sites.map((s) => '${s.name}.dartup.io').join('\n');
}

/// @todo add meat.
Future startNgnix(String conf) async{
  print('Fake Ngnix started');
  print(conf);
}

/// @todo add meat.
Future<Site> addUser(Site site) async{
  print('Fake adder user: ${site.user}');
  return site;
}

/// @todo add meat.
Future<Site> cloneGit(Site site)async{
  print('Fake clone git: ${site.gitUrl}');
  return site;
}

/// @todo add meat.
Future<Site> pubGet(Site site)async{
  print('Fake pubGet');
  return site;
}

/// @todo add meat.
Future<Site> startServer(Site site)async{
  print('Fake started ${site.name}');
  return site;
}
