import 'package:abhay_app_v2/widget/reponsive/extension.dart';
import 'package:flutter/material.dart';

class CustomGridList<T> extends StatelessWidget {
  final List<T> items;
  final int crossAxisCount;
  final double crossAxisSpacing;
  final double mainAxisSpacing;
  final Widget Function(BuildContext context, T item, int index) itemBuilder;
  final EdgeInsets? margin;
  final ScrollPhysics? physics;
  final bool shrinkWrap;

  const CustomGridList({
    super.key,
    required this.items,
    required this.crossAxisCount,
    required this.itemBuilder,
    this.crossAxisSpacing = 12,
    this.mainAxisSpacing = 12,
    this.margin,
    this.physics,
    this.shrinkWrap = false,
  });

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      shrinkWrap: shrinkWrap,
      padding: margin,
      itemCount: (items.length / crossAxisCount).ceil(),
      physics: physics ?? const ClampingScrollPhysics(),
      itemBuilder: (context, rowIndex) {
        final startIndex = rowIndex * crossAxisCount;
        final endIndex = (startIndex + crossAxisCount).clamp(0, items.length);
        final rowItems = items.sublist(startIndex, endIndex);

        return Padding(
          padding: padding(
            bottom: rowIndex == (items.length / crossAxisCount).ceil() - 1 ? 0 : mainAxisSpacing,
          ),
          child: IntrinsicHeight(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: List.generate(crossAxisCount, (colIndex) {
                if (colIndex >= rowItems.length) {
                  return const Expanded(child: SizedBox.shrink());
                }

                final item = rowItems[colIndex];
                final globalIndex = startIndex + colIndex;

                return Expanded(
                  child: Padding(
                    padding: padding(right: colIndex < crossAxisCount - 1 ? crossAxisSpacing : 0),
                    child: itemBuilder(context, item, globalIndex),
                  ),
                );
              }),
            ),
          ),
        );
      },
    );
  }
}
