import 'package:flutter_test/flutter_test.dart';
import 'package:ktgk/utils/validators.dart';

void main() {
  test('email validator accepts valid email and rejects invalid email', () {
    expect(Validators.email('user@example.com'), isNull);
    expect(Validators.email('invalid-email'), isNotNull);
  });

  test('password validator requires at least six characters', () {
    expect(Validators.password('123456'), isNull);
    expect(Validators.password('123'), isNotNull);
  });
}
