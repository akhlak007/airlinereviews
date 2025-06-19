import 'package:cloud_firestore/cloud_firestore.dart';

class Review {
  final String? id;
  final String authorId;
  final String authorName;
  final String departure;
  final String arrival;
  final String airline;
  final String travelClass;
  final String description;
  final DateTime travelDate;
  final double rating;
  final List<String> mediaUrls;
  final List<String> mediaTypes;
  final DateTime createdAt;
  final int likesCount;
  final int commentsCount;

  Review({
    this.id,
    required this.authorId,
    required this.authorName,
    required this.departure,
    required this.arrival,
    required this.airline,
    required this.travelClass,
    required this.description,
    required this.travelDate,
    required this.rating,
    required this.mediaUrls,
    required this.mediaTypes,
    required this.createdAt,
    this.likesCount = 0,
    this.commentsCount = 0,
  });

  factory Review.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return Review(
      id: doc.id,
      authorId: data['authorId'] ?? '',
      authorName: data['authorName'] ?? '',
      departure: data['departure'] ?? '',
      arrival: data['arrival'] ?? '',
      airline: data['airline'] ?? '',
      travelClass: data['travelClass'] ?? '',
      description: data['description'] ?? '',
      travelDate: (data['travelDate'] as Timestamp).toDate(),
      rating: (data['rating'] ?? 0).toDouble(),
      mediaUrls: List<String>.from(data['mediaUrls'] ?? []),
      mediaTypes: List<String>.from(data['mediaTypes'] ?? []),
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      likesCount: data['likesCount'] ?? 0,
      commentsCount: data['commentsCount'] ?? 0,
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'authorId': authorId,
      'authorName': authorName,
      'departure': departure,
      'arrival': arrival,
      'airline': airline,
      'travelClass': travelClass,
      'description': description,
      'travelDate': Timestamp.fromDate(travelDate),
      'rating': rating,
      'mediaUrls': mediaUrls,
      'mediaTypes': mediaTypes,
      'createdAt': FieldValue.serverTimestamp(),
      'likesCount': likesCount,
      'commentsCount': commentsCount,
    };
  }
}

class ReviewComment {
  final String? id;
  final String userId;
  final String userName;
  final String text;
  final DateTime createdAt;

  ReviewComment({
    this.id,
    required this.userId,
    required this.userName,
    required this.text,
    required this.createdAt,
  });

  factory ReviewComment.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return ReviewComment(
      id: doc.id,
      userId: data['userId'] ?? '',
      userName: data['userName'] ?? '',
      text: data['text'] ?? '',
      createdAt: (data['createdAt'] as Timestamp).toDate(),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'userId': userId,
      'userName': userName,
      'text': text,
      'createdAt': FieldValue.serverTimestamp(),
    };
  }
}