import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';

import '../../providers/providers.dart';
import '../../widgets/app_button.dart';

class AddTripScreen extends ConsumerStatefulWidget {
  const AddTripScreen({super.key, this.trip});

  final Trip? trip;

  @override
  ConsumerState<AddTripScreen> createState() => _AddTripScreenState();
}

class _AddTripScreenState extends ConsumerState<AddTripScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _name;
  late final TextEditingController _location;
  late final TextEditingController _description;
  late DateTime _startDate;
  late DateTime _endDate;
  String? _imageBase64; // Lưu ảnh bìa chuyến đi dưới dạng Base64
  bool _isLoading = false;
  late List<String> _destinations;

  @override
  void initState() {
    super.initState();
    final t = widget.trip;
    _name = TextEditingController(text: t?.name ?? '');
    _location = TextEditingController(text: t?.location ?? '');
    _description = TextEditingController(text: t?.description ?? '');
    _startDate = t?.startDate ?? DateTime.now();
    _endDate = t?.endDate ?? DateTime.now().add(const Duration(days: 3));
    _imageBase64 = t?.imageBase64;
    _destinations = List<String>.from(t?.destinations ?? []);
    if (_destinations.isEmpty && _location.text.isNotEmpty) {
      _destinations.add(_location.text);
    }
  }

  @override
  void dispose() {
    _name.dispose();
    _location.dispose();
    _description.dispose();
    super.dispose();
  }

  /// Chọn ảnh từ thư viện và chuyển sang Base64
  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final image = await picker.pickImage(
      source: ImageSource.gallery,
      maxWidth: 1024,
      maxHeight: 768,
      imageQuality: 80,
    );
    if (image != null) {
      final bytes = await image.readAsBytes();
      setState(() => _imageBase64 = base64Encode(bytes));
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEdit = widget.trip != null;
    return Scaffold(
      appBar: AppBar(
        title: Text(isEdit ? 'Chỉnh sửa chuyến đi' : 'Tạo chuyến đi mới'),
        elevation: 0,
        scrolledUnderElevation: 0,
        iconTheme: const IconThemeData(color: Colors.black87),
        titleTextStyle: const TextStyle(
          color: Colors.black,
          fontSize: 18,
          fontWeight: FontWeight.bold,
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ===== CHỌN ẢNH BÌA =====
              _sectionTitle('Ảnh bìa chuyến đi'),
              const SizedBox(height: 12),
              _buildImagePicker(),
              const SizedBox(height: 24),

              _sectionTitle('Thông tin cơ bản'),
              const SizedBox(height: 16),
              _buildField(
                controller: _name,
                label: 'Tên chuyến đi',
                icon: Icons.luggage_rounded,
                hint: 'VD: Khám phá Đà Nẵng',
                delay: 100,
              ),

              // Thêm nhiều địa điểm
              _sectionTitle('Các điểm đến chi tiết'),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                children: _destinations.map((dest) => Chip(
                  label: Text(dest),
                  onDeleted: () => setState(() => _destinations.remove(dest)),
                )).toList(),
              ),
              Row(
                children: [
                  Expanded(
                    child: DropdownButtonFormField<String>(
                      decoration: const InputDecoration(hintText: 'Thêm điểm đến...'),
                      items: [
                        'Hà Nội', 'TP. Hồ Chí Minh', 'Đà Nẵng', 'Hội An', 'Huế',
                        'Nha Trang', 'Phú Quốc', 'Đà Lạt', 'Sapa', 'Hạ Long',
                        'Ninh Bình', 'Bình Dương', 'Mũi Né', 'Cần Thơ', 'Hà Giang',
                      ].map((city) => DropdownMenuItem(value: city, child: Text(city))).toList(),
                      onChanged: (v) {
                        if (v != null && !_destinations.contains(v)) {
                          setState(() => _destinations.add(v));
                        }
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),

              _buildField(
                controller: _description,
                label: 'Mô tả (tùy chọn)',
                icon: Icons.notes_rounded,
                hint: 'Ghi chú ngắn về chuyến đi...',
                delay: 300,
                maxLines: 3,
              ),
              const SizedBox(height: 16),
              _sectionTitle('Thời gian'),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(child: _buildDateTile('Ngày đi', _startDate, true, 400)),
                  const SizedBox(width: 12),
                  Expanded(child: _buildDateTile('Ngày về', _endDate, false, 500)),
                ],
              ),
              const SizedBox(height: 40),
              AppButton(
                label: isEdit ? 'Lưu thay đổi' : 'Tạo chuyến đi',
                icon: isEdit ? Icons.save_rounded : Icons.flight_takeoff_rounded,
                isLoading: _isLoading,
                onPressed: _submit,
              ).animate().fadeIn(delay: 600.ms),
            ],
          ),
        ),
      ),
    );
  }

  /// Widget chọn / xem trước ảnh bìa
  Widget _buildImagePicker() {
    return GestureDetector(
      onTap: _pickImage,
      child: Container(
        height: 180,
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surfaceVariant.withOpacity(0.3),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Theme.of(context).colorScheme.outlineVariant, width: 1.5),
        ),
        clipBehavior: Clip.hardEdge,
        child: _imageBase64 != null
            ? Stack(
                fit: StackFit.expand,
                children: [
                  Image.memory(base64Decode(_imageBase64!), fit: BoxFit.cover),
                  // Nút xóa ảnh
                  Positioned(
                    top: 8,
                    right: 8,
                    child: GestureDetector(
                      onTap: () => setState(() => _imageBase64 = null),
                      child: Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: Colors.black54,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: const Icon(Icons.close, color: Colors.white, size: 18),
                      ),
                    ),
                  ),
                  // Nút đổi ảnh
                  Positioned(
                    bottom: 8,
                    right: 8,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: Colors.black54,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.edit, color: Colors.white, size: 14),
                          SizedBox(width: 4),
                          Text('Đổi ảnh', style: TextStyle(color: Colors.white, fontSize: 12)),
                        ],
                      ),
                    ),
                  ),
                ],
              )
            : Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.add_photo_alternate_outlined, size: 48, color: Colors.grey.shade400),
                  const SizedBox(height: 8),
                  Text('Thêm ảnh bìa', style: TextStyle(color: Colors.grey.shade500)),
                  const SizedBox(height: 4),
                  Text('Chọn từ thư viện', style: TextStyle(color: Colors.grey.shade400, fontSize: 12)),
                ],
              ),
      ),
    ).animate().fadeIn(delay: 50.ms).scale(begin: const Offset(0.98, 0.98));
  }

  Widget _sectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.bold,
        color: Color(0xFF0EA5E9),
      ),
    );
  }

  Widget _buildField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    required int delay,
    String? hint,
    int maxLines = 1,
    String? Function(String?)? validator,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: TextFormField(
        controller: controller,
        validator: validator,
        maxLines: maxLines,
        decoration: InputDecoration(
          labelText: label,
          hintText: hint,
          prefixIcon: Icon(icon),
        ),
      ).animate().fadeIn(delay: delay.ms).moveY(begin: 10, end: 0),
    );
  }

  Widget _buildDateTile(String label, DateTime date, bool isStart, int delay) {
    final fmt = DateFormat('dd/MM/yyyy');
    return GestureDetector(
      onTap: () => _pickDate(isStart),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surfaceVariant.withOpacity(0.2),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Theme.of(context).colorScheme.outlineVariant.withOpacity(0.5)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.calendar_today_outlined, size: 16, color: Color(0xFF0EA5E9)),
                const SizedBox(width: 6),
                Text(label, style: const TextStyle(color: Colors.grey, fontSize: 12)),
              ],
            ),
            const SizedBox(height: 6),
            Text(
              fmt.format(date),
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
            ),
          ],
        ),
      ),
    ).animate().fadeIn(delay: delay.ms).moveY(begin: 10, end: 0);
  }

  Future<void> _pickDate(bool isStart) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: isStart ? _startDate : _endDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
    );
    if (picked != null) {
      setState(() {
        if (isStart) {
          _startDate = picked;
          // Đảm bảo ngày về không trước ngày đi
          if (_endDate.isBefore(_startDate)) {
            _endDate = _startDate.add(const Duration(days: 1));
          }
        } else {
          if (picked.isBefore(_startDate)) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Ngày về phải sau ngày đi!')),
            );
            return;
          }
          _endDate = picked;
        }
      });
    }
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);

    try {
      final auth = ref.read(authProvider);
      final tripService = ref.read(tripServiceProvider);

      final trip = Trip(
        id: widget.trip?.id ?? '',
        name: _name.text.trim(),
        location: _destinations.isNotEmpty ? _destinations.first : '',
        destinations: _destinations,
        description: _description.text.trim(),
        startDate: _startDate,
        endDate: _endDate,
        userId: auth.currentUser?.uid ?? '',
        createdAt: widget.trip?.createdAt ?? DateTime.now(),
        imageBase64: _imageBase64,
        imageUrl: widget.trip?.imageUrl,
      );

      if (widget.trip == null) {
        await tripService.addTrip(trip);
      } else {
        await tripService.updateTrip(trip);
      }

      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(widget.trip == null ? 'Tạo chuyến đi thành công!' : 'Đã cập nhật chuyến đi.'),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Lỗi: $e'), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }
}
