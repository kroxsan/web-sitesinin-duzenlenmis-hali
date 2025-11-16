class Event {
  String id;
  String name;
  String description;
  String category;
  String city;
  double price;
  DateTime date;
  String imageUrl;
  String location;
  int capacity;

  Event({
    required this.id,
    required this.name,
    required this.description,
    required this.category,
    required this.city,
    required this.price,
    required this.date,
    required this.imageUrl,
    required this.location,
    required this.capacity,
  });
}
