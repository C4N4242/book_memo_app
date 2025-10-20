import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/theme_provider.dart';
import '../widgets/app_drawer.dart';

/// 設定画面
class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

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
      appBar: AppBar(title: const Text('設定')),
      drawer: const AppDrawer(),
      // Android 12+のジェスチャーナビゲーションとの競合を避ける
      drawerEnableOpenDragGesture: false,
      body: GestureDetector(
        onHorizontalDragEnd: _handleHorizontalDragEnd,
        child: ListView(
          children: [
            // 外観設定セクション
            const Padding(
              padding: EdgeInsets.fromLTRB(16, 16, 16, 8),
              child: Text(
                '外観',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey,
                ),
              ),
            ),

            // テーマ設定
            Consumer<ThemeProvider>(
              builder: (context, themeProvider, _) {
                return Column(
                  children: [
                    // ライトモード
                    ListTile(
                      leading: const Icon(Icons.light_mode),
                      title: const Text('ライトモード'),
                      subtitle: const Text('明るいテーマで表示'),
                      trailing: Radio<ThemeMode>(
                        value: ThemeMode.light,
                        groupValue: themeProvider.themeMode,
                        onChanged: (mode) {
                          if (mode != null) {
                            themeProvider.setThemeMode(mode);
                          }
                        },
                      ),
                      onTap: () => themeProvider.setThemeMode(ThemeMode.light),
                    ),

                    // ダークモード
                    ListTile(
                      leading: const Icon(Icons.dark_mode),
                      title: const Text('ダークモード'),
                      subtitle: const Text('暗いテーマで表示'),
                      trailing: Radio<ThemeMode>(
                        value: ThemeMode.dark,
                        groupValue: themeProvider.themeMode,
                        onChanged: (mode) {
                          if (mode != null) {
                            themeProvider.setThemeMode(mode);
                          }
                        },
                      ),
                      onTap: () => themeProvider.setThemeMode(ThemeMode.dark),
                    ),

                    // システム設定に従う
                    ListTile(
                      leading: const Icon(Icons.brightness_auto),
                      title: const Text('システム設定に従う'),
                      subtitle: const Text('デバイスの設定に合わせて自動切り替え'),
                      trailing: Radio<ThemeMode>(
                        value: ThemeMode.system,
                        groupValue: themeProvider.themeMode,
                        onChanged: (mode) {
                          if (mode != null) {
                            themeProvider.setThemeMode(mode);
                          }
                        },
                      ),
                      onTap: () => themeProvider.setThemeMode(ThemeMode.system),
                    ),

                    const Divider(),

                    // Material You情報
                    ListTile(
                      leading: const Icon(Icons.palette),
                      title: const Text('Material You'),
                      subtitle: const Text(
                        'Android 12以降では、壁紙の色に合わせたテーマ色を自動生成します',
                      ),
                      trailing: Icon(
                        Icons.info_outline,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                    ),
                  ],
                );
              },
            ),

            const Divider(),

            // アプリ情報セクション
            const Padding(
              padding: EdgeInsets.fromLTRB(16, 16, 16, 8),
              child: Text(
                'アプリ情報',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey,
                ),
              ),
            ),

            ListTile(
              leading: const Icon(Icons.info),
              title: const Text('バージョン'),
              subtitle: const Text('0.1.0'),
            ),

            ListTile(
              leading: const Icon(Icons.menu_book),
              title: const Text('このアプリについて'),
              trailing: const Icon(Icons.chevron_right),
              onTap: () => _showAboutDialog(context),
            ),

            const SizedBox(height: 32),

            // フッター
            Center(
              child: Column(
                children: [
                  Icon(
                    Icons.menu_book,
                    size: 48,
                    color: Theme.of(
                      context,
                    ).colorScheme.primary.withValues(alpha: 0.3),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '読書メモアプリ',
                    style: TextStyle(
                      color: Theme.of(
                        context,
                      ).colorScheme.onSurface.withValues(alpha: 0.5),
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),
          ],
        ), // ListViewを閉じる
      ), // GestureDetectorを閉じる
    );
  }

  void _showAboutDialog(BuildContext context) {
    showAboutDialog(
      context: context,
      applicationName: '読書メモアプリ',
      applicationVersion: '0.1.0',
      applicationIcon: const Icon(Icons.menu_book, size: 48),
      children: const [
        Text('読書の記録とメモを管理するアプリです。'),
        SizedBox(height: 8),
        Text('気になる本、読書中の本、読了した本を管理し、'),
        Text('ページごとのメモや感想を記録できます。'),
        SizedBox(height: 16),
        Text('Features:'),
        Text('• Material You対応 (Android 12+)'),
        Text('• ライト/ダークテーマ切り替え'),
        Text('• レスポンシブデザイン'),
        Text('• 書籍カバー画像表示'),
        Text('• ページ別メモ機能'),
      ],
    );
  }
}
