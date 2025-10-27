import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:share_plus/share_plus.dart';

/// SNS共有ダイアログ
class SnsShareDialog extends StatelessWidget {
  final String text;
  final String? url;

  const SnsShareDialog({super.key, required this.text, this.url});

  @override
  Widget build(BuildContext context) {
    // URLエンコード用のテキスト
    final encodedText = Uri.encodeComponent(text);
    final encodedUrl = url != null ? Uri.encodeComponent(url!) : '';

    return Dialog(
      child: Container(
        constraints: const BoxConstraints(maxWidth: 500, maxHeight: 600),
        child: Column(
          mainAxisSize: MainAxisSize.min,
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
                  Icon(
                    Icons.share,
                    color: Theme.of(context).colorScheme.onPrimaryContainer,
                  ),
                  const SizedBox(width: 12),
                  Text(
                    '共有する',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      color: Theme.of(context).colorScheme.onPrimaryContainer,
                    ),
                  ),
                  const Spacer(),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.pop(context),
                    color: Theme.of(context).colorScheme.onPrimaryContainer,
                  ),
                ],
              ),
            ),

            // 共有テキストプレビュー
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const Text(
                      '共有内容',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade100,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.grey.shade300),
                      ),
                      child: SelectableText(
                        text,
                        style: const TextStyle(fontSize: 14),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        TextButton.icon(
                          onPressed: () => _copyToClipboard(context, text),
                          icon: const Icon(Icons.copy, size: 18),
                          label: const Text('コピー'),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),

                    // SNSボタン一覧
                    const Text(
                      'SNSに投稿',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 12),

                    // X (Twitter)
                    _SnsButton(
                      icon: Icons.close, // Xのアイコン代用
                      label: 'X (Twitter)',
                      color: Colors.black,
                      onPressed: () =>
                          _shareToX(context, encodedText, encodedUrl),
                    ),
                    const SizedBox(height: 8),

                    // Facebook
                    _SnsButton(
                      icon: Icons.facebook,
                      label: 'Facebook',
                      color: const Color(0xFF1877F2),
                      onPressed: () => _shareToFacebook(context, encodedUrl),
                    ),
                    const SizedBox(height: 8),

                    // LINE
                    _SnsButton(
                      icon: Icons.chat_bubble,
                      label: 'LINE',
                      color: const Color(0xFF06C755),
                      onPressed: () => _shareToLine(context, encodedText),
                    ),
                    const SizedBox(height: 8),

                    // Bluesky
                    _SnsButton(
                      icon: Icons.cloud,
                      label: 'Bluesky',
                      color: const Color(0xFF1185FE),
                      onPressed: () =>
                          _shareToBluesky(context, encodedText, encodedUrl),
                    ),
                    const SizedBox(height: 8),

                    // その他（システムの共有シート）
                    _SnsButton(
                      icon: Icons.more_horiz,
                      label: 'その他',
                      color: Colors.grey.shade600,
                      onPressed: () => _shareToOthers(context, text),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // X (Twitter) へ共有
  Future<void> _shareToX(
    BuildContext context,
    String encodedText,
    String encodedUrl,
  ) async {
    final shareUrl = url != null && url!.isNotEmpty
        ? 'https://twitter.com/intent/tweet?text=$encodedText&url=$encodedUrl'
        : 'https://twitter.com/intent/tweet?text=$encodedText';

    await _launchSnsUrl(context, shareUrl, 'X (Twitter)');
  }

  // Facebook へ共有
  Future<void> _shareToFacebook(BuildContext context, String encodedUrl) async {
    if (url == null || url!.isEmpty) {
      _showSnackBar(context, 'FacebookへはURLが必要です');
      return;
    }
    final shareUrl = 'https://www.facebook.com/sharer/sharer.php?u=$encodedUrl';
    await _launchSnsUrl(context, shareUrl, 'Facebook');
  }

  // LINE へ共有
  Future<void> _shareToLine(BuildContext context, String encodedText) async {
    final shareUrl = 'https://line.me/R/share?text=$encodedText';
    await _launchSnsUrl(context, shareUrl, 'LINE');
  }

  // Bluesky へ共有
  Future<void> _shareToBluesky(
    BuildContext context,
    String encodedText,
    String encodedUrl,
  ) async {
    final shareUrl = url != null && url!.isNotEmpty
        ? 'https://bsky.app/intent/compose?text=$encodedText%20$encodedUrl'
        : 'https://bsky.app/intent/compose?text=$encodedText';

    await _launchSnsUrl(context, shareUrl, 'Bluesky');
  }

  // その他（システムの共有シート）
  Future<void> _shareToOthers(BuildContext context, String text) async {
    try {
      await Share.share(text);
      if (context.mounted) {
        Navigator.pop(context);
      }
    } catch (e) {
      if (context.mounted) {
        _showSnackBar(context, '共有に失敗しました: $e');
      }
    }
  }

  // SNS URLを起動
  Future<void> _launchSnsUrl(
    BuildContext context,
    String urlString,
    String snsName,
  ) async {
    try {
      final uri = Uri.parse(urlString);
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
        if (context.mounted) {
          Navigator.pop(context);
        }
      } else {
        if (context.mounted) {
          _showSnackBar(context, '$snsNameを開けませんでした');
        }
      }
    } catch (e) {
      if (context.mounted) {
        _showSnackBar(context, '$snsNameの起動に失敗しました: $e');
      }
    }
  }

  // クリップボードにコピー
  Future<void> _copyToClipboard(BuildContext context, String text) async {
    await Clipboard.setData(ClipboardData(text: text));
    if (context.mounted) {
      _showSnackBar(context, 'クリップボードにコピーしました');
    }
  }

  // スナックバー表示
  void _showSnackBar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 2),
      ),
    );
  }
}

/// SNS共有ボタン
class _SnsButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onPressed;

  const _SnsButton({
    required this.icon,
    required this.label,
    required this.color,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return FilledButton.tonal(
      onPressed: onPressed,
      style: FilledButton.styleFrom(
        backgroundColor: color.withValues(alpha: 0.1),
        foregroundColor: color,
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
        alignment: Alignment.centerLeft,
      ),
      child: Row(
        children: [
          Icon(icon, size: 24),
          const SizedBox(width: 16),
          Text(
            label,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
          ),
          const Spacer(),
          const Icon(Icons.open_in_new, size: 18),
        ],
      ),
    );
  }
}
