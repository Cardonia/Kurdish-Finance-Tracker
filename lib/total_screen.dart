import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'storage_service.dart';
import 'pie_chart.dart';
import 'edit_screen.dart';

class TotalScreen extends StatefulWidget {
  @override
  State<TotalScreen> createState() => _TotalScreenState();
}

class _TotalScreenState extends State<TotalScreen> {
  Map<String, Map<String, int>> data = {};
  List<String> chartKeys = [];

  String filter = "week";
    Map<String, Map<String, int>> filteredData = {};

  @override
  void initState() {
    super.initState();
    loadData();
  }

  List<String> getWeekDays() {
  DateTime now = DateTime.now();
  DateTime start = now.subtract(Duration(days: 6));

  return List.generate(7, (i) {
    return start.add(Duration(days: i)).toIso8601String().split("T")[0];
  });
}

List<String> getMonthDays() {
  DateTime now = DateTime.now();
  DateTime start = now.subtract(Duration(days: 29));

  return List.generate(30, (i) {
    return start.add(Duration(days: i)).toIso8601String().split("T")[0];
  });
}



List<String> getYearMonths() {
  DateTime now = DateTime.now();

  return List.generate(12, (i) {
    return DateTime(now.year, i + 1, 1)
        .toIso8601String()
        .split("T")[0]
        .substring(0, 7);
  });
}

  void loadData() async {
  final result = await StorageService.getDailyStacked();

  setState(() {
    data = result;
    applyFilter();
  });
}


void applyFilter() {
  Map<String, Map<String, int>> temp = {};

  List<String> keys;

  if (filter == "week") {
    keys = getWeekDays();
  } else if (filter == "month") {
    keys = getMonthDays();
  } else {
    keys = getYearMonths();
  }

  for (var k in keys) {
    temp[k] = {"income": 0, "expense": 0};
  }

  for (var e in data.entries) {
    String key;

    if (filter == "year") {
      key = e.key.substring(0, 7); // YYYY-MM
    } else {
      key = e.key.split(" ")[0];
    }

    if (temp.containsKey(key)) {
      temp[key]!["income"] =
          temp[key]!["income"]! + (e.value["income"] ?? 0);

      temp[key]!["expense"] =
          temp[key]!["expense"]! + (e.value["expense"] ?? 0);
    }
  }

  filteredData = temp;
  chartKeys = temp.keys.toList();
}



List<BarChartGroupData> buildBars() {


  return chartKeys.asMap().entries.map((e)  {
    String day = e.value;

    double income = (filteredData[day]?["income"] ?? 0).toDouble();
    double expense = (filteredData[day]?["expense"] ?? 0).toDouble();

    return BarChartGroupData(
      x: e.key,
      barsSpace: 5,
      barRods: [
        BarChartRodData(
          toY: income,
          color: Colors.green,
          width: filter == "month" ? 3 : 10,
          borderRadius: BorderRadius.zero,
        ),
        BarChartRodData(
          toY: expense,
          color: Colors.red,
          width: filter == "month" ? 3 : 10,
          borderRadius: BorderRadius.zero,
        ),
      ],
    );
  }).toList();
}




  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
  title: Text("ئامار", style: TextStyle(fontWeight: FontWeight.bold)),
  actions: [
  Padding(
    padding: EdgeInsets.only(right: 10),
    child: SizedBox(
      width: 40,
      height: 40,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          padding: EdgeInsets.zero,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => PieChartScreen(),
            ),
          );
        },
        child: Icon(Icons.pie_chart, size: 20),
      ),
    ),
  ),

  Padding(
    padding: EdgeInsets.only(right: 10),
    child: SizedBox(
      width: 40,
      height: 40,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          padding: EdgeInsets.zero,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => EditScreen(),
            ),
          );
        },
        child: Icon(Icons.edit, size: 20),
      ),
    ),
  ),
],
),
      body: Column(
  children: [
    DropdownButton(
      value: filter,
      items: [
        DropdownMenuItem(
          value: "week",
          child: Align(
            alignment: Alignment.centerRight,
            child: Text("هەفتە", style: TextStyle(fontWeight: FontWeight.bold)),
          ),
        ),
        DropdownMenuItem(
          value: "month",
          child: Align(
            alignment: Alignment.centerRight,
            child: Text("مانگ", style: TextStyle(fontWeight: FontWeight.bold)),
          ),
        ),
        DropdownMenuItem(
          value: "year",
          child: Align(
            alignment: Alignment.centerRight,
            child: Text("ساڵ", style: TextStyle(fontWeight: FontWeight.bold)),
          ),
        ),
      ],
      onChanged: (v) {
        setState(() {
            filter = v!;
            applyFilter();
        });
      },
    ),

    Expanded(
  child: filteredData.isEmpty || filteredData.isEmpty
      ? Center(child: Text("بێ داتا"))
      : BarChart(
          BarChartData(
            barTouchData: BarTouchData(enabled: false),
  barGroups: buildBars(),

  titlesData: FlTitlesData(
    topTitles: AxisTitles( sideTitles: SideTitles(showTitles: false),),
    bottomTitles: AxisTitles(
        sideTitles: SideTitles(
          showTitles: true, reservedSize: 50,

          getTitlesWidget: (value, meta) {
            int i = value.toInt();

            if (i >= filteredData.keys.length) {
              return Text("");
            }

            String date = chartKeys[i];

            if (filter == "week") {
             const days = [
                "دوو\nشەممە",
                "سێ\nشەممە",
                "چوار\nشەممە",
                "پێنج\nشەممە",
                "هەینی",
                "شەممە",
                "یەک\nشەممە"
              ];
              return Text(days[DateTime.parse(date).weekday - 1] ,  style:  TextStyle(fontWeight: FontWeight.bold, fontSize: 8));
            }

            if (filter == "month") { 
              int day = int.parse(date.split("-")[2]);

              if (day % 2 != 0) return const Text("");

              return Text(
                "$day",
                style: const TextStyle(fontSize: 8),
              );
            }

           const months = [
            "کانونی دووەم",
            "شوبات",
            "ئازار",
            "نیسان",
            "ئایار",
            "حوزەیران",
            "تەمموز",
            "ئاب",
            "ئەیلوول",
            "تشرینی یەکەم",
            "تشرینی دووەم",
            "کانونی یەکەم"
          ];

           return SizedBox(
              width: 40,
              child: Text(
                months[int.parse(date.split("-")[1]) - 1],
                textAlign: TextAlign.center,
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 6),
              ),
            );
          },
        ),
      ),
    ),
)
        ),
),
  ],
),
     );
  }
}