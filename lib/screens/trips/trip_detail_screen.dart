import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../providers/providers.dart';
import '../../widgets/empty_state.dart';
import 'add_trip_screen.dart';

class TripDetailScreen extends ConsumerStatefulWidget {
  const TripDetailScreen({super.key, required this.tripId});
  final String tripId;

  @override
  ConsumerState<TripDetailScreen> createState() => _TripDetailScreenState();
}

class _TripDetailScreenState extends ConsumerState<TripDetailScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final tripService = ref.watch(tripServiceProvider);

    return StreamBuilder<Trip?>(
      stream: tripService.watchTrip(widget.tripId),
      builder: (context, snapshot) {
        final trip = snapshot.data;
        if (trip == null) {
          return const Scaffold(body: Center(child: CircularProgressIndicator()));
        }

        return Scaffold(
          appBar: AppBar(
            elevation: 0,
            scrolledUnderElevation: 0,
            title: Text(trip.name, style: const TextStyle(fontWeight: FontWeight.bold)),
            actions: [
              IconButton(
                icon: const Icon(Icons.edit_outlined),
                onPressed: () => Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => AddTripScreen(trip: trip)),
                ),
              ),
              IconButton(
                icon: const Icon(Icons.delete_outline, color: Colors.redAccent),
                onPressed: () => _deleteTrip(context, ref, trip),
              ),
            ],
            bottom: TabBar(
              controller: _tabController,
              isScrollable: false,
              labelColor: const Color(0xFF0EA5E9),
              unselectedLabelColor: Colors.grey,
              indicatorColor: const Color(0xFF0EA5E9),
              indicatorSize: TabBarIndicatorSize.label,
              labelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
              tabs: const [
                Tab(text: 'Tổng quan'),
                Tab(text: 'Lịch trình'),
                Tab(text: 'Chi phí'),
                Tab(text: 'Checklist'),
              ],
            ),
          ),
          body: TabBarView(
            controller: _tabController,
            children: [
              _OverviewTab(trip: trip),
              _ItineraryTab(trip: trip),
              _ExpenseTab(tripId: widget.tripId),
              _ChecklistTab(tripId: widget.tripId),
            ],
          ),
        );
      },
    );
  }

  Future<void> _deleteTrip(BuildContext context, WidgetRef ref, Trip trip) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Xóa chuyến đi?'),
        content: Text('Bạn có chắc muốn xóa "${trip.name}"? Hành động này không thể hoàn tác.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Hủy')),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Xóa'),
          ),
        ],
      ),
    );
    if (confirmed == true) {
      await ref.read(tripServiceProvider).deleteTrip(trip.id);
      if (context.mounted) Navigator.pop(context);
    }
  }
}

// ============ TAB 1: TỔNG QUAN ============
class _OverviewTab extends StatelessWidget {
  const _OverviewTab({required this.trip});
  final Trip trip;

  @override
  Widget build(BuildContext context) {
    final fmt = DateFormat('dd/MM/yyyy');
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          // Hiển thị ảnh bìa Base64 nếu có
          if (trip.imageBase64 != null) ...[
            ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: Image.memory(
                base64Decode(trip.imageBase64!),
                height: 180,
                width: double.infinity,
                fit: BoxFit.cover,
              ),
            ).animate().fadeIn().scale(),
            const SizedBox(height: 20),
          ],
          Row(
            children: [
              _InfoChip(Icons.location_on_outlined, trip.location, const Color(0xFF0EA5E9), 100),
              const SizedBox(width: 12),
              _InfoChip(Icons.wb_sunny_outlined, '${trip.durationDays} ngày', Colors.orange, 200),
            ],
          ),
          if (trip.destinations.isNotEmpty) ...[
            const SizedBox(height: 16),
            Align(
              alignment: Alignment.centerLeft,
              child: Wrap(
                spacing: 8,
                runSpacing: 0,
                children: trip.destinations.map((d) => Chip(
                  label: Text(d, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Color(0xFF0EA5E9))),
                  avatar: const Icon(Icons.location_on, size: 14, color: Color(0xFF0EA5E9)),
                  backgroundColor: const Color(0xFF0EA5E9).withOpacity(0.1),
                  side: BorderSide.none,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                )).toList(),
              ),
            ).animate().fadeIn(delay: 250.ms),
          ],
          const SizedBox(height: 20),
          _InfoRow(Icons.flight_takeoff_rounded, 'Ngày khởi hành', fmt.format(trip.startDate), 300),
          _InfoRow(Icons.flight_land_rounded, 'Ngày trở về', fmt.format(trip.endDate), 400),
          
          const SizedBox(height: 20),
          // Mã chuyến đi để chia sẻ
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surfaceVariant.withOpacity(0.5),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Theme.of(context).colorScheme.outlineVariant),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Mã chia sẻ', style: TextStyle(fontSize: 12, color: Colors.grey)),
                      Text(trip.id, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                    ],
                  ),
                ),
                IconButton(
                  onPressed: () {
                    // Copy to clipboard logic
                    Clipboard.setData(ClipboardData(text: trip.id));
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Đã sao chép mã chuyến đi!')),
                    );
                  },
                  icon: const Icon(Icons.copy_rounded),
                  tooltip: 'Sao chép mã',
                ),
              ],
            ),
          ).animate().fadeIn(delay: 450.ms),

          if (trip.description.isNotEmpty) ...[
            const SizedBox(height: 20),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primaryContainer.withOpacity(0.3),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Ghi chú', style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF0EA5E9))),
                  const SizedBox(height: 8),
                  Text(trip.description, style: const TextStyle(height: 1.5)),
                ],
              ),
            ).animate().fadeIn(delay: 500.ms),
          ],
        ],
      ),
    );
  }
}

