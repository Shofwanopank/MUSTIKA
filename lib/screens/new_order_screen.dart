import 'dart:math';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../data/models.dart';
import '../providers/product_provider.dart';
import '../providers/customer_provider.dart';
import '../providers/order_provider.dart';
import '../theme/bakery_theme.dart';

class NewOrderScreen extends StatefulWidget {
  const NewOrderScreen({super.key});

  @override
  State<NewOrderScreen> createState() => _NewOrderScreenState();
}

class _NewOrderScreenState extends State<NewOrderScreen> {
  int _currentStep = 0; // 0 = Products, 1 = Customer, 2 = Review

  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _notesController = TextEditingController();
  String _logisticsType = 'Pickup'; // Pickup or Delivery

  // Scheduling fields
  DateTime _selectedDate = DateTime.now().add(const Duration(days: 1)); // Default to tomorrow
  TimeOfDay _selectedTime = const TimeOfDay(hour: 10, minute: 0); // Default to 10:00 AM
  Duration _productionEstimate = const Duration(hours: 1); // Default to 1 hour

  String _selectedCategory = 'All Items';
  final Map<String, int> _quantities = {}; // Product ID -> Qty

  List<Customer> _matchingCustomers = [];

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  double _calculateSubtotal(List<Product> products) {
    double total = 0;
    _quantities.forEach((prodId, qty) {
      final product = products.firstWhere((p) => p.id == prodId, orElse: () => Product(
        id: '', name: '', description: '', price: 0, stock: 0, isAvailable: false, imageUrl: '', category: '', createdAt: DateTime.now(), updatedAt: DateTime.now()
      ));
      if (product.id.isNotEmpty) {
        total += product.price * qty;
      }
    });
    return total;
  }

  void _submitOrder(
    OrderProvider orderProvider,
    ProductProvider productProvider,
    CustomerProvider customerProvider,
  ) async {
    final selectedItems = <OrderItem>[];
    String firstProductImageUrl = '';

    _quantities.forEach((prodId, qty) {
      if (qty > 0) {
        final product = productProvider.products.firstWhere((p) => p.id == prodId);
        selectedItems.add(OrderItem(
          productName: product.name,
          quantity: qty,
          price: product.price,
        ));
        if (firstProductImageUrl.isEmpty) {
          firstProductImageUrl = product.imageUrl;
        }
      }
    });

    // Compute pickup DateTime
    final pickupDateTime = DateTime(
      _selectedDate.year,
      _selectedDate.month,
      _selectedDate.day,
      _selectedTime.hour,
      _selectedTime.minute,
    );

    // Compute priority dynamically
    final now = DateTime.now();
    final difference = pickupDateTime.difference(now);
    String priority = 'Low';
    if (difference.inHours <= 24) {
      priority = 'High';
    } else if (difference.inHours <= 48) {
      priority = 'Medium';
    }

    final totalRevenue = _calculateSubtotal(productProvider.products);
    final costPrice = totalRevenue * 0.45; // 45% default cost

    // Get or Create Customer
    final customer = await customerProvider.getOrCreateCustomer(
      _nameController.text.trim(),
      _phoneController.text.trim(),
    );

    final newOrder = Order(
      id: 'ORD-${Random().nextInt(9000) + 1000}',
      customer: customer,
      items: selectedItems,
      totalPrice: totalRevenue,
      costPrice: costPrice,
      status: OrderStatus.processing,
      notes: _notesController.text.trim(),
      pickupDateTime: pickupDateTime,
      productionEstimate: _productionEstimate,
      priority: priority,
      createdAt: now,
      updatedAt: now,
    );

    await orderProvider.addOrder(newOrder);

    // Deduct stock
    for (var item in selectedItems) {
      final prod = productProvider.products.firstWhere((p) => p.name == item.productName, orElse: () => Product(
        id: '', name: '', description: '', price: 0, stock: 0, isAvailable: false, imageUrl: '', category: '', createdAt: DateTime.now(), updatedAt: DateTime.now()
      ));
      if (prod.id.isNotEmpty) {
        final newStock = max(0, prod.stock - item.quantity);
        await productProvider.updateProductStock(prod.id, newStock);
      }
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Successfully scheduled order #${newOrder.id}!'),
        backgroundColor: BakeryTheme.success,
      ),
    );

