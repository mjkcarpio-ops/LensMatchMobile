import 'package:flutter/material.dart';
import 'package:phosphoricons_flutter/phosphoricons_flutter.dart';
import '../models/frame_model.dart';
import '../services/frame_service.dart';
import 'frame_detail_view.dart';

class FrameView extends StatefulWidget {
  const FrameView({super.key});

  @override
  State<FrameView> createState() => _FrameViewState();
}

class _FrameViewState extends State<FrameView> {
  final FrameService _frameService = FrameService();
  final TextEditingController _searchController = TextEditingController();

  String _searchQuery = '';
  String _selectedCategory = 'All';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;

    return SafeArea(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header Title
          Padding(
            padding: const EdgeInsets.fromLTRB(24.0, 24.0, 24.0, 16.0),
            child: Text('Frame Catalog', style: textTheme.headlineMedium),
          ),

          // Search Bar
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0),
            child: TextField(
              controller: _searchController,
              onChanged: (value) {
                setState(() {
                  _searchQuery = value;
                });
              },
              style: textTheme.bodyMedium,
              decoration: InputDecoration(
                hintText: 'Search frames or brands...',
                hintStyle: textTheme.bodyMedium?.copyWith(
                  color: colorScheme.onSurfaceVariant.withValues(alpha: 0.6),
                ),
                prefixIcon: Icon(
                  PhosphorIcons.magnifyingGlass,
                  color: colorScheme.onSurfaceVariant,
                  size: 20,
                ),
                suffixIcon: _searchQuery.isNotEmpty
                    ? IconButton(
                        icon: Icon(
                          Icons.clear,
                          color: colorScheme.onSurfaceVariant,
                          size: 20,
                        ),
                        onPressed: () {
                          _searchController.clear();
                          setState(() {
                            _searchQuery = '';
                          });
                        },
                      )
                    : null,
                filled: true,
                fillColor: const Color(0xFF141414),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16.0,
                  vertical: 14.0,
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: Color(0xFF2A2A35)),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: colorScheme.primary),
                ),
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Firestore StreamBuilder for Catalog & Filtering
          Expanded(
            child: StreamBuilder<List<FrameModel>>(
              stream: _frameService.getFramesStream(),
              builder: (context, snapshot) {
                // Loading state
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(
                    child: CircularProgressIndicator(
                      color: colorScheme.primary,
                    ),
                  );
                }

                // Error state
                if (snapshot.hasError) {
                  return Center(
                    child: Padding(
                      padding: const EdgeInsets.all(24.0),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.error_outline,
                            size: 48,
                            color: colorScheme.error,
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'Failed to load catalog',
                            style: textTheme.titleMedium,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Please check your network connection.',
                            style: textTheme.bodySmall?.copyWith(
                              color: colorScheme.onSurfaceVariant,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),
                  );
                }

                final rawFrames = snapshot.data ?? [];

                // Store unique categories dynamically from Firestore data
                final Set<String> uniqueStyles = {};
                for (final f in rawFrames) {
                  if (f.frameStyle.trim().isNotEmpty) {
                    uniqueStyles.add(f.frameStyle.trim());
                  }
                }
                final categories = ['All', ...uniqueStyles.toList()..sort()];

                // 1. Sort frames alphabetically by frameName
                final sortedFrames = List<FrameModel>.from(rawFrames)
                  ..sort((a, b) => a.frameName
                      .toLowerCase()
                      .compareTo(b.frameName.toLowerCase()));

                // 2. Filter by Category
                Iterable<FrameModel> filteredList = sortedFrames;
                if (_selectedCategory != 'All') {
                  filteredList = filteredList.where((f) =>
                      f.frameStyle.trim().toLowerCase() ==
                      _selectedCategory.trim().toLowerCase());
                }

                // 3. Filter by Search Query
                if (_searchQuery.trim().isNotEmpty) {
                  final q = _searchQuery.trim().toLowerCase();
                  filteredList = filteredList.where((f) {
                    final nameMatch = f.frameName.toLowerCase().contains(q);
                    final brandMatch = f.brand.toLowerCase().contains(q);
                    final styleMatch = f.frameStyle.toLowerCase().contains(q);
                    return nameMatch || brandMatch || styleMatch;
                  });
                }

                final displayFrames = filteredList.toList();

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Dynamic Category Filter Chips
                    if (rawFrames.isNotEmpty)
                      SizedBox(
                        height: 38,
                        child: ListView.separated(
                          scrollDirection: Axis.horizontal,
                          padding: const EdgeInsets.symmetric(horizontal: 24.0),
                          itemCount: categories.length,
                          separatorBuilder: (context, index) =>
                              const SizedBox(width: 8),
                          itemBuilder: (context, index) {
                            final category = categories[index];
                            final isSelected = _selectedCategory == category;

                            return ChoiceChip(
                              label: Text(category),
                              selected: isSelected,
                              onSelected: (selected) {
                                if (selected) {
                                  setState(() {
                                    _selectedCategory = category;
                                  });
                                }
                              },
                              labelStyle: textTheme.labelMedium?.copyWith(
                                color: isSelected
                                    ? const Color(0xFF141414)
                                    : colorScheme.onSurface,
                                fontWeight: isSelected
                                    ? FontWeight.bold
                                    : FontWeight.normal,
                              ),
                              selectedColor: colorScheme.primary,
                              backgroundColor: const Color(0xFF141414),
                              side: BorderSide(
                                color: isSelected
                                    ? colorScheme.primary
                                    : const Color(0xFF2A2A35),
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(20),
                              ),
                              showCheckmark: false,
                            );
                          },
                        ),
                      ),
                    const SizedBox(height: 16),

                    // Frames Grid or Empty State
                    Expanded(
                      child: rawFrames.isEmpty
                          ? Center(
                              child: Padding(
                                padding: const EdgeInsets.all(24.0),
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(
                                      PhosphorIcons.eyeglasses,
                                      size: 48,
                                      color: colorScheme.onSurfaceVariant
                                          .withValues(alpha: 0.5),
                                    ),
                                    const SizedBox(height: 16),
                                    Text(
                                      'No frames available',
                                      style: textTheme.titleMedium,
                                    ),
                                    const SizedBox(height: 8),
                                    Text(
                                      'Check back later for new arrivals in our catalog.',
                                      style: textTheme.bodySmall?.copyWith(
                                        color: colorScheme.onSurfaceVariant,
                                      ),
                                      textAlign: TextAlign.center,
                                    ),
                                  ],
                                ),
                              ),
                            )
                          : displayFrames.isEmpty
                              ? Center(
                                  child: Padding(
                                    padding: const EdgeInsets.all(24.0),
                                    child: Column(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Icon(
                                          PhosphorIcons.magnifyingGlass,
                                          size: 48,
                                          color: colorScheme.onSurfaceVariant
                                              .withValues(alpha: 0.5),
                                        ),
                                        const SizedBox(height: 16),
                                        Text(
                                          'No frames found',
                                          style: textTheme.titleMedium,
                                        ),
                                        const SizedBox(height: 8),
                                        Text(
                                          'Try changing your search or selecting another category.',
                                          style: textTheme.bodySmall?.copyWith(
                                            color: colorScheme.onSurfaceVariant,
                                          ),
                                          textAlign: TextAlign.center,
                                        ),
                                      ],
                                    ),
                                  ),
                                )
                              : GridView.builder(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 24.0,
                                    vertical: 8.0,
                                  ),
                                  gridDelegate:
                                      const SliverGridDelegateWithFixedCrossAxisCount(
                                    crossAxisCount: 2,
                                    crossAxisSpacing: 16,
                                    mainAxisSpacing: 16,
                                    childAspectRatio: 0.65,
                                  ),
                                  itemCount: displayFrames.length,
                                  itemBuilder: (context, index) {
                                    final frame = displayFrames[index];
                                    return _buildFrameCard(context, frame);
                                  },
                                ),
                    ),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFrameCard(BuildContext context, FrameModel frame) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    final displayStyle =
        frame.frameStyle.isNotEmpty ? frame.frameStyle : 'Standard';
    final displayBrand = frame.brand.isNotEmpty ? frame.brand : displayStyle;

    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: const BorderSide(color: Color(0xFF2A2A35)),
      ),
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => FrameDetailView(frame: frame),
            ),
          );
        },
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Frame image or fallback icon
              Expanded(
                child: Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: const Color(0xFF0A0A0A),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: frame.imageUrl.isNotEmpty
                        ? Image.network(
                            frame.imageUrl,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) {
                              return Center(
                                child: Icon(
                                  PhosphorIcons.eyeglasses,
                                  size: 48,
                                  color: colorScheme.onSurfaceVariant,
                                ),
                              );
                            },
                            loadingBuilder:
                                (context, child, loadingProgress) {
                              if (loadingProgress == null) return child;
                              return Center(
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: colorScheme.primary,
                                  value: loadingProgress
                                              .expectedTotalBytes !=
                                          null
                                      ? loadingProgress
                                              .cumulativeBytesLoaded /
                                          loadingProgress
                                              .expectedTotalBytes!
                                      : null,
                                ),
                              );
                            },
                          )
                        : Center(
                            child: Icon(
                              PhosphorIcons.eyeglasses,
                              size: 48,
                              color: colorScheme.onSurfaceVariant,
                            ),
                          ),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: colorScheme.primaryContainer,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  displayStyle,
                  style: textTheme.labelSmall
                      ?.copyWith(color: colorScheme.onPrimaryContainer),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                frame.frameName,
                style: textTheme.bodyMedium
                    ?.copyWith(fontWeight: FontWeight.bold),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              Text(
                displayBrand,
                style: textTheme.bodySmall,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 8),
              Text(
                frame.formattedPrice,
                style: textTheme.labelLarge
                    ?.copyWith(color: colorScheme.primary),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
