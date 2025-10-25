import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/book.dart';
import '../providers/book_provider.dart';
import '../widgets/book_card.dart';
import 'book_detail_screen.dart';

/// 書籍検索画面
class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final TextEditingController _searchController = TextEditingController();
  List<Book> _searchResults = [];
  bool _isSearching = false;
  bool _hasSearched = false;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  /// 検索実行
  Future<void> _performSearch(String query) async {
    if (query.trim().isEmpty) {
      setState(() {
        _searchResults = [];
        _hasSearched = false;
      });
      return;
    }

    setState(() {
      _isSearching = true;
      _hasSearched = true;
    });

    try {
      final bookProvider = Provider.of<BookProvider>(context, listen: false);
      await bookProvider.searchBooks(query.trim());

      setState(() {
        _searchResults = bookProvider.books;
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('検索に失敗しました: $e')));
      }
    } finally {
      setState(() {
        _isSearching = false;
      });
    }
  }

  /// 検索クリア
  void _clearSearch() {
    _searchController.clear();
    setState(() {
      _searchResults = [];
      _hasSearched = false;
    });
    // 元のリストに戻す
    Provider.of<BookProvider>(context, listen: false).loadBooks();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('書籍を検索')),
      body: Column(
        children: [
          // 検索バー
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'タイトル、著者名、出版社で検索',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: _clearSearch,
                      )
                    : null,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              onChanged: (value) {
                setState(() {}); // suffixIconの表示更新のため
                // リアルタイム検索（デバウンス処理なし）
                _performSearch(value);
              },
              onSubmitted: _performSearch,
              autofocus: true,
            ),
          ),

          // 検索結果
          Expanded(child: _buildSearchResults()),
        ],
      ),
    );
  }

  /// 検索結果の表示
  Widget _buildSearchResults() {
    if (_isSearching) {
      return const Center(child: CircularProgressIndicator());
    }

    if (!_hasSearched) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.search, size: 80, color: Colors.grey[400]),
            const SizedBox(height: 16),
            Text(
              'タイトル、著者名、出版社を入力して検索',
              style: TextStyle(fontSize: 16, color: Colors.grey[600]),
            ),
          ],
        ),
      );
    }

    if (_searchResults.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.book_outlined, size: 80, color: Colors.grey[400]),
            const SizedBox(height: 16),
            Text(
              '該当する書籍が見つかりませんでした',
              style: TextStyle(fontSize: 16, color: Colors.grey[600]),
            ),
            const SizedBox(height: 8),
            Text(
              '別のキーワードで検索してみてください',
              style: TextStyle(fontSize: 14, color: Colors.grey[500]),
            ),
          ],
        ),
      );
    }

    // 検索結果のリスト表示
    return LayoutBuilder(
      builder: (context, constraints) {
        final isWideScreen = constraints.maxWidth > 600;

        if (isWideScreen) {
          // タブレット・横向きスマホ用のグリッドレイアウト
          final crossAxisCount = constraints.maxWidth > 900 ? 3 : 2;
          return GridView.builder(
            padding: const EdgeInsets.all(16),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: crossAxisCount,
              childAspectRatio: 0.75,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
            ),
            itemCount: _searchResults.length,
            itemBuilder: (context, index) {
              final book = _searchResults[index];
              return BookCard(
                book: book,
                onTap: () => _navigateToDetail(context, book),
                isGridLayout: true,
              );
            },
          );
        } else {
          // スマホ縦向き用のリストレイアウト
          return ListView.builder(
            itemCount: _searchResults.length,
            padding: const EdgeInsets.symmetric(vertical: 8),
            itemBuilder: (context, index) {
              final book = _searchResults[index];
              return BookCard(
                book: book,
                onTap: () => _navigateToDetail(context, book),
              );
            },
          );
        }
      },
    );
  }

  Future<void> _navigateToDetail(BuildContext context, Book book) async {
    final result = await Navigator.of(context).push<bool>(
      MaterialPageRoute(builder: (context) => BookDetailScreen(book: book)),
    );

    if (!mounted) return;

    if (result == true) {
      // 更新があった場合に再検索
      final query = _searchController.text.trim();
      if (query.isNotEmpty) {
        _performSearch(query);
      }
    }
  }
}
