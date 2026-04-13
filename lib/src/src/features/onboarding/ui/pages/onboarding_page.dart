import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import 'onboarding_1_page.dart';
import 'onboarding_2_page.dart';
import 'onboarding_3_page.dart';
import 'onboarding_4_page.dart';


@RoutePage()
class OnboardingPage extends HookConsumerWidget {
  const OnboardingPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final pageController = usePageController();
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: PageView(
                controller: pageController,
                physics: AlwaysScrollableScrollPhysics(),
                children: [
                  Onboarding1Page(),
                  Onboarding2Page(),
                  Onboarding3Page(),
                  Onboarding4Page(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
