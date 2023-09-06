import 'dart:math';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:maps_launcher/maps_launcher.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../models/Resource.dart';

class ResourceDetailScreen extends StatefulWidget {
  final Resource resource;
  final String type;
  final int index;

  const ResourceDetailScreen(
      {super.key,
      required this.resource,
      required this.type,
      required this.index});

  @override
  State<ResourceDetailScreen> createState() => _ResourceDetailScreenState();
}

class _ResourceDetailScreenState extends State<ResourceDetailScreen> {
  @override
  Widget build(BuildContext context) {
    return Padding(
        padding: const EdgeInsets.fromLTRB(10, 10, 10, 100),
        child: SingleChildScrollView(
          child: Column(
            children: [
              Padding(
                  padding: EdgeInsets.symmetric(vertical: 10, horizontal: 0),
                  child:
                        Text(
                          widget.resource.name,
                          style: TextStyle(
                              fontSize: 24,
                              fontFamily: 'Jost',
                              fontWeight: FontWeight.bold),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
              Hero(
                tag: 'resource_image${widget.type}${widget.index}',
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
                        child: Image.network(widget.resource.imageUrl),
                      );
                    },
                  );
                },
                child: Image.network(widget.resource.imageUrl),
              ),
              SizedBox(
                height: 10,
              ),
              Text(
                widget.resource.description,
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 20, fontFamily: 'Jost'),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  ElevatedButton(
                    onPressed: () async {
                      final Uri url = Uri.parse(widget.resource.website);
                      if (!await launchUrl(url)) {
                        throw Exception(
                            'Could not launch ${widget.resource.website}');
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
                      MapsLauncher.launchQuery(widget.resource.address);
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
            ],
          ),
        ));
  }
}