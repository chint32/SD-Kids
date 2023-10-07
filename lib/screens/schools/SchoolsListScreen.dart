import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sd_kids/main.dart';
import 'package:sd_kids/models/School.dart';
import 'package:sd_kids/viewModel/SchoolsListViewModel.dart';

import '../../models/FirebaseResponse.dart';
import '../../util/constants.dart' as Constants;
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
    super.initState();
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
          return const Center(
              child: CircularProgressIndicator(
            color: Colors.blue,
          ));
        case Status.COMPLETED:
          List<String> types = viewModel.response.data['types'];
          List<School> schoolsAllTypes = viewModel.response.data['schools'];
          return Padding(
              padding: const EdgeInsets.fromLTRB(10, 10, 10, 80),
              child: SingleChildScrollView(
                  child: Column(children: <Widget>[
                SharedWidgets.screenTitle('Schools'),
                    ListView.builder(
                        shrinkWrap: true,
                        physics: const ClampingScrollPhysics(),
                        padding: const EdgeInsets.symmetric(
                            vertical: 8, horizontal: 4),
                        itemCount: types.length,
                        itemBuilder: (BuildContext context, int index) {
                          return SchoolsByType(
                              viewModel,
                              types,
                              types[index],
                              schoolsAllTypes
                                  .where((school) =>
                                  school.types.contains(types[index]))
                                  .toList());
                        })
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

  Future<double> get _height => Future<double>.value(Constants.isMobile
      ? Constants.itemAnimatedContainerShortHeightMobile - 10
      : Constants.itemAnimatedContainerShortHeightTablet);

  Widget SchoolsByType(SchoolsListViewModel viewModel, List<String> types,
      String type, List<School> schools) {
    return FutureBuilder<double>(
        future: _height,
        initialData: 0.0,
        builder: (context, snapshot) {
          return AnimatedContainer(
              padding: EdgeInsets.symmetric(vertical: 10),
              curve: Curves.elasticOut,
              height: snapshot.data!,
              duration: Duration(milliseconds: 1000),
              child: Column(children: [
                Container(
                    width: double.infinity,
                    child: Padding(
                        padding:
                            EdgeInsets.symmetric(vertical: 0, horizontal: 3),
                        child: Text(type,
                            textAlign: TextAlign.start,
                            style: TextStyle(
                                fontSize: Constants.isMobile
                                    ? Constants.itemTitleFontSizeMobile
                                    : Constants.itemTitleFontSizeTablet,
                                fontWeight: FontWeight.bold)))),
                Container(
                    height: Constants.isMobile
                        ? Constants.itemContainerHeightShortMobile - 10
                        : Constants.itemContainerHeightShortTablet,
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
                              child: SchoolListItemWidget(context, viewModel,
                                  schools[index], types, type, index));
                        }))
              ]));
        });
  }

  Widget SchoolListItemWidget(
      BuildContext context,
      SchoolsListViewModel viewModel,
      School school,
      List<String> types,
      String type,
      int index) {
    return Container(
        width: Constants.isMobile
            ? Constants.itemCardWidthMobile
            : Constants.itemCardWidthTablet,
        child: Card(
            color: Constants.cardBgColors[types.indexOf(type)],
            child: Padding(
                padding: const EdgeInsets.all(10),
                child: Column(
                  children: [
                    SharedWidgets.itemTitleWidget(school.name),
                    Hero(
                      tag: 'school_image$type$index',
                      child: SharedWidgets.networkImageWithLoading(
                          school.imageUrl),
                    ),
                    const SizedBox(
                      height: 8,
                    ),
                    SharedWidgets.itemDescriptionWidget(school.description),
                    Spacer(),
                    likesDislikesWidget(school, viewModel)
                  ],
                ))));
  }
  
  Widget likesDislikesWidget(School school, SchoolsListViewModel viewModel){
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        Padding(
            padding: EdgeInsets.fromLTRB(0, 0, 8, 0),
            child: InkWell(
                onTap: () {
                  if (school.upVotes
                      .contains(Constants.myFcmToken)) {
                    school.upVotes.remove(Constants.myFcmToken);
                    viewModel.upVoteSchool(
                        school, Constants.myFcmToken, true);
                    viewModel.downVoteSchool(
                        school, Constants.myFcmToken, false);
                    setState(() {
                      school.upVotes
                          .remove(Constants.myFcmToken);
                      school.downVotes
                          .add(Constants.myFcmToken);
                    });
                  } else if (school.downVotes
                      .contains(Constants.myFcmToken)) {
                    viewModel.downVoteSchool(
                        school, Constants.myFcmToken, true);
                    setState(() {
                      school.downVotes
                          .remove(Constants.myFcmToken);
                    });
                  } else {
                    viewModel.downVoteSchool(
                        school, Constants.myFcmToken, false);
                    setState(() {
                      school.downVotes
                          .add(Constants.myFcmToken);
                    });
                  }
                },
                child: Wrap(
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [
                    Text(
                      school.downVotes.length.toString() + ' ',
                      style: TextStyle(
                        color: school.downVotes
                            .contains(Constants.myFcmToken)
                            ? Colors.blue
                            : Colors.white,
                        fontSize: Constants.isMobile
                            ? Constants.itemFooterFontSizeMobile
                            : Constants
                            .itemFooterFontSizeTablet,
                      ),
                    ),
                    Icon(
                      Icons.thumb_down_sharp,
                      size: Constants.isMobile
                          ? Constants.iconSizeMobile
                          : Constants.iconSizeTablet,
                      color: school.downVotes
                          .contains(Constants.myFcmToken)
                          ? Colors.blue
                          : Colors.white,
                    ),
                  ],
                ))),
        Padding(
            padding: EdgeInsets.fromLTRB(8, 0, 0, 0),
            child: InkWell(
                onTap: () {
                  if (school.downVotes
                      .contains(Constants.myFcmToken)) {
                    school.downVotes
                        .remove(Constants.myFcmToken);
                    viewModel.downVoteSchool(
                        school, Constants.myFcmToken, true);
                    viewModel.upVoteSchool(
                        school, Constants.myFcmToken, false);
                    setState(() {
                      school.downVotes
                          .remove(Constants.myFcmToken);
                      school.upVotes.add(Constants.myFcmToken);
                    });
                  } else if (school.upVotes
                      .contains(Constants.myFcmToken)) {
                    viewModel.upVoteSchool(
                        school, Constants.myFcmToken, true);
                    setState(() {
                      school.upVotes
                          .remove(Constants.myFcmToken);
                    });
                  } else {
                    viewModel.upVoteSchool(
                        school, Constants.myFcmToken, false);
                    setState(() {
                      school.upVotes.add(Constants.myFcmToken);
                    });
                  }
                },
                child: Wrap(
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [
                    Icon(
                      Icons.thumb_up_sharp,
                      size: Constants.isMobile
                          ? Constants.iconSizeMobile
                          : Constants.iconSizeTablet,
                      color: school.upVotes
                          .contains(Constants.myFcmToken)
                          ? Colors.blue
                          : Colors.white,
                    ),
                    Text(
                      ' ' + school.upVotes.length.toString(),
                      style: TextStyle(
                        color: school.upVotes
                            .contains(Constants.myFcmToken)
                            ? Colors.blue
                            : Colors.white,
                        fontSize: Constants.isMobile
                            ? Constants.itemFooterFontSizeMobile
                            : Constants
                            .itemFooterFontSizeTablet,
                      ),
                    ),
                  ],
                )))
      ],
    );
  }
}
