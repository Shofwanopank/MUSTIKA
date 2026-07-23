enum OrderStatus { menunggu, diproduksi, siap, dikirim, selesai, batal }
enum PaymentStatus { unpaid, dp, paid }

class Customer {
  final String id;
  final String name;
  final String phone;
  final String address;
  final DateTime createdAt;
  final DateTime updatedAt;

  Customer({
    required this.id,
    required this.name,
    required this.phone,
    this.address = '',
    required this.createdAt,
    required this.updatedAt,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'phone': phone,
        'address': address,
        'createdAt': createdAt.toIso8601String(),
        'updatedAt': updatedAt.toIso8601String(),
      };

  factory Customer.fromJson(Map<String, dynamic> json) => Customer(
        id: json['id'],
        name: json['name'],
        phone: json['phone'],
        address: json['address'] ?? '',
        createdAt: DateTime.parse(json['createdAt']),
        updatedAt: DateTime.parse(json['updatedAt']),
      );
}

class Product {
  final String id;
  final String name;
  final String description;
  final double price;
  int stock;
  bool isAvailable;
  final String imageUrl;
  final String category;
  final DateTime createdAt;
  final DateTime updatedAt;

  Product({
    required this.id,
    required this.name,
    required this.description,
    required this.price,
    required this.stock,
    required this.isAvailable,
    required this.imageUrl,
    required this.category,
    required this.createdAt,
    required this.updatedAt,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'description': description,
        'price': price,
        'stock': stock,
        'isAvailable': isAvailable,
        'imageUrl': imageUrl,
        'category': category,
        'createdAt': createdAt.toIso8601String(),
        'updatedAt': updatedAt.toIso8601String(),
      };

  factory Product.fromJson(Map<String, dynamic> json) => Product(
        id: json['id'],
        name: json['name'],
        description: json['description'],
        price: (json['price'] as num).toDouble(),
        stock: json['stock'] as int,
        isAvailable: json['isAvailable'] as bool,
        imageUrl: json['imageUrl'],
        category: json['category'],
        createdAt: DateTime.parse(json['createdAt']),
        updatedAt: DateTime.parse(json['updatedAt']),
      );
}

class OrderItem {
  final String productName;
  final int quantity;
  final double price;

  OrderItem({
    required this.productName,
    required this.quantity,
    required this.price,
  });

  Map<String, dynamic> toJson() => {
        'productName': productName,
        'quantity': quantity,
        'price': price,
      };

  factory OrderItem.fromJson(Map<String, dynamic> json) => OrderItem(
        productName: json['productName'],
        quantity: json['quantity'] as int,
        price: (json['price'] as num).toDouble(),
      );
}

class Order {
  final String id; // Invoice number
  final Customer customer;
  final List<OrderItem> items;
  final double totalPrice;
  final double costPrice;
  final double dp; // Down payment
  final double remainingPayment; // Sisa pembayaran
  final PaymentStatus paymentStatus; // Status pembayaran
  OrderStatus status;
  final String notes;
  final DateTime pickupDateTime;
  final Duration productionEstimate;
  final String priority;
  final DateTime createdAt;
  final DateTime updatedAt;

  Order({
    required this.id,
    required this.customer,
    required this.items,
    required this.totalPrice,
    required this.costPrice,
    this.dp = 0,
    this.remainingPayment = 0,
    this.paymentStatus = PaymentStatus.unpaid,
    required this.status,
    required this.notes,
    required this.pickupDateTime,
    required this.productionEstimate,
    required this.priority,
    required this.createdAt,
    required this.updatedAt,
  });

  String get itemsSummary {
    return items.map((e) => '${e.quantity}x ${e.productName}').join(', ');
  }

  String get timeAgo {
    final difference = DateTime.now().difference(createdAt);
    if (difference.inMinutes < 60) {
      return '${difference.inMinutes}m ago';
    } else if (difference.inHours < 24) {
      return '${difference.inHours}h ago';
    } else {
      return '${difference.inDays}d ago';
    }
  }

  double get profit => totalPrice - costPrice;

  Map<String, dynamic> toJson() => {
        'id': id,
        'customer': customer.toJson(),
        'items': items.map((e) => e.toJson()).toList(),
        'totalPrice': totalPrice,
        'costPrice': costPrice,
        'dp': dp,
        'remainingPayment': remainingPayment,
        'paymentStatus': paymentStatus.name,
        'status': status.name,
        'notes': notes,
        'pickupDateTime': pickupDateTime.toIso8601String(),
        'productionEstimate': productionEstimate.inMinutes,
        'priority': priority,
        'createdAt': createdAt.toIso8601String(),
        'updatedAt': updatedAt.toIso8601String(),
      };

  factory Order.fromJson(Map<String, dynamic> json) => Order(
        id: json['id'],
        customer: Customer.fromJson(Map<String, dynamic>.from(json['customer'])),
        items: (json['items'] as List)
            .map((e) => OrderItem.fromJson(Map<String, dynamic>.from(e)))
            .toList(),
        totalPrice: (json['totalPrice'] as num).toDouble(),
        costPrice: (json['costPrice'] as num).toDouble(),
        dp: (json['dp'] as num?)?.toDouble() ?? 0,
        remainingPayment: (json['remainingPayment'] as num?)?.toDouble() ?? 0,
        paymentStatus: PaymentStatus.values.firstWhere(
          (e) => e.name == (json['paymentStatus'] ?? 'unpaid'),
        ),
        status: OrderStatus.values.firstWhere((e) => e.name == json['status']),
        notes: json['notes'] ?? '',
        pickupDateTime: DateTime.parse(json['pickupDateTime']),
        productionEstimate: Duration(minutes: json['productionEstimate'] as int),
        priority: json['priority'] ?? 'Medium',
        createdAt: DateTime.parse(json['createdAt']),
        updatedAt: DateTime.parse(json['updatedAt']),
      );
}