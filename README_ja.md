# 📚 読書メモアプリ

[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)
[![Flutter](https://img.shields.io/badge/Flutter-3.9.2+-02569B?logo=flutter)](https://flutter.dev)
[![Platform](https://img.shields.io/badge/Platform-Android%20%7C%20Web%20%7C%20Windows-blue)]()

[English](README.md) | 日本語

Flutterで作成した読書管理・メモアプリです。気になる本の管理から読書中のメモ、読了後の感想まで、読書ライフをトータルでサポートします。

## ✨ 主な機能

### 📖 書籍管理
- **簡単登録**: 書籍名・著者名・出版社を登録
- **📸 書籍カバー画像**: 
  - Google Books APIから自動取得
  - カメラで撮影して登録
  - ギャラリーから選択
- **購入先URL**: Amazon等のリンクを保存
- **ステータス管理**: 気になる💭 / 読書中📖 / 読了⭐
- **評価機能**: 5段階の星評価
- **おすすめポイント**: 気になる理由やおすすめポイントを記録

### 📝 メモ機能
- **全体メモ**: 書籍全体に対する感想・レビュー
- **ページメモ**: 特定のページや章に紐づくメモ
- **メモの種類**:
  - 📝 一般メモ
  - 💬 引用
  - 💡 気づき
  - ❓ 疑問点
- **引用機能**: 印象的な一文を記録
- **ページ番号**: 該当ページを記録

### 🔍 検索・フィルター
- 書籍名・著者名での検索
- ステータス別表示（Drawerメニューから）
- 読書中・読了・気になる本を簡単に切り替え

### 🔗 共有機能
- SNS共有: 書籍情報やメモを共有
- URLリンク: 購入先へワンタップでアクセス
- メモの共有: ページメモを個別に共有可能

### 🎨 UI/UX
- **Material Design 3**: モダンなデザイン
- **Material You対応**: Android 12以降で壁紙に合わせた配色を自動生成
- **テーマ切り替え**: ライト/ダーク/システム設定の3種類
- **IBM Plex Sans JPフォント**: 読みやすい日本語フォントを採用
- **書籍カバー表示**: 視覚的に分かりやすい一覧表示
- **Drawerメニュー**: 直感的なナビゲーション
- **カード型UI**: 見やすい書籍一覧
- **タブ切り替え**: 全体メモとページメモを切り替え
- **レスポンシブデザイン**: タブレット・横向き画面でグリッド表示に自動切り替え
- **カスタムスワイプジェスチャー**: Android 12+のジェスチャーナビゲーションと競合しない画面中央スワイプでドロワー表示

## 🛠️ 技術スタック

- **Framework**: Flutter 3.9.2+
- **言語**: Dart
- **状態管理**: Provider
- **データベース**: 
  - Android/iOS: SQLite (sqflite)
  - Windows/Linux/macOS: SQLite (sqflite_common_ffi)
  - Web: IndexedDB (sqflite_common_ffi_web)
- **主要パッケージ**:
  - `provider` - 状態管理
  - `sqflite` / `sqflite_common` / `sqflite_common_ffi` / `sqflite_common_ffi_web` - データベース
  - `flutter_rating_bar` - 星評価UI
  - `cached_network_image` - 画像キャッシュ
  - `image_picker` - カメラ・ギャラリー連携
  - `http` - Google Books API通信
  - `url_launcher` - URL起動
  - `share_plus` - SNS共有
  - `intl` - 日付フォーマット
  - `uuid` - ID生成
  - `dynamic_color` - Material You対応
  - `shared_preferences` - 設定保存
  - `google_fonts` - IBM Plex Sans JPフォント
  - `flutter_launcher_icons` - アプリアイコン自動生成

## 📁 プロジェクト構成

```
lib/
├── main.dart                    # エントリーポイント
├── database_init.dart           # デスクトップ版DB初期化
├── database_init_web.dart       # Web版DB初期化
├── database_init_stub.dart      # スタブ実装
├── models/                      # データモデル
│   ├── book.dart               # 書籍モデル
│   └── page_memo.dart          # ページメモモデル
├── providers/                   # 状態管理
│   ├── book_provider.dart      # 書籍プロバイダー
│   ├── memo_provider.dart      # メモプロバイダー
│   └── theme_provider.dart     # テーマプロバイダー
├── database/                    # データベース
│   └── database_helper.dart    # SQLiteヘルパー
├── screens/                     # 画面
│   ├── home_screen.dart        # ホーム画面
│   ├── books_by_status_screen.dart  # ステータス別一覧
│   ├── add_book_screen.dart    # 書籍追加・編集
│   ├── book_detail_screen.dart # 書籍詳細
│   ├── add_memo_screen.dart    # メモ追加・編集
│   └── settings_screen.dart    # 設定画面
└── widgets/                     # 共通ウィジェット
    ├── app_drawer.dart         # Drawerメニュー
    └── book_card.dart          # 書籍カード
```

## 🚀 セットアップ

### 1. 依存関係のインストール

```bash
flutter pub get
```

### 2. Web版の追加セットアップ（Web版を使用する場合のみ）

```bash
dart run sqflite_common_ffi_web:setup
```

### 3. アプリの実行

**Windows版:**
```bash
flutter run -d windows
```

**Web版:**
```bash
flutter run -d chrome
```

**Android版:**
```bash
flutter run
```

### 4. アプリアイコンの生成（初回のみ）

```bash
dart run flutter_launcher_icons
```

## 📱 動作環境

- Flutter SDK 3.9.2以上
- Dart SDK 3.9.2以上
- 対応プラットフォーム: Android / Web / Windows

### プラットフォーム固有の要件

**Windows:**
- 開発者モードを有効化（Settings → Update & Security → For developers → Developer mode ON）
- Visual Studio 2022（C++デスクトップ開発ツール）

**Web:**
- 初回起動前に `dart run sqflite_common_ffi_web:setup` を実行

## 💡 使い方

### 1. 書籍の追加
1. ホーム画面右下の「本を追加」ボタンをタップ
2. 書籍名・著者名を入力（必須）
3. 出版社・購入先URLを入力（任意）
4. ステータスと評価を設定
5. おすすめポイントを記入
6. 「追加する」をタップ

### 2. メモの追加
1. 書籍詳細画面を開く
2. 「ページメモ」タブを選択
3. 「メモを追加」ボタンをタップ
4. メモの種類を選択
5. ページ番号や引用文を入力（任意）
6. メモ本文を記入
7. 「追加する」をタップ

### 3. ステータス別表示
1. 左上のハンバーガーメニュー（☰）をタップ、または画面中央から右へスワイプ
2. 「読書中」「読了」「気になる」から選択
3. 該当ステータスの書籍のみ表示

### 4. 共有

- **書籍の共有**: 詳細画面右上の共有ボタンをタップ
- **メモの共有**: 各メモカードの共有アイコンをタップ

### 5. テーマ切り替え

- **クイック切り替え**: ホーム画面右上のテーマアイコンをタップで切り替え
- **詳細設定**: Drawerメニュー → 設定 → 外観
  - ライトモード: 明るいテーマ
  - ダークモード: 暗いテーマ
  - システム設定に従う: デバイスの設定に自動対応
- **Material You**: Android 12以降では壁紙の色に合わせた配色を自動生成

## 🎓 学習ポイント

このプロジェクトは、Flutter初学者向けの実践的なサンプルアプリです。以下を学べます：

- ✅ **CRUD操作**: SQLiteでのデータの作成・読取・更新・削除
- ✅ **状態管理**: Providerを使った状態管理
- ✅ **画面遷移**: 複数画面のナビゲーション
- ✅ **フォーム処理**: ユーザー入力のバリデーション
- ✅ **リスト表示**: 動的なリスト生成
- ✅ **タブUI**: TabBarとTabBarViewの使用
- ✅ **Drawerメニュー**: サイドメニューの実装
- ✅ **外部連携**: URL起動とSNS共有
- ✅ **レスポンシブデザイン**: タブレット・横向き対応
- ✅ **マルチプラットフォーム**: Android/Windows/Web対応
- ✅ **Material Design 3**: 最新のデザインシステム
- ✅ **カスタムジェスチャー**: タッチ操作の最適化

## 📝 ライセンス

このプロジェクトはMITライセンスの下で公開されています - 詳細は [LICENSE](LICENSE) ファイルをご覧ください。

### サードパーティライセンス

このプロジェクトは以下のオープンソースパッケージを使用しています:
- [Flutter](https://github.com/flutter/flutter) - BSD-3-Clause License
- [Provider](https://pub.dev/packages/provider) - MIT License
- [sqflite](https://pub.dev/packages/sqflite) - MIT License
- [Google Fonts](https://pub.dev/packages/google_fonts) - Apache-2.0 License

依存パッケージとそのライセンスの完全なリストは [pubspec.yaml](pubspec.yaml) をご覧ください。

---

**Happy Reading! 📚✨**
