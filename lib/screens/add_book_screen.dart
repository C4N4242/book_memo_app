import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';
import '../models/book.dart';
import '../providers/book_provider.dart';
import '../widgets/book_image_picker.dart';

/// 書籍追加・編集画面
class AddBookScreen extends StatefulWidget {
  final Book? book; // 編集の場合は既存の書籍を渡す

  const AddBookScreen({super.key, this.book});

  @override
  State<AddBookScreen> createState() => _AddBookScreenState();
}

class _AddBookScreenState extends State<AddBookScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _authorController = TextEditingController();
  final _publisherController = TextEditingController();
  final _urlController = TextEditingController();
  final _recommendationController = TextEditingController();

  BookStatus _status = BookStatus.wishlist;
  double _rating = 0.0;
  bool _isLoading = false;
  String? _coverImageUrl; // Google Booksからの画像URL
  String? _localImagePath; // ユーザーが選択したローカル画像

  bool get isEditing => widget.book != null;

  @override
  void initState() {
    super.initState();
    // 編集モードの場合は既存データをセット
    if (isEditing) {
      final book = widget.book!;
      _titleController.text = book.title;
      _authorController.text = book.author;
      _publisherController.text = book.publisher ?? '';
      _urlController.text = book.purchaseUrl ?? '';
      _recommendationController.text = book.recommendation ?? '';
      _status = book.status;
      _rating = book.rating;
      _coverImageUrl = book.coverImageUrl;
      _localImagePath = book.localImagePath;
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _authorController.dispose();
    _publisherController.dispose();
    _urlController.dispose();
    _recommendationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(isEditing ? '書籍を編集' : '新しい本を追加')),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : LayoutBuilder(
              builder: (context, constraints) {
                final isWideScreen = constraints.maxWidth > 600;

                return Form(
                  key: _formKey,
                  child: Center(
                    child: ConstrainedBox(
                      constraints: BoxConstraints(
                        maxWidth: isWideScreen ? 800 : double.infinity,
                      ),
                      child: ListView(
                        padding: const EdgeInsets.all(16),
                        children: [
                          // タイトル
                          TextFormField(
                            controller: _titleController,
                            decoration: const InputDecoration(
                              labelText: '書籍名 *',
                              hintText: '例: プログラミング入門',
                              border: OutlineInputBorder(),
                              prefixIcon: Icon(Icons.book),
                            ),
                            validator: (value) {
                              if (value == null || value.trim().isEmpty) {
                                return '書籍名を入力してください';
                              }
                              return null;
                            },
                            textInputAction: TextInputAction.next,
                          ),
                          const SizedBox(height: 16),

                          // 著者名
                          TextFormField(
                            controller: _authorController,
                            decoration: const InputDecoration(
                              labelText: '著者名 *',
                              hintText: '例: 山田太郎',
                              border: OutlineInputBorder(),
                              prefixIcon: Icon(Icons.person),
                            ),
                            validator: (value) {
                              if (value == null || value.trim().isEmpty) {
                                return '著者名を入力してください';
                              }
                              return null;
                            },
                            textInputAction: TextInputAction.next,
                          ),
                          const SizedBox(height: 16),

                          // 出版社
                          TextFormField(
                            controller: _publisherController,
                            decoration: const InputDecoration(
                              labelText: '出版社',
                              hintText: '例: 技術評論社',
                              border: OutlineInputBorder(),
                              prefixIcon: Icon(Icons.business),
                            ),
                            textInputAction: TextInputAction.next,
                          ),
                          const SizedBox(height: 16),

                          // 購入先URL
                          TextFormField(
                            controller: _urlController,
                            decoration: const InputDecoration(
                              labelText: '購入先URL',
                              hintText: 'https://www.amazon.co.jp/...',
                              border: OutlineInputBorder(),
                              prefixIcon: Icon(Icons.link),
                            ),
                            keyboardType: TextInputType.url,
                            textInputAction: TextInputAction.next,
                          ),
                          const SizedBox(height: 24),

                          // 書籍カバー画像
                          const Text(
                            '書籍カバー画像',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 8),
                          _buildImageSection(),
                          const SizedBox(height: 24),

                          // ステータス選択
                          const Text(
                            'ステータス',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 8),
                          SegmentedButton<BookStatus>(
                            segments: BookStatus.values.map((status) {
                              return ButtonSegment<BookStatus>(
                                value: status,
                                label: Text(
                                  '${status.emoji} ${status.displayName}',
                                ),
                              );
                            }).toList(),
                            selected: {_status},
                            onSelectionChanged: (Set<BookStatus> newSelection) {
                              setState(() {
                                _status = newSelection.first;
                              });
                            },
                          ),
                          const SizedBox(height: 24),

                          // 評価
                          const Text(
                            '評価',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              RatingBar.builder(
                                initialRating: _rating,
                                minRating: 0,
                                direction: Axis.horizontal,
                                allowHalfRating: true,
                                itemCount: 5,
                                itemPadding: const EdgeInsets.symmetric(
                                  horizontal: 4,
                                ),
                                itemBuilder: (context, _) =>
                                    const Icon(Icons.star, color: Colors.amber),
                                onRatingUpdate: (rating) {
                                  setState(() {
                                    _rating = rating;
                                  });
                                },
                              ),
                              const SizedBox(width: 8),
                              Text(
                                _rating.toStringAsFixed(1),
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 24),

                          // おすすめポイント
                          TextFormField(
                            controller: _recommendationController,
                            decoration: const InputDecoration(
                              labelText: 'おすすめポイント・気になる理由',
                              hintText: 'この本のどこが魅力的ですか？',
                              border: OutlineInputBorder(),
                              prefixIcon: Icon(Icons.recommend),
                            ),
                            maxLines: 3,
                            textInputAction: TextInputAction.done,
                          ),
                          const SizedBox(height: 32),

                          // 保存ボタン
                          FilledButton.icon(
                            onPressed: _saveBook,
                            icon: const Icon(Icons.save),
                            label: Text(isEditing ? '更新する' : '追加する'),
                            style: FilledButton.styleFrom(
                              padding: const EdgeInsets.all(16),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
    );
  }

  /// 画像選択セクション
  Widget _buildImageSection() {
    final hasImage = _localImagePath != null || _coverImageUrl != null;

    return Column(
      children: [
        if (hasImage) ...[
          // 選択された画像のプレビュー
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: SizedBox(
              width: 120,
              height: 180,
              child: _localImagePath != null
                  ? Image.file(File(_localImagePath!), fit: BoxFit.cover)
                  : Image.network(
                      _coverImageUrl!,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          color: Colors.grey[300],
                          child: const Icon(Icons.error),
                        );
                      },
                    ),
            ),
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              TextButton.icon(
                onPressed: _showImagePicker,
                icon: const Icon(Icons.edit),
                label: const Text('変更'),
              ),
              TextButton.icon(
                onPressed: () {
                  setState(() {
                    _coverImageUrl = null;
                    _localImagePath = null;
                  });
                },
                icon: const Icon(Icons.delete, color: Colors.red),
                label: const Text('削除', style: TextStyle(color: Colors.red)),
              ),
            ],
          ),
        ] else ...[
          // 画像未選択の場合
          OutlinedButton.icon(
            onPressed: _showImagePicker,
            icon: const Icon(Icons.add_photo_alternate),
            label: const Text('書籍画像を追加'),
            style: OutlinedButton.styleFrom(padding: const EdgeInsets.all(16)),
          ),
        ],
      ],
    );
  }

  /// 画像選択ダイアログを表示
  void _showImagePicker() {
    // タイトルと著者名が入力されていない場合は警告
    if (_titleController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('先に書籍名を入力してください'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    showDialog<void>(
      context: context,
      builder: (context) => BookImagePicker(
        bookTitle: _titleController.text.trim(),
        bookAuthor: _authorController.text.trim(),
        onImageSelected: (imageUrl, localPath) {
          setState(() {
            _coverImageUrl = imageUrl;
            _localImagePath = localPath;
          });
        },
      ),
    );
  }

  Future<void> _saveBook() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final book = Book(
        id: isEditing ? widget.book!.id : const Uuid().v4(),
        title: _titleController.text.trim(),
        author: _authorController.text.trim(),
        publisher: _publisherController.text.trim().isEmpty
            ? null
            : _publisherController.text.trim(),
        purchaseUrl: _urlController.text.trim().isEmpty
            ? null
            : _urlController.text.trim(),
        coverImageUrl: _coverImageUrl,
        localImagePath: _localImagePath,
        recommendation: _recommendationController.text.trim().isEmpty
            ? null
            : _recommendationController.text.trim(),
        rating: _rating,
        status: _status,
        createdAt: isEditing ? widget.book!.createdAt : DateTime.now(),
        completedAt: _status == BookStatus.completed ? DateTime.now() : null,
      );

      final bookProvider = Provider.of<BookProvider>(context, listen: false);

      if (isEditing) {
        await bookProvider.updateBook(book);
      } else {
        await bookProvider.addBook(book);
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(isEditing ? '書籍を更新しました' : '書籍を追加しました'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pop(context, true);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('エラーが発生しました: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }
}
