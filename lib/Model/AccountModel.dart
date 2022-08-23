
class AccountModel {
  final int? id;
  final String name;
  final String username;
  final String password;
  final String description;
  final String accountType;
  final String accountLoginType;
  final int createdDateTime;

  AccountModel({
    this.id,
    required this.name,
    required this.username,
    required this.password,
    required this.description,
    required this.accountType,
    required this.accountLoginType,
    required this.createdDateTime,});

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'username': username,
      'password': password,
      'description': description,
      'accountType': accountType,
      'accountLoginType': accountLoginType,
      'createdDateTime': createdDateTime,
    };
  }

  @override
  String toString() {
    return 'AccountModel{id: $id, name: $name, username: $username, password: $password, description: $description, accountType: $accountType, accountLoginType: $accountLoginType, createdDateTime: $createdDateTime}';
  }
}
