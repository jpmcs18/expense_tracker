import 'package:expense_management/pages/expenses.dart';
import 'package:expense_management/pages/landing_screen.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Expenses',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primaryColor: Colors.blue[700],
        accentColor: Colors.white,
        canvasColor: Colors.blue[50],
        cardColor: Colors.white,
        buttonColor: Colors.blue[300],
        // brightness: Brightness.light
      ),
      initialRoute: LandingPage.route,
      onGenerateRoute: (setting) {
        switch (setting.name) {
          case LandingPage.route:
            return _buildRoute(setting, LandingPage());
          case Expenses.route:
            return _buildRoute(setting, Expenses());
          default:
            return _buildRoute(setting, LandingPage());
        }
      },
    );
  }

  MaterialPageRoute _buildRoute(RouteSettings settings, Widget page) {
    return new MaterialPageRoute(
      settings: settings,
      builder: (ctx) => page,
    );
  }
}
