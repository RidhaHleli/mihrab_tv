import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mihrab_tv/core/responsive/responsive.dart';
import 'package:mihrab_tv/core/theme/app_theme_controller.dart';
import 'package:mihrab_tv/core/theme/mihrab_palette.dart';
import 'package:mihrab_tv/main.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Screen sizes in logical pixels: TV (1080p / 540p buffer), tablet,
/// phone portrait and phone landscape.
const _sizes = <String, Size>{
  'tv 1920x1080': Size(1920, 1080),
  'tv 960x540': Size(960, 540),
  'tablet portrait 800x1280': Size(800, 1280),
  'tablet landscape 1280x800': Size(1280, 800),
  'phone portrait 360x800': Size(360, 800),
  'phone small 320x568': Size(320, 568),
  'phone landscape 800x360': Size(800, 360),
};

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues({});
    AppThemeController.instance.value = AppThemeId.kairouan;
  });

  group('Responsive', () {
    test('uses the wide layout on TV and landscape screens', () {
      expect(Responsive.fromSize(const Size(1920, 1080)).isWide, isTrue);
      expect(Responsive.fromSize(const Size(960, 540)).isWide, isTrue);
      expect(Responsive.fromSize(const Size(1280, 800)).isWide, isTrue);
    });

    test('uses the stacked layout on portrait screens', () {
      expect(Responsive.fromSize(const Size(360, 800)).isWide, isFalse);
      expect(Responsive.fromSize(const Size(800, 1280)).isWide, isFalse);
    });

    test('keeps the same proportions on a 1080p and a 540p TV buffer', () {
      final full = Responsive.fromSize(const Size(1920, 1080));
      final half = Responsive.fromSize(const Size(960, 540));

      expect(full.scale, 1.0);
      expect(half.scale, 0.5);
    });

    test('never returns a tap target below 48', () {
      expect(Responsive.fromSize(const Size(320, 568)).tap(40), 48);
    });
  });

  group('MIHRAB app', () {
    for (final entry in _sizes.entries) {
      testWidgets('renders without layout errors on ${entry.key}',
          (tester) async {
        tester.view.physicalSize = entry.value;
        tester.view.devicePixelRatio = 1.0;
        addTearDown(tester.view.reset);

        await tester.pumpWidget(const MihrabApp());
        await tester.pump(const Duration(seconds: 1));

        expect(find.byType(MaterialApp), findsOneWidget);
        expect(tester.takeException(), isNull);
      });
    }
  });

  group('Themes', () {
    test('unknown or missing names fall back to Kairouan', () {
      expect(AppThemeId.fromName(null), AppThemeId.kairouan);
      expect(AppThemeId.fromName('nope'), AppThemeId.kairouan);
      expect(AppThemeId.fromName('quds'), AppThemeId.quds);
    });

    test('palettes can be blended while the theme animates', () {
      final mid = MihrabPalette.kairouan.lerp(MihrabPalette.makkah, 0.5);

      expect(mid.heroGradient.length, 3);
      expect(mid.accent, isNot(MihrabPalette.kairouan.accent));
    });

    for (final id in AppThemeId.values) {
      for (final size in const [Size(1920, 1080), Size(360, 800)]) {
        testWidgets('renders ${id.name} on ${size.width.toInt()}x'
            '${size.height.toInt()}', (tester) async {
          AppThemeController.instance.value = id;
          tester.view.physicalSize = size;
          tester.view.devicePixelRatio = 1.0;
          addTearDown(tester.view.reset);

          await tester.pumpWidget(const MihrabApp());
          await tester.pump(const Duration(seconds: 1));

          expect(tester.takeException(), isNull);
        });
      }
    }
  });
}
