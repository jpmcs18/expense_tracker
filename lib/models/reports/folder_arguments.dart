import 'dart:typed_data';

class FolderArguments {
  Uint8List file;
  String ext;
  String? filename;
  FolderArguments({required this.file, this.filename, required this.ext});
}
