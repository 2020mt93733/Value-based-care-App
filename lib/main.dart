import 'package:adaptive_theme/adaptive_theme.dart';
import 'package:background_fetch/background_fetch.dart';
import 'package:vacseen/commons.dart';
import 'package:vacseen/db/dbWrapper.dart';
import 'package:vacseen/screens/floatingActions/VaccineAlerts/alert_screen.dart';
import 'package:vacseen/screens/floatingActions/VaccineAlerts/vaccine_alert_functions.dart';
import 'package:vacseen/screens/welcome/welcome_screen.dart';
import 'package:vacseen/screens/home.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
    FlutterLocalNotificationsPlugin();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final AdaptiveThemeMode savedTheme =
      await AdaptiveTheme.getThemeMode() ?? AdaptiveThemeMode.system;

  const AndroidInitializationSettings initializationSettingsAndroid =
      AndroidInitializationSettings('@mipmap/ic_launcher');

  final InitializationSettings initializationSettings =
      InitializationSettings(android: initializationSettingsAndroid);
  flutterLocalNotificationsPlugin.initialize(initializationSettings);

  runApp(MaterialRootWidget(initialTheme: savedTheme));
  BackgroundFetch.registerHeadlessTask(backgroundFetchHeadlessTask);
}

void backgroundFetchHeadlessTask(HeadlessTask task) async {
  try {
    String taskId = task.taskId;
    if (taskId == 'flutter_background_fetch') {
      bool isTimeout = task.timeout;

      if (isTimeout) {
        BackgroundFetch.finish(taskId);
        return;
      }

      await VaccineAlertClass().getAlert();
      BackgroundFetch.finish(taskId);
    }
  } catch (_) {}
}

class MaterialRootWidget extends StatelessWidget {
  final AdaptiveThemeMode initialTheme;

  const MaterialRootWidget({this.initialTheme});

  @override
  Widget build(BuildContext context) {
    return DataBaseWrapper(
      initialTheme: initialTheme,
      child: AdaptiveTheme(
        initial: initialTheme,
        light: CommonData.getTheme(context, Brightness.light),
        dark: CommonData.getTheme(context, Brightness.dark),
        builder: (theme, darkTheme) => MaterialApp(
          theme: theme,
          darkTheme: darkTheme,
          title: CommonData.appTitle,
          initialRoute: '/',
          routes: {
            //'/': (context) => Home(),
            '/': (context) => WelcomeScreen(),
            '/alert': (context) => AlertScreen(),
          },
          debugShowCheckedModeBanner: false,
        ),
      ),
    );
  }
}
