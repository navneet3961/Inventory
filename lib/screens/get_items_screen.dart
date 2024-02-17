import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:inventory_app/models/item.dart';
import 'package:inventory_app/widgets/functions.dart';
import 'package:inventory_app/screens/home_screen.dart';
import 'package:inventory_app/screens/print_bill_screen.dart';
import 'package:inventory_app/widgets/get_items_card.dart';

class GetItems extends StatefulWidget {
  final Map<String, Item> map;
  final String latestBillNo;
  const GetItems({
    Key? key,
    required this.map,
    required this.latestBillNo,
  }) : super(key: key);

  @override
  State<GetItems> createState() => _GetItemsState();
}

class _GetItemsState extends State<GetItems> {
  List<Item> itemList = [];
  late Map<String, Item> map;
  late String latestBillNo;
  TextEditingController customerNameController = TextEditingController();
  TextEditingController phoneController = TextEditingController();

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
    latestBillNo = widget.latestBillNo;
    super.initState();
  }

  @override
  void dispose() {
    customerNameController.dispose();
    phoneController.dispose();
    super.dispose();
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
              child: Text("Add items to generate bill"),
            )
          : Column(
              children: [
                const SizedBox(height: 10),
                Center(
                  child: Text(
                    'Order No.: $latestBillNo',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.all(10),
                        child: TextField(
                          controller: customerNameController,
                          inputFormatters: [
                            FilteringTextInputFormatter.allow(
                                RegExp(r'[0-9a-zA-Z ]+'))
                          ],
                          keyboardType: TextInputType.text,
                          maxLength: 50,
                          decoration: const InputDecoration(
                            hintText: "Customer Name",
                            hintStyle: TextStyle(color: Colors.red),
                            prefixIcon: Icon(Icons.person),
                            counterText: "",
                            border: OutlineInputBorder(
                              borderSide: BorderSide(width: 1),
                            ),
                          ),
                        ),
                      ),
                    ),
                    Container(
                      width: 250,
                      padding: const EdgeInsets.all(10),
                      child: TextField(
                        controller: phoneController,
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly
                        ],
                        keyboardType: TextInputType.number,
                        maxLength: 10,
                        decoration: const InputDecoration(
                          prefixIcon: Icon(Icons.phone),
                          hintText: "Phone Number",
                          hintStyle: TextStyle(color: Colors.red),
                          counterText: "",
                          border: OutlineInputBorder(
                            borderSide: BorderSide(width: 1),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(
                  height: MediaQuery.sizeOf(context).height - 250,
                  width: double.infinity,
                  child: ListView.builder(
                    shrinkWrap: true,
                    itemCount: itemList.length,
                    itemBuilder: (BuildContext con, int index) {
                      return Container(
                        padding: const EdgeInsets.all(10),
                        child: GetItemsCard(
                          listNo: index,
                          itemList: itemList,
                          deleteCallback: deleteItem,
                          map: map,
                        ),
                      );
                    },
                  ),
                ),
                const SizedBox(height: 20),
                ElevatedButton(
                    onPressed: () async {
                      if (isValidData(
                        itemList,
                        context,
                        customerName: customerNameController.text,
                        phone: phoneController.text,
                      )) {
                        await placeOrderAndGenerateBill(
                          latestBillNo,
                          customerNameController.text,
                          phoneController.text,
                          itemList,
                          map,
                        ).then(
                          (value) => {
                            if (value.compareTo("Failed") == 0)
                              {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text(
                                        "Some of the barcodes are not found. Please check."),
                                  ),
                                ),
                              }
                            else
                              {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text("Order placed successfully."),
                                  ),
                                ),
                                Navigator.pushAndRemoveUntil(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) =>
                                        PrintBillScreen(bill: value),
                                  ),
                                  (route) => false,
                                ),
                              }
                          },
                        );
                      }
                    },
                    child: const Text("Generate Bill")),
              ],
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: addItem,
        tooltip: 'Add new order item',
        child: const Icon(Icons.add),
      ),
    );
  }
}
