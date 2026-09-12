import '../../../../core/money/currency_type.dart';
import '../../../../core/money/money.dart';
import '../../../../core/utils/enums/wallet_color.dart';
import 'tag_model.dart';

/// Raw SQL aggregate: one row per tag × currency × type.
class TagCurrencySum {
  const TagCurrencySum({
    required this.tagId,
    required this.currencyCode,
    required this.type,
    required this.totalMinor,
    required this.count,
  });

  final String tagId;
  final String currencyCode;

  /// 'income' | 'expense'
  final String type;
  final int totalMinor;
  final int count;
}

/// A wallet touched by a tag, with in/out sums in the wallet's currency.
class TagWalletSum {
  const TagWalletSum({
    required this.walletId,
    required this.name,
    required this.currencyCode,
    required this.colorKey,
    required this.walletDeleted,
    required this.inMinor,
    required this.outMinor,
    required this.count,
  });

  final String walletId;
  final String name;
  final String currencyCode;
  final String? colorKey;
  final bool walletDeleted;
  final int inMinor;
  final int outMinor;
  final int count;

  CurrencyType get currency => CurrencyType.fromCode(currencyCode);
  WalletColor get color => WalletColor.fromString(colorKey);
  Money get inflow => Money(inMinor, currency);
  Money get outflow => Money(outMinor, currency);
  Money get net => Money(inMinor - outMinor, currency);
}

/// Undirected co-occurrence edge between two tags (graph view).
class TagLink {
  const TagLink({required this.a, required this.b, required this.count});

  final String a;
  final String b;
  final int count;
}

/// Tag + totals converted into the base currency (rates from the local FX
/// cache; currencies without a cached rate are listed in [unconvertible]).
class TagStats {
  const TagStats({
    required this.tag,
    required this.income,
    required this.expense,
    required this.transactionCount,
    this.unconvertible = const [],
  });

  final TagModel tag;

  /// Base-currency sums (positive magnitudes).
  final Money income;
  final Money expense;
  final int transactionCount;
  final List<CurrencyType> unconvertible;

  String get id => tag.id;
  String get name => tag.displayName;

  /// income − expense.
  Money get net => Money(income.minor - expense.minor, income.currency);

  /// Magnitude used for node sizing / ranking: total money that moved.
  int get volumeMinor => income.minor + expense.minor;
}

/// Everything the graph view needs in one fetch.
class TagGraphData {
  const TagGraphData({required this.nodes, required this.links, required this.base});

  final List<TagStats> nodes;
  final List<TagLink> links;
  final CurrencyType base;

  bool get isEmpty => nodes.isEmpty;
}
