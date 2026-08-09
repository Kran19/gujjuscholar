import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:edustream/core/constants/app_colors.dart';
import 'package:edustream/features/cart/presentation/providers/cart_controller.dart';


class CoursePreviewScreen extends ConsumerStatefulWidget {
  final int std;
  final String? standardName;
  final String? purchaseLabel;
  final String? purchaseType;
  final int? itemId;
  final double? price;

  const CoursePreviewScreen({
    super.key,
    required this.std,
    this.standardName,
    this.purchaseLabel,
    this.purchaseType,
    this.itemId,
    this.price,
  });

  @override
  ConsumerState<CoursePreviewScreen> createState() => _CoursePreviewScreenState();
}

class _CoursePreviewScreenState extends ConsumerState<CoursePreviewScreen> {
  @override
  Widget build(BuildContext context) {
    final cartState = ref.watch(cartControllerProvider);
    final inCart = cartState.items.any((item) => 
        item['item_id'].toString() == widget.itemId.toString() && 
        item['item_type'].toString().toLowerCase().contains(widget.purchaseType ?? 'course'));

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(widget.purchaseLabel ?? "Course Preview", style: const TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: AppColors.primary),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.movie_filter_rounded, size: 80, color: AppColors.primary),
            const SizedBox(height: 24),
            Text(widget.purchaseLabel ?? "", style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            Text("Price: ₹${widget.price ?? 0}", style: const TextStyle(fontSize: 18, color: AppColors.secondary)),
            const SizedBox(height: 32),
            ElevatedButton(
              onPressed: inCart || cartState.isLoading ? null : () async {
                try {
                  await ref.read(cartControllerProvider).addItem(type: widget.purchaseType ?? 'course', itemId: widget.itemId!);
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Added to cart!'), backgroundColor: Colors.green),
                    );
                  }
                } catch (e) {
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Failed: $e'), backgroundColor: Colors.red),
                    );
                  }
                }
              },
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 48, vertical: 16),
              ),
              child: cartState.isLoading 
                ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2))
                : Text(inCart ? "Already in Cart" : "Add to Cart"),
            ),
          ],
        ),
      ),
    );
  }
}
