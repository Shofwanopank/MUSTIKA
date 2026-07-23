import 'dart:math';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../data/models.dart';
import '../providers/product_provider.dart';
import '../theme/bakery_theme.dart';

class ProductsScreen extends StatelessWidget {
  const ProductsScreen({super.key});

  void _showAddProductDialog(BuildContext context, ProductProvider provider) {
    final nameController = TextEditingController();
    final descController = TextEditingController();
    final priceController = TextEditingController();
    final stockController = TextEditingController();
    String category = 'Bread';

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: BakeryTheme.surfaceContainerLowest,
          title: const Text('Add New Product', style: TextStyle(color: BakeryTheme.primary)),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: nameController,
                  decoration: const InputDecoration(labelText: 'Product Name', fillColor: Colors.transparent),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: descController,
                  decoration: const InputDecoration(labelText: 'Description', fillColor: Colors.transparent),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: priceController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(labelText: 'Price (Rp)', fillColor: Colors.transparent),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: stockController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(labelText: 'Stock Units', fillColor: Colors.transparent),
                ),
                const SizedBox(height: 12),
                DropdownButtonFormField<String>(
                  value: category,
                  decoration: const InputDecoration(labelText: 'Category', fillColor: Colors.transparent),
                  items: const [
                    DropdownMenuItem(value: 'Bread', child: Text('Bread')),
                    DropdownMenuItem(value: 'Pastries', child: Text('Pastries')),
                    DropdownMenuItem(value: 'Cakes', child: Text('Cakes')),
                  ],
                  onChanged: (val) {
                    if (val != null) category = val;
                  },
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
                final desc = descController.text.trim();
                final price = double.tryParse(priceController.text.trim()) ?? 0.0;
                final stock = int.tryParse(stockController.text.trim()) ?? 0;

                if (name.isNotEmpty && price > 0) {
                  final newProd = Product(
                    id: 'item-${Random().nextInt(90000) + 10000}',
                    name: name,
                    description: desc,
                    price: price,
                    stock: stock,
                    isAvailable: stock > 0,
                    imageUrl: 'https://lh3.googleusercontent.com/aida-public/AB6AXuChnDtb50qiLpXyaujpUfzXM451Ls0Oj1SdYthglp1yhJS3LDjRtzx8evGL4VIm7PXgGB2ZIj2qirdhZzcvwzn6XroGWf9eJ_0UwNuFaFfcVixADQftcfN8JIbpx5sIGrrZfFcUpBTkNG8KC9czzw_Acyns3pvD1lU1hMKtpgTv2dgFcv63XFVG7odcELADT6OE5VgIjqcUtjeKVU7v3a1CybmeOvUwHwi-r9VnYoogBXKBdB2j0S5Gb87GEUSRcPffYUnv81Te',
                    category: category,
                    createdAt: DateTime.now(),
                    updatedAt: DateTime.now(),
                  );
                  provider.addProduct(newProd);
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

  void _showEditStockDialog(BuildContext context, Product product, ProductProvider provider) {
    final stockController = TextEditingController(text: '${product.stock}');

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: BakeryTheme.surfaceContainerLowest,
          title: Text('Edit Stock: ${product.name}', style: const TextStyle(color: BakeryTheme.primary)),
          content: TextField(
            controller: stockController,
            keyboardType: TextInputType.number,
            autofocus: true,
            decoration: const InputDecoration(labelText: 'Quantity in Stock', fillColor: Colors.transparent),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel', style: TextStyle(color: BakeryTheme.outline)),
            ),
            ElevatedButton(
              onPressed: () {
                final newStock = int.tryParse(stockController.text.trim()) ?? 0;
                provider.updateProductStock(product.id, newStock);
                Navigator.pop(context);
              },
              child: const Text('Update'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final productProvider = Provider.of<ProductProvider>(context);
    final textTheme = Theme.of(context).textTheme;

    final formattedValue = 'Rp ${productProvider.totalStockValue.toStringAsFixed(0).replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]}.')}';

    return Scaffold(
      appBar: AppBar(
        backgroundColor: BakeryTheme.surface,
        elevation: 0,
        scrolledUnderElevation: 0,
        title: Text(
          'Inventory & Catalog',
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
            // Bento Grid stock metrics
            Row(
              children: [
                Expanded(
                  flex: 2,
                  child: Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: BakeryTheme.primaryContainer.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(24),
                      border: Border.all(color: BakeryTheme.primary.withOpacity(0.1)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Icon(Icons.inventory_2_outlined, color: BakeryTheme.primary, size: 24),
                        const SizedBox(height: 16),
                        Text(
                          formattedValue,
                          style: textTheme.headlineMedium?.copyWith(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: BakeryTheme.primary,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Total Stock Value',
                          style: textTheme.labelSmall?.copyWith(color: BakeryTheme.onSurfaceVariant),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    children: [
                      _buildAlertCard(
                        context,
                        'Low Stock',
                        '${productProvider.lowStockCount} Items',
                        BakeryTheme.tertiary,
                        0.1,
                      ),
                      const SizedBox(height: 12),
                      _buildAlertCard(
                        context,
                        'Out of Stock',
                        '${productProvider.outOfStockCount} Items',
                        BakeryTheme.error,
                        0.1,
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Inventory Items',
                  style: textTheme.headlineMedium?.copyWith(color: BakeryTheme.onSurface),
                ),
                ElevatedButton.icon(
                  onPressed: () => _showAddProductDialog(context, productProvider),
                  icon: const Icon(Icons.add, size: 18),
                  label: const Text('New Product'),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            // Products List
            productProvider.products.isEmpty
                ? Center(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 40.0),
                      child: Text('No products found', style: textTheme.bodyLarge),
                    ),
                  )
                : GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      childAspectRatio: 0.72,
                      crossAxisSpacing: 12,
                      mainAxisSpacing: 12,
                    ),
                    itemCount: productProvider.products.length,
                    itemBuilder: (context, index) {
                      final product = productProvider.products[index];
                      return _buildProductCard(context, product, productProvider);
                    },
                  ),
          ],
        ),
      ),
    );
  }

  Widget _buildAlertCard(BuildContext context, String title, String value, Color color, double opacity) {
    final textTheme = Theme.of(context).textTheme;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: color.withOpacity(opacity),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withOpacity(0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            value,
            style: textTheme.labelLarge?.copyWith(
              fontWeight: FontWeight.bold,
              color: color,
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            title,
            style: textTheme.labelSmall?.copyWith(color: BakeryTheme.onSurfaceVariant, fontSize: 10),
          ),
        ],
      ),
    );
  }

  Widget _buildProductCard(BuildContext context, Product product, ProductProvider provider) {
    final textTheme = Theme.of(context).textTheme;

    // Badges/Status
    String badgeText = 'IN STOCK';
    Color badgeBgColor = BakeryTheme.successContainer;
    Color badgeTextColor = BakeryTheme.onSuccessContainer;

    if (product.stock == 0) {
      badgeText = 'OUT OF STOCK';
      badgeBgColor = BakeryTheme.errorContainer;
      badgeTextColor = BakeryTheme.onErrorContainer;
    } else if (product.stock <= 15) {
      badgeText = 'LOW STOCK';
      badgeBgColor = BakeryTheme.tertiaryContainer;
      badgeTextColor = BakeryTheme.onTertiaryContainer;
    }

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image and badge
            Expanded(
              child: Stack(
                children: [
                  Container(
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: BakeryTheme.surfaceContainerLow,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(16),
                      child: Image.network(
                        product.imageUrl,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return const Icon(
                            Icons.bakery_dining_outlined,
                            color: BakeryTheme.primary,
                            size: 40,
                          );
                        },
                      ),
                    ),
                  ),
                  Positioned(
                    top: 8,
                    left: 8,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: badgeBgColor,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        badgeText,
                        style: TextStyle(
                          color: badgeTextColor,
                          fontSize: 9,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),
            // Product info
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    product.name,
                    style: textTheme.labelLarge?.copyWith(
                      color: BakeryTheme.onSurface,
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                GestureDetector(
                  onTap: () => _showEditStockDialog(context, product, provider),
                  child: const Icon(Icons.edit, size: 16, color: BakeryTheme.outline),
                ),
              ],
            ),
            const SizedBox(height: 2),
            Text(
              'Rp ${product.price.toStringAsFixed(0).replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]}.')}',
              style: textTheme.labelSmall?.copyWith(
                color: BakeryTheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 8),
            // Availability and Stock counts
            Container(
              padding: const EdgeInsets.only(top: 8),
              decoration: const BoxDecoration(
                border: Border(top: BorderSide(color: Color(0x1A432818), width: 0.5)),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Quantity',
                        style: textTheme.labelSmall?.copyWith(fontSize: 9),
                      ),
                      Text(
                        '${product.stock} Units',
                        style: textTheme.labelLarge?.copyWith(fontSize: 11),
                      ),
                    ],
                  ),
                  SizedBox(
                    height: 24,
                    child: Switch(
                      value: product.isAvailable,
                      activeColor: BakeryTheme.primary,
                      onChanged: (val) {
                        provider.toggleProductAvailability(product.id, val);
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              'Product ${product.name} is now ${val ? "AVAILABLE" : "UNAVAILABLE"}',
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
