import 'package:expense_management/providers/google-auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart' as b;
import 'package:google_sign_in/google_sign_in.dart' as s;
import 'package:googleapis/drive/v3.dart';
import 'package:googleapis/storage/v1.dart';
import 'package:googleapis_auth/auth_io.dart';
import 'package:permission_handler/permission_handler.dart' as p;
import 'dart:io' as f;
import 'package:path/path.dart' as a;
import 'package:path_provider/path_provider.dart';

final _credentials = ServiceAccountCredentials.fromJson(r'''
{
  "private_key_id": ...,
  "private_key": ...,
  "client_email": ...,
  "client_id": ...,
  "type": "service_account"
}
''');

const _scopes = [
  StorageApi.devstorageReadOnlyScope
];

class GoogleProvider extends ChangeNotifier {
  final s.GoogleSignIn _googleSignIn = s.GoogleSignIn();
  GoogleProvider() {
    init();
  }

  Future init() async {
    await Firebase.initializeApp();
    await signInWithGoogle();
  }

  s.GoogleSignInAccount? _user;

  s.GoogleSignInAccount? get user => _user;

  set user(s.GoogleSignInAccount? user) {
    _user = user;
    notifyListeners();
  }

  bool get isLoggedIn => user != null;

  Future signOut() async {
    _googleSignIn.signOut();
    user = null;
  }

  Future tryAccessGoogleDrive() async {
    final httpClient = await clientViaServiceAccount(_credentials, _scopes);
    try {
      final storage = StorageApi(httpClient);

      final buckets = await storage.buckets.list('pictures');
      print('Received ${buckets.items?.length ?? 0} bucket names:');
      for (var file in buckets.items ?? []) {
        print(file.name);
      }
    } finally {
      httpClient.close();
    }
  }

  Future signInWithGoogle() async {
    var signin = s.GoogleSignIn.standard(scopes: [
      DriveApi.driveScope
    ]);
    user = await signin.signIn();
    // GoogleSignInAccount? googleSignInAccount = await _googleSignIn.signIn();
    // GoogleSignInAuthentication? googleSignInAuthentication = await y?.authentication;

    // AuthCredential credential = GoogleAuthProvider.credential(
    //   accessToken: googleSignInAuthentication?.accessToken,
    //   idToken: googleSignInAuthentication?.idToken,
    // );

    // await _auth.signInWithCredential(credential);

    // user = _auth.currentUser;
    // tryAccessGoogleDrive();
    //
    //
    // print("User account $user");
  }

  Future createFile(String folder, String fileName, String json) async {
    if (isLoggedIn) {
      if (await p.Permission.storage.isGranted) {
        f.Directory tempDir = (await getTemporaryDirectory());
        f.Directory saveDir = f.Directory(a.join(tempDir.path, folder));
        if (!(await saveDir.exists())) saveDir.create();
        f.File file = await f.File(a.join(saveDir.path, fileName)).create();
        await file.writeAsString(json);

        final authHeaders = await user!.authHeaders;
        final authenticateClient = GoogleAuthClient(authHeaders);
        final driveApi = DriveApi(authenticateClient);
        var driveFile = File();
        driveFile.name = fileName;
        
        await driveApi.files.create(
          driveFile,
          uploadMedia: Media(file.openRead(), file.lengthSync()),
        );

        await file.delete();
      } else {
        await p.Permission.storage.request();
        return createFile(folder, fileName, json);
      }
    }
  }
}
