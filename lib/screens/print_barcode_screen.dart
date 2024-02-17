// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:flutter/material.dart';
import 'package:inventory_app/widgets/functions.dart';
import 'package:pdf/pdf.dart';
import 'package:printing/printing.dart';

class PrintBarcodeScreen extends StatelessWidget {
  final String barcode;
  final int copies;
  const PrintBarcodeScreen({
    Key? key,
    required this.barcode,
    required this.copies,
  }) : super(key: key);

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
        leading: const BackButton(),
      ),
      body: PdfPreview(
        build: (format) => printBarcode(barcode, copies),
        initialPageFormat: PdfPageFormat.roll80,
        canChangePageFormat: false,
        canChangeOrientation: false,
        canDebug: false,
        maxPageWidth: 600,
      ),
    );
  }
}
