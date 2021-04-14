import 'package:expense_management/models/reports/folder_arguments.dart';
import 'package:expense_management/pages/bills.dart';
import 'package:expense_management/pages/expenses.dart';
import 'package:expense_management/pages/incomes.dart';
import 'package:expense_management/pages/landing_screen.dart';
import 'package:expense_management/pages/reports/folder_browser.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      localizationsDelegates: [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ],
      supportedLocales: [
        Locale('en'),
        Locale('zh'),
        Locale('fr'),
        Locale('es'),
        Locale('de'),
        Locale('ru'),
        Locale('ja'),
        Locale('ar'),
        Locale('fa'),
        Locale("es"),
      ],
      title: 'Expenses',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primaryColor: Colors.blue[700],
        accentColor: Colors.blue[500],
        canvasColor: Colors.blue[50],
        cardColor: Colors.white,
        buttonColor: Colors.blue[300],
        primarySwatch: Colors.blue,
        // brightness: Brightness.light
      ),
      initialRoute: LandingPage.route,
      onGenerateRoute: (setting) {
        switch (setting.name) {
          case LandingPage.route:
            return _buildRoute(setting, LandingPage());
          case Expenses.route:
            return _buildRoute(setting, Expenses());
          case Bills.route:
            return _buildRoute(setting, Bills());
          case Incomes.route:
            return _buildRoute(setting, Incomes());
          case FolderBrowser.route:
            return _buildRoute(setting,
                FolderBrowser(args: setting.arguments as FolderArguments));
          default:
            return _buildRoute(setting, LandingPage());
        }
      },
    );
  }

  MaterialPageRoute _buildRoute(RouteSettings settings, Widget page) {
    return new MaterialPageRoute(
      settings: settings,
      builder: (ctx) => SafeArea(child: page),
    );
  }
}
