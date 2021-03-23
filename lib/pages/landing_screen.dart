import 'package:expense_management/pages/components/custom_card.dart';
import 'package:expense_management/pages/expenses.dart';
import 'package:flutter/material.dart';

class LandingPage extends StatefulWidget {
  static const String route = '/';
  @override
  _LandingPageState createState() => _LandingPageState();
}

class _LandingPageState extends State<LandingPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: SafeArea(
          child: Drawer(
        child: ListView(
          children: [
            Container(
              decoration: BoxDecoration(color: Theme.of(context).primaryColor),
              padding: EdgeInsets.all(17.5),
              child: Text(
                "Menus",
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Theme.of(context).accentColor),
              ),
            ),
            ListTile(
              leading: Icon(Icons.money_off_outlined),
              title: Text("Expenses"),
              onTap: () {
                Navigator.of(context).pop();
                Navigator.of(context).pushNamed(Expenses.route);
              },
            ),
            ListTile(
              leading: Icon(Icons.attach_money_outlined),
              title: Text('Incomes'),
              onTap: () {
                Navigator.of(context).pop();
              },
            ),
            ListTile(
              leading: Icon(Icons.payments_outlined),
              title: Text('Bill'),
              onTap: () {
                Navigator.of(context).pop();
              },
            )
          ],
        ),
      )),
      appBar: AppBar(
        title: Text('Expense Management'),
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    return Container(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          _expenseReport(),
          _itemTypePercentage(),
        ],
      ),
    );
  }

  Widget _expenseReport() {
    return CustomCard(title: "Current Month Expenses", child: Container(),);
  }

  Widget _itemTypePercentage() {
    return CustomCard(title: "Expenses Percentage Per Type", child: Card(
        margin: EdgeInsets.all(5),
        child: Container(
          padding: EdgeInsets.all(5),
          child: Row(
            children: [
              Expanded(child: Text('Total Expenses')),
              InkWell(
                child: Container(
                  height: 100,
                  width: 100,
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: Colors.grey,
                      width: 1,
                    ),
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    'Manage Expenses',
                    textAlign: TextAlign.center,
                  ),
                ),
              )
            ],
          ),
        )),);
  }
}
