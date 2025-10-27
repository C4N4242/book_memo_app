import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import '../models/book.dart';
import '../models/page_memo.dart';
import '../providers/book_provider.dart';
import '../providers/memo_provider.dart';
import '../widgets/sns_share_dialog.dart';
import 'add_book_screen.dart';
import 'add_memo_screen.dart';

/// 書籍詳細画面
class BookDetailScreen extends StatefulWidget {
  final Book book;

  const BookDetailScreen({super.key, required this.book});

  @override
  State<BookDetailScreen> createState() => _BookDetailScreenState();
}

class _BookDetailScreenState extends State<BookDetailScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  late Book _currentBook;

  @override
  void initState() {
    super.initState();
    _currentBook = widget.book;
    _tabController = TabController(length: 2, vsync: this);

    // メモを読み込む
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<MemoProvider>(
        context,
        listen: false,
      ).loadMemosByBookId(_currentBook.id);
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('書籍詳細'),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: _editBook,
            tooltip: '編集',
          ),
          IconButton(
            icon: const Icon(Icons.share),
            onPressed: _shareBook,
            tooltip: '共有',
          ),
          PopupMenuButton<String>(
            onSelected: (value) {
              if (value == 'delete') {
                _deleteBook();
              }
            },
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'delete',
                child: Row(
                  children: [
                    Icon(Icons.delete, color: Colors.red),
                    SizedBox(width: 8),
                    Text('削除', style: TextStyle(color: Colors.red)),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          final isWideScreen = constraints.maxWidth > 600;

          if (isWideScreen) {
            // 横長画面: 2カラムレイアウト
            return Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 左側: ヘッダー情報（固定幅）
                SizedBox(
                  width: 350,
                  child: SingleChildScrollView(child: _buildHeader()),
                ),
                const VerticalDivider(width: 1),
                // 右側: タブビュー
                Expanded(
                  child: Column(
                    children: [
                      TabBar(
                        controller: _tabController,
                        tabs: const [
                          Tab(text: '全体メモ'),
                          Tab(text: 'ページメモ'),
                        ],
                      ),
                      Expanded(
                        child: TabBarView(
                          controller: _tabController,
                          children: [
                            _buildOverallMemoTab(),
                            _buildPageMemosTab(),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            );
          } else {
            // 縦長画面: 従来のレイアウト
            return Column(
              children: [
                _buildHeader(),
                TabBar(
                  controller: _tabController,
                  tabs: const [
                    Tab(text: '全体メモ'),
                    Tab(text: 'ページメモ'),
                  ],
                ),
                Expanded(
                  child: TabBarView(
                    controller: _tabController,
                    children: [_buildOverallMemoTab(), _buildPageMemosTab()],
                  ),
                ),
              ],
            );
          }
        },
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(16),
      color: Theme.of(
        context,
      ).colorScheme.primaryContainer.withValues(alpha: 0.3),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ステータス
          Chip(
            label: Text(
              '${_currentBook.status.emoji} ${_currentBook.status.displayName}',
            ),
          ),
          const SizedBox(height: 8),

          // タイトル
          Text(
            _currentBook.title,
            style: Theme.of(
              context,
            ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 4),

          // 著者
          Text(
            _currentBook.author,
            style: Theme.of(
              context,
            ).textTheme.titleMedium?.copyWith(color: Colors.grey[700]),
          ),

          // 出版社
          if (_currentBook.publisher != null &&
              _currentBook.publisher!.isNotEmpty)
            Text(
              _currentBook.publisher!,
              style: TextStyle(color: Colors.grey[600]),
            ),

          const SizedBox(height: 12),

          // 評価
          if (_currentBook.rating > 0)
            Row(
              children: [
                RatingBarIndicator(
                  rating: _currentBook.rating,
                  itemBuilder: (context, index) =>
                      const Icon(Icons.star, color: Colors.amber),
                  itemCount: 5,
                  itemSize: 24,
                ),
                const SizedBox(width: 8),
                Text(
                  _currentBook.rating.toStringAsFixed(1),
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),

          // URL
          if (_currentBook.purchaseUrl != null &&
              _currentBook.purchaseUrl!.isNotEmpty) ...[
            const SizedBox(height: 8),
            TextButton.icon(
              onPressed: () => _launchUrl(_currentBook.purchaseUrl!),
              icon: const Icon(Icons.link),
              label: const Text('購入先を開く'),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildOverallMemoTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // おすすめポイント
          if (_currentBook.recommendation != null &&
              _currentBook.recommendation!.isNotEmpty) ...[
            const Text(
              'おすすめポイント',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.amber.shade50,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.amber.shade200),
              ),
              child: Text(_currentBook.recommendation!),
            ),
            const SizedBox(height: 24),
          ],

          // 全体メモ
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                '全体メモ・感想',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              TextButton.icon(
                onPressed: _editOverallMemo,
                icon: const Icon(Icons.edit, size: 18),
                label: const Text('編集'),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey.shade300),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              _currentBook.overallMemo?.isEmpty ?? true
                  ? '全体的な感想をここに記入できます'
                  : _currentBook.overallMemo!,
              style: TextStyle(
                color: _currentBook.overallMemo?.isEmpty ?? true
                    ? Colors.grey
                    : null,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPageMemosTab() {
    return Consumer<MemoProvider>(
      builder: (context, memoProvider, child) {
        if (memoProvider.isLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        final memos = memoProvider.memos;

        if (memos.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.note_outlined, size: 64, color: Colors.grey[400]),
                const SizedBox(height: 16),
                Text(
                  'ページメモがまだありません',
                  style: TextStyle(color: Colors.grey[600]),
                ),
                const SizedBox(height: 8),
                ElevatedButton.icon(
                  onPressed: _addPageMemo,
                  icon: const Icon(Icons.add),
                  label: const Text('メモを追加'),
                ),
              ],
            ),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.all(8),
          itemCount: memos.length,
          itemBuilder: (context, index) {
            final memo = memos[index];
            return _buildMemoCard(memo);
          },
        );
      },
    );
  }

  Widget _buildMemoCard(PageMemo memo) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ヘッダー（タイプ、ページ番号）
            Row(
              children: [
                Chip(
                  label: Text('${memo.type.emoji} ${memo.type.displayName}'),
                  visualDensity: VisualDensity.compact,
                ),
                if (memo.pageNumber != null) ...[
                  const SizedBox(width: 8),
                  Chip(
                    label: Text(memo.pageDisplay),
                    visualDensity: VisualDensity.compact,
                  ),
                ],
                const Spacer(),
                IconButton(
                  icon: const Icon(Icons.share, size: 20),
                  onPressed: () => _shareMemo(memo),
                  tooltip: '共有',
                ),
                IconButton(
                  icon: const Icon(Icons.delete, size: 20),
                  onPressed: () => _deleteMemo(memo),
                  tooltip: '削除',
                ),
              ],
            ),

            // 章名
            if (memo.chapterName != null && memo.chapterName!.isNotEmpty) ...[
              const SizedBox(height: 4),
              Text(
                '【${memo.chapterName}】',
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
            ],

            // 引用文
            if (memo.quote != null && memo.quote!.isNotEmpty) ...[
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(4),
                  border: Border.all(color: Colors.grey.shade300),
                ),
                child: Text(
                  '「${memo.quote}」',
                  style: const TextStyle(fontStyle: FontStyle.italic),
                ),
              ),
            ],

            // メモ
            const SizedBox(height: 8),
            Text(memo.memo),

            // 日時
            const SizedBox(height: 8),
            Text(
              memo.formattedCreatedDate,
              style: TextStyle(fontSize: 12, color: Colors.grey[600]),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _editBook() async {
    final result = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (context) => AddBookScreen(book: _currentBook),
      ),
    );

    if (result == true && mounted) {
      // 更新後のデータを取得
      final bookProvider = Provider.of<BookProvider>(context, listen: false);
      final updatedBook = await bookProvider.getBook(_currentBook.id);
      if (updatedBook != null) {
        setState(() {
          _currentBook = updatedBook;
        });
      }
    }
  }

  Future<void> _editOverallMemo() async {
    final controller = TextEditingController(text: _currentBook.overallMemo);
    final result = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('全体メモを編集'),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(
            hintText: '全体的な感想を入力',
            border: OutlineInputBorder(),
          ),
          maxLines: 5,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('キャンセル'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, controller.text),
            child: const Text('保存'),
          ),
        ],
      ),
    );

    if (result != null && mounted) {
      final updatedBook = _currentBook.copyWith(overallMemo: result);
      final bookProvider = Provider.of<BookProvider>(context, listen: false);
      await bookProvider.updateBook(updatedBook);
      setState(() {
        _currentBook = updatedBook;
      });
    }
  }

  Future<void> _addPageMemo() async {
    final result = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (context) => AddMemoScreen(bookId: _currentBook.id),
      ),
    );

    if (result == true && mounted) {
      // メモ一覧を再読み込み
      Provider.of<MemoProvider>(
        context,
        listen: false,
      ).loadMemosByBookId(_currentBook.id);
    }
  }

  Future<void> _deleteBook() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('削除確認'),
        content: Text('「${_currentBook.title}」を削除しますか？\nこの操作は取り消せません。'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('キャンセル'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            style: FilledButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('削除'),
          ),
        ],
      ),
    );

    if (confirmed == true && mounted) {
      final bookProvider = Provider.of<BookProvider>(context, listen: false);
      await bookProvider.deleteBook(_currentBook.id);
      if (mounted) {
        Navigator.pop(context, true);
      }
    }
  }

  Future<void> _deleteMemo(PageMemo memo) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('メモを削除'),
        content: const Text('このメモを削除しますか？'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('キャンセル'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            style: FilledButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('削除'),
          ),
        ],
      ),
    );

    if (confirmed == true && mounted) {
      final memoProvider = Provider.of<MemoProvider>(context, listen: false);
      await memoProvider.deleteMemo(memo.id);
    }
  }

  void _shareBook() {
    final text = StringBuffer();
    text.writeln('📚 ${_currentBook.title}');
    text.writeln('著者: ${_currentBook.author}');
    if (_currentBook.rating > 0) {
      text.writeln('評価: ${'⭐' * _currentBook.rating.round()}');
    }
    if (_currentBook.recommendation != null &&
        _currentBook.recommendation!.isNotEmpty) {
      text.writeln('\n${_currentBook.recommendation}');
    }
    if (_currentBook.purchaseUrl != null &&
        _currentBook.purchaseUrl!.isNotEmpty) {
      text.writeln('\n購入先: ${_currentBook.purchaseUrl}');
    }

    // SNS共有ダイアログを表示
    showDialog(
      context: context,
      builder: (context) =>
          SnsShareDialog(text: text.toString(), url: _currentBook.purchaseUrl),
    );
  }

  void _shareMemo(PageMemo memo) {
    final text = memo.generateShareText(_currentBook.title);

    // SNS共有ダイアログを表示
    showDialog(
      context: context,
      builder: (context) =>
          SnsShareDialog(text: text, url: _currentBook.purchaseUrl),
    );
  }

  Future<void> _launchUrl(String urlString) async {
    final url = Uri.parse(urlString);
    if (await canLaunchUrl(url)) {
      await launchUrl(url, mode: LaunchMode.externalApplication);
    }
  }
}
