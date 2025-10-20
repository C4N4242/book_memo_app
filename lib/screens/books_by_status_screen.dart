import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/book.dart';
import '../providers/book_provider.dart';
import '../widgets/app_drawer.dart';
import '../widgets/book_card.dart';
import 'add_book_screen.dart';
import 'book_detail_screen.dart';

/// ステータス別書籍一覧画面
class BooksByStatusScreen extends StatefulWidget {
  final BookStatus status;

  const BooksByStatusScreen({super.key, required this.status});

  @override
  State<BooksByStatusScreen> createState() => _BooksByStatusScreenState();
}

class _BooksByStatusScreenState extends State<BooksByStatusScreen> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
    // 初回データ読み込み
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<BookProvider>(
        context,
        listen: false,
      ).loadBooksByStatus(widget.status);
    });
  }

  /// 画面中央からのスワイプでドロワーを開く
  void _handleHorizontalDragEnd(DragEndDetails details) {
    if (details.velocity.pixelsPerSecond.dx > 500) {
      _scaffoldKey.currentState?.openDrawer();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        title: Text('${widget.status.emoji} ${widget.status.displayName}'),
      ),
      drawer: const AppDrawer(),
      // Android 12+のジェスチャーナビゲーションとの競合を避ける
      drawerEnableOpenDragGesture: false,
      body: GestureDetector(
        onHorizontalDragEnd: _handleHorizontalDragEnd,
        child: Consumer<BookProvider>(
          builder: (context, bookProvider, child) {
            if (bookProvider.isLoading) {
              return const Center(child: CircularProgressIndicator());
            }

            if (bookProvider.error != null) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.error_outline,
                      size: 64,
                      color: Colors.red,
                    ),
                    const SizedBox(height: 16),
                    Text(bookProvider.error!),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () =>
                          bookProvider.loadBooksByStatus(widget.status),
                      child: const Text('再読み込み'),
                    ),
                  ],
                ),
              );
            }

            final books = bookProvider.books;

            if (books.isEmpty) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.book_outlined,
                      size: 80,
                      color: Colors.grey[400],
                    ),
                    const SizedBox(height: 16),
                    Text(
                      '${widget.status.displayName}の本がありません',
                      style: Theme.of(
                        context,
                      ).textTheme.titleLarge?.copyWith(color: Colors.grey[600]),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '右下のボタンから追加してみましょう！',
                      style: TextStyle(color: Colors.grey[600]),
                    ),
                  ],
                ),
              );
            }

            return RefreshIndicator(
              onRefresh: () => bookProvider.loadBooksByStatus(widget.status),
              child: LayoutBuilder(
                builder: (context, constraints) {
                  final isWideScreen = constraints.maxWidth > 600;

                  if (isWideScreen) {
                    final crossAxisCount = constraints.maxWidth > 900 ? 3 : 2;
                    return GridView.builder(
                      padding: const EdgeInsets.all(16),
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: crossAxisCount,
                        childAspectRatio: 0.75,
                        crossAxisSpacing: 16,
                        mainAxisSpacing: 16,
                      ),
                      itemCount: books.length,
                      itemBuilder: (context, index) {
                        final book = books[index];
                        return BookCard(
                          book: book,
                          onTap: () => _navigateToDetail(context, book),
                          isGridLayout: true,
                        );
                      },
                    );
                  } else {
                    return ListView.builder(
                      itemCount: books.length,
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      itemBuilder: (context, index) {
                        final book = books[index];
                        return BookCard(
                          book: book,
                          onTap: () => _navigateToDetail(context, book),
                        );
                      },
                    );
                  }
                },
              ),
            );
          },
        ), // Consumer<BookProvider>を閉じる
      ), // GestureDetectorを閉じる
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _navigateToAddBook(context),
        icon: const Icon(Icons.add),
        label: const Text('本を追加'),
      ),
    );
  }

  Future<void> _navigateToAddBook(BuildContext context) async {
    final navigator = Navigator.of(context);
    final result = await navigator.push<bool>(
      MaterialPageRoute(builder: (context) => const AddBookScreen()),
    );

    if (!mounted) return;

    if (result == true) {
      // 追加成功時にリロード
      if (context.mounted) {
        Provider.of<BookProvider>(
          context,
          listen: false,
        ).loadBooksByStatus(widget.status);
      }
    }
  }

  Future<void> _navigateToDetail(BuildContext context, Book book) async {
    final navigator = Navigator.of(context);
    final result = await navigator.push<bool>(
      MaterialPageRoute(builder: (context) => BookDetailScreen(book: book)),
    );

    if (!mounted) return;

    if (result == true) {
      // 更新があった場合にリロード
      if (context.mounted) {
        Provider.of<BookProvider>(
          context,
          listen: false,
        ).loadBooksByStatus(widget.status);
      }
    }
  }
}
