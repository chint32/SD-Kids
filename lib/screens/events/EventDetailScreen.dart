import 'dart:math';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:maps_launcher/maps_launcher.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../models/Event.dart';

class EventDetailScreen extends StatefulWidget {
  final Event event;
  final String category;
  final int index;

  const EventDetailScreen(
      {super.key,
      required this.event,
      required this.category,
      required this.index});

  @override
  State<EventDetailScreen> createState() => _EventDetailScreenState();
}

class _EventDetailScreenState extends State<EventDetailScreen> {
  // String fcmToken = '';
  //
  // _getToken() async {
  //   FirebaseMessaging messaging = FirebaseMessaging.instance;
  //   String token = (await messaging.getToken())!;
  //   setState(() {
  //     fcmToken = token;
  //   });
  // }
  //
  // @override
  // void initState() {
  //   _getToken();
  // }

  @override
  Widget build(BuildContext context) {
    String date = DateFormat('EEEE, MM/dd/yyyy, hh:mm a')
        .format(widget.event.startDateTime.toDate());
    // [0] - DoW, [1] = Date, [2] = Time
    List<String> dateParts = date.split(', ');
    List<String> monthDayYear = dateParts[1].split('/');
    return Container(
        color: Theme.of(context).primaryColor,
        child: Padding(
            padding: EdgeInsets.fromLTRB(10, 10, 10, 100),
            child: SingleChildScrollView(
              child: Column(
                children: [
                  Padding(
                      padding:
                          EdgeInsets.symmetric(vertical: 10, horizontal: 0),
                      child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Flexible(child: Text(
                              widget.event.title,
                              style: const TextStyle(
                                  fontSize: 24,
                                  fontFamily: 'Jost',
                                  fontWeight: FontWeight.bold),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            )),
                            Text(
                              '\$${widget.event.price}',
                              style: const TextStyle(
                                  fontSize: 24,
                                  fontFamily: 'Jost',
                                  fontWeight: FontWeight.bold),
                            ),
                          ])),
                  Hero(
                    tag: 'event_image${widget.category}${widget.index}',
                    flightShuttleBuilder:
                        (_, Animation<double> animation, __, ___, ____) {
                      final customAnim =
                          Tween<double>(begin: 0, end: 2).animate(animation);
                      return AnimatedBuilder(
                        animation: customAnim,
                        builder: (context, child) {
                          return Transform(
                            transform: Matrix4.identity()
                              ..setEntry(3, 2, 0.003)
                              ..rotateX(customAnim.value * pi),
                            alignment: Alignment.center,
                            child: Image.network(widget.event.imageUrl),
                          );
                        },
                      );
                    },
                    child: Image.network(widget.event.imageUrl),
                  ),
                  Padding(
                      padding:
                          EdgeInsets.symmetric(vertical: 10, horizontal: 0),
                      child: Text(
                        widget.event.subTitle,
                        style: const TextStyle(
                            fontSize: 22,
                            fontFamily: 'Jost',
                            fontWeight: FontWeight.bold),
                      )),
                  Text(
                    '${dateParts[0]}, ${monthDayYear[0]}/${monthDayYear[1]}, ${dateParts[2]}',
                    style: const TextStyle(
                        fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  Padding(
                      padding: const EdgeInsets.symmetric(
                          vertical: 10, horizontal: 0),
                      child: Text(
                        widget.event.description,
                        textAlign: TextAlign.center,
                        style:
                            const TextStyle(fontSize: 20, fontFamily: 'Jost'),
                      )),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      ElevatedButton(
                        onPressed: () async {
                          final Uri url = Uri.parse(widget.event.website);
                          if (!await launchUrl(url)) {
                            throw Exception(
                                'Could not launch ${widget.event.website}');
                          }
                        },
                        style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.blue),
                        child: const Text(
                          'Open Website',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 20,
                            fontFamily: 'Jost',
                          ),
                        ),
                      ),
                      ElevatedButton(
                        onPressed: () {
                          MapsLauncher.launchQuery(widget.event.address);
                        },
                        style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.blue),
                        child: const Text(
                          'Open Maps',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 20,
                            fontFamily: 'Jost',
                          ),
                        ),
                      )
                    ],
                  )
                  // ElevatedButton(onPressed: () async {
                  //   Event updatedEvent = await viewModel
                  //       .updateEventPlanToGo(event, fcmToken);
                  //   setState(() {
                  //     event = updatedEvent;
                  //   });
                  // }, child: Text((() {
                  //   if (event.tokensPlanToGo.contains(fcmToken)) {
                  //     return "Remove plans to go";
                  //   }
                  //   return "Add plans to go";
                  // })()))
                ],
              ),
            )));
    // } else
    //   return Text('null');
  }
}
