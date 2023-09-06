class ParksAndPools {
  String id;
  String name;
  String description;
  String imageUrl;
  String address;
  String website;
  int price;
  List<String> upVotes;
  List<String> downVotes;

  ParksAndPools(
      this.id,
      this.name,
      this.description,
      this.imageUrl,
      this.address,
      this.website,
      this.price,
      this.upVotes,
      this.downVotes
      );
}