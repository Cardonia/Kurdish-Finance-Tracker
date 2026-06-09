import 'package:flutter/material.dart';
import 'storage_service.dart';

class EditScreen extends StatefulWidget {
  const EditScreen({super.key});

  @override
  State<EditScreen> createState() => _EditScreenState();
}

class _EditScreenState extends State<EditScreen> {
  List<List<String>> _items = [];
  List<String> _types = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final types = await StorageService.getTypes();
    final items = await StorageService.getRecords();

    // Build a set for O(1) lookup instead of O(n) contains checks
    final typeSet = <String>{...types};
    for (final item in items) {
      if (item.length > 2 && item[2].isNotEmpty) {
        typeSet.add(item[2]);
      }
    }

    if (!mounted) return;
    setState(() {
      _types = ['', ...typeSet];
      _items = items;
      _isLoading = false;
    });
  }

  Future<void> _save() async {
    await StorageService.saveAllRecords(_items);
  }

  Future<void> _deleteItem(int index) async {
    final confirmed = await _showConfirmDialog(
      title: "دڵنیایت؟",
      content: "ئایا دەتەوێت بسڕیتەوە؟",
    );
    if (confirmed != true) return;

    setState(() => _items.removeAt(index));
    await _save();
  }

  Future<void> _editItem(int index) async {
    // Snapshot current values — controllers created/disposed inside dialog
    final currentItem = _items[index];
    final result = await showDialog<List<String>>(
      context: context,
      builder: (_) => _EditDialog(
        initialAmount: currentItem[0],
        initialDate: currentItem[1],
        initialType: currentItem.length > 2 ? currentItem[2] : '',
        types: _types,
      ),
    );

    if (result == null) return;

    setState(() => _items[index] = result);
    await _save();
  }

  Future<bool?> _showConfirmDialog({
    required String title,
    required String content,
  }) {
    return showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(title,
            style: const TextStyle(fontWeight: FontWeight.bold)),
        content: Text(content,
            style: const TextStyle(fontWeight: FontWeight.bold)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text("نەخێر",
                style: TextStyle(fontWeight: FontWeight.bold)),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text("بەڵێ",
                style: TextStyle(fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("گۆڕانکاری داتا",
            style: TextStyle(fontWeight: FontWeight.bold)),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _items.isEmpty
              ? const Center(
                  child: Text("بێ داتا",
                      style: TextStyle(fontWeight: FontWeight.bold)))
              : ListView.builder(
                  itemCount: _items.length,
                  // Tells Flutter the approximate height so it can skip
                  // layout calculations for off-screen items
                  itemExtent: 72,
                  itemBuilder: (context, index) {
                    final item = _items[index];
                    return _RecordTile(
                      key: ValueKey(Object.hashAll(item)),
                      amount: item[0],
                      date: item[1],
                      type: item.length > 2 ? item[2] : '',
                      onEdit: () => _editItem(index),
                      onDelete: () => _deleteItem(index),
                    );
                  },
                ),
    );
  }
}

// ─── Extracted tile widget ────────────────────────────────────────────────────
// By being its own widget it only rebuilds when ITS data changes,
// not when any sibling changes.

class _RecordTile extends StatelessWidget {
  const _RecordTile({
    super.key,
    required this.amount,
    required this.date,
    required this.type,
    required this.onEdit,
    required this.onDelete,
  });

  final String amount;
  final String date;
  final String type;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        title: Text(amount),
        subtitle: Text('$date  $type'),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: const Icon(Icons.edit),
              onPressed: onEdit,
            ),
            IconButton(
              icon: const Icon(Icons.delete, color: Colors.red),
              onPressed: onDelete,
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Edit dialog as its own StatefulWidget ────────────────────────────────────
// Controllers are now scoped here and properly disposed when the dialog closes.

class _EditDialog extends StatefulWidget {
  const _EditDialog({
    required this.initialAmount,
    required this.initialDate,
    required this.initialType,
    required this.types,
  });

  final String initialAmount;
  final String initialDate;
  final String initialType;
  final List<String> types;

  @override
  State<_EditDialog> createState() => _EditDialogState();
}

class _EditDialogState extends State<_EditDialog> {
  late final TextEditingController _amount;
  late final TextEditingController _date;
  late String _selectedType;
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    _amount = TextEditingController(text: widget.initialAmount);
    _date = TextEditingController(text: widget.initialDate);
    _selectedType =
        widget.types.contains(widget.initialType) ? widget.initialType : '';
  }

  @override
  void dispose() {
    // Controllers are now always cleaned up
    _amount.dispose();
    _date.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("دڵنیایت؟",
            style: TextStyle(fontWeight: FontWeight.bold)),
        content: const Text("ئایا دەتەوێت پاشەکەوت بکەیت؟",
            style: TextStyle(fontWeight: FontWeight.bold)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text("نەخێر",
                style: TextStyle(fontWeight: FontWeight.bold)),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text("بەڵێ",
                style: TextStyle(fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    // Return the result instead of mutating parent state directly
    if (mounted) {
      Navigator.pop(context, [_amount.text, _date.text, _selectedType]);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text("دەستکاریکردن",
          style: TextStyle(fontWeight: FontWeight.bold)),
      content: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextFormField(
              controller: _amount,
              keyboardType: TextInputType.number,
              validator: (v) {
                if (v == null || v.isEmpty) return "بەتاڵە";
                if (int.tryParse(v) == null) return "تەنها ژمارە";
                return null;
              },
              decoration: const InputDecoration(
                label: Text("بڕ",
                    style: TextStyle(fontWeight: FontWeight.bold)),
              ),
            ),
            TextFormField(
              controller: _date,
              validator: (v) {
                if (v == null || v.isEmpty) return "بەتاڵە";
                try {
                  DateTime.parse(v);
                } catch (_) {
                  return "YYYY-MM-DD";
                }
                return null;
              },
              decoration: const InputDecoration(
                label: Text("ڕێکەوت",
                    style: TextStyle(fontWeight: FontWeight.bold)),
              ),
            ),
            DropdownButtonFormField<String>(
              value: _selectedType,
              items: widget.types.map((t) {
                return DropdownMenuItem(
                  value: t,
                  child: Text(t.isEmpty ? ' ' : t),
                );
              }).toList(),
              onChanged: (v) => setState(() => _selectedType = v ?? ''),
              decoration: const InputDecoration(
                label: Text("جۆر",
                    style: TextStyle(fontWeight: FontWeight.bold)),
              ),
              validator: (v) => v == null ? "بەتاڵە" : null,
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text("هەڵوەشاندنەوه",
              style: TextStyle(fontWeight: FontWeight.bold)),
        ),
        ElevatedButton(
          onPressed: _submit,
          child: const Text("تۆمارکردن",
              style: TextStyle(fontWeight: FontWeight.bold)),
        ),
      ],
    );
  }
}