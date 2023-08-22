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
          return const Center(child: CircularProgressIndicator(color: Colors.blue,));
        case Status.COMPLETED:
          List<String> categories = viewModel.response.data['categories'];
          List<ThingToDo> thingsToDoAllCategories =
              viewModel.response.data['thingsToDo'];
          return Padding(
              padding: const EdgeInsets.fromLTRB(10, 10, 10, 60),
              child: SingleChildScrollView(
                  child: Column(children: <Widget>[
                const Text(
                  'Things To Do',
                  style: TextStyle(
                      fontSize: 24,
                      fontFamily: 'Jost',
                      fontWeight: FontWeight.bold),
                ),
                for (var category in categories)
                  ThingsToDoByCategory(
                      categories,
                      category,
                      thingsToDoAllCategories
                          .where((thingToDo) =>
                              thingToDo.categories.contains(category))
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

  Future<double> get _height => Future<double>.value(390);

  Widget ThingsToDoByCategory(
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
                    height: 337,
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
                                  thingsToDo[index],
                                  categories,
                                  category,
                                  index));
                        }))
              ]));
        });
  }

  Widget ThingToDoListItemWidget(BuildContext context, ThingToDo thingToDo,
      List<String> categories, String category, int index) {
    return Container(
        width: 300,
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
                      child: SharedWidgets.networkImageWithLoading(thingToDo.imageUrl),
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
                  ],
                ))));
  }
}
