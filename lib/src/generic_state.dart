

import 'package:flutter/material.dart';

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

  ///State is either [LoadingState] or [InitialState]
  bool get isOnlyLoading {
    return this is LoadingState;
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

  K map<K>(
      {required K Function(SuccessState) onSuccess,
        required K Function(ErrorState) onError,
        required K Function() onLoading}) {
    final state = this;
    return switch (state) {
      SuccessState() => onSuccess(state),
      ErrorState() => onError(state),
      _ => onLoading(),
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
    return successStateOrNull?.serverPageIndex ?? 0;
  }

  /// For [SuccessState] returns nextPage count.
  /// Else for any other state, returns 1
  int get nextPage => currentPage + 1;

  /// For [SuccessState] returns whether have next page.
  /// Else for any other state, returns false
  bool get haveNextPage {
    return successStateOrNull?.serverHaveNext ?? false;
  }

  /// For [SuccessState] returns whether pagination loading.
  /// Else for any other state, returns false
  bool get isPaginationLoading {
    return successStateOrNull?.serverPaginationLoading ?? false;
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

  SuccessState<T> setupNextPage({
    required T data,
    required bool haveNext,
  }) {
    return SuccessState<T>.pagination(
      data,
      serverPageIndex: nextPage,
      serverHaveNext: haveNext,
      serverPaginationLoading: false,
    );
  }
}

class InitialState<T> extends GenericState<T> {}

class ErrorState<T> extends GenericState<T> {
  T? cacheData;
  final Object error;
  final Object? stackTrace;

  ErrorState(this.error, this.stackTrace, {this.cacheData});
}

class LoadingState<T> extends GenericState<T> {
  T? cacheData;

  LoadingState({this.cacheData});
}

class SuccessState<T> extends GenericState<T> {
  T data;

  //Note: Server is used so that developer don't get confused when they are editing GenericState's helper methods
  int serverPageIndex;
  bool serverHaveNext;
  bool serverPaginationLoading;

  SuccessState(this.data)
      : serverPageIndex = 1,
        serverHaveNext = false,
        serverPaginationLoading = false;

  SuccessState.pagination(
      this.data, {
        required this.serverPageIndex,
        required this.serverHaveNext,
        this.serverPaginationLoading = false,
      });
}
