import 'dart:math';

import 'package:flutter/material.dart';
import 'package:maps_launcher/maps_launcher.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../models/RecCenter.dart';

class RecCenterDetailScreen extends StatefulWidget {
  final RecCenter recCenter;
  final int index;

  const RecCenterDetailScreen(
      {super.key, required this.recCenter, required this.index});

  @override
  State<RecCenterDetailScreen> createState() => _RecCenterDetailScreenState();
}

class _RecCenterDetailScreenState extends State<RecCenterDetailScreen> {
  @override
  Widget build(BuildContext context) {
    return Padding(
        padding: EdgeInsets.all(10),
        child: Center(
          child: Column(
            children: [
              Text(
                widget.recCenter.name,
                style: TextStyle(
                    fontSize: 24,
                    fontFamily: 'Jost',
                    fontWeight: FontWeight.bold),
              ),
              SizedBox(
                height: 10,
              ),
              Hero(
                tag: 'rec_center_image${widget.index}',
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
                        child: Image.network(widget.recCenter.imageUrl),
                      );
                    },
                  );
                },
                child: Image.network(widget.recCenter.imageUrl),
              ),
              SizedBox(
                height: 10,
              ),
              Text(
                widget.recCenter.description,
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 20, fontFamily: 'Jost'),
              ),
              InkWell(
                onTap: () async {
                  final Uri url = Uri.parse(widget.recCenter.website);
                  if (!await launchUrl(url)) {
                    throw Exception(
                        'Could not launch ${widget.recCenter.website}');
                  }
                },
                child: Text(
                  widget.recCenter.website,
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
                  MapsLauncher.launchQuery(widget.recCenter.address);
                },
                child: Text(
                  widget.recCenter.address,
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
