import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme.dart';
import '../admin_models.dart';
import '../admin_state.dart';
import '../../../widgets/inner_screen_header.dart';
import 'admin_booking_detail_screen.dart';

class AdminBookingsScreen extends ConsumerStatefulWidget {
  const AdminBookingsScreen({super.key});

  @override
  ConsumerState<AdminBookingsScreen> createState() => _AdminBookingsScreenState();
}

class _AdminBookingsScreenState extends ConsumerState<AdminBookingsScreen> {
  final _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final state = ref.watch(adminControllerProvider);

    final filteredBookings = state.bookings.where((b) {
      if (state.searchQuery.isEmpty) return true;
      final q = state.searchQuery.toLowerCase();
      return b.reference.toLowerCase().contains(q) ||
          b.customerName.toLowerCase().contains(q) ||
          b.pickupAddress.toLowerCase().contains(q) ||
          b.destinationAddress.toLowerCase().contains(q);
    }).toList();

    return Scaffold(
      backgroundColor: colors.surface,
      appBar: InnerScreenHeader(
        title: 'Bookings',
        showBack: false,
        background: InnerScreenHeader.midnightBackground(),
      ),
      body: SafeArea(
        top: false,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(18, 8, 18, 24),
          children: [
            // Subtitle
            Text(
              'Track journeys, manage driver allocations, passenger schedules, and booking lifecycles.',
              style: TextStyle(
                fontSize: 13,
                color: colors.inkMuted,
                height: 1.3,
              ),
            ),
            const SizedBox(height: 14),

                  // Search Bar
                  Container(
                    decoration: BoxDecoration(
                      color: colors.card,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: colors.inkFaint),
                    ),
                    child: TextField(
                      controller: _searchController,
                      onChanged: (v) {
                        ref.read(adminControllerProvider.notifier).setSearchQuery(v);
                      },
                      decoration: InputDecoration(
                        hintText: 'Search bookings...',
                        hintStyle: TextStyle(
                          fontSize: 14,
                          color: colors.inkMuted,
                        ),
                        prefixIcon: Icon(
                          Icons.search_rounded,
                          size: 20,
                          color: colors.inkMuted,
                        ),
                        suffixIcon: IconButton(
                          icon: Icon(
                            Icons.tune_rounded,
                            size: 19,
                            color: colors.inkMuted,
                          ),
                          onPressed: () {},
                        ),
                        border: InputBorder.none,
                        enabledBorder: InputBorder.none,
                        focusedBorder: InputBorder.none,
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 13,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),

                  // Filter Chips Row
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: [
                        // All Bookings Chip (Active)
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
                          decoration: BoxDecoration(
                            color: const Color(0xFF3B82F6).withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(999),
                            border: Border.all(color: const Color(0xFF3B82F6)),
                          ),
                          child: const Text(
                            'All Bookings (28)',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF2563EB),
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        // All Sources Dropdown
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
                          decoration: BoxDecoration(
                            color: colors.card,
                            borderRadius: BorderRadius.circular(999),
                            border: Border.all(color: colors.inkFaint),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                'All Sources',
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w500,
                                  color: colors.ink,
                                ),
                              ),
                              const SizedBox(width: 4),
                              Icon(Icons.keyboard_arrow_down_rounded, size: 16, color: colors.inkMuted),
                            ],
                          ),
                        ),
                        const SizedBox(width: 8),
                        // All Dates Dropdown
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
                          decoration: BoxDecoration(
                            color: colors.card,
                            borderRadius: BorderRadius.circular(999),
                            border: Border.all(color: colors.inkFaint),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.calendar_today_outlined, size: 13, color: colors.inkMuted),
                              const SizedBox(width: 6),
                              Text(
                                'All dates',
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w500,
                                  color: colors.ink,
                                ),
                              ),
                              const SizedBox(width: 4),
                              Icon(Icons.keyboard_arrow_down_rounded, size: 16, color: colors.inkMuted),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),

                  // 3 Summary Counts Row
                  Container(
                    padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 14),
                    decoration: BoxDecoration(
                      color: colors.card,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: colors.inkFaint),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                '28',
                                style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.w800,
                                  color: colors.ink,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                'Total Bookings',
                                style: TextStyle(
                                  fontSize: 11,
                                  color: colors.inkMuted,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Container(width: 1, height: 32, color: colors.inkFaint),
                        Expanded(
                          child: Padding(
                            padding: const EdgeInsets.only(left: 12),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  '21',
                                  style: TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.w800,
                                    color: Color(0xFFF59E0B),
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  'Awaiting Confirmation',
                                  style: TextStyle(
                                    fontSize: 11,
                                    color: colors.inkMuted,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        Container(width: 1, height: 32, color: colors.inkFaint),
                        Expanded(
                          child: Padding(
                            padding: const EdgeInsets.only(left: 12),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  '1',
                                  style: TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.w800,
                                    color: Color(0xFF10B981),
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  'Completed',
                                  style: TextStyle(
                                    fontSize: 11,
                                    color: colors.inkMuted,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 14),

                  // Range / Pagination Row
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '1-${filteredBookings.length} of 28',
                        style: TextStyle(
                          fontSize: 12.5,
                          color: colors.inkMuted,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      Row(
                        children: [
                          Icon(Icons.chevron_left_rounded, size: 20, color: colors.inkMuted),
                          const SizedBox(width: 8),
                          Icon(Icons.chevron_right_rounded, size: 20, color: colors.ink),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),

                  // Bookings List Items
                  ...filteredBookings.map((b) => _BookingCard(booking: b)),
                ],
              ),
            ),
          );
  }
}

class _BookingCard extends StatelessWidget {
  const _BookingCard({required this.booking});

  final AdminBooking booking;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final initials = booking.customerName.trim().split(' ').map((e) => e.isNotEmpty ? e[0] : '').take(2).join().toUpperCase();

    final isAwaiting = booking.status == 'Awaiting Payment';
    final statusColor = isAwaiting
        ? const Color(0xFFF59E0B)
        : (booking.status == 'Cancelled' ? const Color(0xFFEF4444) : const Color(0xFF10B981));

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: colors.card,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: colors.inkFaint),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            Navigator.of(context).push(
              MaterialPageRoute<void>(
                builder: (_) => AdminBookingDetailScreen(booking: booking),
              ),
            );
          },
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Initials Circle
                CircleAvatar(
                  radius: 18,
                  backgroundColor: colors.inkFaint.withValues(alpha: 0.7),
                  child: Text(
                    initials.isEmpty ? 'U' : initials,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: colors.ink,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Header Row: Reference, Time, Status Badge
                      Row(
                        children: [
                          Text(
                            booking.reference,
                            style: TextStyle(
                              fontSize: 12.5,
                              fontWeight: FontWeight.w700,
                              color: const Color(0xFF3B82F6),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            booking.pickupTime,
                            style: TextStyle(
                              fontSize: 11.5,
                              color: colors.inkMuted,
                            ),
                          ),
                          const Spacer(),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                            decoration: BoxDecoration(
                              color: statusColor.withValues(alpha: 0.12),
                              borderRadius: BorderRadius.circular(999),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Container(
                                  width: 5,
                                  height: 5,
                                  decoration: BoxDecoration(
                                    color: statusColor,
                                    shape: BoxShape.circle,
                                  ),
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  booking.status,
                                  style: TextStyle(
                                    fontSize: 10.5,
                                    fontWeight: FontWeight.w600,
                                    color: statusColor,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      // Customer Name
                      Text(
                        booking.customerName,
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: colors.ink,
                        ),
                      ),
                      const SizedBox(height: 4),
                      // Route
                      Text(
                        '${booking.pickupAddress} → ${booking.destinationAddress}',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 12,
                          color: colors.inkMuted,
                        ),
                      ),
                      const SizedBox(height: 6),
                      // Fare
                      Text(
                        '£${booking.fare.toStringAsFixed(2)}',
                        style: TextStyle(
                          fontSize: 13.5,
                          fontWeight: FontWeight.w800,
                          color: colors.ink,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 6),
                Icon(
                  Icons.chevron_right_rounded,
                  size: 20,
                  color: colors.inkMuted,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
