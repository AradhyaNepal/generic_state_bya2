import 'package:flutter/material.dart';
import 'package:generic_state_bya2/generic.dart';

typedef WidgetReturnFunction = Widget Function();
typedef WidgetReturnCallBackInputFunction = Widget Function(
    VoidCallback onErrorReload);
typedef WidgetReturnStringInputFunction = Widget Function(Object value);

class GenericStateSetup {
  static WidgetReturnFunction _onEmpty = () => const Text(
        "No Result",
        style: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.bold,
        ),
      );

  static WidgetReturnFunction _onLoading =
      () => const CircularProgressIndicator();
  static WidgetReturnCallBackInputFunction _onErrorReloadButton =
      (onErrorReload) => Center(
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
      );

  static WidgetReturnStringInputFunction _errorMessage = (error) => Text(
        error.toString(),
    textAlign: TextAlign.center,
    style: TextStyle(
      fontSize: 18,
      color: Colors.grey.shade500,
      fontWeight: FontWeight.w500,
    ),
      );

  static WidgetReturnStringInputFunction get errorMessage => _errorMessage;

  static WidgetReturnFunction get onEmpty => _onEmpty;

  static WidgetReturnCallBackInputFunction get onErrorReloadButton =>
      _onErrorReloadButton;

  static WidgetReturnFunction get onLoading => _onLoading;

  static WidgetReturnFunction _onErrorIcon = () => const Center(
        child: Icon(
          Icons.error,
        ),
      );

  static WidgetReturnFunction get onErrorIcon => _onErrorIcon;

  static void init({
    required WidgetReturnFunction? onEmpty,
    required WidgetReturnFunction? onError,
    required WidgetReturnFunction? onLoading,
    required WidgetReturnCallBackInputFunction? onErrorReloadButton,
    required WidgetReturnStringInputFunction? errorMessage,
  }) {
    _onErrorIcon = onError ?? _onEmpty;
    _onEmpty = onEmpty ?? _onEmpty;
    _onLoading = onLoading ?? _onLoading;
    _onErrorReloadButton = onErrorReloadButton ?? _onErrorReloadButton;
    _errorMessage = errorMessage ?? _errorMessage;
  }
}
