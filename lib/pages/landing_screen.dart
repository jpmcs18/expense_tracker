import 'package:expense_management/databases/main_db.dart';
import 'package:expense_management/models/expenses/expense_details.dart';
import 'package:expense_management/pages/bills.dart';
import 'package:expense_management/pages/components/custom_card.dart';
import 'package:expense_management/pages/expenses.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:pie_chart/pie_chart.dart';
import 'package:expense_management/helpers/extensions/format_extension.dart';

class LandingPage extends StatefulWidget {
  static const String route = '/';
  @override
  _LandingPageState createState() => _LandingPageState();
}

class _LandingPageState extends State<LandingPage> {
  final MainDB db = MainDB.instance;
  final List<ExpenseDetails> _expensesDetails = [];
  final List<DropdownMenuItem<int>> _expenseOption = [
    DropdownMenuItem(
      child: Text('Item Type'),
      value: 1,
    ),
    DropdownMenuItem(
      child: Text('Item'),
      value: 2,
    ),
    DropdownMenuItem(
      child: Text('Expense'),
      value: 3,
    ),
  ];
  int _selectedOption = 1;
  Map<String, double> _expenseReportData = {};
  num _totalExpenses = 0;
  @override
  void initState() {
    super.initState();
    _getExpensesDetails();
  }

  _getExpensesDetails() async {
    try {
      var res = await db.getExpenseDetails();
      if (res.length > 0 && this.mounted) {
        setState(() {
          _expensesDetails.clear();
          _expensesDetails.addAll(res.where((element) => element.date.isCurrentMonth()));
          _fillReport();
        });
      }
    } catch (_) {
      Fluttertoast.showToast(msg: "Something went wrong");
    }
  }

  _fillReport() {
    if (this.mounted) {
      setState(() {
        _totalExpenses = 0;
        _expenseReportData = {};
        _expensesDetails.forEach((e) {
          String _title = '';

          switch (_selectedOption) {
            case 1:
              _title = e.item?.itemType?.description ?? '';
              break;
            case 2:
              _title = e.item?.description ?? '';
              break;
            case 3:
              _title = e.expense?.title ?? '';
              break;
            default:
              break;
          }
          _expenseReportData[_title] = (_expenseReportData[_title] ?? 0) + e.totalPrice;

          _totalExpenses += e.totalPrice;
        });
      });
    }
  }

  _onSelectedOptionChange(int? value) {
    if (this.mounted) {
      setState(() {
        _selectedOption = value ?? 0;
      });
      _fillReport();
    }
  }

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
                Navigator.of(context).popAndPushNamed(Expenses.route).then((value) {
                  _getExpensesDetails();
                });
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
                Navigator.of(context).popAndPushNamed(Bills.route).then((value) {
                  _getExpensesDetails();
                });
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
    return ListView(
      children: [
        _expenseReport(),
      ],
    );
  }

  Widget _expenseReport() {
    return CustomCard(
      title: "Current Month Expenses Breakdown",
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          DropdownButtonFormField(
            decoration: InputDecoration(labelText: 'Breakdown By'),
            isExpanded: true,
            items: _expenseOption,
            value: _selectedOption,
            onChanged: _onSelectedOptionChange,
          ),
          SizedBox(
            height: 15.0,
          ),
          Row(
            children: [
              Text(
                'Total Expenses : ',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16.0),
              ),
              Text(_totalExpenses.format(), style: TextStyle(fontSize: 16.0, fontWeight: FontWeight.bold, color: Colors.red)),
            ],
          ),
          SizedBox(
            height: 15.0,
          ),
          Container(
            child: _expenseReportData.isEmpty
                ? Text('No data yet')
                : PieChart(
                    dataMap: _expenseReportData,
                    animationDuration: Duration(milliseconds: 1000),
                    chartRadius: MediaQuery.of(context).size.width,
                    initialAngleInDegree:180,
                    chartType: ChartType.disc,
                    legendOptions: LegendOptions(
                      showLegendsInRow: true,
                      legendPosition: LegendPosition.bottom,
                      showLegends: true,
                      legendShape: BoxShape.rectangle,
                      legendTextStyle: TextStyle(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    chartValuesOptions: ChartValuesOptions(
                      showChartValueBackground: false,
                      showChartValues: false,
                      showChartValuesInPercentage: true,
                      showChartValuesOutside: false,
                      decimalPlaces: 2,
                    ),
                  ),
          ),
        ],
      ),
    );
  }
}
