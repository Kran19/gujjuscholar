import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:edustream/core/constants/app_colors.dart';
import 'package:edustream/features/cart/presentation/providers/cart_controller.dart';
import 'package:edustream/features/my_courses/presentation/providers/my_courses_providers.dart';
import 'package:edustream/features/explore/presentation/providers/explore_providers.dart';
import 'package:edustream/features/home/presentation/screens/main_entry_screen.dart';
import 'package:edustream/routes/app_routes.dart';

import 'package:razorpay_flutter/razorpay_flutter.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
// ignore: avoid_web_libraries_in_flutter
import 'dart:js' as js; // ignore: deprecated_member_use
import 'package:flutter/foundation.dart' show kIsWeb;

class CartScreen extends ConsumerStatefulWidget {
  const CartScreen({super.key});

  @override
  ConsumerState<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends ConsumerState<CartScreen> {
  late Razorpay _razorpay;

  @override
  void initState() {
    super.initState();
    _razorpay = Razorpay();
    _razorpay.on(Razorpay.EVENT_PAYMENT_SUCCESS, _handlePaymentSuccess);
    _razorpay.on(Razorpay.EVENT_PAYMENT_ERROR, _handlePaymentError);
    _razorpay.on(Razorpay.EVENT_EXTERNAL_WALLET, _handleExternalWallet);

    // Register a global JS function so index.html can call Flutter back after web payment
    if (kIsWeb) {
      // ignore: undefined_function
      js.context['handleRazorpaySuccess'] = js.allowInterop(
        (String paymentId, String orderId, String signature) {
          _handlePaymentSuccess(PaymentSuccessResponse(
            paymentId,
            orderId,
            signature,
            null, // data field (optional metadata)
          ));
        },
      );
    }
  }

  @override
  void dispose() {
    _razorpay.clear();
    // Unregister the JS bridge to avoid stale closures
    if (kIsWeb) {
      js.context['handleRazorpaySuccess'] = null;
    }
    super.dispose();
  }

  void _handlePaymentSuccess(PaymentSuccessResponse response) async {
    try {
      // 1. Verify payment with backend (backend also clears cart & creates enrollment)
      await ref.read(cartControllerProvider).verifyPayment({
        'razorpay_order_id': response.orderId,
        'razorpay_payment_id': response.paymentId,
        'razorpay_signature': response.signature,
      });

      // 2. Clear local cart state immediately
      ref.read(cartControllerProvider).clearCart();

      // 3. Force refresh My Courses AND course subjects (so is_enrolled flag updates)
      ref.invalidate(myCoursesProvider);
      ref.invalidate(courseSubjectsProvider); // Clears all cached course subject pages

      if (!mounted) return;

      // 4. Show success dialog then navigate to My Courses tab
      await showDialog(
        context: context,
        barrierDismissible: false,
        builder: (ctx) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: const BoxDecoration(
                  color: Color(0xFF4CAF50),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.check_rounded, color: Colors.white, size: 40),
              ),
              const SizedBox(height: 16),
              const Text(
                'Payment Successful!',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              const Text(
                'Your course has been unlocked.\nYou can now access it from My Courses.',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.grey),
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => Navigator.pop(ctx),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF4CAF50),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                  child: const Text('Go to My Courses', style: TextStyle(fontWeight: FontWeight.bold)),
                ),
              ),
            ],
          ),
        ),
      );

      if (!mounted) return;

      // 5. Set tab to My Courses (index 1) BEFORE navigating
      ref.read(bottomNavIndexProvider.notifier).state = 1;

      // Use pushNamedAndRemoveUntil to clear the entire stack and go to entry screen
      // This prevents the blank page caused by popUntil failing to find the named route
      Navigator.of(context).pushNamedAndRemoveUntil(
        AppRoutes.entry,
        (route) => false, // Remove all routes from stack
      );

    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Verification Failed: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _handlePaymentError(PaymentFailureResponse response) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Payment Failed: ${response.message}')),
    );
  }

  void _handleExternalWallet(ExternalWalletResponse response) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('External Wallet: ${response.walletName}')),
    );
  }

  Future<void> _startCheckout() async {
    final messengerContext = context;
    debugPrint('Payment: Proceed to Payment button clicked!');

    try {
      debugPrint('Payment: Calling initiatePayment API...');
      final orderData = await ref.read(cartControllerProvider).initiatePayment();
      debugPrint('Payment: API Response received: $orderData');

      if (!messengerContext.mounted) {
        debugPrint('Payment: Context no longer mounted, aborting UI updates');
        return;
      }

      final key = orderData['razorpay_key'] ?? dotenv.env['RAZORPAY_KEY_ID'];
      debugPrint('Payment: Using Razorpay Key: $key');

      if (key == null || key.isEmpty) {
        throw 'Razorpay Key is missing! Please check your .env and backend configuration.';
      }

      final options = {
        'key': key,
        'amount': orderData['amount'],
        'name': orderData['name'],
        'description': orderData['description'],
        'order_id': orderData['razorpay_order_id'],
        'prefill': {
          'contact': '',
          'email': '',
        },
        'external': {
          'wallets': ['paytm']
        }
      };

      debugPrint('Payment: Attempting to open Razorpay sheet with options: $options');

      if (kIsWeb) {
        debugPrint('Payment: Detected Web platform, checking for JS function...');
        try {
          final funcExists = js.context.hasProperty('RazorpayOpen');
          debugPrint('Payment: RazorpayOpen function exists: $funcExists');

          if (!funcExists) {
            throw 'JS Error: RazorpayOpen function not found in index.html. Please REFRESH the page (Ctrl+F5).';
          }

          js.context.callMethod('RazorpayOpen', [js.JsObject.jsify(options)]);
          debugPrint('Payment: JS Interop call successful');
          return;
        } catch (jsError) {
          debugPrint('Payment: JS Interop failed: $jsError');
          throw 'JS Interop failed: $jsError';
        }
      }

      try {
        _razorpay.open(options);
        debugPrint('Payment: Razorpay open() called successfully');
      } catch (razorError) {
        debugPrint('Payment: CRITICAL ERROR - Failed to call _razorpay.open(): $razorError');
        throw 'Could not open payment window. Ensure the script is loaded: $razorError';
      }
    } catch (e, stack) {
      debugPrint('Payment: TOP LEVEL ERROR during checkout: $e');
      debugPrint('Payment: Stacktrace: $stack');

      if (!messengerContext.mounted) return;
      ScaffoldMessenger.of(messengerContext).showSnackBar(
        SnackBar(
          content: Text('Payment System Error: $e'),
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 10),
          action: SnackBarAction(
            label: 'RETRY',
            textColor: Colors.white,
            onPressed: _startCheckout,
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final cartState = ref.watch(cartControllerProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Your Cart', style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: AppColors.primary),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: cartState.isLoading
          ? const Center(child: CircularProgressIndicator())
          : cartState.items.isEmpty
              ? _buildEmptyCart()
              : Column(
                  children: [
                    Expanded(
                      child: ListView.builder(
                        padding: const EdgeInsets.all(16),
                        itemCount: cartState.items.length,
                        itemBuilder: (context, index) {
                          final item = cartState.items[index];
                          return _buildCartItem(item);
                        },
                      ),
                    ),
                    _buildCheckoutSummary(cartState),
                  ],
                ),
    );
  }

  Widget _buildEmptyCart() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.shopping_cart_outlined, size: 80, color: Colors.grey),
          const SizedBox(height: 20),
          const Text('Your cart is empty', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 12),
          ElevatedButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Go Shopping'),
          ),
        ],
      ),
    );
  }

  Widget _buildCartItem(dynamic item) {
    String title = item['item']?['name'] ?? 'Item';
    String price = item['price']?.toString() ?? '0';
    String type = item['item_type'] ?? '';

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 2,
      child: ListTile(
        contentPadding: const EdgeInsets.all(12),
        leading: Container(
          width: 50, height: 50,
          decoration: BoxDecoration(color: AppColors.primary.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(8)),
          child: Icon(type.toLowerCase().contains('course') ? Icons.school : Icons.book, color: AppColors.primary),
        ),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text(type.contains('bundle') ? 'Custom Bundle' : 'Single Item'),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('₹$price', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            IconButton(
              icon: const Icon(Icons.delete_outline, color: Colors.red),
              onPressed: () async {
                debugPrint('Cart: Attempting to remove item ${item['id']}');
                final messenger = ScaffoldMessenger.of(context);
                try {
                  await ref.read(cartControllerProvider).removeItem(item['id']);
                  debugPrint('Cart: Item removed successfully');
                } catch (e) {
                  debugPrint('Cart: Failed to remove item: $e');
                  if (context.mounted) {
                    messenger.showSnackBar(
                      SnackBar(
                        content: Text('Failed to remove item: $e'),
                        backgroundColor: Colors.red,
                      ),
                    );
                  }
                }
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCheckoutSummary(CartNotifier state) {
    final total = state.items.fold(0.0, (sum, item) => sum + (double.tryParse(item['price']?.toString() ?? '0') ?? 0.0));

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 10, offset: Offset(0, -5))],
      ),
      child: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Total Amount', style: TextStyle(fontSize: 16, color: Colors.grey)),
                Text('₹$total', style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: AppColors.primary)),
              ],
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity, height: 54,
              child: ElevatedButton(
                onPressed: state.isLoading ? null : _startCheckout,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: state.isLoading
                    ? const SizedBox(height: 24, width: 24, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                    : const Text('Proceed to Payment', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
