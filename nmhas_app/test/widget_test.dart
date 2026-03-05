import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:nmhas_app/app.dart';

void main() {
  testWidgets('App renders with brand theme', (WidgetTester tester) async {
    await tester.pumpWidget(const ProviderScope(child: NmhasApp()));
    await tester.pumpAndSettle();

    expect(find.text('Protocols'), findsWidgets);
  });
}
