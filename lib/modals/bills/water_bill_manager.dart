import 'package:expense_management/databases/main_db.dart';
import 'package:expense_management/models/bills/water_bill.dart';
import 'package:flutter/material.dart';
import 'package:expense_management/modals/modal_base.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:expense_management/helpers/extensions/format_extension.dart';
import 'package:month_picker_dialog/month_picker_dialog.dart';

Future<bool?> showWaterBillManager(context, waterBill) async {
  return await showModalBottomSheet<bool?>(
    context: context,
    isScrollControlled: true,
    builder: (context) {
      return WaterBillManager(waterBill);
    },
  );
}

class WaterBillManager extends StatefulWidget {
  final WaterBill waterBill;

  const WaterBillManager(this.waterBill);

  @override
  State<StatefulWidget> createState() {
    return WaterBillManagerState();
  }
}

class WaterBillManagerState extends State<WaterBillManager> {
  final MainDB db = MainDB.instance;

  WaterBill _waterBill = WaterBill();

  final DateTime _firstDate = DateTime(DateTime.now().year - 1);
  final DateTime _lastDate = DateTime.now();
  final _ctrlDate = TextEditingController();
  final _ctrlAmount = TextEditingController();

  @override
  void initState() {
    super.initState();
    setState(() {
      _waterBill = widget.waterBill;
      _ctrlDate.text = _waterBill.date.formatToMonthYear();
      _ctrlAmount.text = _waterBill.amount.toString();
    });
  }

  @override
  Widget build(BuildContext context) {
    return generateModalBody(
        Form(
          child: Column(
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
              TextFormField(
                decoration: InputDecoration(labelText: 'Amount'),
                controller: _ctrlAmount,
                keyboardType: TextInputType.number,
                onChanged: (value) {
                  setState(() {
                    _waterBill.amount = num.parse(value);
                  });
                },
              ),
            ],
          ),
        ),
        [
          Expanded(
              child: TextButton(onPressed: _cancel, child: Text('Cancel'))),
          VerticalDivider(
            thickness: 1.5,
            indent: 7,
            endIndent: 7,
          ),
          Expanded(
            child: TextButton(
                onPressed: _saveWaterBill,
                child: Text(_waterBill.id == null ? 'Insert' : 'Update')),
          )
        ],
        header: "Manage Water Bill");
  }

  _getDate() async {
    showMonthPicker(
      context: context,
      firstDate: _firstDate,
      lastDate: _lastDate,
      initialDate: _waterBill.date,
      locale: Locale("en"),
    ).then((date) async {
      if (date != null) {
        setState(() {
          _waterBill.date = date;
          _ctrlDate.text = _waterBill.date.formatToMonthYear();
        });
      }
    });
  }

  _cancel() {
    setState(() {
      _waterBill = WaterBill();
      _ctrlDate.clear();
      _ctrlAmount.clear();
    });
    Navigator.of(context).pop(false);
  }

  _saveWaterBill() async {
    try {
      if (_waterBill.id == null)
        await db.insertWaterBill(_waterBill);
      else
        await db.updateWaterBill(_waterBill);
      setState(() {
        _waterBill = WaterBill();
        _ctrlDate.clear();
        _ctrlAmount.clear();
      });
      Navigator.of(context).pop(true);
    } catch (_) {
      Fluttertoast.showToast(
          msg:
              "Unable to ${_waterBill.id == null ? 'insert' : 'update'} water bill");
    }
  }
}
