import 'package:flutter/cupertino.dart';

class PhoneNumberScreenState extends ChangeNotifier {

  bool _phoneError = false;

  bool get phoneError => _phoneError;

  set phoneError(bool error) {
    _phoneError = error;
    notifyListeners();
  }

  String _phoneNumber = "";

  String get phoneNumber => _phoneNumber;

  set phoneNumber(String phone) {
    _phoneNumber = phone;
    notifyListeners();
  }

  bool get isNextButtonEnabled => _phoneNumber.isNotEmpty;

  bool checkValidations() {
    if (phoneNumber.length != 9) {
      phoneError = true;
    }
    return !phoneError;
  }
}