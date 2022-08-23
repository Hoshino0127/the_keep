import 'dart:ffi';
import 'dart:typed_data';

import 'package:encrypt/encrypt.dart';
import 'package:keep_flutter/Util/Constant.dart';

class EncryptDecrypt{
  static Encrypted? encrypted;
  static var decrypted;

  static setEncrypted(String encoded){
    encrypted = Encrypted.from64(encoded);
  }

  static encryptAES(plainText){
    final key = Key.fromUtf8(Constant.key);
    final iv = IV.fromLength(16);
    final encryptor = Encrypter(AES(key));
    encrypted = encryptor.encrypt(plainText, iv: iv);
    print("Encrypted: " + encrypted!.base64);
  }

  static decryptAES(plainText){
    final key = Key.fromUtf8(Constant.key);
    final iv = IV.fromLength(16);
    final encryptor = Encrypter(AES(key));
    decrypted = encryptor.decrypt(encrypted!, iv: iv);
    print("Decrypted: " + decrypted);
  }
}