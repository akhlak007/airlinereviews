import 'dart:io';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../domain/review.dart';
import '../data/cloudinary_service.dart';
import '../data/firestore_service.dart';
import '../data/review_repository_impl.dart';
import '../../../core/constants/airport_list.dart';

final cloudinaryServiceProvider = Provider<CloudinaryService>((ref) => CloudinaryService());
final firestoreServiceProvider = Provider<FirestoreService>((ref) => FirestoreService());

final reviewRepositoryProvider = Provider<ReviewRepositoryImpl>((ref) {
  return ReviewRepositoryImpl(
    ref.watch(cloudinaryServiceProvider),
    ref.watch(firestoreServiceProvider),
  );
});

final shareReviewViewModelProvider =
    StateNotifierProvider<ShareReviewViewModel, ShareReviewState>((ref) {
  final repository = ref.watch(reviewRepositoryProvider);
  return ShareReviewViewModel(repository);
});

class ShareReviewState {
  final bool isLoading;
  final String? error;
  final List<File> selectedFiles;
  final Airport? departureAirport;
  final Airport? arrivalAirport;
  final String? airline;
  final String? travelClass;
  final String description;
  final DateTime? travelDate;
  final double rating;

  ShareReviewState({
    this.isLoading = false,
    this.error,
    this.selectedFiles = const [],
    this.departureAirport,
    this.arrivalAirport,
    this.airline,
    this.travelClass,
    this.description = '',
    this.travelDate,
    this.rating = 5.0,
  });

  ShareReviewState copyWith({
    bool? isLoading,
    String? error,
    List<File>? selectedFiles,
    Airport? departureAirport,
    Airport? arrivalAirport,
    String? airline,
    String? travelClass,
    String? description,
    DateTime? travelDate,
    double? rating,
  }) {
    return ShareReviewState(
      isLoading: isLoading ?? this.isLoading,
      error: error,
      selectedFiles: selectedFiles ?? this.selectedFiles,
      departureAirport: departureAirport ?? this.departureAirport,
      arrivalAirport: arrivalAirport ?? this.arrivalAirport,
      airline: airline ?? this.airline,
      travelClass: travelClass ?? this.travelClass,
      description: description ?? this.description,
      travelDate: travelDate ?? this.travelDate,
      rating: rating ?? this.rating,
    );
  }
}

class ShareReviewViewModel extends StateNotifier<ShareReviewState> {
  final ReviewRepositoryImpl _repository;

  ShareReviewViewModel(this._repository) : super(ShareReviewState());

  void addFiles(List<File> files) {
    state = state.copyWith(selectedFiles: [...state.selectedFiles, ...files]);
  }

  void removeFile(int index) {
    final files = List<File>.from(state.selectedFiles);
    files.removeAt(index);
    state = state.copyWith(selectedFiles: files);
  }

  void updateDepartureAirport(Airport? airport) {
    state = state.copyWith(departureAirport: airport);
  }

  void updateArrivalAirport(Airport? airport) {
    state = state.copyWith(arrivalAirport: airport);
  }

  void updateAirline(String? airline) {
    state = state.copyWith(airline: airline);
  }

  void updateTravelClass(String? travelClass) {
    state = state.copyWith(travelClass: travelClass);
  }

  void updateDescription(String description) {
    state = state.copyWith(description: description);
  }

  void updateTravelDate(DateTime? date) {
    state = state.copyWith(travelDate: date);
  }

  void updateRating(double rating) {
    state = state.copyWith(rating: rating);
  }

  Future<bool> submitReview() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return false;

    state = state.copyWith(isLoading: true, error: null);

    try {
      // Upload media files
      final mediaUrls = await _repository.uploadMedia(state.selectedFiles);
      final mediaTypes = _repository.getMediaTypes(state.selectedFiles);

      // Create review
      final review = Review(
        authorId: user.uid,
        authorName: user.displayName ?? 'Anonymous',
        departure: state.departureAirport?.code ?? '',
        arrival: state.arrivalAirport?.code ?? '',
        airline: state.airline ?? '',
        travelClass: state.travelClass ?? '',
        description: state.description,
        travelDate: state.travelDate ?? DateTime.now(),
        rating: state.rating,
        mediaUrls: mediaUrls,
        mediaTypes: mediaTypes,
        createdAt: DateTime.now(),
      );

      await _repository.createReview(review);
      state = state.copyWith(isLoading: false);
      return true;
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
      return false;
    }
  }

  void resetForm() {
    state = ShareReviewState();
  }
}