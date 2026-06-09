import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'storage_service.dart';

class InsertScreen extends StatefulWidget {
  @override
  State<InsertScreen> createState() => _InsertScreenState();
}

class _InsertScreenState extends State<InsertScreen> {
  final FocusNode _focusNode = FocusNode();
  final TextEditingController _controller = TextEditingController();

  @override
  void initState() {
    super.initState();

    // run after UI is shown (no freeze)
    WidgetsBinding.instance.addPostFrameCallback((_) {

      precacheImage(const AssetImage("assets/250.jpg"), context);
      precacheImage(const AssetImage("assets/500.jpg"), context);
      precacheImage(const AssetImage("assets/1000.jpg"), context);
      precacheImage(const AssetImage("assets/5000.jpg"), context);
    });
  }

  @override
  void dispose() {
    _focusNode.dispose();
    _controller.dispose();
    super.dispose();
  }

  Widget buildImgButton(String imgPath, int value) {
    return GestureDetector(
      onTap: () {
        int current = int.tryParse(_controller.text) ?? 0;
        _controller.text = (current + value).toString();
      },
      child: ClipRRect(
        borderRadius: BorderRadius.circular(10),
        child: Image.asset(
          imgPath,
          fit: BoxFit.cover,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("دەستکەوت" , style: TextStyle(fontWeight: FontWeight.bold))),
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                SizedBox(
                  width: 200,
                  child: TextField(
                    controller: _controller,
                    focusNode: _focusNode,
                    keyboardType: TextInputType.number,
                    textAlign: TextAlign.center,
                    inputFormatters: [
                      FilteringTextInputFormatter.digitsOnly,
                      LengthLimitingTextInputFormatter(8),
                    ],
                    decoration: const InputDecoration(
                      hintText: "تکایە بەها دابنێ",
                      hintStyle: TextStyle(
                        color: Colors.black,
                        fontWeight: FontWeight.bold,
                      ),
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                const Text(
                  "دینار",
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 15),

            ElevatedButton(
            onPressed: () async {
                int value = int.tryParse(_controller.text) ?? 0;

                await StorageService.saveNumber(value);

                _controller.clear();
            },
              child: const Text(
                "دووپاتکردنەوە",
                style: TextStyle(
                  fontSize: 20,
                  color: Colors.black,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),

            const SizedBox(height: 20),

            GridView.count(
              shrinkWrap: true,
              crossAxisCount: 2,
              mainAxisSpacing: 10,
              crossAxisSpacing: 10,
              childAspectRatio: 2.5,
              children: [
                buildImgButton("assets/250.jpg", 250),
                buildImgButton("assets/500.jpg", 500),
                buildImgButton("assets/1000.jpg", 1000),
                buildImgButton("assets/5000.jpg", 5000),
              ],
            ),
          ],
        ),
      ),
    );
  }
}