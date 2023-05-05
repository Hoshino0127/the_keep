import 'package:flutter/material.dart';
import 'package:keep_flutter/widgets.dart';
import 'package:keep_flutter/Util/AuthService.dart';

class Login extends StatefulWidget {
  const Login({Key? key}) : super(key: key);

  @override
  State<Login> createState() => _LoginState();
}

class _LoginState extends State<Login> {
  Future<void> _authenticate() async {
    bool authenticated = await AuthService.authenticate(context);
    if(authenticated){
      Navigator.popAndPushNamed(context, '/account_list');
    }else{
      showMessageDialog(context, 'Please authenticate your identity before continue');
    }
  }

  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: InkWell(
            child: Container(
              padding: EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.blue,
                borderRadius: BorderRadius.circular(10)
              ),
              child: Text(
                'Authenticate',
                style: TextStyle(
                  color: Colors.white,
                ),
              ),
            ),
            onTap: () {
              _authenticate();
            },
          ),
        ),
      ),
    );
  }
}
