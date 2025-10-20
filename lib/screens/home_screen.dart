import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/book.dart';
import '../providers/book_provider.dart';
import '../providers/theme_provider.dart';
import '../widgets/app_drawer.dart';
import '../widgets/book_card.dart';
import 'add_book_screen.dart';
import 'book_detail_screen.dart';

/// ホーム画面（すべての書籍一覧）
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
    // 初回データ読み込み
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<BookProvider>(context, listen: false).loadBooks();
    });
  }

  /// 画面中央からのスワイプでドロワーを開く
  void _handleHorizontalDragEnd(DragEndDetails details) {
    // 右方向へのスワイプ（velocity.pixelsPerSecond.dx > 0）でドロワーを開く
    if (details.velocity.pixelsPerSecond.dx > 500) {
      _scaffoldKey.currentState?.openDrawer();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        title: const Text('My本棚'),
        actions: [
          // テーマ切り替えボタン
          Consumer<ThemeProvider>(
            builder: (context, themeProvider, _) {
              return IconButton(
                icon: Icon(themeProvider.themeModeIcon),
                tooltip: 'テーマ: ${themeProvider.themeModeString}',
                onPressed: () async {
                  await themeProvider.toggleThemeMode();
                },
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () {
              // 検索画面へ遷移（今後実装）
              ScaffoldMessenger.of(
                context,
              ).showSnackBar(const SnackBar(content: Text('検索機能は今後実装予定です')));
            },
          ),
        ],
      ),
      drawer: const AppDrawer(),
      // Android 12+のジェスチャーナビゲーションとの競合を避けるため、
      // 画面端からのスワイプは無効化
      drawerEnableOpenDragGesture: false,
      body: GestureDetector(
        // 画面中央からの右スワイプでドロワーを開く
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
                      onPressed: () => bookProvider.loadBooks(),
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
                      '書籍がまだありません',
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
              onRefresh: () => bookProvider.loadBooks(),
              child: LayoutBuilder(
                builder: (context, constraints) {
                  // 横長画面ではグリッドレイアウト、縦長ではリスト
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
                    // スマホ縦向き用のリストレイアウト
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
        Provider.of<BookProvider>(context, listen: false).loadBooks();
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
        Provider.of<BookProvider>(context, listen: false).loadBooks();
      }
    }
  }
}
