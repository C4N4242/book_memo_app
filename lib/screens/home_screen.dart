import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/book.dart';
import '../providers/book_provider.dart';
import '../providers/theme_provider.dart';
import '../widgets/app_drawer.dart';
import '../widgets/book_card.dart';
import 'add_book_screen.dart';
import 'book_detail_screen.dart';
import 'search_screen.dart';

/// ホーム画面（すべての書籍一覧）
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  BookStatus? _selectedStatus;
  String? _selectedPublisher;
  List<String> _publishers = [];

  @override
  void initState() {
    super.initState();
    // 初回データ読み込み
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<BookProvider>(context, listen: false).loadBooks();
      _loadPublishers();
    });
  }

  /// 出版社リストの読み込み
  Future<void> _loadPublishers() async {
    final bookProvider = Provider.of<BookProvider>(context, listen: false);
    final publishers = await bookProvider.getAllPublishers();
    setState(() {
      _publishers = publishers;
    });
  }

  /// フィルターを適用
  Future<void> _applyFilter() async {
    final bookProvider = Provider.of<BookProvider>(context, listen: false);

    if (_selectedStatus != null && _selectedPublisher != null) {
      // ステータスと出版社の両方でフィルター
      await bookProvider.filterByStatusAndPublisher(
        _selectedStatus!,
        _selectedPublisher!,
      );
    } else if (_selectedStatus != null) {
      // ステータスのみでフィルター
      await bookProvider.loadBooksByStatus(_selectedStatus!);
    } else if (_selectedPublisher != null) {
      // 出版社のみでフィルター
      await bookProvider.loadBooksByPublisher(_selectedPublisher!);
    } else {
      // フィルターなし
      await bookProvider.loadBooks();
    }
  }

  /// フィルターをクリア
  Future<void> _clearFilter() async {
    setState(() {
      _selectedStatus = null;
      _selectedPublisher = null;
    });
    await Provider.of<BookProvider>(context, listen: false).loadBooks();
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
          // フィルターボタン
          IconButton(
            icon: Badge(
              isLabelVisible:
                  _selectedStatus != null || _selectedPublisher != null,
              child: const Icon(Icons.filter_list),
            ),
            tooltip: 'フィルター',
            onPressed: _showFilterDialog,
          ),
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
              // 検索画面へ遷移
              Navigator.of(context)
                  .push(
                    MaterialPageRoute(
                      builder: (context) => const SearchScreen(),
                    ),
                  )
                  .then((_) {
                    // 検索画面から戻った時にリロード
                    Provider.of<BookProvider>(
                      context,
                      listen: false,
                    ).loadBooks();
                  });
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
        child: Column(
          children: [
            // フィルター表示エリア
            if (_selectedStatus != null || _selectedPublisher != null)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                color: Theme.of(context).colorScheme.primaryContainer,
                child: Wrap(
                  spacing: 8,
                  runSpacing: 4,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [
                    const Icon(Icons.filter_list, size: 20),
                    if (_selectedStatus != null)
                      Chip(
                        label: Text(
                          '${_selectedStatus!.emoji} ${_selectedStatus!.displayName}',
                        ),
                        onDeleted: () {
                          setState(() {
                            _selectedStatus = null;
                          });
                          _applyFilter();
                        },
                      ),
                    if (_selectedPublisher != null)
                      Chip(
                        label: Text(_selectedPublisher!),
                        onDeleted: () {
                          setState(() {
                            _selectedPublisher = null;
                          });
                          _applyFilter();
                        },
                      ),
                    TextButton.icon(
                      icon: const Icon(Icons.clear, size: 16),
                      label: const Text('すべてクリア'),
                      onPressed: _clearFilter,
                    ),
                  ],
                ),
              ),
            // メインコンテンツ
            Expanded(
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
                            style: Theme.of(context).textTheme.titleLarge
                                ?.copyWith(color: Colors.grey[600]),
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
                          final crossAxisCount = constraints.maxWidth > 900
                              ? 3
                              : 2;
                          return GridView.builder(
                            padding: const EdgeInsets.all(16),
                            gridDelegate:
                                SliverGridDelegateWithFixedCrossAxisCount(
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
            ),
          ],
        ),
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

  /// フィルターダイアログを表示
  Future<void> _showFilterDialog() async {
    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('絞り込み'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ステータスフィルター
              Text('ステータス', style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                children: [
                  ChoiceChip(
                    label: const Text('すべて'),
                    selected: _selectedStatus == null,
                    onSelected: (selected) {
                      setState(() {
                        _selectedStatus = null;
                      });
                      Navigator.pop(context);
                      _applyFilter();
                    },
                  ),
                  ...BookStatus.values.map((status) {
                    return ChoiceChip(
                      label: Text('${status.emoji} ${status.displayName}'),
                      selected: _selectedStatus == status,
                      onSelected: (selected) {
                        setState(() {
                          _selectedStatus = selected ? status : null;
                        });
                        Navigator.pop(context);
                        _applyFilter();
                      },
                    );
                  }),
                ],
              ),
              const SizedBox(height: 16),
              const Divider(),
              const SizedBox(height: 16),
              // 出版社フィルター
              Text('出版社', style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(height: 8),
              if (_publishers.isEmpty)
                const Text('出版社情報がありません')
              else
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    RadioListTile<String?>(
                      title: const Text('すべて'),
                      value: null,
                      groupValue: _selectedPublisher,
                      onChanged: (value) {
                        setState(() {
                          _selectedPublisher = null;
                        });
                        Navigator.pop(context);
                        _applyFilter();
                      },
                    ),
                    ..._publishers.map((publisher) {
                      return RadioListTile<String?>(
                        title: Text(publisher),
                        value: publisher,
                        groupValue: _selectedPublisher,
                        onChanged: (value) {
                          setState(() {
                            _selectedPublisher = value;
                          });
                          Navigator.pop(context);
                          _applyFilter();
                        },
                      );
                    }),
                  ],
                ),
            ],
          ),
        ),
        actions: [
          if (_selectedStatus != null || _selectedPublisher != null)
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                _clearFilter();
              },
              child: const Text('クリア'),
            ),
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('閉じる'),
          ),
        ],
      ),
    );
  }
}
