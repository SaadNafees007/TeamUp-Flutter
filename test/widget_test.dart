import 'package:flutter_test/flutter_test.dart';
import 'package:teamup/core/constants/app_constants.dart';

void main() {
  test('App constants and configuration test', () {
    expect(AppConstants.appName, equals('TeamUp'));
    expect(AppConstants.departments, isNotEmpty);
    expect(
      AppConstants.projectTypes,
      containsAll(['Semester Project', 'Final Year Project', 'Both']),
    );
    expect(AppConstants.suggestedSkills, isNotEmpty);
  });
}
