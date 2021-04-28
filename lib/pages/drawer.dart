import 'dart:io';

import 'package:expense_management/models/menu.dart';
import 'package:expense_management/pages/bills.dart';
import 'package:expense_management/pages/expenses.dart';
import 'package:expense_management/pages/incomes.dart';
import 'package:expense_management/pages/landing_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_login_facebook/flutter_login_facebook.dart';

class MainDrawer extends StatefulWidget {
  final String? route;
  MainDrawer(this.route);
  @override
  _MainDrawerState createState() => _MainDrawerState();
}

class _MainDrawerState extends State<MainDrawer> {
  final plugin = FacebookLogin(debug: true);
  String? _sdkVersion;
  FacebookAccessToken? _token;
  FacebookUserProfile? _profile;
  String? _email;
  String? _imageUrl;
  List<Menu> _menuItems = [
    Menu(icon: Icon(Icons.attach_money_outlined), location: 'Incomes', route: Incomes.route),
    Menu(icon: Icon(Icons.money_off_outlined), location: 'Expenses', route: Expenses.route),
    Menu(icon: Icon(Icons.payments_outlined), location: 'Bill', route: Bills.route),
  ];

  @override
  void initState() {
    super.initState();

    _getSdkVersion();
    _updateLoginInfo();
  }

  @override
  Widget build(BuildContext context) {
    final isLogin = _token != null && _profile != null;
    return SafeArea(
        child: Drawer(
      child: ListView(
        children: [
          InkWell(
            child: Container(
              decoration: BoxDecoration(color: Theme.of(context).primaryColor),
              padding: EdgeInsets.all(17.5),
              child: Text(
                "Menus",
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white),
              ),
            ),
            onTap: () {
              Navigator.of(context).pop();
              Navigator.of(context).pushReplacementNamed(LandingPage.route);
            },
          ),
          Center(
          child: Column(
            children: <Widget>[
              if (_sdkVersion != null) Text('SDK v$_sdkVersion'),
              if (isLogin)
                Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: _buildUserInfo(context, _profile!, _token!, _email),
                ),
              isLogin
                  ? InkWell(
                      child: Text('Log Out'),
                      onTap: _onLogout,
                    )
                  : InkWell(
                      child: Text('Log In'),
                      onTap: _onLogin,
                    ),
            ],
          ),
        ),
          ..._menuItems.map(
            (e) => ListTile(
              leading: e.icon,
              title: Text(
                e.location!,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
              onTap: () {
                Navigator.of(context).pop();
                Navigator.of(context).pushReplacementNamed(e.route!);
              },
              selected: e.route == widget.route,
            ),
          ),
        ],
      ),
    ));
  }

  Widget _buildUserInfo(BuildContext context, FacebookUserProfile profile,
      FacebookAccessToken accessToken, String? email) {
    final avatarUrl = _imageUrl;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (avatarUrl != null)
          Center(
            child: Image.network(avatarUrl),
          ),
        Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            const Text('User: '),
            Text(
              '${profile.firstName} ${profile.lastName}',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ],
        ),
        const Text('AccessToken: '),
        Text(
          accessToken.token,
          softWrap: true,
        ),
        if (email != null) Text('Email: $email'),
      ],
    );
  }
  
  Future<void> _onLogin() async {
    await plugin.logIn(permissions: [
      FacebookPermission.publicProfile,
      FacebookPermission.email,
    ]);
    await _updateLoginInfo();
  }

  Future<void> _onLogout() async {
    await plugin.logOut();
    await _updateLoginInfo();
  }


  Future<void> _getSdkVersion() async {
    final sdkVesion = await plugin.sdkVersion;
    setState(() {
      _sdkVersion = sdkVesion;
    });
  }

  Future<void> _updateLoginInfo() async {
    final token = await plugin.accessToken;
    FacebookUserProfile? profile;
    String? email;
    String? imageUrl;

    if (token != null) {
      profile = await plugin.getUserProfile();
      if (token.permissions.contains(FacebookPermission.email.name)) {
        email = await plugin.getUserEmail();
      }
      imageUrl = await plugin.getProfileImageUrl(width: 100);
    }

    setState(() {
      _token = token;
      _profile = profile;
      _email = email;
      _imageUrl = imageUrl;
    });
  }
}
