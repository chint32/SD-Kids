import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:sd_kids/main.dart';
import 'package:sd_kids/models/Event.dart';
import 'package:sd_kids/models/FirebaseResponse.dart';
import 'package:sd_kids/viewModel/EventListViewModel.dart';
import '../../util/constants.dart' as Constants;
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
  final List<String> _items = [
    'Date',
    'Price',
    'Age group',
  ];
  bool isSortingMenuVisible = false;
  double _sortMenuHeight = 0;
  List<String> ageGroups = [];
  List<Event> eventsAllCategories = [];

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
          ageGroups = viewModel.response.data['ageGroups'];
          List<String> categories = viewModel.response.data['categories'];
          eventsAllCategories = viewModel.response.data['events'];
          return Padding(
              padding: const EdgeInsets.fromLTRB(10, 10, 10, 80),
              child: Column(children: [
                SharedWidgets.screenTitle('Events'),
                SharedWidgets.SortMenu(_items, _sortMenuHeight,
                    isSortingMenuVisible, onOpenClose, onReorder),
                SizedBox(height: 10),
                Expanded(
                    child: SingleChildScrollView(
                        child: Column(children: [
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

  void onOpenClose() {
    setState(() {
      isSortingMenuVisible = !isSortingMenuVisible;
      if (isSortingMenuVisible) {
        _sortMenuHeight = Constants.isMobile ? 120 : 136;
      } else {
        _sortMenuHeight = 0;
      }
    });
  }

  void onReorder(int oldIndex, int newIndex) {
    setState(() {
      if (oldIndex < newIndex) {
        newIndex -= 1;
      }
      final String item = _items.removeAt(oldIndex);
      _items.insert(newIndex, item);

      if (_items[0] == 'Age group' && _items[1] == 'Price') {
        eventsAllCategories.sort((a, b) {
          int cmp = ageGroups
              .indexOf(a.ageGroups[0])
              .compareTo(ageGroups.indexOf(b.ageGroups[0]));
          if (cmp != 0) return cmp;
          return a.price.compareTo(b.price);
        });
      } else if (_items[0] == 'Date' && _items[1] == 'Price') {
        eventsAllCategories.sort((a, b) {
          int cmp = a.startDateTime.compareTo(b.startDateTime);
          if (cmp != 0) return cmp;
          return a.price.compareTo(b.price);
        });
      } else if (_items[0] == 'Date' && _items[1] == 'Age group') {
        eventsAllCategories.sort((a, b) {
          int cmp = a.startDateTime.compareTo(b.startDateTime);
          if (cmp != 0) return cmp;
          return ageGroups
              .indexOf(a.ageGroups[0])
              .compareTo(ageGroups.indexOf(b.ageGroups[0]));
        });
      } else if (_items[0] == 'Price' && _items[1] == 'Age group') {
        eventsAllCategories.sort((a, b) {
          int cmp = a.price.compareTo(b.price);
          if (cmp != 0) return cmp;
          return ageGroups
              .indexOf(a.ageGroups[0])
              .compareTo(ageGroups.indexOf(b.ageGroups[0]));
        });
      } else if (_items[0] == 'Age group' && _items[1] == 'Date') {
        eventsAllCategories.sort((a, b) {
          int cmp = ageGroups
              .indexOf(a.ageGroups[0])
              .compareTo(ageGroups.indexOf(b.ageGroups[0]));
          if (cmp != 0) return cmp;
          return a.startDateTime.compareTo(b.startDateTime);
        });
      } else if (_items[0] == 'Price' && _items[1] == 'Date') {
        eventsAllCategories.sort((a, b) {
          int cmp = a.price.compareTo(b.price);
          if (cmp != 0) return cmp;
          return a.startDateTime.compareTo(b.startDateTime);
        });
      }
    });
  }

  Future<double> get _height => Future<double>.value(Constants.isMobile
      ? Constants.itemAnimatedContainerHeightMobile
      : Constants.itemAnimatedContainerHeightTablet);

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
              child:
                  Column(mainAxisAlignment: MainAxisAlignment.start, children: [
                SharedWidgets.categoryTitleWidget(category),
                Container(
                    height: Constants.isMobile
                        ? Constants.itemContainerHeightMobile
                        : Constants.itemContainerHeightTablet,
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
        width: Constants.isMobile
            ? Constants.itemCardWidthMobile
            : Constants.itemCardWidthTablet,
        child: Card(
            color: Constants.cardBgColors[categories.indexOf(category)],
            child: Padding(
                padding: const EdgeInsets.all(10),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Flexible(
                            child: SharedWidgets.itemTitleWidget(event.title)
                        ),
                        SharedWidgets.itemPriceWidget(event.price)
                      ],
                    ),
                    Hero(
                      tag: 'event_image$category$index',
                      child:
                          SharedWidgets.networkImageWithLoading(event.imageUrl),
                    ),
                    const SizedBox(height: 6,),
                    SharedWidgets.itemDateWidget('${dateParts[0]}, ${monthDayYear[0]}/${monthDayYear[1]}, ${dateParts[2]}'),
                    const SizedBox(height: 4,),
                    SharedWidgets.itemDescriptionWidget(event.description),
                    const Spacer(),
                    SharedWidgets.itemAgeGroupsWidget(event.ageGroups)
                  ],
                ))));
  }
}
