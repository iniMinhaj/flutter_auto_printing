class Item {
  final String name;
  final int qty;
  final double price;

  Item({required this.name, required this.qty, required this.price});

  double get total => qty * price;
}
