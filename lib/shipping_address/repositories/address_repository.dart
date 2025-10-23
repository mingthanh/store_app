import 'package:store_app/shipping_address/models/address.dart';

class AddressRepository {
  List<Address> getAddresses() {
    // Implementation here
    return [
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
    ];
  }
  Address? getDefaultAddress() {
    return getAddresses().firstWhere(
      (address) => address.isDefault,
      orElse: () => getAddresses().first,
    );
  }
}