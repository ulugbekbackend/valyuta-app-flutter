# Valyuta kurslari

[O'zbekcha](#ozbekcha) · [English](#english)

---

## O'zbekcha

O'zbekiston Respublikasi Markaziy banki (CBU) rasmiy valyuta kurslarini ko'rsatadigan va so'm ↔ valyuta konvertori bo'lgan Flutter ilova. Bu mening birinchi Flutter loyiham: men Python/Django va React bilan ishlayman va Flutter'ni shu loyiha orqali o'rgandim.

### Imkoniyatlar

- **Kurslar ro'yxati.** 74 ta valyuta, USD, EUR va RUB tepadagi alohida "kurs taxtasi"da, qolganlari alifbo bo'yicha.
- **Kunlik o'zgarish.** O'sgan kurs yashil ▲, tushgani qizil ▼.
- **Qidiruv.** Kod yoki nom bo'yicha (`usd`, `dollar`, `afg'on`).
- **Pull-to-refresh** va "Oxirgi yangilanish" sanasi.
- **Konvertor.** Ikki yo'nalishda, yozilayotganda darhol hisoblanadi. Nominal hisobga olinadi (masalan, IDR kursi 10 birlik uchun).
- **Offline rejim.** Oxirgi muvaffaqiyatli javob saqlanadi. Internet bo'lmasa, saqlangan kurslar "Offline" banner bilan ko'rsatiladi.
- **Dizayn.** Material 3, och va to'q mavzu (tizimga qarab). Samarqand koshinlaridan ilhomlangan ranglar: lojuvard, firuza va zarhal.
- **To'liq o'zbekcha interfeys**, Flutter'ning ichki matnlari ham.

### Ishga tushirish

Talablar: Flutter 3.47+ (Dart 3.13+) va Chrome. Android uchun qo'shimcha ravishda Android SDK kerak.

```bash
git clone https://github.com/ulugbekbackend/valyuta-app-flutter.git
cd valyuta-app-flutter
flutter pub get
flutter run -d chrome
```

Boshqa buyruqlar:

```bash
flutter test                  # barcha testlar (48 ta)
flutter analyze               # kod tahlili (lint)
flutter build web             # production build → build/web
flutter build apk --release   # Android APK → build/app/outputs/flutter-apk/
```

Ma'lumotlar manbai: `https://cbu.uz/uz/arkhiv-kursov-valyut/json/`. API kaliti kerak emas.

### Loyiha tuzilmasi

```
lib/
  main.dart                  ilova, mavzu, HomePage (holat va navigatsiya)
  models/currency.dart       Currency modeli, JSON parse, konvertatsiya
  services/
    currency_service.dart    API'dan yuklash, keshga qaytish, tartiblash, qidiruv
    cache_service.dart       oxirgi javobni saqlash (shared_preferences)
  screens/
    rates_screen.dart        kurslar ro'yxati, qidiruv, pull-to-refresh
    converter_screen.dart    konvertor
  widgets/                   kurs taxtasi, qator, offline banner va boshqalar
  utils/
    formatters.dart          "12 650,50" formati, summani tekshirish
    fonts.dart               lokal Google Fonts (IBM Plex Sans, Unbounded)
assets/google_fonts/         shrift fayllari va litsenziyalari (SIL OFL)
test/                        unit va widget testlar
```

Arxitektura sodda: barcha ma'lumot (kurslar, yuklanish, xato, offline) bitta `HomePage` widgetida turadi va ekranlarga constructor orqali uzatiladi. Holat boshqaruvi uchun faqat `setState` ishlatilgan.

### Nimalarni o'rgandim

- **Widget = komponent.** `StatelessWidget` props'li oddiy komponentga, `StatefulWidget` + `setState` esa `useState`ga o'xshaydi. `build()` bu JSX qaytaradigan render.
- **Lifting state up.** Ma'lumotni umumiy ota widgetga ko'tarish React'dagidek ishlaydi. Natijada ekranlarni testda tarmoqsiz, soxta ma'lumot bilan sinash oson bo'ldi.
- **Layout CSS'siz.** `Row`, `Column`, `Expanded` flexbox o'rnini bosadi. `ListView.builder` faqat ko'rinadigan qatorlarni chizadi.
- **Async.** `Future` va `async`/`await` JS'dagi `Promise`ga juda o'xshaydi. `initState` esa `useEffect(..., [])` ga o'xshaydi.
- **API bilan ishlash.**
  - CBU raqamlarni string ko'rinishida yuboradi, shuning uchun ular `tryParse` bilan xavfsiz o'qiladi.
  - Server charset ko'rsatmaydi, shuning uchun javob UTF-8'da qo'lda decode qilinadi.
  - Kurs `Nominal` birlik uchun beriladi, hisoblashda shuni unutmaslik kerak.
- **Testlash.**
  - `http`ning `MockClient`i bilan internetsiz testlar yozish mumkin.
  - Testda `SharedPreferences` soxta qiymatlar bilan almashtiriladi.
  - `testWidgets` bilan ekranni bosish va yozish taqlid qilinadi.
- **Shriftlar.**
  - `google_fonts` shriftlarni internetdan yuklaydi va dastlab bir lahzaga standart shrift ko'rinadi. Fayllarni loyihaga qo'shib, `runApp`dan oldin kutish bilan bu hal bo'ldi.
  - Har bir qalinlik (bold, semibold) uchun alohida fayl kerak.
- **Mavzu.** `ColorScheme.fromSeed` bitta rangdan butun och va to'q palitrani yasaydi.

### Manbalar

- Valyuta kurslari: [O'zbekiston Respublikasi Markaziy banki](https://cbu.uz).
- Shriftlar: [IBM Plex Sans](https://github.com/IBM/plex) va [Unbounded](https://github.com/googlefonts/unbounded), ikkalasi ham SIL Open Font License 1.1 litsenziyasi ostida.

---

## English

A Flutter app that shows the official exchange rates of the Central Bank of Uzbekistan (CBU) and converts between the Uzbek som and other currencies. This is my first Flutter project. I'm a Python/Django and React developer, and I used this project to learn Flutter.

### Features

- **Rates list.** 74 currencies, with USD, EUR and RUB on a highlighted "rate board" at the top and the rest in alphabetical order.
- **Daily change.** Green ▲ when a rate went up, red ▼ when it went down.
- **Search** by code or name (`usd`, `dollar`, `afg'on`).
- **Pull-to-refresh** and a "last updated" date.
- **Converter.** Works in both directions, updates live as you type and respects `Nominal` (for example, the IDR rate is quoted per 10 units).
- **Offline mode.** The last successful response is cached. Without internet the cached rates are shown under an "Offline" banner.
- **Design.** Material 3 with light and dark themes that follow the system setting. The palette comes from Samarkand tilework: lapis, turquoise and gold.
- **Fully Uzbek UI**, including Flutter's built-in strings.

### Getting started

Requirements: Flutter 3.47+ (Dart 3.13+) and Chrome. Building for Android also needs the Android SDK.

```bash
git clone https://github.com/ulugbekbackend/valyuta-app-flutter.git
cd valyuta-app-flutter
flutter pub get
flutter run -d chrome
```

Other commands:

```bash
flutter test                  # all tests (48)
flutter analyze               # static analysis (lint)
flutter build web             # production build → build/web
flutter build apk --release   # Android APK → build/app/outputs/flutter-apk/
```

Data source: `https://cbu.uz/uz/arkhiv-kursov-valyut/json/`. No API key is needed.

### Project structure

See the tree in the Uzbek section above. In short:
- `models/` holds the data model;
- `services/` handles API access and caching;
- `screens/` contains the two tabs;
- `widgets/` contains reusable UI pieces;
- `utils/` contains formatting and fonts.

All app state (rates, loading, error, offline) lives in one `HomePage` widget and is passed down to the screens through constructors. State management is plain `setState`, with no extra libraries.

### What I learned

- **Widgets are components.** A `StatelessWidget` is like a component that only takes props, and a `StatefulWidget` with `setState` is like one that uses `useState`. `build()` plays the role of a render function that returns JSX.
- **Lifting state up** works just as in React. As a result, the screens are easy to widget-test with fake data and no network.
- **Layout without CSS.** `Row`, `Column` and `Expanded` replace flexbox, and `ListView.builder` virtualizes long lists.
- **Async.** `Future` and `async`/`await` map almost one-to-one to JS promises, and `initState` is the equivalent of `useEffect(..., [])`.
- **Working with a real API.**
  - CBU sends numbers as strings, so they are parsed with `tryParse`.
  - The server sends no charset, so the response is decoded as UTF-8 explicitly.
  - Rates are quoted per `Nominal` units, which the conversion math has to take into account.
- **Testing.**
  - `MockClient` from `package:http` makes tests run without a network.
  - `SharedPreferences` can be mocked in tests.
  - `testWidgets` simulates taps and typing.
- **Fonts.**
  - By default `google_fonts` downloads fonts at runtime, so the default font briefly appears first. Bundling the font files and awaiting them before `runApp` fixes this.
  - Each font weight needs its own file.
- **Theming.** `ColorScheme.fromSeed` builds a full light and dark palette from a single brand color.

### Credits

- Exchange rates: [Central Bank of the Republic of Uzbekistan](https://cbu.uz).
- Fonts: [IBM Plex Sans](https://github.com/IBM/plex) and [Unbounded](https://github.com/googlefonts/unbounded), both licensed under the SIL Open Font License 1.1.
