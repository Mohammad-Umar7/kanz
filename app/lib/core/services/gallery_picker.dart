import 'package:image_picker/image_picker.dart';

/// Picks an existing photo from the gallery.
class GalleryPicker {
  GalleryPicker({ImagePicker? picker}) : _picker = picker ?? ImagePicker();

  final ImagePicker _picker;

  /// Returns null when the user cancels. The photo is compressed afterwards by
  /// the ImageCompressor, so it is requested at full quality here.
  Future<XFile?> pick() => _picker.pickImage(source: ImageSource.gallery);

  /// Android can kill the app while the picker is open; the picked file is then
  /// delivered on the next launch. Call on the scan screen's first build.
  Future<XFile?> recoverLost() async {
    final response = await _picker.retrieveLostData();
    if (response.isEmpty) return null;
    return response.file ?? response.files?.firstOrNull;
  }
}
