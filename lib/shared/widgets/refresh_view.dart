import 'package:flutter/material.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

enum RefreshOutcome { succeeded, failed, noMoreData }

void startRefresh(RefreshController controller) {
  if (controller.isRefresh) {
    return;
  }
  WidgetsBinding.instance.addPostFrameCallback((_) {
    if (!controller.isRefresh && controller.position != null) {
      controller.requestRefresh();
    }
  });
}

void completeRefresh(RefreshController controller, RefreshOutcome outcome) {
  if (controller.isRefresh) {
    switch (outcome) {
      case RefreshOutcome.succeeded:
      case RefreshOutcome.noMoreData:
        controller.refreshCompleted(resetFooterState: true);
      case RefreshOutcome.failed:
        controller.refreshFailed();
    }
  }

  if (!controller.isLoading) {
    return;
  }
  switch (outcome) {
    case RefreshOutcome.succeeded:
      controller.loadComplete();
    case RefreshOutcome.failed:
      controller.loadFailed();
    case RefreshOutcome.noMoreData:
      controller.loadNoData();
  }
}

class RefreshView extends StatelessWidget {
  const RefreshView({
    super.key,
    required this.controller,
    required this.child,
    this.onRefresh,
    this.onLoadMore,
    this.enableRefresh = true,
    this.enableLoadMore = false,
    this.scrollController,
    this.header,
    this.footer,
  });

  final RefreshController controller;
  final Widget child;
  final VoidCallback? onRefresh;
  final VoidCallback? onLoadMore;
  final bool enableRefresh;
  final bool enableLoadMore;
  final ScrollController? scrollController;
  final Widget? header;
  final Widget? footer;

  @override
  Widget build(BuildContext context) {
    return SmartRefresher(
      controller: controller,
      scrollController: scrollController,
      enablePullDown: enableRefresh,
      enablePullUp: enableLoadMore,
      onRefresh: onRefresh,
      onLoading: onLoadMore,
      header: header ?? const ClassicHeader(),
      footer: footer ?? const ClassicFooter(),
      child: child,
    );
  }
}
