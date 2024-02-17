import 'dart:io';
import 'dart:typed_data' as td;
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:inventory_app/models/bill.dart';
import 'package:inventory_app/models/item.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

const List<String> months = [
  "January",
  "February",
  "March",
  "April",
  "May",
  "June",
  "July",
  "August",
  "September",
  "October",
  "November",
  "December"
];

Future<Map<String, Item>> getBarcodes() async {
  Map<String, Item> map = {};
  String path = dotenv.env['PATH']!;
  var file = File('$path/items.csv');

  var lines = await file.readAsLines();
  for (int idx = 1; idx < lines.length; idx++) {
    var line = lines[idx].split(',');

    Item item = Item(
      barcode: line[0],
      name: line[1],
      price: double.parse(line[2]),
      quantity: int.parse(line[3]),
    );

    map[item.barcode] = item;
  }

  return map;
}

Future<int> getTodaysTotalOrders() async {
  final prefs = await SharedPreferences.getInstance();

  String? date = prefs.getString('date');
  String todayDate = DateTime.now().toString().substring(0, 10);

  if (date == null || date.compareTo(todayDate) != 0) {
    await prefs.setString('date', todayDate);
    await prefs.setInt('count', 1);
  }

  return prefs.getInt('count')!;
}

Future<String> getLatestBillNo() async {
  int orders = await getTodaysTotalOrders();

  DateTime date = DateTime.now();
  int year = date.year;
  int month = date.month;
  int day = date.day;

  return '$year${month.toString().padLeft(2, '0')}$day${orders.toString().padLeft(4, '0')}';
}

Future<String> placeOrderAndGenerateBill(
  String latestBillNo,
  String customerName,
  String phone,
  List<Item> itemList,
  Map<String, Item> map,
) async {
  String path = dotenv.env['PATH']!;
  DateTime date = DateTime.now();
  int year = date.year;
  String month = months[date.month - 1];
  int day = date.day;

  // Checking if root folder exists or not
  final Directory rootFolder = Directory('$path/Bills');
  if (!await rootFolder.exists()) {
    await rootFolder.create(recursive: true);
  }

  // Checking if root folder exists for current year or not
  final Directory yearFolder = Directory('$path/Bills/$year');
  if (!await yearFolder.exists()) {
    await yearFolder.create(recursive: true);
  }

  // Checking if root folder exists for current month or not
  final Directory monthFolder = Directory('$path/Bills/$year/$month');
  if (!await monthFolder.exists()) {
    await monthFolder.create(recursive: true);
  }

  // Checking if root folder exists for current day or not
  final Directory dayFolder = Directory('$path/Bills/$year/$month/$day');
  if (!await dayFolder.exists()) {
    await dayFolder.create(recursive: true);
  }

  String billNo = latestBillNo;
  Bill billInfo = Bill(
    billNo: billNo,
    customerName: customerName,
    phone: phone,
    itemList: itemList,
    date: date.toString().substring(0, 19),
  );

  for (Item item in itemList) {
    if (!map.containsKey(item.barcode)) {
      return "Failed";
    }
    map.update(item.barcode, (value) {
      value.quantity -= item.quantity;
      return value;
    });
  }

  String updatedData = "Barcode,Product Name,Price,Quantity\n";
  map.forEach((key, item) {
    updatedData += "${item.toString()}\n";
  });

  // Adding updated item quantity to file
  var file = File('$path/items.csv');
  await file.writeAsString(updatedData);

  // Generating JSON file of bill
  File bill = File('$path/Bills/$year/$month/$day/$billNo.json');
  await bill.writeAsString(billInfo.toJson());

  // Generating txt file of bill
  // bill = File('$path/Bills/$year/$month/$day/$billNo.txt');
  // await bill.writeAsString(billInfo.toString());

  // Updating no. of orders for today
  int orders = int.parse(latestBillNo.substring(8));
  final prefs = await SharedPreferences.getInstance();
  prefs.setInt('count', orders + 1);

  print(billInfo.toString());
  return billInfo.toString();
}

