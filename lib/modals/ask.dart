import 'package:expense_management/modals/modal_base.dart';
import 'package:flutter/material.dart';

Future<bool?> showAskModal(context, title, body) async {
  return await showModalBottomSheet<bool?>(
    context: context,
    isScrollControlled: true,
    builder: (context) {
      return Ask(context, title, body);
    },
  );
}

class Ask extends StatelessWidget {
  final BuildContext context;
  final String title;
  final String body;
  Ask(this.context, this.title, this.body);
  @override
  Widget build(BuildContext context) {
    return generateModalBody(
        Text(body),
        [
          Expanded(child: TextButton(onPressed: _no, child: Text('No'))),
          VerticalDivider(
            thickness: 1.5,
            indent: 7,
            endIndent: 7,
          ),
          Expanded(child: TextButton(onPressed: _yes, child: Text('Yes')))
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
