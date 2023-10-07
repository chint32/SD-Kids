import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sd_kids/models/ThingToDo.dart';
import 'package:sd_kids/util/constants.dart' as Constants;
import 'package:sd_kids/viewModel/ThingsToDoListViewModel.dart';
import '../../main.dart';
import '../../models/FirebaseResponse.dart';
import '../shared/SharedWidgets.dart';

class ThingsToDoListScreen extends StatefulWidget {
  final GlobalKey<NavigatorState> navKey;
  final Function appBarChange;

  const ThingsToDoListScreen(
      {super.key, required this.navKey, required this.appBarChange});

  @override
  State<ThingsToDoListScreen> createState() => _ThingsToDoListScreenState();
}

class _ThingsToDoListScreenState extends State<ThingsToDoListScreen> {
  bool isSortingMenuVisible = false;
  final List<String> _sortMenuItems = ['Price', 'Age group', 'Up Votes'];
  double _sortMenuHeight = 0;
  List<String> ageGroups = [];
  List<ThingToDo> thingsToDoAllCategories = [];

  Future<double> get _height => Future<double>.value(Constants.isMobile
      ? Constants.itemAnimatedContainerShortHeightMobile
      : Constants.itemAnimatedContainerShortHeightTablet);

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        context.read<ThingsToDoListViewModel>().clearData();
        context.read<ThingsToDoListViewModel>().getThingsToDo();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ThingsToDoListViewModel>(
        builder: (context, viewModel, child) {
      switch (viewModel.response.status) {
        case Status.LOADING:
          return const Center(
              child: CircularProgressIndicator(
            color: Colors.blue,
          ));
        case Status.COMPLETED:
          ageGroups = viewModel.response.data['age_groups'];
          List<String> categories = viewModel.response.data['categories'];
          thingsToDoAllCategories = viewModel.response.data['thingsToDo'];
          return Padding(
              padding: const EdgeInsets.fromLTRB(10, 10, 10, 80),
              child: Column(children: [
                SharedWidgets.screenTitle("Things To Do"),
                SharedWidgets.SortMenu(_sortMenuItems, _sortMenuHeight,
                    isSortingMenuVisible, onMenuOpenClose, onMenuReorder),
                ListOfThingsToDoByCategory(
                    viewModel, categories, thingsToDoAllCategories)
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

  Widget ListOfThingsToDoByCategory(ThingsToDoListViewModel viewModel,
      List<String> categories, List<ThingToDo> thingsToDoAllCategories) {
    return Expanded(
        child: SingleChildScrollView(
            child: ListView.builder(
                scrollDirection: Axis.vertical,
                shrinkWrap: true,
                physics: const ClampingScrollPhysics(),
                itemCount: categories.length,
                itemBuilder: (BuildContext context, int index) {
                  List<ThingToDo> thingsToDo = thingsToDoAllCategories
                      .where((thingToDo) =>
                          thingToDo.categories.contains(categories[index]))
                      .toList();
                  return FutureBuilder<double>(
                      future: _height,
                      initialData: 0.0,
                      builder: (context, snapshot) {
                        return AnimatedContainer(
                            padding: EdgeInsets.symmetric(vertical: 10),
                            curve: Curves.elasticOut,
                            height: snapshot.data!,
                            duration: Duration(milliseconds: 1000),
                            child: Column(children: [
                              Container(
                                  width: double.infinity,
                                  child: Padding(
                                      padding: EdgeInsets.symmetric(
                                          vertical: 0, horizontal: 3),
                                      child: SharedWidgets.categoryTitleWidget(
                                          categories[index]))),
                              Container(
                                  height: Constants.isMobile
                                      ? Constants.itemContainerHeightShortMobile
                                      : Constants
                                          .itemContainerHeightShortTablet,
                                  child: ListView.builder(
                                      scrollDirection: Axis.horizontal,
                                      shrinkWrap: true,
                                      physics: const ClampingScrollPhysics(),
                                      itemCount: thingsToDo.length,
                                      itemBuilder:
                                          (BuildContext context, int myIndex) {
                                        return InkWell(
                                            onTap: () {
                                              print(
                                                  'navigating to thingToDo detail');
                                              widget.appBarChange();
                                              widget.navKey.currentState!
                                                  .pushNamed(
                                                      NavRoutes
                                                          .thingToDoDetailsRoute,
                                                      arguments: {
                                                    'thing_to_do':
                                                        thingsToDo[myIndex],
                                                    'category':
                                                        categories[index],
                                                    'index': myIndex
                                                  });
                                            },
                                            child: ThingToDoListItemWidget(
                                                viewModel,
                                                thingsToDo[myIndex],
                                                categories,
                                                categories[index],
                                                myIndex));
                                      }))
                            ]));
                      });
                })));
  }

  Widget ThingToDoListItemWidget(
      ThingsToDoListViewModel viewModel,
      ThingToDo thingToDo,
      List<String> categories,
      String category,
      int index) {
    return Container(
        width: Constants.isMobile
            ? Constants.itemCardWidthMobile
            : Constants.itemCardWidthTablet,
        child: Card(
            color: Constants.cardBgColors[categories.indexOf(category)],
            child: Padding(
                padding: const EdgeInsets.all(10),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Flexible(
                            child:
                                SharedWidgets.itemTitleWidget(thingToDo.name)),
                        SharedWidgets.itemPriceWidget(thingToDo.price),
                      ],
                    ),
                    Hero(
                      tag: 'thing_to_do_image$category$index',
                      child: SharedWidgets.networkImageWithLoading(
                          thingToDo.imageUrl),
                    ),
                    const SizedBox(
                      height: 8,
                    ),
                    SharedWidgets.itemDescriptionWidget(thingToDo.description),
                    SizedBox(
                      height: 4,
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        SharedWidgets.itemAgeGroupsWidget(ageGroups),
                        likesDislikesWidget(thingToDo, viewModel)
                      ],
                    )
                  ],
                ))));
  }

  Widget likesDislikesWidget(ThingToDo thingToDo, ThingsToDoListViewModel viewModel){
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        Padding(
            padding: EdgeInsets.fromLTRB(0, 0, 4, 0),
            child: InkWell(
                onTap: () {
                  if (thingToDo.upVotes.contains(Constants.myFcmToken)) {
                    thingToDo.upVotes.remove(Constants.myFcmToken);
                    viewModel.upVoteThingToDo(thingToDo, Constants.myFcmToken, true);
                    viewModel.downVoteThingToDo(thingToDo, Constants.myFcmToken, false);
                    setState(() {
                      thingToDo.upVotes.remove(Constants.myFcmToken);
                      thingToDo.downVotes.add(Constants.myFcmToken);
                    });
                  } else if (thingToDo.downVotes.contains(Constants.myFcmToken)) {
                    viewModel.downVoteThingToDo(thingToDo, Constants.myFcmToken, true);
                    setState(() {
                      thingToDo.downVotes.remove(Constants.myFcmToken);
                    });
                  } else {
                    viewModel.downVoteThingToDo(thingToDo, Constants.myFcmToken, false);
                    setState(() {
                      thingToDo.downVotes.add(Constants.myFcmToken);
                    });
                  }                },
                child: Wrap(
                  crossAxisAlignment:
                  WrapCrossAlignment.center,
                  children: [
                    Text(
                      thingToDo.downVotes.length
                          .toString() +
                          ' ',
                      style: TextStyle(
                        color: thingToDo.downVotes.contains(
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
                    Icon(
                      Icons.thumb_down_sharp,
                      color: thingToDo.downVotes.contains(
                          Constants.myFcmToken)
                          ? Colors.blue
                          : Colors.white,
                      size: Constants.isMobile
                          ? Constants.iconSizeMobile
                          : Constants.iconSizeTablet,
                    ),
                  ],
                ))),
        Padding(
            padding: EdgeInsets.fromLTRB(4, 0, 0, 0),
            child: InkWell(
                onTap: () {
                  if (thingToDo.downVotes.contains(Constants.myFcmToken)) {
                    thingToDo.downVotes.remove(Constants.myFcmToken);
                    viewModel.downVoteThingToDo(thingToDo, Constants.myFcmToken, true);
                    viewModel.upVoteThingToDo(thingToDo, Constants.myFcmToken, false);
                    setState(() {
                      thingToDo.downVotes.remove(Constants.myFcmToken);
                      thingToDo.upVotes.add(Constants.myFcmToken);
                    });
                  } else if (thingToDo.upVotes.contains(Constants.myFcmToken)) {
                    viewModel.upVoteThingToDo(thingToDo, Constants.myFcmToken, true);
                    setState(() {
                      thingToDo.upVotes.remove(Constants.myFcmToken);
                    });
                  } else {
                    viewModel.upVoteThingToDo(thingToDo, Constants.myFcmToken, false);
                    setState(() {
                      thingToDo.upVotes.add(Constants.myFcmToken);
                    });
                  }                },
                child: Wrap(
                  crossAxisAlignment:
                  WrapCrossAlignment.center,
                  children: [
                    Icon(
                      Icons.thumb_up_sharp,
                      color: thingToDo.upVotes.contains(
                          Constants.myFcmToken)
                          ? Colors.blue
                          : Colors.white,
                      size: Constants.isMobile
                          ? Constants.iconSizeMobile
                          : Constants.iconSizeTablet,
                    ),
                    Text(
                      ' ' +
                          thingToDo.upVotes.length
                              .toString(),
                      style: TextStyle(
                        color: thingToDo.upVotes.contains(
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

  void onMenuOpenClose() {
    setState(() {
      isSortingMenuVisible = !isSortingMenuVisible;
      if (isSortingMenuVisible) {
        _sortMenuHeight = Constants.isMobile ? 120 : 136;
      } else {
        _sortMenuHeight = 0;
      }
    });
  }

  void onMenuReorder(int oldIndex, int newIndex) {
    setState(() {
      if (oldIndex < newIndex) {
        newIndex -= 1;
      }
      final String item = _sortMenuItems.removeAt(oldIndex);
      _sortMenuItems.insert(newIndex, item);

      if (_sortMenuItems[0] == 'Age group' && _sortMenuItems[1] == 'Price') {
        thingsToDoAllCategories.sort((a, b) {
          int cmp = ageGroups
              .indexOf(a.ageGroups[0])
              .compareTo(ageGroups.indexOf(b.ageGroups[0]));
          if (cmp != 0) return cmp;
          return a.price.compareTo(b.price);
        });
      } else if (_sortMenuItems[0] == 'Up Votes' &&
          _sortMenuItems[1] == 'Price') {
        thingsToDoAllCategories.sort((a, b) {
          int cmp = b.upVotes.length.compareTo(a.upVotes.length);
          if (cmp != 0) return cmp;
          return a.price.compareTo(b.price);
        });
      } else if (_sortMenuItems[0] == 'Up Votes' &&
          _sortMenuItems[1] == 'Age group') {
        thingsToDoAllCategories.sort((a, b) {
          int cmp = b.upVotes.length.compareTo(a.upVotes.length);
          if (cmp != 0) return cmp;
          return ageGroups
              .indexOf(a.ageGroups[0])
              .compareTo(ageGroups.indexOf(b.ageGroups[0]));
        });
      } else if (_sortMenuItems[0] == 'Price' &&
          _sortMenuItems[1] == 'Age group') {
        thingsToDoAllCategories.sort((a, b) {
          int cmp = a.price.compareTo(b.price);
          if (cmp != 0) return cmp;
          return ageGroups
              .indexOf(a.ageGroups[0])
              .compareTo(ageGroups.indexOf(b.ageGroups[0]));
        });
      } else if (_sortMenuItems[0] == 'Age group' &&
          _sortMenuItems[1] == 'Up Votes') {
        thingsToDoAllCategories.sort((a, b) {
          int cmp = ageGroups
              .indexOf(a.ageGroups[0])
              .compareTo(ageGroups.indexOf(b.ageGroups[0]));
          if (cmp != 0) return cmp;
          return b.upVotes.length.compareTo(a.upVotes.length);
        });
      } else if (_sortMenuItems[0] == 'Price' &&
          _sortMenuItems[1] == 'Up Votes') {
        thingsToDoAllCategories.sort((a, b) {
          int cmp = a.price.compareTo(b.price);
          if (cmp != 0) return cmp;
          return b.upVotes.length.compareTo(a.upVotes.length);
        });
      }
    });
  }
}
