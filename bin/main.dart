// Copyright (c) 2015, <your name>. All rights reserved. Use of this source code
// is governed by a BSD-style license that can be found in the LICENSE file.

import 'dart:async';

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

/// @todo add meat.
Stream<Site> getFromDB(){
  var fakeData = [];
  fakeData.add(new Site()
    ..name = 'fake1'
    ..gitUrl = 'git://exsample.com/'
  );
  fakeData.add(new Site()
    ..name = 'fake2'
    ..gitUrl = 'git://exsample.com/'
  );
  fakeData.add(new Site()
    ..name = 'fake3'
    ..gitUrl = 'git://exsample.com/'
  );

  return new Stream.fromIterable(fakeData);
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
