import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sd_kids/main.dart';
import 'package:sd_kids/models/FoodDeal.dart';
import 'package:sd_kids/screens/shared/SharedWidgets.dart';
import '../../models/FirebaseResponse.dart';
import '../../util/constants.dart' as Constants;
import '../../viewModel/FoodDealListViewModel.dart';

class FoodDealsListScreen extends StatefulWidget {
  final GlobalKey<NavigatorState> navKey;
  final Function() appBarChange;

  const FoodDealsListScreen(
      {super.key, required this.appBarChange, required this.navKey});

  @override
  State<FoodDealsListScreen> createState() => _FoodDealsListScreenState();
}

class _FoodDealsListScreenState extends State<FoodDealsListScreen> {
  List<String> daysOfWeek = [
    'Sunday',
    'Monday',
    'Tuesday',
    'Wednesday',
    'Thursday',
    'Friday',
    'Saturday'
  ];
  final List<String> _items = ['Age Limit', 'Up Votes'];
  bool isSortingMenuVisible = false;
  double _sortMenuHeight = 0;
  List<FoodDeal> foodDealsAllDays = [];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        context.read<FoodDealListViewModel>().clearData();
        context.read<FoodDealListViewModel>().getFoodDeals();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<FoodDealListViewModel>(
        builder: (context, viewModel, child) {
      switch (viewModel.response.status) {
        case Status.LOADING:
          return const Center(
              child: CircularProgressIndicator(
            color: Colors.blue,
          ));
        case Status.COMPLETED:
          foodDealsAllDays =
              viewModel.response.data as List<FoodDeal>;
          return Padding(
              padding: const EdgeInsets.fromLTRB(10, 10, 10, 80),
              child: Column(children: [
                SharedWidgets.screenTitle('Food Deals'),
                SharedWidgets.SortMenu(_items, _sortMenuHeight, isSortingMenuVisible, onOpenClose, onReorder),
                SizedBox(
                  height: 10,
                ),
                Expanded(
                    child: SingleChildScrollView(
                        child: ListView.builder(
                            shrinkWrap: true,
                            physics: const ClampingScrollPhysics(),
                            padding: const EdgeInsets.symmetric(
                                vertical: 8, horizontal: 4),
                            itemCount: daysOfWeek.length,
                            itemBuilder: (BuildContext context, int index) {
                              return foodDealsByDayOfWeek(
                                viewModel,
                                  daysOfWeek[index],
                                  foodDealsAllDays
                                      .where((foodDeal) =>
                                      foodDeal.daysOfWeek.contains(daysOfWeek[index]))
                                      .toList(),
                                  );
                            })))
              ]));
        case Status.ERROR:
          return const Center(
            child: Text('Please try again later!!!'),
          );
        case Status.INITIAL:
        default:
          return const Center(
            child: Text('loading'),
          );
      }
    });
  }


  Future<double> get _height => Future<double>.value(Constants.isMobile
      ? Constants.itemAnimatedContainerShortHeightMobile - 25
      : Constants.itemAnimatedContainerShortHeightTablet - 25);

  Widget foodDealsByDayOfWeek(FoodDealListViewModel viewModel, String dayOfWeek,
      List<FoodDeal> foodDeals) {
    return FutureBuilder<double>(
        future: _height,
        initialData: 0.0,
        builder: (context, snapshot) {
          return AnimatedContainer(
              padding: EdgeInsets.symmetric(vertical: 5),
              curve: Curves.elasticOut,
              height: snapshot.data!,
              duration: Duration(milliseconds: 2000),
              child: Column(children: [
                SharedWidgets.categoryTitleWidget(dayOfWeek),
                Container(
                    height: Constants.isMobile
                        ? Constants.itemContainerHeightShortMobile - 20
                        : Constants.itemContainerHeightShortTablet - 19,
                    child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        shrinkWrap: true,
                        physics: const ClampingScrollPhysics(),
                        itemCount: foodDeals.length,
                        itemBuilder: (BuildContext context, int index) {
                          return InkWell(
                              onTap: () {
                                print('navigating to food deal detail');
                                widget.appBarChange();
                                widget.navKey.currentState!.pushNamed(
                                    NavRoutes.foodDealDetailsRoute,
                                    arguments: {
                                      'food_deal': foodDeals[index],
                                      'dayOfWeek': dayOfWeek,
                                      'index': index
                                    });
                              },
                              child: FoodDealListItemWidget(context, viewModel,
                                  foodDeals[index], dayOfWeek, index));
                        }))
              ]));
        });
  }

  Widget FoodDealListItemWidget(
      BuildContext context,
      FoodDealListViewModel viewModel,
      FoodDeal foodDeal,
      String dayOfWeek,
      int index) {
    return Container(
        width: Constants.isMobile
            ? Constants.itemCardWidthMobile
            : Constants.itemCardWidthTablet,
        child: Card(
            color: Constants.cardBgColors[daysOfWeek.indexOf(dayOfWeek)],
            child: Padding(
                padding:
                    const EdgeInsets.symmetric(vertical: 5, horizontal: 10),
                child: Column(
                    children: [
                      SharedWidgets.itemTitleWidget(foodDeal.name),
                      Hero(
                        tag: 'food_deal_image$dayOfWeek$index',
                        child: SharedWidgets.networkImageWithLoading(
                            foodDeal.imageUrl),
                      ),
                      SizedBox(height: 8,),
                      SharedWidgets.itemDescriptionWidget(foodDeal.description),
                      const Spacer(),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          ageLimitTextWidget(foodDeal.ageLimit),
                          likeDislikeWidget(foodDeal, viewModel)
                        ],
                      )
                    ]))));
  }
  
  Widget likeDislikeWidget(FoodDeal foodDeal, FoodDealListViewModel viewModel){
    return Wrap(
      crossAxisAlignment: WrapCrossAlignment.end,
      children: [
        Padding(
            padding: EdgeInsets.fromLTRB(0, 0, 8, 0),
            child: InkWell(
                onTap: () {
                  if (foodDeal.upVotes
                      .contains(Constants.myFcmToken)) {
                    foodDeal.upVotes
                        .remove(Constants.myFcmToken);
                    viewModel.upVoteFoodDeal(foodDeal,
                        Constants.myFcmToken, true);
                    viewModel.downVoteFoodDeal(foodDeal,
                        Constants.myFcmToken, false);
                    setState(() {
                      foodDeal.upVotes
                          .remove(Constants.myFcmToken);
                      foodDeal.downVotes
                          .add(Constants.myFcmToken);
                    });
                  } else if (foodDeal.downVotes
                      .contains(Constants.myFcmToken)) {
                    viewModel.downVoteFoodDeal(foodDeal,
                        Constants.myFcmToken, true);
                    setState(() {
                      foodDeal.downVotes
                          .remove(Constants.myFcmToken);
                    });
                  } else {
                    viewModel.downVoteFoodDeal(foodDeal,
                        Constants.myFcmToken, false);
                    setState(() {
                      foodDeal.downVotes
                          .add(Constants.myFcmToken);
                    });
                  }
                },
                child: Wrap(
                  crossAxisAlignment:
                  WrapCrossAlignment.center,
                  children: [
                    Text(
                      foodDeal.downVotes.length
                          .toString() +
                          ' ',
                      style: TextStyle(
                        color: foodDeal.downVotes
                            .contains(Constants
                            .myFcmToken)
                            ? Colors.blue
                            : Colors.white,
                        fontSize: Constants.isMobile
                            ? Constants
                            .itemFooterFontSizeMobile
                            : Constants
                            .itemFooterFontSizeTablet,
                      ),
                    ),
                    Icon(
                      Icons.thumb_down_sharp,
                      size: Constants.iconSizeMobile,
                      color: foodDeal.downVotes.contains(
                          Constants.myFcmToken)
                          ? Colors.blue
                          : Colors.white,
                    ),
                  ],
                ))),
        Padding(
            padding: EdgeInsets.fromLTRB(8, 0, 0, 0),
            child: InkWell(
                onTap: () {
                  if (foodDeal.downVotes
                      .contains(Constants.myFcmToken)) {
                    foodDeal.downVotes
                        .remove(Constants.myFcmToken);
                    viewModel.downVoteFoodDeal(foodDeal,
                        Constants.myFcmToken, true);
                    viewModel.upVoteFoodDeal(foodDeal,
                        Constants.myFcmToken, false);
                    setState(() {
                      foodDeal.downVotes
                          .remove(Constants.myFcmToken);
                      foodDeal.upVotes
                          .add(Constants.myFcmToken);
                    });
                  } else if (foodDeal.upVotes
                      .contains(Constants.myFcmToken)) {
                    viewModel.upVoteFoodDeal(foodDeal,
                        Constants.myFcmToken, true);
                    setState(() {
                      foodDeal.upVotes
                          .remove(Constants.myFcmToken);
                    });
                  } else {
                    viewModel.upVoteFoodDeal(foodDeal,
                        Constants.myFcmToken, false);
                    setState(() {
                      foodDeal.upVotes
                          .add(Constants.myFcmToken);
                    });
                  }
                },
                child: Wrap(
                  crossAxisAlignment:
                  WrapCrossAlignment.center,
                  children: [
                    Icon(
                      Icons.thumb_up_sharp,
                      size: Constants.iconSizeMobile,
                      color: foodDeal.upVotes.contains(
                          Constants.myFcmToken)
                          ? Colors.blue
                          : Colors.white,
                    ),
                    Text(
                      ' ' +
                          foodDeal.upVotes.length
                              .toString(),
                      style: TextStyle(
                        color: foodDeal.upVotes.contains(
                            Constants.myFcmToken)
                            ? Colors.blue
                            : Colors.white,
                        fontSize: Constants.isMobile
                            ? Constants
                            .itemFooterFontSizeMobile
                            : Constants
                            .itemFooterFontSizeTablet,
                      ),
                    ),
                  ],
                )))
      ],
    );
  }
  
  Widget ageLimitTextWidget(int ageLimit){
    return                           Text(
      'Age Limit: $ageLimit',
      style: TextStyle(
        color: Colors.white,
        fontSize: Constants.isMobile
            ? Constants.itemFooterFontSizeMobile
            : Constants.itemFooterFontSizeTablet,
      ),
    );
  }


  void onOpenClose(){
    setState(() {
      isSortingMenuVisible =
      !isSortingMenuVisible;
      if (isSortingMenuVisible) {
        _sortMenuHeight =
        Constants.isMobile
            ? 80
            : 96;
      } else {
        _sortMenuHeight = 0;
      }
    });
  }

  void onReorder(int oldIndex, int newIndex){
    setState(() {
      if (oldIndex < newIndex) {
        newIndex -= 1;
      }
      final String item =
      _items.removeAt(oldIndex);
      _items.insert(newIndex, item);

      if (_items[0] == 'Age Limit' &&
          _items[1] == 'Up Votes') {
        foodDealsAllDays.sort((a, b) {
          int cmp =
          a.ageLimit.compareTo(b.ageLimit);
          if (cmp != 0) return cmp;
          return b.upVotes.length
              .compareTo(a.upVotes.length);
        });
      } else {
        foodDealsAllDays.sort((a, b) {
          int cmp = b.upVotes.length
              .compareTo(a.upVotes.length);
          if (cmp != 0) return cmp;
          return a.ageLimit.compareTo(b.ageLimit);
        });
      }
    });
  }
}
