import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../../core/design_system/app_ui.dart';
import '../../../core/fx/fx_service_impl.dart';
import '../../../core/money/currency_type.dart';
import '../../../core/routing/app_router.dart';
import '../../../core/utils/app_vibrations.dart';
import '../../../core/utils/extensions/build_context_extensions.dart';
import '../../settings/ui/state_management/settings_provider.dart';
import 'pages/onboarding_benefit_page.dart';
import 'pages/onboarding_currency_page.dart';
import 'pages/onboarding_final_page.dart';
import 'pages/onboarding_wallet_page.dart';
import 'pages/onboarding_welcome_page.dart';
import 'widgets/illustrations/onboarding_flow_illustration.dart';
import 'widgets/illustrations/onboarding_one_tap_illustration.dart';
import 'widgets/illustrations/onboarding_tags_illustration.dart';
import 'widgets/illustrations/onboarding_wallets_illustration.dart';
import 'widgets/onboarding_app_bar.dart';

/// First-launch flow — a single route driving an 8-page PageView.
///
/// | Index | Page                     | Progress | Back  | Skip       |
/// |-------|--------------------------|----------|-------|------------|
/// | 0     | Welcome                  | hidden   | —     | —          |
/// | 1–3   | Benefits                 | .20–.60  | prev  | → 5        |
/// | 4     | How it works             | .80      | prev  | → 5        |
/// | 5     | Base currency (mandatory)| 1.00     | prev  | hidden     |
/// | 6     | Create first wallet      | hidden   | → 5   | own bottom |
/// | 7     | Congrats (confetti)      | hidden   | —     | —          |
///
/// The wallet itself is created in the existing [WalletFormRoute] (pushed as
/// the slide-up modal); a saved wallet advances to the congrats page, Skip
/// lands on the empty dashboard. `show_onboarding` flips to 0 in both cases.
@RoutePage()
class OnboardingPage extends HookConsumerWidget {
  const OnboardingPage({super.key});

  static const _welcome = 0;
  static const _currencyPage = 5;
  static const _walletPage = 6;
  static const _finalPage = 7;

  /// Progress bar value per PageView index; `null` = header hidden.
  static const List<double?> _progressPerPage = [
    null, // 0 welcome
    0.20, // 1 wallets
    0.40, // 2 tags
    0.60, // 3 one tap
    0.80, // 4 how it works
    1.00, // 5 currency
    null, // 6 wallet
    null, // 7 final
  ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final pageController = usePageController();
    final currentPage = useState(_welcome);
    final currency = useState<CurrencyType?>(null);
    final leaving = useState(false);

    // Default = device locale currency, fallback USD.
    useEffect(() {
      FxServiceImpl.deviceCurrency().then((c) {
        if (currency.value == null) currency.value = c;
      });
      return null;
    }, const []);

    Future<void> goTo(int index) => pageController.animateToPage(
          index,
          duration: UIAnim.page,
          curve: UIAnim.pageCurve,
        );

    final toNext = useCallback(() => goTo(currentPage.value + 1));
    final toPrevious = useCallback(() => goTo(currentPage.value - 1));
    final skipToCurrency = useCallback(() => goTo(_currencyPage));

    Future<void> finish({required bool celebrate}) async {
      if (leaving.value) return;
      leaving.value = true;
      await ref.read(settingsProvider.notifier).onboardingCompleted();
      if (!context.mounted) return;
      if (celebrate) {
        leaving.value = false;
        await goTo(_finalPage);
      } else {
        context.router.replaceAll([const DashboardRoute()]);
      }
    }

    Future<void> commitCurrency() async {
      final c = currency.value ?? CurrencyType.usd;
      await ref.read(settingsProvider.notifier).changeBaseCurrency(c);
      AppVibrations.light();
      await toNext();
    }

    Future<void> createWallet() async {
      // Reuses the slide-up wallet form; the first wallet is forced primary
      // by the notifier (wallets list is empty).
      final savedId = await context.router.push<String?>(WalletFormRoute());
      if (savedId == null || !context.mounted) return;
      AppVibrations.medium();
      await finish(celebrate: true);
    }

    final index = currentPage.value;
    final progress = _progressPerPage[index];
    final showHeader = index > _welcome && index < _walletPage;
    final canGoBack = index >= 1 && index <= _walletPage;
    final canSkip = index >= 1 && index < _currencyPage;

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (_, _) {
        // System back mirrors the header back button; swallowed on the
        // welcome page and after completion.
        if (canGoBack) toPrevious();
      },
      child: Scaffold(
        body: Stack(
          fit: StackFit.expand,
          children: [
            // Ambient light only frames the hero pages (welcome / final).
            AnimatedOpacity(
              duration: UIAnim.slow,
              opacity: index == _welcome || index == _finalPage ? 1 : 0.35,
              child: const UiAmbientBackground(),
            ),
            SafeArea(
              bottom: false,
              child: Column(
                children: [
                  OnboardingAppBar(
                    visible: showHeader,
                    progress: progress ?? 0,
                    onBack: canGoBack ? toPrevious : null,
                    onSkip: canSkip ? skipToCurrency : null,
                  ),
                  Expanded(
                    child: PageView(
                      controller: pageController,
                      physics: const NeverScrollableScrollPhysics(),
                      onPageChanged: (i) => currentPage.value = i,
                      children: [
                        // 0 — welcome
                        OnboardingWelcomePage(onStart: toNext),

                        // 1–3 — benefits
                        OnboardingBenefitPage(
                          title: l10n.onboarding_benefit_wallets_title,
                          body: l10n.onboarding_benefit_wallets_body,
                          illustration: const OnboardingWalletsIllustration(),
                          onNext: toNext,
                        ),
                        OnboardingBenefitPage(
                          title: l10n.onboarding_benefit_tags_title,
                          body: l10n.onboarding_benefit_tags_body,
                          illustration: const OnboardingTagsIllustration(),
                          onNext: toNext,
                        ),
                        OnboardingBenefitPage(
                          title: l10n.onboarding_benefit_one_tap_title,
                          body: l10n.onboarding_benefit_one_tap_body,
                          illustration: const OnboardingOneTapIllustration(),
                          onNext: toNext,
                        ),

                        // 4 — how it works
                        OnboardingBenefitPage(
                          title: l10n.onboarding_how_title,
                          body: l10n.onboarding_how_body,
                          illustration: OnboardingFlowIllustration(
                            labels: [
                              l10n.onboarding_how_step_wallet,
                              l10n.onboarding_how_step_tap,
                              l10n.onboarding_how_step_totals,
                            ],
                          ),
                          onNext: toNext,
                        ),

                        // 5 — mandatory: base currency
                        OnboardingCurrencyPage(
                          selected: currency.value ?? CurrencyType.usd,
                          onChanged: (c) => currency.value = c,
                          onNext: commitCurrency,
                        ),

                        // 6 — first wallet (opens the wallet form modal)
                        OnboardingWalletPage(
                          onCreate: createWallet,
                          onSkip: () => finish(celebrate: false),
                        ),

                        // 7 — congrats + confetti → dashboard
                        OnboardingFinalPage(
                          onDone: () => context.router.replaceAll([const DashboardRoute()]),
                        ),
                      ],
                    ),
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
