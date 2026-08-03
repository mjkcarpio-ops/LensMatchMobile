import 'package:flutter/material.dart';
import 'package:phosphoricons_flutter/phosphoricons_flutter.dart';
import 'package:url_launcher/url_launcher.dart';
import '../models/clinic_information_model.dart';
import '../models/reservation_model.dart';
import '../services/clinic_information_service.dart';

class ReservationDetailView extends StatelessWidget {
  final ReservationModel reservation;

  const ReservationDetailView({super.key, required this.reservation});

  String _formatDate(DateTime? date) {
    if (date == null) return 'Recent';
    final months = [
      'January',
      'February',
      'March',
      'April',
      'May',
      'June',
      'July',
      'August',
      'September',
      'October',
      'November',
      'December'
    ];
    return '${months[date.month - 1]} ${date.day}, ${date.year}';
  }

  Future<void> _launchUrl(String urlString) async {
    try {
      final Uri uri = Uri.parse(urlString);
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri);
      }
    } catch (_) {}
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;
    final clinicService = ClinicInformationService();

    // Shortened Reservation ID (first 8 characters prefixed with #)
    final shortId = reservation.reservationId.length > 8
        ? reservation.reservationId.substring(0, 8).toUpperCase()
        : reservation.reservationId.toUpperCase();

    // Status badge color coding and explanation text
    Color statusColor;
    Color statusBgColor;
    String statusMessage;

    final statusUpper = reservation.status.trim().toUpperCase();
    if (statusUpper == 'APPROVED') {
      statusColor = Colors.greenAccent.shade400;
      statusBgColor = Colors.green.withValues(alpha: 0.15);
      statusMessage =
          'Your reservation has been approved!\n\nPlease contact the clinic using the information below so our staff can assist you with the next steps of your reservation.';
    } else if (statusUpper == 'REJECTED') {
      statusColor = Colors.redAccent;
      statusBgColor = Colors.red.withValues(alpha: 0.15);
      statusMessage =
          'Unfortunately, your reservation request was not approved.\n\nPlease contact the clinic if you have questions or would like to reserve a different frame.';
    } else {
      // Pending
      statusColor = colorScheme.primary;
      statusBgColor = colorScheme.primary.withValues(alpha: 0.15);
      statusMessage =
          'Your reservation request has been received.\n\nOur staff is currently reviewing your request. We\'ll update the status once the review is complete.';
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Reservation Details',
          style: textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // -----------------------------------------------------------------
            // SECTION 1: FRAME
            // -----------------------------------------------------------------
            _buildSectionHeader(context, 'FRAME'),
            const SizedBox(height: 12),
            Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
                side: const BorderSide(color: Color(0xFF2A2A35)),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  children: [
                    Container(
                      width: 80,
                      height: 80,
                      decoration: BoxDecoration(
                        color: const Color(0xFF0A0A0A),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: reservation.imageUrl.isNotEmpty
                            ? Image.network(
                                reservation.imageUrl,
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) =>
                                    Icon(
                                  PhosphorIcons.eyeglasses,
                                  size: 40,
                                  color: colorScheme.onSurfaceVariant,
                                ),
                              )
                            : Icon(
                                PhosphorIcons.eyeglasses,
                                size: 40,
                                color: colorScheme.onSurfaceVariant,
                              ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            reservation.frameName,
                            style: textTheme.titleMedium
                                ?.copyWith(fontWeight: FontWeight.bold),
                          ),
                          if (reservation.brand.isNotEmpty) ...[
                            const SizedBox(height: 4),
                            Text(
                              'Brand: ${reservation.brand}',
                              style: textTheme.bodySmall?.copyWith(
                                color: colorScheme.onSurfaceVariant,
                              ),
                            ),
                          ],
                          if (reservation.frameStyle.isNotEmpty) ...[
                            const SizedBox(height: 2),
                            Text(
                              'Style: ${reservation.frameStyle}',
                              style: textTheme.bodySmall?.copyWith(
                                color: colorScheme.onSurfaceVariant,
                              ),
                            ),
                          ],
                          if (reservation.price > 0) ...[
                            const SizedBox(height: 6),
                            Text(
                              reservation.formattedPrice,
                              style: textTheme.bodyMedium?.copyWith(
                                color: colorScheme.primary,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 28),

            // -----------------------------------------------------------------
            // SECTION 2: STATUS
            // -----------------------------------------------------------------
            _buildSectionHeader(context, 'STATUS'),
            const SizedBox(height: 12),
            Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
                side: const BorderSide(color: Color(0xFF2A2A35)),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Status Badge & ID Row
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: statusBgColor,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                                color: statusColor.withValues(alpha: 0.4)),
                          ),
                          child: Text(
                            reservation.status,
                            style: textTheme.labelMedium?.copyWith(
                              color: statusColor,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        Text(
                          '#$shortId',
                          style: textTheme.bodyMedium?.copyWith(
                            color: colorScheme.onSurfaceVariant,
                            fontFamily: 'monospace',
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),

                    // Timestamps with icons
                    _buildInfoRowWithIcon(
                      context,
                      PhosphorIcons.calendarBlank,
                      'Requested',
                      _formatDate(reservation.createdAt),
                    ),
                    if (reservation.statusUpdatedAt != null) ...[
                      const SizedBox(height: 6),
                      _buildInfoRowWithIcon(
                        context,
                        PhosphorIcons.clockAfternoon,
                        'Updated',
                        _formatDate(reservation.statusUpdatedAt),
                      ),
                    ],

                    const Divider(color: Color(0xFF2A2A35), height: 24),

                    // Status Explanation Message
                    Text(
                      statusMessage,
                      style: textTheme.bodyMedium?.copyWith(
                        height: 1.5,
                        color: colorScheme.onSurface,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 28),

            // -----------------------------------------------------------------
            // SECTION 3: CLINIC INFORMATION (Loaded via FutureBuilder)
            // -----------------------------------------------------------------
            _buildSectionHeader(context, 'CLINIC INFORMATION'),
            const SizedBox(height: 12),
            FutureBuilder<ClinicInformationModel?>(
              future: clinicService.getClinicInformation(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Card(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                      side: const BorderSide(color: Color(0xFF2A2A35)),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(32.0),
                      child: Center(
                        child: CircularProgressIndicator(
                          color: colorScheme.primary,
                        ),
                      ),
                    ),
                  );
                }

                final clinicInfo = snapshot.data;
                final String clinicName =
                    clinicInfo?.clinicName.isNotEmpty == true
                        ? clinicInfo!.clinicName
                        : 'Franselle Optical Clinic';
                final String phone = clinicInfo?.contactNumber ?? '';
                final String email = clinicInfo?.email ?? '';
                final String rawAddress = clinicInfo?.address ?? '';
                final String hours = clinicInfo?.businessHours ?? '';
                final String instructions =
                    clinicInfo?.reservationInstructions ?? '';

                // Format multi-line address if commas exist
                final String formattedAddress = rawAddress.contains(',')
                    ? rawAddress
                        .split(',')
                        .map((s) => s.trim())
                        .where((s) => s.isNotEmpty)
                        .join('\n')
                    : rawAddress;

                return Card(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                    side: const BorderSide(color: Color(0xFF2A2A35)),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          clinicName,
                          style: textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: colorScheme.primary,
                          ),
                        ),
                        const SizedBox(height: 12),

                        // Phone (Tappable)
                        if (phone.isNotEmpty)
                          _buildInteractiveContactRow(
                            context: context,
                            icon: PhosphorIcons.phoneCall,
                            label: 'Phone',
                            value: phone,
                            onTap: () => _launchUrl('tel:$phone'),
                          ),

                        // Email (Tappable)
                        if (email.isNotEmpty)
                          _buildInteractiveContactRow(
                            context: context,
                            icon: PhosphorIcons.envelopeSimple,
                            label: 'Email',
                            value: email,
                            onTap: () => _launchUrl('mailto:$email'),
                          ),

                        // Address (Formatted Multi-line)
                        if (formattedAddress.isNotEmpty)
                          _buildContactRow(
                            context: context,
                            icon: PhosphorIcons.mapPin,
                            label: 'Address',
                            value: formattedAddress,
                          ),

                        // Business Hours
                        if (hours.isNotEmpty)
                          _buildContactRow(
                            context: context,
                            icon: PhosphorIcons.clock,
                            label: 'Business Hours',
                            value: hours,
                          ),

                        // Special Reservation Instructions
                        if (instructions.isNotEmpty) ...[
                          const Divider(color: Color(0xFF2A2A35), height: 24),
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: colorScheme.primary.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(
                                color:
                                    colorScheme.primary.withValues(alpha: 0.3),
                              ),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Special Instructions',
                                  style: textTheme.labelMedium?.copyWith(
                                    color: colorScheme.primary,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  instructions,
                                  style: textTheme.bodySmall?.copyWith(
                                    height: 1.4,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                );
              },
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(BuildContext context, String title) {
    return Text(
      title,
      style: Theme.of(context).textTheme.labelMedium?.copyWith(
            letterSpacing: 1.2,
            fontWeight: FontWeight.bold,
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
    );
  }

  Widget _buildInfoRowWithIcon(
      BuildContext context, IconData icon, String label, String value) {
    final colorScheme = Theme.of(context).colorScheme;

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            Icon(icon, size: 16, color: colorScheme.onSurfaceVariant),
            const SizedBox(width: 8),
            Text(
              label,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                  ),
            ),
          ],
        ),
        Text(
          value,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
        ),
      ],
    );
  }

  Widget _buildInteractiveContactRow({
    required BuildContext context,
    required IconData icon,
    required String label,
    required String value,
    required VoidCallback onTap,
  }) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6.0),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: const EdgeInsets.all(4.0),
          child: Row(
            children: [
              Icon(icon, size: 20, color: colorScheme.primary),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      label,
                      style: textTheme.labelSmall?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ),
                    Text(
                      value,
                      style: textTheme.bodyMedium?.copyWith(
                        color: colorScheme.primary,
                        fontWeight: FontWeight.w600,
                        decoration: TextDecoration.underline,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.arrow_outward,
                size: 16,
                color: colorScheme.primary.withValues(alpha: 0.7),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildContactRow({
    required BuildContext context,
    required IconData icon,
    required String label,
    required String value,
  }) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 20, color: colorScheme.onSurfaceVariant),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: textTheme.labelSmall?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),
                Text(
                  value,
                  style: textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                    height: 1.3,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
