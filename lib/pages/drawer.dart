import 'package:expense_management/models/menu.dart';
import 'package:expense_management/pages/bills.dart';
import 'package:expense_management/pages/expenses.dart';
import 'package:expense_management/pages/incomes.dart';
import 'package:expense_management/pages/landing_screen.dart';
import 'package:expense_management/providers/google_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class MainDrawer extends StatefulWidget {
  final String? route;
  MainDrawer(this.route);
  @override
  _MainDrawerState createState() => _MainDrawerState();
}

class _MainDrawerState extends State<MainDrawer> {
  List<Menu> _menuItems = [
    Menu(
        icon: Icon(Icons.home_outlined),
        location: 'Dashboard',
        route: LandingPage.route),
    Menu(
        icon: Icon(Icons.attach_money_outlined),
        location: 'Incomes',
        route: Incomes.route),
    Menu(
        icon: Icon(Icons.money_off_outlined),
        location: 'Expenses',
        route: Expenses.route),
    Menu(
        icon: Icon(Icons.payments_outlined),
        location: 'Bill',
        route: Bills.route),
  ];

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
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
                child: ClipOval(
                    child: context.watch<GoogleProvider>().user?.photoUrl ==
                            null
                        ? Image.asset('asset/user.png')
                        : Image.network(
                            context.watch<GoogleProvider>().user!.photoUrl!)),
                // child: ClipOval(child: context.watch<User>().imageUrl == null ? Image.asset('asset/user.png') : Image.network(context.watch<User>().imageUrl!)),
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.start,
                  mainAxisSize: MainAxisSize.max,
                  children: [
                    context.watch<GoogleProvider>().isLoggedIn
                        ? Text(
                            context.watch<GoogleProvider>().user?.displayName ??
                                '',
                            style: TextStyle(
                                fontWeight: FontWeight.bold, fontSize: 20),
                            softWrap: true,
                          )
                        : Text('Login to view data'),
                    if (context.watch<GoogleProvider>().isLoggedIn)
                      Text(
                        context.watch<GoogleProvider>().user?.email ?? '',
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
          context.watch<GoogleProvider>().isLoggedIn
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
                ),
        ],
      ),
    ));
  }

  Future<void> _onLogin() async {
    await context.read<GoogleProvider>().signInWithGoogle();
    // await context.read<User>().login();
  }

  Future<void> _onLogout() async {
    // await context.read<User>().logout();
    await context.read<GoogleProvider>().signOut();
  }
}
