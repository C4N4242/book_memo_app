import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart';

/// 画像選択・保存を管理するヘルパー
class ImageHelper {
  static final ImagePicker _picker = ImagePicker();

  /// カメラから画像を撮影
  Future<String?> pickFromCamera() async {
    try {
      final XFile? photo = await _picker.pickImage(
        source: ImageSource.camera,
        maxWidth: 800,
        maxHeight: 800,
        imageQuality: 85,
      );

      if (photo != null) {
        return await _saveImage(photo);
      }
      return null;
    } catch (e) {
      // エラーログは開発時のみ
      // print('カメラエラー: $e');
      return null;
    }
  }

  /// ギャラリーから画像を選択
  Future<String?> pickFromGallery() async {
    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 800,
        maxHeight: 800,
        imageQuality: 85,
      );

      if (image != null) {
        return await _saveImage(image);
      }
      return null;
    } catch (e) {
      // エラーログは開発時のみ
      // print('ギャラリーエラー: $e');
      return null;
    }
  }

  /// 画像を永続的なディレクトリに保存
  Future<String> _saveImage(XFile image) async {
    final appDir = await getApplicationDocumentsDirectory();
    final fileName =
        '${DateTime.now().millisecondsSinceEpoch}${path.extension(image.path)}';
    final savedPath = path.join(appDir.path, 'book_covers', fileName);

    // ディレクトリが存在しない場合は作成
    final directory = Directory(path.dirname(savedPath));
    if (!await directory.exists()) {
      await directory.create(recursive: true);
    }

    // ファイルをコピー
    final File sourceFile = File(image.path);
    await sourceFile.copy(savedPath);

    return savedPath;
  }

  /// 画像ファイルを削除
  Future<void> deleteImage(String imagePath) async {
    try {
      final file = File(imagePath);
      if (await file.exists()) {
        await file.delete();
      }
    } catch (e) {
      // エラーログは開発時のみ
      // print('画像削除エラー: $e');
    }
  }

  /// 画像選択のダイアログを表示するための選択肢
  static const List<ImageSourceOption> sourceOptions = [
    ImageSourceOption(
      title: 'カメラで撮影',
      icon: 'camera',
      source: ImageSourceType.camera,
    ),
    ImageSourceOption(
      title: 'ギャラリーから選択',
      icon: 'photo_library',
      source: ImageSourceType.gallery,
    ),
  ];
}

/// 画像ソースのタイプ
enum ImageSourceType { camera, gallery }

/// 画像ソースの選択肢
class ImageSourceOption {
  final String title;
  final String icon;
  final ImageSourceType source;

  const ImageSourceOption({
    required this.title,
    required this.icon,
    required this.source,
  });
}
