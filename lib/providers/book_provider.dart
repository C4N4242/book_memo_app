import 'package:flutter/foundation.dart';
import '../models/book.dart';
import '../database/database_helper.dart';

/// 書籍管理用のプロバイダー
class BookProvider with ChangeNotifier {
  final DatabaseHelper _dbHelper = DatabaseHelper.instance;

  List<Book> _books = [];
  Map<BookStatus, int> _statusCounts = {};
  bool _isLoading = false;
  String? _error;

  // Getters
  List<Book> get books => _books;
  Map<BookStatus, int> get statusCounts => _statusCounts;
  bool get isLoading => _isLoading;
  String? get error => _error;

  /// すべての書籍を読み込む
  Future<void> loadBooks() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _books = await _dbHelper.getAllBooks();
      await _loadStatusCounts();
    } catch (e) {
      _error = 'データの読み込みに失敗しました: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// ステータス別に書籍を読み込む
  Future<void> loadBooksByStatus(BookStatus status) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _books = await _dbHelper.getBooksByStatus(status);
    } catch (e) {
      _error = 'データの読み込みに失敗しました: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// ステータス別のカウントを読み込む
  Future<void> _loadStatusCounts() async {
    try {
      _statusCounts = await _dbHelper.getBookCountsByStatus();
    } catch (e) {
      debugPrint('カウントの読み込みに失敗: $e');
    }
  }

  /// 書籍を追加
  Future<void> addBook(Book book) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      await _dbHelper.createBook(book);
      await loadBooks(); // リスト再読み込み
    } catch (e) {
      _error = '書籍の追加に失敗しました: $e';
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// 書籍を更新
  Future<void> updateBook(Book book) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      await _dbHelper.updateBook(book);
      // リストの該当書籍を更新
      final index = _books.indexWhere((b) => b.id == book.id);
      if (index != -1) {
        _books[index] = book;
      }
      await _loadStatusCounts();
    } catch (e) {
      _error = '書籍の更新に失敗しました: $e';
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// 書籍を削除
  Future<void> deleteBook(String id) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      await _dbHelper.deleteBook(id);
      _books.removeWhere((book) => book.id == id);
      await _loadStatusCounts();
    } catch (e) {
      _error = '書籍の削除に失敗しました: $e';
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// 書籍を検索
  Future<void> searchBooks(String query) async {
    if (query.isEmpty) {
      await loadBooks();
      return;
    }

    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _books = await _dbHelper.searchBooks(query);
    } catch (e) {
      _error = '検索に失敗しました: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// 特定の書籍を取得
  Future<Book?> getBook(String id) async {
    try {
      return await _dbHelper.getBook(id);
    } catch (e) {
      _error = '書籍の取得に失敗しました: $e';
      return null;
    }
  }

  /// ステータス別の書籍数を取得
  int getCountByStatus(BookStatus status) {
    return _statusCounts[status] ?? 0;
  }
}
