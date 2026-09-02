import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../../core/design_system/app_ui.dart';
import '../../../core/fx/fx_service_impl.dart';
import '../../../core/money/currency_type.dart';
import '../../../core/routing/app_router.dart';
import '../../../core/utils/app_vibrations.dart';
import '../../../core/utils/constants/constants.dart';
import '../../../core/utils/extensions/build_context_extensions.dart';
import '../../settings/ui/state_management/settings_provider.dart';
import '../../wallet/ui/wallet_form_notifier.dart';
import 'steps/currency_step.dart';
import 'steps/wallet_step.dart';
import 'steps/welcome_step.dart';

/// First launch: welcome → base currency → first wallet. No swipe, no skip.
@RoutePage()
class OnboardingPage extends HookConsumerWidget {
  const OnboardingPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final pageController = usePageController();
    final step = useState(0);
    final currency = useState<CurrencyType?>(null);
    final saving = useState(false);

    const walletArgs = WalletFormArgs(onboarding: true);
    final walletState = ref.watch(walletFormProvider(walletArgs));

    // Default = device locale currency, fallback USD.
    useEffect(() {
      FxServiceImpl.deviceCurrency().then((c) {
        if (currency.value == null) currency.value = c;
      });
      return null;
    }, const []);

    Future<void> goTo(int index) async {
      step.value = index;
      await pageController.animateToPage(
        index,
        duration: const Duration(milliseconds: 350),
        curve: Curves.easeOutCubic,
      );
    }

    Future<void> onPrimary() async {
      switch (step.value) {
        case 0:
          await goTo(1);
        case 1:
          final c = currency.value ?? CurrencyType.usd;
          await ref.read(settingsProvider.notifier).changeBaseCurrency(c);
          // Wallet currency defaults to the base currency.
          ref.read(walletFormProvider(walletArgs).notifier).setCurrency(c);
          await goTo(2);
        case 2:
          if (saving.value) return;
          saving.value = true;
          final wallet = await ref.read(walletFormProvider(walletArgs).notifier).save();
          saving.value = false;
          if (wallet == null) return;
          AppVibrations.medium();
          await ref.read(settingsProvider.notifier).onboardingCompleted();
          if (context.mounted) context.router.replaceAll([const DashboardRoute()]);
      }
    }

    final canContinue = switch (step.value) {
      2 => walletState.canSave && !saving.value,
      _ => true,
    };

    return Scaffold(
      appBar: UIAppbar(
        backTap: step.value == 0 ? null : () => goTo(step.value - 1),
      ),
      body: SafeArea(
        top: false,
        child: Column(
          children: [
            Expanded(
              child: PageView(
                controller: pageController,
                physics: const NeverScrollableScrollPhysics(),
                children: [
                  const WelcomeStep(),
                  CurrencyStep(
                    selected: currency.value ?? CurrencyType.usd,
                    onChanged: (c) => currency.value = c,
                  ),
                  const WalletStep(args: walletArgs),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(kPageHorzPadding, 8, kPageHorzPadding, 16),
              child: Column(
                children: [
                  UIProgressDots(count: 3, index: step.value),
                  const UISpace.vert(16),
                  UiPrimaryButton(
                    label: step.value == 2 ? l10n.onboarding_create_wallet : l10n.common_continue,
                    enabled: canContinue,
                    loading: saving.value,
                    onTap: onPrimary,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
