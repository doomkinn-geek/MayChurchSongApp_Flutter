import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';

class AdaptiveScaffold extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTabChanged;
  final List<AdaptiveTab> tabs;
  final List<Widget> screens;

  const AdaptiveScaffold({
    Key? key,
    required this.currentIndex,
    required this.onTabChanged,
    required this.tabs,
    required this.screens,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (Platform.isIOS) {
      return CupertinoTabScaffold(
        tabBar: CupertinoTabBar(
          currentIndex: currentIndex,
          onTap: onTabChanged,
          items: tabs
              .map((tab) => BottomNavigationBarItem(
                    icon: Icon(tab.cupertinoIcon ?? tab.icon),
                    label: tab.label,
                  ))
              .toList(),
        ),
        tabBuilder: (context, index) {
          return CupertinoTabView(
            builder: (context) => screens[index],
          );
        },
      );
    }

    return Scaffold(
      body: IndexedStack(
        index: currentIndex,
        children: screens,
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: currentIndex,
        onDestinationSelected: onTabChanged,
        destinations: tabs
            .map((tab) => NavigationDestination(
                  icon: Icon(tab.icon),
                  label: tab.label,
                ))
            .toList(),
      ),
    );
  }
}

class AdaptiveTab {
  final String label;
  final IconData icon;
  final IconData? cupertinoIcon;

  const AdaptiveTab({
    required this.label,
    required this.icon,
    this.cupertinoIcon,
  });
}

