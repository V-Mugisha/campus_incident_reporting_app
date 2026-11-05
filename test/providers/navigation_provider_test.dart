import 'package:flutter_test/flutter_test.dart';

import 'package:campus_incident_reporting_app/providers/navigation_provider.dart';

void main() {
  test('setIndex updates index and notifies listeners', () {
    final nav = NavigationProvider();
    var notified = 0;
    nav.addListener(() => notified++);

    expect(nav.currentIndex, 0);

    nav.setIndex(2);
    expect(nav.currentIndex, 2);
    expect(notified, 1);

    nav.setIndex(2);
    expect(notified, 1);
  });
}
