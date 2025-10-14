# Устранение проблем

## Проблема: "System cannot find the path specified" при flutter run

### Причина
Файлы были созданы в неправильной структуре папок (`maychurchsong_flutter/maychurchsong_flutter/lib/` вместо `maychurchsong_flutter/lib/`).

### Решение ✅
**Уже исправлено!** Все файлы были скопированы в правильную структуру.

Структура теперь:
```
maychurchsong_flutter/
├── lib/
│   ├── main.dart
│   ├── data/
│   │   ├── models/
│   │   ├── database/
│   │   ├── repositories/
│   │   └── services/
│   ├── ui/
│   │   ├── screens/
│   │   ├── widgets/
│   │   └── themes/
│   └── utils/
└── assets/
    └── database/
        └── prepopulated_songs.db
```

## Проблема: "Building with plugins requires symlink support"

### Причина
Windows требует включения режима разработчика для работы с символическими ссылками.

### Решение ✅
1. Выполните: `start ms-settings:developers`
2. Включите "Режим разработчика" (Developer Mode)
3. Подтвердите установку
4. Перезапустите терминал

## Проблема: Ошибки компиляции после flutter run

### Решение
```bash
cd maychurchsong_flutter
flutter clean
flutter pub get
flutter run -d windows
```

## Проблема: "More than one device connected"

### Решение
Выберите конкретное устройство:

**Windows:**
```bash
flutter run -d windows
```

**Android (после запуска эмулятора):**
```bash
flutter run -d <android-device-id>
```

**Chrome (для быстрого тестирования UI):**
```bash
flutter run -d chrome
```

**Все устройства:**
```bash
flutter run -d all
```

## Проверка структуры проекта

Если все еще есть проблемы, проверьте что:

1. ✅ Файлы находятся в `maychurchsong_flutter/lib/`, а НЕ в `maychurchsong_flutter/maychurchsong_flutter/lib/`
2. ✅ База данных находится в `maychurchsong_flutter/assets/database/prepopulated_songs.db`
3. ✅ В `main.dart` импорты начинаются с `import 'data/...';` а не с `import '../maychurchsong_flutter/lib/...';`
4. ✅ В `pubspec.yaml` путь к assets: `- assets/database/prepopulated_songs.db`
5. ✅ В `song_database.dart` путь к assets: `'assets/database/prepopulated_songs.db'`

## Текущий статус

✅ Режим разработчика включен
✅ Структура файлов исправлена  
✅ Импорты исправлены
✅ Пути к assets исправлены
🔄 Приложение компилируется...

## Ожидаемое время первой компиляции

- **Windows**: 3-5 минут
- **Android**: 5-10 минут
- **iOS**: 5-10 минут (только на macOS)
- **Web (Chrome)**: 1-2 минуты

## Следующие действия после успешного запуска

1. ✅ Проверить загрузку списка песен
2. ✅ Протестировать поиск
3. ✅ Добавить песню в избранное
4. ✅ Проверить масштабирование текста
5. ✅ Изменить настройки

## Полезные команды

```bash
# Очистка проекта
flutter clean

# Обновление зависимостей
flutter pub get

# Проверка доступных устройств
flutter devices

# Запуск на конкретном устройстве
flutter run -d <device-id>

# Сборка release (Android)
flutter build apk --release

# Анализ проблем
flutter doctor -v

# Проверка устаревших пакетов
flutter pub outdated
```

## Контакты

Если проблема не решена, проверьте:
1. Логи компиляции в терминале
2. Версию Flutter: `flutter --version`
3. Все ли зависимости установлены: `flutter doctor`

