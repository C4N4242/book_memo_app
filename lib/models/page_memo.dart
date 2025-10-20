import 'package:intl/intl.dart';

/// メモの種類
enum MemoType {
  general, // 一般メモ
  quote, // 引用
  insight, // 気づき
  question; // 疑問点

  String get displayName {
    switch (this) {
      case MemoType.general:
        return '一般メモ';
      case MemoType.quote:
        return '引用';
      case MemoType.insight:
        return '気づき';
      case MemoType.question:
        return '疑問点';
    }
  }

  String get emoji {
    switch (this) {
      case MemoType.general:
        return '📝';
      case MemoType.quote:
        return '💬';
      case MemoType.insight:
        return '💡';
      case MemoType.question:
        return '❓';
    }
  }
}

/// ページメモモデル
class PageMemo {
  final String id;
  final String bookId; // 所属する書籍のID
  final int? pageNumber; // ページ番号（任意）
  final String? chapterName; // 章名（任意）
  final String? quote; // 引用文（任意）
  final String memo; // メモ・感想
  final MemoType type; // メモの種類
  final DateTime createdAt; // 作成日時
  final DateTime updatedAt; // 更新日時

  PageMemo({
    required this.id,
    required this.bookId,
    this.pageNumber,
    this.chapterName,
    this.quote,
    required this.memo,
    this.type = MemoType.general,
    required this.createdAt,
    required this.updatedAt,
  });

  /// データベース用のMap変換
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'bookId': bookId,
      'pageNumber': pageNumber,
      'chapterName': chapterName,
      'quote': quote,
      'memo': memo,
      'type': type.name,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  /// Mapからインスタンス生成
  factory PageMemo.fromMap(Map<String, dynamic> map) {
    return PageMemo(
      id: map['id'] as String,
      bookId: map['bookId'] as String,
      pageNumber: map['pageNumber'] as int?,
      chapterName: map['chapterName'] as String?,
      quote: map['quote'] as String?,
      memo: map['memo'] as String,
      type: MemoType.values.firstWhere(
        (e) => e.name == map['type'],
        orElse: () => MemoType.general,
      ),
      createdAt: DateTime.parse(map['createdAt'] as String),
      updatedAt: DateTime.parse(map['updatedAt'] as String),
    );
  }

  /// コピーメソッド
  PageMemo copyWith({
    String? id,
    String? bookId,
    int? pageNumber,
    String? chapterName,
    String? quote,
    String? memo,
    MemoType? type,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return PageMemo(
      id: id ?? this.id,
      bookId: bookId ?? this.bookId,
      pageNumber: pageNumber ?? this.pageNumber,
      chapterName: chapterName ?? this.chapterName,
      quote: quote ?? this.quote,
      memo: memo ?? this.memo,
      type: type ?? this.type,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  /// ページ番号の表示用文字列
  String get pageDisplay {
    if (pageNumber != null) {
      return 'p.$pageNumber';
    }
    return '';
  }

  /// 作成日時のフォーマット表示
  String get formattedCreatedDate {
    return DateFormat('yyyy/MM/dd HH:mm').format(createdAt);
  }

  /// 更新日時のフォーマット表示
  String get formattedUpdatedDate {
    return DateFormat('yyyy/MM/dd HH:mm').format(updatedAt);
  }

  /// 共有用テキストの生成
  String generateShareText(String bookTitle) {
    final buffer = StringBuffer();
    buffer.writeln('📚 $bookTitle');
    if (pageNumber != null) {
      buffer.writeln('📖 $pageDisplay');
    }
    if (chapterName != null && chapterName!.isNotEmpty) {
      buffer.writeln('【$chapterName】');
    }
    if (quote != null && quote!.isNotEmpty) {
      buffer.writeln('\n「$quote」');
    }
    buffer.writeln('\n${type.emoji} $memo');
    return buffer.toString();
  }
}
