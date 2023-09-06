import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:sd_kids/main.dart';
import 'package:sd_kids/models/Event.dart';
import 'package:sd_kids/models/FirebaseResponse.dart';
import 'package:sd_kids/viewModel/EventListViewModel.dart';
import '../../util/constants.dart';
import '../shared/SharedWidgets.dart';

class EventsListScreen extends StatefulWidget {
  final GlobalKey<NavigatorState> navKey;
  final Function() appBarChange;

  const EventsListScreen({
    super.key,
    required this.appBarChange,
    required this.navKey,
  });

  @override
  State<EventsListScreen> createState() => _EventsListScreenState();
}

class _EventsListScreenState extends State<EventsListScreen> {
  final List<String> _items = [ 'Date', 'Price', 'Age group',];
  bool isSortingMenuVisible = false;
  double _sortMenuHeight = 0;

  @override
  void initState() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        context.read<EventListViewModel>().clearData();
        context.read<EventListViewModel>().getEvents();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<EventListViewModel>(builder: (context, viewModel, child) {
      switch (viewModel.response.status) {
        case Status.LOADING:
          return const Center(
              child: CircularProgressIndicator(
            color: Colors.blue,
          ));
        case Status.COMPLETED:
          List<String> ageGroups = viewModel.response.data['ageGroups'];
          List<String> categories = viewModel.response.data['categories'];
          List<Event> eventsAllCategories = viewModel.response.data['events'];
          return Padding(
              padding: const EdgeInsets.fromLTRB(10, 10, 10, 80),
              child: Column(children: [
                Text(
                  'Events',
                  style: TextStyle(
                      fontSize: MyConstants.isMobile ? MyConstants.screenTitleFontSizeMobile : MyConstants.screenTitleFontSizeTablet,
                      fontFamily: 'Jost',
                      fontWeight: FontWeight.bold),
                ),
                Card(
                    color: Colors.white70,
                    child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: Column(
                          children: [
                            Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    'Sort by',
                                    style: TextStyle(
                                        fontSize: MyConstants.isMobile ? MyConstants.sortMenuFontSizeMobile : MyConstants.sortMenuFontSizeTablet,
                                        fontFamily: 'Jost'
                                    ),
                                  ),
                                  RotatedBox(
                                      quarterTurns:
                                          isSortingMenuVisible ? 2 : 0,
                                      child: IconButton(
                                        icon: Icon(
                                          Icons.arrow_drop_down,
                                          size: MyConstants.isMobile ? MyConstants.iconSizeMobile : MyConstants.iconSizeTablet,
                                        ),
                                        onPressed: () {
                                          setState(() {
                                            isSortingMenuVisible =
                                                !isSortingMenuVisible;
                                            if (isSortingMenuVisible) {
                                              _sortMenuHeight = MyConstants.isMobile ? 120 : 136;
                                            } else {
                                              _sortMenuHeight = 0;
                                            }
                                          });
                                        },
                                      )),
                                ]),
                            if (isSortingMenuVisible)
                              Padding(
                                  padding: EdgeInsets.fromLTRB(0, 0, 0, 10),
                                  child: Divider(
                                    height: 2,
                                  )),
                            AnimatedContainer(
                              curve: Curves.linearToEaseOut,
                              duration: Duration(milliseconds: 500),
                              height: _sortMenuHeight,
                              child: ReorderableListView(
                                children: <Widget>[
                                  for (int index = 0;
                                      index < _items.length;
                                      index += 1)
                                    Column(
                                      key: Key('$index'),
                                      children: [
                                        Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceBetween,
                                            children: [
                                              Text(
                                                _items[index],
                                                style: TextStyle(
                                                    fontSize: MyConstants.isMobile ? MyConstants.sortMenuFontSizeMobile : MyConstants.sortMenuFontSizeTablet,
                                                    fontFamily: 'Jost'),
                                              ),
                                              ReorderableDragStartListener(
                                                  key: ValueKey<String>(
                                                      _items[index]),
                                                  index: index,
                                                  child: Padding(
                                                    padding:
                                                        const EdgeInsets.fromLTRB(
                                                            0, 0, 10, 0),
                                                    child: Icon(
                                                      Icons.drag_handle,
                                                      size: MyConstants.isMobile ? MyConstants.iconSizeMobile : MyConstants.iconSizeTablet,
                                                    ),
                                                  )),
                                            ]),
                                        SizedBox(
                                          height: 10,
                                        )
                                      ],
                                    )
                                ],
                                onReorder: (int oldIndex, int newIndex) {
                                  setState(() {
                                    if (oldIndex < newIndex) {
                                      newIndex -= 1;
                                    }
                                    final String item =
                                        _items.removeAt(oldIndex);
                                    _items.insert(newIndex, item);

                                    if (_items[0] == 'Age group' &&
                                        _items[1] == 'Price') {
                                      eventsAllCategories.sort((a, b) {
                                        int cmp = ageGroups
                                            .indexOf(a.ageGroups[0])
                                            .compareTo(ageGroups
                                                .indexOf(b.ageGroups[0]));
                                        if (cmp != 0) return cmp;
                                        return a.price.compareTo(b.price);
                                      });
                                    } else if (_items[0] == 'Date' &&
                                        _items[1] == 'Price') {
                                      eventsAllCategories.sort((a, b) {
                                        int cmp = a.startDateTime
                                            .compareTo(b.startDateTime);
                                        if (cmp != 0) return cmp;
                                        return a.price.compareTo(b.price);
                                      });
                                    } else if (_items[0] == 'Date' &&
                                        _items[1] == 'Age group') {
                                      eventsAllCategories.sort((a, b) {
                                        int cmp = a.startDateTime
                                            .compareTo(b.startDateTime);
                                        if (cmp != 0) return cmp;
                                        return ageGroups
                                            .indexOf(a.ageGroups[0])
                                            .compareTo(ageGroups
                                                .indexOf(b.ageGroups[0]));
                                      });
                                    } else if (_items[0] == 'Price' &&
                                        _items[1] == 'Age group') {
                                      eventsAllCategories.sort((a, b) {
                                        int cmp = a.price.compareTo(b.price);
                                        if (cmp != 0) return cmp;
                                        return ageGroups
                                            .indexOf(a.ageGroups[0])
                                            .compareTo(ageGroups
                                                .indexOf(b.ageGroups[0]));
                                      });
                                    } else if (_items[0] == 'Age group' &&
                                        _items[1] == 'Date') {
                                      eventsAllCategories.sort((a, b) {
                                        int cmp = ageGroups
                                            .indexOf(a.ageGroups[0])
                                            .compareTo(ageGroups
                                                .indexOf(b.ageGroups[0]));
                                        if (cmp != 0) return cmp;
                                        return a.startDateTime
                                            .compareTo(b.startDateTime);
                                      });
                                    } else if (_items[0] == 'Price' &&
                                        _items[1] == 'Date') {
                                      eventsAllCategories.sort((a, b) {
                                        int cmp = a.price.compareTo(b.price);
                                        if (cmp != 0) return cmp;
                                        return a.startDateTime
                                            .compareTo(b.startDateTime);
                                      });
                                    }
                                  });
                                },
                              ),
                            )
                          ],
                        ))),
                SizedBox(height: 10),
                Expanded(
                    child: SingleChildScrollView(
                        child:Column( children: [
                  for (var category in categories)
                    eventsByCategory(
                        category,
                        eventsAllCategories
                            .where(
                                (event) => event.categories.contains(category))
                            .toList(),
                        categories)
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
    });
  }

  Future<double> get _height => Future<double>.value(MyConstants.isMobile ? MyConstants.itemAnimatedContainerHeightMobile : MyConstants.itemAnimatedContainerHeightTablet);

  Widget eventsByCategory(
      String category, List<Event> events, List<String> categories) {
    return FutureBuilder<double>(
        future: _height,
        initialData: 0.0,
        builder: (context, snapshot) {
          return AnimatedContainer(
              padding: EdgeInsets.symmetric(vertical: 10),
              curve: Curves.elasticOut,
              height: snapshot.data!,
              duration: Duration(milliseconds: 2000),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                Container(
                    width: double.infinity,
                    child: Padding(
                        padding:
                            EdgeInsets.symmetric(vertical: 0, horizontal: 3),
                        child: Text(category,
                            textAlign: TextAlign.center,
                            style: TextStyle(
                                fontSize: MyConstants.isMobile ? MyConstants.itemTitleFontSizeMobile : MyConstants.itemTitleFontSizeTablet,
                                fontWeight: FontWeight.bold)))),
                Container(
                    height: MyConstants.isMobile ? MyConstants.itemContainerHeightMobile : MyConstants.itemContainerHeightTablet,
                    child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        shrinkWrap: true,
                        physics: const ClampingScrollPhysics(),
                        itemCount: events.length,
                        itemBuilder: (BuildContext context, int index) {
                          return InkWell(
                              onTap: () {
                                print('navigating to event detail');
                                widget.appBarChange();
                                widget.navKey.currentState!.pushNamed(
                                    NavRoutes.eventDetailsRoute,
                                    arguments: {
                                      'event': events[index],
                                      'category': category,
                                      'index': index
                                    });
                              },
                              child: EventListItemWidget(context, events[index],
                                  categories, category, index));
                        }))
              ]));
        });
  }

  Widget EventListItemWidget(BuildContext context, Event event,
      List<String> categories, String category, int index) {
    String date = DateFormat('EEEE, MM/dd/yyyy, hh:mm a')
        .format(event.startDateTime.toDate());
    // [0] - DoW, [1] = Date, [2] = Time
    List<String> dateParts = date.split(', ');
    List<String> monthDayYear = dateParts[1].split('/');
    return Container(
        width: MyConstants.isMobile ? MyConstants.itemCardWidthMobile : MyConstants.itemCardWidthTablet,
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
                          event.title,
                          style: TextStyle(
                              color: Colors.white,
                              fontSize: MyConstants.isMobile ? MyConstants.itemTitleFontSizeMobile : MyConstants.itemTitleFontSizeTablet,
                              fontWeight: FontWeight.bold),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        )),
                        Text(
                          "\$${event.price}",
                          style: TextStyle(
                              color: Colors.white,
                              fontSize: MyConstants.isMobile ? MyConstants.itemTitleFontSizeMobile : MyConstants.itemTitleFontSizeTablet,
                              fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                    Hero(
                      tag: 'event_image$category$index',
                      child:
                          SharedWidgets.networkImageWithLoading(event.imageUrl),
                    ),
                    const SizedBox(
                      height: 6,
                    ),
                    Text(
                      '${dateParts[0]}, ${monthDayYear[0]}/${monthDayYear[1]}, ${dateParts[2]}',
                      style: TextStyle(
                          fontSize: MyConstants.isMobile ? MyConstants.itemSubtitleFontSizeMobile : MyConstants.itemSubtitleFontSizeTablet,
                          fontWeight: FontWeight.bold,
                          color: Colors.white),
                    ),
                    const SizedBox(
                      height: 4,
                    ),
                    Text(
                      event.description,
                      textAlign: TextAlign.justify,
                      maxLines: 4,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: MyConstants.isMobile ? MyConstants.itemDescriptionFontSizeMobile : MyConstants.itemDescriptionFontSizeTablet,
                          fontWeight: FontWeight.bold),
                    ),
                    Spacer(),
                    Row(
                      children: [
                        for (var group in event.ageGroups)
                          Container(
                            padding: EdgeInsets.symmetric(horizontal: 4),
                            height: MyConstants.isMobile ? MyConstants.itemAgeGroupHeightMobile : MyConstants.itemAgeGroupHeightTablet,
                            decoration: BoxDecoration(
                              color: Color(0xff568f56),
                              borderRadius:
                                  BorderRadius.all(Radius.circular(20)),
                            ),
                            child: Center(
                                child: Text(
                              group,
                              style: TextStyle(
                                color: Colors.white,
                                overflow: TextOverflow.ellipsis,
                                fontSize: MyConstants.isMobile ? MyConstants.itemAgeGroupFontSizeMobile : MyConstants.itemAgeGroupFontSizeTablet,
                              ),
                            )),
                          )
                      ],
                    )
                  ],
                ))));
  }
}
