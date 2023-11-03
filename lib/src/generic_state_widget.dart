import 'package:flutter/material.dart';
import 'package:generic_state_bya2/src/generic_state.dart';



class GenericStateWidget<T> extends StatelessWidget {
  final Widget Function(SuccessState<T>) onSuccess;
  final Widget Function(ErrorState<T>)? onError;
  final Widget Function()? loadingShimmer;
  final Future<void> Function() onErrorReload;
  final Future<void> Function()? onRefresh;
  final GenericState<T> state;
  final bool Function(SuccessState<T>)? isEmptyCheck;

  ///[isEmptyCheck] value must be true to display this widget.
  ///If widget not passed "No result" text will be shown.
  final Widget Function(SuccessState<T>)? onEmpty;

  const GenericStateWidget({
    super.key,
    required this.state,
    required this.onSuccess,
    required this.onErrorReload,
    this.loadingShimmer,
    this.onRefresh,
    this.onError,
    this.isEmptyCheck,
    this.onEmpty,
  });

  @override
  Widget build(
      BuildContext context,
      ) {
    final textTheme = Theme.of(context).textTheme;
    final state = this.state;
    Widget outputChild = switch (state) {
      SuccessState<T>() => _onSuccessWidget(state, textTheme),
      ErrorState<T>() => onError?.call(state) ??
          Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                state.error.toString(),
              ),
              Center(
                child: TextButton(
                  onPressed: onErrorReload,
                  child: Text(
                    "Reload",
                    style: textTheme.displaySmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ],
          ),
      _ => loadingShimmer?.call() ??
          const Center(
            child: CircularProgressIndicator(),
          ),
    };
    if (onRefresh != null) {
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
      TextTheme textTheme,
      ) {
    if (isEmptyCheck?.call(state) == true) {
      return onEmpty?.call(state) ??
          Text(
            "No Result",
            style: textTheme.displaySmall?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          );
    } else {
      return onSuccess(state);
    }
  }
}

class GenericStatePaginationWidget<T> extends StatefulWidget {
  //Below are for GenericStateWidget
  final Widget Function(SuccessState<T>) onSuccess;
  final Widget Function(ErrorState<T>)? onError;
  final Widget Function()? loadingShimmer;
  final Future<void> Function() onErrorReload;
  final Future<void> Function()? onRefresh;
  final GenericState<T> state;
  final bool Function(SuccessState<T>)? isEmptyCheck;

  ///[isEmptyCheck] value must be true to display this widget.
  ///If widget not passed "No result" text will be shown.
  final Widget Function(SuccessState<T>)? onEmpty;

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
    this.isEmptyCheck,
    this.onEmpty,
    this.axis = Axis.vertical,
    this.wrapExpanded=true,
    this.mainAxisSize=MainAxisSize.max,
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
    return Flex(
      direction: widget.axis,
      mainAxisSize: widget.mainAxisSize,
      children: [
        Builder(
            builder: (context) {
              final outputWidget= Expanded(
                child: GenericStateWidget(
                  state:widget.state,
                  onSuccess:widget.onSuccess,
                  onErrorReload:widget.onErrorReload,
                  loadingShimmer:widget.loadingShimmer,
                  onRefresh:widget.onRefresh,
                  onError:widget.onError,
                  isEmptyCheck:widget.isEmptyCheck,
                  onEmpty:widget.onEmpty,

                ),
              );
              if(widget.wrapExpanded){
                return Expanded(child: outputWidget);
              }else{
                return outputWidget;
              }
            }
        ),
        if(widget.state.isPaginationLoading)
          const Center(
            child: CircularProgressIndicator(),
          ),
      ],
    );
  }

  @override
  void dispose() {
    widget.scrollController.removeListener(scrollListener);
    //Warning: Never dispose controller here, because it was not created here
    super.dispose();
  }
}
