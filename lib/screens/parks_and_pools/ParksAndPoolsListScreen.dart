import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sd_kids/models/ParksAndPools.dart';
import '../../main.dart';
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
        builder: (context, viewModel, child) => Padding(
            padding: EdgeInsets.all(10),
            child: SingleChildScrollView(
                child: Column(children: <Widget>[
              const Text(
                'Parks and Pools',
                style: TextStyle(
                    fontSize: 24,
                    fontFamily: 'Jost',
                    fontWeight: FontWeight.bold),
              ),
              SizedBox(
                  height: MediaQuery.of(context).size.height * .85,
                  child: ParksAndPoolsListWidget(context, viewModel.response))
            ]))));
  }

  Widget ParksAndPoolsListWidget(
      BuildContext context, FirebaseResponse firebaseResponse) {
    switch (firebaseResponse.status) {
      case Status.LOADING:
        return const Center(child: CircularProgressIndicator(color: Colors.blue,));
      case Status.COMPLETED:
        List<ParksAndPools> parksAndPools =
            firebaseResponse.data as List<ParksAndPools>;
        return NotificationListener<ScrollEndNotification>(
            onNotification: (notification) {
              needToAnimate = false;
              return false;
            },
            child: ListView.builder(
                shrinkWrap: true,
                physics: const ClampingScrollPhysics(),
                padding: const EdgeInsets.all(8),
                itemCount: parksAndPools.length,
                itemBuilder: (BuildContext context, int index) {
                  print(parksAndPools[index].toString());
                  return InkWell(
                      onTap: () {
                        print('navigating to parks and pool detail');
                        widget.appBarChange();
                        widget.navKey.currentState!.pushNamed(
                            NavRoutes.parkAndPoolDetailsRoute,
                            arguments: {
                              'park_and_pool': parksAndPools[index],
                              'index': index
                            });
                      },
                      child: ParksAndPoolsListItemWidget(
                          context, parksAndPools[index], index));
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

  Future<double> get _height => Future<double>.value(335);

  Widget ParksAndPoolsListItemWidget(
      BuildContext context, ParksAndPools parkAndPool, int index) {
    return FutureBuilder<double>(
        future: _height,
        initialData: 0.0,
        builder: (context, snapshot) {
          return AnimatedContainer(
              padding: EdgeInsets.symmetric(vertical: 5),
              curve: Curves.elasticOut,
              height: needToAnimate ? snapshot.data! : 335,
              duration: Duration(milliseconds: 2000),
              child: Card(
                color: MyConstants.cardBgColors[index],
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Flexible(
                              child: Text(
                            parkAndPool.name,
                            style: const TextStyle(
                                color: Colors.white,
                                fontSize: 20,
                                fontWeight: FontWeight.bold),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          )),
                          Text(
                            "\$${parkAndPool.price}",
                            style: const TextStyle(
                                color: Colors.white,
                                fontSize: 20,
                                fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                      Hero(
                        tag: 'park_and_pool_image$index',
                        child: SharedWidgets.networkImageWithLoading(parkAndPool.imageUrl),
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
                ),
              ));
        });
  }
}
