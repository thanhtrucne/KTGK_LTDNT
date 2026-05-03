import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../providers/providers.dart';
import '../../widgets/empty_state.dart';
import '../../widgets/error_state.dart';
import 'add_trip_screen.dart';
import 'trip_detail_screen.dart';

class TripListScreen extends ConsumerWidget {
  const TripListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final auth = ref.watch(authProvider);
    final tripService = ref.watch(tripServiceProvider);
    final userId = auth.currentUser?.uid ?? '';

    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.background,
      appBar: AppBar(
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
        title: const Text(
          'Chuyến đi của tôi',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 22),
        ),
        actions: [
          IconButton(
            onPressed: () => _showJoinTripDialog(context, ref),
            icon: const Icon(Icons.group_add_rounded),
            tooltip: 'Tham gia bằng mã',
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: StreamBuilder<List<Trip>>(
        stream: tripService.watchTrips(userId),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return ErrorState(message: snapshot.error.toString());
          }

          final trips = snapshot.data ?? [];
          if (trips.isEmpty) {
            return const EmptyState(
              icon: Icons.luggage_rounded,
              title: 'Chưa có chuyến đi nào',
              message: 'Hãy tạo chuyến đi đầu tiên của bạn!',
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: trips.length,
            itemBuilder: (context, index) => _TripCard(trip: trips[index], index: index),
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => Navigator.of(context).push(
          MaterialPageRoute(builder: (_) => const AddTripScreen()),
        ),
        icon: const Icon(Icons.add_rounded),
        label: const Text('Thêm chuyến đi'),
        backgroundColor: const Color(0xFF0EA5E9),
        foregroundColor: Colors.white,
      ).animate().scale(delay: 400.ms),
    );
  }

  Future<void> _showJoinTripDialog(BuildContext context, WidgetRef ref) async {
    final controller = TextEditingController();
    final auth = ref.read(authProvider);
    final tripService = ref.read(tripServiceProvider);

    await showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Tham gia chuyến đi'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Nhập mã chuyến đi (ID) để cùng bạn bè lên kế hoạch.'),
            const SizedBox(height: 16),
            TextField(
              controller: controller,
              decoration: const InputDecoration(
                labelText: 'Mã chuyến đi',
                hintText: 'VD: abc123xyz',
              ),
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Hủy')),
          FilledButton(
            onPressed: () async {
              final code = controller.text.trim();
              if (code.isEmpty) return;

              try {
                await tripService.joinTrip(code, auth.currentUser?.uid ?? '');
                if (context.mounted) {
                  Navigator.pop(ctx);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Đã tham gia chuyến đi thành công!')),
                  );
                }
              } catch (e) {
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Lỗi: $e'), backgroundColor: Colors.red),
                  );
                }
              }
            },
            child: const Text('Tham gia'),
          ),
        ],
      ),
    );
  }
}

class _TripCard extends StatelessWidget {
  const _TripCard({required this.trip, required this.index});

  final Trip trip;
  final int index;

  @override
  Widget build(BuildContext context) {
    final dateFormat = DateFormat('dd/MM/yyyy');
    final statusColor = switch (trip.status) {
      TripStatus.upcoming => const Color(0xFF0EA5E9),
      TripStatus.ongoing => const Color(0xFF10B981),
      TripStatus.completed => Colors.grey,
    };
    final statusLabel = switch (trip.status) {
      TripStatus.upcoming => 'Sắp đến',
      TripStatus.ongoing => 'Đang đi',
      TripStatus.completed => 'Đã xong',
    };

    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: GestureDetector(
        onTap: () => Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) => TripDetailScreen(tripId: trip.id),
          ),
        ),
        child: Container(
          decoration: BoxDecoration(
            color: Theme.of(context).cardTheme.color,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.06),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Ảnh bìa chuyến đi
              ClipRRect(
                borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
                child: _buildTripImage(),
              ),

              Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            trip.name,
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: statusColor.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            statusLabel,
                            style: TextStyle(color: statusColor, fontWeight: FontWeight.w600, fontSize: 12),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        const Icon(Icons.location_on_outlined, size: 16, color: Colors.grey),
                        const SizedBox(width: 4),
                        Text(trip.location, style: const TextStyle(color: Colors.grey)),
                        const Spacer(),
                        const Icon(Icons.calendar_today_outlined, size: 14, color: Colors.grey),
                        const SizedBox(width: 4),
                        Text(
                          '${dateFormat.format(trip.startDate)} – ${dateFormat.format(trip.endDate)}',
                          style: const TextStyle(color: Colors.grey, fontSize: 12),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        const Icon(Icons.wb_sunny_outlined, size: 16, color: Colors.orange),
                        const SizedBox(width: 4),
                        Text(
                          '${trip.durationDays} ngày',
                          style: const TextStyle(fontWeight: FontWeight.w600, color: Colors.orange),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    ).animate().fadeIn(delay: (index * 100).ms).moveY(begin: 20, end: 0);
  }

  Widget _buildTripImage() {
    if (trip.imageBase64 != null && trip.imageBase64!.isNotEmpty) {
      try {
        return Image.memory(
          base64Decode(trip.imageBase64!),
          height: 160,
          width: double.infinity,
          fit: BoxFit.cover,
          errorBuilder: (_, __, ___) => _PlaceholderImage(),
        );
      } catch (e) {
        return _PlaceholderImage();
      }
    }

    if (trip.imageUrl != null && trip.imageUrl!.isNotEmpty) {
      return Image.network(
        trip.imageUrl!,
        height: 160,
        width: double.infinity,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => _PlaceholderImage(),
      );
    }

    return _PlaceholderImage();
  }

}

class _PlaceholderImage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      height: 160,
      width: double.infinity,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF0EA5E9), Color(0xFF6366F1)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: const Icon(Icons.travel_explore, size: 60, color: Colors.white54),
    );
  }
}
