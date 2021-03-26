import 'dart:io';
import 'dart:typed_data';
import 'dart:ui';

import 'package:expense_management/modals/reports/folder_manager.dart';
import 'package:expense_management/models/reports/folder_arguments.dart';
import 'package:expense_management/pages/components/custom_button.dart';
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
  final _ctrlList = ScrollController();

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
    return WillPopScope(
      onWillPop: _checkFolder,
      child: Scaffold(
        appBar: AppBar(
          title: Row(
            children: [
              Expanded(child: Text('Select Folder')),
              InkWell(
                child: Icon(Icons.create_new_folder_outlined),
                onTap: () {
                  _makeNewFolder(context);
                },
              )
            ],
          ),
        ),
        body: Column(
          children: [
            Container(
              padding: EdgeInsets.all(10),
              decoration: BoxDecoration(color: Colors.white38),
              alignment: Alignment.centerLeft,
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                controller: _ctrlList,
                child: Row(
                  children: _selectedDir.map((e) {
                    var w = Row(
                      children: [
                        Icon(Icons.arrow_right),
                        InkWell(
                          child: Container(
                            child: Text(
                              basename(e.path.endsWith("/0") ? "Internal Storage" : e.path),
                              style: TextStyle(color: (_cnt != _selectedDir.length - 1) ? Colors.black : Theme.of(context).primaryColor, fontSize: 16),
                            ),
                          ),
                          onTap: () {
                            _getFolder(e);
                          },
                        ),
                      ],
                    );

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
                  bool isTop = index == 0;
                  bool isBottom = index == _folders.length - 1;
                  return Container(
                    decoration: BoxDecoration(
                      color: Theme.of(context).cardColor,
                      borderRadius: BorderRadius.only(topLeft: Radius.circular(isTop ? 10 : 0), topRight: Radius.circular(isTop ? 10 : 0), bottomLeft: Radius.circular(isBottom ? 10 : 0), bottomRight: Radius.circular(isBottom ? 10 : 0)),
                    ),
                    margin: EdgeInsets.only(top: isTop ? 5 : 0, bottom: isBottom ? 10 : 0, left: 10, right: 10),
                    child: Column(
                      children: [
                        ListTile(
                          leading: FutureBuilder(
                            future: FileSystemEntity.type(_folders[index]?.path ?? ''),
                            builder: (context, snapshot) {
                              if (snapshot.connectionState == ConnectionState.waiting)
                                return CircularProgressIndicator(
                                  strokeWidth: 4.0,
                                  backgroundColor: Theme.of(context).primaryColor,
                                );
                              else {
                                switch (snapshot.data) {
                                  case FileSystemEntityType.directory:
                                    return Icon(Icons.folder_outlined);
                                  case FileSystemEntityType.file:
                                    return Icon(Icons.insert_drive_file_outlined);
                                  default:
                                    return Icon(Icons.android_outlined);
                                }
                              }
                            },
                          ),
                          title: Text(
                            basename(_folders[index]?.path ?? ''),
                            style: TextStyle(fontSize: 18),
                          ),
                          onTap: () {
                            _getFolder(_folders[index]);
                          },
                        ),
                        isBottom
                            ? SizedBox()
                            : Divider(
                                height: 0,
                                thickness: 1,
                                indent: 20,
                                endIndent: 20,
                              )
                      ],
                    ),
                  );
                },
              ),
            ),
            Container(
              margin: EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
              ),
              padding: EdgeInsets.all(15),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _ctrlFileName,
                      decoration: InputDecoration(labelText: 'File Name'),
                    ),
                  ),
                  SizedBox(
                    width: 10.0,
                  ),
                  Container(
                    child: CustomButton(
                      title: 'Save',
                      icon: Icons.save_outlined,
                      onTap: () {
                        _save(context);
                      },
                    ),
                  )
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  _initializeFolders() async {
    _getFolder(Directory('/storage/emulated/0'));
  }

  _makeNewFolder(BuildContext context) async {
    if ((await showFolderManager(context, _directory?.path ?? '')) ?? false) _getFolder(_directory);
  }

  _getFolder(Directory? directory) async {
    if (await FileSystemEntity.type(directory?.path ?? '') != FileSystemEntityType.directory) return;
    if (directory == null) return;
    try {
      if (await Permission.storage.status.isGranted) {
        List<Directory?> d = await directory.list().asyncMap((event) async {
          var p = Directory(event.path);
          // if ((await FileSystemEntity.type(p.path)) == FileSystemEntityType.directory) return p;

          return p;
          // return null;
        })
            // .where((event) => event != null)
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

  _breakDownFolder() async {
    _selectedDir.clear();
    _cnt = 0;
    List<String> folders = _directory?.path.split('/') ?? [];
    String str = '';
    for (int i = 1; i < folders.length; i++) {
      str += '/' + folders[i];
      print(str);
      if (i > 2) _selectedDir.add(Directory(str));
    }

    _ctrlList.animateTo(10000, duration: Duration(seconds: 1), curve: Curves.ease);
  }

  _save(context) async {
    var path = join(_directory?.path ?? '', '${_ctrlFileName.text}.${widget.args.ext}');

    final file = await new File(path).create();
    await file.writeAsBytes(widget.args.file);

    Navigator.of(context).pop();
  }

  Future<void> writeToFile(ByteData data, String path) async {
    final buffer = data.buffer;
    await File(path).writeAsBytes(buffer.asUint8List(data.offsetInBytes, data.lengthInBytes));
  }

  Future<bool> _checkFolder() async {
    if (_selectedDir.last.path.endsWith("/0"))
      return true;
    else {
      _getFolder(_selectedDir[_selectedDir.length - 2]);
      return false;
    }
  }
}
