import 'package:flutter/cupertino.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

class Logger extends ProviderObserver {
/*
  @override
  void didUpdateProvider(
    ProviderBase provider,
    Object? newValue,
  ) {
    debugPrint(
        '''didUpdateProvider {  "provider": "${provider.name ?? provider.runtimeType}",  "newValue": "$newValue", "argument:" "${provider.argument.toString()}"}''');
  }
*/

  @override
  void didDisposeProvider(ProviderBase provider) {
    debugPrint(
        '''didDisposeProvider {  "provider": "${provider.name ?? provider.runtimeType}", "argument:" "${provider.argument.toString()}"}''');
  }

  @override
  void didAddProvider(ProviderBase provider, Object? value) {
    debugPrint(
        '''didAddProvider {  "provider": "${provider.name ?? provider.runtimeType}",  "newValue": "$value", "argument:" "${provider.argument.toString()}"}''');
  }
}
