import 'dart:io';

import 'package:expense_management/modals/modal_base.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:path/path.dart';
import 'package:permission_handler/permission_handler.dart';

Future<bool?> showFolderManager(context, path) async {
  return await showModalBottomSheet<bool?>(
    context: context,
    isScrollControlled: true,
    builder: (context) {
      return FolderManager(path);
    },
  );
}

class FolderManager extends StatefulWidget {
  final String path;

  const FolderManager(this.path);

  @override
  State<StatefulWidget> createState() {
    return FolderManagerState();
  }
}

class FolderManagerState extends State<FolderManager> {
  String _path = '';

  final _ctrlFolderName = TextEditingController();

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    setState(() {
      _path = widget.path;
    });
  }

  @override
  Widget build(BuildContext context) {
    return generateModalBody(
      Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextFormField(
              decoration: InputDecoration(labelText: 'Name'),
              controller: _ctrlFolderName,
              validator: (v) {
                return v == null || v.isEmpty ? "empty..." : null;
              },
            ),
          ],
        ),
      ),
      [
        Expanded(
            child: TextButton(
                onPressed: () {
                  _cancel(context);
                },
                child: Text('Cancel'))),
        VerticalDivider(
          thickness: 1.5,
          indent: 7,
          endIndent: 7,
        ),
        Expanded(
            child: TextButton(
                onPressed: () {
                  _saveFolder(context);
                },
                child: Text('Create')))
      ],
      header: "Manage Folder",
    );
  }

  _cancel(BuildContext context) {
    setState(() {
      _path = '';
      _ctrlFolderName.clear();
    });
    Navigator.of(context).pop(false);
  }

  _saveFolder(BuildContext context) async {
    try {
      if (_formKey.currentState?.validate() ?? false) {
        if (await Permission.storage.status.isGranted) {
          Directory dir = Directory(join(_path, _ctrlFolderName.text));
          if (await dir.exists()) {
            Fluttertoast.showToast(msg: "folder already exists");
            return;
          }
          await dir.create();
          Navigator.of(context).pop(true);
        } else {
          Permission.storage.request();
          await _saveFolder(context);
        }
      }
    } catch (e) {
      Fluttertoast.showToast(msg: 'Unable to create folder');
    }
  }
}
