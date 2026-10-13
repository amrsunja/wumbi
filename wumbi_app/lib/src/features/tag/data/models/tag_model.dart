import 'package:freezed_annotation/freezed_annotation.dart';

import '../../../../core/local/database/sqlite/sqlite_config.dart';
import '../../../../core/utils/extensions/date_time_extensions.dart';
import '../tag_normalizer.dart';

part 'tag_model.freezed.dart';

@freezed
abstract class TagModel with _$TagModel {
  const TagModel._();

  /// Last level of a nested tag: `coffee` for `food/coffee`.
  String get leafName => TagNormalizer.leaf(displayName);

  /// Normalized parent path, null for a top-level tag.
  String? get parentNormalized => TagNormalizer.parentOf(normalizedName);

  /// 0 = top level, 1 = `food/coffee`, …
  int get depth => TagNormalizer.depth(normalizedName);

  bool get isNested => depth > 0;

  const factory TagModel({
    required String id,
    required String normalizedName,
    required String displayName,
    required int usageCount,
    DateTime? lastUsedAt,
    required DateTime createdAt,
    required DateTime updatedAt,
    DateTime? deletedAt,
  }) = _TagModel;

  factory TagModel.fromRow(Map<String, Object?> r) => TagModel(
        id: r[SQLiteConfig.id] as String,
        normalizedName: r[SQLiteConfig.tagNormalizedName] as String,
        displayName: r[SQLiteConfig.tagDisplayName] as String,
        usageCount: (r[SQLiteConfig.tagUsageCount] as int?) ?? 0,
        lastUsedAt: r[SQLiteConfig.tagLastUsedAt] == null
            ? null
            : DateTimeExtension.fromEpochMs(r[SQLiteConfig.tagLastUsedAt] as int),
        createdAt: DateTimeExtension.fromEpochMs(r[SQLiteConfig.createdAt] as int),
        updatedAt: DateTimeExtension.fromEpochMs(r[SQLiteConfig.updatedAt] as int),
        deletedAt: r[SQLiteConfig.deletedAt] == null
            ? null
            : DateTimeExtension.fromEpochMs(r[SQLiteConfig.deletedAt] as int),
      );

  Map<String, Object?> toRow() => {
        SQLiteConfig.id: id,
        SQLiteConfig.tagNormalizedName: normalizedName,
        SQLiteConfig.tagDisplayName: displayName,
        SQLiteConfig.tagUsageCount: usageCount,
        SQLiteConfig.tagLastUsedAt: lastUsedAt?.epochMs,
        SQLiteConfig.createdAt: createdAt.epochMs,
        SQLiteConfig.updatedAt: updatedAt.epochMs,
        SQLiteConfig.deletedAt: deletedAt?.epochMs,
      };
}
