class ThingToDo {
  String id;
  String name;
  String description;
  List<String> categories;
  List<String> ageGroups;
  String imageUrl;
  String address;
  String website;
  int price;
  List<String> upVotes;
  List<String> downVotes;

  ThingToDo(
      this.id,
      this.name,
      this.description,
      this.categories,
      this.ageGroups,
      this.imageUrl,
      this.address,
      this.website,
      this.price,
      this.upVotes,
      this.downVotes
      );
}