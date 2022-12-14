import 'package:valuebasedcare/commons.dart';
import 'package:valuebasedcare/global_functions.dart';
import 'package:valuebasedcare/interface/batteryWarning.dart';
import 'package:valuebasedcare/interface/fade_indexed_stack.dart';
import 'package:valuebasedcare/interface/markdown.dart';
import 'package:valuebasedcare/interface/placeholderScaffold.dart';
import 'package:valuebasedcare/interface/themeDialog.dart';
import 'package:valuebasedcare/screens/todayScreen/dayScreen.dart';
import 'package:valuebasedcare/screens/user_locations.dart';
import 'package:valuebasedcare/screens/weekScreen/weekScreen.dart';
import 'package:valuebasedcare/screens/GMap/location_update.dart';
import 'package:valuebasedcare/screens/GMap/gmap.dart';
import 'package:valuebasedcare/screens/Statistics/stats_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Home extends StatefulWidget {
  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  int _currentIndex = 0;
  Future<void> futureIndex;
  final GlobalFunctions _globalFunctions = GlobalFunctions();

  final List<Widget> widgets = [
    UserLocations(),
    DayScreen(isToday: true),
    GMap(),
    StatsScreen(),
  ];

  @override
  void initState() {
    futureIndex = getLastSelectedTab();
    essentialTasks();
    super.initState();
  }

  Future<void> essentialTasks() async {
    // To Display Changelog
    bool value = await _globalFunctions.isAppNewVersion();

    if (value) {
      String changelog = await rootBundle.loadString('assets/CHANGELOG.md');

      if (changelog == null) return;

      final route = MaterialPageRoute(
        builder: (context) => MarkDownView(changelog: changelog),
      );

      await Navigator.push(context, route);
    }

    // Check battery optimization.
    bool batteryCheck = await _globalFunctions.batteryOptimizationCheck();
    if (!batteryCheck && await _globalFunctions.getBatteryPref())
      await showDialog(
        context: context,
        builder: (context) => BatteryWarning(),
      );

    _globalFunctions.askForReview();
  }

  Future<void> getLastSelectedTab() async {
    try {
      final pref = await SharedPreferences.getInstance();
      int tabIndex = pref.getInt('tab_index') ?? 0;

      setState(() => _currentIndex = tabIndex);
    } catch (_) {}
  }

  Future<void> setLastSelectedTab(int index) async {
    try {
      final pref = await SharedPreferences.getInstance();
      await pref.setInt('tab_index', index);
    } catch (_) {}
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: futureIndex,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.done) {
          return Scaffold(
            appBar: AppBar(
              title: Text(
                CommonData.appTitle,
              ),
            ),
            body: Padding(
              padding: const EdgeInsets.all(10.0),
              child: FadeIndexedStack(
                duration: const Duration(milliseconds: 300),
                index: _currentIndex,
                children: widgets,
              ),
            ),
            floatingActionButton: SpeedDial(
              backgroundColor: Theme.of(context).primaryColor,
              foregroundColor: Colors.white,
              animatedIcon: AnimatedIcons.menu_close,
              buttonSize: 60.0,
              animationSpeed: 90,
              tooltip: 'More Actions',
              renderOverlay: false,
              overlayOpacity: 0.0,
              children: _loadSpeedDialList(),
            ),
            bottomNavigationBar: BottomNavigationBar(
              currentIndex: _currentIndex,
              type: BottomNavigationBarType.fixed,
              items: [
                _bottomNavItem(Icons.explore_rounded, 'Locations'),
                _bottomNavItem(Icons.today_rounded, 'Today'),
                _bottomNavItem(Icons.wc_rounded, 'Crowd'),
                _bottomNavItem(Icons.analytics_outlined, 'Dashboard'),
              ],
              onTap: (int n) {
                setLastSelectedTab(n);
                setState(() => _currentIndex = n);
              },
            ),
          );
        } else
          return PlaceHolderScaffold();
      },
    );
  }

  _bottomNavItem(IconData icon, String label) => BottomNavigationBarItem(
        icon: Icon(
          icon,
        ),
        label: label,
      );

  SpeedDialChild speedDialItem(
      String label, VoidCallback function, IconData icon) {
    bool isLightTheme = Theme.of(context).brightness == Brightness.light;
    Color fg = isLightTheme ? Colors.black : Colors.white;
    Color bg = isLightTheme ? Colors.white : Colors.grey[800];

    return SpeedDialChild(
      child: Icon(
        icon,
      ),
      label: label,
      onTap: function,
      labelBackgroundColor: bg,
      foregroundColor: fg,
      backgroundColor: bg,
      labelStyle: TextStyle(
        color: fg,
      ),
    );
  }

  List<SpeedDialChild> _loadSpeedDialList() {
    final List<SpeedDialChild> list1 = [
      speedDialItem(
        'Set Alerts',
        () => Navigator.pushNamed(context, '/alert'),
        Icons.notifications_active_outlined,
      ),
      speedDialItem(
        'CoWIN Website',
        () => _globalFunctions.launchURL('https://www.cowin.gov.in/home'),
        Icons.public_outlined,
      ),
    ];

    final List<SpeedDialChild> list2 = [
      speedDialItem(
        'CoWin App',
        () => _globalFunctions.launchApp(CommonData.coWin),
        Icons.launch_outlined,
      ),
      speedDialItem(
        'Change Theme',
        () => showDialog(context: context, builder: (context) => ThemeDialog()),
        Icons.lightbulb_outline_rounded,
      ),
      speedDialItem(
        'Review our App',
        () => _globalFunctions.showPlayStorePage(),
        Icons.star_border_outlined,
      ),
      speedDialItem(
        'About',
        () => _globalFunctions.displayAbout(context),
        Icons.info_outline_rounded,
      ),
    ];

    if (MediaQuery.of(context).orientation == Orientation.portrait)
      return [
        ...list1,
        ...list2,
      ];
    else
      return list1;
  }
}