bool isValidData(List<Item> itemList, BuildContext context,
    {String customerName = "Name", String phone = "Phone"}) {
  String error = "";

  if (customerName.isEmpty) {
    error = "Customer Name can not be empty.\n";
  }

  if (phone.isEmpty) {
    error += "Phone Number can not be empty.\n";
  }

  for (Item item in itemList) {
    if (item.barcode.isEmpty || item.name.isEmpty) {
      error += "Some of the fields are empty. Please check.\n";
      break;
    }
  }

  if (error.isNotEmpty) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(error),
      ),
    );

    return false;
  }

  return true;
}

Future addOrUpdateItemsToFile(Map<String, Item> map, List<Item> itemList,
    {newBarcodesAdded = false}) async {
  String path = dotenv.env['PATH']!;
  var file = File('$path/items.csv');

  for (Item item in itemList) {
    map[item.barcode] = item;
  }

  String updatedData = "Barcode,Product Name,Price,Quantity\n";
  map.forEach((key, item) {
    updatedData += "${item.toString()}\n";
  });

  await file.writeAsString(updatedData);

  if (newBarcodesAdded) {
    setTotalBarcodes(itemList.length);
  }
}

Future<td.Uint8List> printDoc(String bill) async {
  final emoji = await PdfGoogleFonts.notoColorEmoji();
  final doc = pw.Document();

  doc.addPage(
    pw.Page(
      pageFormat: PdfPageFormat.roll80,
      build: (pw.Context context) {
        return pw.Center(
            child: pw.Text(
          bill.toString(),
          style: pw.TextStyle(
              fontFallback: [emoji], font: pw.Font.courier(), fontSize: 6.5),
        ));
      },
    ),
  );

  // await Printing.sharePdf(bytes: await doc.save(), filename: 'my-document.pdf');
  // await Printing.layoutPdf(
  //     onLayout: (PdfPageFormat format) async => doc.save());

  return doc.save();

  // String path = dotenv.env['PATH']!;
  // var file = File('$path/abc.pdf');
  // await file.writeAsBytes(await doc.save()).then((value) => print("Done"));
}

Future<td.Uint8List> printBarcode(String barcode, int copies) async {
  final svg = pw.Barcode.code39().toSvg(barcode, width: 400, height: 200);
  final doc = pw.Document();

  doc.addPage(
    pw.Page(
      pageFormat: PdfPageFormat.roll80,
      build: (pw.Context context) {
        return pw.Center(
            child: pw.Column(
                children:
                    List.generate(copies, (index) => pw.SvgImage(svg: svg))));
      },
    ),
  );

  return doc.save();
}

Future<td.Uint8List> printNewBarcodes(List<Item> itemList) async {
  final doc = pw.Document();

  doc.addPage(
    pw.Page(
      pageFormat: PdfPageFormat.roll80,
      build: (pw.Context context) {
        return pw.Center(
          child: pw.Column(
            children: List.generate(
              itemList.length,
              (idx) => pw.SvgImage(
                svg: pw.Barcode.code39()
                    .toSvg(itemList[idx].barcode, width: 400, height: 200),
              ),
            ),
          ),
        );
      },
    ),
  );

  return doc.save();
}

Future<int> getTotalBarcodes() async {
  final prefs = await SharedPreferences.getInstance();

  int? count = prefs.getInt('count');

  if (count == null) {
    await prefs.setInt('count', 1);
  }

  return prefs.getInt('count')!;
}

void setTotalBarcodes(int n) async {
  final prefs = await SharedPreferences.getInstance();

  int? count = prefs.getInt('count');

  if (count == null) {
    await prefs.setInt('count', 1);
  } else {
    await prefs.setInt('count', count + n);
  }
}

bool isValidDataToCreateBarcode(List<Item> itemList, BuildContext context) {
  String error = "";

  for (Item item in itemList) {
    if (item.name.isEmpty) {
      error += "Some of the product name(s) are empty. Please check.\n";
      break;
    }
  }

  if (error.isNotEmpty) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(error),
      ),
    );

    return false;
  }

  return true;
}
