import 'package:flutter/material.dart';
import 'package:phosphoricons_flutter/phosphoricons_flutter.dart';
import '../models/frame_model.dart';
import '../services/reservation_service.dart';

class FrameDetailView extends StatefulWidget {
  final FrameModel frame;

  const FrameDetailView({super.key, required this.frame});

  @override
  State<FrameDetailView> createState() => _FrameDetailViewState();
}

class _FrameDetailViewState extends State<FrameDetailView> {
  final ReservationService _reservationService = ReservationService();
  bool _isReserving = false;

  Future<void> _handleReserve() async {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    // Show informative confirmation dialog
    final bool? confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(color: Color(0xFF2A2A35)),
        ),
        backgroundColor: const Color(0xFF141414),
        title: Text(
          'Reserve Frame',
          style: textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'You are about to submit a reservation request for:',
              style: textTheme.bodyMedium?.copyWith(
                color: colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 12),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFF1F1F28),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: colorScheme.primary.withValues(alpha: 0.3),
                ),
              ),
              child: Text(
                widget.frame.frameName,
                style: textTheme.titleMedium?.copyWith(
                  color: colorScheme.primary,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'Your reservation will be reviewed by the clinic staff.',
              style: textTheme.bodySmall?.copyWith(
                color: colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: Text(
              'Cancel',
              style: textTheme.labelLarge?.copyWith(
                color: colorScheme.onSurfaceVariant,
              ),
            ),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: colorScheme.primary,
              foregroundColor: const Color(0xFF141414),
            ),
            child: const Text(
              'Reserve',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    setState(() {
      _isReserving = true;
    });

    try {
      await _reservationService.createReservation(widget.frame);

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            '${widget.frame.frameName} reservation request submitted!',
          ),
          backgroundColor: colorScheme.primary,
          behavior: SnackBarBehavior.floating,
        ),
      );

      Navigator.pop(context);
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(e.toString()),
          backgroundColor: colorScheme.error,
          behavior: SnackBarBehavior.floating,
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isReserving = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;

    final displayStyle =
        widget.frame.frameStyle.isNotEmpty ? widget.frame.frameStyle : 'Standard';
    final displayBrand =
        widget.frame.brand.isNotEmpty ? widget.frame.brand : 'LensMatch';
    final displayDescription = widget.frame.description.isNotEmpty
        ? widget.frame.description
        : 'Elevate your look with the ${widget.frame.frameName}. Crafted with quality, these frames offer a perfect blend of durability and luxury style. Ideal for all-day comfort.';

    final bool isAvailable = widget.frame.availability;

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Big image container or fallback icon
            Container(
              height: 400,
              width: double.infinity,
              decoration: const BoxDecoration(
                color: Color(0xFF0A0A0A),
              ),
              child: SafeArea(
                child: Center(
                  child: widget.frame.imageUrl.isNotEmpty
                      ? Image.network(
                          widget.frame.imageUrl,
                          fit: BoxFit.contain,
                          errorBuilder: (context, error, stackTrace) {
                            return Icon(
                              PhosphorIcons.eyeglasses,
                              size: 120,
                              color: colorScheme.primary.withValues(alpha: 0.5),
                            );
                          },
                          loadingBuilder: (context, child, loadingProgress) {
                            if (loadingProgress == null) return child;
                            return Center(
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: colorScheme.primary,
                                value: loadingProgress.expectedTotalBytes !=
                                        null
                                    ? loadingProgress.cumulativeBytesLoaded /
                                        loadingProgress.expectedTotalBytes!
                                    : null,
                              ),
                            );
                          },
                        )
                      : Icon(
                          PhosphorIcons.eyeglasses,
                          size: 120,
                          color: colorScheme.primary.withValues(alpha: 0.5),
                        ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(widget.frame.frameName, style: textTheme.headlineMedium),
                            const SizedBox(height: 8),
                            Text(widget.frame.formattedPrice,
                                style: textTheme.headlineSmall?.copyWith(
                                    color: colorScheme.primary)),
                          ],
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: colorScheme.primary.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                              color: colorScheme.primary.withValues(alpha: 0.2)),
                        ),
                        child: Text(displayStyle,
                            style: textTheme.labelMedium?.copyWith(
                                color: colorScheme.primary)),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  Text('Details', style: textTheme.titleLarge),
                  const SizedBox(height: 12),
                  _buildDetailRow(context, 'Brand', displayBrand),
                  _buildDetailRow(context, 'Style', displayStyle),
                  _buildDetailRow(
                      context, 'Status', isAvailable ? 'In Stock' : 'Out of Stock'),
                  const SizedBox(height: 32),
                  Text('Description', style: textTheme.titleLarge),
                  const SizedBox(height: 12),
                  Text(
                    displayDescription,
                    style: textTheme.bodyMedium?.copyWith(height: 1.5),
                  ),
                  const SizedBox(height: 40),
                ],
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.all(24.0),
        decoration: BoxDecoration(
          color: colorScheme.surface,
          border: const Border(top: BorderSide(color: Color(0xFF2A2A35))),
        ),
        child: SafeArea(
          child: SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: (!isAvailable || _isReserving)
                  ? null
                  : () => _handleReserve(),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                disabledBackgroundColor:
                    colorScheme.surface.withValues(alpha: 0.5),
              ),
              child: _isReserving
                  ? Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: colorScheme.onSurfaceVariant,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Text(
                          'Reserving...',
                          style: textTheme.titleMedium?.copyWith(
                            color: colorScheme.onSurfaceVariant,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    )
                  : Text(
                      !isAvailable ? 'Out of Stock' : 'Reserve Now',
                      style: textTheme.titleMedium?.copyWith(
                        color: !isAvailable
                            ? colorScheme.onSurfaceVariant
                            : const Color(0xFF141414),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDetailRow(BuildContext context, String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant)),
          Text(value,
              style: Theme.of(context)
                  .textTheme
                  .bodyMedium
                  ?.copyWith(fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }
}
