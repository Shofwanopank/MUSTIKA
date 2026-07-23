import 'package:hive/hive.dart';
import 'models.dart';

abstract class ProductRepository {
  Future<List<Product>> getProducts();
  Future<void> saveProduct(Product product);
  Future<void> deleteProduct(String id);
}

abstract class CustomerRepository {
  Future<List<Customer>> getCustomers();
  Future<void> saveCustomer(Customer customer);
  Future<void> deleteCustomer(String id);
}

abstract class OrderRepository {
  Future<List<Order>> getOrders();
  Future<void> saveOrder(Order order);
  Future<void> deleteOrder(String id);
}

class HiveProductRepository implements ProductRepository {
  final Box _box;

  HiveProductRepository(this._box);

  @override
  Future<List<Product>> getProducts() async {
    if (_box.isEmpty) {
      // Seed default products
      final initialProducts = [
        Product(
          id: 'item-1',
          name: 'Classic Sourdough',
          description: 'Signature crusty loaf',
          price: 45000,
          stock: 42,
          isAvailable: true,
          category: 'Bread',
          imageUrl: 'https://lh3.googleusercontent.com/aida-public/AB6AXuD70RQygaBpD4USrymO_8oR8r_pACMw4OziEmEAOd_W53wlHkHBhR9UYJScWaxpxr79Ch_bc10Yvf-MkyirCBPgG8e9qfLt1X6l2JakIBT39qo-088kM-xVr_002sawHZa2EjQ5RB4cr38HZc_ZD08Ua52cNvUAK1uwTY85G0Xc3pjfheWaYzCwEfjLRx-rj8P8RTIRKvSXBBOnvXosIVec7roNipY1vEouneX8hmqJZrtbm_utIZsByZN29HlhNx-xLitfLDhr',
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        ),
        Product(
          id: 'item-2',
          name: 'Butter Croissant',
          description: 'French-style flaky pastry',
          price: 22000,
          stock: 14,
          isAvailable: true,
          category: 'Pastries',
          imageUrl: 'https://lh3.googleusercontent.com/aida-public/AB6AXuCs9OqNSiGP-R48eORPHttcRVeNEADW8XrLqdT4UrkPupjigMNzEt2xJyUa-IEsce3TLh5lCjTpoK3fXBoqji-9ov1vO-q-4KrrfkIcJGtULSGLx1ztAfvXtVDGQAXcRcR9gyc9odIFG-8UJAVrfSPUSa4GHUj4AYTSXfS2CWLTWOUZH-LuVWIOKLfbPRtRD8rhiwxMdalkfc3uf4GFUhEwUr7OEjaQArmtn34XKE3Rnwv1ikyaS8nWDSeRf6AaUI1D4QECNOvk',
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        ),
        Product(
          id: 'item-3',
          name: 'Dark Truffle Cake',
          description: '60% Cocoa Belgian dark chocolate',
          price: 320000,
          stock: 5,
          isAvailable: true,
          category: 'Cakes',
          imageUrl: 'https://lh3.googleusercontent.com/aida-public/AB6AXuCH_jyLlYkWJUgaN8b0MoeGh9yQYt0PsEkCMaV7p_yTXgMw7XbIspnDpkp2bV9VfQOGwB30-rnc0nEImgtSrDwlJW9uahO3uSSMrNMQj-OEBPh90YeHPjQN97KbWXJwM76fAjUlFETILucYm85JIjfnOTjJOP-u1pEknDwNqYcjjNMIiFtY9pu9nQA6Hb6Vs4sqb6XwOQDcwdNJUAhjZSlVL2HzgiGq08UebX_ZzXUOwDfgfHbND4mPyyHA4fgY4E9OR0OnAr14',
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        ),
        Product(
          id: 'item-4',
          name: 'Roti Sisir',
          description: 'Sweet soft pull-apart bread',
          price: 15000,
          stock: 25,
          isAvailable: true,
          category: 'Bread',
          imageUrl: 'https://lh3.googleusercontent.com/aida-public/AB6AXuD0ztW3PMLKNqacQqiDaUCxQ6tJF1FoRAdO_nBxOAegKtYr3PudvFERVosZd3QSiZtihq3k3gZuXEM1-Mc1-pjOzww8oFM9cDob9KZwu3cIr-GY6yNmjMTjQUmH5u1kXbV5luxrLbVAlT5cXwU5reqW86I2sLzAbf2ENjypno1hhOg3HVcxJVxkUomlz7SxIUSxFMmafQUYRaR2PM1-99Fn1GsTX1PC15lS1za8KPcZlDWkLB9xs4tlNp_lpv16_A6I3eOycidA',
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        ),
        Product(
          id: 'item-5',
          name: 'Cheese Bun',
          description: 'Soft bun with savory cheese filling',
          price: 18000,
          stock: 0,
          isAvailable: false,
          category: 'Bread',
          imageUrl: 'https://lh3.googleusercontent.com/aida-public/AB6AXuChnDtb50qiLpXyaujpUfzXM451Ls0Oj1SdYthglp1yhJS3LDjRtzx8evGL4VIm7PXgGB2ZIj2qirdhZzcvwzn6XroGWf9eJ_0UwNuFaFfcVixADQftcfN8JIbpx5sIGrrZfFcUpBTkNG8KC9czzw_Acyns3pvD1lU1hMKtpgTv2dgFcv63XFVG7odcELADT6OE5VgIjqcUtjeKVU7v3a1CybmeOvUwHwi-r9VnYoogBXKBdB2j0S5Gb87GEUSRcPffYUnv81Te',
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        ),
      ];

      for (var product in initialProducts) {
        await saveProduct(product);
      }
    }

    final List<Product> list = [];
    for (var key in _box.keys) {
      final data = Map<String, dynamic>.from(_box.get(key));
      list.add(Product.fromJson(data));
    }
    return list;
  }

  @override
  Future<void> saveProduct(Product product) async {
    await _box.put(product.id, product.toJson());
  }

  @override
  Future<void> deleteProduct(String id) async {
    await _box.delete(id);
  }
}

class HiveCustomerRepository implements CustomerRepository {
  final Box _box;

  HiveCustomerRepository(this._box);

  @override
  Future<List<Customer>> getCustomers() async {
    final List<Customer> list = [];
    for (var key in _box.keys) {
      final data = Map<String, dynamic>.from(_box.get(key));
      list.add(Customer.fromJson(data));
    }
    return list;
  }

  @override
  Future<void> saveCustomer(Customer customer) async {
    await _box.put(customer.id, customer.toJson());
  }

  @override
  Future<void> deleteCustomer(String id) async {
    await _box.delete(id);
  }
}

class HiveOrderRepository implements OrderRepository {
  final Box _box;

  HiveOrderRepository(this._box);

  @override
  Future<List<Order>> getOrders() async {
    final List<Order> list = [];
    for (var key in _box.keys) {
      final data = Map<String, dynamic>.from(_box.get(key));
      list.add(Order.fromJson(data));
    }
    return list;
  }

  @override
  Future<void> saveOrder(Order order) async {
    await _box.put(order.id, order.toJson());
  }

  @override
  Future<void> deleteOrder(String id) async {
    await _box.delete(id);
  }
}
