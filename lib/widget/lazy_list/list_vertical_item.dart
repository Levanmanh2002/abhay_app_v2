import 'package:flutter/material.dart';

class ListVerticalItem<T> extends StatelessWidget {
  const ListVerticalItem({
    required this.itemBuilder,
    super.key,
    this.items = const [],
    this.lineItemCount = 2,
    this.paddingBetweenItem = 8,
    this.paddingBetweenLine = 4,
    this.controller,
    this.divider,
    this.viewPadding,
    this.physics,
    this.isShrinkWrap = true,
    this.isLoading = false,
    this.isSameSize = false,
    this.skeletonView,
  });

  final List<T> items;
  final bool isShrinkWrap;
  final Widget Function(int index, T item) itemBuilder;
  final double paddingBetweenItem;
  final double paddingBetweenLine;
  final int lineItemCount;
  final Widget? divider;
  final ScrollController? controller;
  final ScrollPhysics? physics;
  final EdgeInsets? viewPadding;
  final bool isLoading;
  final Widget? skeletonView;
  final bool isSameSize;

  @override
  Widget build(BuildContext context) {
    final itemColumn = (isLoading ? 30 : items.length) ~/ lineItemCount + 1;
    double? itemSize;
    if (isSameSize) {
      final screenSize = MediaQuery.of(context).size;
      itemSize = (screenSize.width -
              paddingBetweenItem * (lineItemCount - 1) -
              (viewPadding?.left ?? 0) -
              (viewPadding?.right ?? 0)) /
          lineItemCount;
    }
    return ListView.separated(
      controller: controller,
      shrinkWrap: isShrinkWrap,
      physics: physics,
      padding: viewPadding ?? EdgeInsets.zero,
      itemBuilder: (context, index) => buildLineItem(index, itemSize),
      separatorBuilder: (context, index) => divider ?? SizedBox(height: paddingBetweenLine),
      itemCount: itemColumn,
    );
  }

  Widget buildLineItem(int index, double? itemSize) {
    final currentIndex = isLoading ? index : index * lineItemCount;
    if (currentIndex >= items.length && !isLoading) return const SizedBox();
    if (itemSize != null) {
      return SizedBox(
        height: itemSize,
        width: itemSize,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          spacing: paddingBetweenItem,
          children: List.generate(
            lineItemCount,
            (index) {
              return Expanded(
                child: currentIndex + index >= items.length && !isLoading
                    ? Container()
                    : isLoading
                        ? skeletonView ?? const SizedBox()
                        : itemBuilder(currentIndex + index, items[currentIndex + index]),
              );
            },
          ),
        ),
      );
    }
    return IntrinsicHeight(
      child: Row(
        spacing: paddingBetweenItem,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: List.generate(
          lineItemCount,
          (index) => Expanded(
            child: currentIndex + index >= items.length && !isLoading
                ? Container()
                : isLoading
                    ? skeletonView ?? const SizedBox()
                    : itemBuilder(currentIndex + index, items[currentIndex + index]),
          ),
        ),
      ),
    );
  }
}
