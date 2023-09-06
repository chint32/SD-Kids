import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sd_kids/main.dart';
import 'package:sd_kids/models/FoodDeal.dart';
import 'package:sd_kids/screens/shared/SharedWidgets.dart';
import '../../models/FirebaseResponse.dart';
import '../../util/constants.dart';
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

  @override
  void initState() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        context.read<FoodDealListViewModel>().clearData();
        context.read<FoodDealListViewModel>().getFoodDeals();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    print('Food Deal List Screen');

    return Consumer<FoodDealListViewModel>(
        builder: (context, viewModel, child) {
      switch (viewModel.response.status) {
        case Status.LOADING:
          return const Center(
              child: CircularProgressIndicator(
            color: Colors.blue,
          ));
        case Status.COMPLETED:
          List<FoodDeal> foodDealsAllDays =
              viewModel.response.data as List<FoodDeal>;
          return Padding(
              padding: const EdgeInsets.fromLTRB(10, 10, 10, 80),
              child: Column(children: [
                Text(
                  'Food Deals',
                  style: TextStyle(
                      fontSize: MyConstants.isMobile
                          ? MyConstants.screenTitleFontSizeMobile
                          : MyConstants.screenTitleFontSizeTablet,
                      fontFamily: 'Jost',
                      fontWeight: FontWeight.bold),
                ),
                Card(
                    color: Colors.white70,
                    child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: Column(
                          children: [
                            Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    'Sort by',
                                    style: TextStyle(
                                        fontSize: MyConstants.isMobile
                                            ? MyConstants.sortMenuFontSizeMobile
                                            : MyConstants.sortMenuFontSizeTablet,
                                        fontFamily: 'Jost'),
                                  ),
                                  RotatedBox(
                                      quarterTurns:
                                          isSortingMenuVisible ? 2 : 0,
                                      child: IconButton(
                                        icon: Icon(
                                          Icons.arrow_drop_down,
                                          size: MyConstants.isMobile
                                              ? MyConstants.iconSizeMobile
                                              : MyConstants.iconSizeTablet,
                                        ),
                                        onPressed: () {
                                          setState(() {
                                            isSortingMenuVisible =
                                                !isSortingMenuVisible;
                                            if (isSortingMenuVisible) {
                                              _sortMenuHeight =
                                                  MyConstants.isMobile
                                                      ? 80
                                                      : 96;
                                            } else {
                                              _sortMenuHeight = 0;
                                            }
                                          });
                                        },
                                      )),
                                ]),
                            if (isSortingMenuVisible)
                              Padding(
                                  padding: EdgeInsets.fromLTRB(0, 0, 0, 10),
                                  child: Divider(
                                    height: 2,
                                  )),
                            AnimatedContainer(
                              curve: Curves.linearToEaseOut,
                              duration: Duration(milliseconds: 500),
                              height: _sortMenuHeight,
                              child: ReorderableListView(
                                children: <Widget>[
                                  for (int index = 0;
                                      index < _items.length;
                                      index += 1)
                                    Column(
                                      key: Key('$index'),
                                      children: [
                                        Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceBetween,
                                            children: [
                                              Text(
                                                _items[index],
                                                style: TextStyle(
                                                    fontSize: MyConstants.isMobile
                                                        ? MyConstants.sortMenuFontSizeMobile
                                                        : MyConstants.sortMenuFontSizeTablet,
                                                    fontFamily: 'Jost'),
                                              ),
                                              ReorderableDragStartListener(
                                                  key: ValueKey<String>(
                                                      _items[index]),
                                                  index: index,
                                                  child: Padding(
                                                    padding:
                                                        EdgeInsets.fromLTRB(
                                                            0, 0, 10, 0),
                                                    child: Icon(
                                                      Icons.drag_handle,
                                                      size: MyConstants.isMobile
                                                          ? MyConstants.iconSizeMobile
                                                          : MyConstants.iconSizeTablet,
                                                    ),
                                                  )),
                                            ]),
                                        SizedBox(
                                          height: 10,
                                        )
                                      ],
                                    )
                                ],
                                onReorder: (int oldIndex, int newIndex) {
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
                                },
                              ),
                            )
                          ],
                        ))),
                SizedBox(
                  height: 10,
                ),
                Expanded(
                    child: SingleChildScrollView(
                        child: Column(children: <Widget>[
                  for (var dayOfWeek in daysOfWeek)
                    foodDealsByDayOfWeek(
                        viewModel,
                        dayOfWeek,
                        foodDealsAllDays
                            .where((foodDeal) =>
                                foodDeal.daysOfWeek.contains(dayOfWeek))
                            .toList())
                ])))
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

  Future<double> get _height => Future<double>.value(MyConstants.isMobile
  ? MyConstants.itemAnimatedContainerShortHeightMobile
  : MyConstants.itemAnimatedContainerShortHeightTablet);

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
                Container(
                    width: double.infinity,
                    child: Padding(
                        padding:
                            EdgeInsets.symmetric(vertical: 0, horizontal: 3),
                        child: Text(dayOfWeek,
                            textAlign: TextAlign.start,
                            style: TextStyle(
                                fontSize: MyConstants.isMobile
                                    ? MyConstants.itemTitleFontSizeMobile
                                    : MyConstants.itemTitleFontSizeTablet,
                                fontWeight: FontWeight.bold)))),
                Container(
                    height: MyConstants.isMobile
                        ? MyConstants.itemContainerHeightShortMobile
                        : MyConstants.itemContainerHeightShortTablet,
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
        width: MyConstants.isMobile
            ? MyConstants.itemCardWidthMobile
            : MyConstants.itemCardWidthTablet,
        child: Card(
            color: MyConstants.cardBgColors[daysOfWeek.indexOf(dayOfWeek)],
            child: Padding(
                padding:
                    const EdgeInsets.symmetric(vertical: 5, horizontal: 10),
                child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Wrap(
                        children: [
                          Text(
                            foodDeal.name,
                            style: TextStyle(
                                color: Colors.white,
                                fontSize: MyConstants.isMobile
                                    ? MyConstants.itemTitleFontSizeMobile
                                    : MyConstants.itemTitleFontSizeTablet,
                                fontWeight: FontWeight.bold),
                          ),
                          Hero(
                            tag: 'food_deal_image$dayOfWeek$index',
                            child: SharedWidgets.networkImageWithLoading(
                                foodDeal.imageUrl),
                          ),
                          const SizedBox(
                            height: 8,
                          ),
                          Text(
                            foodDeal.description,
                            maxLines: 4,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                                color: Colors.white,
                                fontSize: MyConstants.isMobile
                                    ? MyConstants.itemDescriptionFontSizeMobile
                                    : MyConstants.itemDescriptionFontSizeTablet,
                                fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Age Limit: ${foodDeal.ageLimit}',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: MyConstants.isMobile
                                  ? MyConstants.itemFooterFontSizeMobile
                                  : MyConstants.itemFooterFontSizeTablet,
                            ),
                          ),
                          Wrap(
                            crossAxisAlignment: WrapCrossAlignment.end,
                            children: [
                              Padding(
                                  padding: EdgeInsets.fromLTRB(0, 0, 8, 0),
                                  child: InkWell(
                                      onTap: () {
                                        if (foodDeal.upVotes
                                            .contains(MyConstants.myFcmToken)) {
                                          foodDeal.upVotes
                                              .remove(MyConstants.myFcmToken);
                                          viewModel.upVoteFoodDeal(foodDeal,
                                              MyConstants.myFcmToken, true);
                                          viewModel.downVoteFoodDeal(foodDeal,
                                              MyConstants.myFcmToken, false);
                                          setState(() {
                                            foodDeal.upVotes
                                                .remove(MyConstants.myFcmToken);
                                            foodDeal.downVotes
                                                .add(MyConstants.myFcmToken);
                                          });
                                        } else if (foodDeal.downVotes
                                            .contains(MyConstants.myFcmToken)) {
                                          viewModel.downVoteFoodDeal(foodDeal,
                                              MyConstants.myFcmToken, true);
                                          setState(() {
                                            foodDeal.downVotes
                                                .remove(MyConstants.myFcmToken);
                                          });
                                        } else {
                                          viewModel.downVoteFoodDeal(foodDeal,
                                              MyConstants.myFcmToken, false);
                                          setState(() {
                                            foodDeal.downVotes
                                                .add(MyConstants.myFcmToken);
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
                                                      .contains(MyConstants
                                                          .myFcmToken)
                                                  ? Colors.blue
                                                  : Colors.white,
                                              fontSize: MyConstants.isMobile
                                                  ? MyConstants
                                                      .itemFooterFontSizeMobile
                                                  : MyConstants
                                                      .itemFooterFontSizeTablet,
                                            ),
                                          ),
                                          Icon(
                                            Icons.thumb_down_sharp,
                                            size: MyConstants.iconSizeMobile,
                                            color: foodDeal.downVotes.contains(
                                                    MyConstants.myFcmToken)
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
                                            .contains(MyConstants.myFcmToken)) {
                                          foodDeal.downVotes
                                              .remove(MyConstants.myFcmToken);
                                          viewModel.downVoteFoodDeal(foodDeal,
                                              MyConstants.myFcmToken, true);
                                          viewModel.upVoteFoodDeal(foodDeal,
                                              MyConstants.myFcmToken, false);
                                          setState(() {
                                            foodDeal.downVotes
                                                .remove(MyConstants.myFcmToken);
                                            foodDeal.upVotes
                                                .add(MyConstants.myFcmToken);
                                          });
                                        } else if (foodDeal.upVotes
                                            .contains(MyConstants.myFcmToken)) {
                                          viewModel.upVoteFoodDeal(foodDeal,
                                              MyConstants.myFcmToken, true);
                                          setState(() {
                                            foodDeal.upVotes
                                                .remove(MyConstants.myFcmToken);
                                          });
                                        } else {
                                          viewModel.upVoteFoodDeal(foodDeal,
                                              MyConstants.myFcmToken, false);
                                          setState(() {
                                            foodDeal.upVotes
                                                .add(MyConstants.myFcmToken);
                                          });
                                        }
                                      },
                                      child: Wrap(
                                        crossAxisAlignment:
                                            WrapCrossAlignment.center,
                                        children: [
                                          Icon(
                                            Icons.thumb_up_sharp,
                                            size: MyConstants.iconSizeMobile,
                                            color: foodDeal.upVotes.contains(
                                                    MyConstants.myFcmToken)
                                                ? Colors.blue
                                                : Colors.white,
                                          ),
                                          Text(
                                            ' ' +
                                                foodDeal.upVotes.length
                                                    .toString(),
                                            style: TextStyle(
                                              color: foodDeal.upVotes.contains(
                                                      MyConstants.myFcmToken)
                                                  ? Colors.blue
                                                  : Colors.white,
                                              fontSize: MyConstants.isMobile
                                                  ? MyConstants.itemFooterFontSizeMobile
                                                  : MyConstants.itemFooterFontSizeTablet,
                                            ),
                                          ),
                                        ],
                                      )))
                            ],
                          )
                        ],
                      )
                    ]))));
  }
}