    Navigator.pushNamedAndRemoveUntil(context, '/dashboard', (route) => false);
  }

  @override
  Widget build(BuildContext context) {
    final orderProvider = Provider.of<OrderProvider>(context);
    final productProvider = Provider.of<ProductProvider>(context);
    final customerProvider = Provider.of<CustomerProvider>(context);
    final textTheme = Theme.of(context).textTheme;

    // Initialize quantities map for products
    for (var product in productProvider.products) {
      if (product.isAvailable && !_quantities.containsKey(product.id)) {
        _quantities[product.id] = 0;
      }
    }

    final hasSelectedItems = _quantities.values.any((qty) => qty > 0);
    final totalCost = _calculateSubtotal(productProvider.products);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: BakeryTheme.surface,
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: BakeryTheme.primary),
          onPressed: () {
            if (_currentStep > 0) {
              setState(() {
                _currentStep--;
              });
            } else {
              Navigator.pop(context);
            }
          },
        ),
        title: Text(
          _currentStep == 0
              ? 'Choose Items'
              : _currentStep == 1
                  ? 'Scheduling Details'
                  : 'Review Order',
          style: textTheme.headlineMedium?.copyWith(
            color: BakeryTheme.primary,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          Row(
            children: [
              const Icon(Icons.bakery_dining_outlined, color: BakeryTheme.primary),
              const SizedBox(width: 4),
              Text(
                'Roti Mustika',
                style: textTheme.labelLarge?.copyWith(
                  color: BakeryTheme.primary,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(width: 16),
            ],
          ),
        ],
      ),
      body: Column(
        children: [
          // Step progress indicator
          Container(
            padding: const EdgeInsets.symmetric(vertical: 16),
            color: BakeryTheme.surface,
            child: Row(
              children: [
                _buildStepNode(1, 'Products', _currentStep >= 0),
                _buildStepLine(_currentStep >= 1),
                _buildStepNode(2, 'Scheduling', _currentStep >= 1),
                _buildStepLine(_currentStep >= 2),
                _buildStepNode(3, 'Review', _currentStep >= 2),
              ],
            ),
          ),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: _buildCurrentStepView(productProvider, customerProvider),
            ),
          ),
          // Floating summary bottom bar
          if (totalCost > 0 || _currentStep == 2)
            Container(
              padding: const EdgeInsets.all(20),
              decoration: const BoxDecoration(
                color: BakeryTheme.surfaceContainerLowest,
                borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
                boxShadow: [
                  BoxShadow(
                    color: Color(0x14432818),
                    blurRadius: 20,
                    offset: Offset(0, -4),
                  ),
                ],
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'Total Price',
                        style: textTheme.labelSmall?.copyWith(
                          color: BakeryTheme.onSurfaceVariant,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        'Rp ${totalCost.toStringAsFixed(0).replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]}.')}',
                        style: textTheme.headlineMedium?.copyWith(
                          color: BakeryTheme.primary,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  ElevatedButton(
                    onPressed: () {
                      if (_currentStep == 0) {
                        if (hasSelectedItems) {
                          setState(() {
                            _currentStep = 1;
                          });
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Please select at least 1 item.')),
                          );
                        }
                      } else if (_currentStep == 1) {
                        if (_formKey.currentState!.validate()) {
                          setState(() {
                            _currentStep = 2;
                          });
                        }
                      } else if (_currentStep == 2) {
                        _submitOrder(orderProvider, productProvider, customerProvider);
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                    ),
                    child: Text(
                      _currentStep == 2
                          ? 'Confirm & Schedule'
                          : 'Next',
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildStepNode(int stepNum, String title, bool isActive) {
    return Expanded(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: isActive ? BakeryTheme.primary : BakeryTheme.surfaceContainerHighest,
              boxShadow: isActive
                  ? const [BoxShadow(color: Color(0x337D562D), blurRadius: 4, offset: Offset(0, 2))]
                  : null,
            ),
            child: Center(
              child: Text(
                '$stepNum',
                style: TextStyle(
                  color: isActive ? BakeryTheme.onPrimary : BakeryTheme.onSurfaceVariant,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            title,
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.bold,
              color: isActive ? BakeryTheme.primary : BakeryTheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStepLine(bool isActive) {
    return Container(
      width: 40,
      height: 2,
      color: isActive ? BakeryTheme.primary : BakeryTheme.outlineVariant.withOpacity(0.3),
    );
  }

  Widget _buildCurrentStepView(ProductProvider productProvider, CustomerProvider customerProvider) {
    if (_currentStep == 0) {
      return _buildProductSelection(productProvider);
    } else if (_currentStep == 1) {
      return _buildCustomerForm(customerProvider);
    } else {
      return _buildOrderReview(productProvider);
    }
  }

  Widget _buildProductSelection(ProductProvider productProvider) {
    final textTheme = Theme.of(context).textTheme;

    final categories = ['All Items', 'Bread', 'Pastries', 'Cakes'];
    final availableProducts = productProvider.products.where((p) => p.isAvailable).toList();
    final filteredProducts = _selectedCategory == 'All Items'
        ? availableProducts
        : availableProducts.where((p) => p.category == _selectedCategory).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Category filters
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: categories.map((cat) {
              final isSelected = _selectedCategory == cat;
              return Padding(
                padding: const EdgeInsets.only(right: 8.0),
                child: ChoiceChip(
                  label: Text(cat),
                  selected: isSelected,
                  onSelected: (val) {
                    if (val) {
                      setState(() {
                        _selectedCategory = cat;
                      });
                    }
                  },
                  selectedColor: BakeryTheme.primary,
                  backgroundColor: BakeryTheme.surfaceContainerHigh,
                  labelStyle: TextStyle(
                    color: isSelected ? BakeryTheme.onPrimary : BakeryTheme.onSurfaceVariant,
                    fontWeight: FontWeight.bold,
                  ),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                  side: BorderSide.none,
                  showCheckmark: false,
                ),
              );
            }).toList(),
          ),
        ),
        const SizedBox(height: 24),
        // Products List
        filteredProducts.isEmpty
            ? Center(
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 40),
                  child: Text('No products available', style: textTheme.bodyLarge),
                ),
              )
            : ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: filteredProducts.length,
                itemBuilder: (context, index) {
                  final product = filteredProducts[index];
                  final qty = _quantities[product.id] ?? 0;

                  return Card(
                    margin: const EdgeInsets.only(bottom: 16),
                    child: Padding(
                      padding: const EdgeInsets.all(12.0),
                      child: Row(
                        children: [
                          // Product image
                          Container(
                            width: 80,
                            height: 80,
                            decoration: BoxDecoration(
                              color: BakeryTheme.surfaceContainerLow,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(12),
                              child: Image.network(
                                product.imageUrl,
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) {
                                  return const Icon(
                                    Icons.bakery_dining_outlined,
                                    color: BakeryTheme.primary,
                                    size: 32,
                                  );
                                },
                              ),
                            ),
                          ),
                          const SizedBox(width: 16),
                          // Product details
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  product.name,
                                  style: textTheme.headlineMedium?.copyWith(
                                    fontSize: 18,
                                    color: BakeryTheme.secondary,
                                  ),
                                ),
                                Text(
                                  product.description,
                                  style: textTheme.labelSmall?.copyWith(
                                    color: BakeryTheme.outline,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  'Rp ${product.price.toStringAsFixed(0).replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]}.')}',
                                  style: textTheme.labelLarge?.copyWith(
                                    color: BakeryTheme.primary,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          // Qty selectors
                          Row(
                            children: [
                              IconButton(
                                icon: const Icon(Icons.remove_circle_outline, color: BakeryTheme.primary),
                                onPressed: qty > 0
                                    ? () {
                                        setState(() {
                                          _quantities[product.id] = qty - 1;
                                        });
                                      }
                                    : null,
                              ),
                              Text(
                                '$qty',
                                style: textTheme.headlineMedium?.copyWith(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              IconButton(
                                icon: const Icon(Icons.add_circle_outline, color: BakeryTheme.primary),
                                onPressed: () {
                                  setState(() {
                                    _quantities[product.id] = qty + 1;
                                  });
                                },
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
      ],
    );
  }

  Widget _buildCustomerForm(CustomerProvider customerProvider) {
    final textTheme = Theme.of(context).textTheme;

    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Customer & Scheduling',
            style: textTheme.headlineMedium?.copyWith(
              color: BakeryTheme.secondary,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Fill in scheduling and customer details.',
            style: textTheme.bodyMedium?.copyWith(
              color: BakeryTheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 24),
          // Name Field with inline autocomplete
          Text(
            'Full Name',
            style: textTheme.labelLarge?.copyWith(color: BakeryTheme.secondary),
          ),
          const SizedBox(height: 8),
          TextFormField(
            controller: _nameController,
            decoration: const InputDecoration(
              hintText: 'e.g. Budi Santoso',
              prefixIcon: Icon(Icons.person_outline),
            ),
            onChanged: (val) {
              setState(() {
                if (val.trim().isEmpty) {
                  _matchingCustomers = [];
                } else {
                  _matchingCustomers = customerProvider.customers
                      .where((c) => c.name.toLowerCase().contains(val.toLowerCase()))
                      .toList();
                }
              });
            },
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return 'Customer name is required';
              }
              return null;
            },
          ),
          // Autocomplete List
          if (_matchingCustomers.isNotEmpty)
            Container(
              margin: const EdgeInsets.only(top: 4),
              decoration: BoxDecoration(
                color: BakeryTheme.surfaceContainerLow,
                borderRadius: BorderRadius.circular(12),
              ),
              child: ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: _matchingCustomers.length,
                itemBuilder: (context, idx) {
                  final cust = _matchingCustomers[idx];
                  return ListTile(
                    title: Text(cust.name),
                    subtitle: Text(cust.phone),
                    onTap: () {
                      setState(() {
                        _nameController.text = cust.name;
                        _phoneController.text = cust.phone;
                        _matchingCustomers = [];
                      });
                    },
                  );
                },
              ),
            ),
          const SizedBox(height: 20),
          // Phone Field
          Text(
            'Phone Number',
            style: textTheme.labelLarge?.copyWith(color: BakeryTheme.secondary),
          ),
          const SizedBox(height: 8),
          TextFormField(
            controller: _phoneController,
            keyboardType: TextInputType.phone,
            decoration: const InputDecoration(
              hintText: 'e.g. +62 812 3456 7890',
              prefixIcon: Icon(Icons.phone_outlined),
            ),
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return 'Phone number is required';
              }
              return null;
            },
          ),
          const SizedBox(height: 24),
          // Pickup Date & Time Selector
          Text(
            'Pickup Date & Time',
            style: textTheme.labelLarge?.copyWith(color: BakeryTheme.secondary),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () async {
                    final pickedDate = await showDatePicker(
                      context: context,
                      initialDate: _selectedDate,
                      firstDate: DateTime.now(),
                      lastDate: DateTime.now().add(const Duration(days: 365)),
                    );
                    if (pickedDate != null) {
                      setState(() {
                        _selectedDate = pickedDate;
                      });
                    }
                  },
                  icon: const Icon(Icons.calendar_month, size: 18),
                  label: Text(
                    '${_selectedDate.day}/${_selectedDate.month}/${_selectedDate.year}',
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () async {
                    final pickedTime = await showTimePicker(
                      context: context,
                      initialTime: _selectedTime,
                    );
                    if (pickedTime != null) {
                      setState(() {
                        _selectedTime = pickedTime;
                      });
                    }
                  },
                  icon: const Icon(Icons.access_time, size: 18),
                  label: Text(
                    '${_selectedTime.hour.toString().padLeft(2, '0')}:${_selectedTime.minute.toString().padLeft(2, '0')}',
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          // Production Estimate Dropdown
          Text(
            'Production Estimate Time',
            style: textTheme.labelLarge?.copyWith(color: BakeryTheme.secondary),
          ),
          const SizedBox(height: 8),
          DropdownButtonFormField<Duration>(
            value: _productionEstimate,
            decoration: InputDecoration(
              fillColor: BakeryTheme.surfaceContainerLowest,
              prefixIcon: const Icon(Icons.timer_outlined),
            ),
            items: const [
              DropdownMenuItem(value: Duration(minutes: 30), child: Text('30 Minutes')),
              DropdownMenuItem(value: Duration(hours: 1), child: Text('1 Hour')),
              DropdownMenuItem(value: Duration(hours: 2), child: Text('2 Hours')),
              DropdownMenuItem(value: Duration(hours: 3), child: Text('3 Hours')),
              DropdownMenuItem(value: Duration(hours: 4), child: Text('4 Hours')),
            ],
            onChanged: (val) {
              if (val != null) {
                setState(() {
                  _productionEstimate = val;
                });
              }
            },
          ),
          const SizedBox(height: 24),
          // Notes Field
          Text(
            'Special Instructions / Notes',
            style: textTheme.labelLarge?.copyWith(color: BakeryTheme.secondary),
          ),
          const SizedBox(height: 8),
          TextFormField(
            controller: _notesController,
            maxLines: 2,
            decoration: const InputDecoration(
              hintText: 'e.g. Sliced sourdough, birthday writing "Happy Birthday", etc.',
              prefixIcon: Icon(Icons.notes),
            ),
          ),
          const SizedBox(height: 24),
          // Logistics Selector
          Text(
            'Logistics Option',
            style: textTheme.labelLarge?.copyWith(color: BakeryTheme.secondary),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _buildLogisticsCard(
                  'Pickup',
                  Icons.storefront_outlined,
                  _logisticsType == 'Pickup',
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildLogisticsCard(
                  'Delivery',
                  Icons.local_shipping_outlined,
                  _logisticsType == 'Delivery',
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildLogisticsCard(String type, IconData icon, bool isSelected) {
    return GestureDetector(
      onTap: () {
        setState(() {
          _logisticsType = type;
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: isSelected ? BakeryTheme.primaryContainer.withOpacity(0.15) : BakeryTheme.surfaceContainerLowest,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? BakeryTheme.primary : BakeryTheme.outlineVariant.withOpacity(0.3),
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Column(
          children: [
            Icon(
              icon,
              size: 32,
              color: isSelected ? BakeryTheme.primary : BakeryTheme.outline,
            ),
            const SizedBox(height: 8),
            Text(
              type,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: isSelected ? BakeryTheme.primary : BakeryTheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOrderReview(ProductProvider productProvider) {
    final textTheme = Theme.of(context).textTheme;

    final selectedItems = <Map<String, dynamic>>[];
    _quantities.forEach((prodId, qty) {
      if (qty > 0) {
        final product = productProvider.products.firstWhere((p) => p.id == prodId);
        selectedItems.add({
          'name': product.name,
          'qty': qty,
          'price': product.price,
        });
      }
    });

    final hrs = _productionEstimate.inHours;
    final mins = _productionEstimate.inMinutes % 60;
    final formattedEstimate = hrs > 0 ? '$hrs hr ${mins > 0 ? "$mins min" : ""}' : '$mins mins';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Confirm Details',
          style: textTheme.headlineMedium?.copyWith(
            color: BakeryTheme.secondary,
          ),
        ),
        const SizedBox(height: 16),
        // Customer Review Box
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Customer Info & Schedule',
                      style: textTheme.labelLarge?.copyWith(color: BakeryTheme.primary),
                    ),
                    Icon(
                      _logisticsType == 'Pickup' ? Icons.storefront : Icons.local_shipping,
                      color: BakeryTheme.secondary,
                    ),
                  ],
                ),
                const Divider(),
                const SizedBox(height: 8),
                Text(
                  _nameController.text.trim(),
                  style: textTheme.headlineMedium?.copyWith(fontSize: 18),
                ),
                const SizedBox(height: 6),
                Text(
                  'Phone: ${_phoneController.text.trim()}',
                  style: textTheme.bodyMedium?.copyWith(color: BakeryTheme.onSurfaceVariant),
                ),
                const SizedBox(height: 6),
                Row(
                  children: [
                    const Icon(Icons.calendar_month, size: 16, color: BakeryTheme.primary),
                    const SizedBox(width: 6),
                    Text(
                      'Pickup: ${_selectedDate.day}/${_selectedDate.month}/${_selectedDate.year} at '
                      '${_selectedTime.hour.toString().padLeft(2, '0')}:${_selectedTime.minute.toString().padLeft(2, '0')}',
                      style: textTheme.bodyMedium?.copyWith(color: BakeryTheme.onSurfaceVariant, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Row(
                  children: [
                    const Icon(Icons.timer_outlined, size: 16, color: BakeryTheme.primary),
                    const SizedBox(width: 6),
                    Text(
                      'Production Estimate: $formattedEstimate',
                      style: textTheme.bodyMedium?.copyWith(color: BakeryTheme.onSurfaceVariant),
                    ),
                  ],
                ),
                if (_notesController.text.trim().isNotEmpty) ...[
                  const SizedBox(height: 12),
                  Text(
                    'Notes / Instructions:',
                    style: textTheme.labelSmall?.copyWith(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 4),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: BakeryTheme.surfaceContainerLow,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      _notesController.text.trim(),
                      style: textTheme.bodyMedium?.copyWith(fontStyle: FontStyle.italic),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
        const SizedBox(height: 24),
        // Items Review Box
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Selected Items',
                  style: textTheme.labelLarge?.copyWith(color: BakeryTheme.primary),
                ),
                const Divider(),
                const SizedBox(height: 8),
                ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: selectedItems.length,
                  itemBuilder: (context, index) {
                    final item = selectedItems[index];
                    final itemTotal = item['qty'] * item['price'];

                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            '${item['qty']}x ${item['name']}',
                            style: textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.bold),
                          ),
                          Text(
                            'Rp ${itemTotal.toStringAsFixed(0).replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]}.')}',
                            style: textTheme.bodyMedium?.copyWith(color: BakeryTheme.onSurfaceVariant),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
