import 'package:code_verification_flow/code_verification_screen.dart';
import 'package:code_verification_flow/providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

class PhoneNumberScreen extends HookWidget {
  const PhoneNumberScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        floatingActionButton: const PhoneNumberNextButton(),
        extendBodyBehindAppBar: true,
        floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          title:
              const Text("Phone number", style: TextStyle(color: Colors.black)),
          leading: const BackButton(color: Colors.black),
        ),
        body: SafeArea(
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [PhoneNumberHeader(), UserPhoneSection()],
              ),
            ),
          ),
        ));
  }
}

class PhoneNumberHeader extends StatelessWidget {
  const PhoneNumberHeader({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      alignment: Alignment.center,
      padding: const EdgeInsets.fromLTRB(4, 16, 4, 0),
      child: const Text(
        "Enter the phone number to use with your account.",
        style: TextStyle(color: Colors.black, fontSize: 16),
        textAlign: TextAlign.center,
      ),
    );
  }
}

class PhoneNumberNextButton extends HookConsumerWidget {
  const PhoneNumberNextButton({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final phoneNumberScreenState = ref.watch(phoneNumberScreenStateProvider);
    bool keyboardVisible = MediaQuery.of(context).viewInsets.bottom != 0.0;
    bool active = phoneNumberScreenState.isNextButtonEnabled;
    return Visibility(
      visible: !keyboardVisible,
      child: Opacity(
        opacity: active ? 1 : 0.7,
        child: Align(
            alignment: Alignment.bottomCenter,
            child: FloatingActionButton.extended(
                heroTag: null,
                onPressed: () {
                  FocusScope.of(context).unfocus();
                  if (active && phoneNumberScreenState.checkValidations()) {
                    final phoneNumberScreenState =
                        ref.read(phoneNumberScreenStateProvider);
                    final currentPhoneNr =
                        ref.read(currentPhoneNrProvider.notifier);
                    currentPhoneNr.state = phoneNumberScreenState.phoneNumber;
                    final phoneNumbersInVerification =
                        ref.read(phoneNumbersInVerificationProvider);
                    phoneNumbersInVerification
                        .add(phoneNumberScreenState.phoneNumber);
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) =>
                                const CodeVerificationScreen()));
                  }
                },
                label: const SizedBox(
                  child: Center(
                      child: Text("Next",
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

class UserPhoneSection extends HookConsumerWidget {
  const UserPhoneSection({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final phoneError = ref.watch(phoneNumberScreenStateProvider
        .select((phoneNumberScreenState) => phoneNumberScreenState.phoneError));
    return Padding(
      padding: const EdgeInsets.only(top: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Phone number",
            style: TextStyle(color: Colors.black, fontSize: 12),
          ),
          SizedBox(
            height: 52,
            child: Padding(
              padding: const EdgeInsets.only(top: 8),
              child: TextField(
                onChanged: (value) {
                  final phoneNumberScreenState =
                      ref.read(phoneNumberScreenStateProvider);
                  phoneNumberScreenState.phoneNumber = value;
                  phoneNumberScreenState.phoneError = false;
                },
                decoration: InputDecoration(
                  hintText: "Enter your phone number",
                  hintStyle:
                      const TextStyle(color: Colors.black38, fontSize: 16),
                  filled: true,
                  contentPadding: const EdgeInsets.all(10.0),
                  enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(
                        color: phoneError ? Colors.red : Colors.transparent,
                        width: 2.0),
                  ),
                  border: const OutlineInputBorder(
                    borderRadius: BorderRadius.all(
                      Radius.circular(6.0),
                    ),
                    borderSide: BorderSide.none,
                  ),
                ),
                keyboardType: const TextInputType.numberWithOptions(
                    signed: true, decimal: true),
                inputFormatters: [
                  LengthLimitingTextInputFormatter(9),
                ],
              ),
            ),
          ),
          const Padding(
            padding: EdgeInsets.only(top: 8, right: 12),
            child: Text(
              "Phone number should be 9 digits long.",
            ),
          )
        ],
      ),
    );
  }
}
