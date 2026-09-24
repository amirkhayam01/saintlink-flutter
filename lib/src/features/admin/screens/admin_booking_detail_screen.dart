import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme.dart';
import '../admin_models.dart';
import '../admin_state.dart';

class AdminBookingDetailScreen extends ConsumerStatefulWidget {
  const AdminBookingDetailScreen({super.key, required this.booking});

  final AdminBooking booking;

  @override
  ConsumerState<AdminBookingDetailScreen> createState() =>
      _AdminBookingDetailScreenState();
}

class _AdminBookingDetailScreenState
    extends ConsumerState<AdminBookingDetailScreen> {
  late AdminBooking _booking;

  @override
  void initState() {
    super.initState();
    _booking = widget.booking;
  }

  void _showAssignDriverModal() {
    final colors = context.colors;
    final state = ref.read(adminControllerProvider);

    showModalBottomSheet<void>(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      backgroundColor: colors.card,
      builder: (sheetContext) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Center(
                  child: Container(
                    width: 36,
                    height: 4,
                    decoration: BoxDecoration(
                      color: colors.inkFaint,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  'Assign Driver to ${_booking.reference}',
                  style: TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w700,
                    color: colors.ink,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Select an available driver for this journey',
                  style: TextStyle(fontSize: 13, color: colors.inkMuted),
                ),
                const SizedBox(height: 16),
                ...state.drivers.map((driver) {
                  return Container(
                    margin: const EdgeInsets.only(bottom: 8),
                    decoration: BoxDecoration(
                      color: colors.surface,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: colors.inkFaint),
                    ),
                    child: ListTile(
                      leading: CircleAvatar(
                        backgroundColor: AppTheme.brand,
                        child: Text(
                          driver.initials,
                          style: const TextStyle(
                            fontWeight: FontWeight.w700,
                            color: AppTheme.midnight,
                          ),
                        ),
                      ),
                      title: Text(
                        driver.name,
                        style: TextStyle(
                          fontWeight: FontWeight.w700,
                          color: colors.ink,
                          fontSize: 14,
                        ),
                      ),
                      subtitle: Text(
                        '${driver.vehicleName} • ★ ${driver.rating}',
                        style: TextStyle(fontSize: 12, color: colors.inkMuted),
                      ),
                      trailing: FilledButton(
                        style: FilledButton.styleFrom(
                          backgroundColor: AppTheme.brand,
                          foregroundColor: AppTheme.midnight,
                          minimumSize: const Size(70, 34),
                          padding: const EdgeInsets.symmetric(horizontal: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        onPressed: () {
                          ref
                              .read(adminControllerProvider.notifier)
                              .assignDriver(_booking.id, driver.name);
                          setState(() {
                            _booking = _booking.copyWith(
                              driverName: driver.name,
                              isUnassigned: false,
                              status: 'Confirmed',
                            );
                          });
                          Navigator.of(sheetContext).pop();
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('Assigned ${driver.name} to ${_booking.reference}'),
                            ),
                          );
                        },
                        child: const Text(
                          'Assign',
                          style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700),
                        ),
                      ),
                    ),
                  );
                }),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final initials = _booking.customerName
        .trim()
        .split(' ')
        .map((e) => e.isNotEmpty ? e[0] : '')
        .take(2)
        .join()
        .toUpperCase();

    final isAwaiting = _booking.status == 'Awaiting Payment';
    final statusColor = isAwaiting
        ? const Color(0xFFF59E0B)
        : (_booking.status == 'Cancelled' ? const Color(0xFFEF4444) : const Color(0xFF10B981));

    return Scaffold(
      backgroundColor: colors.surface,
      appBar: AppBar(
        backgroundColor: colors.card,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_rounded, color: colors.ink),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          'Booking Details',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: colors.ink,
          ),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.more_vert_rounded, color: colors.ink),
            onPressed: () {},
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(18, 14, 18, 100),
        children: [
          // Reference & Status Pill
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                _booking.reference,
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF2563EB),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: statusColor.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 6,
                      height: 6,
                      decoration: BoxDecoration(
                        color: statusColor,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 5),
                    Text(
                      _booking.status,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: statusColor,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Customer Card
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: colors.card,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: colors.inkFaint),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    CircleAvatar(
                      radius: 20,
                      backgroundColor: colors.inkFaint,
                      child: Text(
                        initials.isEmpty ? 'U' : initials,
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          color: colors.ink,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _booking.customerName,
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                            color: colors.ink,
                          ),
                        ),
                        const SizedBox(height: 3),
                        Row(
                          children: [
                            Icon(Icons.phone_outlined, size: 14, color: colors.inkMuted),
                            const SizedBox(width: 5),
                            Text(
                              _booking.customerPhone,
                              style: TextStyle(
                                fontSize: 12.5,
                                color: colors.inkMuted,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 2),
                        Row(
                          children: [
                            Icon(Icons.email_outlined, size: 14, color: colors.inkMuted),
                            const SizedBox(width: 5),
                            Text(
                              _booking.customerEmail,
                              style: TextStyle(
                                fontSize: 12.5,
                                color: colors.inkMuted,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),

          // Journey Route Card
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: colors.card,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: colors.inkFaint),
            ),
            child: Column(
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      margin: const EdgeInsets.only(top: 2),
                      width: 10,
                      height: 10,
                      decoration: const BoxDecoration(
                        color: Color(0xFF10B981),
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Pickup',
                            style: TextStyle(fontSize: 11, color: colors.inkMuted),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            _booking.pickupAddress,
                            style: TextStyle(
                              fontSize: 13.5,
                              fontWeight: FontWeight.w600,
                              color: colors.ink,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            _booking.pickupTime,
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF3B82F6),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                Padding(
                  padding: const EdgeInsets.only(left: 4.5, top: 4, bottom: 4),
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: Container(
                      width: 1.5,
                      height: 24,
                      color: colors.inkFaint,
                    ),
                  ),
                ),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      margin: const EdgeInsets.only(top: 2),
                      width: 10,
                      height: 10,
                      decoration: const BoxDecoration(
                        color: Color(0xFFEF4444),
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Destination',
                            style: TextStyle(fontSize: 11, color: colors.inkMuted),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            _booking.destinationAddress,
                            style: TextStyle(
                              fontSize: 13.5,
                              fontWeight: FontWeight.w600,
                              color: colors.ink,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            _booking.destinationTime,
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF3B82F6),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),

          // Vehicle & Driver Details Card
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: colors.card,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: colors.inkFaint),
            ),
            child: Column(
              children: [
                // Date & Time
                Row(
                  children: [
                    Icon(Icons.calendar_today_outlined, size: 18, color: colors.inkMuted),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Date & Time', style: TextStyle(fontSize: 11, color: colors.inkMuted)),
                          const SizedBox(height: 2),
                          Text(
                            _booking.createdAt,
                            style: TextStyle(fontSize: 13.5, fontWeight: FontWeight.w600, color: colors.ink),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  child: Divider(color: colors.inkFaint, height: 1),
                ),
                // Vehicle
                Row(
                  children: [
                    Icon(Icons.directions_car_outlined, size: 18, color: colors.inkMuted),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Vehicle', style: TextStyle(fontSize: 11, color: colors.inkMuted)),
                          const SizedBox(height: 2),
                          Text(
                            _booking.vehicleCategory,
                            style: TextStyle(fontSize: 13.5, fontWeight: FontWeight.w600, color: colors.ink),
                          ),
                          if (_booking.isUnassigned)
                            const Text(
                              'Unassigned',
                              style: TextStyle(
                                fontSize: 11.5,
                                fontWeight: FontWeight.w600,
                                color: Color(0xFFF59E0B),
                              ),
                            ),
                        ],
                      ),
                    ),
                    OutlinedButton(
                      style: OutlinedButton.styleFrom(
                        foregroundColor: colors.ink,
                        side: BorderSide(color: colors.inkFaint),
                        minimumSize: const Size(100, 32),
                        padding: const EdgeInsets.symmetric(horizontal: 10),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(999),
                        ),
                      ),
                      onPressed: _showAssignDriverModal,
                      child: const Text(
                        'Assign Driver',
                        style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600),
                      ),
                    ),
                  ],
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  child: Divider(color: colors.inkFaint, height: 1),
                ),
                // Driver
                Row(
                  children: [
                    Icon(Icons.person_outline_rounded, size: 18, color: colors.inkMuted),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Driver', style: TextStyle(fontSize: 11, color: colors.inkMuted)),
                          const SizedBox(height: 2),
                          Text(
                            _booking.driverName,
                            style: TextStyle(
                              fontSize: 13.5,
                              fontWeight: FontWeight.w600,
                              color: _booking.driverName == 'Not assigned' ? colors.inkMuted : colors.ink,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),

          // 3-Box Summary Row: Fare, Payment, Status
          Row(
            children: [
              Expanded(
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: colors.card,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: colors.inkFaint),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Fare', style: TextStyle(fontSize: 11, color: colors.inkMuted)),
                      const SizedBox(height: 4),
                      Text(
                        '£${_booking.fare.toStringAsFixed(2)}',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w800,
                          color: colors.ink,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: colors.card,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: colors.inkFaint),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Payment', style: TextStyle(fontSize: 11, color: colors.inkMuted)),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Icon(Icons.credit_card_outlined, size: 14, color: colors.ink),
                          const SizedBox(width: 4),
                          Expanded(
                            child: Text(
                              _booking.paymentMethod,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w700,
                                color: colors.ink,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: colors.card,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: colors.inkFaint),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Status', style: TextStyle(fontSize: 11, color: colors.inkMuted)),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Icon(Icons.check_circle_outline_rounded, size: 14, color: statusColor),
                          const SizedBox(width: 4),
                          Expanded(
                            child: Text(
                              _booking.status,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w700,
                                color: statusColor,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
      bottomSheet: Container(
        padding: const EdgeInsets.fromLTRB(18, 12, 18, 20),
        decoration: BoxDecoration(
          color: colors.card,
          border: Border(top: BorderSide(color: colors.inkFaint)),
        ),
        child: Row(
          children: [
            Expanded(
              child: OutlinedButton(
                style: OutlinedButton.styleFrom(
                  foregroundColor: colors.ink,
                  side: BorderSide(color: colors.inkFaint),
                  minimumSize: const Size.fromHeight(48),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                onPressed: () {
                  ref.read(adminControllerProvider.notifier).cancelBooking(_booking.id);
                  setState(() {
                    _booking = _booking.copyWith(status: 'Cancelled');
                  });
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Cancelled booking ${_booking.reference}')),
                  );
                },
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.close_rounded, size: 16),
                    SizedBox(width: 6),
                    Text('Cancel Booking', style: TextStyle(fontSize: 13.5, fontWeight: FontWeight.w600)),
                  ],
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: FilledButton(
                style: FilledButton.styleFrom(
                  backgroundColor: AppTheme.brand,
                  foregroundColor: AppTheme.midnight,
                  minimumSize: const Size.fromHeight(48),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                onPressed: _showAssignDriverModal,
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.person_add_alt_rounded, size: 16),
                    SizedBox(width: 6),
                    Text('Assign Driver', style: TextStyle(fontSize: 13.5, fontWeight: FontWeight.w700)),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
