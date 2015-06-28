part of dartup_agent;

class Site{
  final String name;
  final String gitUrl;
  Map<String, String> envVars;
  User user;
  int port = 0;
  StringBuffer output = new StringBuffer();

  Process _server;

  Site(this.name,this.gitUrl,[this.envVars]){
    if(envVars == null){
      envVars = {};
    }
  }

  Future<Site> start(User user, int port) async{
    this.user = user;
    this.port = port;
    await addUser();
    await cloneGit();
    await pubGet();
    await startServer();
    return this;
  }

  Future<Site> update() async{
    if(await needUpdate()){
      _server.kill();
      output.clear();
      await pullGit();
      await pubGet();
      await startServer();
    }
    return this;
  }

  /// Add the user in Site.user
  Future addUser() async {
    var result = await runProcess('useradd', [user]);
    print('Created user: $user');
    print(result.stdout);
    print(result.stderr);
  }

  /// Get only the tip of git repository. For now there is no need to get the hole
  /// thing.
  Future cloneGit() async {
    var result = await user.run('git', ['clone',gitUrl,'project']);
    output.writeln('Git clone: $gitUrl');
    output.writeln(result.stdout);
    output.writeln(result.stderr);
  }

  /// run git fetch and if something is downloaded return true.
  Future<bool> needUpdate() async{
    var result = await user.run('git', ['fetch'], workingDirectory: 'project');
    // 5 is just to make sure there is not some hidden spaces.
    return result.stderr.length > 5;
  }

  /// run git fetch and if something is downloaded return true.
  Future pullGit() async{
    var result = await user.run('git', ['pull'], workingDirectory: 'project');
    output.writeln('Git pull: $gitUrl');
    output.writeln(result.stdout);
    output.writeln(result.stderr);
  }

  /// Just run pub get.
  Future pubGet() async {
    var result = await user.run('pub', ['get'],workingDirectory: 'project');
    output.writeln('Pub get:');
    output.writeln(result.stdout);
    output.writeln(result.stderr);
  }

  /// Sets up the environment variables and starts the server finally.
  Future startServer() async {
    var env = {
      'DARTUP': '1',
      'DARTUP_PORT': port.toString(),
      'DARTUP_ADDRESS': '127.0.0.1',
      'DARTUP_DOMAIN': '$name.dartup.io'
    };
    _server = await user.start('dart',['bin/server.dart'],workingDirectory: 'project', environment: env);
    output.writeln('Started $name:');
    _server.stdout.transform(UTF8.decoder).listen(output.writeln);
    _server.stderr.transform(UTF8.decoder).listen(output.writeln);
  }
}