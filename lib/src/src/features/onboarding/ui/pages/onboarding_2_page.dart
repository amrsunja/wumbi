import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';


@RoutePage()
class Onboarding2Page extends HookConsumerWidget {
  const Onboarding2Page({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
    backgroundColor: Colors.red,
    );
  }
}
