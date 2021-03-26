import 'package:expense_management/databases/main_db.dart';
import 'package:expense_management/models/bills/electric_bill.dart';
import 'package:flutter/material.dart';
import 'package:expense_management/modals/modal_base.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:expense_management/helpers/extensions/format_extension.dart';

Future<bool?> showElectricBillManager(context, electricBill) async {
  return await showModalBottomSheet<bool?>(
    context: context,
    isScrollControlled: true,
    builder: (context) {
      return ElectricBillManager(electricBill);
    },
  );
}

class ElectricBillManager extends StatefulWidget {
  final ElectricBill electricBill;

  const ElectricBillManager(this.electricBill);

  @override
  State<StatefulWidget> createState() {
    return ElectricBillManagerState();
  }
}

class ElectricBillManagerState extends State<ElectricBillManager> {
  final MainDB db = MainDB.instance;

  ElectricBill _electricBill = ElectricBill();

  final DateTime _firstDate = DateTime(DateTime.now().year - 1);
  final DateTime _lastDate = DateTime.now();
  final _ctrlDate = TextEditingController();
  final _ctrlAmount = TextEditingController();

  @override
  void initState() {
    super.initState();
    setState(() {
      _electricBill = widget.electricBill;
      _ctrlDate.text = _electricBill.date.format(dateOnly: true);
      _ctrlAmount.text = _electricBill.amount.toString();
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
                    _electricBill.amount = num.parse(value);
                  });
                },
              ),
            ],
          ),
        ),
        [
          Expanded(child: TextButton(onPressed: _cancel, child: Text('Cancel'))),
          VerticalDivider(
            thickness: 1.5,
            indent: 7,
            endIndent: 7,
          ),
          Expanded(
            child: TextButton(onPressed: _saveElectricBill, child: Text(_electricBill.id == null ? 'Insert' : 'Update')),
          )
        ],
        header: "Manage Electric Bill");
  }

  _getDate() async {
    var date = await showDatePicker(context: context, initialDate: _electricBill.date, firstDate: _firstDate, lastDate: _lastDate);
    if (date != null) {
      setState(() {
        _electricBill.date = date;
        _ctrlDate.text = _electricBill.date.format(dateOnly: true);
      });
    }
  }

  _cancel() {
    setState(() {
      _electricBill = ElectricBill();
      _ctrlDate.clear();
      _ctrlAmount.clear();
    });
    Navigator.of(context).pop(false);
  }

  _saveElectricBill() async {
    try {
      if (_electricBill.id == null)
        await db.insertElectricBill(_electricBill);
      else
        await db.updateElectricBill(_electricBill);
      setState(() {
        _electricBill = ElectricBill();
        _ctrlDate.clear();
        _ctrlAmount.clear();
      });
      Navigator.of(context).pop(true);
    } catch (_) {
      Fluttertoast.showToast(msg: "Unable to ${_electricBill.id == null ? 'insert' : 'update'} electric bill");
    }
  }
}
