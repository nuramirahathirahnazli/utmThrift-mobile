// ignore_for_file: avoid_print, use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';

import '../../viewmodels/review_viewmodel.dart';

class LeaveReviewPage extends StatefulWidget {
  final int orderId;
  final int itemId;
  final int buyerId;
  final int sellerId;

  const LeaveReviewPage({
    super.key,
    required this.orderId,
    required this.itemId,
    required this.buyerId,
    required this.sellerId,
  });

  @override
  State<LeaveReviewPage> createState() => _LeaveReviewPageState();
}

class _LeaveReviewPageState extends State<LeaveReviewPage> {
  double _rating = 3;
  final TextEditingController _commentController = TextEditingController();
  bool _isSubmitting = false;

  void _submitReview(BuildContext context) async {
    setState(() => _isSubmitting = true);

    final viewModel = Provider.of<ReviewViewModel>(context, listen: false);
    final success = await viewModel.submitReview(
      orderId: widget.orderId,
      itemId: widget.itemId,
      buyerId: widget.buyerId,
      sellerId: widget.sellerId,
      rating: _rating.toInt(),
      comment: _commentController.text.trim(),
    );

    setState(() => _isSubmitting = false);

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Review submitted successfully!')),
      );
      Navigator.pop(context);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to submit review')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Leave a Review')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            const Text(
              'Rate this item',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            RatingBar.builder(
              initialRating: _rating,
              minRating: 1,
              direction: Axis.horizontal,
              allowHalfRating: false,
              itemCount: 5,
              itemPadding: const EdgeInsets.symmetric(horizontal: 4.0),
              itemBuilder: (context, _) => const Icon(Icons.star, color: Colors.amber),
              onRatingUpdate: (rating) {
                setState(() {
                  _rating = rating;
                });
              },
            ),
            const SizedBox(height: 24),
            TextField(
              controller: _commentController,
              maxLines: 4,
              decoration: InputDecoration(
                labelText: 'Comment (optional)',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: _isSubmitting ? null : () => _submitReview(context),
              child: _isSubmitting
                  ? const CircularProgressIndicator(color: Colors.white)
                  : const Text('Submit Review'),
            ),
          ],
        ),
      ),
    );
  }
}
