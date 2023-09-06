import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sd_kids/models/ParksAndPools.dart';
import '../../models/FirebaseResponse.dart';
import '../../util/constants.dart';
import '../../viewModel/ParksAndPoolsListViewModel.dart';
import '../shared/SharedWidgets.dart';

class ParksAndPoolsListScreen extends StatefulWidget {
  final GlobalKey<NavigatorState> navKey;
  final Function() appBarChange;

  const ParksAndPoolsListScreen(
      {super.key, required this.navKey, required this.appBarChange});

  @override
  State<ParksAndPoolsListScreen> createState() =>
      _ParksAndPoolsListScreenState();
}

class _ParksAndPoolsListScreenState extends State<ParksAndPoolsListScreen> {
  final List<String> _items = ['Price', 'Up Votes'];
  bool isSortingMenuVisible = false;
  double _sortMenuHeight = 0;

  @override
  void initState() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        context.read<ParksAndPoolsListViewModel>().clearData();
        context.read<ParksAndPoolsListViewModel>().getParksAndPools();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    print('Things To Do List Screen');
    return Consumer<ParksAndPoolsListViewModel>(
        builder: (context, viewModel, child) =>
            ParksAndPoolsListWidget(context, viewModel));
  }

  Widget ParksAndPoolsListWidget(
      BuildContext context, ParksAndPoolsListViewModel viewModel) {
    switch (viewModel.response.status) {
      case Status.LOADING:
        return const Center(
            child: CircularProgressIndicator(
          color: Colors.blue,
        ));
      case Status.COMPLETED:
        List<ParksAndPools> parksAndPools =
            viewModel.response.data as List<ParksAndPools>;
        return Padding(
            padding: EdgeInsets.fromLTRB(10, 10, 10, 80),
            child: Column(children: <Widget>[
              Text(
                'Parks and Pools',
                style: TextStyle(
                    fontSize: MyConstants.isMobile
                        ? MyConstants.screenTitleFontSizeMobile
                        : MyConstants.screenTitleFontSizeTablet,                    fontFamily: 'Jost',
                    fontWeight: FontWeight.bold),
              ),
              Card(
                  color: Colors.white70,
                  child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: Column(
                        children: [
                          Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  'Sort by',
                                  style: TextStyle(
                                      fontSize: MyConstants.isMobile
                                          ? MyConstants.sortMenuFontSizeMobile
                                          : MyConstants.sortMenuFontSizeTablet,                                      fontFamily: 'Jost'),
                                ),
                                RotatedBox(
                                    quarterTurns: isSortingMenuVisible ? 2 : 0,
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
                                            _sortMenuHeight = 80;
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
                                                      : MyConstants.sortMenuFontSizeTablet,                                                  fontFamily: 'Jost'),
                                            ),
                                            ReorderableDragStartListener(
                                                key: ValueKey<String>(
                                                    _items[index]),
                                                index: index,
                                                child:  Padding(
                                                  padding: const EdgeInsets.fromLTRB(
                                                      0, 0, 10, 0),
                                                  child: Icon(
                                                    Icons.drag_handle,
                                                    size: MyConstants.isMobile
                                                        ? MyConstants.iconSizeMobile
                                                        : MyConstants.iconSizeTablet,                                                  ),
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
                                  final String item = _items.removeAt(oldIndex);
                                  _items.insert(newIndex, item);

                                  if (_items[0] == 'Price' &&
                                      _items[1] == 'Up Votes') {
                                    parksAndPools.sort((a, b) {
                                      int cmp = a.price.compareTo(b.price);
                                      if (cmp != 0) return cmp;
                                      return b.upVotes.length
                                          .compareTo(a.upVotes.length);
                                    });
                                  } else {
                                    parksAndPools.sort((a, b) {
                                      int cmp = b.upVotes.length
                                          .compareTo(a.upVotes.length);
                                      if (cmp != 0) return cmp;
                                      return a.price.compareTo(b.price);
                                    });
                                  }
                                });
                              },
                            ),
                          ),
                        ],
                      ))),
              SizedBox(height: 10,),
              Expanded(
                  child: SingleChildScrollView(
                      child: Column(children: [
                for (var parkPool in parksAndPools)
                  ParksAndPoolsListItemWidget(context, viewModel, parkPool,
                      parksAndPools.indexOf(parkPool))
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
  }

  bool needToAnimate = true;
  Future<double> get _height => Future<double>.value(360);

  Widget ParksAndPoolsListItemWidget(
      BuildContext context,
      ParksAndPoolsListViewModel viewModel,
      ParksAndPools parkAndPool,
      int index) {
    return FutureBuilder<double>(
        future: _height,
        initialData: 0.0,
        builder: (context, snapshot) {
          return AnimatedContainer(
              padding: EdgeInsets.symmetric(vertical: 5),
              curve: Curves.elasticOut,
              height: needToAnimate ? snapshot.data! : 360,
              duration: Duration(milliseconds: 2000),
              child: Card(
                color: MyConstants.cardBgColors[index],
                child: Padding(
                  padding:
                      const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Wrap(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Flexible(
                                  child: Text(
                                parkAndPool.name,
                                style: TextStyle(
                                    color: Colors.white,
                                    fontSize: MyConstants.isMobile
                                        ? MyConstants.itemTitleFontSizeMobile
                                        : MyConstants.itemTitleFontSizeTablet,                                    fontWeight: FontWeight.bold),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              )),
                              Text(
                                "\$${parkAndPool.price}",
                                style: TextStyle(
                                    color: Colors.white,
                                    fontSize: MyConstants.isMobile
                                        ? MyConstants.itemTitleFontSizeMobile
                                        : MyConstants.itemTitleFontSizeTablet,                                    fontWeight: FontWeight.bold),
                              ),
                            ],
                          ),
                          Hero(
                            tag: 'park_and_pool_image$index',
                            child: SharedWidgets.networkImageWithLoading(
                                parkAndPool.imageUrl),
                          ),
                          Text(
                            parkAndPool.description,
                            maxLines: 4,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                            ),
                          ),
                        ],
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          Padding(
                              padding: EdgeInsets.fromLTRB(0, 0, 8, 0),
                              child: InkWell(
                                  onTap: () {
                                    if (parkAndPool.upVotes
                                        .contains(MyConstants.myFcmToken)) {
                                      parkAndPool.upVotes
                                          .remove(MyConstants.myFcmToken);
                                      viewModel.upVoteParkAndPool(parkAndPool,
                                          MyConstants.myFcmToken, true);
                                      viewModel.downVoteParkAndPool(parkAndPool,
                                          MyConstants.myFcmToken, false);
                                      setState(() {
                                        parkAndPool.upVotes
                                            .remove(MyConstants.myFcmToken);
                                        parkAndPool.downVotes
                                            .add(MyConstants.myFcmToken);
                                      });
                                    } else if (parkAndPool.downVotes
                                        .contains(MyConstants.myFcmToken)) {
                                      viewModel.downVoteParkAndPool(parkAndPool,
                                          MyConstants.myFcmToken, true);
                                      setState(() {
                                        parkAndPool.downVotes
                                            .remove(MyConstants.myFcmToken);
                                      });
                                    } else {
                                      viewModel.downVoteParkAndPool(parkAndPool,
                                          MyConstants.myFcmToken, false);
                                      setState(() {
                                        parkAndPool.downVotes
                                            .add(MyConstants.myFcmToken);
                                      });
                                    }
                                  },
                                  child: Wrap(
                                    crossAxisAlignment:
                                        WrapCrossAlignment.center,
                                    children: [
                                      Text(
                                        parkAndPool.downVotes.length
                                                .toString() +
                                            ' ',
                                        style: TextStyle(
                                          color: parkAndPool.downVotes.contains(
                                                  MyConstants.myFcmToken)
                                              ? Colors.blue
                                              : Colors.white,
                                          fontSize: 16,
                                        ),
                                      ),
                                      Icon(
                                        Icons.thumb_down_sharp,
                                        color: parkAndPool.downVotes.contains(
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
                                    if (parkAndPool.downVotes
                                        .contains(MyConstants.myFcmToken)) {
                                      parkAndPool.downVotes
                                          .remove(MyConstants.myFcmToken);
                                      viewModel.downVoteParkAndPool(parkAndPool,
                                          MyConstants.myFcmToken, true);
                                      viewModel.upVoteParkAndPool(parkAndPool,
                                          MyConstants.myFcmToken, false);
                                      setState(() {
                                        parkAndPool.downVotes
                                            .remove(MyConstants.myFcmToken);
                                        parkAndPool.upVotes
                                            .add(MyConstants.myFcmToken);
                                      });
                                    } else if (parkAndPool.upVotes
                                        .contains(MyConstants.myFcmToken)) {
                                      viewModel.upVoteParkAndPool(parkAndPool,
                                          MyConstants.myFcmToken, true);
                                      setState(() {
                                        parkAndPool.upVotes
                                            .remove(MyConstants.myFcmToken);
                                      });
                                    } else {
                                      viewModel.upVoteParkAndPool(parkAndPool,
                                          MyConstants.myFcmToken, false);
                                      setState(() {
                                        parkAndPool.upVotes
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
                                        color: parkAndPool.upVotes.contains(
                                                MyConstants.myFcmToken)
                                            ? Colors.blue
                                            : Colors.white,
                                      ),
                                      Text(
                                        ' ' +
                                            parkAndPool.upVotes.length
                                                .toString(),
                                        style: TextStyle(
                                          color: parkAndPool.upVotes.contains(
                                                  MyConstants.myFcmToken)
                                              ? Colors.blue
                                              : Colors.white,
                                          fontSize: 16,
                                        ),
                                      ),
                                    ],
                                  )))
                        ],
                      )
                    ],
                  ),
                ),
              ));
        });
  }
}
