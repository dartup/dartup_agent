// Copyright (c) 2015, Ole Martin Gjersvik. All rights reserved. Use of this
// source code is governed by a BSD-style license that can be found in the
// LICENSE file.

part of dartup_agent;

/// set to true if you do not want to run any commands. Nice for testing or
/// developing outside is proper context.
///
/// The process returned if this is true. Has pid -1, exist code 0, the command
/// it would have run as stdout and empty string as stderr.
bool fakeRun = false;

/// Will do the same as [Process.run].
Future<ProcessResult> run(String executable, List<String> arguments) async {
  if(fakeRun){
    return new ProcessResult(-1,0,'Faking: $executable' + arguments.join(' '),'');
  }
  return Process.run(executable, arguments, runInShell: true);
}

/// Will do the same as [Process.start].
Future<Process> start(String executable, List<String> arguments) async{
  if(fakeRun){
    return new _FakeProcess('Faking: $executable' + arguments.join(' '));
  }
  return Process.start(executable, arguments, runInShell: true);
}

/// Just an internal mock of Process as it do not have constructor to create a fake.
class _FakeProcess implements Process{
  /// returns false as it is always already dead.
  bool kill([_]) => false;

  Future<int> exitCode = new Future.value(0);
  final int pid = -1;
  final IOSink stdin = new IOSink(new StreamController.broadcast());
  final Stream<List<int>> stderr = new Stream.fromIterable([]);
  final Stream<List<int>> stdout;

  _FakeProcess(String command): stdout = new Stream.fromIterable([UTF8.encode(command)]);
}