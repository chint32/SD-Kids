import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sd_kids/main.dart';
import 'package:sd_kids/models/School.dart';
import 'package:sd_kids/viewModel/SchoolsListViewModel.dart';

import '../../models/FirebaseResponse.dart';
import '../../util/constants.dart';
import '../shared/SharedWidgets.dart';

class SchoolsListScreen extends StatefulWidget {
  final GlobalKey<NavigatorState> navKey;
  final Function() appBarChange;

  const SchoolsListScreen(
      {super.key, required this.appBarChange, required this.navKey});

  @override
  State<SchoolsListScreen> createState() => _SchoolsListScreenState();
}

class _SchoolsListScreenState extends State<SchoolsListScreen> {
  @override
  void initState() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        context.read<SchoolsListViewModel>().clearData();
        context.read<SchoolsListViewModel>().getSchools();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    print('Schools List Screen');

    return Consumer<SchoolsListViewModel>(builder: (context, viewModel, child) {
      switch (viewModel.response.status) {
        case Status.LOADING:
          return const Center(child: CircularProgressIndicator(color: Colors.blue,));
        case Status.COMPLETED:
          List<String> types = viewModel.response.data['types'];
          List<School> schoolsAllTypes = viewModel.response.data['schools'];
          return Padding(
              padding: const EdgeInsets.fromLTRB(10, 10, 10, 60),
              child: SingleChildScrollView(
                  child: Column(children: <Widget>[
                const Text(
                  'Schools',
                  style: TextStyle(
                      fontSize: 24,
                      fontFamily: 'Jost',
                      fontWeight: FontWeight.bold),
                ),
                for (var type in types)
                  SchoolsByType(
                      types,
                      type,
                      schoolsAllTypes
                          .where((school) => school.types.contains(type))
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

  Widget SchoolsByType(List<String> types, String type, List<School> schools) {
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
                        child: Text(type,
                            textAlign: TextAlign.start,
                            style: const TextStyle(
                                fontSize: 20, fontWeight: FontWeight.bold)))),
                Container(
                    height: 337,
                    child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        shrinkWrap: true,
                        physics: const ClampingScrollPhysics(),
                        itemCount: schools.length,
                        itemBuilder: (BuildContext context, int index) {
                          return InkWell(
                              onTap: () {
                                print('navigating to school detail');
                                widget.appBarChange();
                                widget.navKey.currentState!.pushNamed(
                                    NavRoutes.schoolDetailsRoute,
                                    arguments: {
                                      'school': schools[index],
                                      'type': type,
                                      'index': index
                                    });
                              },
                              child: SchoolListItemWidget(
                                  context, schools[index], types, type, index));
                        }))
              ]));
        });
  }

  Widget SchoolListItemWidget(BuildContext context, School school,
      List<String> types, String type, int index) {
    return Container(
        width: 300,
        height: 280,
        child: Card(
            color: MyConstants.cardBgColors[types.indexOf(type)],
            child: Padding(
                padding: const EdgeInsets.all(10),
                child: Column(
                  children: [
                    Text(
                      school.name,
                      style: const TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.bold),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    Hero(
                      tag: 'school_image$type$index',
                      child: SharedWidgets.networkImageWithLoading(school.imageUrl),
                    ),
                    const SizedBox(
                      height: 8,
                    ),
                    Text(
                      school.description,
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
