import 'package:flutter/services.dart';
import 'package:keep_flutter/widgets.dart';
import 'package:local_auth/local_auth.dart';

class AuthService{
  static final auth = LocalAuthentication();

  static Future<bool> hasBiometric() async{
    try {
      return await auth.canCheckBiometrics;
    } on PlatformException catch (e) {
      return false;
    }
  }

  static Future<List<BiometricType>> getBiometrics() async{
    try{
      return await auth.getAvailableBiometrics();
    } on PlatformException catch (e) {
      return <BiometricType>[];
    }
  }

  static Future<bool> authenticate(context) async{
    final isAvailable = await hasBiometric();
    if (!isAvailable) return showMessageDialog(context,"This device does not have fingerprint access");
    try{
      return await auth.authenticate(
        localizedReason: 'Scan Fingerprint to Login',
        options: const AuthenticationOptions(
          stickyAuth: true,
        )
      );
    } on PlatformException catch (e) {
      return false;
    }
  }
}