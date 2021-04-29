import 'dart:convert';
import 'dart:io';

import 'package:expense_management/databases/main_db.dart';
import 'package:expense_management/models/backup.dart';
import 'package:expense_management/models/bills/electric_bill.dart';
import 'package:expense_management/models/bills/electric_reading.dart';
import 'package:expense_management/models/bills/person.dart';
import 'package:expense_management/models/bills/water_bill.dart';
import 'package:expense_management/models/bills/water_reading.dart';
import 'package:expense_management/models/expenses/expense_details.dart';
import 'package:expense_management/models/incomes/income.dart';
import 'package:expense_management/models/reports/bill_report.dart';
import 'package:expense_management/models/reports/folder_arguments.dart';
import 'package:expense_management/pages/components/custom_button.dart';
import 'package:expense_management/pages/components/custom_card.dart';
import 'package:expense_management/pages/drawer.dart';
import 'package:expense_management/pages/reports/folder_browser.dart';
// import 'package:firebase_core/firebase_core.dart';
// import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:month_picker_dialog/month_picker_dialog.dart';
import 'package:pie_chart/pie_chart.dart';
import 'package:expense_management/helpers/extensions/format_extension.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

class LandingPage extends StatefulWidget {
  static const String route = '/';
  @override
  _LandingPageState createState() => _LandingPageState();
}

