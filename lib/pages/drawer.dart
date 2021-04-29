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
  FacebookAccessToken? _token;
  FacebookUserProfile? _profile;
  String? _email;
  String? _imageUrl;
  List<Menu> _menuItems = [
    Menu(icon: Icon(Icons.home_outlined), location: 'Dashboard', route: LandingPage.route),
    Menu(icon: Icon(Icons.attach_money_outlined), location: 'Incomes', route: Incomes.route),
    Menu(icon: Icon(Icons.money_off_outlined), location: 'Expenses', route: Expenses.route),
    Menu(icon: Icon(Icons.payments_outlined), location: 'Bill', route: Bills.route),
  ];

  @override
  void initState() {
    super.initState();

    _updateLoginInfo();
  }

  @override
  Widget build(BuildContext context) {
    final isLogin = _token != null && _profile != null;
    return SafeArea(
        child: Drawer(
      child: ListView(
        children: [
          Row(
            children: [
              Container(
                margin: EdgeInsets.all(15.0),
                height: 70,
                width: 70,
                child: ClipOval(child: _imageUrl == null ? Image.asset('asset/user.png') : Image.network(_imageUrl!)),
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.start,
                  mainAxisSize: MainAxisSize.max,
                  children: [
                    _profile == null
                        ? Text('Login to view data')
                        : Text(
                            '${_profile!.firstName} ${_profile!.lastName}',
                            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
                            softWrap: true,
                          ),
                    if (_email != null)
                      Text(
                        '$_email',
                        softWrap: true,
                      ),
                  ],
                ),
              ),
            ],
          ),
          Divider(
            endIndent: 20,
            indent: 20,
          ),
            ..._menuItems.map(
              (e) => ListTile(
                leading: e.icon,
                title: Text(
                  e.location!,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w400,
                  ),
                ),
                onTap: () {
                  Navigator.of(context).pop();
                  Navigator.of(context).pushReplacementNamed(e.route!);
                },
                selected: e.route == widget.route,
              ),
            ),
          isLogin
              ? ListTile(
                  leading: Icon(Icons.logout),
                  title: Text(
                    'Logout',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                  onTap: _onLogout,
                )
              : ListTile(
                  leading: Icon(Icons.login_outlined),
                  title: Text(
                    'Login',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                  onTap: _onLogin,
                )
        ],
      ),
    ));
  }

  Future<void> _onLogin() async {
    var res = await plugin.logIn(permissions: [
      FacebookPermission.publicProfile,
      FacebookPermission.email,
    ]);

// Check result status
    switch (res.status) {
      case FacebookLoginStatus.success:
        // Logged in

        // Send access token to server for validation and auth
        final FacebookAccessToken accessToken = res.accessToken!;
        print('Access token: ${accessToken.token}');

        // Get profile data
        final profile = await plugin.getUserProfile();
        print('Hello, ${profile!.name}! You ID: ${profile.userId}');

        // Get user profile image url
        final imageUrl = await plugin.getProfileImageUrl(width: 100);
        print('Your profile image: $imageUrl');

        // Get email (since we request email permission)
        final email = await plugin.getUserEmail();
        // But user can decline permission
        if (email != null) print('And your email is $email');

        break;
      case FacebookLoginStatus.cancel:
        // User cancel log in
        print('asdasd--');
        break;
      case FacebookLoginStatus.error:
        // Log in failed
        print('Error while log in: ${res.error}');
        break;
      default:
        print('--');
        break;
    }
    await _updateLoginInfo();
  }

  Future<void> _onLogout() async {
    await plugin.logOut();
    await _updateLoginInfo();
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
