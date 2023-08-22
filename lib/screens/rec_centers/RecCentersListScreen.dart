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
                  child: RecCentersListWidget(context, viewModel.response))
            ]))));
  }

  Widget RecCentersListWidget(
      BuildContext context, FirebaseResponse firebaseResponse) {
    switch (firebaseResponse.status) {
      case Status.LOADING:
        return const Center(child: CircularProgressIndicator(color: Colors.blue,));
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
                  return Padding(padding: EdgeInsets.symmetric(vertical: 10), child: InkWell(
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
                          context, recCenters[index], index)));
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
  Future<double> get _height => Future<double>.value(322);

  Widget RecCentersListItemWidget(
      BuildContext context, RecCenter recCenter, int index) {
    return FutureBuilder<double>(
        future: _height,
        initialData: 0.0,
        builder: (context, snapshot) {
          return AnimatedContainer(
              curve: Curves.elasticOut,
              height: needToAnimate ? snapshot.data! : 322,
              duration: Duration(milliseconds: 2000),
              child: Card(
                color: MyConstants.cardBgColors[index],
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 5, horizontal: 10),
                  child: Column(
                    children: [
                      Text(
                        recCenter.name,
                        style: const TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                            fontWeight: FontWeight.bold),
                      ),
                      Hero(
                        tag: 'rec_center_image$index',
                        child: SharedWidgets.networkImageWithLoading(recCenter.imageUrl),
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
                    ],
                  ),
                ),
              ));
        });
  }
}
