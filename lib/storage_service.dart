
import 'dart:io';
import 'package:path_provider/path_provider.dart';

class StorageService {
  static Future<File> _getFile() async {
    final dir = await getApplicationDocumentsDirectory();
    return File('${dir.path}/data.csv');
  }

  static Future<void> saveNumber(int value) async {
    final file = await _getFile();
    String line = "$value,${DateTime.now().toIso8601String().split("T")[0]}\n";
    await file.writeAsString(line, mode: FileMode.append);
  }
  
  static Future<Map<String, Map<String, int>>> getDailyStacked() async {
    final file = await _getFile();
    if (!await file.exists()) return {};

    final lines = await file.readAsLines();

    Map<String, Map<String, int>> result = {};

    for (var line in lines) {
      if (line.trim().isEmpty) continue;
      var parts = line.split(",");
      if (parts.length < 2) continue;

      int value = int.tryParse(parts[0]) ?? 0;
      String date = parts[1];

      result.putIfAbsent(date, () => {"income": 0, "expense": 0});

      if (value >= 0) {
        result[date]!["income"] = result[date]!["income"]! + value;
      } else {
        result[date]!["expense"] =
            result[date]!["expense"]! + value.abs();
      }
    }

    return result;
  }

  static Map<String, int> filterByRange(Map<String, int> data, String type) {
    DateTime now = DateTime.now();

    return Map.fromEntries(
      data.entries.where((e) {
        DateTime d = DateTime.parse(e.key);

        if (type == "week") {
          return now.difference(d).inDays <= 7;
        }

        if (type == "month") {
          return now.difference(d).inDays <= 30;
        }

        if (type == "year") {
          return now.difference(d).inDays <= 365;
        }

        return true;
      }),
    );
  }

  static Future<void> saveRecord(int value, String type) async {
    final file = await _getFile();

    String date = DateTime.now().toIso8601String().split("T")[0];

    String line = "$value,$date,$type\n";

    await file.writeAsString(line, mode: FileMode.append);
  }







  static Future<File> _getFileConfig() async {
    final dir = await getApplicationDocumentsDirectory();
    return File('${dir.path}/config.txt');
  }

  static Future<void> initConfig() async {
    final file = await _getFileConfig();

    if (!(await file.exists())) {
      await file.writeAsString("خۆراک\nجلوبەرگ\n");
    }
  }

  static Future<List<String>> getTypes() async {
    final file = await _getFileConfig();

    if (!(await file.exists())) {
      await initConfig();
    }

    final content = await file.readAsString();
    return content
        .split('\n')
        .where((e) => e.trim().isNotEmpty)
        .toList();
  }

  static Future<void> deleteType(String value) async {
    final file = await _getFileConfig();

    final types = await getTypes();
    types.remove(value);

    await file.writeAsString(types.join('\n') + '\n');
  }

  static Future<void> addType(String value) async {
  final file = await _getFileConfig();

  final types = await getTypes();
  types.add(value);

  await file.writeAsString(types.join('\n') + '\n');
}



static Future<List<List<String>>> getRecords() async {
  final file = await _getFile();
  if (!await file.exists()) return [];

  final lines = await file.readAsLines();

  return lines
      .where((line) => line.trim().isNotEmpty)
      .map((line) => line.split(","))
      .toList();
}

static Future<void> saveAllRecords(List<List<String>> records) async {
  final file = await _getFile();

  final data = records.map((e) => e.join(",")).join("\n");

  await file.writeAsString(data);
}
}