import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:inventory_app/models/item.dart';

class BarcodeCreateCard extends StatefulWidget {
  final int listNo;
  final int codeNo;
  final List<Item> itemList;
  final Map<String, Item> map;
  final Function(int) deleteCallback;
  const BarcodeCreateCard({
    Key? key,
    required this.listNo,
    required this.codeNo,
    required this.itemList,
    required this.map,
    required this.deleteCallback,
  }) : super(key: key);

  @override
  State<BarcodeCreateCard> createState() => _BarcodeCreateCardState();
}

class _BarcodeCreateCardState extends State<BarcodeCreateCard> {
  TextEditingController barcodeController = TextEditingController();
  TextEditingController nameController = TextEditingController();
  TextEditingController priceController = TextEditingController();
  TextEditingController quantityController = TextEditingController();
  late Item item;
  late int idx;

  @override
  void dispose() {
    barcodeController.dispose();
    nameController.dispose();
    priceController.dispose();
    quantityController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    idx = widget.listNo;
    item = widget.itemList[idx];

    barcodeController.text =
        "SGSM${(widget.codeNo + widget.listNo).toString().padLeft(5, '0')}";
    nameController.text = item.name;
    priceController.text = item.price.toString();
    quantityController.text = item.quantity.toString();
    widget.itemList[idx].barcode = barcodeController.text;

    return Row(
      children: [
        Text(
          (idx + 1).toString().padRight(4),
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
        const SizedBox(width: 20),
        SizedBox(
          width: 150,
          child: TextField(
            controller: barcodeController,
            textAlign: TextAlign.center,
            readOnly: true,
            decoration: const InputDecoration(
              border: OutlineInputBorder(
                borderSide: BorderSide(width: 1),
              ),
            ),
          ),
        ),
        const SizedBox(width: 20),
        Flexible(
          child: TextField(
            controller: nameController,
            onChanged: (val) {
              widget.itemList[idx].name = val;
            },
            keyboardType: TextInputType.text,
            decoration: const InputDecoration(
              hintText: "Product Name",
              hintStyle: TextStyle(color: Colors.red),
              border: OutlineInputBorder(
                borderSide: BorderSide(width: 1),
              ),
            ),
          ),
        ),
        const SizedBox(width: 20),
        SizedBox(
          width: 150,
          child: TextField(
            controller: priceController,
            maxLength: 10,
            inputFormatters: [
              FilteringTextInputFormatter.allow(RegExp(r'[0-9]+.?[0-9]?')),
            ],
            onChanged: (val) {
              RegExp regExp = RegExp('^[0-9]+[.]\$');
              if (val.isEmpty) {
                widget.itemList[idx].price = 0;
              } else if (!regExp.hasMatch(val)) {
                widget.itemList[idx].price = double.parse(val);
              }
            },
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(
              hintText: "Price",
              hintStyle: TextStyle(color: Colors.red),
              prefixIcon: Icon(Icons.currency_rupee_sharp),
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
            controller: quantityController,
            maxLength: 5,
            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            onChanged: (val) {
              widget.itemList[idx].quantity = int.parse(val);
            },
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(
              hintText: "Quantity",
              hintStyle: TextStyle(color: Colors.red),
              counterText: '',
              border: OutlineInputBorder(
                borderSide: BorderSide(width: 1),
              ),
            ),
          ),
        ),
        const SizedBox(width: 20),
        InkWell(
          onTap: () => widget.deleteCallback(idx),
          mouseCursor: MaterialStateMouseCursor.clickable,
          child: const Icon(
            Icons.delete_forever,
            size: 32,
            color: Colors.red,
          ),
        ),
      ],
    );
  }
}
