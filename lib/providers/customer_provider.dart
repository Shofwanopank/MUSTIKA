import 'package:flutter/material.dart';
import 'dart:math';
import '../data/models.dart';
import '../data/repositories.dart';

class CustomerProvider extends ChangeNotifier {
  final CustomerRepository _repository;
  List<Customer> _customers = [];

  CustomerProvider(this._repository);

  List<Customer> get customers => _customers;

  Future<void> loadCustomers() async {
    _customers = await _repository.getCustomers();
    notifyListeners();
  }

  Future<Customer> getOrCreateCustomer(String name, String phone, {String address = ''}) async {
    final cleanPhone = phone.replaceAll(RegExp(r'\s+'), '');
    final index = _customers.indexWhere((c) => c.phone.replaceAll(RegExp(r'\s+'), '') == cleanPhone);

    if (index != -1) {
      // If customer exists but name or address changed, update it
      final existing = _customers[index];
      if (existing.name != name || existing.address != address) {
        final updated = Customer(
          id: existing.id,
          name: name,
          phone: phone,
          address: address,
          createdAt: existing.createdAt,
          updatedAt: DateTime.now(),
        );
        _customers[index] = updated;
        await _repository.saveCustomer(updated);
        notifyListeners();
        return updated;
      }
      return existing;
    } else {
      // Create new customer
      final newCustomer = Customer(
        id: 'CUST-${Random().nextInt(9000) + 1000}',
        name: name,
        phone: phone,
        address: address,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );
      _customers.add(newCustomer);
      await _repository.saveCustomer(newCustomer);
      notifyListeners();
      return newCustomer;
    }
  }

  Future<void> addCustomer(Customer customer) async {
    _customers.add(customer);
    await _repository.saveCustomer(customer);
    notifyListeners();
  }

  Future<void> updateCustomer(Customer customer) async {
    final idx = _customers.indexWhere((c) => c.id == customer.id);
    if (idx != -1) {
      final updated = Customer(
        id: customer.id,
        name: customer.name,
        phone: customer.phone,
        address: customer.address,
        createdAt: customer.createdAt,
        updatedAt: DateTime.now(),
      );
      _customers[idx] = updated;
      await _repository.saveCustomer(updated);
      notifyListeners();
    }
  }

  Future<void> deleteCustomer(String id) async {
    _customers.removeWhere((c) => c.id == id);
    await _repository.deleteCustomer(id);
    notifyListeners();
  }
}