class _InfoChip extends StatelessWidget {
  const _InfoChip(this.icon, this.label, this.color, this.delay);
  final IconData icon;
  final String label;
  final Color color;
  final int delay;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: color.withOpacity(0.08),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: color.withOpacity(0.2)),
        ),
        child: Row(
          children: [
            Icon(icon, color: color, size: 20),
            const SizedBox(width: 8),
            Expanded(child: Text(label, style: TextStyle(color: color, fontWeight: FontWeight.w600))),
          ],
        ),
      ).animate().fadeIn(delay: delay.ms).scale(),
    );
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow(this.icon, this.label, this.value, this.delay);
  final IconData icon;
  final String label;
  final String value;
  final int delay;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        children: [
          Icon(icon, color: const Color(0xFF0EA5E9), size: 20),
          const SizedBox(width: 12),
          Text(label, style: const TextStyle(color: Colors.grey)),
          const Spacer(),
          Text(value, style: const TextStyle(fontWeight: FontWeight.bold)),
        ],
      ).animate().fadeIn(delay: delay.ms).moveX(begin: 20, end: 0),
    );
  }
}

// ============ TAB 2: LỊCH TRÌNH ============
class _ItineraryTab extends ConsumerWidget {
  const _ItineraryTab({required this.trip});
  final Trip trip; // Nhận trip để lấy khoảng thời gian cho phép

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final actService = ref.watch(activityServiceProvider);

