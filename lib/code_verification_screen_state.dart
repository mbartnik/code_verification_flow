import 'dart:math';

import 'package:code_verification_flow/providers.dart';
import 'package:flutter/cupertino.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

class CodeVerificationScreenState extends ChangeNotifier {
  final AutoDisposeProviderReference _ref;

  // this variable holds the code that otherwise would be sent to us
  String? _code;

  int endTime = DateTime.now().millisecondsSinceEpoch + 1000 * 180;

  bool recreateTimer = false;

  bool _isCodeVerified = false;

  bool get isCodeVerified => _isCodeVerified;

  String _pin1 = "";
  String _pin2 = "";
  String _pin3 = "";
  String _pin4 = "";

  bool _codeExpired = false;
  bool _codeError = false;

  String get pin1 => _pin1;

  set pin1(String value) {
    _pin1 = value;
    notifyListeners();
  }

  String get pin2 => _pin2;

  set pin2(String value) {
    _pin2 = value;
    notifyListeners();
  }

  String get pin3 => _pin3;

  set pin3(String value) {
    _pin3 = value;
    notifyListeners();
  }

  String get pin4 => _pin4;

  set pin4(String value) {
    _pin4 = value;
    notifyListeners();
  }

  bool get codeExpired => _codeExpired;

  set codeExpired(bool value) {
    if (value != _codeExpired) {
      _codeExpired = value;
      notifyListeners();
    }
  }

  bool get codeError => _codeError;

  set codeError(bool value) {
    if (value != _codeError) {
      _codeError = value;
      notifyListeners();
    }
  }

  CodeVerificationScreenState(this._ref) {
    final phoneNr = _ref.read(currentPhoneNrProvider);
    requestVerificationCode(phoneNr.state, false);
  }

  @override
  void dispose() {
    final phoneNumbersInVerification =
        _ref.read(phoneNumbersInVerificationProvider);
    final phoneNr = _ref.read(currentPhoneNrProvider);
    phoneNumbersInVerification.remove(phoneNr);
    super.dispose();
  }

  requestVerificationCode(String phoneNr, bool renewCode) async {
    _code = "${Random().nextInt(9000) + 1000}";
    debugPrint('Generated code: $_code');
    _ref.maintainState = true;
    if (renewCode) {
      endTime = DateTime.now().millisecondsSinceEpoch + 1000 * 180;
      _codeExpired = !_codeExpired;
      recreateTimer = !recreateTimer;
      notifyListeners();
    }
  }

  confirmVerificationCode(Function() onCodeVerified, String phoneNr) async {
    if (_isCodeVerified) {
      onCodeVerified();
      return;
    }

    String enteredCode = pin1 + pin2 + pin3 + pin4;
    if (enteredCode != _code) {
      codeError = true;
    } else {
      _isCodeVerified = true;
      notifyListeners();
      onCodeVerified();
    }
  }

  bool get isNextButtonActive =>
      pin1.isNotEmpty && pin2.isNotEmpty && pin3.isNotEmpty && pin4.isNotEmpty;

  disableMaintainState() {
    _ref.maintainState = false;
  }
}
