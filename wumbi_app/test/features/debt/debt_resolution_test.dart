import 'package:flutter_test/flutter_test.dart';
import 'package:wumbi/src/core/fx/fx_service.dart';
import 'package:wumbi/src/core/money/currency_type.dart';
import 'package:wumbi/src/core/money/money.dart';
import 'package:wumbi/src/core/utils/enums/debt_direction.dart';
import 'package:wumbi/src/features/debt/data/debt_resolution.dart';
import 'package:wumbi/src/features/debt/data/models/person_model.dart';

const _usd = CurrencyType.usd;
const _eur = CurrencyType.eur;

PersonBalance _balance({Map<CurrencyType, int> owedToMe = const {}, Map<CurrencyType, int> iOwe = const {}}) =>
    PersonBalance(personId: 'p', owedToMe: owedToMe, iOwe: iOwe);

double _noFx(CurrencyType from, CurrencyType to) => throw const FxUnavailableException();

RepaymentTarget _t(String id, int minor, [CurrencyType c = _usd]) =>
    RepaymentTarget(debtId: id, remaining: Money(minor, c));

void main() {
  group('resolveDebtFlow', () {
    test('GAVE to someone I owe → repays my debts', () {
      expect(resolveDebtFlow(_balance(iOwe: {_usd: 2000}), DebtFlow.outgoing),
          const RepaysDebts(DebtDirection.borrowed));
    });

    test('GAVE to someone I owe nothing → lends', () {
      expect(resolveDebtFlow(_balance(), DebtFlow.outgoing), const OpensDebt(DebtDirection.lent));
      expect(resolveDebtFlow(_balance(owedToMe: {_usd: 100}), DebtFlow.outgoing), const OpensDebt(DebtDirection.lent),
          reason: 'they already owe me: lending more is a new debt');
    });

    test('GOT from someone who owes me → their return', () {
      expect(resolveDebtFlow(_balance(owedToMe: {_usd: 15000}), DebtFlow.incoming),
          const RepaysDebts(DebtDirection.lent));
    });

    test('GOT from someone who owes me nothing → I borrow', () {
      expect(resolveDebtFlow(_balance(), DebtFlow.incoming), const OpensDebt(DebtDirection.borrowed));
    });

    test('both directions open: each flow repays its own side', () {
      final both = _balance(owedToMe: {_usd: 15000}, iOwe: {_eur: 2000});
      expect(resolveDebtFlow(both, DebtFlow.incoming), const RepaysDebts(DebtDirection.lent));
      expect(resolveDebtFlow(both, DebtFlow.outgoing), const RepaysDebts(DebtDirection.borrowed));
    });
  });

  group('allocateRepayment', () {
    test('FIFO across debts, same currency, exact', () {
      final shares = allocateRepayment(
        walletAmount: const Money(7000, _usd),
        targets: [_t('old', 5000), _t('new', 4000)],
        rate: _noFx,
      );
      expect(shares.map((s) => (s.debtId, s.amount.minor)), [('old', 5000), ('new', 2000)]);
    });

    test('over-repayment reports everything that is open', () {
      expect(
        () => allocateRepayment(walletAmount: const Money(9001, _usd), targets: [_t('a', 5000), _t('b', 4000)], rate: _noFx),
        throwsA(isA<OverRepayment>().having((e) => e.maxRemaining, 'max', const Money(9000, _usd))),
      );
    });

    test('cross currency: a full payment closes the debt exactly', () {
      double rate(CurrencyType f, CurrencyType t) => f == _usd ? 0.9 : 1.1111;
      final shares = allocateRepayment(walletAmount: const Money(9000, _eur), targets: [_t('a', 10000)], rate: rate);
      expect(shares.single.amount, const Money(10000, _usd));
    });

    test('cross currency: a 1-minor residue is absorbed', () {
      double rate(CurrencyType f, CurrencyType t) => f == _usd ? 0.9 : 1.1111;
      // 89.99 EUR × 1.1111 = 99.988… → 9999 USD minor, 1 left → closes.
      final shares = allocateRepayment(walletAmount: const Money(8999, _eur), targets: [_t('a', 10000)], rate: rate);
      expect(shares.single.amount, const Money(10000, _usd));
    });

    test('cross currency: a real partial payment stays partial', () {
      double rate(CurrencyType f, CurrencyType t) => f == _usd ? 0.9 : 1.1111;
      final shares = allocateRepayment(walletAmount: const Money(4500, _eur), targets: [_t('a', 10000)], rate: rate);
      expect(shares.single.amount, const Money(5000, _usd));
    });

    test('typed in the debt currency with one target → typed amount, no FX', () {
      final shares = allocateRepayment(
        walletAmount: const Money(9213, _eur),
        original: const Money(10000, _usd),
        targets: [_t('a', 10000)],
        rate: _noFx,
      );
      expect(shares.single.amount, const Money(10000, _usd));
      expect(shares.single.walletAmountMinor, 9213);
    });
  });
}
