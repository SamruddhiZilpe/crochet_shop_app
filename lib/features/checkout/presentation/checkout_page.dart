import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hive/hive.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:razorpay_flutter/razorpay_flutter.dart';
import '../../../shared/widgets/custom_button.dart';
import '../../../shared/widgets/custom_input_decoration.dart';
import '../../cart/presentation/bloc/cart_bloc.dart';
import '../../cart/presentation/bloc/cart_event.dart';
import '../../cart/presentation/bloc/cart_state.dart';
import '../../order/domain/entities/order_item.dart';
import '../../order/presentation/pages/order_success_file.dart';

class CheckoutPage extends StatefulWidget {
  const CheckoutPage({super.key});

  @override
  State<CheckoutPage> createState() => _CheckoutPageState();
}

class _CheckoutPageState extends State<CheckoutPage> {
  final _formKey = GlobalKey<FormState>();

  late final TextEditingController _nameController;
  late final TextEditingController _phoneController;
  late final TextEditingController _addressController;
  late Razorpay _razorpay;

  bool _isUsingSavedAddress = false;
  bool _isSavingAddressLoading = false;

  // Track all saved addresses and which one is selected
  List<Map<String, dynamic>> _savedAddressesList = [];
  int _selectedAddressIndex = 0;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController();
    _phoneController = TextEditingController();
    _addressController = TextEditingController();

    _razorpay = Razorpay();
    _razorpay.on(Razorpay.EVENT_PAYMENT_SUCCESS, _handlePaymentSuccess);
    _razorpay.on(Razorpay.EVENT_PAYMENT_ERROR, _handlePaymentError);

