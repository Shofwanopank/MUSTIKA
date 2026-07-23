import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'data/repositories.dart';
import 'providers/product_provider.dart';
import 'providers/customer_provider.dart';
import 'providers/order_provider.dart';
import 'theme/bakery_theme.dart';
import 'screens/login_screen.dart';
import 'screens/dashboard_screen.dart';
import 'screens/new_order_screen.dart';
import 'screens/products_screen.dart';
import 'screens/reports_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Hive.initFlutter();

  // Open Hive Boxes
  final productsBox = await Hive.openBox('products');
  final customersBox = await Hive.openBox('customers');
  final ordersBox = await Hive.openBox('orders');

  // Repositories
  final productRepo = HiveProductRepository(productsBox);
  final customerRepo = HiveCustomerRepository(customersBox);
  final orderRepo = HiveOrderRepository(ordersBox);

  // Providers
  final productProvider = ProductProvider(productRepo);
  final customerProvider = CustomerProvider(customerRepo);
  final orderProvider = OrderProvider(orderRepo);

  // Prefetch data
  await productProvider.loadProducts();
  await customerProvider.loadCustomers();
  await orderProvider.loadOrders();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider.value(value: productProvider),
        ChangeNotifierProvider.value(value: customerProvider),
        ChangeNotifierProvider.value(value: orderProvider),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Roti Mustika Admin Portal',
      theme: BakeryTheme.lightTheme,
      debugShowCheckedModeBanner: false,
      initialRoute: '/',
      routes: {
        '/': (context) => const LoginScreen(),
        '/dashboard': (context) => const MainShell(),
        '/new_order': (context) => const NewOrderScreen(),
      },
    );
  }
}

class MainShell extends StatefulWidget {
  const MainShell({super.key});

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  int _currentIndex = 0;

  final List<Widget> _screens = [
    const DashboardScreen(),
    const ProductsScreen(),
    const ReportsScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screens[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        selectedItemColor: BakeryTheme.primary,
        unselectedItemColor: BakeryTheme.outline,
        backgroundColor: BakeryTheme.surfaceContainerLowest,
        showUnselectedLabels: true,
        type: BottomNavigationBarType.fixed,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.shopping_bag_outlined),
            activeIcon: Icon(Icons.shopping_bag),
            label: 'Orders',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.bakery_dining_outlined),
            activeIcon: Icon(Icons.bakery_dining),
            label: 'Products',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.trending_up_outlined),
            activeIcon: Icon(Icons.trending_up),
            label: 'Reports',
          ),
        ],
      ),
    );
  }
}
