import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:file_picker/file_picker.dart';
import 'share_review_viewmodel.dart';
import '../../../core/widgets/airport_dropdown.dart';
import '../../../core/widgets/rating_stars.dart';
import '../../../core/widgets/media_preview.dart';
import '../../../core/constants/class_options.dart';

// Airlines list for dropdown
static const List<Map<String, String>> airlines = [
  {'name': 'Air Bangladesh', 'country': 'Bangladesh', 'code': 'B9'},
  {'name': 'Biman Bangladesh Airlines', 'country': 'Bangladesh', 'code': 'BG'},
  {'name': 'Bismillah Airlines', 'country': 'Bangladesh', 'code': '5Z'},
  {'name': 'United Airways', 'country': 'Bangladesh', 'code': '4H'},
];

class ShareReviewScreen extends ConsumerStatefulWidget {
  const ShareReviewScreen({super.key});

  @override
  ConsumerState<ShareReviewScreen> createState() => _ShareReviewScreenState();
}

class _ShareReviewScreenState extends ConsumerState<ShareReviewScreen> {
  final _descriptionController = TextEditingController();
  final _airlineController = TextEditingController();

  @override
  void dispose() {
    _descriptionController.dispose();
    _airlineController.dispose();
    super.dispose();
  }

  Future<void> _pickMedia() async {
    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.photo_library),
              title: const Text('Pick Images'),
              onTap: () async {
                Navigator.pop(context);
                final ImagePicker picker = ImagePicker();
                final List<XFile> images = await picker.pickMultiImage();
                if (images.isNotEmpty) {
                  final files =
                      images.map((image) => File(image.path)).toList();
                  ref
                      .read(shareReviewViewModelProvider.notifier)
                      .addFiles(files);
                }
              },
            ),
            ListTile(
              leading: const Icon(Icons.videocam),
              title: const Text('Pick Video'),
              onTap: () async {
                Navigator.pop(context);
                final result = await FilePicker.platform.pickFiles(
                  type: FileType.video,
                );
                if (result != null && result.files.single.path != null) {
                  final file = File(result.files.single.path!);
                  ref
                      .read(shareReviewViewModelProvider.notifier)
                      .addFiles([file]);
                }
              },
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _selectDate() async {
    final date = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
    );
    if (date != null) {
      ref.read(shareReviewViewModelProvider.notifier).updateTravelDate(date);
    }
  }

  void _submit() async {
    final success =
        await ref.read(shareReviewViewModelProvider.notifier).submitReview();
    if (success && mounted) {
      ref.read(shareReviewViewModelProvider.notifier).resetForm();
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Review shared successfully!')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(shareReviewViewModelProvider);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Share'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Media Upload Section
            GestureDetector(
              onTap: _pickMedia,
              child: Container(
                height: 120,
                decoration: BoxDecoration(
                  border: Border.all(
                      color: Colors.grey.shade300, style: BorderStyle.solid),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: state.selectedFiles.isEmpty
                    ? const Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.file_upload_outlined,
                              size: 40, color: Colors.grey),
                          SizedBox(height: 8),
                          Text('Drop Your Image Here Or Browse',
                              style: TextStyle(color: Colors.grey)),
                        ],
                      )
                    : SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        padding: const EdgeInsets.all(10),
                        child: Row(
                          children:
                              state.selectedFiles.asMap().entries.map((entry) {
                            final index = entry.key;
                            final file = entry.value;
                            final isVideo =
                                file.path.toLowerCase().endsWith('.mp4') ||
                                    file.path.toLowerCase().endsWith('.mov');

                            return Padding(
                              padding: const EdgeInsets.only(right: 8),
                              child: MediaPreview(
                                filePath: file.path,
                                isVideo: isVideo,
                                onRemove: () => ref
                                    .read(shareReviewViewModelProvider.notifier)
                                    .removeFile(index),
                              ),
                            );
                          }).toList(),
                        ),
                      ),
              ),
            ),
            const SizedBox(height: 20),

            // Departure Airport
            AirportDropdown(
              selectedAirport: state.departureAirport,
              hintText: 'Departure Airport',
              onChanged: (airport) => ref
                  .read(shareReviewViewModelProvider.notifier)
                  .updateDepartureAirport(airport),
            ),
            const SizedBox(height: 16),

            // Arrival Airport
            AirportDropdown(
              selectedAirport: state.arrivalAirport,
              hintText: 'Arrival Airport',
              onChanged: (airport) => ref
                  .read(shareReviewViewModelProvider.notifier)
                  .updateArrivalAirport(airport),
            ),
            const SizedBox(height: 16),

            // Airline
            DropdownButtonFormField<String>(
              value: state.airline,
              decoration: InputDecoration(
                hintText: 'Airline',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide(color: Colors.grey.shade300),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide(color: Colors.grey.shade300),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: const BorderSide(color: Colors.deepPurple),
                ),
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              ),
              items: airlines.map((airline) {
                return DropdownMenuItem<String>(
                  value: airline['code'],
                  child: Text('${airline['name']} (${airline['code']})'),
                );
              }).toList(),
              onChanged: (value) => ref
                  .read(shareReviewViewModelProvider.notifier)
                  .updateAirline(value),
            ),
            const SizedBox(height: 16),

            // Travel Class
            DropdownButtonFormField<String>(
              value: state.travelClass,
              decoration: InputDecoration(
                hintText: 'Class',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide(color: Colors.grey.shade300),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide(color: Colors.grey.shade300),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: const BorderSide(color: Colors.deepPurple),
                ),
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              ),
              items: TravelClass.options.map((classType) {
                return DropdownMenuItem(
                  value: classType,
                  child: Text(classType),
                );
              }).toList(),
              onChanged: (value) => ref
                  .read(shareReviewViewModelProvider.notifier)
                  .updateTravelClass(value),
            ),
            const SizedBox(height: 16),

            // Description
            TextFormField(
              controller: _descriptionController,
              maxLines: 4,
              decoration: InputDecoration(
                hintText: 'Write your message...',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide(color: Colors.grey.shade300),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide(color: Colors.grey.shade300),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: const BorderSide(color: Colors.deepPurple),
                ),
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              ),
              onChanged: (value) => ref
                  .read(shareReviewViewModelProvider.notifier)
                  .updateDescription(value),
            ),
            const SizedBox(height: 20),

            // Travel Date and Rating Row
            Row(
              children: [
                Expanded(
                  child: GestureDetector(
                    onTap: _selectDate,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 14),
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey.shade300),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.calendar_today,
                              size: 20, color: Colors.grey),
                          const SizedBox(width: 8),
                          Text(
                            state.travelDate != null
                                ? '${state.travelDate!.day}/${state.travelDate!.month}/${state.travelDate!.year}'
                                : 'Travel Date',
                            style: TextStyle(
                              color: state.travelDate != null
                                  ? Colors.black
                                  : Colors.grey,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Rating',
                        style: TextStyle(fontWeight: FontWeight.w500)),
                    const SizedBox(height: 4),
                    RatingStars(
                      rating: state.rating,
                      size: 24,
                      isInteractive: true,
                      onRatingUpdate: (rating) => ref
                          .read(shareReviewViewModelProvider.notifier)
                          .updateRating(rating),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 24),

            if (state.error != null)
              Container(
                padding: const EdgeInsets.all(12),
                margin: const EdgeInsets.only(bottom: 16),
                decoration: BoxDecoration(
                  color: Colors.red.shade50,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.red.shade200),
                ),
                child: Text(
                  state.error!,
                  style: TextStyle(color: Colors.red.shade700),
                ),
              ),

            // Submit Button
            ElevatedButton(
              onPressed: state.isLoading ? null : _submit,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.black,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: state.isLoading
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    )
                  : const Text(
                      'Submit',
                      style:
                          TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
