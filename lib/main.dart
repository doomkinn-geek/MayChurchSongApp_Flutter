import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';
import 'data/database/song_dao.dart';
import 'data/repositories/song_repository.dart';
import 'data/services/preferences_service.dart';
import 'data/services/background_update_service.dart';
import 'ui/themes/app_theme.dart';
import 'ui/themes/ios_theme.dart';
import 'ui/screens/home_screen.dart';
import 'ui/screens/recent_screen.dart';
import 'ui/screens/favorites_screen.dart';
import 'ui/screens/settings_screen.dart';
import 'ui/widgets/adaptive_scaffold.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Инициализируем PreferencesService
  final preferencesService = PreferencesService();
  await preferencesService.init();

  // Инициализируем Repository
  final songDao = SongDao();
  final songRepository = SongRepository(songDao);

  // Инициализируем фоновое обновление
  if (Platform.isAndroid) {
    await BackgroundUpdateService.initializeAndroid(preferencesService);
  } else if (Platform.isIOS) {
    await BackgroundUpdateService.initializeIOS(preferencesService);
  }

  // Инициализируем базу данных, если необходимо
  await songRepository.initializeDatabaseIfNeeded();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider.value(value: preferencesService),
        Provider.value(value: songRepository),
      ],
      child: const MayChurchSongApp(),
    ),
  );
}

class MayChurchSongApp extends StatelessWidget {
  const MayChurchSongApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final prefs = context.watch<PreferencesService>();
    final interfaceFontSize = AppTheme.getInterfaceFontSize(prefs.interfaceFontSize);

    // Определяем тему
    final isDarkTheme = prefs.useSystemTheme
        ? MediaQuery.platformBrightnessOf(context) == Brightness.dark
        : prefs.isDarkTheme;

    if (Platform.isIOS) {
      return CupertinoApp(
        title: 'Духовные песни',
        theme: isDarkTheme
            ? IOSTheme.darkTheme(interfaceFontSize)
            : IOSTheme.lightTheme(interfaceFontSize),
        home: const MainScreen(),
        debugShowCheckedModeBanner: false,
      );
    }

    return MaterialApp(
      title: 'Духовные песни',
      theme: AppTheme.lightTheme(interfaceFontSize),
      darkTheme: AppTheme.darkTheme(interfaceFontSize),
      themeMode: prefs.useSystemTheme
          ? ThemeMode.system
          : (prefs.isDarkTheme ? ThemeMode.dark : ThemeMode.light),
      home: const MainScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class MainScreen extends StatefulWidget {
  const MainScreen({Key? key}) : super(key: key);

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _currentIndex = 0;

  final List<Widget> _screens = const [
    HomeScreen(),
    RecentScreen(),
    FavoritesScreen(),
    SettingsScreen(),
  ];

  final List<AdaptiveTab> _tabs = const [
    AdaptiveTab(
      label: 'Главная',
      icon: Icons.home,
      cupertinoIcon: CupertinoIcons.home,
    ),
    AdaptiveTab(
      label: 'Недавние',
      icon: Icons.history,
      cupertinoIcon: CupertinoIcons.clock,
    ),
    AdaptiveTab(
      label: 'Избранное',
      icon: Icons.favorite,
      cupertinoIcon: CupertinoIcons.heart,
    ),
    AdaptiveTab(
      label: 'Настройки',
      icon: Icons.settings,
      cupertinoIcon: CupertinoIcons.settings,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return AdaptiveScaffold(
      currentIndex: _currentIndex,
      onTabChanged: (index) {
        setState(() {
          _currentIndex = index;
        });
      },
      tabs: _tabs,
      screens: _screens,
    );
  }
}
