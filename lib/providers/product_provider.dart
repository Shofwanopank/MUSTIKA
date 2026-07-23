import 'package:flutter/material.dart';
import '../data/models.dart';
import '../data/repositories.dart';

class ProductProvider extends ChangeNotifier {
  final ProductRepository _repository;
  List<Product> _products = [];

  ProductProvider(this._repository);

  List<Product> get products => _products;

  Future<void> loadProducts() async {
    _products = await _repository.getProducts();
    notifyListeners();
  }

  double get totalStockValue {
    return _products.fold(0, (sum, product) => sum + (product.price * product.stock));
  }

  int get lowStockCount {
    return _products.where((p) => p.isAvailable && p.stock > 0 && p.stock <= 15).length;
  }

  int get outOfStockCount {
    return _products.where((p) => p.stock == 0).length;
  }

  Future<void> toggleProductAvailability(String id, bool val) async {
    final index = _products.indexWhere((p) => p.id == id);
    if (index != -1) {
      final updatedProduct = Product(
        id: _products[index].id,
        name: _products[index].name,
        description: _products[index].description,
        price: _products[index].price,
        stock: val ? (_products[index].stock == 0 ? 10 : _products[index].stock) : 0,
        isAvailable: val,
        imageUrl: _products[index].imageUrl,
        category: _products[index].category,
        createdAt: _products[index].createdAt,
        updatedAt: DateTime.now(),
      );

      _products[index] = updatedProduct;
      await _repository.saveProduct(updatedProduct);
      notifyListeners();
    }
  }

  Future<void> updateProductStock(String id, int stock) async {
    final index = _products.indexWhere((p) => p.id == id);
    if (index != -1) {
      final updatedProduct = Product(
        id: _products[index].id,
        name: _products[index].name,
        description: _products[index].description,
        price: _products[index].price,
        stock: stock,
        isAvailable: stock > 0,
        imageUrl: _products[index].imageUrl,
        category: _products[index].category,
        createdAt: _products[index].createdAt,
        updatedAt: DateTime.now(),
      );

      _products[index] = updatedProduct;
      await _repository.saveProduct(updatedProduct);
      notifyListeners();
    }
  }

  Future<void> addProduct(Product product) async {
    _products.add(product);
    await _repository.saveProduct(product);
    notifyListeners();
  }

  Future<void> deleteProduct(String id) async {
    _products.removeWhere((p) => p.id == id);
    await _repository.deleteProduct(id);
    notifyListeners();
  }
}
