import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:inventory_app/models/item.dart';
import 'package:inventory_app/screens/add_items_screen.dart';
import 'package:inventory_app/screens/create_barcode_screen.dart';
import 'package:inventory_app/screens/print_barcode_screen.dart';
import 'package:inventory_app/widgets/functions.dart';
import 'package:inventory_app/screens/get_items_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  Map<String, Item> map = {};
  String latestBillNo = "";
  int countOfBarcodes = 0;
  TextEditingController barcodeController = TextEditingController();
  TextEditingController copiesController = TextEditingController(text: "1");

  @override
  void initState() {
    super.initState();
    getBarcodes().then((value) => map = value);
    getLatestBillNo().then((value) => latestBillNo = value);
    getTotalBarcodes().then((value) => countOfBarcodes = value);
  }

  @override
  void dispose() {
    barcodeController.dispose();
    copiesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "🪔 Shri Govind Shopping Mart 🪔",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        backgroundColor: Colors.blue[100],
      ),
      body: SizedBox(
        width: double.infinity,
        height: double.infinity,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton(
                  onPressed: () {
                    Navigator.pushAndRemoveUntil(
                        context,
                        MaterialPageRoute(
                            builder: (context) => AddItems(map: map)),
                        (route) => false);
                  },
                  child: const Text("Add/Update items"),
                ),
                const SizedBox(width: 50),
                ElevatedButton(
                  onPressed: () {
                    Navigator.pushAndRemoveUntil(
                        context,
                        MaterialPageRoute(
                            builder: (context) => GetItems(
                                  map: map,
                                  latestBillNo: latestBillNo,
                                )),
                        (route) => false);
                  },
                  child: const Text("Create new order"),
                ),
                const SizedBox(width: 50),
                ElevatedButton(
                  onPressed: () {
                    Navigator.pushAndRemoveUntil(
                        context,
                        MaterialPageRoute(
                          builder: (context) => CreateBarcodeScreen(
                            map: map,
                            totalBarcodes: countOfBarcodes,
                          ),
                        ),
                        (route) => false);
                  },
                  child: const Text("Generate barcode(s)"),
                ),
              ],
            ),
            const SizedBox(height: 50),
            Container(
              padding: const EdgeInsets.all(10),
              child: Form(
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SizedBox(
                      width: 250,
                      child: TextField(
                        maxLength: 50,
                        controller: barcodeController,
                        inputFormatters: [
                          FilteringTextInputFormatter.allow(
                              RegExp(r'[0-9a-zA-Z]+')),
                        ],
                        keyboardType: TextInputType.text,
                        decoration: const InputDecoration(
                          hintText: "Barcode",
                          hintStyle: TextStyle(color: Colors.red),
                          counterText: '',
                          border: OutlineInputBorder(
                            borderSide: BorderSide(width: 1),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 20),
                    SizedBox(
                      width: 90,
                      child: TextField(
                        controller: copiesController,
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly
                        ],
                        keyboardType: TextInputType.number,
                        maxLength: 2,
                        decoration: const InputDecoration(
                          hintText: "Copies",
                          hintStyle: TextStyle(color: Colors.red),
                          counterText: '',
                          border: OutlineInputBorder(
                            borderSide: BorderSide(width: 1),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 50),
                    ElevatedButton(
                      onPressed: () {
                        String error = "";
                        if (barcodeController.text.isEmpty) {
                          error += "Enter barcode.\n";
                        } else if (copiesController.text.isEmpty ||
                            int.parse(copiesController.text) == 0) {
                          error += "Enter no. of copies";
                        } else {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => PrintBarcodeScreen(
                                barcode: barcodeController.text,
                                copies: int.parse(copiesController.text),
                              ),
                            ),
                          );
                        }

                        if (error.isNotEmpty) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(error),
                            ),
                          );
                        }
                      },
                      child: const Text("Print barcode(s)"),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
