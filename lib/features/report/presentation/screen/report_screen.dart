import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:pantau_app/core/constant/colors.dart';
import 'package:pantau_app/features/report/presentation/providers/report_providers.dart';
import 'package:pantau_app/features/work/domain/models/work_order.dart';
import 'package:pantau_app/features/work/presentation/viewmodels/work_order_viewmodel.dart';
import 'package:pantau_app/features/work_order_detail/presentation/providers/work_order_detail_provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class ReportScreen extends ConsumerStatefulWidget {
  static const String route = '/workorder/report';
  final String workOrderId;

  const ReportScreen({
    super.key,
    required this.workOrderId,
  });

  @override
  ConsumerState<ReportScreen> createState() => _ReportScreenState();
}

class _ReportScreenState extends ConsumerState<ReportScreen> {
  File? _beforeImage;
  File? _afterImage;
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _noteController = TextEditingController();
  bool _isLoading = false;
  final ImagePicker _picker = ImagePicker();

  @override
  void dispose() {
    _noteController.dispose();
    super.dispose();
  }

  Future<void> _showImageSourceDialog(bool isAfter) async {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (BuildContext context) {
        return Container(
          decoration: const BoxDecoration(
            color: AppColors.cardColor,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(20),
              topRight: Radius.circular(20),
            ),
          ),
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text(
                    'Pilih Sumber Gambar',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: AppColors.black,
                    ),
                  ),
                  const SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      _imageSourceOption(
                        icon: Icons.camera_alt,
                        label: 'Kamera',
                        onTap: () {
                          Navigator.pop(context);
                          pickImage(isAfter, ImageSource.camera);
                        },
                      ),
                      _imageSourceOption(
                        icon: Icons.photo_library,
                        label: 'Galeri',
                        onTap: () {
                          Navigator.pop(context);
                          pickImage(isAfter, ImageSource.gallery);
                        },
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _imageSourceOption({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        width: 100,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.backgroundColor,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 40, color: AppColors.primaryColor),
            const SizedBox(height: 8),
            Text(
              label,
              style: const TextStyle(
                fontSize: 14,
                color: AppColors.black,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> pickImage(bool isAfter, ImageSource source) async {
    try {
      final XFile? image = await _picker.pickImage(
        source: source,
        imageQuality: 80,
      );
      
      if (image != null) {
        setState(() {
          if (isAfter) {
            _afterImage = File(image.path);
          } else {
            _beforeImage = File(image.path);
          }
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error saat mengambil gambar: ${e.toString()}'),
          backgroundColor: AppColors.errorColor,
        ),
      );
    }
  }

  String _generatePath(String prefix, String originalPath, String title) {
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final ext = originalPath.split('.').last;
    final sanitizedTitle = title.replaceAll(' ', '_').replaceAll(RegExp(r'[^\w\s]+'), '');
    return '$sanitizedTitle/$prefix-$timestamp.$ext';
  }

  Future<String> _uploadFile(File file, String path) async {
    try {
      final supabase = Supabase.instance.client;
      await supabase.storage
          .from('reports')
          .upload(path, file, fileOptions: const FileOptions(upsert: false));
      final publicUrl =
          supabase.storage.from('reports').getPublicUrl(path);
      return publicUrl;
    } catch (e) {
      throw Exception('Upload gagal: $e');
    }
  }

  Future<void> _submitReport(WorkOrder workOrder) async {
    if (!_formKey.currentState!.validate()) return;
    if (_afterImage == null) {
      _showSnackBar('Gambar sesudah wajib diunggah!', isError: true);
      return;
    }

    setState(() => _isLoading = true);
    try {
      String? beforeUrl;
      if (_beforeImage != null) {
        final beforePath = _generatePath(
            'before', _beforeImage!.path, workOrder.title);
        beforeUrl = await _uploadFile(_beforeImage!, beforePath);
      }
      final afterPath = _generatePath(
          'after', _afterImage!.path, workOrder.title);
      final afterUrl = await _uploadFile(_afterImage!, afterPath);

      final supabase = Supabase.instance.client;
      final payload = <String, dynamic>{
        'before_photo': beforeUrl,
        'after_photo': afterUrl,
        'created_at': DateTime.now().toIso8601String(),
        'wo_id': workOrder.id,
      };
      if (_noteController.text.trim().isNotEmpty) {
        payload['note'] = _noteController.text.trim();
      }

      final insertRes = await supabase
          .from('report')
          .insert(payload)
          .select()
          .single();
      if (insertRes.isEmpty) {
        throw Exception('Gagal menyimpan report');
      }

      await ref
          .read(workOrderViewModelProvider.notifier)
          .updateWorkOrderStatus(workOrder.id, 'selesai');
      
      // refresh report widget
      ref.invalidate(workOrderReportsProvider(widget.workOrderId));

      _showSnackBar('Report berhasil dikirim!', isError: false);
      Navigator.of(context).pop(true);
    } catch (e) {
      _showSnackBar('Error: ${e.toString()}', isError: true);
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _showSnackBar(String message, {required bool isError}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? AppColors.errorColor : AppColors.successColor,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        margin: const EdgeInsets.all(10),
      ),
    );
  }

  Widget _imageContainer(File? image, bool isAfter) {
    return Container(
      width: double.infinity,
      height: 200,
      decoration: BoxDecoration(
        color: AppColors.backgroundColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppColors.primaryColor.withValues(alpha: 0.5),
          width: 1,
        ),
      ),
      child: image != null
          ? ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Stack(
                fit: StackFit.expand,
                children: [
                  Image.file(
                    image,
                    fit: BoxFit.cover,
                  ),
                  Positioned(
                    top: 8,
                    right: 8,
                    child: InkWell(
                      onTap: () {
                        setState(() {
                          if (isAfter) {
                            _afterImage = null;
                          } else {
                            _beforeImage = null;
                          }
                        });
                      },
                      child: Container(
                        padding: const EdgeInsets.all(4),
                        decoration: const BoxDecoration(
                          color: AppColors.errorColor,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.close,
                          color: Colors.white,
                          size: 16,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            )
          : Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.add_photo_alternate_outlined,
                  size: 48,
                  color: AppColors.primaryColor.withValues(alpha: 0.7),
                ),
                const SizedBox(height: 8),
                Text(
                  isAfter
                      ? 'Add after photo'
                      : 'Add before photo (Optional)',
                  style: TextStyle(
                    fontSize: 14,
                    color: AppColors.black.withValues(alpha: 0.7),
                  ),
                ),
              ],
            ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final workOrderAsync =
        ref.watch(workOrderDetailProvider(widget.workOrderId));

    return workOrderAsync.when(
      loading: () => _buildLoadingScreen(),
      error: (error, stack) => _buildErrorScreen(error),
      data: (workOrder) => _buildReportScreen(workOrder),
    );
  }

  Widget _buildLoadingScreen() {
    return const Scaffold(
      backgroundColor: AppColors.backgroundColor,
      body: Center(
        child: CircularProgressIndicator(
          color: AppColors.primaryColor,
        ),
      ),
    );
  }

  Widget _buildErrorScreen(dynamic error) {
    return Scaffold(
      backgroundColor: AppColors.backgroundColor,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.error_outline,
              color: AppColors.errorColor,
              size: 60,
            ),
            const SizedBox(height: 16),
            Text(
              'Error: $error',
              style: const TextStyle(
                color: AppColors.black,
                fontSize: 16,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () => Navigator.of(context).pop(),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryColor,
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: const Text('Kembali'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildReportScreen(WorkOrder workOrder) {
    return Scaffold(
      backgroundColor: AppColors.backgroundColor,
      appBar: AppBar(
        backgroundColor: AppColors.primaryColor,
        elevation: 0,
        title: const Text(
          'Report',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: SafeArea(
        child: Form(
          key: _formKey,
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              _buildImagesSection(),
              const SizedBox(height: 20),
              _buildNoteSection(),
              const SizedBox(height: 24),
              _buildSubmitButton(workOrder),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildImagesSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Documentation',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: AppColors.black,
          ),
        ),
        const SizedBox(height: 16),
        const Text(
          'Before',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: AppColors.black,
          ),
        ),
        const SizedBox(height: 8),
        GestureDetector(
          onTap: _isLoading ? null : () => _showImageSourceDialog(false),
          child: _imageContainer(_beforeImage, false),
        ),
        const SizedBox(height: 16),
        const Row(
          children: [
            Text(
              'After',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: AppColors.black,
              ),
            ),
            SizedBox(width: 4),
            Text(
              '*',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: AppColors.errorColor,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        GestureDetector(
          onTap: _isLoading ? null : () => _showImageSourceDialog(true),
          child: _imageContainer(_afterImage, true),
        ),
      ],
    );
  }

  Widget _buildNoteSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Note',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: AppColors.black,
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: _noteController,
          decoration: InputDecoration(
            hintText: 'Add work notes...',
            filled: true,
            fillColor: AppColors.cardColor,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                color: AppColors.primaryColor.withValues(alpha: 0.5),
              ),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                color: AppColors.primaryColor.withValues(alpha: 0.5),
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(
                color: AppColors.primaryColor,
                width: 2,
              ),
            ),
          ),
          maxLines: 5,
          enabled: !_isLoading,
          style: const TextStyle(
            fontSize: 14,
            color: AppColors.black,
          ),
        ),
      ],
    );
  }

  Widget _buildSubmitButton(WorkOrder workOrder) {
    return ElevatedButton(
      onPressed: _isLoading ? null : () => _submitReport(workOrder),
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.primaryColor,
        padding: const EdgeInsets.symmetric(vertical: 16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        disabledBackgroundColor: AppColors.primaryColor.withValues(alpha: 0.5),
      ),
      child: _isLoading
          ? const SizedBox(
              width: 24,
              height: 24,
              child: CircularProgressIndicator(
                color: Colors.white,
                strokeWidth: 2,
              ),
            )
          : const Text(
              'Send Report',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
    );
  }
}