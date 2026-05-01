import 'dart:async';
import 'dart:io';

import 'package:abhay_app_v2/extension/color_extension.dart';
import 'package:abhay_app_v2/main.dart';
import 'package:abhay_app_v2/models/media/post_media.dart';
import 'package:abhay_app_v2/theme/style/style_theme.dart';
import 'package:abhay_app_v2/widget/reponsive/extension.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:dismissible_page/dismissible_page.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';

class FullPhotoViewer extends StatefulWidget {
  const FullPhotoViewer({
    super.key,
    this.initialIndex = 0,
    this.assets = const [],
    this.onPageChanged,
    this.customSubChild,
  });

  final List<PostMedia> assets;
  final int initialIndex;
  final Function(int)? onPageChanged;
  final List<Widget>? customSubChild;

  @override
  State<FullPhotoViewer> createState() => _FullPhotoViewerState();
}

class _FullPhotoViewerState extends State<FullPhotoViewer> {
  Completer<ImageInfo> completer = Completer();
  late ImageProvider imageProvider;
  late PageController pageController;
  late final ValueNotifier<int> indexNotifier;

  @override
  void initState() {
    pageController = PageController(initialPage: widget.initialIndex);
    indexNotifier = ValueNotifier(widget.initialIndex);
    super.initState();
  }

  @override
  void dispose() {
    pageController.dispose();
    indexNotifier.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return DismissiblePage(
      backgroundColor: appTheme.transparentColor,
      onDismissed: () {
        Navigator.of(context).pop();
      },
      direction: DismissiblePageDismissDirection.multi,
      isFullScreen: true,
      child: Stack(
        children: [
          PageView.builder(
            controller: pageController,
            itemCount: widget.assets.length,
            onPageChanged: (index) {
              if (widget.onPageChanged != null) {
                widget.onPageChanged!(index);
              }
              indexNotifier.value = index;
            },
            itemBuilder: (BuildContext context, int index) {
              final assetSource = widget.assets[index];
              final urlImage = assetSource.mediaModel?.url ?? '';
              final isFile = assetSource.file != null;

              return Center(
                child: urlImage.isNotEmpty
                    ? CachedNetworkImage(
                        imageUrl: urlImage,
                        placeholder: (context, url) => CupertinoActivityIndicator(
                          color: appTheme.whiteColor,
                          radius: 15,
                        ),
                        errorWidget: (context, url, error) => Icon(Icons.error, color: appTheme.red55Color),
                        fit: BoxFit.contain,
                      )
                    : isFile
                        ? Image.file(
                            File(assetSource.file!.path),
                            fit: BoxFit.contain,
                          )
                        : const SizedBox(),
              );
            },
          ),
          ...widget.customSubChild ?? [],
          Positioned(
            bottom: 30,
            left: 30,
            right: 30,
            child: Center(
              child: SmoothPageIndicator(
                controller: pageController,
                count: widget.assets.length,
                effect: WormEffect(
                  radius: 5.w,
                  dotHeight: 10.w,
                  dotWidth: 10.w,
                  spacing: 6.w,
                  activeDotColor: appTheme.whiteColor,
                  dotColor: appTheme.grayColor,
                ),
              ),
            ),
          ),
          Positioned(
            bottom: 30,
            right: 30,
            child: ValueListenableBuilder(
              valueListenable: indexNotifier,
              builder: (_, index, __) {
                return Text(
                  '${index + 1}/${widget.assets.length}',
                  style: StyleThemeData.size12Weight400(color: appTheme.whiteColor, height: 1.h),
                );
              },
            ),
          ),
          Positioned(
            top: 40,
            right: 10,
            child: IconButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              icon: Container(
                padding: padding(all: 6),
                decoration: BoxDecoration(
                  color: appTheme.blackColor.withSafeOpacity(0.5),
                  shape: BoxShape.circle,
                ),
                child: Icon(Icons.close, color: appTheme.whiteColor, size: 18.w),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
