class Item {
  int? id;
  final String itemName;
  final String shopName;
  final String date;
  final double price;
  final String? photoPath;
  int orderIndex; // Menambahkan kolom baru

  Item({
    this.id,
    required this.itemName,
    required this.shopName,
    required this.date,
    required this.price,
    this.photoPath,
    this.orderIndex = 0, // Default order
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'itemName': itemName,
      'shopName': shopName,
      'date': date,
      'price': price,
      'photoPath': photoPath,
      'orderIndex': orderIndex,
    };
  }

  factory Item.fromMap(Map<String, dynamic> map) {
    return Item(
      id: map['id'],
      itemName: map['itemName'],
      shopName: map['shopName'],
      date: map['date'],
      price: map['price'],
      photoPath: map['photoPath'],
      orderIndex: map['orderIndex'],
    );
  }
}
