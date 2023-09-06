import 'dart:math';

import 'package:flutter/material.dart';
import 'package:maps_launcher/maps_launcher.dart';
import 'package:sd_kids/models/ParksAndPools.dart';
import 'package:url_launcher/url_launcher.dart';

class ParksAndPoolsDetailScreen extends StatefulWidget {
  final ParksAndPools parkAndPool;
  final int index;

  const ParksAndPoolsDetailScreen(
      {super.key, required this.parkAndPool, required this.index});

  @override
  State<ParksAndPoolsDetailScreen> createState() =>
      _ParksAndPoolsDetailScreenState();
}

class _ParksAndPoolsDetailScreenState extends State<ParksAndPoolsDetailScreen> {
  @override
  Widget build(BuildContext context) {
    print('Pool Splash Pad Detail Screen');

    return Padding(
        padding: EdgeInsets.fromLTRB(10, 10, 10, 100),
        child: SingleChildScrollView(
          child: Column(
            children: [
              Padding(
                  padding: EdgeInsets.symmetric(vertical: 10, horizontal: 0),
                  child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Flexible(child: Text(
                          widget.parkAndPool.name,
                          style: const TextStyle(
                              fontSize: 24,
                              fontFamily: 'Jost',
                              fontWeight: FontWeight.bold),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        )),
                        Text(
                          '\$${widget.parkAndPool.price}',
                          style: TextStyle(
                              fontSize: 24,
                              fontFamily: 'Jost',
                              fontWeight: FontWeight.bold),
                        ),
                      ])),
              Hero(
                tag: 'park_and_pool_image${widget.index}',
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
                        child: Image.network(widget.parkAndPool.imageUrl),
                      );
                    },
                  );
                },
                child: Image.network(widget.parkAndPool.imageUrl),
              ),
              SizedBox(
                height: 10,
              ),
              Text(
                widget.parkAndPool.description,
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 20, fontFamily: 'Jost'),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  ElevatedButton(
                    onPressed: () async {
                      final Uri url = Uri.parse(widget.parkAndPool.website);
                      if (!await launchUrl(url)) {
                        throw Exception(
                            'Could not launch ${widget.parkAndPool.website}');
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
                      MapsLauncher.launchQuery(widget.parkAndPool.address);
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
