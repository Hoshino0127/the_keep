import 'dart:io';

import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/material.dart';
import 'package:keep_flutter/Util/Constant.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({Key? key}) : super(key: key);

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  bool _permissionReady = false;

  Future<void> fileSetup() async{
    // _bindBackgroundIsolate();
    //
    // FlutterDownloader.registerCallback(downloadCallback);

    _permissionReady = await _checkPermission();

    if (_permissionReady) {
      await _prepareSaveDir();
      print('Saved path: ' + Constant.localPath);
    }
  }

  Future<bool> _checkPermission() async {
    if (Platform.isIOS) return true;

    DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();
    AndroidDeviceInfo androidInfo = await deviceInfo.androidInfo;
    if (Theme.of(context).platform == TargetPlatform.android &&
        androidInfo.version.sdkInt! <= 28) {
      final status = await Permission.storage.status;
      if (status != PermissionStatus.granted) {
        final result = await Permission.storage.request();
        if (result == PermissionStatus.granted) {
          return true;
        }
      } else {
        return true;
      }
    } else {
      return true;
    }
    return false;
  }

  Future<void> _prepareSaveDir() async {
    Constant.localPath = (await _findLocalPath())!;
    final savedDir = Directory(Constant.localPath);
    bool hasExisted = await savedDir.exists();
    if (!hasExisted) {
      savedDir.create();
    }
  }

  Future<String?> _findLocalPath() async {
    String? externalStorageDirPath;
    if (Platform.isAndroid) {
      Directory? directory = await getExternalStorageDirectory();
      // Put file in global download folder, if for an unknown reason it didn't exist, we fallback
      // ignore: avoid_slow_async_io
      externalStorageDirPath = directory?.path;
    } else if (Platform.isIOS) {
      externalStorageDirPath = (await getApplicationDocumentsDirectory()).absolute.path;
    }
    return externalStorageDirPath;
  }

  @override
  void initState() {
    super.initState();
    initView();
  }

  void initView() async{
    //get the account list from sqflite
    Future.wait([
      fileSetup(),
    ]).then((value) {
      Navigator.popAndPushNamed(context, '/login');
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        decoration: const BoxDecoration(
          color: Color.fromARGB(255, 117, 193, 255)
        ),
        child: Center(
            child: Text(
              Constant.appName,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 30,
                fontWeight: FontWeight.bold,
                color:Colors.white,
              ),
            )
        ),
      ),
    );
  }
}
