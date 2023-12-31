# generic_state_bya2
Generic State For any State Management. This package remove all the type casting hassle, and have
methods and classes to deal with API, Pagination Responses or your own UseCase.

## Note
GenericState is always different as per the project requirements and setups, 
so for full customization of this package, I recommend cloning the Github Repository
and editing as per your need. 
If you do so you can better customize LoadingIndicator, on error graphics, on no data graphics, and much more.

# Usage
## Controller
For Normal API request you can use something like this:

```
  Future<void> getValue({bool isRefresh = false}) async {
    await Future.delayed(Duration.zero);
    if (!isRefresh) {
      state = LoadingState();
    }
    try {
      final repositoryData = await repository.getData();
      state = SuccessState(repositoryData);
      //Or state= SuccessState.pagination(...) if its pagination type
    } catch (e, s) {
      if (state.showToastInError(isRefresh)) {
        showCustomToast(e.toString());
      } else {
        state = ErrorState(e, s);
      }
    }
  }
```
Or, for Pagination API request you can use like this:
```
  Future<void> fetchValue({
    bool isRefresh = false,
    bool isPagination = false,
  }) async {
    if (state.isPaginationLoading) return;
    await Future.delayed(Duration.zero);
    if (state.showLoading(isRefresh, isPagination)) {
      state = LoadingState();
    }
    try {
      if (isPagination) {
        state = state.copyToTogglePaginationLoading(true);
      }
      final repositoryData = await repository.getData(
        pageIndex: state.nextPage(isRefresh),
      );
      state = state.copyOfNextOrRefresh(
        response: repositoryData,
        isRefresh: isRefresh,
        oldPlusNewData: () => [
          ...?state.dataOrNull,
          ...repositoryData.data,
        ],
      );
    } catch (e, s) {
      if (state.showToastInError(isRefresh)) {
        showCustomToast(e.toString());
      } else {
        state = ErrorState(e, s);
      }
    }
  }
}
```
For this you need to set return type of repository data as [PaginationResponse](#PaginationResponse).
## Helper Methods
The best part about this generic state is that it comes with lots of helper methods which removes
the type casting hassle.

Most important usage of this would be getting the data of the generic state on some place on the UI.

In UI you need to get the value, sometime need to provide alternative value if the state is not
success or sometimes needs to map the value.
```
  final state = SuccessState(1);
  final data = state.dataOrNull;
  final data2 = state.dataOr(5);
  final data3 = state.dataInKOr<String>(
    onData: (data) => data.toString(),
    alternative: "NULL",
  );
  final data4 = state.when<int>(
    success: (state) => state.data * 2,
    error: (state) => state.error.hashCode,
    loading: () => 0,
  );
```
Above are the helper methods the package provides.
You can use this methods in scenarios like on username of app header. You might need to set the
Username on success but
when the state is loading or other you want to show user Loading... text. So you can do something
like this:
```
    Text(
      state.dataOrNull?.userName ?? "Loading...",
      style: TextStyle(
          fontSize: 16,
          color: Colors.black,
          fontWeight: FontWeight.bold,
      ),
    ),
        
```
Or you might set different value on success, and on error and on loading.
```   
    Text(
      state.when(
        success: (state) => state.data.fullName,
        error: (state) => "-",
        loading: () => "Loading...",
      ),
      style: TextStyle(
          fontSize: 16,
          color:  Colors.black,
          fontWeight: FontWeight.bold,
          ),
    ),
```
And finally it comes with state checker methods like:
``` 
  state.isLoading;
  state.isNotLoading;
  state.isSuccess;
  state.isNotSuccess;
  state.isError;
  state.isNotError;
```
Which can be used in situation like this:
``` 
  #1
  IgnorePointer(
        ignoring: state.isLoading,
        ...
  )
  
  #2
  Future<void> mayFetchOrUseCache() async {
    if (state.isNotSuccess) {
      await fetchTheData();
    }
  }
  
  #3
  if (state.isLoading) {
  return LinearProgressIndicator(
      ...
  );
} else {
  return SizedBox(
     ...
  );
} 
```
## GenericStateWidget and GenericStatePaginationWidget
GenericStateWidget and GenericStatePaginationWidget are really useful while dealing with api responses in the application.
This package handles all the complex use cases which a developer needs to consider while integrating api responses.
``` 
      GenericStateWidget(
        state: ref.watch(homeProvider),
        onSuccess: (state) => Column(
         ...
        ),
        onErrorReload: ()async {
          ref.read(homeProvider.notifier).loadData();
        },
        isEmptyCheck: (state) => state.data.isEmpty,
        onRefresh: ()async{
          await ref.read(homeProvider.notifier).loadData(isRefresh: true);
        },
        loadingShimmer: () => const HomeLoadingShimmer(),
      ),
```
And the most interesting part is the pagination, by this package you don't need to worry about the complexity of pagination.
This package deals with the listening of the scroll controller, 
calling the suitable method when we need to do pagination, and show the loading of pagination.
```
 final ScrollController scrollController = ScrollController();
 
  @override
  Widget build(BuildContext context) {
    final state = ref.watch(friendListProvider(widget.type));
    return GenericStatePaginationWidget(
      state: state,
      scrollController: scrollController,
      onRefresh: () async {
        await ref
            .read(friendListProvider(widget.type).notifier)
            .getFriends(ref, isRefresh: true);
      },
      isEmptyCheck: (state) => state.data.isEmpty,
      onSuccess: (state) {
        return ListView.builder(
          controller: scrollController,
          itemCount: state.data.length,
          itemBuilder: (context, index) {
            return IndividualFriendWidget(
              item: state.data[index],
            );
          },
        );
      },
      toFetchNextPage: () {
        ref
            .read(friendListProvider(widget.type).notifier)
            .getFriends(ref, isPagination: true);
      },
      onErrorReload: () async {
        ref
            .read(friendListProvider(widget.type).notifier)
            .getFriends(ref);
      },
      loadingShimmer: () => const FriendsLoadingShimmer(),
    );
  }
  
  @override
  void dispose() {
    scrollController.dispose();
    super.dispose();
  }
```
Just few things to remember are:
* Make sure you have passed ScrollController on the scrollable slice of the UI.
* Dispose the ScrollController. I repeat, Dispose the ScrollController. 
Not doing so will not cause any problem with the package or with the application. 
But it causes memory leaks, which a good programmer always handle.

Some time the GenericStateWidget or GenericStatePaginationWidget is inside CustomScrollView,
that means the parent is expecting child to be a Sliver not a normal RenderBox.

In this case you can pass isSliver: true, which is false by default.
```
   GenericStatePaginationWidget(
      isSliver: true,
      ...
   ),
```
Just few things to remember are:
* If isSliver is true, the code which you passed on onRefresh will never run. 
Because you need to handle onRefresh on parent class, CustomScrollView.
* Similarly, unlike normal pagination widget, loading indicator on bottom when next page is loading
will not work on isSliver is true, you have to manually set loading on the last item on the ListView.
``` 
    GenericStatePaginationWidget(
      onSuccess: (state) {
        return SliverList(
          delegate: SliverChildBuilderDelegate(
            (_, int index) {
              final bool showPaginationLoading =
                  state.isPaginationLoading && index == state.data.length - 1;
              return IndividualFriendWidget(
                item: state.data[index],
                showPaginationLoading: showPaginationLoading,
              );
            },
            childCount: state.data.length,
          ),
        );
      },
      ...
    ),
    
    //IndividualFriendWidget
    Column(
      children: [
        ...
        if(showPaginationLoading)
          const Center(child: CircularProgressIndicator(),),
      ],
    )
```
## PaginationResponse
Thanks to PaginationResponse, our package figures out whether the page have nextPage or not,
accordingly whether to load the next or not. And helps on lots of others setups required on pagination.
```
//Do the setup of PaginationResponse, mostly in main, if you don't do so below value will be used in default.
  PaginationResponseSetup.setup(
    haveNext: (response,pageNumber){
      return response["totalPages"] > pageNumber;
    },
    paramsMap: (pageIndex,pageSize){
      return {
        "pageIndex": pageIndex,
        "pageSize": pageSize,
      };
    },
    pageSize: 20,
  );
  
//Return PaginationReponse in your repository.
class FriendsRepository extends BaseRepository {
  Future<PaginationResponse<List<Friend>>> getFriendList(
      {required int pageIndex}) async {
    return await get<PaginationResponse<List<Friend>>>(
      RequestInput(
        url: ApiConstants.getAllFriends,
        params: PaginationResponse.params(pageIndex), <---------- Params the PaginationResponse class Provide
        body: null,
        parseJson: (response) {
          return PaginationResponse(  <-------- Returning PaginationResponse after API Fetching and Json Parsing
            data: (response["data"] as List)
                .map((e) => Friend.fromJson(e))
                .toList(),
            response: response,
            pageIndex: pageIndex,
          );
        },
      ),
    );
  }
  
  //And use it like this
  final response=await FriendsRepository().getFriendList(pageIndex:1);
  responseData.data;
  responseData.haveNext;
  responseData.pageIndex;
  responseData.oldPlusNew([
    ...?state.dataOrNull, <---- Old Data
    ...responseData.data, <---- New Data
  ]);
  //And on controller emit state like this for pagination
   emit(SuccessState.pagination(...)); //BLOC
   state=SuccessState.pagination(...); //Riverpod
}
```
You can go to the top section to see how to use PaginationResponse on [Controller](#Controller).