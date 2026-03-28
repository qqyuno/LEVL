# Phase 1: Foundation — Research

**Date:** 2026-03-28

## Flutter + Riverpod v2 Architecture

### Folder Structure (Feature-Based)
```
lib/
├── core/               # theme/, router/, supabase/, constants/
├── features/
│   ├── auth/           # data/ + domain/ + presentation/ + providers.dart
│   ├── onboarding/
│   ├── dashboard/
│   ├── character/
│   └── ai_mentor/
├── shared/             # widgets/, models/, providers/
└── main.dart
```

### Riverpod v2 Key Patterns
- Use `@riverpod` annotations (NOT legacy StateNotifierProvider)
- `AsyncNotifierProvider` — async state (auth, fetch)
- `NotifierProvider` — sync mutable state
- `ref.watch()` only in `build()` — NOT in methods
- `ref.read()` in methods for one-time lookups
- Wrap mutations in `AsyncValue.guard()`
- Run `flutter pub run build_runner watch` during dev

### pubspec.yaml — Riverpod
```yaml
dependencies:
  flutter_riverpod: ^2.5.0
  riverpod_annotation: ^2.3.0
dev_dependencies:
  riverpod_generator: ^2.4.0
  build_runner: ^2.4.0
```

---

## Isar Database

### Versions (stable)
- isar: 3.1.0+1
- isar_flutter_libs: 3.1.0+1
- isar_generator: 3.1.0+1 (dev_dep)

### Schema Pattern
```dart
@Collection()
class UserProfile {
  Id id = Isar.autoIncrement;
  late String name;
  late int level;
  late int xp;
  // ...
}
```

### pubspec.yaml — Isar
```yaml
dependencies:
  isar: 3.1.0+1
  isar_flutter_libs: 3.1.0+1
dev_dependencies:
  isar_generator: 3.1.0+1
  build_runner: any
```

---

## GoRouter v14+ + ThemeData

### GoRouter + Riverpod
```dart
final goRouterProvider = Provider((ref) {
  final authState = ref.watch(authStateProvider);
  return GoRouter(
    redirect: (context, state) {
      if (!authState.isLoggedIn) return '/onboarding';
      return null;
    },
    routes: [...],
  );
});
```

### ThemeData (Material 3) — LEVL Colors
```dart
ThemeData(
  useMaterial3: true,
  colorScheme: ColorScheme(
    brightness: Brightness.light,
    primary: Color(0xFFB8962E),      // gold — earned only
    surface: Color(0xFFE2E2DE),      // lines
    background: Color(0xFFF8F8F6),   // white bg
    onBackground: Color(0xFF0A0A0A), // black text
    onSurface: Color(0xFF0A0A0A),
    // ...
  ),
)
```

### Google Fonts
```dart
// DM Sans for all UI text
textTheme: GoogleFonts.dmSansTextTheme(ThemeData.light().textTheme)

// DM Serif Display for headers — use per-widget
GoogleFonts.dmSerifDisplay(fontSize: 32)
```

### pubspec.yaml — Router + Fonts
```yaml
dependencies:
  go_router: ^14.0.0
  google_fonts: ^7.0.0
```

---

## Key Decisions for Phase 1

1. **Isar 3.1.0+1** (stable) — not 4.0.0-dev
2. **Riverpod v2 annotations** — no legacy syntax
3. **GoRouter as provider** — watches auth state reactively
4. **Material 3** with full custom ColorScheme
5. **Google Fonts** loaded at theme level, not per-widget
6. **build_runner watch** mode during all development
