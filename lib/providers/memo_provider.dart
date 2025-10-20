import 'package:flutter/foundation.dart';
import '../models/page_memo.dart';
import '../database/database_helper.dart';

/// ページメモ管理用のプロバイダー
class MemoProvider with ChangeNotifier {
  final DatabaseHelper _dbHelper = DatabaseHelper.instance;

  List<PageMemo> _memos = [];
  bool _isLoading = false;
  String? _error;
  String? _currentBookId;

  // Getters
  List<PageMemo> get memos => _memos;
  bool get isLoading => _isLoading;
  String? get error => _error;

  /// 特定の書籍のメモを読み込む
  Future<void> loadMemosByBookId(String bookId) async {
    _currentBookId = bookId;
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _memos = await _dbHelper.getPageMemosByBookId(bookId);
    } catch (e) {
      _error = 'メモの読み込みに失敗しました: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// メモを追加
  Future<void> addMemo(PageMemo memo) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      await _dbHelper.createPageMemo(memo);
      // 同じ書籍のメモなら追加
      if (memo.bookId == _currentBookId) {
        await loadMemosByBookId(memo.bookId);
      }
    } catch (e) {
      _error = 'メモの追加に失敗しました: $e';
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// メモを更新
  Future<void> updateMemo(PageMemo memo) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      await _dbHelper.updatePageMemo(memo);
      // リストの該当メモを更新
      final index = _memos.indexWhere((m) => m.id == memo.id);
      if (index != -1) {
        _memos[index] = memo;
      }
    } catch (e) {
      _error = 'メモの更新に失敗しました: $e';
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// メモを削除
  Future<void> deleteMemo(String id) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      await _dbHelper.deletePageMemo(id);
      _memos.removeWhere((memo) => memo.id == id);
    } catch (e) {
      _error = 'メモの削除に失敗しました: $e';
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// メモを検索
  Future<void> searchMemos(String bookId, String query) async {
    if (query.isEmpty) {
      await loadMemosByBookId(bookId);
      return;
    }

    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _memos = await _dbHelper.searchMemos(bookId, query);
    } catch (e) {
      _error = 'メモの検索に失敗しました: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// タイプ別にメモをフィルタリング
  List<PageMemo> getMemsByType(MemoType type) {
    return _memos.where((memo) => memo.type == type).toList();
  }

  /// メモの件数を取得
  int get memoCount => _memos.length;

  /// タイプ別のメモ件数を取得
  Map<MemoType, int> get memoCountsByType {
    final counts = <MemoType, int>{};
    for (final type in MemoType.values) {
      counts[type] = _memos.where((m) => m.type == type).length;
    }
    return counts;
  }
}
