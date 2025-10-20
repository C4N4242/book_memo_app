import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';
import '../models/page_memo.dart';
import '../providers/memo_provider.dart';

/// ページメモ追加・編集画面
class AddMemoScreen extends StatefulWidget {
  final String bookId;
  final PageMemo? memo; // 編集の場合は既存のメモを渡す

  const AddMemoScreen({super.key, required this.bookId, this.memo});

  @override
  State<AddMemoScreen> createState() => _AddMemoScreenState();
}

class _AddMemoScreenState extends State<AddMemoScreen> {
  final _formKey = GlobalKey<FormState>();
  final _pageController = TextEditingController();
  final _chapterController = TextEditingController();
  final _quoteController = TextEditingController();
  final _memoController = TextEditingController();

  MemoType _type = MemoType.general;
  bool _isLoading = false;

  bool get isEditing => widget.memo != null;

  @override
  void initState() {
    super.initState();
    // 編集モードの場合は既存データをセット
    if (isEditing) {
      final memo = widget.memo!;
      if (memo.pageNumber != null) {
        _pageController.text = memo.pageNumber.toString();
      }
      _chapterController.text = memo.chapterName ?? '';
      _quoteController.text = memo.quote ?? '';
      _memoController.text = memo.memo;
      _type = memo.type;
    }
  }

  @override
  void dispose() {
    _pageController.dispose();
    _chapterController.dispose();
    _quoteController.dispose();
    _memoController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(isEditing ? 'メモを編集' : 'メモを追加')),
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
                          // メモの種類
                          const Text(
                            'メモの種類',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Wrap(
                            spacing: 8,
                            children: MemoType.values.map((type) {
                              return ChoiceChip(
                                label: Text(
                                  '${type.emoji} ${type.displayName}',
                                ),
                                selected: _type == type,
                                onSelected: (selected) {
                                  if (selected) {
                                    setState(() {
                                      _type = type;
                                    });
                                  }
                                },
                              );
                            }).toList(),
                          ),
                          const SizedBox(height: 24),

                          // ページ番号
                          Row(
                            children: [
                              Expanded(
                                child: TextFormField(
                                  controller: _pageController,
                                  decoration: const InputDecoration(
                                    labelText: 'ページ番号（任意）',
                                    hintText: '例: 25',
                                    border: OutlineInputBorder(),
                                    prefixIcon: Icon(Icons.book),
                                  ),
                                  keyboardType: TextInputType.number,
                                  inputFormatters: [
                                    FilteringTextInputFormatter.digitsOnly,
                                  ],
                                  textInputAction: TextInputAction.next,
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: TextFormField(
                                  controller: _chapterController,
                                  decoration: const InputDecoration(
                                    labelText: '章名（任意）',
                                    hintText: '例: 第2章',
                                    border: OutlineInputBorder(),
                                  ),
                                  textInputAction: TextInputAction.next,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),

                          // 引用文
                          TextFormField(
                            controller: _quoteController,
                            decoration: InputDecoration(
                              labelText: '引用文（任意）',
                              hintText: '印象的な一文を引用',
                              border: const OutlineInputBorder(),
                              prefixIcon: const Icon(Icons.format_quote),
                              helperText: _type == MemoType.quote
                                  ? '引用の場合は入力推奨'
                                  : null,
                            ),
                            maxLines: 3,
                            textInputAction: TextInputAction.next,
                          ),
                          const SizedBox(height: 16),

                          // メモ本文
                          TextFormField(
                            controller: _memoController,
                            decoration: const InputDecoration(
                              labelText: 'メモ・感想 *',
                              hintText: 'あなたの感想や気づきを記録',
                              border: OutlineInputBorder(),
                              prefixIcon: Icon(Icons.edit_note),
                            ),
                            maxLines: 8,
                            validator: (value) {
                              if (value == null || value.trim().isEmpty) {
                                return 'メモを入力してください';
                              }
                              return null;
                            },
                            textInputAction: TextInputAction.done,
                          ),
                          const SizedBox(height: 32),

                          // 保存ボタン
                          FilledButton.icon(
                            onPressed: _saveMemo,
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

  Future<void> _saveMemo() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final now = DateTime.now();
      final memo = PageMemo(
        id: isEditing ? widget.memo!.id : const Uuid().v4(),
        bookId: widget.bookId,
        pageNumber: _pageController.text.isEmpty
            ? null
            : int.tryParse(_pageController.text),
        chapterName: _chapterController.text.trim().isEmpty
            ? null
            : _chapterController.text.trim(),
        quote: _quoteController.text.trim().isEmpty
            ? null
            : _quoteController.text.trim(),
        memo: _memoController.text.trim(),
        type: _type,
        createdAt: isEditing ? widget.memo!.createdAt : now,
        updatedAt: now,
      );

      final memoProvider = Provider.of<MemoProvider>(context, listen: false);

      if (isEditing) {
        await memoProvider.updateMemo(memo);
      } else {
        await memoProvider.addMemo(memo);
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(isEditing ? 'メモを更新しました' : 'メモを追加しました'),
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
