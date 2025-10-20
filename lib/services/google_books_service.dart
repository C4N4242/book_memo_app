import 'dart:convert';
import 'package:http/http.dart' as http;

/// Google Books APIから書籍情報を取得するサービス
class GoogleBooksService {
  static const String _baseUrl = 'https://www.googleapis.com/books/v1/volumes';

  /// 書籍を検索
  /// [query] には書籍名や著者名を指定
  /// [maxResults] 取得する最大件数（デフォルト: 5）
  Future<List<BookSearchResult>> searchBooks(
    String query, {
    int maxResults = 5,
  }) async {
    try {
      final encodedQuery = Uri.encodeComponent(query);
      final url = Uri.parse(
        '$_baseUrl?q=$encodedQuery&maxResults=$maxResults&langRestrict=ja',
      );

      final response = await http.get(url);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final items = data['items'] as List<dynamic>?;

        if (items == null || items.isEmpty) {
          return [];
        }

        return items
            .map((item) => BookSearchResult.fromJson(item))
            .where((result) => result.thumbnail != null) // サムネイルがあるもののみ
            .toList();
      }

      return [];
    } catch (e) {
      // エラーログは開発時のみ
      // print('Google Books API エラー: $e');
      return [];
    }
  }

  /// 書籍名と著者名で検索（より精度が高い）
  Future<List<BookSearchResult>> searchByTitleAndAuthor(
    String title,
    String author, {
    int maxResults = 5,
  }) async {
    final query = 'intitle:$title+inauthor:$author';
    return searchBooks(query, maxResults: maxResults);
  }
}

/// 書籍検索結果
class BookSearchResult {
  final String id;
  final String title;
  final List<String> authors;
  final String? publisher;
  final String? publishedDate;
  final String? description;
  final String? thumbnail; // サムネイル画像URL
  final String? previewLink;

  BookSearchResult({
    required this.id,
    required this.title,
    required this.authors,
    this.publisher,
    this.publishedDate,
    this.description,
    this.thumbnail,
    this.previewLink,
  });

  factory BookSearchResult.fromJson(Map<String, dynamic> json) {
    final volumeInfo = json['volumeInfo'] as Map<String, dynamic>;
    final imageLinks = volumeInfo['imageLinks'] as Map<String, dynamic>?;

    // サムネイル画像のURLを取得（HTTPSに変換）
    String? thumbnailUrl = imageLinks?['thumbnail'] as String?;
    if (thumbnailUrl != null && thumbnailUrl.startsWith('http:')) {
      thumbnailUrl = thumbnailUrl.replaceFirst('http:', 'https:');
    }

    return BookSearchResult(
      id: json['id'] as String,
      title: volumeInfo['title'] as String? ?? '不明',
      authors:
          (volumeInfo['authors'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          [],
      publisher: volumeInfo['publisher'] as String?,
      publishedDate: volumeInfo['publishedDate'] as String?,
      description: volumeInfo['description'] as String?,
      thumbnail: thumbnailUrl,
      previewLink: volumeInfo['previewLink'] as String?,
    );
  }

  /// 著者名を結合して返す
  String get authorsText {
    if (authors.isEmpty) return '著者不明';
    return authors.join(', ');
  }
}
