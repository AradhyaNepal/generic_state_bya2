typedef HaveNextType = bool Function(Map response, int pageIndex);
typedef ParamsType = Map<String, dynamic> Function(
    int pageIndex, int pageSize);

class PageResponseSetup {
  static HaveNextType _haveNext = (response, pageIndex) {
    return response["totalPages"] > pageIndex;
  };
  static ParamsType _params = (pageIndex, pageSize) {
    return {
      "pageIndex": pageIndex,
      "pageSize": PageResponseSetup.pageSize,
    };
  };

  static int _pageSize = 20;

  static HaveNextType get haveNext => _haveNext;

  static ParamsType get params => _params;

  static int get pageSize => _pageSize;

  static void setup({
    required HaveNextType? haveNext,
    required ParamsType? paramsMap,
    required int? pageSize,
  }) {
    PageResponseSetup._haveNext = haveNext??_haveNext;
    PageResponseSetup._params = paramsMap??_params;
    PageResponseSetup._pageSize = pageSize??_pageSize;
  }
}
