import '../data/models.dart';

class TopProductMetric {
  final String name;
  final int unitsSold;
  final double revenue;

  TopProductMetric({
    required this.name,
    required this.unitsSold,
    required this.revenue,
  });
}

class ReportService {
  static double calculateTotalRevenue(List<Order> orders) {
    return orders.fold(0, (sum, order) => sum + order.totalPrice);
  }

  static double calculateTotalCost(List<Order> orders) {
    return orders.fold(0, (sum, order) => sum + order.costPrice);
  }

  static double calculateTotalProfit(List<Order> orders) {
    return calculateTotalRevenue(orders) - calculateTotalCost(orders);
  }

  static double calculateProfitMargin(List<Order> orders) {
    final revenue = calculateTotalRevenue(orders);
    if (revenue == 0) return 0;
    return (calculateTotalProfit(orders) / revenue) * 100;
  }

  static double calculateAverageTicket(List<Order> orders) {
    if (orders.isEmpty) return 0;
    return calculateTotalRevenue(orders) / orders.length;
  }

  static Map<String, double> calculateHourlySales(List<Order> orders) {
    // Map of hourly brackets -> relative height indicator (0.0 to 1.0)
    // We will initialize them
    final Map<String, double> hourlyCounts = {
      '08:00': 0.0,
      '10:00': 0.0,
      '12:00': 0.0,
      '14:00': 0.0,
      '16:00': 0.0,
    };

    if (orders.isEmpty) return hourlyCounts;

    for (var order in orders) {
      final hour = order.pickupDateTime.hour;
      if (hour >= 8 && hour < 10) {
        hourlyCounts['08:00'] = (hourlyCounts['08:00'] ?? 0) + order.totalPrice;
      } else if (hour >= 10 && hour < 12) {
        hourlyCounts['10:00'] = (hourlyCounts['10:00'] ?? 0) + order.totalPrice;
      } else if (hour >= 12 && hour < 14) {
        hourlyCounts['12:00'] = (hourlyCounts['12:00'] ?? 0) + order.totalPrice;
      } else if (hour >= 14 && hour < 16) {
        hourlyCounts['14:00'] = (hourlyCounts['14:00'] ?? 0) + order.totalPrice;
      } else if (hour >= 16) {
        hourlyCounts['16:00'] = (hourlyCounts['16:00'] ?? 0) + order.totalPrice;
      }
    }

    // Find the maximum value to scale heights from 0.0 to 1.0
    double maxVal = 0.0;
    hourlyCounts.forEach((key, val) {
      if (val > maxVal) maxVal = val;
    });

    if (maxVal > 0) {
      hourlyCounts.forEach((key, val) {
        hourlyCounts[key] = val / maxVal;
      });
    }

    return hourlyCounts;
  }

  static List<TopProductMetric> calculateTopProducts(List<Order> orders) {
    final Map<String, int> productUnits = {};
    final Map<String, double> productRevenue = {};

    for (var order in orders) {
      for (var item in order.items) {
        productUnits[item.productName] = (productUnits[item.productName] ?? 0) + item.quantity;
        productRevenue[item.productName] = (productRevenue[item.productName] ?? 0) + (item.price * item.quantity);
      }
    }

    final List<TopProductMetric> metrics = [];
    productUnits.forEach((name, units) {
      metrics.add(TopProductMetric(
        name: name,
        unitsSold: units,
        revenue: productRevenue[name] ?? 0.0,
      ));
    });

    // Sort by revenue descending
    metrics.sort((a, b) => b.revenue.compareTo(a.revenue));

    return metrics;
  }
}
