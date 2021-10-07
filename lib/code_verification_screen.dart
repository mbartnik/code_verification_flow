import 'package:code_verification_flow/new_password_screen.dart';
import 'package:code_verification_flow/providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_countdown_timer/countdown_timer_controller.dart';
import 'package:flutter_countdown_timer/current_remaining_time.dart';
import 'package:flutter_countdown_timer/flutter_countdown_timer.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

class CodeVerificationScreen extends HookWidget {
  const CodeVerificationScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        floatingActionButton: const CodeVerificationNextButton(),
        extendBodyBehindAppBar: true,
        resizeToAvoidBottomInset: false,
        floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          title:
              const Text("Enter code", style: TextStyle(color: Colors.black)),
          leading: const BackButton(color: Colors.black),
        ),
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                CodeVerificationHeader(),
                VerificationSection(),
                Counter(),
                PinError(),
                CodeVerificationBottomText(),
              ],
            ),
          ),
        ));
  }
}

class CodeVerificationHeader extends StatelessWidget {
  const CodeVerificationHeader({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const Align(
      alignment: Alignment.center,
      child: Text("Your verification code will arrive shortly.",
          textAlign: TextAlign.center, style: TextStyle(fontSize: 16.0)),
    );
  }
}

class VerificationSection extends HookWidget {
  const VerificationSection({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final pin2FocusNode = useFocusNode();
    final pin3FocusNode = useFocusNode();
    final pin4FocusNode = useFocusNode();
    final phoneNr = useProvider(currentPhoneNrProvider.notifier);
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 24, 16, 0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          CodeTextField(
              codeIndex: 1,
              onChanged: (value) {
                _onCodeChanged(context, value, pin2FocusNode, phoneNr.state);
                final codeVerificationScreenState = context
                    .read(codeVerificationScreenStateProvider(phoneNr.state));
                codeVerificationScreenState.pin1 = value;
              }),
          CodeTextField(
              codeIndex: 2,
              focusNode: pin2FocusNode,
              onChanged: (value) {
                _onCodeChanged(context, value, pin3FocusNode, phoneNr.state);
                final codeVerificationScreenState = context
                    .read(codeVerificationScreenStateProvider(phoneNr.state));
                codeVerificationScreenState.pin2 = value;
              }),
          CodeTextField(
              codeIndex: 3,
              focusNode: pin3FocusNode,
              onChanged: (value) {
                _onCodeChanged(context, value, pin4FocusNode, phoneNr.state);
                final codeVerificationScreenState = context
                    .read(codeVerificationScreenStateProvider(phoneNr.state));
                codeVerificationScreenState.pin3 = value;
              }),
          CodeTextField(
              codeIndex: 4,
              focusNode: pin4FocusNode,
              onChanged: (value) {
                _onCodeChanged(context, value, null, phoneNr.state);
                final codeVerificationScreenState = context
                    .read(codeVerificationScreenStateProvider(phoneNr.state));
                codeVerificationScreenState.pin4 = value;
                if (value.length == 1) {
                  pin4FocusNode.unfocus();
                }
              }),
        ],
      ),
    );
  }

  void nextField(String value, FocusNode focusNode) {
    if (value.length == 1) {
      focusNode.requestFocus();
    }
  }

  _onCodeChanged(BuildContext context, String text, FocusNode? nextFocusNode,
      String phoneNr) {
    final codeVerificationScreenState =
        context.read(codeVerificationScreenStateProvider(phoneNr));
    codeVerificationScreenState.codeError = false;
    if (nextFocusNode != null) {
      nextField(text, nextFocusNode);
    }
  }
}

