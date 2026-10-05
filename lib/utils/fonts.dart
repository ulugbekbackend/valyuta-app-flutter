import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

// google_fonts har bir qalinlik (w400, w700...) uchun alohida shrift yuklaydi.
// Shuning uchun qalinlikni avval belgilab, keyin shu funksiyalardan o'tkazing:
//   displayFont(style.copyWith(fontWeight: FontWeight.w700))
// Aks holda brauzer oddiy shriftni sun'iy qalinlashtiradi.
//
// Fayllar assets/google_fonts/ ichida. Yangi qalinlik ishlatsangiz,
// uning .ttf faylini ham shu yerga qo'shing.

/// Ilova chizilishidan oldin shriftlarni tayyorlaydi — shunda ekranda
/// bir lahzaga standart shrift ko'rinib, keyin almashmaydi.
Future<void> loadFonts() async {
  // Faqat ilova ichidagi fayllar; internetdan yuklamaydi (offline ham ishlaydi).
  GoogleFonts.config.allowRuntimeFetching = false;

  // Shriftlar litsenziyasi (SIL OFL) — ilova bilan birga bo'lishi shart.
  LicenseRegistry.addLicense(() async* {
    for (final name in ['IBMPlexSans', 'Unbounded']) {
      final text = await rootBundle.loadString(
        'assets/google_fonts/$name-OFL.txt',
      );
      yield LicenseEntryWithLineBreaks([name], text);
    }
  });

  // Har bir ishlatiladigan qalinlikni "so'raymiz", keyin hammasini kutamiz.
  for (final w in [
    FontWeight.w400,
    FontWeight.w500,
    FontWeight.w600,
    FontWeight.w700,
  ]) {
    bodyFont(TextStyle(fontWeight: w));
    if (w != FontWeight.w400) displayFont(TextStyle(fontWeight: w));
  }
  await GoogleFonts.pendingFonts();
}

/// Matn uchun: IBM Plex Sans — o'qish oson, raqamlari tabular.
TextStyle bodyFont(TextStyle? style) =>
    GoogleFonts.ibmPlexSans(textStyle: style);

/// Sarlavha va katta raqamlar uchun: keng, xarakterli Unbounded.
TextStyle displayFont(TextStyle? style) =>
    GoogleFonts.unbounded(textStyle: style);

/// Butun ilova matnlari IBM Plex Sans bilan.
TextTheme appTextTheme(TextTheme t) => TextTheme(
  displayLarge: bodyFont(t.displayLarge),
  displayMedium: bodyFont(t.displayMedium),
  displaySmall: bodyFont(t.displaySmall),
  headlineLarge: bodyFont(t.headlineLarge),
  headlineMedium: bodyFont(t.headlineMedium),
  headlineSmall: bodyFont(t.headlineSmall),
  titleLarge: bodyFont(t.titleLarge),
  titleMedium: bodyFont(t.titleMedium),
  titleSmall: bodyFont(t.titleSmall),
  bodyLarge: bodyFont(t.bodyLarge),
  bodyMedium: bodyFont(t.bodyMedium),
  bodySmall: bodyFont(t.bodySmall),
  labelLarge: bodyFont(t.labelLarge),
  labelMedium: bodyFont(t.labelMedium),
  labelSmall: bodyFont(t.labelSmall),
);
