import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sd_kids/main.dart';
import 'package:sd_kids/models/Resource.dart';
import 'package:sd_kids/viewModel/ResourcesListViewModel.dart';

import '../../models/FirebaseResponse.dart';
import '../../util/constants.dart' as Constants;
import '../shared/SharedWidgets.dart';

class ResourcesListScreen extends StatefulWidget {
  final GlobalKey<NavigatorState> navKey;
  final Function() appBarChange;

  const ResourcesListScreen(
      {super.key, required this.appBarChange, required this.navKey});

  @override
  State<ResourcesListScreen> createState() => _ResourcesListScreenState();
}

class _ResourcesListScreenState extends State<ResourcesListScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        context.read<ResourcesListViewModel>().clearData();
        context.read<ResourcesListViewModel>().getResources();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ResourcesListViewModel>(
        builder: (context, viewModel, child) {
          switch (viewModel.response.status) {
            case Status.LOADING:
              return const Center(
                  child: CircularProgressIndicator(color: Colors.blue,));
            case Status.COMPLETED:
              List<String> types = viewModel.response.data['types'];
              List<Resource> resourcesAllTypes =
              viewModel.response.data['resources'];
              return Padding(
                  padding: const EdgeInsets.fromLTRB(10, 10, 10, 80),
                  child: SingleChildScrollView(
                      child: ListView.builder(
                          shrinkWrap: true,
                          physics: const ClampingScrollPhysics(),
                          padding: const EdgeInsets.symmetric(
                              vertical: 8, horizontal: 4),
                          itemCount: types.length,
                          itemBuilder: (BuildContext context, int index) {
                            return ResourcesByType(
                              viewModel,
                                types,
                                types[index],
                                resourcesAllTypes
                                    .where((resource) =>
                                    resource.types.contains(types[index]))
                                    .toList());
                          })));
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

  Future<double> get _height =>
      Future<double>.value(Constants.isMobile
          ? Constants.itemAnimatedContainerShortHeightMobile - 10
          : Constants.itemAnimatedContainerShortHeightTablet);

  Widget ResourcesByType(ResourcesListViewModel viewModel,
      List<String> types, String type, List<Resource> resources) {
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
                        itemCount: resources.length,
                        itemBuilder: (BuildContext context, int index) {
                          return InkWell(
                              onTap: () {
                                print('navigating to resource detail');
                                widget.appBarChange();
                                widget.navKey.currentState!.pushNamed(
                                    NavRoutes.resourceDetailsRoute,
                                    arguments: {
                                      'resource': resources[index],
                                      'type': type,
                                      'index': index
                                    });
                              },
                              child: ResourceListItemWidget(context, viewModel,
                                  resources[index], types, type, index));
                        }))
              ]));
        });
  }

  Widget ResourceListItemWidget(BuildContext context,
      ResourcesListViewModel viewModel, Resource resource,
      List<String> types, String type, int index) {
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
                    SharedWidgets.itemTitleWidget(resource.name),
                    Hero(
                      tag: 'resource_image$type$index',
                      child: SharedWidgets.networkImageWithLoading(
                          resource.imageUrl),
                    ),
                    const SizedBox(
                      height: 8,
                    ),
                    SharedWidgets.itemDescriptionWidget(resource.description),
                    Spacer(),
                    likesDislikesWidget(resource, viewModel)
                  ],
                ))));
  }
  
  Widget likesDislikesWidget(Resource resource, ResourcesListViewModel viewModel){
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        Padding(padding: EdgeInsets.fromLTRB(0, 0, 8, 0),
            child: InkWell(
                onTap: () {
                  if (resource.upVotes.contains(
                      Constants.myFcmToken)) {
                    resource.upVotes.remove(Constants
                        .myFcmToken);
                    viewModel.upVoteResource(
                        resource, Constants.myFcmToken, true);
                    viewModel.downVoteResource(
                        resource, Constants.myFcmToken,
                        false);
                    setState(() {
                      resource.upVotes.remove(
                          Constants.myFcmToken);
                      resource.downVotes.add(
                          Constants.myFcmToken);
                    });
                  }
                  else if (resource.downVotes.contains(
                      Constants.myFcmToken)) {
                    viewModel.downVoteResource(resource,
                        Constants.myFcmToken, true);
                    setState(() {
                      resource.downVotes.remove(
                          Constants.myFcmToken);
                    });
                  }
                  else {
                    viewModel.downVoteResource(
                        resource, Constants.myFcmToken,
                        false);
                    setState(() {
                      resource.downVotes.add(
                          Constants.myFcmToken);
                    });
                  }
                },
                child: Wrap(
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [
                    Text(resource.downVotes.length.toString() +
                        ' ', style: TextStyle(
                      color: resource.downVotes.contains(
                          Constants.myFcmToken)
                          ? Colors.blue
                          : Colors.white,
                      fontSize: Constants.isMobile
                          ? Constants
                          .itemFooterFontSizeMobile
                          : Constants
                          .itemFooterFontSizeTablet,),),
                    Icon(
                      Icons.thumb_down_sharp,
                      size: Constants.isMobile
                          ? Constants.iconSizeMobile
                          : Constants.iconSizeTablet,
                      color: resource.downVotes.contains(
                          Constants.myFcmToken)
                          ? Colors.blue
                          : Colors.white,),
                  ],
                ))),
        Padding(padding: EdgeInsets.fromLTRB(8, 0, 0, 0),
            child: InkWell(
                onTap: () {
                  if (resource.downVotes.contains(
                      Constants.myFcmToken)) {
                    resource.downVotes.remove(Constants
                        .myFcmToken);
                    viewModel.downVoteResource(
                        resource, Constants.myFcmToken, true);
                    viewModel.upVoteResource(
                        resource, Constants.myFcmToken,
                        false);
                    setState(() {
                      resource.downVotes.remove(
                          Constants.myFcmToken);
                      resource.upVotes.add(
                          Constants.myFcmToken);
                    });
                  }
                  else if (resource.upVotes.contains(
                      Constants.myFcmToken)) {
                    viewModel.upVoteResource(resource,
                        Constants.myFcmToken, true);
                    setState(() {
                      resource.upVotes.remove(
                          Constants.myFcmToken);
                    });
                  }
                  else {
                    viewModel.upVoteResource(
                        resource, Constants.myFcmToken,
                        false);
                    setState(() {
                      resource.upVotes.add(
                          Constants.myFcmToken);
                    });
                  }
                },
                child: Wrap(
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [
                    Icon(Icons.thumb_up_sharp,
                      size: Constants.isMobile
                          ? Constants.iconSizeMobile
                          : Constants.iconSizeTablet,
                      color: resource.upVotes.contains(
                          Constants.myFcmToken)
                          ? Colors.blue
                          : Colors.white,
                    ),
                    Text(' ' + resource.upVotes.length
                        .toString(), style: TextStyle(
                      color: resource.upVotes.contains(
                          Constants.myFcmToken)
                          ? Colors.blue
                          : Colors.white,
                      fontSize: Constants.isMobile
                          ? Constants
                          .itemFooterFontSizeMobile
                          : Constants
                          .itemFooterFontSizeTablet,),),
                  ],
                )))
      ],);
  }
}
