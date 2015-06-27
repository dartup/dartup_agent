part of dartup_agent;

class User {
  final String name;

  User(this.name);

  toString() => name;

  Future<ProcessResult> run(String executable, List arguments,
      {String workingDirectory, Map<String, String> environment}) {
    var command =
        _toRunUser(executable, arguments, workingDirectory, environment);
    return runProcess('runuser', ['-l', name, '-c', command]);
  }

  Future<Process> start(String executable, List arguments,
      {String workingDirectory, Map<String, String> environment}) {
    var command =
        _toRunUser(executable, arguments, workingDirectory, environment);
    return startProcess('runuser', ['-l', name, '-c', command]);
  }

  String _toRunUser(String executable, List arguments, String workingDirectory,
      Map<String, String> environment) {
    var sb = new StringBuffer();
    if (workingDirectory != null) {
      sb.write('cd $workingDirectory; ');
    }
    if (environment != null) {
      environment.forEach((k, v) => sb.write('$k=$v '));
    }
    sb.write(executable);
    if (arguments.isNotEmpty) {
      sb.write(' ');
    }
    sb.write(argumentsToString(arguments));
    return sb.toString();
  }
}
