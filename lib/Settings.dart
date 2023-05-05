import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:keep_flutter/Database/AccountDB.dart';
import 'package:keep_flutter/Model/AccountModel.dart';
import 'package:keep_flutter/Util/Constant.dart';
import 'package:keep_flutter/widgets.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';

class Settings extends StatefulWidget {
  const Settings({Key? key}) : super(key: key);

  @override
  State<Settings> createState() => _SettingsState();
}

class _SettingsState extends State<Settings> {
  final _formKey = GlobalKey<FormState>();

  final accountDB = AccountDB();
  final TextEditingController _sqlQueryController = TextEditingController();
  final _accountList = List.empty(growable: true);

  bool isLoading = false;
  String accountData = '';
  int listCount = 0;

  @override
  void initState() {
    super.initState();
    initView();
  }

  void initView() async {
    accountDB.getAccountList().then((value) {
      setState(() {
        listCount = value.length;
      });
    });
  }

  showMessageDialog(BuildContext context, String msg) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(10.0)),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Center(
                child: Text(
                  msg,
                  textAlign: TextAlign.center,
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              child: const Text('Close'),
              onPressed: () {
                Navigator.pop(context);
                shouldReload();
              },
            ),
          ],
        );
      },
    );
  }

  void shouldReload() async {
    Navigator.pop(context, true);
  }

  exportDataToFile() async{
    setState(() {
      isLoading = ! isLoading;
    });
    accountData = '';
    _accountList.clear();
    await Future.wait([
      accountDB.getAccountList().then((value) async {
        _accountList.addAll(value);
        for(AccountModel account in _accountList){
          accountData += mapAccountData(account);
        }

        DateTime now = DateTime.now();
        String strNow = DateFormat('yyyy-MM-dd hh:mm:ss').format(now);
        final file = await File('${Constant.localPath}/exportData_$strNow.txt').create(recursive: true);
        await file.writeAsString(accountData);

      }),
    ]).then((value) {
      setState(() {
        isLoading = !isLoading;
      });
      showMessageDialog(context, "File exported successfully");
    });

  }

  String mapAccountData(AccountModel accountModel){
    return (
      'INSERT INTO Account ('
          'id, '
          'name, '
          'username, '
          'password, '
          'description, '
          'accountType, '
          'accountLoginType, '
          'createdDateTime'
      ') VALUES ('
          '${accountModel.id}, '
          '\'${accountModel.name}\', '
          '\'${accountModel.username}\', '
          '\'${accountModel.password}\', '
          '\'${accountModel.description}\', '
          '\'${accountModel.accountType}\', '
          '\'${accountModel.accountLoginType}\', '
          '${accountModel.createdDateTime}'
      ');\n'
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
        centerTitle: true,
        title: Text("Settings"),
      ),
      body: isLoading
        ? loadingIndicator()
        : SafeArea(
            child: Padding(
              padding: EdgeInsets.all(8),
              child: Container(
                  child: SingleChildScrollView(
                      child: Form(
                        key: _formKey,
                        autovalidateMode: AutovalidateMode.onUserInteraction,
                        child: Column(
                          children: [
                            TextFormField(
                              controller: _sqlQueryController,
                              maxLines: 5,
                              readOnly: false,
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Please enter some text';
                                }
                                return null;
                              },
                              decoration: InputDecoration(
                                labelText: 'SQL query',
                                enabledBorder: OutlineInputBorder(
                                  borderSide: BorderSide(color: Colors.grey, width: 2.0),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderSide: BorderSide(color: Colors.grey, width: 2.0),
                                ),
                                labelStyle: TextStyle(
                                  color: Colors.black,
                                ),
                              ),
                            ),
                            SizedBox(
                              height: 20,
                            ),
                            InkWell(
                              child: Container(
                                width: double.infinity,
                                margin: EdgeInsets.fromLTRB(5, 0, 5, 0),
                                padding: EdgeInsets.all(10),
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(10),
                                  color: Colors.blue,
                                ),
                                child: Text(
                                  'Run SQL',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              ),
                              onTap: () async {
                                if(_formKey.currentState!.validate()){
                                  final splitString = _sqlQueryController.text.split(';');
                                  print(splitString.length);
                                  print(splitString[splitString.length -1]);
                                  for(String str in splitString){
                                    str.replaceAll('\'', '');
                                    if(str.contains('INSERT')){
                                      print('run');
                                      print(str);
                                      await accountDB.insertAccountRawSQL(str);
                                    }
                                  }
                                  showMessageDialog(context, "SQL query run successfully");
                                }
                              },
                            ),
                            SizedBox(
                              height: 20,
                            ),
                            InkWell(
                              child: Container(
                                width: double.infinity,
                                margin: EdgeInsets.fromLTRB(5, 0, 5, 0),
                                padding: EdgeInsets.all(10),
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(10),
                                  color: Colors.blue,
                                ),
                                child: Text(
                                  'Run delete script',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              ),
                              onTap: () async {
                                showDialog(
                                  context: context,
                                  builder: (BuildContext context) {
                                    return AlertDialog(
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.all(Radius.circular(10.0)),
                                      ),
                                      content: Column(
                                        mainAxisSize: MainAxisSize.min,
                                        children: const [
                                          Center(
                                            child: Text(
                                              "Are you sure you want to delete all records?",
                                              textAlign: TextAlign.center,
                                            ),
                                          ),
                                        ],
                                      ),
                                      actions: [
                                        TextButton(
                                          child: const Text('No'),
                                          onPressed: () {
                                            Navigator.pop(context);
                                          },
                                        ),
                                        TextButton(
                                          child: const Text('Yes'),
                                          onPressed: () {
                                            Navigator.pop(context);
                                            accountDB.deleteAccountRawSQL().then((value) {
                                              showMessageDialog(context, 'Account deleted successfully');
                                            });
                                          },
                                        ),
                                      ],
                                    );
                                  },
                                );

                              },
                            ),
                            SizedBox(
                              height: 50,
                            ),
                            InkWell(
                              child: Container(
                                width: double.infinity,
                                margin: EdgeInsets.fromLTRB(5, 0, 5, 0),
                                padding: EdgeInsets.all(10),
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(10),
                                  color: Colors.blue,
                                ),
                                child: Text(
                                  'Export data to text file',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              ),
                              onTap: (){
                                exportDataToFile();
                              },
                            ),
                            SizedBox(
                              height: 20,
                            ),
                            Center(
                              child: Text(
                                'Number of accounts : $listCount',
                              ),
                            )
                        ],
                      ),
                    )
                )
            ),
          )
      ),
    );
  }
}
