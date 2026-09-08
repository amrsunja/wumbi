abstract class RoutePaths {
  static const splash = '/';
  static const onboarding = '/onboarding';

  // ROOT ROUTES
  static const dashboard = '/dashboard';
  static const walletDetails = '/wallet/:id';
  static const walletForm = '/wallet/form';
  static const transaction = '/transaction';

  /// Tags hub (list / graph) and a single tag's transactions + wallets.
  static const tags = '/tags';
  static const tagDetails = '/tags/:id';

  /// Recurring rules ("subscriptions"); optional `walletId` narrows the list.
  static const subscriptions = '/subscriptions';

  static const settings = '/settings';
  static const baseCurrencySettings = '/settings/currency';
  static const aboutProject = '/settings/about';

  static const appLangSettings = '/settings/language';
}
