import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sd_kids/models/RecCenter.dart';
import 'package:sd_kids/util/constants.dart';

import '../../main.dart';
import '../../models/FirebaseResponse.dart';
import '../../viewModel/RecCenterListViewModel.dart';
import '../shared/SharedWidgets.dart';

class RecCentersListScreen extends StatefulWidget {
  final GlobalKey<NavigatorState> navKey;
  final Function appBarChange;

  const RecCentersListScreen(
      {super.key, required this.navKey, required this.appBarChange});

  @override
  State<RecCentersListScreen> createState() => _RecCentersListScreenState();
}

class _RecCentersListScreenState extends State<RecCentersListScreen> {
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
    print('Rec Centers List Screen');
    return Consumer<RecCenterListViewModel>(
        builder: (context, viewModel, child) => Padding(
            padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 5),
            child: SingleChildScrollView(
                child: Column(children: <Widget>[
              const Text(
                'Rec Centers',
                style: TextStyle(
                    fontSize: 24,
                    fontFamily: 'Jost',
                    fontWeight: FontWeight.bold),
              ),
              SizedBox(
                  height: MediaQuery.of(context).size.height * .85,
                  child: RecCentersListWidget(
                      context, viewModel, viewModel.response))
            ]))));
  }

  Widget RecCentersListWidget(BuildContext context,
      RecCenterListViewModel viewModel, FirebaseResponse firebaseResponse) {
    switch (firebaseResponse.status) {
      case Status.LOADING:
        return const Center(
            child: CircularProgressIndicator(
          color: Colors.blue,
        ));
      case Status.COMPLETED:
        List<RecCenter> recCenters = firebaseResponse.data as List<RecCenter>;
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
                            print('navigating to thing to do detail');
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

  bool needToAnimate = true;

  Future<double> get _height => Future<double>.value(344);

  Widget RecCentersListItemWidget(BuildContext context,
      RecCenterListViewModel viewModel, RecCenter recCenter, int index) {
    return FutureBuilder<double>(
        future: _height,
        initialData: 0.0,
        builder: (context, snapshot) {
          return AnimatedContainer(
              curve: Curves.elasticOut,
              height: needToAnimate ? snapshot.data! : 344,
              duration: Duration(milliseconds: 2000),
              child: Card(
                color: MyConstants.cardBgColors[index],
                child: Padding(
                  padding:
                      const EdgeInsets.symmetric(vertical: 5, horizontal: 10),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Wrap(children: [
                        Text(
                          recCenter.name,
                          style: const TextStyle(
                              color: Colors.white,
                              fontSize: 20,
                              fontWeight: FontWeight.bold),
                        ),
                        Hero(
                          tag: 'rec_center_image$index',
                          child: SharedWidgets.networkImageWithLoading(
                              recCenter.imageUrl),
                        ),
                        Text(
                          recCenter.description,
                          maxLines: 4,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                          ),
                        ),
                      ]),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          Padding(
                              padding: EdgeInsets.fromLTRB(0, 0, 8, 0),
                              child: InkWell(
                                  onTap: () {
                                    if (recCenter.upVotes
                                        .contains(MyConstants.myFcmToken)) {
                                      recCenter.upVotes
                                          .remove(MyConstants.myFcmToken);
                                      viewModel.upVoteRecCenter(recCenter,
                                          MyConstants.myFcmToken, true);
                                      viewModel.downVoteRecCenter(recCenter,
                                          MyConstants.myFcmToken, false);
                                      setState(() {
                                        recCenter.upVotes
                                            .remove(MyConstants.myFcmToken);
                                        recCenter.downVotes
                                            .add(MyConstants.myFcmToken);
                                      });
                                    } else if (recCenter.downVotes
                                        .contains(MyConstants.myFcmToken)) {
                                      viewModel.downVoteRecCenter(recCenter,
                                          MyConstants.myFcmToken, true);
                                      setState(() {
                                        recCenter.downVotes
                                            .remove(MyConstants.myFcmToken);
                                      });
                                    } else {
                                      viewModel.downVoteRecCenter(recCenter,
                                          MyConstants.myFcmToken, false);
                                      setState(() {
                                        recCenter.downVotes
                                            .add(MyConstants.myFcmToken);
                                      });
                                    }
                                  },
                                  child: Wrap(
                                    crossAxisAlignment:
                                        WrapCrossAlignment.center,
                                    children: [
                                      Text(
                                        recCenter.downVotes.length.toString() +
                                            ' ',
                                        style: TextStyle(
                                          color: recCenter.downVotes.contains(
                                                  MyConstants.myFcmToken)
                                              ? Colors.blue
                                              : Colors.white,
                                          fontSize: 16,
                                        ),
                                      ),
                                      Icon(
                                        Icons.thumb_down_sharp,
                                        color: recCenter.downVotes.contains(
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
                                    if (recCenter.downVotes
                                        .contains(MyConstants.myFcmToken)) {
                                      recCenter.downVotes
                                          .remove(MyConstants.myFcmToken);
                                      viewModel.downVoteRecCenter(recCenter,
                                          MyConstants.myFcmToken, true);
                                      viewModel.upVoteRecCenter(recCenter,
                                          MyConstants.myFcmToken, false);
                                      setState(() {
                                        recCenter.downVotes
                                            .remove(MyConstants.myFcmToken);
                                        recCenter.upVotes
                                            .add(MyConstants.myFcmToken);
                                      });
                                    } else if (recCenter.upVotes
                                        .contains(MyConstants.myFcmToken)) {
                                      viewModel.upVoteRecCenter(recCenter,
                                          MyConstants.myFcmToken, true);
                                      setState(() {
                                        recCenter.upVotes
                                            .remove(MyConstants.myFcmToken);
                                      });
                                    } else {
                                      viewModel.upVoteRecCenter(recCenter,
                                          MyConstants.myFcmToken, false);
                                      setState(() {
                                        recCenter.upVotes
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
                                        color: recCenter.upVotes.contains(
                                                MyConstants.myFcmToken)
                                            ? Colors.blue
                                            : Colors.white,
                                      ),
                                      Text(
                                        ' ' +
                                            recCenter.upVotes.length.toString(),
                                        style: TextStyle(
                                          color: recCenter.upVotes.contains(
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
