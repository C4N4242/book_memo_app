import 'package:sqflite_common/sqflite.dart';
import '../models/book.dart';
import '../models/page_memo.dart';

/// データベースヘルパークラス
class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();
  static Database? _database;

  DatabaseHelper._init();

  /// データベースインスタンスの取得
  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('book_memo.db');
    return _database!;
  }

  /// データベースの初期化
  Future<Database> _initDB(String filePath) async {
    // databaseFactoryは事前に初期化されている必要がある
    final db = databaseFactory;

    // Web版ではパスの概念がないため、直接ファイル名を使用
    return await db.openDatabase(
      filePath,
      options: OpenDatabaseOptions(
        version: 2,
        onCreate: _createDB,
        onUpgrade: _onUpgrade,
      ),
    );
  }

  /// テーブルの作成
  Future<void> _createDB(Database db, int version) async {
    const idType = 'TEXT PRIMARY KEY';
    const textType = 'TEXT NOT NULL';
    const textTypeNullable = 'TEXT';
    const intType = 'INTEGER';
    const realType = 'REAL NOT NULL';

    // 書籍テーブル
    await db.execute('''
      CREATE TABLE books (
        id $idType,
        title $textType,
        author $textType,
        publisher $textTypeNullable,
        purchaseUrl $textTypeNullable,
        coverImageUrl $textTypeNullable,
        localImagePath $textTypeNullable,
        overallMemo $textTypeNullable,
        recommendation $textTypeNullable,
        rating $realType,
        status $textType,
        createdAt $textType,
        completedAt $textTypeNullable
      )
    ''');

    // ページメモテーブル
    await db.execute('''
      CREATE TABLE page_memos (
        id $idType,
        bookId $textType,
        pageNumber $intType,
        chapterName $textTypeNullable,
        quote $textTypeNullable,
        memo $textType,
        type $textType,
        createdAt $textType,
        updatedAt $textType,
        FOREIGN KEY (bookId) REFERENCES books (id) ON DELETE CASCADE
      )
    ''');

    // インデックスの作成
    await db.execute(
      'CREATE INDEX idx_page_memos_bookId ON page_memos(bookId)',
    );
    await db.execute(
      'CREATE INDEX idx_page_memos_pageNumber ON page_memos(pageNumber)',
    );
  }

  /// データベースのアップグレード
  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2) {
      // バージョン2への移行: 画像関連カラムを追加
      await db.execute('ALTER TABLE books ADD COLUMN coverImageUrl TEXT');
      await db.execute('ALTER TABLE books ADD COLUMN localImagePath TEXT');
    }
  }

  // ========== 書籍関連のCRUD操作 ==========

  /// 書籍の追加
  Future<Book> createBook(Book book) async {
    final db = await database;
    await db.insert('books', book.toMap());
    return book;
  }

  /// すべての書籍を取得
  Future<List<Book>> getAllBooks() async {
    final db = await database;
    const orderBy = 'createdAt DESC';
    final result = await db.query('books', orderBy: orderBy);
    return result.map((json) => Book.fromMap(json)).toList();
  }

  /// ステータス別に書籍を取得
  Future<List<Book>> getBooksByStatus(BookStatus status) async {
    final db = await database;
    final result = await db.query(
      'books',
      where: 'status = ?',
      whereArgs: [status.name],
      orderBy: 'createdAt DESC',
    );
    return result.map((json) => Book.fromMap(json)).toList();
  }

  /// IDで書籍を取得
  Future<Book?> getBook(String id) async {
    final db = await database;
    final maps = await db.query('books', where: 'id = ?', whereArgs: [id]);

    if (maps.isNotEmpty) {
      return Book.fromMap(maps.first);
    }
    return null;
  }

  /// 書籍の更新
  Future<int> updateBook(Book book) async {
    final db = await database;
    return db.update(
      'books',
      book.toMap(),
      where: 'id = ?',
      whereArgs: [book.id],
    );
  }

  /// 書籍の削除
  Future<int> deleteBook(String id) async {
    final db = await database;
    // ページメモも一緒に削除される（CASCADE）
    return await db.delete('books', where: 'id = ?', whereArgs: [id]);
  }

  /// 書籍の検索（タイトル・著者名・出版社）
  Future<List<Book>> searchBooks(String query) async {
    final db = await database;
    final result = await db.query(
      'books',
      where: 'title LIKE ? OR author LIKE ? OR publisher LIKE ?',
      whereArgs: ['%$query%', '%$query%', '%$query%'],
      orderBy: 'createdAt DESC',
    );
    return result.map((json) => Book.fromMap(json)).toList();
  }

  /// ステータス別のカウント取得
  Future<Map<BookStatus, int>> getBookCountsByStatus() async {
    final db = await database;
    final counts = <BookStatus, int>{};

    for (final status in BookStatus.values) {
      final result = await db.rawQuery(
        'SELECT COUNT(*) as count FROM books WHERE status = ?',
        [status.name],
      );
      // 結果の最初の行から count カラムを取得
      counts[status] = (result.first['count'] as int?) ?? 0;
    }

    return counts;
  }

  /// すべての出版社リストを取得（重複なし、アルファベット順）
  Future<List<String>> getAllPublishers() async {
    final db = await database;
    final result = await db.rawQuery(
      'SELECT DISTINCT publisher FROM books WHERE publisher IS NOT NULL AND publisher != "" ORDER BY publisher ASC',
    );
    return result
        .map((row) => row['publisher'] as String)
        .where((publisher) => publisher.isNotEmpty)
        .toList();
  }

  /// 出版社別に書籍を取得
  Future<List<Book>> getBooksByPublisher(String publisher) async {
    final db = await database;
    final result = await db.query(
      'books',
      where: 'publisher = ?',
      whereArgs: [publisher],
      orderBy: 'createdAt DESC',
    );
    return result.map((json) => Book.fromMap(json)).toList();
  }

  // ========== ページメモ関連のCRUD操作 ==========

  /// ページメモの追加
  Future<PageMemo> createPageMemo(PageMemo memo) async {
    final db = await database;
    await db.insert('page_memos', memo.toMap());
    return memo;
  }

  /// 書籍のすべてのページメモを取得
  Future<List<PageMemo>> getPageMemosByBookId(String bookId) async {
    final db = await database;
    final result = await db.query(
      'page_memos',
      where: 'bookId = ?',
      whereArgs: [bookId],
      orderBy: 'pageNumber ASC, createdAt DESC',
    );
    return result.map((json) => PageMemo.fromMap(json)).toList();
  }

  /// ページメモの更新
  Future<int> updatePageMemo(PageMemo memo) async {
    final db = await database;
    return db.update(
      'page_memos',
      memo.toMap(),
      where: 'id = ?',
      whereArgs: [memo.id],
    );
  }

  /// ページメモの削除
  Future<int> deletePageMemo(String id) async {
    final db = await database;
    return await db.delete('page_memos', where: 'id = ?', whereArgs: [id]);
  }

  /// メモの検索（メモ内容・引用文）
  Future<List<PageMemo>> searchMemos(String bookId, String query) async {
    final db = await database;
    final result = await db.query(
      'page_memos',
      where: 'bookId = ? AND (memo LIKE ? OR quote LIKE ?)',
      whereArgs: [bookId, '%$query%', '%$query%'],
      orderBy: 'pageNumber ASC, createdAt DESC',
    );
    return result.map((json) => PageMemo.fromMap(json)).toList();
  }

  /// データベースのクローズ
  Future<void> close() async {
    final db = await database;
    await db.close();
  }
}
