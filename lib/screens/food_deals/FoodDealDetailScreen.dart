import 'dart:math';

import 'package:flutter/material.dart';
import 'package:maps_launcher/maps_launcher.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../models/FoodDeal.dart';
import '../../viewModel/EventDetailViewModel.dart';

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
  final viewModel = EventDetailViewModel();

  @override
  Widget build(BuildContext context) {
    print('Food Deal Detail Screen');

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
                          widget.foodDeal.name,
                          style: TextStyle(
                              fontSize: 24,
                              fontFamily: 'Jost',
                              fontWeight: FontWeight.bold),
                        ),
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
              InkWell(
                onTap: () async {
                  final Uri url = Uri.parse(widget.foodDeal.website);
                  if (!await launchUrl(url)) {
                    throw Exception(
                        'Could not launch ${widget.foodDeal.website}');
                  }
                },
                child: Text(
                  widget.foodDeal.website,
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
                  MapsLauncher.launchQuery(widget.foodDeal.address);
                },
                child: Text(
                  widget.foodDeal.address,
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
