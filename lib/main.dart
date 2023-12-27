import 'dart:io';
import 'dart:async';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'borrow_section.dart';
import 'history_section.dart';
import 'lent_section.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return CupertinoApp(
      localizationsDelegates: const [
        DefaultMaterialLocalizations.delegate,
        DefaultWidgetsLocalizations.delegate,
      ],
      supportedLocales: const [
        Locale('en', 'US'),
      ],
      debugShowCheckedModeBanner: false,
      theme: const CupertinoThemeData(
        brightness: Brightness.dark,
      ),
      home: CupertinoTabScaffold(
        tabBar: CupertinoTabBar(
          items: const [
            BottomNavigationBarItem(
              label: 'Lent',
              icon: Icon(CupertinoIcons.money_dollar),
            ),
            BottomNavigationBarItem(
              label: 'Borrow',
              icon: Icon(CupertinoIcons.money_dollar_circle),
            ),
            BottomNavigationBarItem(
              label: 'History',
              icon: Icon(CupertinoIcons.clock),
            ),
          ],
        ),
        tabBuilder: (BuildContext context, int index) {
          Widget tabContent;
          switch (index) {
            case 0:
              tabContent = TabOneContent();
              break;
            case 1:
              tabContent = TabTwoContent();
              break;
            case 2:
              tabContent = TabThreeContent();
              break;
            default:
              tabContent = Container();
          }

          return CupertinoTabView(
            builder: (BuildContext context) => CupertinoPageScaffold(
              navigationBar: CupertinoNavigationBar(
                middle: Text('Debt Manager'),
                leading: CupertinoButton(
                  onPressed: () {
                    // Add your logic for the user icon here
                  },
                  child: Icon(CupertinoIcons.person),
                ),
                trailing: CupertinoButton(
                  onPressed: () {
                    showSettingsAlert(context);
                  },
                  child: Icon(CupertinoIcons.settings),
                ),
              ),
              child: tabContent,
            ),
          );
        },
      ),
    );
  }
}

void showSettingsAlert(BuildContext context) {
  showCupertinoDialog(
    context: context,
    builder: (BuildContext context) {
      return CupertinoAlertDialog(
        title: Text('Are you sure?'),
        content: Text('This action cannot be undone.'),
        actions: [
          CupertinoDialogAction(
            onPressed: () {
              Navigator.pop(context, 'Cancel');
            },
            child: Text('Cancel'),
          ),
          CupertinoDialogAction(
            onPressed: () async {
              await clearLocalStorage();
              restartApp();
            },
            child: Text('Reset'),
            isDestructiveAction: true,
          ),
        ],
      );
    },
  );
}

Future<void> clearLocalStorage() async {
  final SharedPreferences prefs = await SharedPreferences.getInstance();
  await prefs.clear();
}

void restartApp() {
  // Platform-specific code to restart the app
  if (Platform.isAndroid) {
    // Android-specific code
    exit(0);
  } else if (Platform.isIOS) {
    // iOS-specific code
    exit(0);
  } else {
    // Fallback for other platforms
    exit(0);
  }
}
