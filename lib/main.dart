import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:dynamic_color/dynamic_color.dart';
import 'package:google_fonts/google_fonts.dart';
import 'models/book.dart';
import 'providers/book_provider.dart';
import 'providers/memo_provider.dart';
import 'providers/theme_provider.dart';
import 'screens/home_screen.dart';
import 'screens/books_by_status_screen.dart';
import 'screens/search_screen.dart';

// デスクトップ用のインポート(Web以外のみ)
import 'database_init_stub.dart'
    if (dart.library.io) 'database_init.dart'
    if (dart.library.html) 'database_init_web.dart';

void main() {
  // プラットフォームに応じたデータベース初期化
  initializeDatabase();

  runApp(const BookMemoApp());
}

class BookMemoApp extends StatelessWidget {
  const BookMemoApp({super.key});

  // ベースカラー (Material Youが使えない場合のフォールバック)
  static final _defaultLightColorScheme = ColorScheme.fromSeed(
    seedColor: Colors.blue,
    brightness: Brightness.light,
  );

  static final _defaultDarkColorScheme = ColorScheme.fromSeed(
    seedColor: Colors.blue,
    brightness: Brightness.dark,
  );

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
        ChangeNotifierProvider(create: (_) => BookProvider()),
        ChangeNotifierProvider(create: (_) => MemoProvider()),
      ],
      child: Consumer<ThemeProvider>(
        builder: (context, themeProvider, _) {
          return DynamicColorBuilder(
            builder: (lightDynamic, darkDynamic) {
              // Material Youのカラースキームを使用（利用可能な場合）
              // 利用不可の場合はデフォルトカラーを使用
              final lightColorScheme = lightDynamic ?? _defaultLightColorScheme;
              final darkColorScheme = darkDynamic ?? _defaultDarkColorScheme;

              return MaterialApp(
                title: '読書メモアプリ',
                debugShowCheckedModeBanner: false,

                // テーマモード設定
                themeMode: themeProvider.themeMode,

                // ライトテーマ
                theme: ThemeData(
                  colorScheme: lightColorScheme,
                  useMaterial3: true,
                  // IBM Plex Sans JPフォントを適用
                  textTheme: GoogleFonts.ibmPlexSansJpTextTheme(
                    ThemeData.light().textTheme,
                  ),
                  appBarTheme: AppBarTheme(
                    centerTitle: false,
                    elevation: 0,
                    titleTextStyle: GoogleFonts.ibmPlexSansJp(
                      fontSize: 20,
                      fontWeight: FontWeight.w500,
                      color: lightColorScheme.onSurface,
                    ),
                  ),
                  cardTheme: CardThemeData(
                    elevation: 2,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  inputDecorationTheme: InputDecorationTheme(
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    filled: true,
                  ),
                ),

                // ダークテーマ
                darkTheme: ThemeData(
                  colorScheme: darkColorScheme,
                  useMaterial3: true,
                  // IBM Plex Sans JPフォントを適用
                  textTheme: GoogleFonts.ibmPlexSansJpTextTheme(
                    ThemeData.dark().textTheme,
                  ),
                  appBarTheme: AppBarTheme(
                    centerTitle: false,
                    elevation: 0,
                    titleTextStyle: GoogleFonts.ibmPlexSansJp(
                      fontSize: 20,
                      fontWeight: FontWeight.w500,
                      color: darkColorScheme.onSurface,
                    ),
                  ),
                  cardTheme: CardThemeData(
                    elevation: 2,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  inputDecorationTheme: InputDecorationTheme(
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    filled: true,
                  ),
                ),

                home: const HomeScreen(),
                onGenerateRoute: (settings) {
                  // ルーティング設定
                  switch (settings.name) {
                    case '/':
                      return MaterialPageRoute(
                        builder: (_) => const HomeScreen(),
                      );
                    case '/books-by-status':
                      final status = settings.arguments as BookStatus;
                      return MaterialPageRoute(
                        builder: (_) => BooksByStatusScreen(status: status),
                      );
                    case '/search':
                      return MaterialPageRoute(
                        builder: (_) => const SearchScreen(),
                      );
                    default:
                      return null;
                  }
                },
              );
            },
          );
        },
      ),
    );
  }
}
