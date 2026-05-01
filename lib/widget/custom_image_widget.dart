import 'package:abhay_app_v2/core/app_gradient.dart';
import 'package:abhay_app_v2/gen/assets.gen.dart';
import 'package:abhay_app_v2/main.dart';
import 'package:abhay_app_v2/theme/style/style_theme.dart';
import 'package:abhay_app_v2/widget/image_asset_custom.dart';
import 'package:abhay_app_v2/widget/reponsive/extension.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

class CustomImageWidget extends StatelessWidget {
  const CustomImageWidget({
    super.key,
    this.imageUrl = '',
    this.size = 24,
    this.borderRadius = 1000,
    this.width,
    this.height,
    this.showBoder = false,
    this.colorBoder,
    this.color,
    this.fit,
    this.noImage = true,
    this.name = '',
  });

  final String imageUrl;
  final double size;
  final double borderRadius;
  final double? width;
  final double? height;
  final bool showBoder;
  final Color? colorBoder;
  final Color? color;
  final BoxFit? fit;
  final bool noImage;
  final String name;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(borderRadius),
        border: showBoder ? Border.all(width: 1.w, color: colorBoder ?? appTheme.grayE6Color) : null,
        color: color,
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(borderRadius),
        child: CachedNetworkImage(
          imageUrl: imageUrl,
          width: width ?? size,
          height: height ?? size,
          fit: fit ?? BoxFit.cover,
          placeholder: (context, url) => noImage == true
              ? ImageAssetCustom(
                  imagePath: Assets.images.placeholder.path,
                  boxFit: BoxFit.cover,
                  size: size,
                )
              : ImageAssetCustom(
                  imagePath: Assets.images.noUrl.path,
                  boxFit: BoxFit.cover,
                  size: size,
                ),
          errorWidget: (context, url, error) => name.isNotEmpty
              ? Container(
                  width: size,
                  height: size,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: AppGradient.gradientPrimary,
                  ),
                  child: Text(
                    name.isNotEmpty ? name.trim()[0].toUpperCase() : '?',
                    style: StyleThemeData.size18Weight700(color: appTheme.whiteColor),
                  ),
                )
              : noImage == true
                  ? ImageAssetCustom(
                      imagePath: Assets.images.placeholder.path,
                      boxFit: BoxFit.cover,
                      size: size,
                    )
                  : ImageAssetCustom(
                      imagePath: Assets.images.noUrl.path,
                      size: size,
                      boxFit: BoxFit.cover,
                    ),
        ),
      ),
    );
  }
}
