```dart
class Sale {
  final String id;
  final String customerName;
  final String mushroomType;
  final double quantity;
  final double ratePerKg;
  final double totalPrice;
  final DateTime date;

  Sale({
    required this.id,
    required this.customerName,
    required this.mushroomType,
    required this.quantity,
    required this.ratePerKg,
    required this.totalPrice,
    required this.date,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'customerName': customerName,
      'mushroomType': mushroomType,
      'quantity': quantity,
      'ratePerKg': ratePerKg,
      'totalPrice': totalPrice,
      'date': date.toIso8601String(),
    };
  }

  factory Sale.fromMap(Map<String, dynamic> map) {
    return Sale(
      id: map['id'] as String,
      customerName: map['customerName'] as String,
      mushroomType: map['mushroomType'] as String,
      quantity: (map['quantity'] as num).toDouble(),
      ratePerKg: (map['ratePerKg'] as num).toDouble(),
      totalPrice: (map['totalPrice'] as num).toDouble(),
      date: DateTime.parse(map['date'] as String),
    );
  }
}
```

---

### 🟢 FILE 5 — Type this in the name box:
```
lib/services/sales_store.dart
```
Paste this code:
```dart
import '../models/sale.dart';

class SalesStore {
  SalesStore._();
  static final SalesStore instance = SalesStore._();

  final List<Sale> _sales = [];

  List<Sale> getAll() {
    final sorted = List<Sale>.from(_sales);
    sorted.sort((a, b) => b.date.compareTo(a.date));
    return sorted;
  }

  void add(Sale sale) {
    _sales.add(sale);
  }

  void delete(String id) {
    _sales.removeWhere((s) => s.id == id);
  }
}
```