    return StreamBuilder<List<Activity>>(
      stream: actService.watchActivities(trip.id),
      builder: (context, snapshot) {
        final items = snapshot.data ?? [];
        return Scaffold(
          backgroundColor: Colors.transparent,
          body: items.isEmpty
              ? const EmptyState(icon: Icons.map_outlined, title: 'Chưa có lịch trình', message: 'Thêm hoạt động đầu tiên!')
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: items.length,
                  itemBuilder: (_, i) => _ActivityTile(
                    item: items[i],
                    onDelete: () => actService.deleteActivity(items[i].id),
                    // Cho phép chỉnh sửa từng hoạt động
                    onEdit: () => _showActivitySheet(
                      context, ref,
                      existing: items[i],
                    ),
                  ),
                ),
          floatingActionButton: FloatingActionButton(
            mini: true,
            backgroundColor: const Color(0xFF0EA5E9),
            foregroundColor: Colors.white,
            onPressed: () => _showActivitySheet(context, ref),
            child: const Icon(Icons.add),
          ),
        );
      },
    );
  }

  /// Hiển thị bottom sheet thêm/sửa hoạt động
  void _showActivitySheet(BuildContext context, WidgetRef ref, {Activity? existing}) {
    final isEdit = existing != null;
    final nameCtrl = TextEditingController(text: existing?.name ?? '');
    final locationCtrl = TextEditingController(text: existing?.location ?? '');
    final noteCtrl = TextEditingController(text: existing?.note ?? '');
    String time = existing?.time ?? '09:00';
    // Ngày mặc định phải nằm trong khoảng của chuyến đi
    DateTime date = existing?.date ?? trip.startDate;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setModal) => Padding(
          padding: EdgeInsets.only(bottom: MediaQuery.of(ctx).viewInsets.bottom, left: 24, right: 24, top: 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    isEdit ? 'Chỉnh sửa hoạt động' : 'Thêm hoạt động',
                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  // Hiển thị khoảng ngày cho phép
                  Text(
                    '${DateFormat('dd/MM').format(trip.startDate)} – ${DateFormat('dd/MM').format(trip.endDate)}',
                    style: const TextStyle(fontSize: 12, color: Colors.grey),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              TextField(controller: nameCtrl, decoration: const InputDecoration(labelText: 'Tên hoạt động', prefixIcon: Icon(Icons.event_note))),
              const SizedBox(height: 12),
              TextField(controller: locationCtrl, decoration: const InputDecoration(labelText: 'Địa điểm', prefixIcon: Icon(Icons.location_on_outlined))),
              const SizedBox(height: 12),
              TextField(controller: noteCtrl, decoration: const InputDecoration(labelText: 'Ghi chú', prefixIcon: Icon(Icons.notes))),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () async {
                        // ⚠️ Ràng buộc ngày trong khoảng của chuyến đi
                        final picked = await showDatePicker(
                          context: ctx,
                          initialDate: date,
                          firstDate: trip.startDate,
                          lastDate: trip.endDate,
                          helpText: 'Chọn ngày (trong chuyến đi)',
                        );
                        if (picked != null) setModal(() => date = picked);
                      },
                      icon: const Icon(Icons.calendar_today_outlined, size: 16),
                      label: Text(DateFormat('dd/MM/yyyy').format(date)),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () async {
                        final parts = time.split(':');
                        final init = TimeOfDay(hour: int.tryParse(parts[0]) ?? 9, minute: int.tryParse(parts[1]) ?? 0);
                        final picked = await showTimePicker(context: ctx, initialTime: init);
                        if (picked != null) setModal(() => time = '${picked.hour.toString().padLeft(2, '0')}:${picked.minute.toString().padLeft(2, '0')}');
                      },
                      icon: const Icon(Icons.access_time, size: 16),
                      label: Text(time),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              FilledButton(
                style: FilledButton.styleFrom(backgroundColor: const Color(0xFF0EA5E9), minimumSize: const Size.fromHeight(48)),
                onPressed: () async {
                  if (nameCtrl.text.trim().isEmpty) return;
                  final activity = Activity(
                    id: existing?.id ?? '',
                    tripId: trip.id,
                    name: nameCtrl.text.trim(),
                    date: date,
                    time: time,
                    location: locationCtrl.text.trim(),
                    note: noteCtrl.text.trim(),
                  );
                  if (isEdit) {
                    await ref.read(activityServiceProvider).updateActivity(activity);
                  } else {
                    await ref.read(activityServiceProvider).addActivity(activity);
                  }
                  if (ctx.mounted) Navigator.pop(ctx);
                },
                child: Text(isEdit ? 'Lưu thay đổi' : 'Thêm hoạt động'),
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }
}

class _ActivityTile extends StatelessWidget {
  const _ActivityTile({required this.item, required this.onDelete, required this.onEdit});
  final Activity item;
  final VoidCallback onDelete;
  final VoidCallback onEdit; // Callback chỉnh sửa

  @override
  Widget build(BuildContext context) {
    final dateFmt = DateFormat('dd/MM');
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Cột thời gian
          SizedBox(
            width: 52,
            child: Column(
              children: [
                Text(item.time, style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF0EA5E9), fontSize: 13)),
                Text(dateFmt.format(item.date), style: const TextStyle(color: Colors.grey, fontSize: 11)),
                Container(width: 2, height: 32, color: Colors.blue.shade100, margin: const EdgeInsets.only(top: 4)),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: Theme.of(context).cardTheme.color,
                borderRadius: BorderRadius.circular(14),
                boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 8, offset: const Offset(0, 2))],
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(item.name, style: const TextStyle(fontWeight: FontWeight.bold)),
                        if (item.location.isNotEmpty) ...[
                          const SizedBox(height: 4),
                          Row(children: [
                            const Icon(Icons.location_on_outlined, size: 14, color: Colors.grey),
                            const SizedBox(width: 4),
                            Expanded(child: Text(item.location, style: const TextStyle(color: Colors.grey, fontSize: 13), overflow: TextOverflow.ellipsis)),
                          ]),
                        ],
                        if (item.note.isNotEmpty) ...[
                          const SizedBox(height: 4),
                          Text(item.note, style: const TextStyle(color: Colors.grey, fontSize: 12, fontStyle: FontStyle.italic)),
                        ],
                      ],
                    ),
                  ),
                  // Nút sửa và xóa
                  IconButton(icon: const Icon(Icons.edit_outlined, color: Color(0xFF0EA5E9), size: 18), onPressed: onEdit),
                  IconButton(icon: const Icon(Icons.delete_outline, color: Colors.red, size: 18), onPressed: onDelete),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ============ TAB 3: CHI PHÍ ============
