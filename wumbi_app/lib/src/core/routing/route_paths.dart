abstract class RoutePaths {
  static const splash = '/';
  static const onboarding = '/onboarding';

  // ROOT ROUTES
  static const dashboard = '/dashboard';
  static const walletDetails = '/wallet/:id';
  static const walletForm = '/wallet/form';
  static const transaction = '/transaction';

  /// Income vs expense over the last months / years.
  static const progress = '/progress';

  /// Global search over every wallet's transactions.
  static const search = '/search';

  /// Tags hub (list / graph) and a single tag's transactions + wallets.
  static const tags = '/tags';
  static const tagDetails = '/tags/:id';

  /// Recurring rules ("subscriptions"); optional `walletId` narrows the list.
  static const subscriptions = '/subscriptions';

  /// Budgets (optional `walletId` narrows the list), one budget, the form.
  static const budgets = '/budgets';
  static const budgetDetails = '/budgets/:id';
  static const budgetForm = '/budget/form';

  /// Personal debts with people.
  static const debts = '/debts';
  static const newDebt = '/debts/new';
  static const debtTransaction = '/debts/:id/payment';
  static const debtDetails = '/debts/:id';

  static const settings = '/settings';
  static const baseCurrencySettings = '/settings/currency';
  static const aboutProject = '/settings/about';

  static const appLangSettings = '/settings/language';

  /// "Need help?" — list of guides; each guide is a nested page.
  static const help = '/settings/help';
  static const tagsHelp = '/settings/help/tags';
}
