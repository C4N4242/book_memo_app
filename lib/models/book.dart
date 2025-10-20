import 'package:intl/intl.dart';

/// 書籍のステータス
enum BookStatus {
  wishlist, // 気になる（ウィッシュリスト）
  reading, // 読書中
  completed; // 読了

  String get displayName {
    switch (this) {
      case BookStatus.wishlist:
        return '気になる';
      case BookStatus.reading:
        return '読書中';
      case BookStatus.completed:
        return '読了';
    }
  }

  String get emoji {
    switch (this) {
      case BookStatus.wishlist:
        return '💭';
      case BookStatus.reading:
        return '📖';
      case BookStatus.completed:
        return '⭐';
    }
  }
}

/// 書籍モデル
class Book {
  final String id;
  final String title; // 書籍名
  final String author; // 著者名
  final String? publisher; // 出版社（任意）
  final String? purchaseUrl; // 購入先URL
  final String? coverImageUrl; // カバー画像URL（Google Books APIから）
  final String? localImagePath; // ローカル画像パス（ユーザーが撮影/選択）
  final String? overallMemo; // 全体メモ・感想
  final String? recommendation; // おすすめポイント
  final double rating; // 評価（0-5）
  final BookStatus status; // ステータス
  final DateTime createdAt; // 登録日
  final DateTime? completedAt; // 読了日

  Book({
    required this.id,
    required this.title,
    required this.author,
    this.publisher,
    this.purchaseUrl,
    this.coverImageUrl,
    this.localImagePath,
    this.overallMemo,
    this.recommendation,
    this.rating = 0.0,
    this.status = BookStatus.wishlist,
    required this.createdAt,
    this.completedAt,
  });

  /// データベース用のMap変換
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'author': author,
      'publisher': publisher,
      'purchaseUrl': purchaseUrl,
      'coverImageUrl': coverImageUrl,
      'localImagePath': localImagePath,
      'overallMemo': overallMemo,
      'recommendation': recommendation,
      'rating': rating,
      'status': status.name,
      'createdAt': createdAt.toIso8601String(),
      'completedAt': completedAt?.toIso8601String(),
    };
  }

  /// Mapからインスタンス生成
  factory Book.fromMap(Map<String, dynamic> map) {
    return Book(
      id: map['id'] as String,
      title: map['title'] as String,
      author: map['author'] as String,
      publisher: map['publisher'] as String?,
      purchaseUrl: map['purchaseUrl'] as String?,
      coverImageUrl: map['coverImageUrl'] as String?,
      localImagePath: map['localImagePath'] as String?,
      overallMemo: map['overallMemo'] as String?,
      recommendation: map['recommendation'] as String?,
      rating: (map['rating'] as num?)?.toDouble() ?? 0.0,
      status: BookStatus.values.firstWhere(
        (e) => e.name == map['status'],
        orElse: () => BookStatus.wishlist,
      ),
      createdAt: DateTime.parse(map['createdAt'] as String),
      completedAt: map['completedAt'] != null
          ? DateTime.parse(map['completedAt'] as String)
          : null,
    );
  }

  /// コピーメソッド
  Book copyWith({
    String? id,
    String? title,
    String? author,
    String? publisher,
    String? purchaseUrl,
    String? coverImageUrl,
    String? localImagePath,
    String? overallMemo,
    String? recommendation,
    double? rating,
    BookStatus? status,
    DateTime? createdAt,
    DateTime? completedAt,
  }) {
    return Book(
      id: id ?? this.id,
      title: title ?? this.title,
      author: author ?? this.author,
      publisher: publisher ?? this.publisher,
      purchaseUrl: purchaseUrl ?? this.purchaseUrl,
      coverImageUrl: coverImageUrl ?? this.coverImageUrl,
      localImagePath: localImagePath ?? this.localImagePath,
      overallMemo: overallMemo ?? this.overallMemo,
      recommendation: recommendation ?? this.recommendation,
      rating: rating ?? this.rating,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      completedAt: completedAt ?? this.completedAt,
    );
  }

  /// 表示する画像（優先順位: ローカル画像 > カバー画像URL）
  String? get displayImagePath {
    return localImagePath ?? coverImageUrl;
  }

  /// 画像を持っているか
  bool get hasImage {
    return localImagePath != null || coverImageUrl != null;
  }

  /// 読了日のフォーマット表示
  String get formattedCompletedDate {
    if (completedAt == null) return '-';
    return DateFormat('yyyy/MM/dd').format(completedAt!);
  }

  /// 登録日のフォーマット表示
  String get formattedCreatedDate {
    return DateFormat('yyyy/MM/dd').format(createdAt);
  }
}
