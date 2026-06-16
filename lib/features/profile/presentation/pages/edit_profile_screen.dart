import 'package:flutter/material.dart';
import '../../../../shared/widgets/custom_input_decoration.dart';

class EditProfileScreen extends StatefulWidget {
  final String name;
  final String email;
  final String phone;
  final String address;

  const EditProfileScreen({
    super.key,
    required this.name,
    required this.email,
    required this.phone,
    required this.address,
  });

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _emailController;
  late TextEditingController _phoneController;

  // Dedicated controllers for explicit address architecture
  late TextEditingController _streetController;
  late TextEditingController _cityController;
  late TextEditingController _stateController;
  late TextEditingController _pincodeController;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.name);
    _emailController = TextEditingController(text: widget.email);
    _phoneController = TextEditingController(text: widget.phone);

    // Parse the existing consolidated address string if it contains our delimiter structure
    final addressParts = widget.address.split(' | ');
    if (addressParts.length >= 4) {
      _streetController = TextEditingController(text: addressParts[0]);
      _cityController = TextEditingController(text: addressParts[1]);
      _stateController = TextEditingController(text: addressParts[2]);
      _pincodeController = TextEditingController(text: addressParts[3]);
    } else {
      // Fallback clean slate initialization if the format is new or empty
      _streetController = TextEditingController(text: widget.address);
      _cityController = TextEditingController();
      _stateController = TextEditingController();
      _pincodeController = TextEditingController();
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _streetController.dispose();
    _cityController.dispose();
    _stateController.dispose();
    _pincodeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text("Edit Profile"),
        backgroundColor: theme.appBarTheme.backgroundColor,
        elevation: 0,
        iconTheme: IconThemeData(color: theme.iconTheme.color),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Personal Info",
                style: theme.textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: Colors.grey,
                ),
              ),
              const SizedBox(height: 10),

              // Name Field
              TextFormField(
                controller: _nameController,
                decoration: CustomInputDecoration.build(
                  hint: "Name",
                  icon: Icons.person,
                  theme: theme,
                ),
                validator: (val) => val == null || val.trim().isEmpty
                    ? "Name cannot be empty"
                    : null,
              ),
              const SizedBox(height: 16),

              // Email Field
              TextFormField(
                controller: _emailController,
                keyboardType: TextInputType.emailAddress,
                decoration: CustomInputDecoration.build(
                  hint: "Email",
                  icon: Icons.email,
                  theme: theme,
                ),
                validator: (val) => val == null || val.trim().isEmpty
                    ? "Email cannot be empty"
                    : null,
              ),
              const SizedBox(height: 16),

              // Phone Field
              TextFormField(
                controller: _phoneController,
                keyboardType: TextInputType.phone,
                decoration: CustomInputDecoration.build(
                  hint: "Mobile Number",
                  icon: Icons.phone,
                  theme: theme,
                ),
                validator: (val) {
                  if (val == null || val.trim().isEmpty)
                    return "Phone number cannot be empty";
                  if (val.trim().length < 10)
                    return "Enter a valid 10-digit number";
                  return null;
                },
              ),

              const SizedBox(height: 24),
              const Divider(),
              const SizedBox(height: 12),
              Text(
                "Shipping Destination",
                style: theme.textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: Colors.grey,
                ),
              ),
              const SizedBox(height: 12),

              // Detailed Street Address Input
              TextFormField(
                controller: _streetController,
                maxLines: 2,
                decoration: CustomInputDecoration.build(
                  hint: "Flat, House no., Building, Company, Apartment",
                  icon: Icons.location_city,
                  theme: theme,
                ),
                validator: (val) => val == null || val.trim().isEmpty
                    ? "Street address details are required"
                    : null,
              ),
              const SizedBox(height: 16),

              // City Input Field
              TextFormField(
                controller: _cityController,
                decoration: CustomInputDecoration.build(
                  hint: "Town / City",
                  icon: Icons.map,
                  theme: theme,
                ),
                validator: (val) => val == null || val.trim().isEmpty
                    ? "City is required"
                    : null,
              ),
              const SizedBox(height: 16),

              // State & Pincode Inline Split Grid View Layout Row
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // State Input Component Module
                  Expanded(
                    child: TextFormField(
                      controller: _stateController,
                      decoration: CustomInputDecoration.build(
                        hint: "State",
                        icon: Icons.explore,
                        theme: theme,
                      ),
                      validator: (val) =>
                          val == null || val.trim().isEmpty ? "Required" : null,
                    ),
                  ),
                  const SizedBox(width: 12),

                  // Pincode Input Component Module
                  Expanded(
                    child: TextFormField(
                      controller: _pincodeController,
                      keyboardType: TextInputType.number,
                      decoration: CustomInputDecoration.build(
                        hint: "Pincode",
                        icon: Icons.pin_drop,
                        theme: theme,
                      ),
                      validator: (val) {
                        if (val == null || val.trim().isEmpty)
                          return "Required";
                        if (val.trim().length != 6 ||
                            int.tryParse(val.trim()) == null) {
                          return "Enter 6-digit pin";
                        }
                        return null;
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 35),

              // Save Changes Action Confirmation Button
              Center(
                child: SizedBox(
                  width: size.width * 0.7,
                  height: size.height * 0.055,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: theme.colorScheme.primary,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    onPressed: () {
                      if (_formKey.currentState!.validate()) {
                        // Concatenate structural data elements cleanly with a split token delimiter
                        final blendedAddress =
                            "${_streetController.text.trim()} | ${_cityController.text.trim()} | ${_stateController.text.trim()} | ${_pincodeController.text.trim()}";

                        // Return the cleanly unified payload map data block backward to your ProfileScreen setup
                        Navigator.pop(context, {
                          "name": _nameController.text.trim(),
                          "email": _emailController.text.trim(),
                          "phone": _phoneController.text.trim(),
                          "address": blendedAddress,
                        });
                      }
                    },
                    child: const Text(
                      "Save Changes",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}
