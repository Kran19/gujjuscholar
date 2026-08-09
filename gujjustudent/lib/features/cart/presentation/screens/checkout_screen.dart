import 'package:flutter/material.dart';
import 'package:edustream/core/constants/app_colors.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:edustream/features/cart/presentation/providers/cart_controller.dart';
import 'package:edustream/features/auth/presentation/providers/auth_providers.dart';

class CheckoutScreen extends ConsumerStatefulWidget {
  const CheckoutScreen({super.key});

  @override
  ConsumerState<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends ConsumerState<CheckoutScreen> {
  bool _isProcessing = false;

  void _handlePayment() async {
    setState(() => _isProcessing = true);
    try {
      await ref.read(cartControllerProvider).checkout('Razorpay');
      if (mounted) {
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Success'),
            content: const Text('Order placed successfully!'),
            actions: [
              TextButton(onPressed: () => Navigator.of(context).popUntil((route) => route.isFirst), child: const Text('OK')),
            ],
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
      }
    } finally {
      if (mounted) setState(() => _isProcessing = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final cartState = ref.watch(cartControllerProvider);
    final profileAsync = ref.watch(profileProvider);

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        title: const Text('Secure Checkout', style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(icon: const Icon(Icons.arrow_back, color: AppColors.primary), onPressed: () => Navigator.pop(context)),
      ),
      body: profileAsync.when(
        data: (user) => SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildOrderSummary(cartState.items),
              const SizedBox(height: 24),
              _buildStudentDetails(user),
              const SizedBox(height: 24),
              _buildPaymentMethod(),
              const SizedBox(height: 24),
              _buildPricing(cartState),
              const SizedBox(height: 32),
              _buildPayButton(),
            ],
          ),
        ),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(child: Text("Error loading profile: $err")),
      ),
    );
  }

  Widget _buildOrderSummary(List<dynamic> items) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text("Order Summary", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        const SizedBox(height: 12),
        ...items.map((item) {
          final name = item['item']?['name'] ?? 'Item';
          return Card(
              child: ListTile(
                title: Text(name),
                trailing: Text("₹${item['price']}", style: const TextStyle(fontWeight: FontWeight.bold)),
              ),
            );
        }),
      ],
    );
  }

  Widget _buildStudentDetails(dynamic user) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text("Student Details", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        const SizedBox(height: 12),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                _detailRow(Icons.person, "Name", user['name']),
                const Divider(),
                _detailRow(Icons.email, "Email", user['email']),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _detailRow(IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(icon, size: 20, color: AppColors.primary),
        const SizedBox(width: 12),
        Text("$label: ", style: const TextStyle(color: Colors.grey)),
        Text(value, style: const TextStyle(fontWeight: FontWeight.w600)),
      ],
    );
  }

  Widget _buildPaymentMethod() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text("Payment Method", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        const SizedBox(height: 12),
        const Card(
          child: ListTile(
            leading: Icon(Icons.payment, color: AppColors.primary),
            title: Text("Online Payment (Razorpay)"),
            trailing: Icon(Icons.check_circle, color: Colors.green),
          ),
        ),
      ],
    );
  }

  Widget _buildPricing(CartNotifier state) {
    final subtotal = state.items.fold<double>(0, (sum, item) => sum + (double.tryParse(item['price']?.toString() ?? '0') ?? 0.0));
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            _priceRow("Subtotal", "₹$subtotal"),
            const Divider(),
            _priceRow("Total Payable", "₹$subtotal", isTotal: true),
          ],
        ),
      ),
    );
  }

  Widget _priceRow(String label, String value, {bool isTotal = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: TextStyle(fontSize: isTotal ? 18 : 14, fontWeight: isTotal ? FontWeight.bold : FontWeight.normal)),
        Text(value, style: TextStyle(fontSize: isTotal ? 18 : 14, fontWeight: FontWeight.bold, color: isTotal ? AppColors.primary : null)),
      ],
    );
  }

  Widget _buildPayButton() {
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: ElevatedButton(
        onPressed: _isProcessing ? null : _handlePayment,
        style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary, foregroundColor: Colors.white, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16))),
        child: _isProcessing ? const CircularProgressIndicator(color: Colors.white) : const Text("Pay Securely", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
      ),
    );
  }
}

