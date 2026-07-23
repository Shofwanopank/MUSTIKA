import 'dart:math';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../data/models.dart';
import '../providers/customer_provider.dart';
import '../providers/product_provider.dart';
import '../providers/order_provider.dart';
import '../theme/bakery_theme.dart';
import '../services/reminder_service.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  bool _isCalendarExpanded = false;
  DateTime _selectedCalendarDate = DateTime.now();

  // Calendar variables
  int _currentYear = DateTime.now().year;
  int _currentMonth = DateTime.now().month;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _nextMonth() {
    setState(() {
      if (_currentMonth == 12) {
        _currentMonth = 1;
        _currentYear++;
      } else {
        _currentMonth++;
      }
    });
  }

  void _prevMonth() {
    setState(() {
      if (_currentMonth == 1) {
        _currentMonth = 12;
        _currentYear--;
      } else {
        _currentMonth--;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final orderProvider = Provider.of<OrderProvider>(context);
    final customerProvider = Provider.of<CustomerProvider>(context);
    final productProvider = Provider.of<ProductProvider>(context);
    final textTheme = Theme.of(context).textTheme;

    // Filter active orders for segmented tabs
    final todayList = orderProvider.todaysOrders;
    final tomorrowList = orderProvider.tomorrowsOrders;
    final upcomingList = orderProvider.upcomingOrders;
    final readyList = orderProvider.readyOrders;

    // Calendar filter
    final calendarFilteredOrders = orderProvider.orders.where((o) {
      return o.pickupDateTime.year == _selectedCalendarDate.year &&
          o.pickupDateTime.month == _selectedCalendarDate.month &&
          o.pickupDateTime.day == _selectedCalendarDate.day &&
          o.status != OrderStatus.delivered;
    }).toList();

    return Scaffold(
      appBar: AppBar(
        backgroundColor: BakeryTheme.surface,
        elevation: 0,
        scrolledUnderElevation: 0,
        title: Row(
          children: [
            const Icon(Icons.bakery_dining_outlined, color: BakeryTheme.primary, size: 32),
            const SizedBox(width: 8),
            Text(
              'Roti Mustika',
              style: textTheme.headlineMedium?.copyWith(
                color: BakeryTheme.primary,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        actions: [
          // Customer Directory CRUD Button
          IconButton(
            icon: const Icon(Icons.people_outline, color: BakeryTheme.primary),
            tooltip: 'Customer Directory',
            onPressed: () {
              _showCustomerDirectoryModal(context, customerProvider);
            },
          ),
          IconButton(
            icon: Icon(
              _isCalendarExpanded ? Icons.calendar_today : Icons.calendar_today_outlined,
              color: BakeryTheme.primary,
            ),
            onPressed: () {
              setState(() {
                _isCalendarExpanded = !_isCalendarExpanded;
              });
            },
          ),
          const SizedBox(width: 8),
          Container(
            margin: const EdgeInsets.only(right: 16),
            width: 40,
            height: 40,
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              color: BakeryTheme.primaryContainer,
            ),
            child: const Center(
              child: Text(
                'RM',
                style: TextStyle(
                  color: BakeryTheme.onPrimaryContainer,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
      ),
      body: orderProvider.orders.isEmpty
          ? _buildEmptyState(context)
          : Column(
              children: [
                // Collapsible Calendar view
                if (_isCalendarExpanded) _buildCalendarView(context, orderProvider),

                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Smart Reminders Alert Box
                        if (orderProvider.smartReminders.isNotEmpty)
                          _buildRemindersWidget(context, orderProvider.smartReminders),

                        const SizedBox(height: 12),

                        // Calendar selection indicator
                        if (_isCalendarExpanded) ...[
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Date Selected: ${_selectedCalendarDate.day}/${_selectedCalendarDate.month}/${_selectedCalendarDate.year}',
                                style: textTheme.labelLarge?.copyWith(
                                  color: BakeryTheme.primary,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              TextButton(
                                onPressed: () {
                                  setState(() {
                                    _selectedCalendarDate = DateTime.now();
                                  });
                                },
                                child: const Text('Reset to Today'),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          calendarFilteredOrders.isEmpty
                              ? Center(
                                  child: Padding(
                                    padding: const EdgeInsets.symmetric(vertical: 24.0),
                                    child: Text(
                                      'No orders scheduled for this day',
                                      style: textTheme.bodyMedium?.copyWith(color: BakeryTheme.outline),
                                    ),
                                  ),
                                )
                              : ListView.builder(
                                  shrinkWrap: true,
                                  physics: const NeverScrollableScrollPhysics(),
                                  itemCount: calendarFilteredOrders.length,
                                  itemBuilder: (context, index) {
                                    final order = calendarFilteredOrders[index];
                                    return _buildOrderBentoCard(context, order, orderProvider, productProvider);
                                  },
                                ),
                          const Divider(height: 32),
                        ],

                        // Overview header
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Orders Dashboard',
                              style: textTheme.headlineMedium?.copyWith(
                                color: BakeryTheme.onSurface,
                              ),
                            ),
                            ElevatedButton.icon(
                              onPressed: () {
                                Navigator.pushNamed(context, '/new_order');
                              },
                              icon: const Icon(Icons.add, size: 18),
                              label: const Text('New Order'),
                              style: ElevatedButton.styleFrom(
                                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                                textStyle: textTheme.labelLarge?.copyWith(color: BakeryTheme.onPrimary),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),

                        // Segmented Tabs
                        TabBar(
                          controller: _tabController,
                          isScrollable: false,
                          labelColor: BakeryTheme.primary,
                          unselectedLabelColor: BakeryTheme.outline,
                          indicatorColor: BakeryTheme.primary,
                          dividerColor: Colors.transparent,
                          labelStyle: textTheme.labelLarge?.copyWith(fontWeight: FontWeight.bold),
                          tabs: [
                            Tab(text: 'Today (${todayList.length})'),
                            Tab(text: 'Tomorrow (${tomorrowList.length})'),
                            Tab(text: 'Upcoming (${upcomingList.length})'),
                            Tab(text: 'Ready (${readyList.length})'),
                          ],
                        ),
                        const SizedBox(height: 20),

                        // Tab Views
                        SizedBox(
                          height: 500,
                          child: TabBarView(
                            controller: _tabController,
                            children: [
                              _buildTabOrderList(context, todayList, orderProvider, productProvider),
                              _buildTabOrderList(context, tomorrowList, orderProvider, productProvider),
                              _buildTabOrderList(context, upcomingList, orderProvider, productProvider),
                              _buildTabOrderList(context, readyList, orderProvider, productProvider),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: BakeryTheme.primaryContainer.withOpacity(0.15),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.assignment_outlined,
                size: 64,
                color: BakeryTheme.primary,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'No Scheduled Orders Yet 🥐',
              style: textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: BakeryTheme.secondary,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'Your scheduled bakery orders will appear here. Get started by taking the first scheduled order from a customer!',
              textAlign: TextAlign.center,
              style: textTheme.bodyMedium?.copyWith(
                color: BakeryTheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 32),
            ElevatedButton.icon(
              onPressed: () {
                Navigator.pushNamed(context, '/new_order');
              },
              icon: const Icon(Icons.add),
              label: const Text('Create First Order'),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 16),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRemindersWidget(BuildContext context, List<SmartReminder> reminders) {
    final textTheme = Theme.of(context).textTheme;

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: BakeryTheme.errorContainer.withOpacity(0.4),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: BakeryTheme.error.withOpacity(0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.notifications_active, color: BakeryTheme.error),
              const SizedBox(width: 8),
              Text(
                'Active Reminders',
                style: textTheme.labelLarge?.copyWith(
                  color: BakeryTheme.onErrorContainer,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: reminders.length,
            itemBuilder: (context, index) {
              final reminder = reminders[index];
              return Padding(
                padding: const EdgeInsets.only(bottom: 8.0),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      margin: const EdgeInsets.only(top: 2),
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: reminder.type == '2 Hours' || reminder.type == 'Overdue' ? BakeryTheme.error : BakeryTheme.primary,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        reminder.type,
                        style: const TextStyle(color: Colors.white, fontSize: 8, fontWeight: FontWeight.bold),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        '#${reminder.orderId} (${reminder.customerName}): ${reminder.message}',
                        style: textTheme.labelSmall?.copyWith(
                          color: BakeryTheme.onErrorContainer,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildCalendarView(BuildContext context, OrderProvider provider) {
    final textTheme = Theme.of(context).textTheme;

    final daysInMonth = DateTime(_currentYear, _currentMonth + 1, 0).day;
    final firstWeekday = DateTime(_currentYear, _currentMonth, 1).weekday;

    final offset = firstWeekday == 7 ? 0 : firstWeekday;

    final monthNames = [
      'January', 'February', 'March', 'April', 'May', 'June',
      'July', 'August', 'September', 'October', 'November', 'December'
    ];

    final List<Widget> dayCells = [];

    final weekDays = ['S', 'M', 'T', 'W', 'T', 'F', 'S'];
    for (var day in weekDays) {
      dayCells.add(Center(
        child: Text(
          day,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: BakeryTheme.outline),
        ),
      ));
    }

    for (int i = 0; i < offset; i++) {
      dayCells.add(const SizedBox());
    }

    for (int dayNum = 1; dayNum <= daysInMonth; dayNum++) {
      final cellDate = DateTime(_currentYear, _currentMonth, dayNum);
      final isSelected = _selectedCalendarDate.year == cellDate.year &&
          _selectedCalendarDate.month == cellDate.month &&
          _selectedCalendarDate.day == cellDate.day;

      final hasOrders = provider.orders.any((o) =>
          o.pickupDateTime.year == cellDate.year &&
          o.pickupDateTime.month == cellDate.month &&
          o.pickupDateTime.day == cellDate.day &&
          o.status != OrderStatus.delivered);

      dayCells.add(
        GestureDetector(
          onTap: () {
            setState(() {
              _selectedCalendarDate = cellDate;
            });
          },
          child: Container(
            margin: const EdgeInsets.all(2),
            decoration: BoxDecoration(
              color: isSelected ? BakeryTheme.primary : Colors.transparent,
              shape: BoxShape.circle,
            ),
            child: Stack(
              alignment: Alignment.center,
              children: [
                Center(
                  child: Text(
                    '$dayNum',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: isSelected
                          ? BakeryTheme.onPrimary
                          : BakeryTheme.onSurface,
                    ),
                  ),
                ),
                if (hasOrders && !isSelected)
                  Positioned(
                    bottom: 4,
                    child: Container(
                      width: 4,
                      height: 4,
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        color: BakeryTheme.tertiary,
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: const BoxDecoration(
        color: BakeryTheme.surfaceContainerLow,
        border: Border(bottom: BorderSide(color: BakeryTheme.outlineVariant, width: 0.5)),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              IconButton(
                icon: const Icon(Icons.arrow_back_ios, size: 16),
                onPressed: _prevMonth,
              ),
              Text(
                '${monthNames[_currentMonth - 1]} $_currentYear',
                style: textTheme.labelLarge?.copyWith(fontWeight: FontWeight.bold, fontSize: 16),
              ),
              IconButton(
                icon: const Icon(Icons.arrow_forward_ios, size: 16),
                onPressed: _nextMonth,
              ),
            ],
          ),
          const SizedBox(height: 8),
          GridView.count(
            shrinkWrap: true,
            crossAxisCount: 7,
            childAspectRatio: 1.2,
            physics: const NeverScrollableScrollPhysics(),
            children: dayCells,
          ),
        ],
      ),
    );
  }

  Widget _buildTabOrderList(
    BuildContext context,
    List<Order> list,
    OrderProvider provider,
    ProductProvider productProvider,
  ) {
    if (list.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 48.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.assignment_outlined, size: 48, color: BakeryTheme.outline.withOpacity(0.5)),
              const SizedBox(height: 16),
              Text(
                'No orders scheduled',
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(color: BakeryTheme.onSurfaceVariant),
              ),
            ],
          ),
        ),
      );
    }

    return ListView.builder(
      itemCount: list.length,
      itemBuilder: (context, index) {
        final order = list[index];
        return _buildOrderBentoCard(context, order, provider, productProvider);
      },
    );
  }

  Widget _buildOrderBentoCard(
    BuildContext context,
    Order order,
    OrderProvider orderProvider,
    ProductProvider productProvider,
  ) {
    final textTheme = Theme.of(context).textTheme;

    Color statusBgColor = BakeryTheme.primaryContainer;
    Color statusTextColor = BakeryTheme.onPrimaryContainer;

    if (order.status == OrderStatus.ready) {
      statusBgColor = BakeryTheme.successContainer;
      statusTextColor = BakeryTheme.onSuccessContainer;
    }

    Color priorityColor = BakeryTheme.outline;
    if (order.priority == 'High') {
      priorityColor = BakeryTheme.error;
    } else if (order.priority == 'Medium') {
      priorityColor = BakeryTheme.tertiary;
    }

    final hrs = order.productionEstimate.inHours;
    final mins = order.productionEstimate.inMinutes % 60;
    final estimateText = hrs > 0 ? '$hrs hr ${mins > 0 ? "$mins min" : ""}' : '$mins mins';

    // Mock first image from productProvider based on first item
    String firstProductImageUrl = '';
    if (order.items.isNotEmpty) {
      final name = order.items.first.productName;
      final matchingProd = productProvider.products.firstWhere((p) => p.name == name, orElse: () => Product(
        id: '', name: '', description: '', price: 0, stock: 0, isAvailable: false, imageUrl: '', category: '', createdAt: DateTime.now(), updatedAt: DateTime.now()
      ));
      if (matchingProd.imageUrl.isNotEmpty) {
        firstProductImageUrl = matchingProd.imageUrl;
      }
    }

    return GestureDetector(
      onTap: () {
        _showOrderDetailsSheet(context, order, orderProvider);
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: BakeryTheme.surfaceContainerLowest,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: BakeryTheme.outline.withOpacity(0.1)),
          boxShadow: const [
            BoxShadow(
              color: Color(0x05432818),
              blurRadius: 10,
              offset: Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                    color: BakeryTheme.surfaceContainerLow,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Image.network(
                      firstProductImageUrl.isNotEmpty ? firstProductImageUrl : 'https://lh3.googleusercontent.com/aida-public/AB6AXuChnDtb50qiLpXyaujpUfzXM451Ls0Oj1SdYthglp1yhJS3LDjRtzx8evGL4VIm7PXgGB2ZIj2qirdhZzcvwzn6XroGWf9eJ_0UwNuFaFfcVixADQftcfN8JIbpx5sIGrrZfFcUpBTkNG8KC9czzw_Acyns3pvD1lU1hMKtpgTv2dgFcv63XFVG7odcELADT6OE5VgIjqcUtjeKVU7v3a1CybmeOvUwHwi-r9VnYoogBXKBdB2j0S5Gb87GEUSRcPffYUnv81Te',
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return const Icon(
                          Icons.bakery_dining_outlined,
                          color: BakeryTheme.primary,
                        );
                      },
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(
                            '#${order.id}',
                            style: textTheme.labelLarge?.copyWith(fontSize: 15, fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
                            decoration: BoxDecoration(
                              color: priorityColor.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(6),
                              border: Border.all(color: priorityColor.withOpacity(0.3)),
                            ),
                            child: Text(
                              order.priority,
                              style: TextStyle(color: priorityColor, fontSize: 8, fontWeight: FontWeight.bold),
                            ),
                          ),
                          const SizedBox(width: 6),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
                            decoration: BoxDecoration(
                              color: statusBgColor,
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              order.status.name.toUpperCase(),
                              style: TextStyle(color: statusTextColor, fontSize: 8, fontWeight: FontWeight.bold),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        order.customer.name,
                        style: textTheme.labelLarge?.copyWith(fontSize: 14),
                      ),
                      Text(
                        order.itemsSummary,
                        style: textTheme.labelSmall?.copyWith(fontSize: 12),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 6),
                      Row(
                        children: [
                          const Icon(Icons.access_time_outlined, size: 14, color: BakeryTheme.primary),
                          const SizedBox(width: 4),
                          Text(
                            'Pickup: ${order.pickupDateTime.day}/${order.pickupDateTime.month} at '
                            '${order.pickupDateTime.hour.toString().padLeft(2, '0')}:${order.pickupDateTime.minute.toString().padLeft(2, '0')}',
                            style: textTheme.labelSmall?.copyWith(fontSize: 10, fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(width: 10),
                          const Icon(Icons.timer_outlined, size: 14, color: BakeryTheme.secondary),
                          const SizedBox(width: 4),
                          Text(
                            estimateText,
                            style: textTheme.labelSmall?.copyWith(fontSize: 10),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                Text(
                  'Rp ${order.totalPrice.toStringAsFixed(0).replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]}.')}',
                  style: textTheme.headlineMedium?.copyWith(
                    color: BakeryTheme.primary,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _showOrderDetailsSheet(BuildContext context, Order order, OrderProvider provider) {
    final textTheme = Theme.of(context).textTheme;

    showModalBottomSheet(
      context: context,
      backgroundColor: BakeryTheme.surfaceContainerLowest,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setSheetState) {
            int activeStep = 0;
            if (order.status == OrderStatus.ready) {
              activeStep = 3;
            } else if (order.status == OrderStatus.delivered) {
              activeStep = 4;
            } else {
              activeStep = 1;
            }

            final hrs = order.productionEstimate.inHours;
            final mins = order.productionEstimate.inMinutes % 60;
            final estimateText = hrs > 0 ? '$hrs hr ${mins > 0 ? "$mins min" : ""}' : '$mins mins';

            return DraggableScrollableSheet(
              expand: false,
              initialChildSize: 0.75,
              minChildSize: 0.5,
              maxChildSize: 0.9,
              builder: (context, scrollController) {
                return SingleChildScrollView(
                  controller: scrollController,
                  padding: const EdgeInsets.all(24.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Center(
                        child: Container(
                          width: 40,
                          height: 4,
                          decoration: BoxDecoration(
                            color: BakeryTheme.outlineVariant,
                            borderRadius: BorderRadius.circular(2),
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Order #${order.id}',
                            style: textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.bold),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color: order.status == OrderStatus.ready
                                  ? BakeryTheme.successContainer
                                  : BakeryTheme.primaryContainer,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              order.status.name.toUpperCase(),
                              style: TextStyle(
                                color: order.status == OrderStatus.ready
                                    ? BakeryTheme.onSuccessContainer
                                    : BakeryTheme.onPrimaryContainer,
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),

                      // Timeline
                      Text(
                        'Production Timeline',
                        style: textTheme.labelLarge?.copyWith(color: BakeryTheme.primary, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 16),
                      _buildTimelineRow(context, 'Ordered', 'Placement date: ${order.createdAt.day}/${order.createdAt.month}', activeStep >= 0, activeStep == 0),
                      _buildTimelineConnector(activeStep > 0),
                      _buildTimelineRow(context, 'Prepping', 'Dough/filling preparation', activeStep >= 1, activeStep == 1),
                      _buildTimelineConnector(activeStep > 1),
                      _buildTimelineRow(context, 'Baking', 'Oven active / cooking phase', activeStep >= 2, activeStep == 2),
                      _buildTimelineConnector(activeStep > 2),
                      _buildTimelineRow(context, 'Ready', 'Cooling / Ready to pickup', activeStep >= 3, activeStep == 3),
                      _buildTimelineConnector(activeStep > 3),
                      _buildTimelineRow(context, 'Picked Up', 'Delivered to customer', activeStep >= 4, activeStep == 4),

                      const Divider(height: 32),

                      // Customer Details
                      Text(
                        'Customer & Logistics Details',
                        style: textTheme.labelLarge?.copyWith(color: BakeryTheme.primary, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 12),
                      Text('Customer Name: ${order.customer.name}', style: textTheme.bodyMedium),
                      const SizedBox(height: 4),
                      Text('Phone: ${order.customer.phone}', style: textTheme.bodyMedium),
                      const SizedBox(height: 4),
                      Text('Notes: ${order.notes.isEmpty ? "No special instructions" : order.notes}', style: textTheme.bodyMedium),
                      const SizedBox(height: 4),
                      Text(
                        'Pickup Date/Time: ${order.pickupDateTime.day}/${order.pickupDateTime.month}/${order.pickupDateTime.year} at '
                        '${order.pickupDateTime.hour.toString().padLeft(2, '0')}:${order.pickupDateTime.minute.toString().padLeft(2, '0')}',
                        style: textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 4),
                      Text('Production Estimate: $estimateText', style: textTheme.bodyMedium),

                      const Divider(height: 32),

                      // Items
                      Text(
                        'Order Items',
                        style: textTheme.labelLarge?.copyWith(color: BakeryTheme.primary, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 8),
                      ListView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: order.items.length,
                        itemBuilder: (context, idx) {
                          final item = order.items[idx];
                          return Padding(
                            padding: const EdgeInsets.symmetric(vertical: 4.0),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text('${item.quantity}x ${item.productName}', style: textTheme.bodyMedium),
                                Text(
                                  'Rp ${(item.price * item.quantity).toStringAsFixed(0).replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]}.')}',
                                  style: textTheme.bodyMedium,
                                ),
                              ],
                            ),
                          );
                        },
                      ),

                      const Divider(height: 32),

                      // Actions
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          TextButton(
                            onPressed: () {
                              Navigator.pop(context);
                              provider.removeOrder(order.id);
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text('Order #${order.id} cancelled.')),
                              );
                            },
                            child: const Text('Cancel Order', style: TextStyle(color: BakeryTheme.error)),
                          ),
                          const SizedBox(width: 16),
                          ElevatedButton(
                            onPressed: () {
                              if (order.status == OrderStatus.processing) {
                                provider.updateOrderStatus(order.id, OrderStatus.ready);
                                setSheetState(() {
                                  order.status = OrderStatus.ready;
                                });
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(content: Text('Order #${order.id} is now READY!')),
                                );
                              } else if (order.status == OrderStatus.ready) {
                                provider.updateOrderStatus(order.id, OrderStatus.delivered);
                                Navigator.pop(context);
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(content: Text('Order #${order.id} DELIVERED and closed.')),
                                );
                              }
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: order.status == OrderStatus.ready
                                  ? BakeryTheme.secondary
                                  : BakeryTheme.primary,
                            ),
                            child: Text(
                              order.status == OrderStatus.ready
                                  ? 'Confirm Delivery'
                                  : 'Mark Ready',
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                );
              },
            );
          },
        );
      },
    );
  }

  Widget _buildTimelineRow(BuildContext context, String title, String subtitle, bool isCompleted, bool isActive) {
    final textTheme = Theme.of(context).textTheme;

    return Row(
      children: [
        Container(
          width: 24,
          height: 24,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: isCompleted
                ? BakeryTheme.primary
                : BakeryTheme.surfaceContainerHighest,
            border: isActive ? Border.all(color: BakeryTheme.primary, width: 2) : null,
          ),
          child: Center(
            child: isCompleted
                ? const Icon(Icons.check, size: 14, color: Colors.white)
                : Container(
                    width: 8,
                    height: 8,
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      color: BakeryTheme.outline,
                    ),
                  ),
          ),
        ),
        const SizedBox(width: 16),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: textTheme.labelLarge?.copyWith(
                fontWeight: FontWeight.bold,
                color: isCompleted ? BakeryTheme.onSurface : BakeryTheme.outline,
              ),
            ),
            Text(
              subtitle,
              style: textTheme.labelSmall?.copyWith(fontSize: 10),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildTimelineConnector(bool isCompleted) {
    return Container(
      margin: const EdgeInsets.only(left: 11),
      width: 2,
      height: 20,
      color: isCompleted ? BakeryTheme.primary : BakeryTheme.outlineVariant.withOpacity(0.3),
    );
  }

  // --- Customer CRUD Modal Section ---
  void _showCustomerDirectoryModal(BuildContext context, CustomerProvider customerProvider) {
    final textTheme = Theme.of(context).textTheme;
    String searchQuery = '';

    showModalBottomSheet(
      context: context,
      backgroundColor: BakeryTheme.surfaceContainerLowest,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            final filteredCustomers = customerProvider.customers
                .where((c) =>
                    c.name.toLowerCase().contains(searchQuery.toLowerCase()) ||
                    c.phone.contains(searchQuery))
                .toList();

            return DraggableScrollableSheet(
              expand: false,
              initialChildSize: 0.8,
              minChildSize: 0.6,
              maxChildSize: 0.95,
              builder: (context, scrollController) {
                return Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Column(
                    children: [
                      Center(
                        child: Container(
                          width: 40,
                          height: 4,
                          decoration: BoxDecoration(
                            color: BakeryTheme.outlineVariant,
                            borderRadius: BorderRadius.circular(2),
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      // Modal title & Plus button
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('Customer Directory', style: textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.bold)),
                          ElevatedButton.icon(
                            onPressed: () {
                              _showAddOrEditCustomerDialog(context, customerProvider, null).then((_) {
                                setModalState(() {});
                              });
                            },
                            icon: const Icon(Icons.add, size: 16),
                            label: const Text('New'),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      // Search box
                      TextField(
                        decoration: const InputDecoration(
                          hintText: 'Search by name or phone...',
                          prefixIcon: Icon(Icons.search),
                        ),
                        onChanged: (val) {
                          setModalState(() {
                            searchQuery = val;
                          });
                        },
                      ),
                      const SizedBox(height: 16),
                      // Customers list
                      Expanded(
                        child: filteredCustomers.isEmpty
                            ? Center(child: Text('No customers found', style: textTheme.bodyLarge))
                            : ListView.builder(
                                controller: scrollController,
                                itemCount: filteredCustomers.length,
                                itemBuilder: (context, index) {
                                  final cust = filteredCustomers[index];
                                  return Card(
                                    margin: const EdgeInsets.only(bottom: 12),
                                    child: ListTile(
                                      title: Text(cust.name, style: const TextStyle(fontWeight: FontWeight.bold)),
                                      subtitle: Text(cust.phone),
                                      trailing: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          IconButton(
                                            icon: const Icon(Icons.edit_outlined, color: BakeryTheme.primary),
                                            onPressed: () {
                                              _showAddOrEditCustomerDialog(context, customerProvider, cust).then((_) {
                                                setModalState(() {});
                                              });
                                            },
                                          ),
                                          IconButton(
                                            icon: const Icon(Icons.delete_outline, color: BakeryTheme.error),
                                            onPressed: () {
                                              _showDeleteConfirmationDialog(context, customerProvider, cust).then((_) {
                                                setModalState(() {});
                                              });
                                            },
                                          ),
                                        ],
                                      ),
                                    ),
                                  );
                                },
                              ),
                      ),
                    ],
                  ),
                );
              },
            );
          },
        );
      },
    );
  }

  Future<void> _showAddOrEditCustomerDialog(BuildContext context, CustomerProvider provider, Customer? existing) async {
    final nameController = TextEditingController(text: existing?.name ?? '');
    final phoneController = TextEditingController(text: existing?.phone ?? '');
    final addressController = TextEditingController(text: existing?.address ?? '');

    return showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: BakeryTheme.surfaceContainerLowest,
          title: Text(existing == null ? 'Add Customer' : 'Edit Customer', style: const TextStyle(color: BakeryTheme.primary)),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: nameController,
                  decoration: const InputDecoration(labelText: 'Name', fillColor: Colors.transparent),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: phoneController,
                  keyboardType: TextInputType.phone,
                  decoration: const InputDecoration(labelText: 'Phone', fillColor: Colors.transparent),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: addressController,
                  decoration: const InputDecoration(labelText: 'Address (Optional)', fillColor: Colors.transparent),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel', style: TextStyle(color: BakeryTheme.outline)),
            ),
            ElevatedButton(
              onPressed: () {
                final name = nameController.text.trim();
                final phone = phoneController.text.trim();
                final address = addressController.text.trim();

                if (name.isNotEmpty && phone.isNotEmpty) {
                  if (existing == null) {
                    provider.getOrCreateCustomer(name, phone, address: address);
                  } else {
                    provider.updateCustomer(Customer(
                      id: existing.id,
                      name: name,
                      phone: phone,
                      address: address,
                      createdAt: existing.createdAt,
                      updatedAt: DateTime.now(),
                    ));
                  }
                  Navigator.pop(context);
                }
              },
              child: const Text('Save'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _showDeleteConfirmationDialog(BuildContext context, CustomerProvider provider, Customer customer) async {
    return showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: BakeryTheme.surfaceContainerLowest,
          title: const Text('Delete Customer?', style: TextStyle(color: BakeryTheme.error)),
          content: Text('Are you sure you want to delete ${customer.name}? This cannot be undone.'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel', style: TextStyle(color: BakeryTheme.outline)),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: BakeryTheme.error),
              onPressed: () {
                provider.deleteCustomer(customer.id);
                Navigator.pop(context);
              },
              child: const Text('Delete', style: TextStyle(color: Colors.white)),
            ),
          ],
        );
      },
    );
  }
}
