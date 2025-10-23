import 'package:store_app/shipping_address/models/address.dart';

/// Simple in-memory repository for Shipping Addresses.
/// For production, back this with Firestore and user-specific docs.
class AddressRepository {
  AddressRepository() {
    // Seed initial data once
    if (_addresses.isEmpty) {
      _addresses.addAll([
        Address(
          id: '1',
          label: 'Home',
          fullAddress: '31 Spooner , Quahog, Rhode Island',
          city: 'Quahog',
          state: 'Rhode Island',
          isDefault: true,
          zipCode: '62701',
        ),
        Address(
          id: '2',
          label: 'Work',
          fullAddress: '456 Elm St, Springfield, IL',
          city: 'Springfield',
          state: 'IL',
          zipCode: '62701',
        ),
      ]);
    }
  }

  final List<Address> _addresses = <Address>[];

  List<Address> getAddresses() => List.unmodifiable(_addresses);

  Address? getDefaultAddress() {
    if (_addresses.isEmpty) return null;
    return _addresses.firstWhere(
      (address) => address.isDefault,
      orElse: () => _addresses.first,
    );
  }

  void addAddress(Address address) {
    _addresses.add(address);
  }

  void updateAddress(Address updated) {
    final idx = _addresses.indexWhere((a) => a.id == updated.id);
    if (idx != -1) {
      _addresses[idx] = updated;
    }
  }

  void deleteAddress(String id) {
    _addresses.removeWhere((a) => a.id == id);
  }
}