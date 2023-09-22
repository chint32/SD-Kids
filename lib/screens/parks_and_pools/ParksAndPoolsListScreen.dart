import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sd_kids/models/ParksAndPools.dart';
import '../../models/FirebaseResponse.dart';
import '../../util/constants.dart' as Constants;
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
  List<ParksAndPools> parksAndPools = [];
  bool needToAnimate = true;
  Future<double> get _height => Future<double>.value(360);

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
        parksAndPools = viewModel.response.data as List<ParksAndPools>;
        return Padding(
            padding: EdgeInsets.fromLTRB(10, 10, 10, 80),
            child: Column(children: <Widget>[
              SharedWidgets.screenTitle('Parks and Pools'),
              SharedWidgets.SortMenu(_items, _sortMenuHeight,
                  isSortingMenuVisible, onOpenClose, onReorder),
              SizedBox(
                height: 10,
              ),
              Expanded(
                  child: SingleChildScrollView(
                      child: Column(children: [
                for (var parkPool in parksAndPools)
                  parksAndPoolsListItemWidget(context, viewModel, parkPool,
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

  Widget parksAndPoolsListItemWidget(
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
                color: Constants.cardBgColors[index],
                child: Padding(
                    padding:
                        const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                    child: Constants.isMobile
                        ? itemMobile(parkAndPool, viewModel, index)
                        : itemTablet(parkAndPool, viewModel, index)),
              ));
        });
  }

  Widget itemMobile(ParksAndPools parkAndPool,
      ParksAndPoolsListViewModel viewModel, int index) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        SharedWidgets.itemTitleWidget(parkAndPool.name),
        Hero(
          tag: 'park_and_pool_image$index',
          child: SharedWidgets.networkImageWithLoading(parkAndPool.imageUrl),
        ),
        Padding(
            padding: EdgeInsets.symmetric(vertical: 2),
            child:
                SharedWidgets.itemDescriptionWidget(parkAndPool.description)),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            SharedWidgets.itemPriceWidget(parkAndPool.price),
            likeDislikeWidget(parkAndPool, viewModel)
          ],
        )
      ],
    );
  }

  Widget itemTablet(ParksAndPools parkAndPool,
      ParksAndPoolsListViewModel viewModel, int index) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          SharedWidgets.itemTitleWidget(parkAndPool.name),
          SharedWidgets.itemPriceWidget(parkAndPool.price),
        ]),
        Row(
          children: [
            Hero(
              tag: 'park_and_pool_image$index',
              child:
                  SharedWidgets.networkImageWithLoading(parkAndPool.imageUrl),
            ),
            Expanded(
                child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16),
                    child: SharedWidgets.itemDescriptionWidget(
                        parkAndPool.description))),
          ],
        ),
        Padding(
            padding: EdgeInsets.fromLTRB(32, 0, 0, 0),
            child: likeDislikeWidget(parkAndPool, viewModel))
      ],
    );
  }

  Widget likeDislikeWidget(
      ParksAndPools parkAndPool, ParksAndPoolsListViewModel viewModel) {
    return Wrap(children: [
      Padding(
          padding: EdgeInsets.fromLTRB(0, 0, 8, 0),
          child: InkWell(
              onTap: () {
                if (parkAndPool.upVotes.contains(Constants.myFcmToken)) {
                  parkAndPool.upVotes.remove(Constants.myFcmToken);
                  viewModel.upVoteParkAndPool(
                      parkAndPool, Constants.myFcmToken, true);
                  viewModel.downVoteParkAndPool(
                      parkAndPool, Constants.myFcmToken, false);
                  setState(() {
                    parkAndPool.upVotes.remove(Constants.myFcmToken);
                    parkAndPool.downVotes.add(Constants.myFcmToken);
                  });
                } else if (parkAndPool.downVotes
                    .contains(Constants.myFcmToken)) {
                  viewModel.downVoteParkAndPool(
                      parkAndPool, Constants.myFcmToken, true);
                  setState(() {
                    parkAndPool.downVotes.remove(Constants.myFcmToken);
                  });
                } else {
                  viewModel.downVoteParkAndPool(
                      parkAndPool, Constants.myFcmToken, false);
                  setState(() {
                    parkAndPool.downVotes.add(Constants.myFcmToken);
                  });
                }
              },
              child: Wrap(
                crossAxisAlignment: WrapCrossAlignment.center,
                children: [
                  Text(
                    parkAndPool.downVotes.length.toString() + ' ',
                    style: TextStyle(
                      color:
                          parkAndPool.downVotes.contains(Constants.myFcmToken)
                              ? Colors.blue
                              : Colors.white,
                      fontSize: Constants.itemFooterFontSizeMobile,
                    ),
                  ),
                  Icon(
                    Icons.thumb_down_sharp,
                    color: parkAndPool.downVotes.contains(Constants.myFcmToken)
                        ? Colors.blue
                        : Colors.white,
                  ),
                ],
              ))),
      Padding(
          padding: EdgeInsets.fromLTRB(8, 0, 0, 0),
          child: InkWell(
              onTap: () {
                if (parkAndPool.downVotes.contains(Constants.myFcmToken)) {
                  parkAndPool.downVotes.remove(Constants.myFcmToken);
                  viewModel.downVoteParkAndPool(
                      parkAndPool, Constants.myFcmToken, true);
                  viewModel.upVoteParkAndPool(
                      parkAndPool, Constants.myFcmToken, false);
                  setState(() {
                    parkAndPool.downVotes.remove(Constants.myFcmToken);
                    parkAndPool.upVotes.add(Constants.myFcmToken);
                  });
                } else if (parkAndPool.upVotes.contains(Constants.myFcmToken)) {
                  viewModel.upVoteParkAndPool(
                      parkAndPool, Constants.myFcmToken, true);
                  setState(() {
                    parkAndPool.upVotes.remove(Constants.myFcmToken);
                  });
                } else {
                  viewModel.upVoteParkAndPool(
                      parkAndPool, Constants.myFcmToken, false);
                  setState(() {
                    parkAndPool.upVotes.add(Constants.myFcmToken);
                  });
                }
              },
              child: Wrap(
                crossAxisAlignment: WrapCrossAlignment.center,
                children: [
                  Icon(
                    Icons.thumb_up_sharp,
                    color: parkAndPool.upVotes.contains(Constants.myFcmToken)
                        ? Colors.blue
                        : Colors.white,
                  ),
                  Text(
                    ' ' + parkAndPool.upVotes.length.toString(),
                    style: TextStyle(
                      color: parkAndPool.upVotes.contains(Constants.myFcmToken)
                          ? Colors.blue
                          : Colors.white,
                      fontSize: Constants.itemFooterFontSizeMobile,
                    ),
                  ),
                ],
              )))
    ]);
  }

  void onOpenClose() {
    setState(() {
      isSortingMenuVisible = !isSortingMenuVisible;
      if (isSortingMenuVisible) {
        _sortMenuHeight = 80;
      } else {
        _sortMenuHeight = 0;
      }
    });
  }

  void onReorder(int oldIndex, int newIndex) {
    setState(() {
      if (oldIndex < newIndex) {
        newIndex -= 1;
      }
      final String item = _items.removeAt(oldIndex);
      _items.insert(newIndex, item);

      if (_items[0] == 'Price' && _items[1] == 'Up Votes') {
        parksAndPools.sort((a, b) {
          int cmp = a.price.compareTo(b.price);
          if (cmp != 0) return cmp;
          return b.upVotes.length.compareTo(a.upVotes.length);
        });
      } else {
        parksAndPools.sort((a, b) {
          int cmp = b.upVotes.length.compareTo(a.upVotes.length);
          if (cmp != 0) return cmp;
          return a.price.compareTo(b.price);
        });
      }
    });
  }
}
