// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:convert';
import 'dart:math';

import 'package:flutter/foundation.dart';

import 'package:inventory_app/models/item.dart';

class Bill {
  String billNo;
  String customerName;
  String phone;
  List<Item> itemList;
  String date;
  Bill({
    required this.billNo,
    required this.customerName,
    required this.phone,
    required this.itemList,
    required this.date,
  });

  Bill copyWith({
    String? billNo,
    String? customerName,
    String? phone,
    List<Item>? itemList,
    String? date,
  }) {
    return Bill(
      billNo: billNo ?? this.billNo,
      customerName: customerName ?? this.customerName,
      phone: phone ?? this.phone,
      itemList: itemList ?? this.itemList,
      date: date ?? this.date,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'billNo': billNo,
      'customerName': customerName,
      'phone': phone,
      'date': DateTime.now().toString(),
      'itemList': itemList.map((x) => x.toMap()).toList(),
    };
  }

  factory Bill.fromMap(Map<String, dynamic> map) {
    return Bill(
      billNo: map['billNo'] as String,
      customerName: map['customerName'] as String,
      phone: map['phone'] as String,
      itemList: List<Item>.from(
        (map['itemList'] as List<int>).map<Item>(
          (x) => Item.fromMap(x as Map<String, dynamic>),
        ),
      ),
      date: map['date'] as String,
    );
  }

  String toJson() => json.encode(toMap());

  factory Bill.fromJson(String source) =>
      Bill.fromMap(json.decode(source) as Map<String, dynamic>);

  @override
  String toString() {
    int total = 0;

    String bill = "";
    bill += '\n${"Shri Govind Shopping Mart!".padLeft(38, " ")}\n\n';
    bill += "${'Ord. No.: $billNo'.padLeft(36, ' ')}\n";
    bill +=
        " Customer Name: ${customerName.substring(0, min(33, customerName.length))}\n";
    bill += " Phone: ${phone.padRight(10, ' ')} ";
    bill += '${"Date: $date".padLeft(30, " ")}\n';
    bill += "".padLeft(50, "*");
    bill += "\n\n";

    for (int idx = 0; idx < itemList.length; idx++) {
      Item item = itemList[idx];

      bill += " ${idx + 1}.${item.toStringForBill()}\n";
      total += item.total;
    }

    bill += " Order Total:${'Rs.$total'.padLeft(36, ' ')}\n\n";
    bill += "".padLeft(50, "*");
    bill += '\n${"Thank you for shopping 😊".padLeft(37, " ")}\n';

    return bill;
    // return 'Bill(billNo: $billNo, customerName: $customerName, phone: $phone, itemList: $itemList)';
  }

  @override
  bool operator ==(covariant Bill other) {
    if (identical(this, other)) return true;

    return other.billNo == billNo &&
        other.customerName == customerName &&
        other.phone == phone &&
        listEquals(other.itemList, itemList);
  }

  @override
  int get hashCode {
    return billNo.hashCode ^
        customerName.hashCode ^
        phone.hashCode ^
        itemList.hashCode;
  }
}
