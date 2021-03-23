import 'package:expense_management/modals/modal_base.dart';
import 'package:flutter/material.dart';

Future<bool?> showDeleteRecordManager(context, title, body) async {
  return await showModalBottomSheet<bool?>(
    context: context,
    isScrollControlled: true,
    builder: (context) {
      return DeleteRecord(context, title, body);
    },
  );
}

class DeleteRecord extends StatelessWidget {
  final BuildContext context;
  final String title;
  final String body;
  DeleteRecord(this.context, this.title, this.body);
  @override
  Widget build(BuildContext context) {
    return generateModalBody(
        Text(body),
        [
          TextButton(onPressed: _no, child: Text('No')),
          TextButton(onPressed: _yes, child: Text('Yes'))
        ],
        header: title);
  }

  _no() {
    Navigator.of(context).pop(false);
  }

  _yes() {
    Navigator.of(context).pop(true);
  }
}
