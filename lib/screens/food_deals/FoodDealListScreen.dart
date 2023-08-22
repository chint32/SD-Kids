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
          return const Center(child: CircularProgressIndicator(color: Colors.blue,));
        case Status.COMPLETED:
          List<FoodDeal> foodDealsAllDays =
              viewModel.response.data as List<FoodDeal>;
          return Padding(
              padding: const EdgeInsets.fromLTRB(10, 10, 10, 60),
              child: SingleChildScrollView(
                  child: Column(children: <Widget>[
                const Text(
                  'Food Deals',
                  style: TextStyle(
                      fontSize: 24,
                      fontFamily: 'Jost',
                      fontWeight: FontWeight.bold),
                ),
                    for (var dayOfWeek in daysOfWeek)
                      foodDealsByDayOfWeek(
                          dayOfWeek,
                          foodDealsAllDays
                              .where((foodDeal) => foodDeal.daysOfWeek.contains(dayOfWeek))
                              .toList())
              ])));
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
  Future<double> get _height => Future<double>.value(372);
  Widget foodDealsByDayOfWeek(String dayOfWeek, List<FoodDeal> foodDeals) {
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
                            style: const TextStyle(
                                fontSize: 20, fontWeight: FontWeight.bold)))),
                    Container(
                        height: 330,
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
                                  child: FoodDealListItemWidget(context,
                                      foodDeals[index], dayOfWeek, index));
                            }))
              ]));
        });
  }

  Widget FoodDealListItemWidget(
      BuildContext context, FoodDeal foodDeal, String dayOfWeek, int index) {
    return Container(
        width: 300,
        height: 280,
        child: Card(
            color: MyConstants.cardBgColors[daysOfWeek.indexOf(dayOfWeek)],
            child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 5, horizontal: 10),
                child: Column(
                  children: [
                    Text(
                      foodDeal.name,
                      style: const TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.bold),
                    ),
                    Hero(
                      tag: 'food_deal_image$dayOfWeek$index',
                      child: SharedWidgets.networkImageWithLoading(foodDeal.imageUrl),
                    ),
                    const SizedBox(
                      height: 8,
                    ),
                    Text(
                      foodDeal.description,
                      maxLines: 4,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.bold),
                    ),
                  ],
                ))));
  }
}
