class FoodDeal {
  String id;
  String name;
  String description;
  List<String> daysOfWeek;
  String imageUrl;
  String address;
  String website;
  int price;
  int ageLimit;
  List<String> upVotes;
  List<String> downVotes;

  FoodDeal(
      this.id,
      this.name,
      this.description,
      this.daysOfWeek,
      this.imageUrl,
      this.address,
      this.website,
      this.price,
      this.ageLimit,
      this.upVotes,
      this.downVotes
      );
}