import 'package:flutter/material.dart';
import 'package:generic_state_bya2/src/generic_state_setup.dart';
import 'generic_state.dart';

class GenericStateWidget<T> extends StatelessWidget {
  //Must now be sliver
  final Widget Function(T) onSuccess;
  final Widget Function(ErrorState<T>)? onError;
  final Widget Function()? loadingShimmer;
  final void Function() onErrorReload;

  ///Does not work for slivers
  final Future<void> Function()? onRefresh;
  final GenericState<T> state;
  final bool Function(T) isEmptyCheck;

  ///[isEmptyCheck] value must be true to display this widget.
  ///If widget not passed "No result" text will be shown.
  final Widget Function(SuccessState<T>)? onEmpty;
  final bool isSliver;

  const GenericStateWidget({
    super.key,
    required this.state,
    required this.onSuccess,
    required this.onErrorReload,
    this.loadingShimmer,
    this.onRefresh,
    this.onError,
    required this.isEmptyCheck,
    this.onEmpty,
    this.isSliver = false,
  });

  @override
  Widget build(
    BuildContext context,
  ) {
    final state = this.state;
    Widget outputChild = switch (state) {
      SuccessState<T>() => _onSuccessWidget(state),
      ErrorState<T>() => onError?.call(state) ??
          Builder(builder: (context) {
            final outputWidget = Padding(
              padding: const EdgeInsets.symmetric(horizontal: 5),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const SizedBox(
                    height: 30,
                  ),
                  GenericStateSetup.onError(),
                  Text(
                    state.error.toString(),
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 18,
                      color: Colors.grey.shade500,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(
                    height: 15,
                  ),
                  Center(
                    child: ElevatedButton(
                      onPressed: onErrorReload,
                      child: const Text(
                        "Reload",
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(
                    height: 30,
                  ),
                ],
              ),
            );
            if (isSliver) {
              return SliverToBoxAdapter(
                child: outputWidget,
              );
            } else {
              return outputWidget;
            }
          }),
      _ => loadingShimmer?.call() ??
          Builder(builder: (context) {
            const outputWidget = Center(
              child: CircularProgressIndicator(),
            );
            if (isSliver) {
              return const SliverFillRemaining(
                child: outputWidget,
              );
            } else {
              return outputWidget;
            }
          }),
    };
    if (onRefresh != null && !isSliver && !state.isLoading) {
      return RefreshIndicator(
        child: outputChild,
        onRefresh: () async {
          await onRefresh?.call();
        },
      );
    } else {
      return outputChild;
    }
  }

  Widget _onSuccessWidget(
    SuccessState<T> state,
  ) {
    if (isEmptyCheck.call(state.data) == true) {
      return Builder(builder: (context) {
        final returnWidget = Center(
          child: onEmpty?.call(state) ??
              GenericStateSetup.onEmpty(),
        );
        if (isSliver) {
          return SliverToBoxAdapter(
            child: returnWidget,
          );
        }
        return returnWidget;
      });
    } else {
      return onSuccess(state.data);
    }
  }
}

///Pagination loading does not work for sliver
class GenericStatePaginationWidget<T> extends StatefulWidget {
  //Below are for GenericStateWidget
  //Must now be sliver
  final Widget Function(T) onSuccess;
  final Widget Function(ErrorState<T>)? onError;
  final Widget Function()? loadingShimmer;
  final void Function() onErrorReload;

  ///Does not work for slivers
  final Future<void> Function()? onRefresh;
  final GenericState<T> state;
  final bool Function(T) isEmptyCheck;

  ///[isEmptyCheck] value must be true to display this widget.
  ///If widget not passed "No result" text will be shown.
  final Widget Function(SuccessState<T>)? onEmpty;
  final bool isSliver;

  //Below are for Pagination
  final ScrollController scrollController;
  final VoidCallback toFetchNextPage;
  final Axis axis;

  ///Set false if you have having issue on infinite size error
  final bool wrapExpanded;
  final MainAxisSize mainAxisSize;

  const GenericStatePaginationWidget({
    super.key,
    required this.state,
    required this.onSuccess,
    required this.onErrorReload,
    required this.scrollController,
    required this.toFetchNextPage,
    this.loadingShimmer,
    this.onRefresh,
    this.onError,
    required this.isEmptyCheck,
    this.onEmpty,
    this.axis = Axis.vertical,
    this.wrapExpanded = true,
    this.mainAxisSize = MainAxisSize.max,
    this.isSliver = false,
  });

  @override
  State<GenericStatePaginationWidget<T>> createState() =>
      _GenericStatePaginationWidgetState<T>();
}

class _GenericStatePaginationWidgetState<T>
    extends State<GenericStatePaginationWidget<T>> {
  @override
  void initState() {
    super.initState();
    widget.scrollController.addListener(scrollListener);
  }

  void scrollListener() {
    if (!context.mounted) return;
    if (widget.state.canDoPagination(widget.scrollController)) {
      widget.toFetchNextPage();
    }
  }

  @override
  Widget build(BuildContext context) {
    return GenericStateWidget(
      state: widget.state,
      onSuccess: (data) {
        if (widget.isSliver) {
          return widget.onSuccess(data);
        }
        final onSuccess = widget.onSuccess(data);
        final outputValue = Flex(
          direction: widget.axis,
          mainAxisSize: widget.mainAxisSize,
          children: [
            Builder(builder: (context) {
              if (widget.wrapExpanded) {
                return Expanded(child: onSuccess);
              } else {
                return onSuccess;
              }
            }),
            if (widget.state.isPaginationLoading)
              const Center(
                child: CircularProgressIndicator(),
              ),
          ],
        );
        return outputValue;
      },
      onErrorReload: widget.onErrorReload,
      loadingShimmer: widget.loadingShimmer,
      onRefresh: widget.onRefresh,
      onError: widget.onError,
      isEmptyCheck: widget.isEmptyCheck,
      onEmpty: widget.onEmpty,
      isSliver: widget.isSliver,
    );
  }

  @override
  void dispose() {
    widget.scrollController.removeListener(scrollListener);
    //Warning: Never dispose controller here, because it was not created here
    super.dispose();
  }
}
