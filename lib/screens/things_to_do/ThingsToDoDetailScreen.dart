import 'dart:math';

import 'package:flutter/material.dart';
import 'package:maps_launcher/maps_launcher.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../models/ThingToDo.dart';
import '../../viewModel/EventDetailViewModel.dart';

class ThingsToDoDetailScreen extends StatefulWidget {
  final ThingToDo thingToDo;
  final String category;
  final int index;

  const ThingsToDoDetailScreen(
      {super.key, required this.thingToDo, required this.category, required this.index});

  @override
  State<ThingsToDoDetailScreen> createState() => _ThingsToDoDetailScreenState();
}

class _ThingsToDoDetailScreenState extends State<ThingsToDoDetailScreen> {

  @override
  Widget build(BuildContext context) {
    return Padding(
        padding: EdgeInsets.all(10),
        child: Center(
          child: Column(
            children: [
              Padding(
                  padding: EdgeInsets.symmetric(vertical: 10, horizontal: 0),
                  child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          widget.thingToDo.name,
                          style: TextStyle(
                              fontSize: 24,
                              fontFamily: 'Jost',
                              fontWeight: FontWeight.bold),
                        ),
                        Text(
                          '\$${widget.thingToDo.price}',
                          style: TextStyle(
                              fontSize: 24,
                              fontFamily: 'Jost',
                              fontWeight: FontWeight.bold),
                        ),
                      ])),
              Hero(
                tag: 'thing_to_do_image${widget.category}${widget.index}',
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
                        child: Image.network(widget.thingToDo.imageUrl),
                      );
                    },
                  );
                },
                child: Image.network(widget.thingToDo.imageUrl),
              ),
              SizedBox(
                height: 10,
              ),
              Text(
                widget.thingToDo.description,
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 20, fontFamily: 'Jost'),
              ),
              InkWell(
                onTap: () async {
                  final Uri url = Uri.parse(widget.thingToDo.website);
                  if (!await launchUrl(url)) {
                    throw Exception(
                        'Could not launch ${widget.thingToDo.website}');
                  }
                },
                child: Text(
                  widget.thingToDo.website,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                      fontSize: 20,
                      fontFamily: 'Jost',
                      color: Colors.blue,
                      decoration: TextDecoration.underline),
                ),
              ),
              SizedBox(height: 10,),
              InkWell(
                onTap: () {
                  MapsLauncher.launchQuery(widget.thingToDo.address);
                },
                child: Text(
                  widget.thingToDo.address,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                      fontSize: 20,
                      fontFamily: 'Jost',
                      color: Colors.blue,
                      decoration: TextDecoration.underline),
                ),
              ),
            ],
          ),
        ));
  }
}
