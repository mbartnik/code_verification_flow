import 'package:code_verification_flow/new_password_screen_state.dart';
import 'package:code_verification_flow/phone_number_screen_state.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import 'code_verification_screen_state.dart';

final phoneNumberScreenStateProvider =
    ChangeNotifierProvider.autoDispose((ref) => PhoneNumberScreenState());

final phoneNumbersInVerificationProvider = Provider((ref) => <String>{});
final currentPhoneNrProvider = StateProvider((ref) => "");

final codeVerificationScreenStateProvider = ChangeNotifierProvider.autoDispose
    .family<CodeVerificationScreenState, String>(
        (ref, phoneNr) => CodeVerificationScreenState(ref));

final newPasswordScreenStateProvider =
    ChangeNotifierProvider.autoDispose((ref) => NewPasswordScreenState());
