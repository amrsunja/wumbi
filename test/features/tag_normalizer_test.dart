import 'package:wumbi/src/features/tag/data/tag_normalizer.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('normalize strips #, trims, lower-cases', () {
    expect(TagNormalizer.normalize('#Food'), 'food');
    expect(TagNormalizer.normalize('  food '), 'food');
    expect(TagNormalizer.normalize('##Work'), 'work');
    expect(TagNormalizer.normalize('two words'), 'twowords');
  });

  test('display keeps casing', () {
    expect(TagNormalizer.display('#Food'), 'Food');
  });

  test('dedupe keeps first casing', () {
    expect(TagNormalizer.dedupe(['Food', '#food', 'food ', 'Work']), ['Food', 'Work']);
    expect(TagNormalizer.dedupe(['', '#', '  ']), isEmpty);
  });
}
