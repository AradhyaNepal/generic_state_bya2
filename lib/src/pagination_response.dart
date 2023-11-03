import 'package:generic_state_bya2/src/page_response_setup.dart';

class PaginationResponse<T> {
  T data;
  bool haveNext;
  int pageIndex;

  PaginationResponse({
    required this.data,
    required Map response,
    required this.pageIndex,
  }) : haveNext = PageResponseSetup.haveNext(response,pageIndex);

  PaginationResponse.fromState({
    required this.data,
    required this.haveNext,
    required this.pageIndex,
  });

  static Map<String, dynamic> params(
    int pageIndex,
  ) {
    return  PageResponseSetup.params(pageIndex,PageResponseSetup.pageSize);
  }

  ///[oldPlusNew] is the data to be shown on pagination success which stores previous page data
  ///plus newly fetched page data.
  ///This data must be in order as per how to show in the UI, else newly added page data will be added on reverse order
  PaginationResponse oldPlusNew(T data) {
    return PaginationResponse.fromState(
      data: data,
      haveNext: haveNext,
      pageIndex: pageIndex,
    );
  }
}