class CodeVerificationBottomText extends StatelessWidget {
  const CodeVerificationBottomText({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Align(
        alignment: FractionalOffset.bottomCenter,
        child: Padding(
            padding: const EdgeInsets.only(bottom: 90.0),
            child: Wrap(
              crossAxisAlignment: WrapCrossAlignment.center,
              direction: Axis.vertical,
              children: const [
                Text(
                  "SMS didn't arrive?",
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                Text("After 3 minutes you can request a new code"),
              ],
            )),
      ),
    );
  }
}

class PinError extends HookWidget {
  const PinError({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final phoneNr = useProvider(currentPhoneNrProvider.notifier);
    final codeError = useProvider(
        codeVerificationScreenStateProvider(phoneNr.state)
            .select((value) => value.codeError));
    return Visibility(
      visible: codeError,
      child: const Padding(
        padding: EdgeInsets.only(top: 24, left: 16),
        child: Text(
          "The code you entered is incorrect!",
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}

class CodeVerificationNextButton extends HookWidget {
  const CodeVerificationNextButton({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final phoneNr = useProvider(currentPhoneNrProvider.notifier);
    final codeExpired = useProvider(
        codeVerificationScreenStateProvider(phoneNr.state)
            .select((value) => value.codeExpired));
    bool active = useProvider(codeVerificationScreenStateProvider(phoneNr.state)
        .select((value) => value.isNextButtonActive));
    return Opacity(
      opacity: (active || codeExpired) ? 1 : 0.7,
      child: Align(
          alignment: Alignment.bottomCenter,
          child: FloatingActionButton.extended(
              heroTag: null,
              onPressed: () {
                final codeVerificationScreenState = context
                    .read(codeVerificationScreenStateProvider(phoneNr.state));
                FocusScope.of(context).unfocus();
                if (codeVerificationScreenState.codeExpired) {
                  codeVerificationScreenState.requestVerificationCode(
                      phoneNr.state, true);
                } else if (active) {
                  codeVerificationScreenState.confirmVerificationCode(() {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => const NewPasswordScreen()));
                  }, phoneNr.state);
                }
              },
              label: SizedBox(
                child: Center(
                    child: Text(codeExpired ? "Request new code" : "Next",
                        style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                            color: Colors.black))),
                width: 230,
                height: 48,
              ),
              backgroundColor: Colors.amberAccent)),
    );
  }
}

class Counter extends HookWidget {
  const Counter({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final phoneNr = useProvider(currentPhoneNrProvider.notifier);
    final isCodeVerified = useProvider(
        codeVerificationScreenStateProvider(phoneNr.state)
            .select((value) => value.isCodeVerified));
    final endTime = useProvider(
        codeVerificationScreenStateProvider(phoneNr.state)
            .notifier
            .select((value) => value.endTime));
    final codeError = useProvider(
        codeVerificationScreenStateProvider(phoneNr.state)
            .select((value) => value.codeError));
    final recreateTimer = useProvider(
        codeVerificationScreenStateProvider(phoneNr.state)
            .notifier
            .select((value) => value.recreateTimer));
    final isMounted = useIsMounted();
    final controller = useCountdownTimerController(
        endTime: endTime,
        onEnd: () => onEnd(context, isMounted()),
        keys: [recreateTimer]);
    return Visibility(
      visible: !codeError,
      child: Padding(
        padding: const EdgeInsets.only(top: 24, left: 16),
        child: isCodeVerified
            ? const Text(
                "Your code has been verified!",
                style: TextStyle(fontSize: 16),
              )
            : CountdownTimer(
                controller: controller.isRunning ? controller : null,
                onEnd: () => onEnd(context, isMounted()),
                endTime: endTime,
                widgetBuilder: (_, CurrentRemainingTime? time) {
                  if (time == null) {
                    return const Text(
                      "Your code has expired,\nplease request another code through button below.",
                      style: TextStyle(fontSize: 16),
                    );
                  }
                  return Text(
                    'Code will expire in '
                    '${time.min ?? 0}:'
                    '${(time.sec ?? 0) >= 10 ? time.sec : "0${time.sec}"} min',
                    style: const TextStyle(fontSize: 16),
                  );
                },
              ),
      ),
    );
  }

  void onEnd(BuildContext context, bool mounted) {
    if (mounted) {
      final phoneNr = context.read(currentPhoneNrProvider);
      final codeVerificationScreenState =
          context.read(codeVerificationScreenStateProvider(phoneNr.state));
      if (!codeVerificationScreenState.isCodeVerified) {
        WidgetsBinding.instance!.addPostFrameCallback((_) {
          codeVerificationScreenState.disableMaintainState();
          codeVerificationScreenState.codeExpired = true;
        });
      }
    }
  }
}

class CodeTextField extends HookWidget {
  final int codeIndex;
  final FocusNode? focusNode;
  final Function(String) onChanged;

  const CodeTextField(
      {Key? key,
      required this.codeIndex,
      this.focusNode,
      required this.onChanged})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    final textEditingController = useTextEditingController();
    final phoneNr = useProvider(currentPhoneNrProvider.notifier);
    final codeError = useProvider(
        codeVerificationScreenStateProvider(phoneNr.state)
            .select((value) => value.codeError));
    final pin = useProvider(codeVerificationScreenStateProvider(phoneNr.state)
        .notifier
        .select((value) {
      switch (codeIndex) {
        case 1:
          return value.pin1;
        case 2:
          return value.pin2;
        case 3:
          return value.pin3;
        case 4:
          return value.pin4;
        default:
          throw UnsupportedError(
              'Unsupported code index passed to CodeTextField');
      }
    }));
    useMemoized(() {
      textEditingController.text = pin;
    }, []);
    return SizedBox(
      width: 55,
      child: TextField(
        controller: textEditingController,
        inputFormatters: [
          LengthLimitingTextInputFormatter(1),
        ],
        focusNode: focusNode,
        style: const TextStyle(fontSize: 20),
        keyboardType:
            const TextInputType.numberWithOptions(signed: true, decimal: true),
        textAlign: TextAlign.center,
        decoration: InputDecoration(
          contentPadding: const EdgeInsets.symmetric(vertical: 16),
          border: outlineInputBorder(codeError),
          focusedBorder: outlineInputBorder(codeError),
          filled: true,
          enabledBorder: outlineInputBorder(codeError),
        ),
        onChanged: onChanged,
      ),
    );
  }

  InputBorder outlineInputBorder(bool codeError) {
    return OutlineInputBorder(
      borderRadius: BorderRadius.circular(6),
      borderSide:
          BorderSide(color: codeError ? Colors.red : Colors.black, width: 2.0),
    );
  }
}

class _CountdownTimerControllerHook extends Hook<CountdownTimerController> {
  const _CountdownTimerControllerHook({
    required this.endTime,
    this.onEnd,
    this.debugLabel,
    List<Object?>? keys,
  }) : super(keys: keys);

  final int endTime;
  final Function()? onEnd;
  final String? debugLabel;

  @override
  HookState<CountdownTimerController, Hook<CountdownTimerController>>
      createState() => _CountdownTimerControllerHookState();
}

class _CountdownTimerControllerHookState
    extends HookState<CountdownTimerController, _CountdownTimerControllerHook> {
  late final controller = CountdownTimerController(
    endTime: hook.endTime,
    onEnd: hook.onEnd,
  );

  @override
  CountdownTimerController build(BuildContext context) => controller;

  @override
  void dispose() => controller.dispose();

  @override
  String get debugLabel => 'useCountdownTimerController';
}

CountdownTimerController useCountdownTimerController({
  required int endTime,
  Function()? onEnd,
  String? debugLabel,
  List<Object?>? keys,
}) {
  return use(
    _CountdownTimerControllerHook(
      endTime: endTime,
      onEnd: onEnd,
      debugLabel: debugLabel,
      keys: keys,
    ),
  );
}
