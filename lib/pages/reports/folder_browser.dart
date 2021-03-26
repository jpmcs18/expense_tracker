import 'dart:io';
import 'dart:typed_data';
import 'dart:ui';

import 'package:expense_management/models/reports/folder_arguments.dart';
import 'package:flutter/material.dart';
import 'package:path/path.dart';
import 'package:permission_handler/permission_handler.dart';

class FolderBrowser extends StatefulWidget {
  static const String route = '/folder';

  FolderBrowser({required this.args});
  final FolderArguments args;
  @override
  FolderBrowserState createState() => FolderBrowserState();
}

class FolderBrowserState extends State<FolderBrowser> {
  List<Directory?> _folders = [];
  Directory? _directory;
  List<Directory> _selectedDir = [];
  int _cnt = 0;
  final _ctrlFileName = TextEditingController();

  @override
  void initState() {
    super.initState();
    setState(() {
      _ctrlFileName.text = widget.args.filename ?? '';
    });
    _initializeFolders();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            Expanded(child: Text('Select Folder'))
          ],
        ),
      ),
      body: Column(children: [
        Container(
          alignment: Alignment.centerLeft,
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: _selectedDir.map((e) {
                var w = Container(
                    child: Row(children: [
                  Icon(Icons.arrow_right),
                  InkWell(
                    child: Container(
                      child: Text(
                        basename(e.path),
                        style: TextStyle(color: (_cnt != _selectedDir.length - 1) ? Colors.black : Theme.of(context).primaryColor),
                      ),
                      margin: EdgeInsets.all(5),
                    ),
                    onTap: () {
                      _getFolder(e);
                    },
                  )
                ]));

                setState(() {
                  _cnt++;
                });

                return w;
              }).toList(),
            ),
          ),
        ),
        Expanded(
            child: ListView.builder(
                itemCount: _folders.length,
                itemBuilder: (context, index) {
                  return ListTile(
                    leading: Icon(Icons.folder),
                    title: Container(
                      child: Text(
                        basename(_folders[index]?.path ?? ''),
                      ),
                      margin: EdgeInsets.all(5),
                    ),
                    onTap: () {
                      _getFolder(_folders[index]);
                    },
                  );
                })),
        Card(
          child: Container(
            margin: EdgeInsets.all(10),
            child: Row(
              children: [
                Expanded(
                    child: TextField(
                  controller: _ctrlFileName,
                  decoration: InputDecoration(labelText: 'File Name'),
                )),
                IconButton(
                    icon: Icon(Icons.save),
                    onPressed: () {
                      _saveQRCode(context);
                    })
              ],
            ),
          ),
        )
      ]),
    );
  }

  _initializeFolders() async {
    _getFolder(Directory('/storage/emulated/0'));
  }

  _getFolder(Directory? directory) async {
    if (directory == null) return;
    try {
      if (await Permission.storage.status.isGranted) {
        List<Directory?> d = await directory
            .list()
            .asyncMap((event) async {
              var p = Directory(event.path);
              if ((await FileSystemEntity.type(p.path)) == FileSystemEntityType.directory) return p;
              return null;
            })
            .where((event) => event != null)
            .toList();
        setState(() {
          _directory = directory;
          _folders = d;
          _breakDownFolder();
        });
      }
    } catch (e) {
      Permission.storage.request();
      _getFolder(directory);
    }
  }

  _breakDownFolder() {
    _selectedDir.clear();
    _cnt = 0;
    List<String> folders = _directory?.path.split('/') ?? [];
    String str = '';
    for (int i = 1; i < folders.length; i++) {
      str += '/' + folders[i];
      print(str);
      if (i > 2) _selectedDir.add(Directory(str));
    }
  }

  _saveQRCode(context) async {
    var path = join(_directory?.path ?? '', '${_ctrlFileName.text}.${widget.args.ext}');

    final file = await new File(path).create();
    await file.writeAsBytes(widget.args.file);

    Navigator.of(context).pop();
  }

  Future<void> writeToFile(ByteData data, String path) async {
    final buffer = data.buffer;
    await File(path).writeAsBytes(buffer.asUint8List(data.offsetInBytes, data.lengthInBytes));
  }
}
