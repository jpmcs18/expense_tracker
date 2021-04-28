import 'dart:typed_data';

class FolderArguments {
  Uint8List? file;
  String? ext;
  String? filename;
  bool openFile;
  bool isText;
  String? text;
  FolderArguments(
      {this.file,
      this.filename,
      this.openFile = false,
      this.ext,
      this.isText = false,
      this.text});
}
