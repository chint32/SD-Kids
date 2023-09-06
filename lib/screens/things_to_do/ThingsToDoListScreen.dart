import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sd_kids/models/ThingToDo.dart';
import 'package:sd_kids/util/constants.dart';
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
  final List<String> _items = ['Price', 'Age group', 'Up Votes'];
  bool isSortingMenuVisible = false;
  double _sortMenuHeight = 0;

  @override
  void initState() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        context.read<ThingsToDoListViewModel>().clearData();
        context.read<ThingsToDoListViewModel>().getThingsToDo();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    print('Resources List Screen');

    return Consumer<ThingsToDoListViewModel>(
        builder: (context, viewModel, child) {
      switch (viewModel.response.status) {
        case Status.LOADING:
          return const Center(
              child: CircularProgressIndicator(
            color: Colors.blue,
          ));
        case Status.COMPLETED:
          List<String> ageGroups = viewModel.response.data['age_groups'];
          List<String> categories = viewModel.response.data['categories'];
          List<ThingToDo> thingsToDoAllCategories =
              viewModel.response.data['thingsToDo'];
          return Padding(
              padding: const EdgeInsets.fromLTRB(10, 10, 10, 80),
              child: Column(children: [
                const Text(
                  'Things To Do',
                  style: TextStyle(
                      fontSize: 24,
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
                                        fontSize: 18, fontFamily: 'Jost'),
                                  ),
                                  RotatedBox(
                                      quarterTurns:
                                      isSortingMenuVisible ? 2 : 0,
                                      child: IconButton(
                                        icon: Icon(
                                          Icons.arrow_drop_down,
                                          size: 30,
                                        ),
                                        onPressed: () {
                                          setState(() {
                                            isSortingMenuVisible =
                                            !isSortingMenuVisible;
                                            if (isSortingMenuVisible) {
                                              _sortMenuHeight = 120;
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
                                                    fontSize: 18,
                                                    fontFamily: 'Jost'),
                                              ),
                                              ReorderableDragStartListener(
                                                  key: ValueKey<String>(
                                                      _items[index]),
                                                  index: index,
                                                  child: const Padding(
                                                    padding:
                                                    EdgeInsets.fromLTRB(
                                                        0, 0, 10, 0),
                                                    child: Icon(
                                                      Icons.drag_handle,
                                                      size: 30,
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

                                    if (_items[0] == 'Age group' &&
                                        _items[1] == 'Price') {
                                      thingsToDoAllCategories.sort((a, b) {
                                        int cmp = ageGroups
                                            .indexOf(a.ageGroups[0])
                                            .compareTo(ageGroups
                                            .indexOf(b.ageGroups[0]));
                                        if (cmp != 0) return cmp;
                                        return a.price.compareTo(b.price);
                                      });
                                    } else if (_items[0] == 'Up Votes' &&
                                        _items[1] == 'Price') {
                                      thingsToDoAllCategories.sort((a, b) {
                                        int cmp = b.upVotes.length
                                            .compareTo(a.upVotes.length);
                                        if (cmp != 0) return cmp;
                                        return a.price.compareTo(b.price);
                                      });
                                    } else if (_items[0] == 'Up Votes' &&
                                        _items[1] == 'Age group') {
                                      thingsToDoAllCategories.sort((a, b) {
                                        int cmp = b.upVotes.length
                                            .compareTo(a.upVotes.length);
                                        if (cmp != 0) return cmp;
                                        return ageGroups
                                            .indexOf(a.ageGroups[0])
                                            .compareTo(ageGroups
                                            .indexOf(b.ageGroups[0]));
                                      });
                                    } else if (_items[0] == 'Price' &&
                                        _items[1] == 'Age group') {
                                      thingsToDoAllCategories.sort((a, b) {
                                        int cmp = a.price.compareTo(b.price);
                                        if (cmp != 0) return cmp;
                                        return ageGroups
                                            .indexOf(a.ageGroups[0])
                                            .compareTo(ageGroups
                                            .indexOf(b.ageGroups[0]));
                                      });
                                    } else if (_items[0] == 'Age group' &&
                                        _items[1] == 'Up Votes') {
                                      thingsToDoAllCategories.sort((a, b) {
                                        int cmp = ageGroups
                                            .indexOf(a.ageGroups[0])
                                            .compareTo(ageGroups
                                            .indexOf(b.ageGroups[0]));
                                        if (cmp != 0) return cmp;
                                        return b.upVotes.length
                                            .compareTo(a.upVotes.length);
                                      });
                                    } else if (_items[0] == 'Price' &&
                                        _items[1] == 'Up Votes') {
                                      thingsToDoAllCategories.sort((a, b) {
                                        int cmp = a.price.compareTo(b.price);
                                        if (cmp != 0) return cmp;
                                        return b.upVotes.length
                                            .compareTo(a.upVotes.length);
                                      });
                                    }
                                  });
                                },
                              ),
                            )
                          ],
                        ))),
                Expanded(child:SingleChildScrollView(
                  child:  Column(
                      children: <Widget>[
                for (var category in categories)
                  ThingsToDoByCategory(
                      viewModel,
                      categories,
                      category,
                      thingsToDoAllCategories
                          .where((thingToDo) =>
                              thingToDo.categories.contains(category))
                          .toList())
              ])))]));
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

  Future<double> get _height => Future<double>.value(450);

  Widget ThingsToDoByCategory(ThingsToDoListViewModel viewModel,
      List<String> categories, String category, List<ThingToDo> thingsToDo) {
    return FutureBuilder<double>(
        future: _height,
        initialData: 0.0,
        builder: (context, snapshot) {
          return AnimatedContainer(
              padding: EdgeInsets.symmetric(vertical: 10),
              curve: Curves.elasticOut,
              height: snapshot.data!,
              duration: Duration(milliseconds: 2000),
              child: Column(children: [
                Container(
                    width: double.infinity,
                    child: Padding(
                        padding:
                            EdgeInsets.symmetric(vertical: 0, horizontal: 3),
                        child: Text(category,
                            textAlign: TextAlign.start,
                            style: const TextStyle(
                                fontSize: 20, fontWeight: FontWeight.bold)))),
                Container(
                    height: 371,
                    child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        shrinkWrap: true,
                        physics: const ClampingScrollPhysics(),
                        itemCount: thingsToDo.length,
                        itemBuilder: (BuildContext context, int index) {
                          return InkWell(
                              onTap: () {
                                print('navigating to thingToDo detail');
                                widget.appBarChange();
                                widget.navKey.currentState!.pushNamed(
                                    NavRoutes.thingToDoDetailsRoute,
                                    arguments: {
                                      'thing_to_do': thingsToDo[index],
                                      'category': category,
                                      'index': index
                                    });
                              },
                              child: ThingToDoListItemWidget(
                                  context,
                                  viewModel,
                                  thingsToDo[index],
                                  categories,
                                  category,
                                  index));
                        }))
              ]));
        });
  }

  Widget ThingToDoListItemWidget(
      BuildContext context,
      ThingsToDoListViewModel viewModel,
      ThingToDo thingToDo,
      List<String> categories,
      String category,
      int index) {
    return Container(
        width: 341,
        height: 280,
        child: Card(
            color: MyConstants.cardBgColors[categories.indexOf(category)],
            child: Padding(
                padding: const EdgeInsets.all(10),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Flexible(
                            child: Text(
                          thingToDo.name,
                          style: const TextStyle(
                              color: Colors.white,
                              fontSize: 20,
                              fontWeight: FontWeight.bold),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        )),
                        Text(
                          "\$${thingToDo.price}",
                          style: const TextStyle(
                              color: Colors.white,
                              fontSize: 20,
                              fontWeight: FontWeight.bold),
                        ),
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
                    Text(
                      thingToDo.description,
                      maxLines: 4,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.bold),
                    ),
                    SizedBox(
                      height: 4,
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Wrap(
                          children: [
                            for (var ageGroup in thingToDo.ageGroups)
                              Container(
                                padding: EdgeInsets.symmetric(horizontal: 4),
                                height: 30,
                                decoration: BoxDecoration(
                                  color: Color(0xff568f56),
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(20)),
                                ),
                                child: Center(
                                    child: Text(
                                  ageGroup,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    overflow: TextOverflow.ellipsis,
                                    fontSize: 11,
                                  ),
                                )),
                              )
                          ],
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            Padding(
                                padding: EdgeInsets.fromLTRB(0, 0, 4, 0),
                                child: InkWell(
                                    onTap: () {
                                      if (thingToDo.upVotes
                                          .contains(MyConstants.myFcmToken)) {
                                        thingToDo.upVotes
                                            .remove(MyConstants.myFcmToken);
                                        viewModel.upVoteThingToDo(thingToDo,
                                            MyConstants.myFcmToken, true);
                                        viewModel.downVoteThingToDo(thingToDo,
                                            MyConstants.myFcmToken, false);
                                        setState(() {
                                          thingToDo.upVotes
                                              .remove(MyConstants.myFcmToken);
                                          thingToDo.downVotes
                                              .add(MyConstants.myFcmToken);
                                        });
                                      } else if (thingToDo.downVotes
                                          .contains(MyConstants.myFcmToken)) {
                                        viewModel.downVoteThingToDo(thingToDo,
                                            MyConstants.myFcmToken, true);
                                        setState(() {
                                          thingToDo.downVotes
                                              .remove(MyConstants.myFcmToken);
                                        });
                                      } else {
                                        viewModel.downVoteThingToDo(thingToDo,
                                            MyConstants.myFcmToken, false);
                                        setState(() {
                                          thingToDo.downVotes
                                              .add(MyConstants.myFcmToken);
                                        });
                                      }
                                    },
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
                                                    MyConstants.myFcmToken)
                                                ? Colors.blue
                                                : Colors.white,
                                            fontSize: 15,
                                          ),
                                        ),
                                        Icon(
                                          Icons.thumb_down_sharp,
                                          color: thingToDo.downVotes.contains(
                                                  MyConstants.myFcmToken)
                                              ? Colors.blue
                                              : Colors.white,
                                          size: 22,
                                        ),
                                      ],
                                    ))),
                            Padding(
                                padding: EdgeInsets.fromLTRB(4, 0, 0, 0),
                                child: InkWell(
                                    onTap: () {
                                      if (thingToDo.downVotes
                                          .contains(MyConstants.myFcmToken)) {
                                        thingToDo.downVotes
                                            .remove(MyConstants.myFcmToken);
                                        viewModel.downVoteThingToDo(thingToDo,
                                            MyConstants.myFcmToken, true);
                                        viewModel.upVoteThingToDo(thingToDo,
                                            MyConstants.myFcmToken, false);
                                        setState(() {
                                          thingToDo.downVotes
                                              .remove(MyConstants.myFcmToken);
                                          thingToDo.upVotes
                                              .add(MyConstants.myFcmToken);
                                        });
                                      } else if (thingToDo.upVotes
                                          .contains(MyConstants.myFcmToken)) {
                                        viewModel.upVoteThingToDo(thingToDo,
                                            MyConstants.myFcmToken, true);
                                        setState(() {
                                          thingToDo.upVotes
                                              .remove(MyConstants.myFcmToken);
                                        });
                                      } else {
                                        viewModel.upVoteThingToDo(thingToDo,
                                            MyConstants.myFcmToken, false);
                                        setState(() {
                                          thingToDo.upVotes
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
                                          color: thingToDo.upVotes.contains(
                                                  MyConstants.myFcmToken)
                                              ? Colors.blue
                                              : Colors.white,
                                          size: 22,
                                        ),
                                        Text(
                                          ' ' +
                                              thingToDo.upVotes.length
                                                  .toString(),
                                          style: TextStyle(
                                            color: thingToDo.upVotes.contains(
                                                    MyConstants.myFcmToken)
                                                ? Colors.blue
                                                : Colors.white,
                                            fontSize: 15,
                                          ),
                                        ),
                                      ],
                                    )))
                          ],
                        )
                      ],
                    )
                  ],
                ))));
  }
}
