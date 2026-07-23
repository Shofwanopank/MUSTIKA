import '../data/models.dart';

class SmartReminder {
  final String orderId;
  final String customerName;
  final String type; // 'Overdue', '2 Hours', 'Today', 'H-1', 'H-3'
  final String message;
  final DateTime pickupTime;

  SmartReminder({
    required this.orderId,
    required this.customerName,
    required this.type,
    required this.message,
    required this.pickupTime,
  });
}

class ReminderService {
  static List<SmartReminder> calculateReminders(List<Order> orders) {
    final List<SmartReminder> list = [];
    final now = DateTime.now();

    for (var order in orders) {
      if (order.status == OrderStatus.selesai || order.status == OrderStatus.batal) continue;

      final diff = order.pickupDateTime.difference(now);

      // Check if overdue first
      if (order.pickupDateTime.isBefore(now) && order.status != OrderStatus.selesai && order.status != OrderStatus.batal) {
        list.add(SmartReminder(
          orderId: order.id,
          customerName: order.customer.name,
          type: 'Overdue',
          message: 'Overdue: Pickup time was scheduled for ${order.pickupDateTime.hour.toString().padLeft(2, '0')}:${order.pickupDateTime.minute.toString().padLeft(2, '0')}!',
          pickupTime: order.pickupDateTime,
        ));
        continue;
      }

      final daysDiff = order.pickupDateTime.day - now.day;

      if (daysDiff == 0) {
        // Today
        if (diff.inMinutes > 0 && diff.inMinutes <= 120) {
          list.add(SmartReminder(
            orderId: order.id,
            customerName: order.customer.name,
            type: '2 Hours',
            message: 'Urgent: Pickup in ${diff.inMinutes} mins! Baking must finish.',
            pickupTime: order.pickupDateTime,
          ));
        } else {
          list.add(SmartReminder(
            orderId: order.id,
            customerName: order.customer.name,
            type: 'Today',
            message: 'Schedule Today: Pickup at ${order.pickupDateTime.hour.toString().padLeft(2, '0')}:${order.pickupDateTime.minute.toString().padLeft(2, '0')}.',
            pickupTime: order.pickupDateTime,
          ));
        }
      } else if (daysDiff == 1) {
        // Tomorrow (H-1)
        list.add(SmartReminder(
          orderId: order.id,
          customerName: order.customer.name,
          type: 'H-1',
          message: 'H-1 Alert: Prep dough/fillings for tomorrow morning.',
          pickupTime: order.pickupDateTime,
        ));
      } else if (daysDiff == 3) {
        // H-3
        list.add(SmartReminder(
          orderId: order.id,
          customerName: order.customer.name,
          type: 'H-3',
          message: 'H-3 Reminder: Upcoming cake/pastry order scheduled.',
          pickupTime: order.pickupDateTime,
        ));
      }
    }

    return list;
  }
}
