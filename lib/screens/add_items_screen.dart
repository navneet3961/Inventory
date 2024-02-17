import 'package:flutter/material.dart';
import 'package:inventory_app/models/item.dart';
import 'package:inventory_app/widgets/functions.dart';
import 'package:inventory_app/screens/home_screen.dart';
import 'package:inventory_app/widgets/add_items_card.dart';

class AddItems extends StatefulWidget {
  final Map<String, Item> map;
  const AddItems({
    Key? key,
    required this.map,
  }) : super(key: key);

  @override
  State<AddItems> createState() => _AddItemsState();
}

class _AddItemsState extends State<AddItems> {
  List<Item> itemList = [];
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
                        child: AddItemsCard(
                          map: map,
                          listNo: index,
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
                      if (isValidData(itemList, context)) {
                        await addOrUpdateItemsToFile(map, itemList).then(
                            (value) => Navigator.pushAndRemoveUntil(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => const HomeScreen()),
                                (route) => false));
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
