import 'dart:developer';

import 'package:flutter/material.dart';
import 'pagination_response.dart';

sealed class GenericState<T> {
  ///State is either [SuccessState]
  bool get isSuccess {
    return this is SuccessState;
  }

  bool get isError {
    return this is ErrorState;
  }

  ///State is either [LoadingState] or [InitialState]
  bool get isLoading {
    return this is InitialState || this is LoadingState;
  }

  ///State is only [LoadingState]
  bool get isOnlyLoading {
    return this is LoadingState;
  }

  ///State is only [InitialState]
  bool get isOnlyInitial {
    return this is InitialState;
  }

  void listenAndReact({
    required void Function(
      T success,
    ) onSuccess,
    required void Function(
        Object error,
        ) onError,
  }) {
    final state=this;
      switch(state){
        case SuccessState():
         onSuccess(state.data);
          break;
        case ErrorState():
          onError(state.error);
          break;
        default:
          break;
      }

  }

  ///State is not [SuccessState]
  bool get isNotSuccess => !isSuccess;

  ///State not [ErrorState]
  bool get isNotError => !isError;

  ///State is neither [LoadingState] nor [InitialState]
  bool get isNotLoading => !isLoading;

  ///If [SuccessState] returns its data,
  ///If [LoadingState] or [ErrorState] returns data if there is some [cacheData] saved,
  ///Else return null
  T? get dataOrNull {
    final state = this;
    return switch (state) {
      InitialState() => null,
      SuccessState() => state.data,
      ErrorState() => state.cacheData,
      LoadingState() => state.cacheData,
    };
  }

  ///If [ErrorState] or null
  ErrorState? get errorOrNull {
    final state = this;
    return switch (state) {
      InitialState() => null,
      SuccessState() => null,
      ErrorState() => state,
      LoadingState() => null,
    };
  }

  ///If [SuccessState] returns actual data,
  ///If [LoadingState] or [ErrorState] returns actual data if there is some [cacheData] saved,
  ///Else return [alternative]
  T dataOr(T alternative) {
    return dataOrNull ?? alternative;
  }

  ///If [SuccessState] returns output of [dataMap],
  ///If [LoadingState] or [ErrorState] returns output of [dataMap] if there is some [cacheData] saved,
  ///Else return [alternative]
  K dataInKOr<K>({
    required K Function(T) onData,
    required K alternative,
  }) {
    final data = dataOrNull;
    if (data != null) {
      return onData(data);
    } else {
      return alternative;
    }
  }

  K when<K>(
      {required K Function(T) success,
      required K Function(Object) error,
      required K Function() loading}) {
    final state = this;
    return switch (state) {
      SuccessState() => success(state.data),
      ErrorState() => error(state.error),
      _ => loading(),
    };
  }

  SuccessState<T>? get successStateOrNull {
    final state = this;
    if (state case SuccessState()) {
      return state;
    } else {
      return null;
    }
  }

  /// Returns currentPage of [SuccessState].
  /// In any other state, returns 0
  int get currentPage {
    return successStateOrNull?._pageIndex ?? 0;
  }

  /// For [SuccessState] returns nextPage count.
  /// If is for refresh returns 1
  /// Else for any other state, returns 1
  int nextPage(bool isRefresh) => isRefresh ? 1 : currentPage + 1;

  /// For [SuccessState] returns whether have next page.
  /// Else for any other state, returns false
  bool get haveNextPage {
    return successStateOrNull?._haveNext ?? false;
  }

  /// For [SuccessState] returns whether pagination loading.
  /// Else for any other state, returns false
  /// When pagination is loading:
  ///   * loading indicator must be shown on the below of ScrollView
  ///   * addListener of [ScrollController] must not call the controller to fetch next page
  ///   * Controller must make sure that from UI unnecessary next page request have not been request
  bool get isPaginationLoading {
    return successStateOrNull?._paginationLoading ?? false;
  }

  /// In order to do pagination:
  /// * There must be next page, which only happens in [SuccessState]
  /// * Pagination must not be already loading
  /// * The current scroll must exceed the range from where the pagination should start
  bool canDoPagination(ScrollController scrollController) {
    if (!haveNextPage) return false;
    if (isPaginationLoading) return false;
    return scrollController.position.pixels >=
        scrollController.position.maxScrollExtent * 0.9;
  }

  //Todo: Document
  //Todo: Assert that both is not true
  bool showLoading(bool isRefresh, bool isPagination) =>
      !isRefresh && !isPagination;

  bool showToastInError(bool isRefresh) {
    return (isRefresh && isSuccess) || isPaginationLoading;
  }

  //Below are Copies Methods to update the State

  ///On [SuccessState] returns another [SuccessState] instance where pagination loading is true
  ///On any other state, does nothing and returns the same state as it is.
  GenericState<T> copyToTogglePaginationLoading(bool value) {
    final state = this;
    if (state case SuccessState()) {
      return SuccessState.pagination(
        response: state._response,
        paginationLoading: value,
      );
    } else {
      return state;
    }
  }

  ///If its for refresh, returns [SuccessState.pagination(response: response)], i.e new page
  ///If not it returns [_copyOfNextPage].
  ///[oldPlusNewData] is the data to be shown on pagination success which stores previous page data
  ///plus newly fetched page data.
  ///This data must be in order as per how to show in the UI, else newly added page data will be added on reverse order
  GenericState<T> copyOfNextOrRefresh({
    required PaginationResponse<T> response,
    required bool isRefresh,
    required T Function() oldPlusNewData,
  }) {
    if (isRefresh) {
      return SuccessState<T>.pagination(
        response: response,
      );
    } else {
      return this._copyOfNextPage(
        response: response.oldPlusNew(
          oldPlusNewData(),
        ),
      );
    }
  }

  ///On [SuccessState], increases the page number.
  ///On other state returns the first Pagination page.

  SuccessState<T> _copyOfNextPage({
    required PaginationResponse response,
    bool paginationLoading = false,
  }) {
    return SuccessState<T>.pagination(
      response: response,
      paginationLoading: paginationLoading,
    );
  }
}

class InitialState<T> extends GenericState<T> {}

class ErrorState<T> extends GenericState<T> {
  final T? _cacheData;

  T? get cacheData => _cacheData;
  final Object error;
  final Object? stackTrace;

  ErrorState(this.error, this.stackTrace, {T? cacheData})
      : _cacheData = cacheData{
    log(error.toString());
    log(stackTrace.toString());
  }
}

class LoadingState<T> extends GenericState<T> {
  final T? _cacheData;

  T? get cacheData => _cacheData;

  LoadingState({T? cacheData}) : _cacheData = cacheData;
}

class SuccessState<T> extends GenericState<T> {
  T get data => _data;

  final T _data;
  final int _pageIndex;
  final bool _haveNext;
  final bool _paginationLoading;

  PaginationResponse<T> get _response => PaginationResponse.fromState(
        data: _data,
        haveNext: _haveNext,
        pageIndex: _pageIndex,
      );

  SuccessState(this._data)
      : _pageIndex = 1,
        _haveNext = false,
        _paginationLoading = false;

  SuccessState.pagination({
    required PaginationResponse response,
    bool paginationLoading = false,
  })  : _paginationLoading = paginationLoading,
        _data = response.data,
        _haveNext = response.haveNext,
        _pageIndex = response.pageIndex;
}
