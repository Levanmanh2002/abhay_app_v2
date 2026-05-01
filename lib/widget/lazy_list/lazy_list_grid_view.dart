import 'package:abhay_app_v2/main.dart';
import 'package:abhay_app_v2/widget/reponsive/extension.dart';
import 'package:flutter/material.dart';
import 'package:skeletonizer/skeletonizer.dart';

import 'lazy_list_controller.dart';

class LazyListGridView<T> extends StatefulWidget {
  const LazyListGridView({
    super.key,
    required this.itemBuilder,
    required this.controller,
    required this.skeletonView,
    this.emptyView,
    this.divider,
    this.physics,
    this.listPadding,
    this.callInit = true,
    this.hasRefresh = false,
    this.shrinkWrap = true,
    this.lineItemCount = 1,
    this.topView,
    this.onRefresh,
    this.bottomView,
    this.onLoadMore,
    this.scrollController,
    this.isSameItemSize = false,
    this.buildCustomView,
    this.onEndScroll,
    this.disposeScrollCtrl = true,
    this.firstView,
    this.mainAxisSpacing = 8,
    this.crossAxisSpacing = 12,
    this.itemsFilter,
  });

  final Widget Function(int index, T item) itemBuilder;
  final Widget Function() skeletonView;
  final Widget? emptyView;
  final LazyListController<T> controller;
  final ScrollController? scrollController;
  final Widget? divider;
  final ScrollPhysics? physics;
  final EdgeInsets? listPadding;
  final bool hasRefresh;
  final bool callInit;
  final int lineItemCount;
  final bool shrinkWrap;
  final Widget? topView;
  final Future<void> Function()? onRefresh;
  final Widget? bottomView;
  final VoidCallback? onLoadMore;
  final bool isSameItemSize;
  final Widget Function(Widget listView)? buildCustomView;
  final VoidCallback? onEndScroll;
  final bool disposeScrollCtrl;
  final Widget? firstView;
  final double mainAxisSpacing;
  final double crossAxisSpacing;
  final List<T> Function(List<T> items)? itemsFilter;

  @override
  State<LazyListGridView<T>> createState() => LazyListGridViewState<T>();
}

class LazyListGridViewState<T> extends State<LazyListGridView<T>> with AutomaticKeepAliveClientMixin {
  LazyListController<T> get controller => widget.controller;
  late final ScrollController scrollCtrl = widget.scrollController ?? ScrollController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (controller.data.value.isEmpty && widget.callInit) {
        controller.onRefresh();
      }
    });
  }

  @override
  void dispose() {
    if (widget.disposeScrollCtrl) {
      scrollCtrl.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final hasTopView = widget.topView != null;
    Widget child = ValueListenableBuilder(
      valueListenable: controller.isLoading,
      builder: (context, loading, child) => ValueListenableBuilder<List<T>>(
        valueListenable: controller.data,
        builder: (context, items, child) => NotificationListener<ScrollNotification>(
          onNotification: (notification) {
            if (notification is ScrollEndNotification) {
              widget.onEndScroll?.call();
              if (notification.metrics.extentAfter == 0 && notification.metrics.axis == Axis.vertical) {
                if (controller.isLoadMore || controller.isOutOfRange) {
                  return false;
                }
                controller.onLoadMore();
              }
            }
            return false;
          },
          child: hasTopView
              ? ListView(
                  physics: widget.physics ?? const AlwaysScrollableScrollPhysics(),
                  padding: EdgeInsets.zero,
                  children: [
                    widget.topView ?? const SizedBox(),
                    _buildListItemView(loading, items, hasTopView),
                    widget.bottomView ?? const SizedBox()
                  ],
                )
              : _buildListItemView(loading, items, hasTopView),
        ),
      ),
    );
    if (widget.hasRefresh) {
      child = RefreshIndicator(
          onRefresh: () async {
            await Future.wait([
              controller.onRefresh(),
              if (widget.onRefresh != null) widget.onRefresh!(),
            ]);
          },
          child: child);
    }
    if (widget.buildCustomView != null) {
      return widget.buildCustomView!(child);
    }
    return child;
  }

  Widget _buildListItemView(bool loading, List<T> items, bool hasTopView) {
    // final length = widget.firstView != null ? 1 + items.length : items.length;
    final filteredItems = widget.itemsFilter != null ? widget.itemsFilter!(items) : items;

    final length = widget.firstView != null ? 1 + filteredItems.length : filteredItems.length;

    return Stack(
      alignment: Alignment.bottomCenter,
      children: [
        Skeletonizer(
          enabled: loading,
          child: loading || filteredItems.isNotEmpty
              ? GridView.builder(
                  padding: widget.listPadding ?? padding(vertical: 12),
                  shrinkWrap: hasTopView ? true : widget.shrinkWrap,
                  controller: scrollCtrl,
                  itemCount: loading ? 12 : length,
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: widget.lineItemCount,
                    mainAxisSpacing: widget.mainAxisSpacing,
                    crossAxisSpacing: widget.crossAxisSpacing,
                  ),
                  physics: hasTopView
                      ? const NeverScrollableScrollPhysics()
                      : widget.physics ?? const AlwaysScrollableScrollPhysics(),
                  itemBuilder: (context, index) {
                    if (loading) {
                      return widget.skeletonView();
                    }
                    var newIndex = index;
                    if (widget.firstView != null) {
                      if (index == 0) {
                        return widget.firstView!;
                      }
                      newIndex = index - 1;
                    }
                    return widget.itemBuilder(newIndex, filteredItems[newIndex]);
                    // return loading
                    //     ? widget.skeletonView()
                    //     : index == 0 && widget.firstView != null
                    //         ? widget.firstView
                    //         : widget.itemBuilder(
                    //             index - (widget.firstView != null ? 1 : 0),
                    //             items[index]);
                  },
                )
              : widget.emptyView ?? const SizedBox(),
        ),
        if (!loading && filteredItems.isNotEmpty)
          ValueListenableBuilder(
            valueListenable: controller.isLoadMoreNotifier,
            builder: (context, isLoadMore, _) => AnimatedPositioned(
              duration: const Duration(milliseconds: 50),
              bottom: isLoadMore ? 50.h : -200,
              right: 0,
              left: 0,
              child: Center(child: _buildLoadMore()),
            ),
          )
      ],
    );
  }

  Widget _buildLoadMore() {
    return Padding(
      padding: padding(all: 8),
      child: SizedBox(
        height: 20.w,
        width: 20.w,
        child: CircularProgressIndicator(color: appTheme.appColor),
      ),
    );
  }

  @override
  bool get wantKeepAlive => true;
}
