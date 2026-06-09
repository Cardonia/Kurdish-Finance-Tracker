import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'storage_service.dart';

class PieChartScreen extends StatefulWidget {
  const PieChartScreen({super.key});

  @override
  State<PieChartScreen> createState() => _ReportScreenState();
}

class _ReportScreenState extends State<PieChartScreen> {
  String filter = "week";

  Map<String, Color> getColorMap() {
  final List<Color> colors = [
    Colors.red,
    Colors.blue,
    Colors.green,
    Colors.orange,
    Colors.purple,
    Colors.teal,
    Colors.pink,
    Colors.yellow,
    Colors.cyan,
    Colors.indigo,
    Colors.brown,
    Colors.lime,
    Colors.amber,
    Colors.deepOrange,
    Colors.deepPurple,
    Colors.lightBlue,
  ];

  Map<String, Color> map = {};
  int i = 0;

  for (var key in data.keys) {
    map[key] = colors[i % colors.length];
    i++;
  }

  return map;
}

  Map<String, double> data = {};

  @override
  void initState() {
    super.initState();
    load();
  }

  bool inRange(DateTime d) {
    DateTime now = DateTime.now();

    if (filter == "week") return now.difference(d).inDays <= 7;
    if (filter == "month") return now.difference(d).inDays <= 30;
    if (filter == "year") return now.difference(d).inDays <= 365;

    return true;
  }

  Future<void> load() async {
    final rows = await StorageService.getRecords();

    Map<String, double> temp = {};

    for (var r in rows) {
      if (r.length < 3) continue;

      int value = int.tryParse(r[0]) ?? 0;
      DateTime date = DateTime.parse(r[1]);
      String type = r[2].isEmpty ? "نەناسراو" : r[2];

      if (!inRange(date)) continue;

      temp[type] = (temp[type] ?? 0) + value.abs();
    }

    setState(() {
      data = temp;
    });
  }
List<PieChartSectionData> chart(Map<String, Color> colorMap) {
  final total = data.values.fold(0.0, (a, b) => a + b);

  return data.entries.map((e) {
    final percent = (e.value / total) * 100;

    return PieChartSectionData(
      value: e.value,
      title: "${percent.toStringAsFixed(1)}%",
      color: colorMap[e.key],
      radius: 200,
    );
  }).toList();
}

  @override
  Widget build(BuildContext context) {
    final total = data.values.fold(0.0, (a, b) => a + b);
    final colorMap = getColorMap();
    return Scaffold(
      appBar: AppBar(title: const Text("نەخشەی کێک",style: TextStyle(fontWeight: FontWeight.bold))),

      body: Column(
        children: [

          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
                DropdownButton<String>(
                value: filter,
                items: const [
            DropdownMenuItem(
                value: "week",
                child: Align(
                    alignment: Alignment.centerRight,
                    child: Text(
                    "هەفتە",
                    style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                ),
                ),
                DropdownMenuItem(
                value: "month",
                child: Align(
                    alignment: Alignment.centerRight,
                    child: Text(
                    "مانگ",
                    style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                ),
                ),
                DropdownMenuItem(
                value: "year",
                child: Align(
                    alignment: Alignment.centerRight,
                    child: Text(
                    "ساڵ",
                    style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                ),
            ),
            ],
            onChanged: (value) {
                setState(() {
                filter = value!;
                });
                load();
            },
            ),
        ],
        ),

          const SizedBox(height: 20),
            Text(
                "سەرجەم: $total ",
                style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
          Expanded(
            child: data.isEmpty
                ? const Center(child: Text("بێ داتا",style: TextStyle(fontWeight: FontWeight.bold)))
                : PieChart(
                    PieChartData(
                        sections: chart(getColorMap()),
                        centerSpaceRadius: 0, // no hole in middle
                        sectionsSpace: 0, 
                    ),
                  ),
          ),

          const SizedBox(height: 10),

            Wrap(
            spacing: 10,
            children: data.entries.map((e) {
                return Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                    Container(width: 10, height: 10, color: colorMap[e.key]),
                    const SizedBox(width: 5),
                    Text("${e.key}: ${e.value}"),
                ],
                );
            }).toList(),
            ),

          const SizedBox(height: 10),
        ],
      ),
    );
  }
}