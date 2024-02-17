import 'package:flutter/material.dart';
import 'package:inventory_app/models/item.dart';
import 'package:inventory_app/screens/home_screen.dart';
import 'package:inventory_app/widgets/functions.dart';
import 'package:pdf/pdf.dart';
import 'package:printing/printing.dart';

class PrintNewBarcodeScreen extends StatelessWidget {
  final List<Item> itemList;
  const PrintNewBarcodeScreen({
    Key? key,
    required this.itemList,
  }) : super(key: key);

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
      body: PdfPreview(
        build: (format) => printNewBarcodes(itemList),
        initialPageFormat: PdfPageFormat.roll80,
        canChangePageFormat: false,
        canChangeOrientation: false,
        canDebug: false,
        maxPageWidth: 600,
      ),
    );
  }
}
