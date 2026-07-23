import 'package:flutter/material.dart';
import '../data/models.dart';
import '../data/repositories.dart';
import '../services/reminder_service.dart';
import '../services/report_service.dart';

class OrderProvider extends ChangeNotifier {
  final OrderRepository _repository;
  List<Order> _orders = [];

  OrderProvider(this._repository);

  List<Order> get orders => _orders;

  Future<void> loadOrders() async {
    _orders = await _repository.getOrders();
    _orders.sort((a, b) => a.pickupDateTime.compareTo(b.pickupDateTime));
    notifyListeners();
  }

  List<Order> get todaysOrders {
    final now = DateTime.now();
    return _orders.where((o) {
      return o.status != OrderStatus.selesai && o.status != OrderStatus.batal &&
          o.pickupDateTime.year == now.year &&
          o.pickupDateTime.month == now.month &&
          o.pickupDateTime.day == now.day;
    }).toList();
  }

  List<Order> get tomorrowsOrders {
    final tomorrow = DateTime.now().add(const Duration(days: 1));
    return _orders.where((o) {
      return o.status != OrderStatus.selesai && o.status != OrderStatus.batal &&
          o.pickupDateTime.year == tomorrow.year &&
          o.pickupDateTime.month == tomorrow.month &&
          o.pickupDateTime.day == tomorrow.day;
    }).toList();
  }

  List<Order> get upcomingOrders {
    final tomorrowEnd = DateTime.now().add(const Duration(days: 1)).copyWith(hour: 23, minute: 59, second: 59);
    return _orders.where((o) {
      return o.status != OrderStatus.selesai && o.status != OrderStatus.batal &&
          o.pickupDateTime.isAfter(tomorrowEnd);
    }).toList();
  }

  List<Order> get readyOrders {
    return _orders.where((o) => o.status == OrderStatus.siap).toList();
  }

  List<SmartReminder> get smartReminders {
    return ReminderService.calculateReminders(_orders);
  }

  double get totalRevenue => ReportService.calculateTotalRevenue(_orders);
  double get totalCost => ReportService.calculateTotalCost(_orders);
  double get totalProfit => ReportService.calculateTotalProfit(_orders);
  double get profitMargin => ReportService.calculateProfitMargin(_orders);
  double get averageTicket => ReportService.calculateAverageTicket(_orders);
  Map<String, double> get hourlySalesActivity => ReportService.calculateHourlySales(_orders);
  List<TopProductMetric> get topSellingProducts => ReportService.calculateTopProducts(_orders);

  int get readyToPickupCount => readyOrders.length;

  Future<void> addOrder(Order order) async {
    _orders.add(order);
    _orders.sort((a, b) => a.pickupDateTime.compareTo(b.pickupDateTime));
    await _repository.saveOrder(order);
    notifyListeners();
  }

  Future<void> updateOrderStatus(String id, OrderStatus status) async {
    final index = _orders.indexWhere((o) => o.id == id);
    if (index != -1) {
      final existing = _orders[index];
      final updatedOrder = Order(
        id: existing.id,
        customer: existing.customer,
        items: existing.items,
        totalPrice: existing.totalPrice,
        costPrice: existing.costPrice,
        dp: existing.dp,
        remainingPayment: existing.remainingPayment,
        paymentStatus: existing.paymentStatus,
        status: status,
        notes: existing.notes,
        pickupDateTime: existing.pickupDateTime,
        productionEstimate: existing.productionEstimate,
        priority: existing.priority,
        createdAt: existing.createdAt,
        updatedAt: DateTime.now(),
      );

      _orders[index] = updatedOrder;
      await _repository.saveOrder(updatedOrder);
      notifyListeners();
    }
  }

  Future<void> updateOrderPayment(String id, {
    required double dp,
    required PaymentStatus paymentStatus,
    required String notes,
  }) async {
    final index = _orders.indexWhere((o) => o.id == id);
    if (index != -1) {
      final existing = _orders[index];
      final updatedOrder = Order(
        id: existing.id,
        customer: existing.customer,
        items: existing.items,
        totalPrice: existing.totalPrice,
        costPrice: existing.costPrice,
        dp: dp,
        remainingPayment: existing.totalPrice - dp,
        paymentStatus: paymentStatus,
        status: existing.status,
        notes: notes,
        pickupDateTime: existing.pickupDateTime,
        productionEstimate: existing.productionEstimate,
        priority: existing.priority,
        createdAt: existing.createdAt,
        updatedAt: DateTime.now(),
      );

      _orders[index] = updatedOrder;
      await _repository.saveOrder(updatedOrder);
      notifyListeners();
    }
  }

  Future<void> removeOrder(String id) async {
    _orders.removeWhere((o) => o.id == id);
    await _repository.deleteOrder(id);
    notifyListeners();
  }
}

extension DateTimeCopy on DateTime {
  DateTime copyWith({
    int? year,
    int? month,
    int? day,
    int? hour,
    int? minute,
    int? second,
    int? millisecond,
    int? microsecond,
  }) {
    return DateTime(
      year ?? this.year,
      month ?? this.month,
      day ?? this.day,
      hour ?? this.hour,
      minute ?? this.minute,
      second ?? this.second,
      millisecond ?? this.millisecond,
      microsecond ?? this.microsecond,
    );
  }
}