import 'package:flutter/material.dart';
import 'package:inventory_app/models/item.dart';
import 'package:inventory_app/screens/print_new_barcode_screen.dart';
import 'package:inventory_app/widgets/barcode_create_card.dart';
import 'package:inventory_app/widgets/functions.dart';
import 'package:inventory_app/screens/home_screen.dart';

class CreateBarcodeScreen extends StatefulWidget {
  final Map<String, Item> map;
  final int totalBarcodes;
  const CreateBarcodeScreen({
    Key? key,
    required this.map,
    required this.totalBarcodes,
  }) : super(key: key);

  @override
  State<CreateBarcodeScreen> createState() => _CreateBarcodeScreenState();
}

class _CreateBarcodeScreenState extends State<CreateBarcodeScreen> {
  List<Item> itemList = [];
  late int codeNo;
  late Map<String, Item> map;

  void deleteItem(int idx) {
    setState(() {
      itemList.removeAt(idx);
    });
  }

  void addItem() {
    setState(() {
      itemList.add(Item());
    });
  }

  @override
  void initState() {
    map = widget.map;
    codeNo = widget.totalBarcodes;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: InkWell(
          onTap: () {
            Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (context) => const HomeScreen()),
                (route) => false);
          },
          child: const Icon(Icons.home),
        ),
        title: const Text(
          "🪔 Shri Govind Shopping Mart 🪔",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        backgroundColor: Colors.blue[100],
      ),
      body: itemList.isEmpty
          ? const Center(
              child: Text("Add items"),
            )
          : Column(
              children: [
                SizedBox(
                  height: MediaQuery.sizeOf(context).height - 150,
                  width: double.infinity,
                  child: ListView.builder(
                    shrinkWrap: true,
                    itemCount: itemList.length,
                    itemBuilder: (BuildContext con, int index) {
                      return Container(
                        padding: const EdgeInsets.all(10),
                        child: BarcodeCreateCard(
                          map: map,
                          listNo: index,
                          codeNo: codeNo,
                          itemList: itemList,
                          deleteCallback: deleteItem,
                        ),
                      );
                    },
                  ),
                ),
                const SizedBox(height: 20),
                ElevatedButton(
                    onPressed: () async {
                      if (isValidDataToCreateBarcode(itemList, context)) {
                        await addOrUpdateItemsToFile(map, itemList,
                                newBarcodesAdded: true)
                            .then(
                          (value) => showDialog<String>(
                            context: context,
                            barrierDismissible: false,
                            builder: (BuildContext context) => AlertDialog(
                              content: const Text(
                                  'Do you want to print new created barcodes?'),
                              actions: <Widget>[
                                TextButton(
                                  onPressed: () => Navigator.pushAndRemoveUntil(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) =>
                                            PrintNewBarcodeScreen(
                                                itemList: itemList),
                                      ),
                                      (route) => false),
                                  // Navigator.pop(context, 'Cancel'),
                                  child: const Text('Yes'),
                                ),
                                TextButton(
                                  onPressed: () => Navigator.pushAndRemoveUntil(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) =>
                                            const HomeScreen(),
                                      ),
                                      (route) => false),
                                  child: const Text('No'),
                                ),
                              ],
                            ),
                          ),
                        );
                      }
                    },
                    child: const Text("Add Items")),
              ],
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: addItem,
        tooltip: 'Add new item',
        child: const Icon(Icons.add),
      ),
    );
  }
}
