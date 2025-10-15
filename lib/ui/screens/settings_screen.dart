import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';
import '../../data/services/preferences_service.dart';
import '../../data/repositories/song_repository.dart';
import '../../data/services/background_update_service.dart';
import '../widgets/platform_widgets.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _isUpdating = false;
  String? _updateMessage;

  Future<void> _checkForNewSongs() async {
    setState(() {
      _isUpdating = true;
      _updateMessage = null;
    });

    try {
      final repository = context.read<SongRepository>();
      final result = await repository.refreshSongsFromWebsite(forceUpdate: false);

      setState(() {
        _isUpdating = false;
        _updateMessage = 'Найдено новых песен: ${result.newSongsCount}\nВсего песен: ${result.totalSongsCount}';
      });

      // Обновляем время последнего обновления
      final prefs = context.read<PreferencesService>();
      await prefs.setLastUpdateTime(DateTime.now().millisecondsSinceEpoch);
    } catch (e) {
      setState(() {
        _isUpdating = false;
        _updateMessage = 'Ошибка: $e';
      });
    }
  }

  Future<void> _forceUpdate() async {
    setState(() {
      _isUpdating = true;
      _updateMessage = null;
    });

    try {
      final repository = context.read<SongRepository>();
      final result = await repository.refreshSongsFromWebsite(forceUpdate: true);

      setState(() {
        _isUpdating = false;
        _updateMessage = 'Новых песен: ${result.newSongsCount}\nОбновлено песен: ${result.updatedSongsCount}\nВсего песен: ${result.totalSongsCount}';
      });

      final prefs = context.read<PreferencesService>();
      await prefs.setLastUpdateTime(DateTime.now().millisecondsSinceEpoch);
    } catch (e) {
      setState(() {
        _isUpdating = false;
        _updateMessage = 'Ошибка: $e';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (Platform.isIOS) {
      return _buildIOSLayout();
    }
    return _buildMaterialLayout();
  }

  Widget _buildMaterialLayout() {
    final theme = Theme.of(context);
    final prefs = context.watch<PreferencesService>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Настройки'),
        backgroundColor: theme.colorScheme.primary,
        foregroundColor: Colors.white,
      ),
      body: ListView(
        children: [
          // Тема
          _buildSectionHeader('Тема', theme),
          SwitchListTile(
            title: const Text('Использовать системную тему'),
            value: prefs.useSystemTheme,
            onChanged: (value) async {
              await prefs.setUseSystemTheme(value);
            },
          ),
          if (!prefs.useSystemTheme)
            SwitchListTile(
              title: const Text('Тёмная тема'),
              value: prefs.isDarkTheme,
              onChanged: (value) async {
                await prefs.setDarkTheme(value);
              },
            ),
          const Divider(),

          // Размер шрифта песен
          _buildSectionHeader('Размер шрифта песен', theme),
          RadioListTile<int>(
            title: const Text('Малый'),
            value: PreferencesService.fontSizeSmall,
            groupValue: prefs.fontSize,
            onChanged: (value) => prefs.setFontSize(value!),
          ),
          RadioListTile<int>(
            title: const Text('Средний'),
            value: PreferencesService.fontSizeMedium,
            groupValue: prefs.fontSize,
            onChanged: (value) => prefs.setFontSize(value!),
          ),
          RadioListTile<int>(
            title: const Text('Большой'),
            value: PreferencesService.fontSizeLarge,
            groupValue: prefs.fontSize,
            onChanged: (value) => prefs.setFontSize(value!),
          ),
          const Divider(),

          // Размер шрифта интерфейса
          _buildSectionHeader('Размер шрифта интерфейса', theme),
          RadioListTile<int>(
            title: const Text('Малый'),
            value: PreferencesService.fontSizeSmall,
            groupValue: prefs.interfaceFontSize,
            onChanged: (value) => prefs.setInterfaceFontSize(value!),
          ),
          RadioListTile<int>(
            title: const Text('Средний'),
            value: PreferencesService.fontSizeMedium,
            groupValue: prefs.interfaceFontSize,
            onChanged: (value) => prefs.setInterfaceFontSize(value!),
          ),
          RadioListTile<int>(
            title: const Text('Большой'),
            value: PreferencesService.fontSizeLarge,
            groupValue: prefs.interfaceFontSize,
            onChanged: (value) => prefs.setInterfaceFontSize(value!),
          ),
          const Divider(),

          // Автообновление
          _buildSectionHeader('Обновление базы данных', theme),
          SwitchListTile(
            title: const Text('Автоматическое обновление'),
            subtitle: const Text('Проверять наличие новых песен'),
            value: prefs.isAutoUpdateEnabled,
            onChanged: (value) async {
              await prefs.setAutoUpdateEnabled(value);
              if (value) {
                await BackgroundUpdateService.scheduleUpdate(prefs.updateIntervalHours);
              } else {
                await BackgroundUpdateService.cancelUpdate();
              }
            },
          ),
          if (prefs.isAutoUpdateEnabled) ...[
            RadioListTile<int>(
              title: const Text('Каждые 12 часов'),
              value: PreferencesService.updateInterval12Hours,
              groupValue: prefs.updateIntervalHours,
              onChanged: (value) async {
                await prefs.setUpdateIntervalHours(value!);
                await BackgroundUpdateService.scheduleUpdate(value);
              },
            ),
            RadioListTile<int>(
              title: const Text('Каждые 24 часа'),
              value: PreferencesService.updateInterval24Hours,
              groupValue: prefs.updateIntervalHours,
              onChanged: (value) async {
                await prefs.setUpdateIntervalHours(value!);
                await BackgroundUpdateService.scheduleUpdate(value);
              },
            ),
            RadioListTile<int>(
              title: const Text('Каждые 48 часов'),
              value: PreferencesService.updateInterval48Hours,
              groupValue: prefs.updateIntervalHours,
              onChanged: (value) async {
                await prefs.setUpdateIntervalHours(value!);
                await BackgroundUpdateService.scheduleUpdate(value);
              },
            ),
            RadioListTile<int>(
              title: const Text('Раз в неделю'),
              value: PreferencesService.updateIntervalWeek,
              groupValue: prefs.updateIntervalHours,
              onChanged: (value) async {
                await prefs.setUpdateIntervalHours(value!);
                await BackgroundUpdateService.scheduleUpdate(value);
              },
            ),
          ],
          ListTile(
            title: const Text('Последнее обновление'),
            subtitle: Text(prefs.getFormattedLastUpdateTime()),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: ElevatedButton(
              onPressed: _isUpdating ? null : _checkForNewSongs,
              child: _isUpdating
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Text('Проверить новые песни'),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: ElevatedButton(
              onPressed: _isUpdating ? null : _forceUpdate,
              child: _isUpdating
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Text('Принудительное обновление'),
            ),
          ),
          if (_updateMessage != null)
            Padding(
              padding: const EdgeInsets.all(16),
              child: Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Text(_updateMessage!),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildIOSLayout() {
    final prefs = context.watch<PreferencesService>();

    return CupertinoPageScaffold(
      navigationBar: const CupertinoNavigationBar(
        middle: Text('Настройки'),
      ),
      child: SafeArea(
        child: ListView(
          children: [
            // Тема
            _buildIOSSectionHeader('Тема'),
            CupertinoListSection.insetGrouped(
              children: [
                CupertinoListTile(
                  title: const Text('Системная тема'),
                  trailing: CupertinoSwitch(
                    value: prefs.useSystemTheme,
                    onChanged: (value) => prefs.setUseSystemTheme(value),
                  ),
                ),
                if (!prefs.useSystemTheme)
                  CupertinoListTile(
                    title: const Text('Тёмная тема'),
                    trailing: CupertinoSwitch(
                      value: prefs.isDarkTheme,
                      onChanged: (value) => prefs.setDarkTheme(value),
                    ),
                  ),
              ],
            ),

            // Размеры шрифтов
            _buildIOSSectionHeader('Размер шрифта песен'),
            CupertinoListSection.insetGrouped(
              children: [
                _buildIOSRadioTile('Малый', PreferencesService.fontSizeSmall, prefs.fontSize, prefs.setFontSize),
                _buildIOSRadioTile('Средний', PreferencesService.fontSizeMedium, prefs.fontSize, prefs.setFontSize),
                _buildIOSRadioTile('Большой', PreferencesService.fontSizeLarge, prefs.fontSize, prefs.setFontSize),
              ],
            ),

            _buildIOSSectionHeader('Размер шрифта интерфейса'),
            CupertinoListSection.insetGrouped(
              children: [
                _buildIOSRadioTile('Малый', PreferencesService.fontSizeSmall, prefs.interfaceFontSize, prefs.setInterfaceFontSize),
                _buildIOSRadioTile('Средний', PreferencesService.fontSizeMedium, prefs.interfaceFontSize, prefs.setInterfaceFontSize),
                _buildIOSRadioTile('Большой', PreferencesService.fontSizeLarge, prefs.interfaceFontSize, prefs.setInterfaceFontSize),
              ],
            ),

            // Обновление
            _buildIOSSectionHeader('Обновление базы данных'),
            CupertinoListSection.insetGrouped(
              children: [
                CupertinoListTile(
                  title: const Text('Автообновление'),
                  trailing: CupertinoSwitch(
                    value: prefs.isAutoUpdateEnabled,
                    onChanged: (value) async {
                      await prefs.setAutoUpdateEnabled(value);
                      if (value) {
                        await BackgroundUpdateService.scheduleUpdate(prefs.updateIntervalHours);
                      } else {
                        await BackgroundUpdateService.cancelUpdate();
                      }
                    },
                  ),
                ),
              ],
            ),

            if (prefs.isAutoUpdateEnabled)
              CupertinoListSection.insetGrouped(
                children: [
                  _buildIOSRadioTile('Каждые 12 часов', PreferencesService.updateInterval12Hours, prefs.updateIntervalHours, (value) async {
                    await prefs.setUpdateIntervalHours(value);
                    await BackgroundUpdateService.scheduleUpdate(value);
                  }),
                  _buildIOSRadioTile('Каждые 24 часа', PreferencesService.updateInterval24Hours, prefs.updateIntervalHours, (value) async {
                    await prefs.setUpdateIntervalHours(value);
                    await BackgroundUpdateService.scheduleUpdate(value);
                  }),
                  _buildIOSRadioTile('Каждые 48 часов', PreferencesService.updateInterval48Hours, prefs.updateIntervalHours, (value) async {
                    await prefs.setUpdateIntervalHours(value);
                    await BackgroundUpdateService.scheduleUpdate(value);
                  }),
                  _buildIOSRadioTile('Раз в неделю', PreferencesService.updateIntervalWeek, prefs.updateIntervalHours, (value) async {
                    await prefs.setUpdateIntervalHours(value);
                    await BackgroundUpdateService.scheduleUpdate(value);
                  }),
                ],
              ),

            CupertinoListSection.insetGrouped(
              children: [
                CupertinoListTile(
                  title: const Text('Последнее обновление'),
                  subtitle: Text(prefs.getFormattedLastUpdateTime()),
                ),
              ],
            ),

            Padding(
              padding: const EdgeInsets.all(16),
              child: CupertinoButton.filled(
                onPressed: _isUpdating ? null : _checkForNewSongs,
                child: _isUpdating
                    ? const CupertinoActivityIndicator()
                    : const Text('Проверить новые песни'),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: CupertinoButton.filled(
                onPressed: _isUpdating ? null : _forceUpdate,
                child: _isUpdating
                    ? const CupertinoActivityIndicator()
                    : const Text('Принудительное обновление'),
              ),
            ),

            if (_updateMessage != null)
              Padding(
                padding: const EdgeInsets.all(16),
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: CupertinoColors.systemGrey6,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(_updateMessage!),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title, ThemeData theme) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      child: Text(
        title,
        style: theme.textTheme.titleMedium?.copyWith(
          color: theme.colorScheme.primary,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildIOSSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      child: Text(
        title.toUpperCase(),
        style: const TextStyle(
          fontSize: 13,
          color: CupertinoColors.systemGrey,
        ),
      ),
    );
  }

  Widget _buildIOSRadioTile(String title, int value, int groupValue, Function(int) onChanged) {
    return CupertinoListTile(
      title: Text(title),
      trailing: value == groupValue
          ? const Icon(CupertinoIcons.checkmark_alt, color: CupertinoColors.activeBlue)
          : null,
      onTap: () => onChanged(value),
    );
  }
}

