class UserData {
  static final UserData _instance = UserData._internal();

  String? uid; // Globally accessible UID

  factory UserData() {
    return _instance;
  }

  UserData._internal();
}
