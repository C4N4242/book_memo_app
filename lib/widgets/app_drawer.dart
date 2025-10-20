import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/book.dart';
import '../providers/book_provider.dart';
import '../providers/theme_provider.dart';
import '../screens/settings_screen.dart';

/// 共通のDrawerメニューウィジェット
class AppDrawer extends StatelessWidget {
  const AppDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    final bookProvider = Provider.of<BookProvider>(context);
    final statusCounts = bookProvider.statusCounts;

    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          // ヘッダー
          DrawerHeader(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Theme.of(context).colorScheme.primary,
                  Theme.of(context).colorScheme.secondary,
                ],
              ),
            ),
            child: const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Icon(Icons.menu_book, size: 48, color: Colors.white),
                SizedBox(height: 8),
                Text(
                  '読書メモアプリ',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  'version 0.1.0',
                  style: TextStyle(color: Colors.white70, fontSize: 12),
                ),
              ],
            ),
          ),

          // My本棚セクション
          const Padding(
            padding: EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: Text(
              '📚 My本棚',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
          ),

          // すべての本
          ListTile(
            leading: const Icon(Icons.library_books),
            title: const Text('すべての本'),
            onTap: () {
              Navigator.pop(context);
              Navigator.pushReplacementNamed(context, '/');
              bookProvider.loadBooks();
            },
          ),

          // 読書中
          ListTile(
            leading: Icon(
              Icons.book,
              color: Theme.of(context).colorScheme.primary,
            ),
            title: Text(
              '${BookStatus.reading.emoji} ${BookStatus.reading.displayName}',
            ),
            trailing: Chip(
              label: Text('${statusCounts[BookStatus.reading] ?? 0}'),
              backgroundColor: Theme.of(context).colorScheme.primaryContainer,
            ),
            onTap: () {
              Navigator.pop(context);
              Navigator.pushReplacementNamed(
                context,
                '/books-by-status',
                arguments: BookStatus.reading,
              );
            },
          ),

          // 読了
          ListTile(
            leading: const Icon(Icons.star, color: Colors.orange),
            title: Text(
              '${BookStatus.completed.emoji} ${BookStatus.completed.displayName}',
            ),
            trailing: Chip(
              label: Text('${statusCounts[BookStatus.completed] ?? 0}'),
              backgroundColor: Colors.orange.shade100,
            ),
            onTap: () {
              Navigator.pop(context);
              Navigator.pushReplacementNamed(
                context,
                '/books-by-status',
                arguments: BookStatus.completed,
              );
            },
          ),

          // 気になる
          ListTile(
            leading: const Icon(Icons.favorite, color: Colors.pink),
            title: Text(
              '${BookStatus.wishlist.emoji} ${BookStatus.wishlist.displayName}',
            ),
            trailing: Chip(
              label: Text('${statusCounts[BookStatus.wishlist] ?? 0}'),
              backgroundColor: Colors.pink.shade100,
            ),
            onTap: () {
              Navigator.pop(context);
              Navigator.pushReplacementNamed(
                context,
                '/books-by-status',
                arguments: BookStatus.wishlist,
              );
            },
          ),

          const Divider(),

          // テーマ切り替え
          Consumer<ThemeProvider>(
            builder: (context, themeProvider, _) {
              return ListTile(
                leading: Icon(themeProvider.themeModeIcon),
                title: const Text('テーマ'),
                subtitle: Text(themeProvider.themeModeString),
                onTap: () async {
                  await themeProvider.toggleThemeMode();
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          'テーマを${themeProvider.themeModeString}に変更しました',
                        ),
                        duration: const Duration(seconds: 1),
                      ),
                    );
                  }
                },
              );
            },
          ),

          const Divider(),

          // その他の機能
          ListTile(
            leading: const Icon(Icons.search),
            title: const Text('検索'),
            onTap: () {
              Navigator.pop(context);
              Navigator.pushNamed(context, '/search');
            },
          ),

          const Divider(),

          // 設定
          ListTile(
            leading: const Icon(Icons.settings),
            title: const Text('設定'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const SettingsScreen()),
              );
            },
          ),

          // このアプリについて
          ListTile(
            leading: const Icon(Icons.info),
            title: const Text('このアプリについて'),
            onTap: () {
              Navigator.pop(context);
              _showAboutDialog(context);
            },
          ),
        ],
      ),
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
      ],
    );
  }
}
