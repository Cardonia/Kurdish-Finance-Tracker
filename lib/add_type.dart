import 'package:flutter/material.dart';
import 'storage_service.dart';

class AddType extends StatefulWidget {
  const AddType({super.key});

  @override
  State<AddType> createState() => _AddTypeState();
}
class _AddTypeState extends State<AddType> {
  List<String> types = [];
  final TextEditingController _textController = TextEditingController();

  @override
  void initState() {
    super.initState();
    loadTypes();
  }

  void loadTypes() async {
    final data = await StorageService.getTypes();
    setState(() {
      types = data;
    });
  }

  void deleteItem(String value) async {
    await StorageService.deleteType(value);
    loadTypes();
  }

  void addItem() async {
    final text = _textController.text.trim();

    if (text.isEmpty) return;
    if (types.contains(text)) return;

    if (types.length > 15) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("گەیشتە سنووری 15 ئەوپەڕی")),
    );
    return;
  }
    await StorageService.addType(text);
    _textController.clear();
    loadTypes();
  }

  @override
Widget build(BuildContext context) {
  return Scaffold(
    appBar: AppBar(title: const Text(" زیادکردنی جۆر" , style: TextStyle(fontWeight: FontWeight.bold))),

    body: SizedBox(
      width: double.infinity,
      child: Container(
        color: Colors.grey.shade200,
        child: Column(
          children: [
            const SizedBox(height: 10),

            // INPUT
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: TextField(
                controller: _textController,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  hintText: "جۆری نوێ",
                ),
              ),
            ),

            const SizedBox(height: 5),

            // BUTTON
            ElevatedButton(
              onPressed: addItem,
              child: const Text("دووپاتکردنەوە",  style: TextStyle(fontWeight: FontWeight.bold)),
            ),

            const Divider(),

            // LIST
            Expanded(
              child: ListView.builder(
                itemCount: types.length,
                itemBuilder: (context, index) {
                  final item = types[index];

                  return ListTile(
                    title: Text(item),
                    trailing: IconButton(
                      icon: const Icon(Icons.delete, color: Colors.red),
                      onPressed: () => deleteItem(item),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    ),
  );
}
}