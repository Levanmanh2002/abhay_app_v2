import 'dart:io';
import 'dart:typed_data';

import 'package:abhay_app_v2/enum/media_picker.dart';
import 'package:json_annotation/json_annotation.dart';

import 'post_media.dart';

part 'media_model.g.dart';

enum MediaRatioType {
  square, // 1:1
  landscape, // 16:9
  portrait, // 9:16
}

@JsonSerializable()
class MediaModel {
  String? url;
  String? fileName;
  int? width;
  int? height;
  double? ratio;
  MediaType type;
  String? thumbnail;
  double duration;

  @JsonKey(includeFromJson: false, includeToJson: false)
  File? file;

  @JsonKey(includeFromJson: false, includeToJson: false)
  Uint8List? thumbnailFile;

  String get name {
    if ((fileName ?? '').isNotEmpty) {
      return fileName!;
    } else {
      return url?.split('/').last ?? '';
    }
  }

  MediaRatioType get ratioType {
    final ratio = this.ratio ?? 0;
    if (ratio >= 1.05) {
      return MediaRatioType.landscape;
    } else if (ratio <= 0.95) {
      return MediaRatioType.portrait;
    } else {
      return MediaRatioType.square;
    }
  }

  MediaRatioType get chatRatioType {
    final ratio = this.ratio ?? 0;
    if (ratio > 1) {
      return MediaRatioType.landscape;
    } else {
      return MediaRatioType.portrait;
    }
  }

  MediaModel({
    this.url,
    this.fileName,
    this.width,
    this.height,
    this.ratio,
    this.type = MediaType.image,
    this.duration = 0,
    this.thumbnail,
    this.file,
    this.thumbnailFile,
  });

  factory MediaModel.fromJson(Map<String, dynamic> json) => _$MediaModelFromJson(json);

  Map<String, dynamic> toJson() => _$MediaModelToJson(this);

  void copyMediaThumbnail(MediaModel thumbnail) {
    this.thumbnail = thumbnail.url;
    width = thumbnail.width;
    height = thumbnail.height;
    ratio = thumbnail.ratio;
    type = MediaType.video;
  }

  // Dựa vào aspect ratio:
  // Nếu 1.7 ≤ Aspect Ratio ≤ 1.8 → Hiển thị 16:9 (ảnh ngang).
  // Nếu 0.55 ≤ Aspect Ratio ≤ 0.57 → Hiển thị 9:16 (ảnh dọc).
  // Nếu ngoài khoảng này, có thể xử lý đặc biệt (ví dụ: crop ảnh hoặc hiển thị theo tỷ lệ gần nhất).
  factory MediaModel.fromPostMedia(PostMedia postMedia) => MediaModel(
        duration: postMedia.duration,
        file: postMedia.file,
        thumbnailFile: postMedia.thumbnail,
        type: postMedia.mediaType,
        width: postMedia.width,
        height: postMedia.height,
        ratio: postMedia.width / postMedia.height,
      );
}

extension MediaModelExtension on MediaModel {
  PostMedia get postMedia => PostMedia(
        mediaType: type,
        mediaModel: this,
        height: height ?? 0,
        width: width ?? 0,
        duration: duration,
      );
}
