import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'storage_service.dart';
import 'add_type.dart';


class RemoveScreen extends StatefulWidget {
  @override
  State<RemoveScreen> createState() => _RemoveScreenState();
}

class _RemoveScreenState extends State<RemoveScreen> {
  final FocusNode _focusNode = FocusNode();
  final TextEditingController _controller = TextEditingController();
  List<String> types = [];
  String _selected = "";

  @override
  void initState() {
    super.initState();
    loadTypes();

    WidgetsBinding.instance.addPostFrameCallback((_) {

      precacheImage(const AssetImage("assets/250.jpg"), context);
      precacheImage(const AssetImage("assets/500.jpg"), context);
      precacheImage(const AssetImage("assets/1000.jpg"), context);
      precacheImage(const AssetImage("assets/5000.jpg"), context);
    });
  }


  void loadTypes() async {
    final data = await StorageService.getTypes();
    setState(() {
      types = data;
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
      appBar: AppBar(title: const Text("خەرج کردن" , style: TextStyle(fontWeight: FontWeight.bold))),
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [

           Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                
               ElevatedButton(
                onPressed: () async {
                  await Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => AddType()),
                  );
                  loadTypes();
                },
                style: ElevatedButton.styleFrom(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.zero,
                  ),
                ),
                child: const Text("+"),
              ),
                const SizedBox(width: 30),

                SizedBox(
                  width: 200,
                  child: DropdownButtonFormField<String>(
                    value: _selected.isEmpty ? null : _selected,
                    hint: const Text("هەڵبژاردن"),
                    items: ["", ...types].map((item) {
                      return DropdownMenuItem(
                        value: item,
                        child: Text(item.isEmpty ? "هیچ کامیان" : item, style: TextStyle(fontWeight: FontWeight.bold)),
                      );
                    }).toList(),
                    onChanged: (value) {
                      setState(() {
                        _selected = value ?? "";
                      });
                    },
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),

                const SizedBox(width: 20),

                 const Text("جۆری بڕگە",style: TextStyle(fontSize: 16,fontWeight: FontWeight.bold,),),
              ],
            ),

            const SizedBox(height: 15),
            
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

                 if(value == 0) return;

                await StorageService.saveRecord(-value, _selected);

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