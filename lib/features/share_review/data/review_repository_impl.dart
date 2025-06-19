import 'dart:io';
import '../domain/review.dart';
import 'cloudinary_service.dart';
import 'firestore_service.dart';

class ReviewRepositoryImpl {
  final CloudinaryService _cloudinaryService;
  final FirestoreService _firestoreService;

  ReviewRepositoryImpl(this._cloudinaryService, this._firestoreService);

  Future<List<String>> uploadMedia(List<File> files) async {
    final List<String> urls = [];
    for (final file in files) {
      final url = await _cloudinaryService.uploadMedia(file);
      urls.add(url);
    }
    return urls;
  }

  List<String> getMediaTypes(List<File> files) {
    return files
        .map((file) => _cloudinaryService.getMediaType(file.path))
        .toList();
  }

  Future<void> createReview(Review review) async {
    await _firestoreService.createReview(review);
  }

  Stream<List<Review>> getReviews() {
    return _firestoreService.getReviews();
  }

  Future<void> toggleLike(String reviewId, String userId) async {
    await _firestoreService.toggleLike(reviewId, userId);
  }

  Future<bool> isLiked(String reviewId, String userId) async {
    return await _firestoreService.isLiked(reviewId, userId);
  }

  Future<void> addComment(String reviewId, ReviewComment comment) async {
    await _firestoreService.addComment(reviewId, comment);
  }

  Stream<List<ReviewComment>> getComments(String reviewId) {
    return _firestoreService.getComments(reviewId);
  }
}