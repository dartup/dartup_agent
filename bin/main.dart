// Copyright (c) 2015, <your name>. All rights reserved. Use of this source code
// is governed by a BSD-style license that can be found in the LICENSE file.

import 'dart:async';

main() async {
  List sites = await assignNames(getFromDB()).toList();

  await startNgnix(writeNgnixConf(sites));

  await Future.wait(sites.map(runSite));
}

Future runSite(Site site) => addUser(site).then(cloneGit).then(pubGet).then(startServer);

class Site{}

/// @todo add meat.
Stream<Site> getFromDB(){}

/// @todo add meat.
Stream<Site> assignNames(Stream<Site> sites){}

/// @todo add meat.
String writeNgnixConf(List<Site>){}

/// @todo add meat.
Future startNgnix(String conf){}

/// @todo add meat.
Future<Site> addUser(Site site){}

/// @todo add meat.
Future<Site> cloneGit(Site site){}

/// @todo add meat.
Future<Site> pubGet(Site site){}

/// @todo add meat.
Future<Site> startServer(Site site){}
