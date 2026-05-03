import 'package:abhay_app_v2/extension/string_extension.dart';
import 'package:abhay_app_v2/gen/assets.gen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:universal_html/html.dart' as html;

class BuildHtmlWidget extends StatelessWidget {
  const BuildHtmlWidget({
    super.key,
    required this.htmlText,
    required this.htmlType,
    this.style,
    this.imageStyle,
    this.styleP,
  });

  final String htmlText;
  final String htmlType;
  final Style? style;
  final Style? imageStyle;
  final Style? styleP;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        SelectionArea(
          focusNode: FocusNode(),
          key: Key(htmlType),
          child: Html(
            data: htmlText.removeAllStyle,
            key: Key(htmlType),
            shrinkWrap: true,
            onLinkTap: (url, attributes, element) {
              if (url!.startsWith('www.')) {
                url = 'https://$url';
              }
              html.window.open(url, '_blank');
            },
            style: {
              'body': style ?? Style(),
              'img': imageStyle ?? Style(),
              'p': styleP ?? Style(),
            },
            extensions: [
              TagExtension(
                tagsToExtend: {'img'},
                builder: (extensionContext) {
                  final src = extensionContext.attributes['src'] ?? '';
                  if (src.isEmpty) return Container();

                  final widthAttr = extensionContext.attributes['width'];

                  double? imageWidth;

                  if (widthAttr != null) {
                    imageWidth = double.tryParse(widthAttr.replaceAll(RegExp(r'[^0-9.]'), ''));
                  }

                  return LayoutBuilder(
                    builder: (context, constraints) {
                      return Image.network(
                        src,
                        width: imageWidth,
                        fit: BoxFit.contain,
                        frameBuilder: (context, child, frame, wasSynchronouslyLoaded) {
                          if (wasSynchronouslyLoaded) return child;
                          return frame != null ? child : Container();
                        },
                        loadingBuilder: (context, child, loadingProgress) {
                          if (loadingProgress == null) {
                            return ConstrainedBox(
                              constraints: BoxConstraints(maxWidth: constraints.maxWidth),
                              child: child,
                            );
                          }
                          return Center(
                            child: CircularProgressIndicator(
                              value: loadingProgress.expectedTotalBytes != null
                                  ? loadingProgress.cumulativeBytesLoaded / loadingProgress.expectedTotalBytes!
                                  : null,
                            ),
                          );
                        },
                        errorBuilder: (context, error, stackTrace) {
                          return Assets.images.placeholder.image();
                        },
                      );
                    },
                  );
                },
              ),
            ],
          ),
        ),
      ],
    );
  }
}
