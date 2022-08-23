
import 'dart:convert';
import 'dart:typed_data';

import 'package:intl/intl.dart';
import 'package:flutter/material.dart';
import 'package:keep_flutter/Database/AccountDB.dart';
import 'package:keep_flutter/Model/AccountModel.dart';
import 'package:keep_flutter/Util/Constant.dart';
import 'package:keep_flutter/Util/EncryptDecrypt.dart';

class AccountDetails extends StatefulWidget {
  final AccountModel? accountModel;
  const AccountDetails({Key? key, this.accountModel}) : super(key: key);

  @override
  State<AccountDetails> createState() => _AccountDetailsState();
}

class _AccountDetailsState extends State<AccountDetails> {
  final _formKey = GlobalKey<FormState>();

  final accountDB = AccountDB();
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _createdDateTimeController = TextEditingController();

  late final List<String> _accountTypeList = List.empty(growable: true);
  late final List<String> _accountLoginTypeList = List.empty(growable: true);

  late String _selectedAccountType;
  late String _selectedAccountLoginType;
  late String _createdDateTime;

  bool _allowAdd = false;
  bool _allowUpdate = false;
  bool _allowDelete = false;

  bool _showDecrypt = false;

  bool _validatePassword = true;

  late String encryptedPassword;
  late String decryptedPassword;
  bool isValid = false;

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

  @override
  void initState() {
    super.initState();
    _accountTypeList.addAll(Constant.accountTypeList);
    _accountLoginTypeList.addAll(Constant.accountLoginTypeList);
    initView();
  }

