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
    print('Events List Screen');

    return Consumer<EventListViewModel>(builder: (context, viewModel, child) {
      switch (viewModel.response.status) {
        case Status.LOADING:
          print('getting events - show loading');
          return const Center(child: CircularProgressIndicator(color: Colors.blue,));
        case Status.COMPLETED:
          List<String> categories = viewModel.response.data['categories'];
          List<Event> eventsAllCategories =
              viewModel.response.data['events'];
          return Padding(
              padding: const EdgeInsets.fromLTRB(10, 10, 10, 60),
              child: SingleChildScrollView(
                  child: Column(children: [
                const Text(
                  'Events',
                  style: TextStyle(
                      fontSize: 24,
                      fontFamily: 'Jost',
                      fontWeight: FontWeight.bold),
                ),
                for (var category in categories)
                  eventsByCategory(
                      category,
                      eventsAllCategories
                          .where((event) => event.categories.contains(category))
                          .toList(), categories)
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

  Future<double> get _height => Future<double>.value(387);

  Widget eventsByCategory(String category, List<Event> events, List<String> categories) {
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
                              child: EventListItemWidget(
                                  context, events[index], categories, category, index));
                        }))
              ]));
        });
  }

  Widget EventListItemWidget(
      BuildContext context, Event event, List<String> categories, String category, int index) {
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
                        Flexible(child: Text(
                          event.title,
                          style: const TextStyle(
                              color: Colors.white,
                              fontSize: 20,
                              fontWeight: FontWeight.bold),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        )),
                        Text(
                          "\$${event.price}",
                          style: const TextStyle(
                              color: Colors.white,
                              fontSize: 20,
                              fontWeight: FontWeight.bold),
                        ),
                      ],),
                    Hero(
                      tag: 'event_image$category$index',
                      child: SharedWidgets.networkImageWithLoading(event.imageUrl),
                    ),
                    const SizedBox(
                      height: 8,
                    ),
                    Text(
                      event.description,
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
