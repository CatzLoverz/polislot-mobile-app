import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

// ✅ IMPORT YANG BENAR:
import 'package:polislot_mobile_catz/main.dart'; 

void main() {
  setUpAll(() async {
    // Mocking Environment Variables agar tidak error saat aplikasi baca .env
    // Kita isi dummy data saja karena ini cuma test UI
    dotenv.load(
      mergeWith: {
        'API_BASE_URL': 'http://localhost/api',
        'API_STORAGE_URL': 'http://localhost/storage/',
        'API_SECRET_KEY': '12345678901234567890123456789012',
        'API_SECRET_IV': '1234567890123456',
      },
    );
  });

  testWidgets('Aplikasi bisa dijalankan (Smoke Test)', (WidgetTester tester) async {
    await tester.pumpWidget(
      const ProviderScope(
        child: PoliSlotApp(), // ✅ Sekarang ini sudah dikenali
      ),
    );

    await tester.pumpAndSettle(const Duration(seconds: 5));
    expect(find.byType(MaterialApp), findsOneWidget);
  });
}