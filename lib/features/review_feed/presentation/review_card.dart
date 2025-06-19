import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:share_plus/share_plus.dart';
import '../../share_review/domain/review.dart';
import '../../share_review/presentation/share_review_viewmodel.dart';
import '../../../core/widgets/rating_stars.dart';
import '../../../core/utils/relative_time.dart';
import '../../../core/utils/date_utils.dart';
import 'media_grid.dart';

class ReviewCard extends ConsumerStatefulWidget {
  final Review review;

  const ReviewCard({super.key, required this.review});

  @override
  ConsumerState<ReviewCard> createState() => _ReviewCardState();
}

class _ReviewCardState extends ConsumerState<ReviewCard> {
  bool _isLiked = false;
  bool _showComments = false;
  final _commentController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _checkIfLiked();
  }

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  void _checkIfLiked() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null && widget.review.id != null) {
      final repository = ref.read(reviewRepositoryProvider);
      final isLiked = await repository.isLiked(widget.review.id!, user.uid);
      setState(() {
        _isLiked = isLiked;
      });
    }
  }

  void _toggleLike() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null || widget.review.id == null) return;

    final repository = ref.read(reviewRepositoryProvider);
    await repository.toggleLike(widget.review.id!, user.uid);
    setState(() {
      _isLiked = !_isLiked;
    });
  }

  void _addComment() async {
    if (_commentController.text.trim().isEmpty) return;

    final user = FirebaseAuth.instance.currentUser;
    if (user == null || widget.review.id == null) return;

    final comment = ReviewComment(
      userId: user.uid,
      userName: user.displayName ?? 'Anonymous',
      text: _commentController.text.trim(),
      createdAt: DateTime.now(),
    );

    final repository = ref.read(reviewRepositoryProvider);
    await repository.addComment(widget.review.id!, comment);
    _commentController.clear();
  }

  void _share() {
    Share.share(
      '${widget.review.authorName} shared a review about ${widget.review.airline} flight from ${widget.review.departure} to ${widget.review.arrival}.\n\n${widget.review.description}',
      subject: 'Flight Review',
    );
  }

  @override
  Widget build(BuildContext context) {
    final review = widget.review;
    final List<String> pillTags = [
      review.departure,
      review.arrival,
      review.airline,
      review.travelClass,
      AppDateUtils.formatTravelDate(review.travelDate),
    ];
    return Card(
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CircleAvatar(
                  backgroundColor: Colors.deepPurple,
                  backgroundImage: null, // TODO: Add user photo if available
                  child: const Icon(Icons.person, color: Colors.white),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(
                            review.authorName,
                            style: const TextStyle(
                                fontWeight: FontWeight.w600, fontSize: 16),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            RelativeTime.getRelativeTime(review.createdAt),
                            style: TextStyle(
                                color: Colors.grey.shade600, fontSize: 12),
                          ),
                        ],
                      ),
                      const SizedBox(height: 2),
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(
                            vertical: 2, horizontal: 0),
                        decoration: BoxDecoration(
                          color: Colors.grey.shade200,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: pillTags
                              .map((tag) => Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 14, vertical: 7),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              tag,
                              style: const TextStyle(
                                fontSize: 14,
                                color: Colors.black,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ))
                              .toList(),
                        ),
                      ),
                    ],
                  ),
                ),
                Column(
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.star, color: Colors.amber, size: 18),
                        const SizedBox(width: 2),
                        Text(
                          review.rating.toStringAsFixed(1),
                          style: const TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 16),
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 12),

            // Review Text
            Text(
              review.description,
              style: const TextStyle(fontSize: 15, height: 1.5),
            ),
            const SizedBox(height: 12),

            // Media Grid
            if (review.mediaUrls.isNotEmpty)
              _ReviewMediaGrid(mediaUrls: review.mediaUrls),
            const SizedBox(height: 12),

            // Actions Row
            Row(
              children: [
                IconButton(
                  icon: Icon(_isLiked ? Icons.favorite : Icons.favorite_border,
                      color: Colors.red),
                  onPressed: _toggleLike,
                ),
                const SizedBox(width: 4),
                Text('${review.likesCount} Like'),
                const SizedBox(width: 16),
                IconButton(
                  icon: const Icon(Icons.comment_outlined),
                  onPressed: () =>
                      setState(() => _showComments = !_showComments),
                ),
                const SizedBox(width: 4),
                Text('${review.commentsCount} Comment'),
                const Spacer(),
                IconButton(
                  icon: const Icon(Icons.share_outlined),
                  onPressed: _share,
                ),
                const Text('Share'),
              ],
            ),

            // Comments Section
            if (_showComments) ...[
              const Divider(),
              StreamBuilder<List<ReviewComment>>(
                stream:
                ref.read(reviewRepositoryProvider).getComments(review.id!),
                builder: (context, snapshot) {
                  if (!snapshot.hasData) return const SizedBox.shrink();
                  final comments = snapshot.data!;
                  return Column(
                    children:
                    comments.map((c) => _CommentTile(comment: c)).toList(),
                  );
                },
              ),
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _commentController,
                        decoration: const InputDecoration(
                          hintText: 'Add a comment...',
                          border: OutlineInputBorder(),
                          isDense: true,
                          contentPadding:
                          EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        ),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.send),
                      onPressed: _addComment,
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _ReviewMediaGrid extends StatelessWidget {
  final List<String> mediaUrls;
  const _ReviewMediaGrid({required this.mediaUrls});

  @override
  Widget build(BuildContext context) {
    final showCount = mediaUrls.length > 4 ? 4 : mediaUrls.length;
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        mainAxisSpacing: 4,
        crossAxisSpacing: 4,
        childAspectRatio: 1,
      ),
      itemCount: showCount,
      itemBuilder: (context, i) {
        if (i == 3 && mediaUrls.length > 4) {
          return Stack(
            fit: StackFit.expand,
            children: [
              _ReviewImage(url: mediaUrls[i]),
              Container(
                color: Colors.black.withOpacity(0.5),
                child: Center(
                  child: Text(
                    '+${mediaUrls.length - 3}',
                    style: const TextStyle(
                        color: Colors.white,
                        fontSize: 24,
                        fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ],
          );
        }
        return _ReviewImage(url: mediaUrls[i]);
      },
    );
  }
}

class _ReviewImage extends StatelessWidget {
  final String url;
  const _ReviewImage({required this.url});

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(8),
      child: Image.network(url, fit: BoxFit.cover),
    );
  }
}

class _CommentTile extends StatelessWidget {
  final ReviewComment comment;
  const _CommentTile({required this.comment});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const CircleAvatar(
            radius: 14,
            backgroundColor: Colors.deepPurple,
            child: Icon(Icons.person, size: 16, color: Colors.white),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  comment.userName,
                  style: const TextStyle(
                      fontWeight: FontWeight.w600, fontSize: 13),
                ),
                Text(
                  RelativeTime.getRelativeTime(comment.createdAt),
                  style: TextStyle(color: Colors.grey.shade600, fontSize: 11),
                ),
                const SizedBox(height: 2),
                Text(comment.text),
              ],
            ),
          ),
        ],
      ),
    );
  }
}