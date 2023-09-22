import 'dart:math';

import 'package:flutter/material.dart';
import 'package:maps_launcher/maps_launcher.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../models/FoodDeal.dart';

class FoodDealDetailScreen extends StatefulWidget {
  final FoodDeal foodDeal;
  final String dayOfWeek;
  final int index;

  const FoodDealDetailScreen(
      {super.key, required this.foodDeal, required this.dayOfWeek, required this.index});

  @override
  State<FoodDealDetailScreen> createState() => _FoodDealDetailScreenState();
}

class _FoodDealDetailScreenState extends State<FoodDealDetailScreen> {

  @override
  Widget build(BuildContext context) {
    print('Food Deal Detail Screen');

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
                          widget.foodDeal.name,
                          style: const TextStyle(
                              fontSize: 24,
                              fontFamily: 'Jost',
                              fontWeight: FontWeight.bold),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        )),
                        Text(
                          '\$${widget.foodDeal.price}',
                          style: TextStyle(
                              fontSize: 24,
                              fontFamily: 'Jost',
                              fontWeight: FontWeight.bold),
                        ),
                      ])),
              Hero(
                tag: 'food_deal_image${widget.dayOfWeek}${widget.index}',
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
                        child: Image.network(widget.foodDeal.imageUrl),
                      );
                    },
                  );
                },
                child: Image.network(widget.foodDeal.imageUrl),
              ),
              SizedBox(
                height: 10,
              ),
              Text(
                widget.foodDeal.description,
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 20, fontFamily: 'Jost'),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  ElevatedButton(
                    onPressed: () async {
                      final Uri url = Uri.parse(widget.foodDeal.website);
                      if (!await launchUrl(url)) {
                        throw Exception(
                            'Could not launch ${widget.foodDeal.website}');
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
                      MapsLauncher.launchQuery(widget.foodDeal.address);
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
