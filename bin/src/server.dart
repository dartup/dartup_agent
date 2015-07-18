part of dartup_agent;

webServer() async{
  var server = await HttpServer.bind('127.0.0.1',8000);
  server.listen((HttpRequest request){
    var path = request.uri.pathSegments;
    // is it the front page
    if(path.isEmpty){
      sendHtml(request.response,mainPage());
      return;
    }

    // is sitepage
    if(sites.containsKey(path.first)){
      Site site = sites[path.first];
      if(path.last == 'update') {
        update(request, site);
        return;
      }
      sendHtml(request.response,detailPage(site));
      return;
    }
    // not found.
    request.response.statusCode = 404;
    request.response.close();
  });
}

update(HttpRequest req, Site site){
  site.update();
  req.response.statusCode = 303;
  req.response.headers.add('Location','http://${req.requestedUri.authority}/${site.name}');
  req.response.close();
}

sendHtml(HttpResponse res,String body){
  res.headers.contentType = ContentType.HTML;
  res.write(chrome(body));
  res.close();
}

String chrome(String content){
  return '''
<html>
<head>
    <title>Dartup's very alpha control panel.</title>
</head>
<body>
<h1>Dartup's very alpha control panel.</h1>
$content
</body>
</html>
  ''';
}

String mainPage(){
  var sb = new StringBuffer();
  sb.writeln('<ul>');
  sb.writeAll(sites.keys.map((name) => '<li><a href="/$name">$name</a></li>'),'\n');
  sb.writeln('</ul>');
  return sb.toString();
}

String detailPage(Site site){
  var sb = new StringBuffer();
  sb.writeln('<a href="/${site.name}/update">Update ${site.name}<a>');
  sb.write('<pre>');
  sb.write(site.output);
  sb.write('</pre>');
  return sb.toString();
}