    _loadSavedAddresses();
  }

  void _loadSavedAddresses() {
    try {
      final userBox = Hive.box('userProfileBox');
      final dynamic savedData = userBox.get('profile');

      if (savedData != null) {
        setState(() {
          if (savedData is List) {
            // Handle new list-based structure
            _savedAddressesList = List<Map<String, dynamic>>.from(
              savedData.map((e) => Map<String, dynamic>.from(e as Map)),
            );
          } else if (savedData is Map) {
            // Migrates old legacy single-address users seamlessly
            _savedAddressesList = [Map<String, dynamic>.from(savedData)];
          }

          if (_savedAddressesList.isNotEmpty) {
            _selectAddress(_selectedAddressIndex);
            _isUsingSavedAddress = true;
          }
        });
      }
    } catch (e) {
      debugPrint("Error loading profile data into checkout: $e");
    }
  }

  void _selectAddress(int index) {
    if (index >= 0 && index < _savedAddressesList.length) {
      setState(() {
        _selectedAddressIndex = index;
        final selected = _savedAddressesList[index];
        _nameController.text = selected['name'] ?? "";
        _phoneController.text = selected['phone'] ?? "";
        _addressController.text = selected['address'] ?? "";
      });
    }
  }

  Future<void> _saveCurrentAddressToDatabase() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isSavingAddressLoading = true;
    });

    try {
      final name = _nameController.text.trim();
      final phone = _phoneController.text.trim();
      final address = _addressController.text.trim();

      final newAddressMap = {
        'id': DateTime.now().millisecondsSinceEpoch.toString(),
        'name': name,
        'phone': phone,
        'address': address,
      };

      // Check if this address string already exists to prevent exact duplicate entries
      final preExistingIndex = _savedAddressesList.indexWhere(
        (element) => element['address'].toString().trim() == address,
      );

      if (preExistingIndex != -1) {
        // Just update the contact details on the existing one
        _savedAddressesList[preExistingIndex] = newAddressMap;
        _selectedAddressIndex = preExistingIndex;
      } else {
        // Add new address to the list history
        _savedAddressesList.add(newAddressMap);
        _selectedAddressIndex = _savedAddressesList.length - 1;
      }

      final userBox = Hive.box('userProfileBox');
      await userBox.put('profile', _savedAddressesList);

      final uid = FirebaseAuth.instance.currentUser?.uid;
      if (uid != null) {
        await FirebaseFirestore.instance.collection('users').doc(uid).set({
          'addresses': _savedAddressesList,
          // Keep root values mirrored for system backwards compatibility
          'name': name,
          'phone': phone,
          'address': address,
        }, SetOptions(merge: true));
      }

      setState(() {
        _isUsingSavedAddress = true;
        _isSavingAddressLoading = false;
      });

      _showSnackBar("Address saved successfully!");
    } catch (e) {
      setState(() {
        _isSavingAddressLoading = false;
      });
      _showSnackBar("Failed to save address: $e");
    }
  }

  Future<void> _deleteAddressInstance(int index) async {
    try {
      setState(() {
        _savedAddressesList.removeAt(index);
        if (_selectedAddressIndex >= _savedAddressesList.length) {
          _selectedAddressIndex = _savedAddressesList.length - 1;
        }
      });

      final userBox = Hive.box('userProfileBox');

      if (_savedAddressesList.isEmpty) {
        await userBox.delete('profile');
        _nameController.clear();
        _phoneController.clear();
        _addressController.clear();
        setState(() {
          _isUsingSavedAddress = false;
        });
      } else {
        await userBox.put('profile', _savedAddressesList);
        _selectAddress(_selectedAddressIndex);
      }

      final uid = FirebaseAuth.instance.currentUser?.uid;
      if (uid != null) {
        if (_savedAddressesList.isEmpty) {
          await FirebaseFirestore.instance.collection('users').doc(uid).update({
            'phone': FieldValue.delete(),
            'address': FieldValue.delete(),
            'addresses': FieldValue.delete(),
          });
        } else {
          await FirebaseFirestore.instance.collection('users').doc(uid).set({
            'addresses': _savedAddressesList,
            'name': _savedAddressesList[_selectedAddressIndex]['name'],
            'phone': _savedAddressesList[_selectedAddressIndex]['phone'],
            'address': _savedAddressesList[_selectedAddressIndex]['address'],
          }, SetOptions(merge: true));
        }
      }

      _showSnackBar("Address deleted successfully.");
    } catch (e) {
      _showSnackBar("Failed to delete address: $e");
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    _razorpay.clear();
    super.dispose();
  }

  void _startPaymentProcess(double totalAmount) {
    var options = {
      'key': 'rzp_test_T0cdeDKoaixdd0',
      'amount': (totalAmount * 100).toInt(),
      'name': "Veemadeforyou",
      'description': 'Handmade Crochet Order',
      'retry': {'enabled': true, 'max_count': 1},
      'prefill': {
        'contact': _phoneController.text.trim(),
        'email': 'customer@example.com',
      },
    };

    try {
      _razorpay.open(options);
    } catch (e) {
      _showSnackBar("Failed to open Razorpay gateway: $e");
    }
  }

  void _handlePaymentSuccess(PaymentSuccessResponse response) async {
    final cartBloc = context.read<CartBloc>();
    final items = cartBloc.state.items;
    final orderId = DateTime.now().millisecondsSinceEpoch.toString();

    try {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (_) => const Center(child: CircularProgressIndicator()),
      );

      await FirebaseFirestore.instance.collection('orders').doc(orderId).set({
        'orderId': orderId,
        'paymentId': response.paymentId,
        'customerName': _nameController.text.trim(),
        'mobileNumber': _phoneController.text.trim(),
        'shippingAddress': _addressController.text.trim(),
        'items': items
            .map(
              (e) => {'name': e.name, 'price': e.price, 'quantity': e.quantity},
            )
            .toList(),
        'totalAmount': cartBloc.state.totalPrice,
        'status': 'Paid - Processing Shipment',
        'createdAt': FieldValue.serverTimestamp(),
      });

      final orderBox = Hive.box<OrderItem>('ordersBox');
      final localOrder = OrderItem(
        id: orderId,
        productNames: items.map((e) => e.name).toList(),
        total: cartBloc.state.totalPrice,
        date: DateTime.now().toString().substring(0, 16),
      );
      await orderBox.add(localOrder);

      for (var item in items) {
        cartBloc.add(RemoveItem(item.id));
      }

      if (mounted) Navigator.pop(context);

      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const OrderSuccessPage()),
        );
      }
    } catch (e) {
      if (mounted) Navigator.pop(context);
      _showSnackBar("Payment succeeded, but failed to save order: $e");
    }
  }

  void _handlePaymentError(PaymentFailureResponse response) {
    _showSnackBar("Payment Failed: ${response.message ?? 'Unknown Error'}");
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: theme.appBarTheme.backgroundColor,
        elevation: 0,
        title: Text(
          "Checkout",
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        iconTheme: IconThemeData(color: theme.iconTheme.color),
      ),
      body: BlocBuilder<CartBloc, CartState>(
        builder: (context, state) {
          final items = state.items;
          final isCartEmpty = items.isEmpty;

          return Form(
            key: _formKey,
            child: Column(
              children: [
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        /// SECTION 1: ORDER ITEMS
                        Text(
                          "Your Items",
                          style: theme.textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 10),

                        ListView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: items.length,
                          itemBuilder: (context, index) {
                            final item = items[index];
                            return Card(
                              color: theme.cardColor,
                              margin: const EdgeInsets.only(bottom: 12),
                              elevation: isDark ? 0 : 2,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                              ),
                              child: Padding(
                                padding: const EdgeInsets.all(12),
                                child: Row(
                                  children: [
                                    ClipRRect(
                                      borderRadius: BorderRadius.circular(12),
                                      child: Image.network(
                                        item.image,
                                        height: 60,
                                        width: 60,
                                        fit: BoxFit.cover,
                                        errorBuilder:
                                            (context, error, stackTrace) =>
                                                const Icon(
                                                  Icons.image_not_supported,
                                                ),
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            item.name,
                                            style: theme.textTheme.bodyLarge
                                                ?.copyWith(
                                                  fontWeight: FontWeight.bold,
                                                ),
                                          ),
                                          const SizedBox(height: 6),
                                          Text(
                                            "₹${item.price}",
                                            style: theme.textTheme.bodyMedium
                                                ?.copyWith(
                                                  color:
                                                      theme.colorScheme.primary,
                                                  fontWeight: FontWeight.w600,
                                                ),
                                          ),
                                          const SizedBox(height: 6),
                                          Text(
                                            "Quantity: ${item.quantity}",
                                            style: theme.textTheme.bodySmall,
                                          ),
                                        ],
                                      ),
                                    ),
                                    Text(
                                      "₹${(item.price * item.quantity).toStringAsFixed(0)}",
                                      style: theme.textTheme.titleMedium
                                          ?.copyWith(
                                            fontWeight: FontWeight.bold,
                                          ),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),

                        const SizedBox(height: 20),
                        const Divider(),
                        const SizedBox(height: 10),

                        /// SECTION 2: SHIPPING DETAILS HEADER WITH UX TOGGLE
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              "Delivery Address",
                              style: theme.textTheme.titleSmall?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            if (_savedAddressesList.isNotEmpty)
                              TextButton(
                                onPressed: () {
                                  setState(() {
                                    _isUsingSavedAddress =
                                        !_isUsingSavedAddress;

                                    if (_isUsingSavedAddress) {
                                      // If switching back to saved, auto-populate selected index
                                      _selectAddress(_selectedAddressIndex);
                                    } else {
                                      // If turning off saved mode to add a new address, clear fields out!
                                      _nameController.clear();
                                      _phoneController.clear();
                                      _addressController.clear();
                                    }
                                  });
                                },
                                child: Text(
                                  _isUsingSavedAddress
                                      ? "Add New Address"
                                      : "View Saved Addresses (${_savedAddressesList.length})",
                                  style: TextStyle(
                                    color: theme.colorScheme.primary,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                          ],
                        ),
                        const SizedBox(height: 8),

                        /// SWITCH VIEW INTERCHANGEABILITY
                        AnimatedSwitcher(
                          duration: const Duration(milliseconds: 200),
                          child:
                              (_isUsingSavedAddress &&
                                  _savedAddressesList.isNotEmpty)
                              ? _buildSavedAddressesCarousel(theme)
                              : _buildEditableAddressForm(theme),
                        ),
                        const SizedBox(height: 20),
                      ],
                    ),
                  ),
                ),

                /// BOTTOM CHECKOUT CONTAINER
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: theme.cardColor,
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(24),
                      topRight: Radius.circular(24),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: isDark ? Colors.black54 : Colors.black12,
                        blurRadius: 10,
                        spreadRadius: 2,
                      ),
                    ],
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text("Total", style: theme.textTheme.titleMedium),
                          Text(
                            "₹${state.totalPrice.toStringAsFixed(2)}",
                            style: theme.textTheme.headlineSmall?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: theme.colorScheme.primary,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),

                      CustomButton(
                        text: isCartEmpty ? "Cart Empty" : "Place Order",
                        backgroundColor: isCartEmpty
                            ? Colors.grey
                            : theme.colorScheme.primary,
                        width: size.width * 0.7,
                        height: size.height * 0.06,
                        onPressed: () {
                          if (isCartEmpty) return;

                          if ((_isUsingSavedAddress &&
                                  _savedAddressesList.isNotEmpty) ||
                              _formKey.currentState!.validate()) {
                            _startPaymentProcess(state.totalPrice);
                          }
                        },
                      ),
                      const SizedBox(height: 10),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  /// UI COMPONENT: Displays list of saved addresses
  Widget _buildSavedAddressesCarousel(ThemeData theme) {
    return ListView.builder(
      key: const ValueKey("SavedList"),
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: _savedAddressesList.length,
      itemBuilder: (context, index) {
        final item = _savedAddressesList[index];
        final rawAddress = item['address'] ?? '';
        final addressParts = rawAddress.split(' | ');
        final isSelected = index == _selectedAddressIndex;

        String displayAddress = rawAddress;
        if (addressParts.length >= 4) {
          displayAddress =
              "${addressParts[0]}\n${addressParts[1]}, ${addressParts[2]} - ${addressParts[3]}";
        }

        return GestureDetector(
          onTap: () => _selectAddress(index),
          child: Container(
            margin: const EdgeInsets.only(bottom: 12),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: theme.cardColor,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: isSelected
                    ? theme.colorScheme.primary
                    : theme.colorScheme.primary.withOpacity(0.1),
                width: isSelected ? 2.0 : 1.0,
              ),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Radio<int>(
                  value: index,
                  groupValue: _selectedAddressIndex,
                  activeColor: theme.colorScheme.primary,
                  onChanged: (val) {
                    if (val != null) _selectAddress(val);
                  },
                ),
                const SizedBox(width: 4),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        item['name'] ?? '',
                        style: theme.textTheme.bodyLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        item['phone'] ?? '',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: Colors.grey,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        displayAddress,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          height: 1.4,
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  onPressed: () async {
                    final confirmDelete = await showDialog<bool>(
                      context: context,
                      builder: (context) => AlertDialog(
                        title: const Text("Delete Saved Address?"),
                        content: const Text(
                          "This will remove this specific address from your profile history.",
                        ),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(context, false),
                            child: const Text("Cancel"),
                          ),
                          TextButton(
                            onPressed: () => Navigator.pop(context, true),
                            child: const Text(
                              "Delete",
                              style: TextStyle(color: Colors.red),
                            ),
                          ),
                        ],
                      ),
                    );
                    if (confirmDelete == true) {
                      await _deleteAddressInstance(index);
                    }
                  },
                  icon: const Icon(
                    Icons.delete_outline,
                    color: Colors.redAccent,
                    size: 22,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  /// UI COMPONENT: Input fields paired with an inline dynamic "Save Address" pipeline
  Widget _buildEditableAddressForm(ThemeData theme) {
    return Container(
      key: const ValueKey("FormFields"),
      child: Column(
        children: [
          TextFormField(
            controller: _nameController,
            decoration:
                CustomInputDecoration.build(
                  hint: "Full Name",
                  icon: Icons.person,
                  theme: theme,
                ).copyWith(
                  suffixIcon: _nameController.text.isNotEmpty
                      ? IconButton(
                          icon: const Icon(Icons.clear, size: 18),
                          onPressed: () =>
                              setState(() => _nameController.clear()),
                        )
                      : null,
                ),
            onChanged: (val) => setState(() {}),
            validator: (val) => val == null || val.trim().isEmpty
                ? "Please enter your name"
                : null,
          ),
          const SizedBox(height: 12),
          TextFormField(
            controller: _phoneController,
            keyboardType: TextInputType.phone,
            decoration:
                CustomInputDecoration.build(
                  hint: "Mobile Number",
                  icon: Icons.phone,
                  theme: theme,
                ).copyWith(
                  suffixIcon: _phoneController.text.isNotEmpty
                      ? IconButton(
                          icon: const Icon(Icons.clear, size: 18),
                          onPressed: () =>
                              setState(() => _phoneController.clear()),
                        )
                      : null,
                ),
            onChanged: (val) => setState(() {}),
            validator: (val) {
              if (val == null || val.trim().isEmpty)
                return "Please enter phone number";
              if (val.trim().length < 10)
                return "Please enter a valid 10-digit number";
              return null;
            },
          ),
          const SizedBox(height: 12),
          TextFormField(
            controller: _addressController,
            maxLines: 3,
            decoration:
                CustomInputDecoration.build(
                  hint: "Complete Shipping Address with Pincode",
                  icon: Icons.home,
                  theme: theme,
                ).copyWith(
                  suffixIcon: _addressController.text.isNotEmpty
                      ? IconButton(
                          icon: const Icon(Icons.clear, size: 18),
                          onPressed: () =>
                              setState(() => _addressController.clear()),
                        )
                      : null,
                ),
            onChanged: (val) => setState(() {}),
            validator: (val) => val == null || val.trim().isEmpty
                ? "Please enter delivery address"
                : null,
          ),
          const SizedBox(height: 16),

          /// Interactive Button to Save the Modified Address Form State
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 14),
                side: BorderSide(color: theme.colorScheme.primary),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              onPressed: _isSavingAddressLoading
                  ? null
                  : _saveCurrentAddressToDatabase,
              icon: _isSavingAddressLoading
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : Icon(Icons.save_alt, color: theme.colorScheme.primary),
              label: Text(
                _isSavingAddressLoading
                    ? "Saving..."
                    : "Save details to my profile updates",
                style: TextStyle(
                  color: theme.colorScheme.primary,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
