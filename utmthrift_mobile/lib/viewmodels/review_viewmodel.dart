// ignore_for_file: avoid_print

import 'package:flutter/material.dart';
import 'package:utmthrift_mobile/models/review_model.dart';
import 'package:utmthrift_mobile/services/review_service.dart';

class ReviewViewModel extends ChangeNotifier {
  final ReviewService _reviewService = ReviewService();

  List<Review> _reviews = [];
  double _averageRating = 0.0;
  bool _isLoading = false;

  List<Review> get reviews => _reviews;
  double get averageRating => _averageRating;
  bool get isLoading => _isLoading;

  Future<void> fetchReviews(int sellerId) async {
    _isLoading = true;
    notifyListeners();
    try {
      _reviews = await _reviewService.fetchReviewsForSeller(sellerId);
      _averageRating = await _reviewService.fetchAverageRating(sellerId);
    } catch (e) {
      print('Error loading reviews: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> submitReview({
    required int orderId,
    required int itemId,
    required int buyerId,
    required int sellerId,
    required int rating,
    String? comment,
  }) async {
    try {
      final success = await _reviewService.submitReview(
        orderId: orderId,
        itemId: itemId,
        buyerId: buyerId,
        sellerId: sellerId,
        rating: rating,
        comment: comment,
      );
      if (success) {
        await fetchReviews(sellerId); // Refresh reviews
        return true;
      }
      return false;
    } catch (e) {
      print('Error in ViewModel.submitReview: $e');
      rethrow; // So UI can handle it too
    }
  }

}
