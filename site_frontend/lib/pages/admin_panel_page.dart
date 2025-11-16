import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/event_provider.dart';
import '../data/event.dart';

class AdminPanelPage extends StatefulWidget {
  const AdminPanelPage({super.key});

  @override
  State<AdminPanelPage> createState() => _AdminPanelPageState();
}

class _AdminPanelPageState extends State<AdminPanelPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();        //kullanıcı formu doldururken veriler bu controller’lar üzerinden okunur ve backend’e gönderilebilir
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _categoryController = TextEditingController();
  final TextEditingController _cityController = TextEditingController();
  final TextEditingController _priceController = TextEditingController();
  final TextEditingController _imageUrlController = TextEditingController();
  final TextEditingController _capacityController = TextEditingController();
  final TextEditingController _dateController = TextEditingController();

  String? editingEventId;

  @override
  void initState() {
    super.initState();
    // context kullanımı async olmadığı için güvenli
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<EventProvider>().fetchEvents();
    });
  }

  void _loadEventToForm(Event event) {
    _nameController.text = event.name;
    _descriptionController.text = event.description;
    _categoryController.text = event.category;
    _cityController.text = event.city;
    _priceController.text = event.price.toString();
    _imageUrlController.text = event.imageUrl;
    _capacityController.text = event.capacity.toString();
    _dateController.text = event.date.toIso8601String().split('T')[0];
    editingEventId = event.id;
  }

  void _clearForm() {
    _nameController.clear();
    _descriptionController.clear();
    _categoryController.clear();
    _cityController.clear();
    _priceController.clear();
    _imageUrlController.clear();
    _capacityController.clear();
    _dateController.clear();
    editingEventId = null;
  }

  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate()) return;

    final provider = context.read<EventProvider>();

    final event = Event(
      id: editingEventId ?? DateTime.now().millisecondsSinceEpoch.toString(),
      name: _nameController.text,
      description: _descriptionController.text,
      category: _categoryController.text,
      city: _cityController.text,
      price: double.tryParse(_priceController.text) ?? 0,
      date: DateTime.tryParse(_dateController.text) ?? DateTime.now(),
      imageUrl: _imageUrlController.text.isNotEmpty
          ? _imageUrlController.text
          : "https://picsum.photos/400/200",
      location: "Bilinmiyor",
      capacity: int.tryParse(_capacityController.text) ?? 100,
    );

    try {
      if (editingEventId != null) {
        await provider.updateEvent(event);
        if (!mounted) return;
        ScaffoldMessenger.of(context)
            .showSnackBar(const SnackBar(content: Text("Etkinlik güncellendi ✅")));
      } else {
        await provider.addEvent(event);
        if (!mounted) return;
        ScaffoldMessenger.of(context)
            .showSnackBar(const SnackBar(content: Text("Etkinlik eklendi ✅")));
      }
      _clearForm();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Hata: $e")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final eventProvider = context.watch<EventProvider>();

    return Scaffold(
      appBar: AppBar(
        title: const Text("Yönetici Paneli"),
        backgroundColor: Colors.deepPurple,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Form(
              key: _formKey,
              child: Column(
                children: [
                  TextFormField(
                    controller: _nameController,
                    decoration: const InputDecoration(labelText: "Etkinlik Adı"),
                    validator: (value) => value!.isEmpty ? "Boş bırakılamaz" : null,
                  ),
                  TextFormField(
                    controller: _descriptionController,
                    decoration: const InputDecoration(labelText: "Açıklama"),
                  ),
                  TextFormField(
                    controller: _categoryController,
                    decoration: const InputDecoration(labelText: "Kategori"),
                  ),
                  TextFormField(
                    controller: _cityController,
                    decoration: const InputDecoration(labelText: "Şehir"),
                  ),
                  TextFormField(
                    controller: _priceController,
                    decoration: const InputDecoration(labelText: "Fiyat"),
                    keyboardType: TextInputType.number,
                  ),
                  TextFormField(
                    controller: _imageUrlController,
                    decoration: const InputDecoration(labelText: "Görsel URL"),
                  ),
                  TextFormField(
                    controller: _capacityController,
                    decoration: const InputDecoration(labelText: "Kapasite"),
                    keyboardType: TextInputType.number,
                    validator: (value) => value!.isEmpty ? "Boş bırakılamaz" : null,
                  ),
                  TextFormField(
                    controller: _dateController,
                    decoration: const InputDecoration(labelText: "Tarih (YYYY-MM-DD)"),
                    keyboardType: TextInputType.datetime,
                    validator: (value) => value!.isEmpty ? "Boş bırakılamaz" : null,
                  ),
                  const SizedBox(height: 12),
                  ElevatedButton(
                    onPressed: _submitForm,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.deepPurple,
                    ),
                    child: Text(editingEventId != null ? "Güncelle" : "Etkinlik Ekle"),
                  ),
                  if (editingEventId != null)
                    TextButton(
                      onPressed: _clearForm,
                      child: const Text("İptal"),
                    ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            const Divider(thickness: 2),
            const SizedBox(height: 8),
            const Text(
              "Etkinlik Listesi",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            eventProvider.events.isEmpty
                ? const Text("Henüz etkinlik yok.")
                : ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: eventProvider.events.length,
                    itemBuilder: (context, index) {
                      final event = eventProvider.events[index];
                      return Card(
                        child: ListTile(
                          leading: Image.network(
                            event.imageUrl,
                            width: 50,
                            height: 50,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) =>
                                const Icon(Icons.image_not_supported),
                          ),
                          title: Text(event.name),
                          subtitle:
                              Text("${event.city} - ${event.date.toLocal()}".split(' ')[0]),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                icon: const Icon(Icons.edit, color: Colors.orange),
                                onPressed: () => _loadEventToForm(event),
                              ),
                              IconButton(
                                icon: const Icon(Icons.delete, color: Colors.red),
                                onPressed: () async {
                                  try {
                                    await eventProvider.deleteEvent(event.id);
                                  } catch (e) {
                                    if (!mounted) return;
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(content: Text("Silme hatası: $e")),
                                    );
                                  }
                                },
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
          ],
        ),
      ),
    );
  }
}