  void initView() async{
    if(widget.accountModel != null){
      setState(() {
        //allow update and delete
        _allowAdd = false;
        _allowUpdate = true;
        _allowDelete = true;
        _nameController.text = widget.accountModel?.name ?? "";
        _usernameController.text = widget.accountModel?.username ?? "";

        _descriptionController.text = widget.accountModel?.description ?? "";
        _selectedAccountType = widget.accountModel?.accountType ?? "";
        _selectedAccountLoginType = widget.accountModel?.accountLoginType ?? "";


        DateTime createdDateTime = DateTime.fromMicrosecondsSinceEpoch(widget.accountModel?.createdDateTime ?? 0);
        print(createdDateTime);
        _createdDateTimeController.text = DateFormat('MM/dd/yyyy, hh:mm a').format(createdDateTime);

        encryptedPassword = widget.accountModel?.password ?? "";
        EncryptDecrypt.setEncrypted(encryptedPassword);
        EncryptDecrypt.decryptAES(encryptedPassword);
        decryptedPassword = EncryptDecrypt.decrypted ?? '';

        //show encrypted password by default
        _passwordController.text = encryptedPassword;
      });
    }else{
      setState(() {
        //allow add
        _allowAdd = true;
        _allowUpdate = false;
        _allowDelete = false;
        _nameController.text = "";
        _usernameController.text = "";
        _passwordController.text = "";
        _descriptionController.text = "";
        _selectedAccountType = "";
        _selectedAccountLoginType = "";

        encryptedPassword = "";
        decryptedPassword = "";
        _showDecrypt = true;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text("Details"),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(10.0),
          child: Form(
            key: _formKey,
            autovalidateMode: AutovalidateMode.onUserInteraction,
            child: Column(
              children: [
                Container(
                  padding: EdgeInsets.fromLTRB(0, 10, 0, 20),
                  width: double.infinity,
                  child: Text(
                    'Account details',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.start,
                  ),
                ),
                TextFormField(
                  controller: _nameController,
                  maxLines: 1,
                  readOnly: false,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter some text';
                    }
                    return null;
                  },
                  decoration: InputDecoration(
                    labelText: 'Name',
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
                TextFormField(
                  controller: _usernameController,
                  maxLines: 1,
                  readOnly: false,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter some text';
                    }
                    return null;
                  },
                  decoration: InputDecoration(
                    labelText: 'Username',
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
                TextFormField(
                  controller: _passwordController,
                  maxLines: 1,
                  readOnly: false,
                  validator: (value) {
                    if (value == null || value.isEmpty && _validatePassword) {
                      return 'Please enter some text';
                    }
                    return null;
                  },
                  decoration: InputDecoration(
                    suffixIcon: IconButton(
                      onPressed: () {
                        setState(() {
                          if(_passwordController.text == encryptedPassword){
                            _showDecrypt = true;

                            _passwordController.text = decryptedPassword;
                          }else if(_passwordController.text == decryptedPassword){
                            _showDecrypt = false;
                            _passwordController.text = encryptedPassword;
                          }
                        });
                      },
                      icon: Icon(Icons.repeat),
                    ),
                    labelText: 'Password',
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
                TextFormField(
                  controller: _descriptionController,
                  maxLines: 3,
                  readOnly: false,
                  decoration: InputDecoration(
                    labelText: 'Description',
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
                DropdownButtonFormField(
                  decoration: InputDecoration(
                    labelText: "Account type",
                    border: OutlineInputBorder(),
                    enabledBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.grey, width: 2.0),
                    ),
                  ),
                  value: _selectedAccountType,
                  validator: (String? value) => value == "" ? 'Required' : null,
                  onChanged: (String? value) {
                    setState(() {
                      _selectedAccountType = value!;
                    });
                  },
                  selectedItemBuilder: (BuildContext context) {
                    return _accountTypeList.map<Widget>((e) {
                      return Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          e,
                          overflow: TextOverflow.ellipsis,
                        ),
                      );
                    }).toList();
                  },
                  items: _accountTypeList.map(
                        (e) {
                      return DropdownMenuItem(
                        value: e,
                        child: _selectedAccountType != e
                            ? Text(
                          e,
                        )
                            : Container(
                          width: double.infinity,
                          decoration: BoxDecoration(
                              color: Colors.blue,
                              borderRadius: BorderRadius.circular(4.0)),
                          //color: CustomColors.primaryColor,
                          padding: EdgeInsets.all(10),
                          child: Text(
                            e,
                            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                          ),
                        ),
                      );
                    },
                  ).toList(),
                ),
                SizedBox(
                  height: 20,
                ),
                DropdownButtonFormField(
                  decoration: InputDecoration(
                    labelText: "Account login type",
                    border: OutlineInputBorder(),
                    enabledBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.grey, width: 2.0),
                    ),
                  ),
                  value: _selectedAccountLoginType,
                  validator: (String? value) => value == "" ? 'Required' : null,
                  onChanged: (String? value) {
                    setState(() {
                      _selectedAccountLoginType = value!;
                      if(_selectedAccountLoginType != "UsernamePassword"){
                        _validatePassword = false;
                      }else{
                        _validatePassword = true;
                      }
                    });
                  },
                  selectedItemBuilder: (BuildContext context) {
                    return _accountLoginTypeList.map<Widget>((e) {
                      return Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          e,
                          overflow: TextOverflow.ellipsis,
                        ),
                      );
                    }).toList();
                  },
                  items: _accountLoginTypeList.map(
                        (e) {
                      return DropdownMenuItem(
                        value: e,
                        child: _selectedAccountLoginType != e
                            ? Text(
                          e,
                        )
                            : Container(
                          width: double.infinity,
                          decoration: BoxDecoration(
                              color: Colors.blue,
                              borderRadius: BorderRadius.circular(4.0)),
                          //color: CustomColors.primaryColor,
                          padding: EdgeInsets.all(10),
                          child: Text(
                            e,
                            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                          ),
                        ),
                      );
                    },
                  ).toList(),
                ),
                SizedBox(
                  height: 20,
                ),
                TextFormField(
                  controller: _createdDateTimeController,
                  maxLines: 1,
                  readOnly: true,
                  decoration: InputDecoration(
                    labelText: 'Created Date',
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
                Row(
                  children: [
                    if(_allowAdd) Expanded(
                      flex: 1,
                      child: InkWell(
                        child: Container(
                          width: double.infinity,
                          margin: EdgeInsets.fromLTRB(5, 0, 5, 0),
                          padding: EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(10),
                            color: Colors.blue,
                          ),
                          child: Text(
                            'Add',
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                        onTap: (){
                          if(_formKey.currentState!.validate()){
                            if(_showDecrypt && decryptedPassword != _passwordController.text){
                              decryptedPassword = _passwordController.text;
                              EncryptDecrypt.encryptAES(decryptedPassword);
                              encryptedPassword = EncryptDecrypt.encrypted?.base64.toString() ?? "";
                            }
                            int createdDateTime = DateTime.now().microsecondsSinceEpoch;
                            print(createdDateTime);
                            accountDB.insertAccount(
                                AccountModel(
                                    name: _nameController.text,
                                    username: _usernameController.text,
                                    password: encryptedPassword,
                                    description: _descriptionController.text,
                                    accountType: _selectedAccountType,
                                    accountLoginType: _selectedAccountLoginType,
                                    createdDateTime: createdDateTime,)
                            ).then((value) {
                              showMessageDialog(context, "Account added successfully");
                            });
                          }
                        },
                      ),
                    ),
                    if(_allowUpdate) Expanded(
                      flex: 1,
                      child: InkWell(
                        child: Container(
                          width: double.infinity,
                          margin: EdgeInsets.fromLTRB(5, 0, 5, 0),
                          padding: EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(10),
                            color: Colors.blue,
                          ),
                          child: Text(
                            'Update',
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                        onTap: (){
                          if(_formKey.currentState!.validate()){
                            if(_showDecrypt && decryptedPassword != _passwordController.text){
                              decryptedPassword = _passwordController.text;
                              EncryptDecrypt.encryptAES(decryptedPassword);
                              encryptedPassword = EncryptDecrypt.encrypted?.base64.toString() ?? "";
                            }
                            accountDB.updateAccount(
                                AccountModel(
                                    id: widget.accountModel?.id,
                                    name: _nameController.text,
                                    username: _usernameController.text,
                                    password: encryptedPassword,
                                    description: _descriptionController.text,
                                    accountType: _selectedAccountType,
                                    accountLoginType: _selectedAccountLoginType,
                                    createdDateTime: widget.accountModel?.createdDateTime ?? 0,)
                            ).then((value) {
                              showMessageDialog(context, "Account updated successfully");
                            });
                          }
                        },
                      ),
                    ),
                    if(_allowDelete) Expanded(
                      flex: 1,
                      child: InkWell(
                        child: Container(
                          width: double.infinity,
                          margin: EdgeInsets.fromLTRB(5, 0, 5, 0),
                          padding: EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(10),
                            color: Colors.blue,
                          ),
                          child: Text(
                            'Delete',
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                        onTap: (){
                          accountDB.deleteAccount(
                              AccountModel(
                                  id: widget.accountModel?.id,
                                  name: _nameController.text,
                                  username: _usernameController.text,
                                  password: encryptedPassword,
                                  description: _descriptionController.text,
                                  accountType: _selectedAccountType,
                                  accountLoginType: _selectedAccountLoginType,
                                  createdDateTime: widget.accountModel?.createdDateTime ?? 0,)
                          ).then((value) {
                            showMessageDialog(context, "Account deleted successfully");
                          });
                        },
                      ),
                    ),
                  ],
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
