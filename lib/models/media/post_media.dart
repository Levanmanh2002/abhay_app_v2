import 'dart:io';
import 'dart:typed_data';

import 'package:abhay_app_v2/enum/media_picker.dart';

import 'media_model.dart';

class PostMedia {
  MediaType mediaType;
  File? file;
  MediaModel? mediaModel;
  Uint8List? thumbnail;
  double duration;
  int height;
  int width;

  bool get hasLocalFile {
    return file != null || thumbnail != null;
  }

  double get ratio {
    if (height == 0 || width == 0) {
      return 0;
    }
    return width / height;
  }

  PostMedia({
    this.mediaType = MediaType.image,
    this.file,
    this.thumbnail,
    this.duration = 0,
    this.height = 0,
    this.width = 0,
    this.mediaModel,
  });

  PostMedia copyWith({
    MediaType? mediaType,
    File? file,
    Uint8List? thumbnail,
    double? duration,
    int? height,
    int? width,
    MediaModel? mediaModel,
  }) =>
      PostMedia(
        mediaType: mediaType ?? this.mediaType,
        file: file ?? this.file,
        thumbnail: thumbnail ?? this.thumbnail,
        duration: duration ?? this.duration,
        height: height ?? this.height,
        width: width ?? this.width,
        mediaModel: mediaModel ?? this.mediaModel,
      );
}
