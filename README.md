# generic_state_bya2

* This package is still on development phase with lots of testing still pending to be done
  Documentation coming soon

Generic State For any State Management. This package remove all the type casting hassle, and have
methods and classes to deal with API, Pagination Responses or your own UseCase.

## Note

For full customization of this package, I recommend cloning the Github Repository and editing as per
your need.
Because Generic State is always different as per the project requirements and setups.

## Usage

### Controller

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
For this you need to set return type of repository data as PaginationResponse.

### Helper Methods

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
      style: textTheme.displaySmall?.copyWith(
          color: ColorConstant.blackTextColor,
          fontWeight: FontWeight.bold),
    ),
        
```
Or you might set different value on success, and on error and or loading.
```   
    Text(
      state.when(
        success: (state) => state.data.fullName,
        error: (state) => "-",
        loading: () => "Loading...",
      ),
      style: textTheme.displaySmall?.copyWith(
          color: ColorConstant.blackTextColor,
          fontWeight: FontWeight.bold),
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

### GenericStateWidget and GenericStatePaginationWidget


