import 'dart:convert';

class Item {
  String barcode;
  String name;
  double price;
  int quantity;
  int discount = 0;
  int total = 0;
  Item({
    this.barcode = "",
    this.name = "",
    this.price = 0,
    this.quantity = 0,
    this.discount = 0,
    this.total = 0,
  });

  Item copyWith({
    String? barcode,
    String? name,
    double? price,
    int? quantity,
    int? discount,
    int? total,
  }) {
    return Item(
      barcode: barcode ?? this.barcode,
      name: name ?? this.name,
      price: price ?? this.price,
      quantity: quantity ?? this.quantity,
      discount: discount ?? this.discount,
      total: total ?? this.total,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      // 'barcode': barcode,
      'name': name,
      'price': price,
      'quantity': quantity,
      'discount': discount,
      'total': total,
    };
  }

  factory Item.fromMap(Map<String, dynamic> map) {
    return Item(
      barcode: map['barcode'] as String,
      name: map['name'] as String,
      price: map['price'] as double,
      quantity: map['quantity'] as int,
      discount: map['discount'] as int,
      total: map['total'] as int,
    );
  }

  String toJson() => json.encode(toMap());

  factory Item.fromJson(String source) =>
      Item.fromMap(json.decode(source) as Map<String, dynamic>);

  @override
  String toString() {
    return '$barcode,$name,$price,$quantity,$discount';
  }

  String toStringForBill() {
    String item = "";
    item += " ${name.length > 45 ? name.substring(0, 45) : name}\n";
    item +=
        " Price: ${'Rs.$price'.padRight(10, ' ')}   Qty: ${'$quantity'.padRight(5, ' ')}  Discount: Rs.${'$discount'.padRight(3, ' ')}\n";
    item += " Subtotal:${'Rs.$total'.padLeft(39, ' ')}\n";
    return item;
  }

  @override
  bool operator ==(covariant Item other) {
    if (identical(this, other)) return true;

    return other.barcode == barcode &&
        other.name == name &&
        other.price == price &&
        other.quantity == quantity &&
        other.discount == discount &&
        other.total == total;
  }

  @override
  int get hashCode {
    return barcode.hashCode ^
        name.hashCode ^
        price.hashCode ^
        quantity.hashCode ^
        discount.hashCode ^
        total.hashCode;
  }
}
