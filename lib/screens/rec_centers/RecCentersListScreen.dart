import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sd_kids/models/RecCenter.dart';
import '../../main.dart';
import '../../models/FirebaseResponse.dart';
import '../../viewModel/RecCenterListViewModel.dart';
import '../shared/SharedWidgets.dart';
import 'package:sd_kids/util/constants.dart' as Constants;

class RecCentersListScreen extends StatefulWidget {
  final GlobalKey<NavigatorState> navKey;
  final Function appBarChange;

  const RecCentersListScreen(
      {super.key, required this.navKey, required this.appBarChange});

  @override
  State<RecCentersListScreen> createState() => _RecCentersListScreenState();
}

class _RecCentersListScreenState extends State<RecCentersListScreen> {
  bool needToAnimate = true;

  Future<double> get _height => Future<double>.value(344);

  @override
  void initState() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        context.read<RecCenterListViewModel>().clearData();
        context.read<RecCenterListViewModel>().getRecCenters();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<RecCenterListViewModel>(
        builder: (context, viewModel, child) => Padding(
            padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 5),
            child: SingleChildScrollView(
                child: Column(children: <Widget>[
              SharedWidgets.screenTitle('Rec Centers'),
              SizedBox(
                  height: MediaQuery.of(context).size.height * .85,
                  child: RecCentersListWidget(context, viewModel))
            ]))));
  }

  Widget RecCentersListWidget(
      BuildContext context, RecCenterListViewModel viewModel) {
    switch (viewModel.response.status) {
      case Status.LOADING:
        return const Center(
            child: CircularProgressIndicator(
          color: Colors.blue,
        ));
      case Status.COMPLETED:
        List<RecCenter> recCenters = viewModel.response.data as List<RecCenter>;
        return NotificationListener<ScrollEndNotification>(
            onNotification: (notification) {
              needToAnimate = false;
              return false;
            },
            child: ListView.builder(
                shrinkWrap: true,
                physics: const ClampingScrollPhysics(),
                padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
                itemCount: recCenters.length,
                itemBuilder: (BuildContext context, int index) {
                  print(recCenters[index].toString());
                  return Padding(
                      padding: EdgeInsets.symmetric(vertical: 10),
                      child: InkWell(
                          onTap: () {
                            widget.appBarChange();
                            widget.navKey.currentState!.pushNamed(
                                NavRoutes.recCenterDetailsRoute,
                                arguments: {
                                  'rec_center': recCenters[index],
                                  'index': index
                                });
                          },
                          child: RecCentersListItemWidget(
                              context, viewModel, recCenters[index], index)));
                }));
      case Status.ERROR:
        return const Center(
          child: Text('Please try again latter!!!'),
        );
      case Status.INITIAL:
      default:
        return const Center(
          child: Text('loading'),
        );
    }
  }

  Widget RecCentersListItemWidget(BuildContext context,
      RecCenterListViewModel viewModel, RecCenter recCenter, int index) {
    return FutureBuilder<double>(
        future: _height,
        initialData: 0.0,
        builder: (context, snapshot) {
          return AnimatedContainer(
            curve: Curves.elasticOut,
            height: needToAnimate ? snapshot.data! : 344,
            duration: Duration(milliseconds: 1000),
            child: Card(
              color: Constants.cardBgColors[index],
              child: Padding(
                  padding:
                      const EdgeInsets.symmetric(vertical: 5, horizontal: 10),
                  child: Constants.isMobile
                      ? itemMobile(recCenter, viewModel, index)
                      : itemTablet(recCenter, viewModel, index)),
            ),
          );
        });
  }

  Widget itemMobile(
      RecCenter recCenter, RecCenterListViewModel viewModel, int index) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        SharedWidgets.itemTitleWidget(recCenter.name),
        Hero(
          tag: 'park_and_pool_image$index',
          child: SharedWidgets.networkImageWithLoading(recCenter.imageUrl),
        ),
        Padding(
            padding: EdgeInsets.symmetric(vertical: 2),
            child: SharedWidgets.itemDescriptionWidget(recCenter.description)),
        likesDislikesWidget(recCenter, viewModel)
      ],
    );
  }

  Widget likesDislikesWidget(
      RecCenter recCenter, RecCenterListViewModel viewModel) {
    return Wrap(
      children: [
        Padding(
            padding: EdgeInsets.fromLTRB(16, 0, 12, 0),
            child: InkWell(
                onTap: () {
                  if (recCenter.upVotes.contains(Constants.myFcmToken)) {
                    recCenter.upVotes.remove(Constants.myFcmToken);
                    viewModel.upVoteRecCenter(
                        recCenter, Constants.myFcmToken, true);
                    viewModel.downVoteRecCenter(
                        recCenter, Constants.myFcmToken, false);
                    setState(() {
                      recCenter.upVotes.remove(Constants.myFcmToken);
                      recCenter.downVotes.add(Constants.myFcmToken);
                    });
                  } else if (recCenter.downVotes
                      .contains(Constants.myFcmToken)) {
                    viewModel.downVoteRecCenter(
                        recCenter, Constants.myFcmToken, true);
                    setState(() {
                      recCenter.downVotes.remove(Constants.myFcmToken);
                    });
                  } else {
                    viewModel.downVoteRecCenter(
                        recCenter, Constants.myFcmToken, false);
                    setState(() {
                      recCenter.downVotes.add(Constants.myFcmToken);
                    });
                  }
                },
                child: Wrap(
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [
                    Text(
                      recCenter.downVotes.length.toString() + ' ',
                      style: TextStyle(
                        color:
                            recCenter.downVotes.contains(Constants.myFcmToken)
                                ? Colors.blue
                                : Colors.white,
                        fontSize: Constants.itemFooterFontSizeMobile,
                      ),
                    ),
                    Icon(
                      Icons.thumb_down_sharp,
                      color: recCenter.downVotes.contains(Constants.myFcmToken)
                          ? Colors.blue
                          : Colors.white,
                    ),
                  ],
                ))),
        Padding(
            padding: EdgeInsets.fromLTRB(12, 0, 0, 0),
            child: InkWell(
                onTap: () {
                  if (recCenter.downVotes.contains(Constants.myFcmToken)) {
                    recCenter.downVotes.remove(Constants.myFcmToken);
                    viewModel.downVoteRecCenter(
                        recCenter, Constants.myFcmToken, true);
                    viewModel.downVoteRecCenter(
                        recCenter, Constants.myFcmToken, false);
                    setState(() {
                      recCenter.downVotes.remove(Constants.myFcmToken);
                      recCenter.upVotes.add(Constants.myFcmToken);
                    });
                  } else if (recCenter.upVotes.contains(Constants.myFcmToken)) {
                    viewModel.upVoteRecCenter(
                        recCenter, Constants.myFcmToken, true);
                    setState(() {
                      recCenter.upVotes.remove(Constants.myFcmToken);
                    });
                  } else {
                    viewModel.upVoteRecCenter(
                        recCenter, Constants.myFcmToken, false);
                    setState(() {
                      recCenter.upVotes.add(Constants.myFcmToken);
                    });
                  }
                },
                child: Wrap(
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [
                    Icon(
                      Icons.thumb_up_sharp,
                      color: recCenter.upVotes.contains(Constants.myFcmToken)
                          ? Colors.blue
                          : Colors.white,
                    ),
                    Text(
                      ' ' + recCenter.upVotes.length.toString(),
                      style: TextStyle(
                        color: recCenter.upVotes.contains(Constants.myFcmToken)
                            ? Colors.blue
                            : Colors.white,
                        fontSize: Constants.itemFooterFontSizeMobile,
                      ),
                    ),
                  ],
                )))
      ],
    );
  }

  Widget itemTablet(
      RecCenter recCenter, RecCenterListViewModel viewModel, int index) {
    return Column(
      children: [
        Text(
          recCenter.name,
          style: TextStyle(
              color: Colors.white,
              fontSize: Constants.itemTitleFontSizeTablet,
              fontWeight: FontWeight.bold),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        Padding(
            padding: EdgeInsets.symmetric(vertical: 8),
            child: Row(
              children: [
                Hero(
                  tag: 'park_and_pool_image$index',
                  child:
                      SharedWidgets.networkImageWithLoading(recCenter.imageUrl),
                ),
                Expanded(
                    child: Padding(
                        padding: EdgeInsets.symmetric(horizontal: 16),
                        child: Text(
                          recCenter.description,
                          maxLines: 8,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: Constants.itemDescriptionFontSizeTablet,
                          ),
                        ))),
              ],
            )),
       likesDislikesWidget(recCenter, viewModel)
      ],
    );
  }
}
