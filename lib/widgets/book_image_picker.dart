import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../services/google_books_service.dart';
import '../services/image_helper.dart';

/// 書籍画像選択ダイアログ
class BookImagePicker extends StatefulWidget {
  final String bookTitle;
  final String bookAuthor;
  final Function(String? imageUrl, String? localPath) onImageSelected;

  const BookImagePicker({
    super.key,
    required this.bookTitle,
    required this.bookAuthor,
    required this.onImageSelected,
  });

  @override
  State<BookImagePicker> createState() => _BookImagePickerState();
}

class _BookImagePickerState extends State<BookImagePicker> {
  final GoogleBooksService _booksService = GoogleBooksService();
  final ImageHelper _imageHelper = ImageHelper();

  List<BookSearchResult>? _searchResults;
  bool _isSearching = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _searchBooks();
  }

  Future<void> _searchBooks() async {
    if (widget.bookTitle.isEmpty) {
      return;
    }

    setState(() {
      _isSearching = true;
      _error = null;
    });

    try {
      final results = await _booksService.searchByTitleAndAuthor(
        widget.bookTitle,
        widget.bookAuthor,
        maxResults: 10,
      );

      setState(() {
        _searchResults = results;
        _isSearching = false;
      });
    } catch (e) {
      setState(() {
        _error = 'エラーが発生しました: $e';
        _isSearching = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: Container(
        constraints: const BoxConstraints(maxWidth: 500, maxHeight: 600),
        child: Column(
          children: [
            // ヘッダー
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primaryContainer,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(28),
                  topRight: Radius.circular(28),
                ),
              ),
              child: Row(
                children: [
                  const Icon(Icons.image),
                  const SizedBox(width: 8),
                  const Text(
                    '書籍画像を選択',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const Spacer(),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
            ),

            // カメラ/ギャラリー選択ボタン
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () async {
                        final path = await _imageHelper.pickFromCamera();
                        if (path != null && context.mounted) {
                          widget.onImageSelected(null, path);
                          Navigator.pop(context);
                        }
                      },
                      icon: const Icon(Icons.camera_alt),
                      label: const Text('カメラ'),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () async {
                        final path = await _imageHelper.pickFromGallery();
                        if (path != null && context.mounted) {
                          widget.onImageSelected(null, path);
                          Navigator.pop(context);
                        }
                      },
                      icon: const Icon(Icons.photo_library),
                      label: const Text('ギャラリー'),
                    ),
                  ),
                ],
              ),
            ),

            const Divider(),

            // Google Books検索結果
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Row(
                children: [
                  const Text(
                    'Google Booksから選択',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const Spacer(),
                  if (_isSearching)
                    const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    ),
                ],
              ),
            ),

            // 検索結果グリッド
            Expanded(child: _buildResultsGrid()),
          ],
        ),
      ),
    );
  }

  Widget _buildResultsGrid() {
    if (_isSearching) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_error != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 48, color: Colors.red),
            const SizedBox(height: 8),
            Text(_error!),
            const SizedBox(height: 16),
            ElevatedButton(onPressed: _searchBooks, child: const Text('再試行')),
          ],
        ),
      );
    }

    if (_searchResults == null || _searchResults!.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.search_off, size: 48, color: Colors.grey),
            SizedBox(height: 8),
            Text('該当する書籍が見つかりませんでした'),
          ],
        ),
      );
    }

    return GridView.builder(
      padding: const EdgeInsets.all(16),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        childAspectRatio: 0.7,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
      ),
      itemCount: _searchResults!.length,
      itemBuilder: (context, index) {
        final result = _searchResults![index];
        return _buildBookCard(result);
      },
    );
  }

  Widget _buildBookCard(BookSearchResult result) {
    return InkWell(
      onTap: () {
        widget.onImageSelected(result.thumbnail, null);
        Navigator.pop(context);
      },
      borderRadius: BorderRadius.circular(8),
      child: Column(
        children: [
          // 書籍カバー
          Expanded(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: result.thumbnail != null
                  ? CachedNetworkImage(
                      imageUrl: result.thumbnail!,
                      fit: BoxFit.cover,
                      placeholder: (context, url) => Container(
                        color: Colors.grey[200],
                        child: const Center(
                          child: CircularProgressIndicator(strokeWidth: 2),
                        ),
                      ),
                      errorWidget: (context, url, error) => Container(
                        color: Colors.grey[300],
                        child: const Icon(Icons.book, size: 40),
                      ),
                    )
                  : Container(
                      color: Colors.grey[300],
                      child: const Icon(Icons.book, size: 40),
                    ),
            ),
          ),
          const SizedBox(height: 4),
          // タイトル
          Text(
            result.title,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 11),
          ),
        ],
      ),
    );
  }
}
