import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../share_review/domain/review.dart';
import '../../share_review/presentation/share_review_screen.dart';
import '../../share_review/presentation/share_review_viewmodel.dart';
import '../../auth/presentation/auth_viewmodel.dart';
import 'review_card.dart';

final reviewsStreamProvider = StreamProvider<List<Review>>((ref) {
  final repository = ref.watch(reviewRepositoryProvider);
  return repository.getReviews();
});

class ReviewFeedScreen extends ConsumerWidget {
  const ReviewFeedScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final reviewsAsync = ref.watch(reviewsStreamProvider);
    final user = FirebaseAuth.instance.currentUser;

    // Local asset images replacing network URLs
    final imageAssets = [
      'assets/images/carousel1.jpg',
      'assets/images/carousel2.jpg',
      'assets/images/carousel3.jpg',
    ];

    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        title: const Text('Airline Review'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_outlined),
            onPressed: () {},
          ),
          GestureDetector(
            onTap: () => showModalBottomSheet(
              context: context,
              builder: (ctx) => SafeArea(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    ListTile(
                      leading: CircleAvatar(
                        backgroundImage: user?.photoURL != null
                            ? NetworkImage(user!.photoURL!)
                            : null,
                        child: user?.photoURL == null
                            ? const Icon(Icons.person)
                            : null,
                      ),
                      title: Text(user?.displayName ?? 'User'),
                      subtitle: Text(user?.email ?? ''),
                    ),
                    const Divider(),
                    ListTile(
                      leading: const Icon(Icons.logout),
                      title: const Text('Sign Out'),
                      onTap: () {
                        Navigator.pop(ctx);
                        ref.read(authViewModelProvider.notifier).signOut();
                      },
                    ),
                  ],
                ),
              ),
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: CircleAvatar(
                backgroundColor: Colors.deepPurple,
                backgroundImage: user?.photoURL != null
                    ? NetworkImage(user!.photoURL!)
                    : null,
                child: user?.photoURL == null
                    ? const Icon(Icons.person, color: Colors.white)
                    : null,
              ),
            ),
          ),
        ],
      ),
      body: reviewsAsync.when(
        data: (reviews) {
          return ListView.separated(
            padding: EdgeInsets.zero,
            separatorBuilder: (context, index) => const SizedBox(height: 16),
            itemCount: (reviews.isEmpty ? 2 : reviews.length + 1),
            itemBuilder: (context, index) {
              if (index == 0) {
                // Top section
                return Container(
                  color: Colors.white,
                  padding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  child: Column(
                    children: [
                      // 1) Two pill‑shaped buttons
                      Row(
                        children: [
                          Expanded(
                            child: ElevatedButton.icon(
                              onPressed: () => Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (_) => const ShareReviewScreen()),
                              ),
                              icon: const Icon(Icons.share, size: 18),
                              label: const Text('Share Your Experience'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.black,
                                foregroundColor: Colors.white,
                                padding:
                                const EdgeInsets.symmetric(vertical: 14),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(30),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: ElevatedButton.icon(
                              onPressed: () {},
                              icon: const Icon(Icons.help_outline, size: 18),
                              label: const Text('Ask A Question'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.black,
                                foregroundColor: Colors.white,
                                padding:
                                const EdgeInsets.symmetric(vertical: 14),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(30),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      // 2) Black search bar
                      Center(
                        child: TextField(
                          decoration: InputDecoration(
                            hintText: 'Search',
                            hintStyle: const TextStyle(color: Colors.white70),
                            prefixIcon:
                            const Icon(Icons.search, color: Colors.white70),
                            filled: true,
                            fillColor: Colors.black,
                            contentPadding:
                            const EdgeInsets.symmetric(vertical: 14),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(30),
                              borderSide: BorderSide.none,
                            ),
                          ),
                          style: const TextStyle(color: Colors.white),
                        ),
                      ),
                      const SizedBox(height: 16),
                      // 3) Image carousel (local assets)
                      CarouselSlider(
                        items: imageAssets.map((path) {
                          return ClipRRect(
                            borderRadius: BorderRadius.circular(12),
                            child: Image.asset(
                              path,
                              width: double.infinity,
                              fit: BoxFit.cover,
                            ),
                          );
                        }).toList(),
                        options: CarouselOptions(
                          height: 160,
                          autoPlay: true,
                          autoPlayInterval: const Duration(seconds: 3),
                          enlargeCenterPage: true,
                          viewportFraction: 0.9,
                        ),
                      ),
                    ],
                  ),
                );
              } else if (reviews.isEmpty) {
                // No reviews yet
                return Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: const [
                      Icon(Icons.flight_takeoff, size: 72, color: Colors.grey),
                      SizedBox(height: 20),
                      Text('No reviews yet',
                          style: TextStyle(fontSize: 20, color: Colors.grey)),
                      SizedBox(height: 10),
                      Text('Be the first to share your travel story!',
                          style: TextStyle(color: Colors.grey)),
                    ],
                  ),
                );
              } else {
                // Review cards
                final review = reviews[index - 1];
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: ReviewCard(review: review),
                );
              }
            },
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.error_outline,
                  size: 64, color: Colors.redAccent),
              const SizedBox(height: 18),
              Text('Oops! Something went wrong.',
                  style: TextStyle(fontSize: 18, color: Colors.red.shade700),
                  textAlign: TextAlign.center),
            ],
          ),
        ),
      ),
    );
  }
}
