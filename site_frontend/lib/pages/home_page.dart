import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/event_provider.dart';
import '../data/event.dart';
import '../widgets/event_card.dart';
import '../widgets/navbar.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  String search = "";
  String selectedCategory = "Tümü";
  String selectedCity = "Tümü";

  final int perPage = 5;
  int currentPage = 1;

  @override
  void initState() {
    super.initState();
    context.read<EventProvider>().fetchEvents();
  }

  // 🔹 Filtrelenmiş tüm listeyi döndüren fonksiyon
  List<Event> getFilteredEvents(List<Event> allEvents) {
    return allEvents.where((event) {
      final matchesSearch =
          event.name.toLowerCase().contains(search.toLowerCase());
      final matchesCategory =
          selectedCategory == "Tümü" || event.category == selectedCategory;
      final matchesCity =
          selectedCity == "Tümü" || event.city == selectedCity;
      return matchesSearch && matchesCategory && matchesCity;
    }).toList();
  }

  // 🔹 Sadece currentPage’e ait dilimi döndüren fonksiyon
  List<Event> getCurrentPageEvents(List<Event> filteredEvents) {
    int start = (currentPage - 1) * perPage;
    int end = (start + perPage).clamp(0, filteredEvents.length);
    if (start >= filteredEvents.length) return [];
    return filteredEvents.sublist(start, end);
  }

  @override
  Widget build(BuildContext context) {
    final allEvents = context.watch<EventProvider>().events;

    final filteredAll = getFilteredEvents(allEvents); // tüm filtrelenmiş liste
    final filteredEvents = getCurrentPageEvents(filteredAll); // sadece currentPage

    final totalPages = (filteredAll.length / perPage).ceil();

    return Scaffold(
      appBar: const NavBar(),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // 🔍 Arama ve filtre
            Row(
              children: [
                Expanded(
                  child: TextField(
                    decoration: const InputDecoration(
                      prefixIcon: Icon(Icons.search),
                      hintText: "Etkinlik ara...",
                      border: OutlineInputBorder(),
                    ),
                    onChanged: (value) => setState(() {
                      search = value;
                      currentPage = 1; // filtre değişince sayfayı 1 yap
                    }),
                  ),
                ),
                const SizedBox(width: 10),
                DropdownButton<String>(
                  value: selectedCategory,
                  items: ["Tümü", "Müzik", "Komedi", "Tiyatro"]
                      .map(
                        (e) => DropdownMenuItem(
                          value: e,
                          child: Text(e),
                        ),
                      )
                      .toList(),
                  onChanged: (value) => setState(() {
                    selectedCategory = value!;
                    currentPage = 1;
                  }),
                ),
                const SizedBox(width: 10),
                DropdownButton<String>(
                  value: selectedCity,
                  items: ["Tümü", "İstanbul", "Ankara", "İzmir"]
                      .map(
                        (e) => DropdownMenuItem(
                          value: e,
                          child: Text(e),
                        ),
                      )
                      .toList(),
                  onChanged: (value) => setState(() {
                    selectedCity = value!;
                    currentPage = 1;
                  }),
                ),
              ],
            ),

            const SizedBox(height: 16),

            // 🎟️ Event listesi
            Expanded(
              child: filteredEvents.isEmpty
                  ? const Center(
                      child: Text("Hiç etkinlik bulunamadı."),
                    )
                  : GridView.count(
                      crossAxisCount:
                          MediaQuery.of(context).size.width > 800 ? 3 : 1,
                      mainAxisSpacing: 16,
                      crossAxisSpacing: 16,
                      children: filteredEvents
                          .map((event) => EventCard(event: event))
                          .toList(),
                    ),
            ),

            // 📄 Sayfalama
            if (filteredEvents.isNotEmpty)
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  IconButton(
                    onPressed: currentPage > 1
                        ? () => setState(() => currentPage--)
                        : null,
                    icon: const Icon(Icons.arrow_back),
                  ),
                  Text("Sayfa $currentPage / $totalPages"),
                  IconButton(
                    onPressed: currentPage < totalPages
                        ? () => setState(() => currentPage++)
                        : null,
                    icon: const Icon(Icons.arrow_forward),
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }
}
