import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../models/book.dart';

/// 書籍カードウィジェット
class BookCard extends StatelessWidget {
  final Book book;
  final VoidCallback? onTap;
  final bool isGridLayout; // グリッドレイアウトかどうか

  const BookCard({
    super.key,
    required this.book,
    this.onTap,
    this.isGridLayout = false,
  });

  @override
  Widget build(BuildContext context) {
    if (isGridLayout) {
      return _buildGridCard(context);
    } else {
      return _buildListCard(context);
    }
  }

  /// グリッド用カード (縦並び)
  Widget _buildGridCard(BuildContext context) {
    return Card(
      elevation: 2,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 書籍カバー画像 (中央配置)
              if (book.hasImage) ...[
                Center(child: _buildCoverImage(size: const Size(100, 150))),
                const SizedBox(height: 12),
              ],

              // ステータスチップ
              _buildStatusChip(context),
              const SizedBox(height: 8),

              // タイトル (最大2行)
              Text(
                book.title,
                style: Theme.of(
                  context,
                ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 4),

              // 著者名
              Text(
                book.author,
                style: Theme.of(
                  context,
                ).textTheme.bodySmall?.copyWith(color: Colors.grey[600]),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),

              const Spacer(),

              // 評価
              if (book.rating > 0) ...[
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    RatingBarIndicator(
                      rating: book.rating,
                      itemBuilder: (context, index) =>
                          const Icon(Icons.star, color: Colors.amber),
                      itemCount: 5,
                      itemSize: 16,
                    ),
                  ],
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  /// リスト用カード (横並び)
  Widget _buildListCard(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      elevation: 2,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 書籍カバー画像
              if (book.hasImage) ...[
                _buildCoverImage(),
                const SizedBox(width: 16),
              ],

              // 書籍情報
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // ステータスバッジと評価
                    Row(
                      children: [
                        _buildStatusChip(context),
                        const Spacer(),
                        if (book.rating > 0)
                          Row(
                            children: [
                              RatingBarIndicator(
                                rating: book.rating,
                                itemBuilder: (context, index) =>
                                    const Icon(Icons.star, color: Colors.amber),
                                itemCount: 5,
                                itemSize: 20,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                book.rating.toStringAsFixed(1),
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                      ],
                    ),
                    const SizedBox(height: 12),

                    // タイトル
                    Text(
                      book.title,
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),

                    // 著者名
                    Text(
                      book.author,
                      style: Theme.of(
                        context,
                      ).textTheme.bodyMedium?.copyWith(color: Colors.grey[600]),
                    ),

                    // 出版社（あれば）
                    if (book.publisher != null &&
                        book.publisher!.isNotEmpty) ...[
                      const SizedBox(height: 2),
                      Text(
                        book.publisher!,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Colors.grey[500],
                        ),
                      ),
                    ],

                    const SizedBox(height: 12),

                    // おすすめポイント（あれば）
                    if (book.recommendation != null &&
                        book.recommendation!.isNotEmpty) ...[
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.amber.shade50,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: Colors.amber.shade200),
                        ),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Icon(
                              Icons.recommend,
                              size: 16,
                              color: Colors.amber,
                            ),
                            const SizedBox(width: 4),
                            Expanded(
                              child: Text(
                                book.recommendation!,
                                style: const TextStyle(fontSize: 12),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 8),
                    ],

                    // 日付情報
                    Row(
                      children: [
                        Icon(
                          Icons.calendar_today,
                          size: 14,
                          color: Colors.grey[600],
                        ),
                        const SizedBox(width: 4),
                        Text(
                          book.status == BookStatus.completed &&
                                  book.completedAt != null
                              ? '読了: ${book.formattedCompletedDate}'
                              : '登録: ${book.formattedCreatedDate}',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[600],
                          ),
                        ),
                        if (book.purchaseUrl != null &&
                            book.purchaseUrl!.isNotEmpty) ...[
                          const Spacer(),
                          IconButton(
                            icon: const Icon(Icons.link, size: 20),
                            onPressed: () => _launchUrl(book.purchaseUrl!),
                            tooltip: '購入先を開く',
                            padding: EdgeInsets.zero,
                            constraints: const BoxConstraints(),
                          ),
                        ],
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// カバー画像ウィジェット
  Widget _buildCoverImage({Size size = const Size(80, 120)}) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(8),
      child: SizedBox(
        width: size.width,
        height: size.height,
        child: book.localImagePath != null
            ? Image.file(
                File(book.localImagePath!),
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return _buildPlaceholder();
                },
              )
            : book.coverImageUrl != null
            ? CachedNetworkImage(
                imageUrl: book.coverImageUrl!,
                fit: BoxFit.cover,
                placeholder: (context, url) => Container(
                  color: Colors.grey[200],
                  child: const Center(
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
                ),
                errorWidget: (context, url, error) => _buildPlaceholder(),
              )
            : _buildPlaceholder(),
      ),
    );
  }

  /// プレースホルダー画像
  Widget _buildPlaceholder() {
    return Container(
      color: Colors.grey[300],
      child: Icon(Icons.book, size: 40, color: Colors.grey[500]),
    );
  }

  Widget _buildStatusChip(BuildContext context) {
    Color color;
    switch (book.status) {
      case BookStatus.reading:
        color = Theme.of(context).colorScheme.primary;
        break;
      case BookStatus.completed:
        color = Colors.orange;
        break;
      case BookStatus.wishlist:
        color = Colors.pink;
        break;
    }

    return Chip(
      label: Text(
        '${book.status.emoji} ${book.status.displayName}',
        style: const TextStyle(fontSize: 12),
      ),
      backgroundColor: color.withValues(alpha: 0.1),
      side: BorderSide(color: color.withValues(alpha: 0.5)),
      padding: const EdgeInsets.symmetric(horizontal: 4),
      visualDensity: VisualDensity.compact,
    );
  }

  Future<void> _launchUrl(String urlString) async {
    final url = Uri.parse(urlString);
    if (await canLaunchUrl(url)) {
      await launchUrl(url, mode: LaunchMode.externalApplication);
    }
  }
}
