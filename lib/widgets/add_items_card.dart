import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:inventory_app/models/item.dart';

class AddItemsCard extends StatefulWidget {
  final int listNo;
  final List<Item> itemList;
  final Map<String, Item> map;
  final Function(int) deleteCallback;
  const AddItemsCard({
    Key? key,
    required this.listNo,
    required this.itemList,
    required this.map,
    required this.deleteCallback,
  }) : super(key: key);

  @override
  State<AddItemsCard> createState() => _AddItemsCardState();
}

class _AddItemsCardState extends State<AddItemsCard> {
  TextEditingController barcodeController = TextEditingController();
  TextEditingController nameController = TextEditingController();
  TextEditingController priceController = TextEditingController();
  TextEditingController quantityController = TextEditingController();
  TextEditingController discountController = TextEditingController();

  late Item item;
  late int idx;

  void updateItemTile(String barcode) {
    Item? item = widget.map[barcode];
    nameController.text = item == null ? "" : item.name;
    priceController.text = item == null ? "0" : item.price.toString();
    quantityController.text = item == null ? "0" : item.quantity.toString();
    discountController.text = item == null ? "0" : item.discount.toString();

    widget.itemList[idx].barcode = barcode;
    widget.itemList[idx].name = nameController.text;
    widget.itemList[idx].price = double.parse(priceController.text);
    widget.itemList[idx].quantity = int.parse(quantityController.text);
    widget.itemList[idx].discount = int.parse(discountController.text);
  }

  @override
  void dispose() {
    barcodeController.dispose();
    nameController.dispose();
    priceController.dispose();
    quantityController.dispose();
    discountController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    idx = widget.listNo;
    item = widget.itemList[idx];

    barcodeController.text = item.barcode;
    nameController.text = item.name;
    priceController.text = item.price.toString();
    quantityController.text = item.quantity.toString();
    discountController.text = item.discount.toString();

    return Row(
      children: [
        Text(
          (idx + 1).toString().padRight(4),
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
        const SizedBox(width: 20),
        SizedBox(
          width: 250,
          child: TextField(
            maxLength: 50,
            controller: barcodeController,
            inputFormatters: [
              FilteringTextInputFormatter.allow(RegExp(r'[0-9a-zA-Z]+')),
            ],
            onChanged: updateItemTile,
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
              if (val.isEmpty) {
                widget.itemList[idx].quantity = 0;
              } else {
                widget.itemList[idx].quantity = int.parse(val);
              }
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
        SizedBox(
          width: 120,
          child: TextField(
            controller: discountController,
            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            onChanged: (val) {
              if (val.isEmpty) {
                widget.itemList[idx].discount = 0;
              } else {
                widget.itemList[idx].discount = int.parse(val);
              }
            },
            keyboardType: TextInputType.number,
            maxLength: 2,
            decoration: const InputDecoration(
              hintText: "Discount",
              hintStyle: TextStyle(color: Colors.red),
              counterText: '',
              prefixIcon: Icon(Icons.currency_rupee_sharp),
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
