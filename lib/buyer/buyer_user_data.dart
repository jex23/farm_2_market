class BuyerUserData {
  static final BuyerUserData _instance = BuyerUserData._internal();

  String? uid; // Globally accessible UID

  factory BuyerUserData() {
    return _instance;
  }

  BuyerUserData._internal();
}
