import 'package:code_verification_flow/providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

class NewPasswordScreen extends HookWidget {
  const NewPasswordScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        floatingActionButton: const ChangePasswordButton(),
        extendBodyBehindAppBar: true,
        floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          title: const Text("Enter new password",
              style: TextStyle(color: Colors.black)),
          leading: const BackButton(color: Colors.black),
        ),
        body: SafeArea(
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  NewPasswordHeader(),
                  NewPasswordSection(),
                ],
              ),
            ),
          ),
        ));
  }
}

class NewPasswordHeader extends StatelessWidget {
  const NewPasswordHeader({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      alignment: Alignment.center,
      padding: const EdgeInsets.fromLTRB(4, 16, 4, 0),
      child: const Text(
        "Enter new password",
        style: TextStyle(color: Colors.black, fontSize: 16),
        textAlign: TextAlign.center,
      ),
    );
  }
}

class NewPasswordSection extends HookWidget {
  const NewPasswordSection({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final obscurePass = useProvider(
        newPasswordScreenStateProvider.select((value) => value.obscurePass));
    final passError = useProvider(
        newPasswordScreenStateProvider.select((value) => value.passError));
    return Padding(
      padding: const EdgeInsets.only(top: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Password",
            style: TextStyle(color: Colors.black, fontSize: 12),
          ),
          SizedBox(
            height: 52,
            child: Padding(
              padding: const EdgeInsets.only(top: 8),
              child: TextField(
                onChanged: (value) {
                  final newPasswordScreenState =
                      context.read(newPasswordScreenStateProvider);
                  newPasswordScreenState.userPass = value;
                  newPasswordScreenState.passError = false;
                },
                obscureText: obscurePass,
                decoration: InputDecoration(
                  suffixIcon: GestureDetector(
                      onTap: () {
                        final newPasswordScreenState =
                            context.read(newPasswordScreenStateProvider);
                        newPasswordScreenState.obscurePass =
                            !newPasswordScreenState.obscurePass;
                      },
                      child: const Icon(Icons.remove_red_eye,
                          color: Colors.black)),
                  hintText: "Enter new password",
                  hintStyle:
                      const TextStyle(color: Colors.black38, fontSize: 16),
                  filled: true,
                  contentPadding: const EdgeInsets.all(10.0),
                  enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(
                        color: passError ? Colors.red : Colors.transparent,
                        width: 2.0),
                  ),
                  border: const OutlineInputBorder(
                    borderRadius: BorderRadius.all(
                      Radius.circular(6.0),
                    ),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
            ),
          ),
          const Padding(
            padding: EdgeInsets.only(top: 8, right: 12),
            child: Text(
              "Password must have at least 8 characters, with an upper-case letter and a number",
            ),
          )
        ],
      ),
    );
  }
}

class ChangePasswordButton extends HookWidget {
  const ChangePasswordButton({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    bool keyboardIsOpened = MediaQuery.of(context).viewInsets.bottom != 0.0;
    bool active = useProvider(newPasswordScreenStateProvider
        .select((value) => value.isNextButtonEnabled));
    return Visibility(
      visible: !keyboardIsOpened,
      child: Opacity(
        opacity: active ? 1 : 0.7,
        child: Align(
            alignment: Alignment.bottomCenter,
            child: FloatingActionButton.extended(
                heroTag: null,
                onPressed: () {
                  final newPasswordScreenState =
                      context.read(newPasswordScreenStateProvider);
                  FocusScope.of(context).unfocus();
                  if (active && newPasswordScreenState.checkValidations()) {
                    context.read(currentPhoneNrProvider).dispose();
                    final phoneNumbersInVerification =
                        context.read(phoneNumbersInVerificationProvider);
                    for (final phoneNumber in phoneNumbersInVerification) {
                      context
                          .read(
                              codeVerificationScreenStateProvider(phoneNumber))
                          .dispose();
                    }
                    Navigator.popUntil(context, (route) => route.isFirst);
                  }
                },
                label: const SizedBox(
                  child: Center(
                      child: Text("Change password",
                          style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                              color: Colors.black))),
                  width: 230,
                  height: 48,
                ),
                backgroundColor: Colors.amberAccent)),
      ),
    );
  }
}
