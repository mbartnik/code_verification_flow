import 'package:flutter/cupertino.dart';

class NewPasswordScreenState extends ChangeNotifier {
  bool _obscurePass = true;

  bool get obscurePass => _obscurePass;

  set obscurePass(bool error) {
    _obscurePass = error;
    notifyListeners();
  }

  bool _passError = false;

  bool get passError => _passError;

  set passError(bool error) {
    _passError = error;
    notifyListeners();
  }

  String? _userPass;

  String? get userPass => _userPass;

  set userPass(String? pass) {
    _userPass = pass;
    notifyListeners();
  }

  bool get isNextButtonEnabled => _userPass?.isNotEmpty ?? false;

  bool checkValidations() {
    if (userPass!.length < 8 ||
        !userPass!.contains(RegExp(r'[A-Z]')) ||
        !userPass!.contains(RegExp(r'[0-9]'))) {
      passError = true;
    }
    return !passError;
  }
}
