import 'dart:math';
import 'package:flutter/material.dart';
import 'package:maps_launcher/maps_launcher.dart';
import 'package:sd_kids/models/School.dart';
import 'package:url_launcher/url_launcher.dart';

class SchoolDetailScreen extends StatefulWidget {
  final School school;
  final String type;
  final int index;
  const SchoolDetailScreen({super.key,
    required this.school,
    required this.type,
    required this.index});

  @override
  State<SchoolDetailScreen> createState() => _SchoolDetailScreenState();
}

class _SchoolDetailScreenState extends State<SchoolDetailScreen> {
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
                  widget.school.name,
                  style: TextStyle(
                      fontSize: 24,
                      fontFamily: 'Jost',
                      fontWeight: FontWeight.bold),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              Hero(
                tag: 'school_image${widget.type}${widget.index}',
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
                        child: Image.network(widget.school.imageUrl),
                      );
                    },
                  );
                },
                child: Image.network(widget.school.imageUrl),
              ),
              SizedBox(
                height: 10,
              ),
              Text(
                widget.school.description,
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 20, fontFamily: 'Jost'),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  ElevatedButton(
                    onPressed: () async {
                      final Uri url = Uri.parse(widget.school.website);
                      if (!await launchUrl(url)) {
                        throw Exception(
                            'Could not launch ${widget.school.website}');
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
                      MapsLauncher.launchQuery(widget.school.address);
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