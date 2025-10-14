# Быстрый старт

## Запуск проекта

### 1. Проверка Flutter
```bash
flutter doctor
```

### 2. Установка зависимостей
```bash
cd maychurchsong_flutter
flutter pub get
```

### 3. Запуск на Android
```bash
flutter run
```

### 4. Запуск на iOS (только macOS)
```bash
flutter run
```

## Сборка release версии

### Android APK
```bash
flutter build apk --release
```

Файл будет в: `build/app/outputs/flutter-apk/app-release.apk`

### Android App Bundle (для Google Play)
```bash
flutter build appbundle --release
```

Файл будет в: `build/app/outputs/bundle/release/app-release.aab`

### iOS (только macOS)
```bash
flutter build ios --release
```

## Особенности

- ✅ База данных автоматически копируется из assets при первом запуске
- ✅ Адаптивный дизайн (Material для Android, Cupertino для iOS)
- ✅ Полная функциональность оригинального приложения
- ✅ Поддержка фоновых обновлений
- ✅ Настраиваемые темы и размеры шрифтов

## Структура файлов

```
maychurchsong_flutter/
├── lib/                          # Основной код (main.dart)
├── maychurchsong_flutter/        # Все компоненты приложения
│   ├── lib/
│   │   ├── data/                 # Слой данных
│   │   │   ├── models/           # Модели (Song)
│   │   │   ├── database/         # SQLite (SongDatabase, SongDao)
│   │   │   ├── repositories/     # Репозитории
│   │   │   └── services/         # Сервисы (обновление, настройки)
│   │   ├── ui/                   # Слой UI
│   │   │   ├── screens/          # 5 экранов
│   │   │   ├── widgets/          # Переиспользуемые виджеты
│   │   │   └── themes/           # Темы (Material + Cupertino)
│   │   └── utils/                # Константы и утилиты
│   └── assets/
│       └── database/             # Предзаполненная база данных
├── android/                      # Android конфигурация
└── ios/                          # iOS конфигурация
```

## Известные особенности

1. **Структура проекта**: Файлы находятся в подпапке `maychurchsong_flutter/` для сохранения совместимости с assets.

2. **Первый запуск**: При первом запуске приложение копирует базу данных из assets, это может занять несколько секунд.

3. **Фоновые обновления**: 
   - На Android используется WorkManager
   - На iOS используется BackgroundFetch
   - Интервал можно настроить в настройках

4. **Разрешения**:
   - Android: INTERNET, ACCESS_NETWORK_STATE (уже добавлены)
   - iOS: NSAppTransportSecurity настроен для HTTP запросов

## Тестирование

### Проверка функциональности:
1. Открыть приложение
2. Проверить загрузку списка песен
3. Протестировать поиск (по номеру и тексту)
4. Добавить песню в избранное
5. Открыть песню и протестировать масштабирование
6. Проверить настройки (тема, размер шрифта)
7. Запустить ручное обновление базы данных

### Проверка на iOS:
1. Убедиться, что дизайн использует Cupertino виджеты
2. Проверить навигацию с помощью CupertinoTabBar
3. Проверить адаптивные диалоги

## Проблемы и решения

### Ошибка: "Cannot find module"
```bash
flutter clean
flutter pub get
flutter run
```

### Ошибка сборки Android
```bash
cd android
./gradlew clean
cd ..
flutter build apk
```

### Ошибка iOS (только macOS)
```bash
cd ios
pod install
cd ..
flutter build ios
```

## Поддержка

Для вопросов и предложений обращайтесь к разработчикам Майской Церкви.