class _ExpenseTab extends ConsumerWidget {
  const _ExpenseTab({required this.tripId});
  final String tripId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final expService = ref.watch(expenseServiceProvider);
    final fmt = NumberFormat.currency(locale: 'vi_VN', symbol: '₫');

    return StreamBuilder<List<Expense>>(
      stream: expService.watchExpenses(tripId),
      builder: (context, snapshot) {
        final items = snapshot.data ?? [];
        final total = items.fold<double>(0, (sum, e) => sum + e.amount);

        final categoryIcons = {
          ExpenseCategory.dining: Icons.restaurant_rounded,
          ExpenseCategory.transport: Icons.directions_car_outlined,
          ExpenseCategory.hotel: Icons.hotel_outlined,
          ExpenseCategory.other: Icons.category_outlined,
        };
        final categoryColors = {
          ExpenseCategory.dining: Colors.orange,
          ExpenseCategory.transport: Colors.blue,
          ExpenseCategory.hotel: Colors.purple,
          ExpenseCategory.other: Colors.grey,
        };

        return Scaffold(
          backgroundColor: Colors.transparent,
          body: Column(
            children: [
              // Tổng chi phí
              Container(
                margin: const EdgeInsets.all(16),
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(colors: [Color(0xFF10B981), Color(0xFF059669)]),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.account_balance_wallet_outlined, color: Colors.white, size: 32),
                    const SizedBox(width: 16),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Tổng chi phí', style: TextStyle(color: Colors.white70)),
                        Text(fmt.format(total), style: const TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold)),
                      ],
                    ),
                  ],
                ),
              ).animate().fadeIn().scale(),
              Expanded(
                child: items.isEmpty
                    ? const EmptyState(icon: Icons.receipt_long_outlined, title: 'Chưa có chi phí', message: 'Thêm khoản chi đầu tiên!')
                    : ListView.builder(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        itemCount: items.length,
                        itemBuilder: (_, i) {
                          final e = items[i];
                          return Card(
                            margin: const EdgeInsets.only(bottom: 10),
                            child: ListTile(
                              leading: CircleAvatar(
                                backgroundColor: categoryColors[e.category]?.withOpacity(0.1),
                                child: Icon(categoryIcons[e.category], color: categoryColors[e.category]),
                              ),
                              title: Text(e.title, style: const TextStyle(fontWeight: FontWeight.w600)),
                              subtitle: Text(e.category.label),
                              trailing: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(fmt.format(e.amount), style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF10B981))),
                                  IconButton(
                                    icon: const Icon(Icons.delete_outline, color: Colors.red, size: 20),
                                    onPressed: () => expService.deleteExpense(e.id),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
              ),
            ],
          ),
          floatingActionButton: FloatingActionButton(
            mini: true,
            backgroundColor: const Color(0xFF10B981),
            foregroundColor: Colors.white,
            onPressed: () => _showAddExpense(context, ref),
            child: const Icon(Icons.add),
          ),
        );
      },
    );
  }

  void _showAddExpense(BuildContext context, WidgetRef ref) {
    final titleCtrl = TextEditingController();
    final amountCtrl = TextEditingController();
    ExpenseCategory selectedCat = ExpenseCategory.other;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setModal) => Padding(
          padding: EdgeInsets.only(bottom: MediaQuery.of(ctx).viewInsets.bottom, left: 24, right: 24, top: 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('Thêm chi phí', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 16),
              TextField(controller: titleCtrl, decoration: const InputDecoration(labelText: 'Tên chi phí', prefixIcon: Icon(Icons.receipt_outlined))),
              const SizedBox(height: 12),
              TextField(
                controller: amountCtrl,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Số tiền',
                  prefixIcon: Icon(Icons.payments_outlined),
                  suffixText: '.000 đ',
                  hintText: 'VD: 50',
                ),
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<ExpenseCategory>(
                value: selectedCat,
                items: ExpenseCategory.values.map((c) => DropdownMenuItem(value: c, child: Text(c.label))).toList(),
                onChanged: (v) => setModal(() => selectedCat = v ?? selectedCat),
                decoration: const InputDecoration(labelText: 'Danh mục', prefixIcon: Icon(Icons.category_outlined)),
              ),
              const SizedBox(height: 16),
              FilledButton(
                style: FilledButton.styleFrom(backgroundColor: const Color(0xFF10B981), minimumSize: const Size.fromHeight(48)),
                onPressed: () async {
                  // Tự động nhân 1000 để người dùng nhập nhanh
                  final inputVal = double.tryParse(amountCtrl.text) ?? 0;
                  final amount = inputVal * 1000;
                  
                  if (titleCtrl.text.trim().isEmpty || amount <= 0) return;
                  await ref.read(expenseServiceProvider).addExpense(Expense(
                    id: '', tripId: tripId, title: titleCtrl.text.trim(),
                    amount: amount, category: selectedCat, createdAt: DateTime.now(),
                  ));
                  if (ctx.mounted) Navigator.pop(ctx);
                },
                child: const Text('Thêm chi phí'),
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }
}

// ============ TAB 4: CHECKLIST ============
class _ChecklistTab extends ConsumerWidget {
  const _ChecklistTab({required this.tripId});
  final String tripId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final checkService = ref.watch(checklistServiceProvider);

    return StreamBuilder<List<ChecklistItem>>(
      stream: checkService.watchChecklist(tripId),
      builder: (context, snapshot) {
        final items = snapshot.data ?? [];
        final doneCount = items.where((i) => i.isDone).length;

        return Scaffold(
          backgroundColor: Colors.transparent,
          body: Column(
            children: [
              if (items.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      Expanded(
                        child: LinearProgressIndicator(
                          value: items.isEmpty ? 0 : doneCount / items.length,
                          backgroundColor: Colors.grey.shade200,
                          color: const Color(0xFF6366F1),
                          minHeight: 8,
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Text('$doneCount/${items.length}', style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF6366F1))),
                    ],
                  ),
                ),
              Expanded(
                child: items.isEmpty
                    ? const EmptyState(icon: Icons.checklist_rounded, title: 'Checklist trống', message: 'Thêm những thứ cần chuẩn bị!')
                    : ListView.builder(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        itemCount: items.length,
                        itemBuilder: (_, i) {
                          final item = items[i];
                          return Card(
                            margin: const EdgeInsets.only(bottom: 8),
                            child: CheckboxListTile(
                              value: item.isDone,
                              onChanged: (v) => checkService.toggleItem(item.id, v ?? false),
                              title: Text(
                                item.title,
                                style: TextStyle(
                                  decoration: item.isDone ? TextDecoration.lineThrough : null,
                                  color: item.isDone ? Colors.grey : null,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              activeColor: const Color(0xFF6366F1),
                              secondary: IconButton(
                                icon: const Icon(Icons.delete_outline, color: Colors.red, size: 20),
                                onPressed: () => checkService.deleteItem(item.id),
                              ),
                              controlAffinity: ListTileControlAffinity.leading,
                            ),
                          );
                        },
                      ),
              ),
            ],
          ),
          floatingActionButton: FloatingActionButton(
            mini: true,
            backgroundColor: const Color(0xFF6366F1),
            foregroundColor: Colors.white,
            onPressed: () => _showAddItem(context, ref),
            child: const Icon(Icons.add),
          ),
        );
      },
    );
  }

  void _showAddItem(BuildContext context, WidgetRef ref) {
    final ctrl = TextEditingController();

    // Gợi ý mặc định để điền nhanh
    final suggestions = ['Hộ chiếu / CCCD', 'Vé máy bay', 'Đặt khách sạn', 'Quần áo', 'Sạc dự phòng', 'Thuốc'];

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (ctx) => Padding(
        padding: EdgeInsets.only(bottom: MediaQuery.of(ctx).viewInsets.bottom, left: 24, right: 24, top: 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Thêm mục chuẩn bị', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            TextField(
              controller: ctrl,
              autofocus: true,
              decoration: const InputDecoration(labelText: 'Tên mục', prefixIcon: Icon(Icons.check_circle_outline)),
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              children: suggestions.map((s) => ActionChip(
                label: Text(s, style: const TextStyle(fontSize: 12)),
                onPressed: () => ctrl.text = s,
              )).toList(),
            ),
            const SizedBox(height: 16),
            FilledButton(
              style: FilledButton.styleFrom(backgroundColor: const Color(0xFF6366F1), minimumSize: const Size.fromHeight(48)),
              onPressed: () async {
                if (ctrl.text.trim().isEmpty) return;
                await ref.read(checklistServiceProvider).addItem(ChecklistItem(id: '', tripId: tripId, title: ctrl.text.trim()));
                if (ctx.mounted) Navigator.pop(ctx);
              },
              child: const Text('Thêm'),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}


