import 'event.dart';

final List<Event> mockEvents = [
  Event(
    id: '1',
    name: 'Konser',
    description: 'Müthiş bir konser',
    category: 'Müzik',
    city: 'İstanbul',
    price: 150.0,
    date: DateTime.now().add(Duration(days: 5)),
    imageUrl: 'https://picsum.photos/400/200',
    location: 'Sahne 1',
    capacity: 300,
  ),
  Event(
    id: '2',
    name: 'Workshop',
    description: 'Eğitici workshop',
    category: 'Eğitim',
    city: 'Ankara',
    price: 50.0,
    date: DateTime.now().add(Duration(days: 10)),
    imageUrl: 'https://picsum.photos/400/200',
    location: 'Salon 2',
    capacity: 50,
  ),
];
