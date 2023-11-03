import 'package:generic_state_bya2/src/page_response_setup.dart';

class PageResponse<T> {
  T data;
  bool haveNext;
  int pageIndex;

  PageResponse({
    required this.data,
    required Map response,
    required this.pageIndex,
  }) : haveNext = PageResponseSetup.haveNext(response,pageIndex);

  PageResponse.fromState({
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
  PageResponse oldPlusNew(T data) {
    return PageResponse.fromState(
      data: data,
      haveNext: haveNext,
      pageIndex: pageIndex,
    );
  }
}

