import 'dart:math';

import 'package:sd_kids/models/Event.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:sd_kids/models/FoodDeal.dart';
import 'package:sd_kids/models/ParksAndPools.dart';
import 'package:sd_kids/models/RecCenter.dart';
import 'package:sd_kids/models/ThingToDo.dart';

import '../models/Resource.dart';
import '../models/School.dart';

abstract class FirebaseRepository {
  Future<Map<String, dynamic>> getEvents();

  Future<List<ParksAndPools>> getParksAndPools();

  Future<List<FoodDeal>> getFoodDeals();

  Future<Map<String, dynamic>> getThingsToDo();

  Future<List<RecCenter>> getRecCenters();

  Future<Map<String, dynamic>> getResources();

  Future<Map<String, dynamic>> getSchools();

// Future<Event> updatePlanToGo(Event event, String token);
}

class FirebaseRepositoryImpl implements FirebaseRepository {
  @override
  Future<Map<String, dynamic>> getEvents() async {
    QuerySnapshot snapshot =
        await FirebaseFirestore.instance.collection('upcoming_events').get();

    List<String> categories = snapshot.docs.where((doc) => doc.id == 'categories')
    .map((doc) => List<String>.from(doc.get("categories"))).toList()[0];


    List<Event> events = snapshot.docs.where((doc) => doc.id != 'categories').map((doc) => Event(
      doc.get("title"),
      doc.get("subtitle"),
      doc.get("venue"),
      doc.get("imageUrl"),
      doc.get("description"),
      doc.get("website"),
      doc.get("address"),
      doc.get("startDateTime"),
      doc.get("endDateTime"),
      List<String>.from(doc.get("categories")),
      doc.get("price"),
    )).toList();

    print(categories);

    return {
      'categories': categories,
      'events': events
    };

  }

  // @override
  // Future<Event> updatePlanToGo(Event event, String token) async {
  //   if (!event.tokensPlanToGo.contains(token)) {
  //     await FirebaseFirestore.instance
  //         .collection('upcoming_events')
  //         .doc(event.eventId)
  //         .update({
  //       "tokensPlanToGo": FieldValue.arrayUnion([token])
  //     });
  //     event.tokensPlanToGo.add(token);
  //   } else {
  //     await FirebaseFirestore.instance
  //         .collection('upcoming_events')
  //         .doc(event.eventId)
  //         .update({
  //       "tokensPlanToGo": FieldValue.arrayRemove([token])
  //     });
  //     event.tokensPlanToGo.remove(token);
  //   }
  //   return event;
  // }

  @override
  Future<List<FoodDeal>> getFoodDeals() async {
    QuerySnapshot snapshot =
        await FirebaseFirestore.instance.collection('food_deals').get();

    List<FoodDeal> foodDeals = snapshot.docs
        .map((doc) => FoodDeal(
              doc.get('name'),
              doc.get('description'),
              List<String>.from(doc.get('daysOfWeek')),
              doc.get('imageUrl'),
              doc.get('address'),
              doc.get('website'),
              doc.get('price'),
            ))
        .toList();
    return foodDeals;
  }

  @override
  Future<List<ParksAndPools>> getParksAndPools() async {
    QuerySnapshot snapshot =
        await FirebaseFirestore.instance.collection('pools_splash_pads').get();
    List<ParksAndPools> poolsSplashPads = snapshot.docs
        .map((doc) => ParksAndPools(
              doc.get('name'),
              doc.get('description'),
              doc.get('imageUrl'),
              doc.get('address'),
              doc.get('website'),
              doc.get('price'),
            ))
        .toList();
    return poolsSplashPads;
  }

  @override
  Future<Map<String, dynamic>> getThingsToDo() async {
    QuerySnapshot snapshot =
        await FirebaseFirestore.instance.collection('things_to_do').get();

    List<String> categories = snapshot.docs.where((doc) => doc.id == 'categories')
        .map((doc) => List<String>.from(doc.get("categories"))).toList()[0];

    List<ThingToDo> thingsToDo = snapshot.docs.where((doc) => doc.id != 'categories')
        .map((doc) => ThingToDo(
              doc.get('name'),
              doc.get('description'),
              List<String>.from(doc.get("categories")),
              doc.get('imageUrl'),
              doc.get('address'),
              doc.get('website'),
              doc.get('price'),
            ))
        .toList();
    return {
      'categories': categories,
      'thingsToDo': thingsToDo
    };
  }

  @override
  Future<List<RecCenter>> getRecCenters() async {
    QuerySnapshot snapshot =
        await FirebaseFirestore.instance.collection('rec_centers').get();

    List<RecCenter> recCenters = snapshot.docs
        .map((doc) => RecCenter(
              doc.get('name'),
              doc.get('description'),
              doc.get('imageUrl'),
              doc.get('address'),
              doc.get('website'),
            ))
        .toList();
    return recCenters;
  }

  @override
  Future<Map<String, dynamic>> getResources() async {
    QuerySnapshot snapshot =
        await FirebaseFirestore.instance.collection('resources').get();

    List<String> types = snapshot.docs.where((doc) => doc.id == 'types')
        .map((doc) => List<String>.from(doc.get("types"))).toList()[0];

    List<Resource> resources = snapshot.docs.where((doc) => doc.id != 'types')
        .map((doc) => Resource(
              List<String>.from(doc.get("types")),
              doc.get('name'),
              doc.get('description'),
              doc.get('imageUrl'),
              doc.get('phone'),
              doc.get('address'),
              doc.get('website'),
            ))
        .toList();
    return {
      'types': types,
      'resources': resources
    };
  }

  @override
  Future<Map<String, dynamic>> getSchools() async {
    QuerySnapshot snapshot =
        await FirebaseFirestore.instance.collection('schools').get();

    List<String> types = snapshot.docs.where((doc) => doc.id == 'types')
        .map((doc) => List<String>.from(doc.get("types"))).toList()[0];

    List<School> schools = snapshot.docs.where((doc) => doc.id != 'types')
        .map((doc) => School(
              List<String>.from(doc.get("types")),
              doc.get('name'),
              doc.get('description'),
              doc.get('imageUrl'),
              doc.get('phone'),
              doc.get('address'),
              doc.get('website'),
            ))
        .toList();
    return {
      'types': types,
      'schools': schools
    };
  }
}
