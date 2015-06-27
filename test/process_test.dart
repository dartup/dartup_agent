@TestOn("vm")
import 'package:test/test.dart';

import 'dart:convert';

import '../bin/main.dart';

main() => group('process.dart', () {
  // test that run and start really do start sub processes.
  group('Real', () {
    // for these test we want to force fakeRun to be false;
    bool tempFake;
    setUp(() {
      tempFake = fakeRun;
      fakeRun = false;
    });
    tearDown(() {
      fakeRun = tempFake;
    });

    test('Try to run dart --version.', () async {
      var res = await runProcess('dart', ['--version']);
      // dart will return something like
      // 'Dart VM version: 1.11.0 (Wed Jun 24 06:44:48 2015) on "windows_x64"'
      // to make the test lest fragile only look for successful return and Dart
      // some where in stderr.
      expect(res.exitCode, 0);
      expect(res.stderr, contains('Dart'));
    });

    test('Try to start dart --version.', () async {
      var pro = await startProcess('dart', ['--version']);
      // dart will return something like
      // 'Dart VM version: 1.11.0 (Wed Jun 24 06:44:48 2015) on "windows_x64"'
      // to make the test lest fragile only look for successful return and Dart
      // some where in stderr.
      expect(await pro.exitCode, 0);
      expect(await UTF8.decodeStream(pro.stderr), contains('Dart'));
    });
  });

  //test that run and start can be faked.
  group('Fake', () {
    // for these test we want to force fakeRun to be true;
    bool tempFake;
    setUp(() {
      tempFake = fakeRun;
      fakeRun = true;
    });
    tearDown(() {
      fakeRun = tempFake;
    });

    test('Try to run dart --version.', () async {
      var res = await runProcess('dart', ['--version']);
      // Not that its faked we know what the result should be.
      expect(res.pid, -1);
      expect(res.exitCode, 0);
      expect(res.stdout, '');
      expect(res.stderr, 'Faking: dart --version');
    });

    test('Try to start dart --version.', () async {
      var pro = await startProcess('dart', ['--version']);
      // Not that its faked we know what the result should be.
      expect(pro.pid, -1);
      expect(await pro.exitCode, 0);
      expect(await UTF8.decodeStream(pro.stdout), '');
      expect(await UTF8.decodeStream(pro.stderr), 'Faking: dart --version');
    });
  });

  test('argumentsToString handle simple cases', () {
    var s = argumentsToString(['--one', 2, true]);
    expect(s, '--one 2 true');
  });

  test('argumentsToString waraps if agument has space', () {
    var s = argumentsToString(['shuld be wraped in quaotes']);
    expect(s, '"shuld be wraped in quaotes"');
  });
});
