import 'package:cloud_firestore/cloud_firestore.dart';
import '../domain/review.dart';

class FirestoreService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> createReview(Review review) async {
    await _firestore.collection('reviews').add(review.toFirestore());
  }

  Stream<List<Review>> getReviews() {
    return _firestore
        .collection('reviews')
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) =>
            snapshot.docs.map((doc) => Review.fromFirestore(doc)).toList());
  }

  Future<void> toggleLike(String reviewId, String userId) async {
    final reviewRef = _firestore.collection('reviews').doc(reviewId);
    final likeRef = reviewRef.collection('likes').doc(userId);

    await _firestore.runTransaction((transaction) async {
      final likeDoc = await transaction.get(likeRef);
      final reviewDoc = await transaction.get(reviewRef);

      if (likeDoc.exists) {
        // Unlike
        transaction.delete(likeRef);
        transaction.update(reviewRef, {
          'likesCount': FieldValue.increment(-1),
        });
      } else {
        // Like
        transaction.set(likeRef, {'userId': userId});
        transaction.update(reviewRef, {
          'likesCount': FieldValue.increment(1),
        });
      }
    });
  }

  Future<bool> isLiked(String reviewId, String userId) async {
    final likeDoc = await _firestore
        .collection('reviews')
        .doc(reviewId)
        .collection('likes')
        .doc(userId)
        .get();
    return likeDoc.exists;
  }

  Future<void> addComment(String reviewId, ReviewComment comment) async {
    final reviewRef = _firestore.collection('reviews').doc(reviewId);

    await _firestore.runTransaction((transaction) async {
      transaction.set(
        reviewRef.collection('comments').doc(),
        comment.toFirestore(),
      );
      transaction.update(reviewRef, {
        'commentsCount': FieldValue.increment(1),
      });
    });
  }

  Stream<List<ReviewComment>> getComments(String reviewId) {
    return _firestore
        .collection('reviews')
        .doc(reviewId)
        .collection('comments')
        .orderBy('createdAt', descending: false)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => ReviewComment.fromFirestore(doc))
            .toList());
  }
}