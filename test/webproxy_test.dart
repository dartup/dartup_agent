@TestOn("vm")
import 'package:test/test.dart';

import '../bin/main.dart';

main() => group('VirtualHost', () {
  test('VirtualHost.emptyHost must return true on isEmpty',(){
    expect(VirtualHost.emptyHost.isEmpty, isTrue);
  });

  test('A created VirtualHost must return false on isEmpty',(){
    expect(new VirtualHost('test', 8080, 'localhost', 'exsample.com').isEmpty, isFalse);
  });
});