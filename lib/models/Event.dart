import 'package:cloud_firestore/cloud_firestore.dart';

class Event {
  String title;
  String subTitle;
  String venue;
  String imageUrl;
  String description;
  String website;
  String address;
  Timestamp startDateTime;
  Timestamp endDateTime;
  List<String> categories;
  List<String> ageGroups;
  int price;

  Event(
      this.title,
      this.subTitle,
      this.venue,
      this.imageUrl,
      this.description,
      this.website,
      this.address,
      this.startDateTime,
      this.endDateTime,
      this.categories,
      this.ageGroups,
      this.price,
      );

  factory Event.fromJson(Map<String, dynamic> parsedJson) {
    return Event(
        parsedJson['title'].toString(),
        parsedJson['subtitle'].toString(),
        parsedJson['venue'].toString(),
        parsedJson['imageUrl'].toString(),
        parsedJson['description'].toString(),
        parsedJson['website'].toString(),
        parsedJson['address'].toString(),
        Timestamp.fromDate(DateTime.now()),
        Timestamp.fromDate(DateTime.now()),
        parsedJson['categories'].toString().split(","),
        parsedJson['ageGroups'].toString().split(","),
        int.parse(parsedJson['price'].toString())
    );
  }

  @override
  String toString(){
    return '$title\n$subTitle\n$venue\n$startDateTime\n$endDateTime\n$price';
  }
}
