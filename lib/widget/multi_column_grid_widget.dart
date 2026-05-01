import 'package:abhay_app_v2/widget/empty_data_widget.dart';
import 'package:abhay_app_v2/widget/reponsive/extension.dart';
import 'package:flutter/material.dart';

class MultiColumnGridWidget<T> extends StatelessWidget {
  final List<T> items;
  final Widget Function(int index, T item) itemBuilder;
  final int columnCount;
  final double horizontalSpacing;
  final double verticalSpacing;
  final Widget? emptyWidget;
  final CrossAxisAlignment crossAxisAlignment;

  const MultiColumnGridWidget({
    super.key,
    required this.items,
    required this.itemBuilder,
    this.columnCount = 2,
    this.horizontalSpacing = 10,
    this.verticalSpacing = 10,
    this.emptyWidget,
    this.crossAxisAlignment = CrossAxisAlignment.start,
  });

  @override
  Widget build(BuildContext context) {
    if (items.isEmpty) {
      return emptyWidget ?? const EmptyDataWidget();
    }

    final rowCount = (items.length / columnCount).ceil();

    return SingleChildScrollView(
      physics: const ClampingScrollPhysics(),
      child: Column(
        children: List.generate(rowCount, (rowIndex) {
          final isLastRow = rowIndex == rowCount - 1;

          return Padding(
            padding: padding(
              bottom: isLastRow ? 0 : verticalSpacing.h,
            ),
            child: Row(
              crossAxisAlignment: crossAxisAlignment,
              children: List.generate(columnCount, (colIndex) {
                final itemIndex = rowIndex * columnCount + colIndex;
                final hasItem = itemIndex < items.length;
                final isLastColumn = colIndex == columnCount - 1;

                return Expanded(
                  child: Row(
                    children: [
                      Expanded(
                        child: hasItem ? itemBuilder(itemIndex, items[itemIndex]) : const SizedBox.shrink(),
                      ),
                      if (!isLastColumn) SizedBox(width: horizontalSpacing.w),
                    ],
                  ),
                );
              }),
            ),
          );
        }),
      ),
    );
  }
}
