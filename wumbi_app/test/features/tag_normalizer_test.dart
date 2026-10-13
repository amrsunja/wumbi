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

  test('nested paths: clean slashes, parents, depth', () {
    expect(TagNormalizer.display('#Food//Coffee/ '), 'Food/Coffee');
    expect(TagNormalizer.normalize('/food/coffee/'), 'food/coffee');
    expect(TagNormalizer.ancestors('a/b/c'), ['a', 'a/b']);
    expect(TagNormalizer.parentOf('a/b/c'), 'a/b');
    expect(TagNormalizer.parentOf('a'), isNull);
    expect(TagNormalizer.leaf('a/b/c'), 'c');
    expect(TagNormalizer.depth('a/b/c'), 2);
    expect(TagNormalizer.isDescendant('food/coffee', 'food'), isTrue);
    expect(TagNormalizer.isDescendant('foodtruck', 'food'), isFalse);
    expect(TagNormalizer.isDescendant('food', 'food'), isFalse);
  });
}