class _LandingPageState extends State<LandingPage> {
  final MainDB db = MainDB.instance;
  // late DatabaseReference _db;
  final _ctrlDate =
      TextEditingController(text: DateTime.now().formatToMonthYear());
  final List<ExpenseDetails> _expensesDetails = [];
  final List<ElectricBill> _electricBills = [];
  final List<WaterBill> _waterBills = [];
  final List<ElectricReading> _electricReadings = [];
  final List<WaterReading> _waterReadings = [];
  final List<Person> _persons = [];
  final List<Income> _income = [];
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
      child: Text('Expense Category'),
      value: 3,
    ),
  ];

  final List<BillReport> _billReports = [];
  DateTime _selectedDate = DateTime.now();
  int _selectedOption = 1;
  Map<String, double> _expenseReportData = {};
  num _totalExpenses = 0;
  num _grandTotalIncome = 0;
  num _grandTotalExpenses = 0;
  num _electricBill = 0;
  num _waterBill = 0;
  num _electricBillPerReading = 0;
  num _waterBillPerReading = 0;

  @override
  void initState() {
    super.initState();
    _init();
  }

  Future _init() async {
    // await Firebase.initializeApp();
    // _db = FirebaseDatabase.instance.reference().child("TextValue");
    // await _db.once().then((result) => Fluttertoast.showToast(msg: 'result = ${result.value}'));
    await _getIncomeDetails();
    await _getExpensesDetails();
    await _getBillDetails();
    // _db.set("sample_asdbakjsdhkasd");
  }

  _getIncomeDetails() async {
    try {
      var res = await db.getIncomes();
      if (res.length > 0 && this.mounted) {
        setState(() {
          _income.clear();
          _income.addAll(res);
          _grandTotalIncome = res.fold(
              0, (previousValue, element) => previousValue + element.amount);
        });
      }
    } catch (_) {
      Fluttertoast.showToast(msg: "Something went wrong");
    }
  }

  _getExpensesDetails() async {
    try {
      var res = await db.getExpenseDetails();
      if (res.length > 0 && this.mounted) {
        setState(() {
          _expensesDetails.clear();
          _expensesDetails
              .addAll(res.where((element) => element.date.isCurrentMonth()));
          _grandTotalExpenses = res.fold(0,
              (previousValue, element) => previousValue + element.totalPrice);
          _fillExpensesReport();
        });
      }
    } catch (_) {
      Fluttertoast.showToast(msg: "Something went wrong");
    }
  }

  _getBillDetails() async {
    try {
      var p = await db.getPersons();
      if (p.length > 0 && this.mounted) {
        setState(() {
          _persons.clear();
          _persons.addAll(p);
        });
      }

      var eb = await db.getElectricBills();
      if (eb.length > 0 && this.mounted) {
        setState(() {
          _electricBills.clear();
          _electricBills.addAll(eb);
        });
      }

      var wb = await db.getWaterBills();
      if (wb.length > 0 && this.mounted) {
        setState(() {
          _waterBills.clear();
          _waterBills.addAll(wb);
        });
      }

      var er = await db.getElectricReadings();
      if (er.length > 0 && this.mounted) {
        setState(() {
          _electricReadings.clear();
          _electricReadings.addAll(er);
        });
      }

      var wr = await db.getWaterReadings();
      if (wr.length > 0 && this.mounted) {
        setState(() {
          _waterReadings.clear();
          _waterReadings.addAll(wr);
        });
      }

      _fillBillReport();
    } catch (_) {
      Fluttertoast.showToast(msg: "Something went wrong");
    }
  }

  _fillExpensesReport() {
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
          _expenseReportData[_title] =
              (_expenseReportData[_title] ?? 0) + e.totalPrice;

          _totalExpenses += e.totalPrice;
        });
      });
    }
  }

  _fillBillReport() {
    if (this.mounted) {
      setState(() {
        _electricBill = _electricBills
                .where((element) =>
                    element.date.formatToMonthYear() ==
                    _selectedDate.formatToMonthYear())
                .toList()
                .firstOrNull()
                ?.amount ??
            0;
        _waterBill = _waterBills
                .where((element) =>
                    element.date.formatToMonthYear() ==
                    _selectedDate.formatToMonthYear())
                .toList()
                .firstOrNull()
                ?.amount ??
            0;
        _billReports.clear();
        var _bills = _persons.map((e) {
          var currentMonthWaterReading = _waterReadings
                  .where((element) =>
                      element.person?.id == e.id &&
                      element.date.formatToMonthYear() ==
                          _selectedDate.formatToMonthYear())
                  .firstOrNull()
                  ?.reading ??
              0;
          var currentMonthElectricReading = _electricReadings
                  .where((element) =>
                      element.person?.id == e.id &&
                      element.date.formatToMonthYear() ==
                          _selectedDate.formatToMonthYear())
                  .firstOrNull()
                  ?.reading ??
              0;
          var previousMonthWaterReading = _waterReadings
                  .where((element) =>
                      element.person?.id == e.id &&
                      element.date.formatToMonthYear() ==
                          _selectedDate.previousMonth().formatToMonthYear())
                  .firstOrNull()
                  ?.reading ??
              0;
          var previousMonthElectricReading = _electricReadings
                  .where((element) =>
                      element.person?.id == e.id &&
                      element.date.formatToMonthYear() ==
                          _selectedDate.previousMonth().formatToMonthYear())
                  .firstOrNull()
                  ?.reading ??
              0;

          return BillReport(
            person: e,
            waterReading: currentMonthWaterReading,
            previousMonthWaterReading: previousMonthWaterReading,
            electricReading: currentMonthElectricReading,
            previousMonthElectricReading: previousMonthElectricReading,
          );
        }).toList();

        var waterConsumption = _bills.fold<int>(
            0,
            (previousValue, element) =>
                previousValue + element.waterConsumption);
        var electricConsumption = _bills.fold<int>(
            0,
            (previousValue, element) =>
                previousValue + element.electricConsumption);

        _waterBillPerReading =
            waterConsumption <= 0 ? 0 : (_waterBill / waterConsumption);
        _electricBillPerReading = electricConsumption <= 0
            ? 0
            : (_electricBill / electricConsumption);

        _billReports.addAll(_bills.map((e) {
          e.waterBillAmount = _waterBillPerReading * e.waterConsumption;
          e.electricBillAmount =
              _electricBillPerReading * e.electricConsumption;
          return e;
        }));
      });
    }
  }

  _onSelectedOptionChange(int? value) {
    if (this.mounted) {
      setState(() {
        _selectedOption = value ?? 0;
      });
      _fillExpensesReport();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: MainDrawer(LandingPage.route),
      appBar: AppBar(
        title: Text('Dashboard'),
      ),
      body: RefreshIndicator(onRefresh: _init, child: _buildBody()),
    );
  }

  Widget _buildBody() {
    return ListView(
      children: [
        _balanceReport(),
        _expenseReport(),
        _billsReport(),
        _backupNRestoreData(),
      ],
    );
  }

  Widget _balanceReport() {
    return CustomCard(
      isCollapsed: true,
      isCollapsible: true,
      title: "Incomes & Expenses Summary",
      child: Table(children: [
        TableRow(
          children: <Widget>[
            _buildTableChild("Total Incomes",
                fontSize: 18, color: Colors.green, fontWeight: FontWeight.w500),
            _buildTableChild(_grandTotalIncome.format(),
                alignment: Alignment.centerRight,
                fontSize: 18,
                color: Colors.green,
                fontWeight: FontWeight.w500)
          ],
        ),
        TableRow(
          children: <Widget>[
            _buildTableChild("Total Expenses",
                fontSize: 18, color: Colors.red, fontWeight: FontWeight.w500),
            _buildTableChild(_grandTotalExpenses.format(),
                alignment: Alignment.centerRight,
                fontSize: 18,
                color: Colors.red,
                fontWeight: FontWeight.w500)
          ],
        ),
        TableRow(
          children: <Widget>[
            _buildTableChild("Total Balance",
                fontSize: 18, color: Colors.blue, fontWeight: FontWeight.w500),
            _buildTableChild((_grandTotalIncome - _grandTotalExpenses).format(),
                alignment: Alignment.centerRight,
                fontSize: 18,
                color: Colors.blue,
                fontWeight: FontWeight.w500)
          ],
        ),
      ]),
    );
  }

  Widget _expenseReport() {
    return CustomCard(
      isCollapsed: true,
      isCollapsible: true,
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
              Text(_totalExpenses.format(),
                  style: TextStyle(
                      fontSize: 16.0,
                      fontWeight: FontWeight.bold,
                      color: Colors.red)),
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
                    initialAngleInDegree: 180,
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

  Widget _billsReport() {
    return CustomCard(
        title: "Monthly Bill Report",
        isCollapsible: true,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            TextFormField(
              decoration: InputDecoration(labelText: 'Date'),
              controller: _ctrlDate,
              readOnly: true,
              onTap: () {
                _getDate();
              },
            ),
            SizedBox(
              height: 15.0,
            ),
            Container(
              child: Text(
                'Electric Bill',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
              ),
              alignment: Alignment.centerLeft,
            ),
            SizedBox(
              height: 15.0,
            ),
            IntrinsicHeight(
              child: Table(
                children: [
                  TableRow(children: [
                    Row(
                      children: [
                        Text(
                          'Bill : ',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        Text(_electricBill.format(),
                            style: TextStyle(
                                color: Colors.red,
                                fontWeight: FontWeight.bold)),
                      ],
                    ),
                    Row(
                      children: [
                        Text(
                          'Per Reading : ',
                          style: TextStyle(fontWeight: FontWeight.w600),
                        ),
                        Text(_electricBillPerReading.format()),
                      ],
                    ),
                  ])
                ],
              ),
            ),
            SizedBox(
              height: 15.0,
            ),
            Table(
              children: [
                TableRow(
                  children: <Widget>[
                    _buildTableHeader('Name', alignment: Alignment.center),
                    _buildTableHeader('Old', alignment: Alignment.center),
                    _buildTableHeader('New', alignment: Alignment.center),
                    _buildTableHeader('Reading', alignment: Alignment.center),
                    _buildTableHeader('Amount', alignment: Alignment.center),
                  ],
                ),
                ..._billReports
                    .map((e) => TableRow(
                          children: <Widget>[
                            _buildTableChild(e.person?.name ?? ''),
                            _buildTableChild(
                                e.previousMonthElectricReading.toString(),
                                alignment: Alignment.center),
                            _buildTableChild(e.electricReading.toString(),
                                alignment: Alignment.center),
                            _buildTableChild(e.electricConsumption.toString(),
                                alignment: Alignment.center),
                            _buildTableChild(e.electricBillAmount.format(),
                                alignment: Alignment.centerRight)
                          ],
                        ))
                    .toList()
              ],
            ),
            SizedBox(
              height: 15.0,
            ),
            Divider(
                thickness: 2,
                endIndent: MediaQuery.of(context).size.width / 8,
                indent: MediaQuery.of(context).size.width / 8),
            SizedBox(
              height: 15.0,
            ),
            Container(
              child: Text(
                'Water Bill',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
              ),
              alignment: Alignment.centerLeft,
            ),
            SizedBox(
              height: 15.0,
            ),
            Table(
              children: [
                TableRow(
                  children: [
                    Row(
                      children: [
                        Text(
                          'Bill : ',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        Text(_waterBill.format(),
                            style: TextStyle(
                                color: Colors.red,
                                fontWeight: FontWeight.bold)),
                      ],
                    ),
                    Row(
                      children: [
                        Text(
                          'Per Reading : ',
                          style: TextStyle(fontWeight: FontWeight.w600),
                        ),
                        Text(_waterBillPerReading.format()),
                      ],
                    ),
                  ],
                ),
              ],
            ),
            SizedBox(
              height: 15.0,
            ),
            Table(
              children: [
                TableRow(
                  children: <Widget>[
                    _buildTableHeader('Name', alignment: Alignment.center),
                    _buildTableHeader('Old', alignment: Alignment.center),
                    _buildTableHeader('New', alignment: Alignment.center),
                    _buildTableHeader('Reading', alignment: Alignment.center),
                    _buildTableHeader('Amount', alignment: Alignment.center),
                  ],
                ),
                ..._billReports
                    .map((e) => TableRow(
                          children: <Widget>[
                            _buildTableChild(e.person?.name ?? ''),
                            _buildTableChild(
                                e.previousMonthWaterReading.toString(),
                                alignment: Alignment.center),
                            _buildTableChild(e.waterReading.toString(),
                                alignment: Alignment.center),
                            _buildTableChild(e.waterConsumption.toString(),
                                alignment: Alignment.center),
                            _buildTableChild(e.waterBillAmount.format(),
                                alignment: Alignment.centerRight)
                          ],
                        ))
                    .toList(),
              ],
            ),
            SizedBox(
              height: 15.0,
            ),
            Divider(
                thickness: 2,
                endIndent: MediaQuery.of(context).size.width / 8,
                indent: MediaQuery.of(context).size.width / 8),
            SizedBox(
              height: 15.0,
            ),
            Container(
              child: Text(
                'Total Bill',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
              ),
              alignment: Alignment.centerLeft,
            ),
            SizedBox(
              height: 15.0,
            ),
            Table(
              children: _billReports
                  .map((e) => TableRow(
                        children: <Widget>[
                          _buildTableChild(e.person?.name ?? ''),
                          _buildTableChild(e.totalBillAmount.format(),
                              alignment: Alignment.centerRight)
                        ],
                      ))
                  .toList(),
            ),
            SizedBox(
              height: 15.0,
            ),
            Container(
                alignment: Alignment.centerRight,
                child: CustomButton(
                  title: 'Print',
                  icon: Icons.print_outlined,
                  onTap: _printBillReport,
                ))
          ],
        ));
  }

  _buildTableHeader(String title,
      {Alignment alignment = Alignment.centerLeft}) {
    return Container(
      child: Text(
        title,
        textAlign: TextAlign.center,
        style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
      ),
      decoration: BoxDecoration(color: Color(0xFFEEEEEE)),
      padding: EdgeInsets.only(top: 5, bottom: 5),
      alignment: alignment,
    );
  }

  _buildTableChild(String title,
      {Alignment alignment = Alignment.centerLeft,
      double fontSize = 10,
      FontWeight fontWeight = FontWeight.normal,
      Color? color}) {
    return Container(
      padding: EdgeInsets.all(5),
      alignment: alignment,
      child: Text(
        title,
        style:
            TextStyle(fontSize: fontSize, fontWeight: fontWeight, color: color),
      ),
    );
  }

  _buildPDFTableHeader(String title,
      {pw.Alignment alignment = pw.Alignment.centerLeft}) {
    return pw.Container(
      child: pw.Text(
        title,
        textAlign: pw.TextAlign.center,
        style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 14),
      ),
      decoration: pw.BoxDecoration(color: PdfColor.fromInt(0xFFEEEEEE)),
      padding: pw.EdgeInsets.only(top: 5, bottom: 5),
      alignment: alignment,
    );
  }

  _buildPDFTableChild(String title,
      {pw.Alignment alignment = pw.Alignment.centerLeft,
      double fontSize = 12,
      pw.FontWeight fontWeight = pw.FontWeight.normal,
      PdfColor? color}) {
    return pw.Container(
      padding: pw.EdgeInsets.all(5),
      alignment: alignment,
      child: pw.Text(
        title,
        style: pw.TextStyle(
            fontSize: fontSize, fontWeight: fontWeight, color: color),
      ),
    );
  }

  _getDate() async {
    showMonthPicker(
      context: context,
      firstDate: DateTime.now().add(Duration(days: -500)),
      lastDate: DateTime.now(),
      initialDate: _selectedDate,
      locale: Locale("en"),
    ).then((date) async {
      if (date != null) {
        setState(() {
          _selectedDate = date;
          _ctrlDate.text = _selectedDate.formatToMonthYear();
        });
        await _fillBillReport();
      }
    });
  }

  _printBillReport() async {
    Navigator.of(context).pushNamed(FolderBrowser.route,
        arguments: FolderArguments(
            file: await _generatePDF(),
            ext: 'pdf',
            filename: _ctrlDate.text.replaceAll(' ', '')));
  }

  _generatePDF() async {
    final pdf = pw.Document();

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.legal,
        build: (pw.Context context) {
          return pw.Column(children: [
            pw.Text('Monthly Bill Report',
                style:
                    pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 25)),
            pw.SizedBox(height: 15.0),
            pw.Text(_ctrlDate.text, style: pw.TextStyle(fontSize: 18)),
            pw.SizedBox(height: 15.0),
            pw.SizedBox(
              height: 15.0,
            ),
            pw.Container(
              child: pw.Text(
                'Electric Bill',
                style: pw.TextStyle(
                    fontSize: 20, fontWeight: pw.FontWeight.normal),
              ),
              alignment: pw.Alignment.centerLeft,
            ),
            pw.SizedBox(
              height: 15.0,
            ),
            pw.Table(
              children: [
                pw.TableRow(children: [
                  pw.Row(
                    children: [
                      pw.Text(
                        'Bill : ',
                        style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                      ),
                      pw.Text(_electricBill.format(),
                          style: pw.TextStyle(
                              color: PdfColor.fromHex('F00'),
                              fontWeight: pw.FontWeight.bold)),
                    ],
                  ),
                  pw.Row(
                    children: [
                      pw.Text(
                        'Per Reading : ',
                        style: pw.TextStyle(fontWeight: pw.FontWeight.normal),
                      ),
                      pw.Text(_electricBillPerReading.format()),
                    ],
                  ),
                ])
              ],
            ),
            pw.SizedBox(
              height: 15.0,
            ),
            pw.Table(
              children: [
                pw.TableRow(
                  children: [
                    _buildPDFTableHeader('Name',
                        alignment: pw.Alignment.center),
                    _buildPDFTableHeader('Old', alignment: pw.Alignment.center),
                    _buildPDFTableHeader('New', alignment: pw.Alignment.center),
                    _buildPDFTableHeader('Reading',
                        alignment: pw.Alignment.center),
                    _buildPDFTableHeader('Amount',
                        alignment: pw.Alignment.center),
                  ],
                ),
                ..._billReports
                    .map((e) => pw.TableRow(
                          children: [
                            _buildPDFTableChild(e.person?.name ?? ''),
                            _buildPDFTableChild(
                                e.previousMonthElectricReading.toString(),
                                alignment: pw.Alignment.center),
                            _buildPDFTableChild(e.electricReading.toString(),
                                alignment: pw.Alignment.center),
                            _buildPDFTableChild(
                                e.electricConsumption.toString(),
                                alignment: pw.Alignment.center),
                            _buildPDFTableChild(e.electricBillAmount.format(),
                                alignment: pw.Alignment.centerRight)
                          ],
                        ))
                    .toList()
              ],
            ),
            pw.SizedBox(
              height: 15.0,
            ),
            pw.Divider(thickness: 2, endIndent: 20, indent: 20),
            pw.SizedBox(
              height: 15.0,
            ),
            pw.Container(
              child: pw.Text(
                'Water Bill',
                style: pw.TextStyle(
                    fontSize: 20, fontWeight: pw.FontWeight.normal),
              ),
              alignment: pw.Alignment.centerLeft,
            ),
            pw.SizedBox(
              height: 15.0,
            ),
            pw.Table(
              children: [
                pw.TableRow(
                  children: [
                    pw.Row(
                      children: [
                        pw.Text(
                          'Bill : ',
                          style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                        ),
                        pw.Text(_waterBill.format(),
                            style: pw.TextStyle(
                                color: PdfColor.fromHex('F00'),
                                fontWeight: pw.FontWeight.bold)),
                      ],
                    ),
                    pw.Row(
                      children: [
                        pw.Text(
                          'Per Reading : ',
                          style: pw.TextStyle(fontWeight: pw.FontWeight.normal),
                        ),
                        pw.Text(_waterBillPerReading.format()),
                      ],
                    ),
                  ],
                ),
              ],
            ),
            pw.SizedBox(
              height: 15.0,
            ),
            pw.Table(
              children: [
                pw.TableRow(
                  children: [
                    _buildPDFTableHeader('Name',
                        alignment: pw.Alignment.center),
                    _buildPDFTableHeader('Old', alignment: pw.Alignment.center),
                    _buildPDFTableHeader('New', alignment: pw.Alignment.center),
                    _buildPDFTableHeader('Reading',
                        alignment: pw.Alignment.center),
                    _buildPDFTableHeader('Amount',
                        alignment: pw.Alignment.center),
                  ],
                ),
                ..._billReports
                    .map((e) => pw.TableRow(
                          children: [
                            _buildPDFTableChild(e.person?.name ?? ''),
                            _buildPDFTableChild(
                                e.previousMonthWaterReading.toString(),
                                alignment: pw.Alignment.center),
                            _buildPDFTableChild(e.waterReading.toString(),
                                alignment: pw.Alignment.center),
                            _buildPDFTableChild(e.waterConsumption.toString(),
                                alignment: pw.Alignment.center),
                            _buildPDFTableChild(e.waterBillAmount.format(),
                                alignment: pw.Alignment.centerRight)
                          ],
                        ))
                    .toList(),
              ],
            ),
            pw.SizedBox(
              height: 15.0,
            ),
            pw.Divider(thickness: 2, endIndent: 20, indent: 20),
            pw.SizedBox(
              height: 15.0,
            ),
            pw.Container(
              child: pw.Text(
                'Total Bill',
                style: pw.TextStyle(
                    fontSize: 20, fontWeight: pw.FontWeight.normal),
              ),
              alignment: pw.Alignment.centerLeft,
            ),
            pw.SizedBox(
              height: 15.0,
            ),
            pw.Table(
              children: _billReports
                  .map((e) => pw.TableRow(
                        children: [
                          _buildPDFTableChild(e.person?.name ?? ''),
                          _buildPDFTableChild(e.totalBillAmount.format(),
                              alignment: pw.Alignment.centerRight)
                        ],
                      ))
                  .toList(),
            ),
          ]);
        },
      ),
    );

    return await pdf.save();
  }

  Widget _backupNRestoreData() {
    return CustomCard(
        title: "Backup & Restore",
        isCollapsed: true,
        isCollapsible: true,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            CustomButton(
              title: 'Backup',
              icon: Icons.file_download,
              onTap: _backupData,
            ),
            SizedBox(
              height: 10.0,
            ),
            CustomButton(
              title: 'Restore',
              icon: Icons.file_upload,
              onTap: _restoreData,
            ),
          ],
        ));
  }

  Future _backupData() async {
    Backup _backup = Backup();

    _backup.income = await db.getIncomes();
    _backup.incomeType = await db.getIncomeTypes();

    _backup.person = await db.getPersons();
    _backup.electricBill = await db.getElectricBills();
    _backup.electricReading = await db.getElectricReadings();
    _backup.waterBill = await db.getWaterBills();
    _backup.waterReading = await db.getWaterReadings();

    _backup.expense = await db.getExpenses();
    _backup.expenseDetails = await db.getExpenseDetails();
    _backup.item = await db.getItems();
    _backup.itemType = await db.getItemTypes();

    String backupData = jsonEncode(_backup);

    await Navigator.of(context).pushNamed(FolderBrowser.route,
        arguments: FolderArguments(
            isText: true,
            text: backupData,
            ext: 'jpmb',
            filename: DateTime.now().backupDate()));
  }

  Future _restoreData() async {
    var data = await Navigator.of(context).pushNamed(FolderBrowser.route,
        arguments: FolderArguments(openFile: true, ext: 'jpmb'));
    if (data != null) {
      var file = File((data as String));
      var read = await file.readAsString();
      Fluttertoast.showToast(msg: read);
    }
  }
}
