import 'dart:math';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/order_provider.dart';
import '../theme/bakery_theme.dart';

class ReportsScreen extends StatefulWidget {
  const ReportsScreen({super.key});

  @override
  State<ReportsScreen> createState() => _ReportsScreenState();
}

class _ReportsScreenState extends State<ReportsScreen> {
  String _timeRange = 'Today'; // Today, Weekly, Monthly

  @override
  Widget build(BuildContext context) {
    final orderProvider = Provider.of<OrderProvider>(context);
    final textTheme = Theme.of(context).textTheme;

    final double totalRev = orderProvider.totalRevenue;
    final int totalOrd = orderProvider.orders.length;
    final double avgTicket = orderProvider.averageTicket;

    final double totalProfit = orderProvider.totalProfit;
    final double totalCost = orderProvider.totalCost;
    final double margin = orderProvider.profitMargin;

    final formattedRev = totalRev >= 1000000
        ? 'Rp ${(totalRev / 1000000).toStringAsFixed(2)}M'
        : 'Rp ${(totalRev / 1000).toStringAsFixed(1)}k';

    final formattedAvg = avgTicket >= 1000000
        ? 'Rp ${(avgTicket / 1000000).toStringAsFixed(2)}M'
        : 'Rp ${(avgTicket / 1000).toStringAsFixed(1)}k';

    final formattedProfit = totalProfit >= 1000000
        ? 'Rp ${(totalProfit / 1000000).toStringAsFixed(2)}M'
        : 'Rp ${(totalProfit / 1000).toStringAsFixed(1)}k';

    final formattedCost = totalCost >= 1000000
        ? 'Rp ${(totalCost / 1000000).toStringAsFixed(2)}M'
        : 'Rp ${(totalCost / 1000).toStringAsFixed(1)}k';

    return Scaffold(
      appBar: AppBar(
        backgroundColor: BakeryTheme.surface,
        elevation: 0,
        scrolledUnderElevation: 0,
        title: Text(
          'Sales Performance',
          style: textTheme.headlineMedium?.copyWith(
            color: BakeryTheme.primary,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Time range selector
            Center(
              child: Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: BakeryTheme.surfaceContainer,
                  borderRadius: BorderRadius.circular(30),
                  border: Border.all(color: BakeryTheme.outlineVariant.withOpacity(0.3)),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: ['Today', 'Weekly', 'Monthly'].map((range) {
                    final isSelected = _timeRange == range;
                    return GestureDetector(
                      onTap: () {
                        setState(() {
                          _timeRange = range;
                        });
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
                        decoration: BoxDecoration(
                          color: isSelected ? BakeryTheme.primary : Colors.transparent,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          range,
                          style: TextStyle(
                            color: isSelected ? BakeryTheme.onPrimary : BakeryTheme.onSurfaceVariant,
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ),
            ),
            const SizedBox(height: 24),
            // Bento Grid metrics
            LayoutBuilder(
              builder: (context, constraints) {
                if (constraints.maxWidth > 600) {
                  return Row(
                    children: [
                      Expanded(
                        flex: 2,
                        child: _buildBentoMetricCard(
                          context,
                          'Total Revenue',
                          formattedRev,
                          '+14.2%',
                          Icons.payments_outlined,
                          Colors.green,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _buildBentoProgressCard(
                          context,
                          'Total Orders',
                          '$totalOrd',
                          '75% of daily target reached',
                          0.75,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _buildBentoMetricCard(
                          context,
                          'Avg. Ticket',
                          formattedAvg,
                          '-2.1%',
                          Icons.receipt_long_outlined,
                          Colors.red,
                        ),
                      ),
                    ],
                  );
                } else {
                  return Column(
                    children: [
                      _buildBentoMetricCard(
                        context,
                        'Total Revenue',
                        formattedRev,
                        '+14.2%',
                        Icons.payments_outlined,
                        Colors.green,
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(
                            child: _buildBentoProgressCard(
                              context,
                              'Total Orders',
                              '$totalOrd',
                              '75% of target',
                              0.75,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: _buildBentoMetricCard(
                              context,
                              'Avg. Ticket',
                              formattedAvg,
                              '-2.1%',
                              Icons.receipt_long_outlined,
                              Colors.red,
                            ),
                          ),
                        ],
                      ),
                    ],
                  );
                }
              },
            ),
            const SizedBox(height: 24),

            // Profit & Cost Bento Card
            Card(
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Profit & Cost Analytics',
                      style: textTheme.headlineMedium?.copyWith(
                        fontSize: 18,
                        color: BakeryTheme.onSurface,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        // Circle progress indicator for profit margin
                        Stack(
                          alignment: Alignment.center,
                          children: [
                            SizedBox(
                              width: 80,
                              height: 80,
                              child: CircularProgressIndicator(
                                value: margin / 100,
                                strokeWidth: 10,
                                backgroundColor: BakeryTheme.surfaceContainerHighest,
                                color: BakeryTheme.primary,
                              ),
                            ),
                            Text(
                              '${margin.toStringAsFixed(1)}%',
                              style: textTheme.labelLarge?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: BakeryTheme.primary,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(width: 24),
                        // Cost and Profit Details
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _buildProfitInfoRow('Net Profit', formattedProfit, Colors.green),
                              const SizedBox(height: 12),
                              _buildProfitInfoRow('Expenses / COGS', formattedCost, BakeryTheme.secondary),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Hourly Sales Activity
            Card(
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Hourly Sales Activity',
                          style: textTheme.headlineMedium?.copyWith(
                            fontSize: 18,
                            color: BakeryTheme.onSurface,
                          ),
                        ),
                        const Icon(Icons.more_vert, color: BakeryTheme.outline),
                      ],
                    ),
                    const SizedBox(height: 24),
                    // Bar Chart Row
                    _buildBarChart(context, orderProvider),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
            // Top Selling Products
            Card(
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Top Selling Products',
                      style: textTheme.headlineMedium?.copyWith(
                        fontSize: 18,
                        color: BakeryTheme.onSurface,
                      ),
                    ),
                    const SizedBox(height: 16),
                    orderProvider.topSellingProducts.isEmpty
                        ? Center(
                            child: Padding(
                              padding: const EdgeInsets.symmetric(vertical: 24.0),
                              child: Text(
                                'No sales records yet',
                                style: textTheme.bodyMedium?.copyWith(color: BakeryTheme.outline),
                              ),
                            ),
                          )
                        : ListView.separated(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            itemCount: min(5, orderProvider.topSellingProducts.length),
                            separatorBuilder: (context, idx) => const Divider(height: 16),
                            itemBuilder: (context, idx) {
                              final item = orderProvider.topSellingProducts[idx];
                              final formattedRev = 'Rp ${item.revenue.toStringAsFixed(0).replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]}.')}';
                              return _buildTopProductItem(context, item.name, item.unitsSold, formattedRev);
                            },
                          ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProfitInfoRow(String label, String value, Color color) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            Container(
              width: 8,
              height: 8,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: color,
              ),
            ),
            const SizedBox(width: 8),
            Text(
              label,
              style: const TextStyle(
                fontSize: 12,
                color: BakeryTheme.onSurfaceVariant,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        Text(
          value,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: BakeryTheme.onSurface,
          ),
        ),
      ],
    );
  }

  Widget _buildBentoMetricCard(
    BuildContext context,
    String label,
    String value,
    String badge,
    IconData icon,
    Color badgeColor,
  ) {
    final textTheme = Theme.of(context).textTheme;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Icon(icon, color: BakeryTheme.primary, size: 20),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: badgeColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    badge,
                    style: TextStyle(
                      color: badgeColor,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Text(
              value,
              style: textTheme.headlineMedium?.copyWith(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: BakeryTheme.onSurface,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: textTheme.labelSmall?.copyWith(
                color: BakeryTheme.outline,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBentoProgressCard(
    BuildContext context,
    String label,
    String value,
    String subtext,
    double progress,
  ) {
    final textTheme = Theme.of(context).textTheme;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              value,
              style: textTheme.headlineMedium?.copyWith(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: BakeryTheme.onSurface,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: textTheme.labelSmall?.copyWith(
                color: BakeryTheme.outline,
              ),
            ),
            const SizedBox(height: 16),
            ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(
                value: progress,
                minHeight: 6,
                backgroundColor: BakeryTheme.surfaceContainerHighest,
                valueColor: const AlwaysStoppedAnimation<Color>(BakeryTheme.primary),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              subtext,
              style: textTheme.labelSmall?.copyWith(
                color: BakeryTheme.onSurfaceVariant,
                fontSize: 10,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBarChart(BuildContext context, OrderProvider provider) {
    final Map<String, double> hourlySales = provider.hourlySalesActivity;

    return SizedBox(
      height: 160,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: hourlySales.entries.map((entry) {
          final heightMultiplier = entry.value;
          return Column(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Container(
                width: 32,
                height: max(4.0, 120 * heightMultiplier), // Ensure at least a line is visible if > 0
                decoration: const BoxDecoration(
                  color: BakeryTheme.primary,
                  borderRadius: BorderRadius.vertical(top: Radius.circular(8)),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                entry.key,
                style: const TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                  color: BakeryTheme.onSurfaceVariant,
                ),
              ),
            ],
          );
        }).toList(),
      ),
    );
  }

  Widget _buildTopProductItem(BuildContext context, String name, int units, String rev) {
    final textTheme = Theme.of(context).textTheme;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                name,
                style: textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.bold),
              ),
              Text(
                '$units units sold',
                style: textTheme.labelSmall?.copyWith(fontSize: 12),
              ),
            ],
          ),
          Text(
            rev,
            style: textTheme.bodyMedium?.copyWith(
              color: BakeryTheme.primary,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}
