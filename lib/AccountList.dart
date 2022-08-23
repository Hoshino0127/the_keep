import 'package:flutter/material.dart';
import 'package:keep_flutter/Database/AccountDB.dart';
import 'package:keep_flutter/Model/AccountModel.dart';
import 'package:keep_flutter/widgets.dart';

class AccountList extends StatefulWidget {
  const AccountList({Key? key}) : super(key: key);

  @override
  State<AccountList> createState() => _AccountListState();
}

class _AccountListState extends State<AccountList> {
  final accountDB = AccountDB();
  late final List<AccountModel> _accountList = List.empty(growable: true);
  late final List<AccountModel> _filteredAccountList =
      List.empty(growable: true);

  String filteredText = "";
  final TextEditingController _nameController = TextEditingController();

  late String _selectedSortBy;
  late String _selectedOrderBy;

  List<String> sortByList = [
    "Name",
    "Date"
  ];

  List<String> orderByList = [
    "ASC",
    "DESC"
  ];

  bool isLoading = true;

  @override
  void initState() {
    super.initState();

    _nameController.addListener(() {
      setState(() {
        filteredText = _nameController.text;
      });
    });

    setDefaultSort();

    initView();
  }

  void setDefaultSort() {
    _selectedSortBy = "Date";
    _selectedOrderBy = "DESC";
  }

  void initView() async {
    await Future.wait([
      accountDB.getAccountList().then((value) {
        _accountList.addAll(value);
        for(AccountModel accountModel in _accountList){
          print(accountModel.name);
        }
      }),
    ]).then((value) {
      setState(() {
        isLoading = !isLoading;
      });
    });
  }

  void shouldReloadList() async {
    _accountList.clear();
    setState(() {
      isLoading = !isLoading;
    });

    await Future.wait([
      accountDB.getAccountList().then((value) {
        _accountList.addAll(value);
      })
    ]).then((value) {
      setState(() {
        setDefaultSort();
        sortList();
        isLoading = !isLoading;
      });
    });
  }

  void sortList(){
    setState(() {
      print(_selectedSortBy);
      print(_selectedOrderBy);
      if(_selectedSortBy == "Name"){
        _accountList.sort((a,b) {
          return _selectedOrderBy == "ASC"
              ? a.name.toLowerCase().compareTo(b.name.toLowerCase())
              : b.name.toLowerCase().compareTo(a.name.toLowerCase());
        });
      }else if(_selectedSortBy == "Date"){
        _accountList.sort((a,b) {
          return _selectedOrderBy == "ASC"
              ? a.createdDateTime.compareTo(b.createdDateTime)
              : b.createdDateTime.compareTo(a.createdDateTime);
        });
      }
    });
  }

  Widget accountItem(AccountModel accountModel) {
    return InkWell(
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: Colors.black),
          color: Colors.white,
        ),
        padding: EdgeInsets.all(10),
        margin: EdgeInsets.all(10),
        child: ListTile(
            title: Container(
              padding: EdgeInsets.fromLTRB(0, 10, 0, 10),
              child: Text(accountModel.name),
            ),
            subtitle: Container(
              padding: EdgeInsets.fromLTRB(0, 0, 0, 10),
              child: Column(
                children: [
                  Container(
                    padding: EdgeInsets.fromLTRB(0, 2, 0, 2),
                    width: double.infinity,
                    child: Text(
                      "Username : " + accountModel.username,
                      textAlign: TextAlign.start,
                    ),
                  ),
                  Container(
                    padding: EdgeInsets.fromLTRB(0, 2, 0, 2),
                    width: double.infinity,
                    child: Text(
                      accountModel.description,
                      textAlign: TextAlign.start,
                    ),
                  ),
                ],
              ),
            )),
      ),
      onTap: () {
        Navigator.pushNamed(context, '/account_details',
                arguments: accountModel)
            .then((shouldReload) {
          if (shouldReload != null && shouldReload == true) {
            shouldReloadList();
          }
        });
      },
    );
  }

  Widget _filterWidget() {
    return Column(
      children: [ 
        Padding(
          padding: EdgeInsets.fromLTRB(10,10,10,0),
          child: TextFormField(
            controller: _nameController,
            maxLines: 1,
            readOnly: false,
            onChanged: (text){
              setState(() {
                filteredText = _nameController.text;
              });
            },
            decoration: InputDecoration(
              hintText: 'Filtered account name',
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
        ),
        SizedBox(height:20),
        Row(
          children: [
            Expanded( 
              child: Padding(
                padding: EdgeInsets.fromLTRB(10,0,10,10),
                child: DropdownButtonFormField(
                  decoration: InputDecoration(
                    labelText: "Sort By",
                    border: OutlineInputBorder(),
                    enabledBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.grey, width: 2.0),
                    ),
                  ),
                  value: _selectedSortBy,
                  onChanged: (String? value) {
                    setState(() {
                      _selectedSortBy = value!;
                      sortList();
                    });
                  },
                  selectedItemBuilder: (BuildContext context) {
                    return sortByList.map<Widget>((e) {
                      return Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          e,
                          overflow: TextOverflow.ellipsis,
                        ),
                      );
                    }).toList();
                  },
                  items: sortByList.map(
                        (e) {
                      return DropdownMenuItem(
                        value: e,
                        child: _selectedSortBy != e
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
              ),
            ),
            Expanded(
              child: Padding(
                padding: EdgeInsets.fromLTRB(10,0,10,10),
                child: DropdownButtonFormField(
                  decoration: InputDecoration(
                    labelText: "Order By",
                    border: OutlineInputBorder(),
                    enabledBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.grey, width: 2.0),
                    ),
                  ),
                  value: _selectedOrderBy,
                  onChanged: (String? value) {
                    setState(() {
                      _selectedOrderBy = value!;
                      print(_selectedOrderBy);
                      sortList();
                    });
                  },
                  selectedItemBuilder: (BuildContext context) {
                    return orderByList.map<Widget>((e) {
                      return Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          e,
                          overflow: TextOverflow.ellipsis,
                        ),
                      );
                    }).toList();
                  },
                  items: orderByList.map(
                        (e) {
                      return DropdownMenuItem(
                        value: e,
                        child: _selectedOrderBy != e
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
              ),
            ),

          ],
        ),
        Divider(
          height: 5,
          thickness: 1,
          color: Colors.black,
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text("Listing"),
        actions: [
          InkWell(
            onTap: () {
              Navigator.pushNamed(context, '/settings').then((shouldReload) {
                if (shouldReload != null && shouldReload == true) {
                  shouldReloadList();
                }
              });
            },
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: SizedBox(
                width: 30,
                height: 30,
                child: Icon(
                  Icons.settings,
                  color: Colors.white,
                )
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.pushNamed(context, '/account_details').then((shouldReload) {
            if (shouldReload != null && shouldReload == true) {
              shouldReloadList();
            }
          });
        },
        backgroundColor: Colors.blue,
        child: const Icon(Icons.add),
      ),
      body: isLoading
          ? loadingIndicator()
          : SafeArea(
              child: Padding(
                padding: EdgeInsets.all(10),
                child: Container(
                  height: MediaQuery.of(context).size.height,
                  child: SingleChildScrollView(
                    child: Column(
                      children: [
                        _filterWidget(),
                        ..._accountList.map((e) {
                          return filteredText == ""
                              ? accountItem(e)
                              : e.name.toLowerCase().contains(filteredText.toLowerCase())
                                  ? accountItem(e)
                                  : Container();
                        }).toList(),
                      ],
                    ),
                  ),
                ),
              ),
            ),
    );
  }
}
