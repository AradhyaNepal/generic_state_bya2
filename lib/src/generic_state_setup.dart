import 'package:flutter/material.dart';

typedef WidgetReturnFunction = Widget Function();

class GenericStateSetup {
  static WidgetReturnFunction _onEmpty = () => const Text(
        "No Result",
        style: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.bold,
        ),
      );

  static WidgetReturnFunction get onEmpty => _onEmpty;

  static WidgetReturnFunction _onError = () => const Center(
        child: Icon(
          Icons.error,
        ),
      );

  static WidgetReturnFunction get onError => _onError;

  static void init({
    required WidgetReturnFunction onEmpty,
    required WidgetReturnFunction onError,
  }) {
    _onError = onError;
    _onEmpty = onEmpty;
  }
}
