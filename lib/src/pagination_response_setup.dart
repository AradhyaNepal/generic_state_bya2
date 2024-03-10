typedef HaveNextType = bool Function(Map response, int pageNumber);
typedef ParamsType = Map<String, dynamic> Function(
    int pageIndex, int pageSize);

class PaginationResponseSetup {
  static HaveNextType _haveNext = (response, pageNumber) {
    return response["data"]["totalPages"] > pageNumber;
  };
  static ParamsType _params = (pageNumber, pageSize) {
    return {
      "page": pageNumber,
      "pageSize": pageSize,
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
    PaginationResponseSetup._haveNext = haveNext??_haveNext;
    PaginationResponseSetup._params = paramsMap??_params;
    PaginationResponseSetup._pageSize = pageSize??_pageSize;
  }
}
