import 'package:keep_flutter/Model/AccountModel.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class AccountDB{
  late Database _database;

  Future openDb() async {
    _database = await openDatabase(
      join(await getDatabasesPath(), "main.db"),
      version: 1,
      onCreate: (db, int version,) async{
        await db.execute(
          "CREATE TABLE Account("
              "id INTEGER PRIMARY KEY autoincrement, "
              "name TEXT, "
              "username TEXT, "
              "password TEXT, "
              "description TEXT, "
              "accountType TEXT, "
              "accountLoginType TEXT, "
              "createdDateTime INT "
              ")",
        );
      }
    );
    return _database;
  }

  Future<void> insertAccount(AccountModel accountModel) async {

    await openDb();
    await _database.insert(
      'Account',
      accountModel.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
    print("Added: " + accountModel.toString());
  }
  
  Future<void> insertAccountRawSQL(String insertSQL) async{
    await openDb();
    await _database.rawInsert(insertSQL);
  }

  Future<List<AccountModel>> getAccountList() async{
    await openDb();
    final List<Map<String,dynamic>> maps = await _database.query('Account');
    return List.generate(maps.length, (i) {
      return AccountModel(
          id: maps[i]['id'],
          name: maps[i]['name'],
          username: maps[i]['username'],
          password: maps[i]['password'],
          description: maps[i]['description'],
          accountType: maps[i]['accountType'],
          accountLoginType: maps[i]['accountLoginType'],
          createdDateTime: maps[i]['createdDateTime']
      );
    });
  }

  Future<int> updateAccount(AccountModel accountModel) async{
    await openDb();
    String whereString = 'id = ?';
    Map<String,dynamic> rows = {
      'id':accountModel.id,
      'name':accountModel.name,
      'username':accountModel.username,
      'password':accountModel.password,
      'description':accountModel.description,
      'accountType':accountModel.accountType,
      'accountLoginType':accountModel.accountLoginType,
      'createdDateTime':accountModel.createdDateTime
    };
    int updateCount = 0;
    updateCount = await _database.update(
        'Account',
        rows,
        where: whereString,
        whereArgs:[accountModel.id]
    );

    return updateCount;
  }

  Future<bool> deleteAccount(AccountModel accountModel) async{
    try{
      await openDb();
      await _database.delete('Account', where: 'id = ?', whereArgs: [accountModel.id]);
      return true;
    }on Exception catch (_){
      return false;
    }

  }

  Future<void> deleteAccountRawSQL() async{
    await openDb();
    await _database.rawDelete('DELETE FROM Account');
  }

}