import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:pantau_app/core/constant/colors.dart';
import 'package:pantau_app/features/report/presentation/providers/report_providers.dart';
import 'package:pantau_app/features/work/domain/models/work_order.dart';
import 'package:pantau_app/features/work_order_detail/presentation/providers/work_order_detail_provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class EditReportScreen extends ConsumerStatefulWidget {
  static const String route = '/workorder/report_edit';
  final String workOrderId;
  final bool isTerkendala;
  final String? status;

  const EditReportScreen({
    super.key,
    required this.workOrderId,
    required this.isTerkendala,
    this.status,
  });

  @override
  ConsumerState<EditReportScreen> createState() => _EditReportScreenState();
}

class _EditReportScreenState extends ConsumerState<EditReportScreen> {
  File? _newBefore;
  File? _newAfter;
  final TextEditingController _noteController = TextEditingController();
  bool _isLoading = false;
  bool _isInitialLoading = true;
  final ImagePicker _picker = ImagePicker();

  String? _reportId;
  String? _beforePath;
  String? _afterPath;
  String? _beforeUrl;
  String? _afterUrl;

  @override
  void initState() {
    super.initState();
    _loadExistingReport();
  }

  @override
  void dispose() {
    _noteController.dispose();
    super.dispose();
  }

  String _extractPath(String url) {
    final uri = Uri.parse(url);
    final segments = uri.pathSegments;
    final idx = segments.indexOf('reports');
    return (idx >= 0 && idx + 1 < segments.length)
        ? segments.sublist(idx + 1).join('/')
        : '';
  }

  Future<void> _loadExistingReport() async {
    setState(() => _isInitialLoading = true);
    try {
      final supabase = Supabase.instance.client;
      final res = await supabase
          .from('workorder')
          .select('id, before_url, after_url, note, report_created_at')
          .eq('id', widget.workOrderId)
          .single();

      setState(() {
        _reportId = res['id'] as String?;
        _beforeUrl = res['before_url'] as String?;
        _afterUrl = res['after_url'] as String?;
        _noteController.text = res['note'] as String? ?? '';
        _beforePath = _beforeUrl != null ? _extractPath(_beforeUrl!) : null;
        _afterPath = _afterUrl != null ? _extractPath(_afterUrl!) : null;
      });
    } catch (e) {
      if (mounted) {
        _showSnackBar('Error saat memuat data report: ${e.toString()}', isError: true);
      }
    } finally {
      if (mounted) {
        setState(() => _isInitialLoading = false);
      }
    }
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
                          pickNewImage(isAfter, ImageSource.camera);
                        },
                      ),
                      _imageSourceOption(
                        icon: Icons.photo_library,
                        label: 'Galeri',
                        onTap: () {
                          Navigator.pop(context);
                          pickNewImage(isAfter, ImageSource.gallery);
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

  Future<void> pickNewImage(bool isAfter, ImageSource source) async {
    try {
      final XFile? file = await _picker.pickImage(
        source: source,
        imageQuality: 80,
      );
      
      if (file != null) {
        setState(() {
          if (isAfter) {
            _newAfter = File(file.path);
          } else {
            _newBefore = File(file.path);
          }
        });
      }
    } catch (e) {
      _showSnackBar('Error saat mengambil gambar: ${e.toString()}', isError: true);
    }
  }

  Future<String> _uploadFile(File file, String path) async {
    try {
      final supabase = Supabase.instance.client;
      await supabase.storage.from('reports').upload(
            path,
            file,
            fileOptions: const FileOptions(upsert: true),
          );
      return supabase.storage.from('reports').getPublicUrl(path);
    } catch (e) {
      throw Exception('Upload gagal: $e');
    }
  }

  bool _validateFields() {
    if (widget.isTerkendala) {
      // terkendala, note harus diisi
      if (_noteController.text.trim().isEmpty) {
        _showSnackBar('Detail kendala harus diisi!', isError: true);
        return false;
      }
    } else {
      // selesai, after photo harus diisi
      if (_newAfter == null && _afterUrl == null) {
        _showSnackBar('Gambar sesudah harus diunggah!', isError: true);
        return false;
      }
    }
    return true;
  }

  Future<void> _updateReport(String title) async {
    if (!_validateFields()) {
      return;
    }
    
    final reportId = _reportId;
    if (reportId == null) {
      _showSnackBar('Data report tidak ditemukan', isError: true);
      return;
    }
    
    setState(() => _isLoading = true);
    try {
      final supabase = Supabase.instance.client;
      final updates = <String, dynamic>{};

      // Handle before photo
      if (_newBefore != null) {
        if (_beforePath?.isNotEmpty ?? false) {
          await supabase.storage.from('reports').remove([_beforePath!]);
        }
        final ts = DateTime.now().millisecondsSinceEpoch;
        final ext = _newBefore!.path.split('.').last;
        final folder = title.replaceAll(' ', '_').replaceAll(RegExp(r'[^\w\s]+'), '');
        final newPath = '$folder/before-$ts.$ext';
        final url = await _uploadFile(_newBefore!, newPath);
        updates['before_url'] = url;
      }

      // Handle after photo
      if (_newAfter != null) {
        if (_afterPath?.isNotEmpty ?? false) {
          await supabase.storage.from('reports').remove([_afterPath!]);
        }
        final ts = DateTime.now().millisecondsSinceEpoch;
        final ext = _newAfter!.path.split('.').last;
        final folder = title.replaceAll(' ', '_').replaceAll(RegExp(r'[^\w\s]+'), '');
        final newPath = '$folder/after-$ts.$ext';
        final url = await _uploadFile(_newAfter!, newPath);
        updates['after_url'] = url;
      }

      // Handle note
      updates['note'] = _noteController.text.trim();

      updates['report_created_at'] = DateTime.now().toIso8601String();

      if (widget.status != null) {
        updates['status'] = widget.status;
      }

      if (updates.isNotEmpty) {
        await supabase.from('workorder').update(updates).eq('id', reportId);
        _showSnackBar('Report berhasil diperbarui!', isError: false);
      }
      ref.invalidate(workOrderReportsProvider(widget.workOrderId));
      if (mounted) Navigator.of(context).pop(true);
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

  Widget _buildImageSection({
    required String title, 
    required bool isAfter, 
    String? existingUrl, 
    File? newImage,
    bool isRequired = false,
    required bool isTerkendala,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              title,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: AppColors.black,
              ),
            ),
            if (isRequired) ...[
              const SizedBox(width: 4),
              const Text(
                '*',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: AppColors.errorColor,
                ),
              ),
            ],
          ],
        ),
        const SizedBox(height: 8),
        GestureDetector(
          onTap: _isLoading ? null : () => _showImageSourceDialog(isAfter),
          child: Container(
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
            child: newImage != null 
              ? _buildNewImagePreview(newImage, isAfter)
              : existingUrl != null 
                ? _buildExistingImagePreview(existingUrl, isAfter)
                : _buildEmptyImagePlaceholder(isAfter, isTerkendala),
          ),
        ),
      ],
    );
  }

  Widget _buildNewImagePreview(File image, bool isAfter) {
    return ClipRRect(
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
                    _newAfter = null;
                  } else {
                    _newBefore = null;
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
    );
  }

  Widget _buildExistingImagePreview(String imageUrl, bool isAfter) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: Stack(
        fit: StackFit.expand,
        children: [
          Image.network(
            imageUrl,
            fit: BoxFit.cover,
            loadingBuilder: (context, child, loadingProgress) {
              if (loadingProgress == null) return child;
              return Center(
                child: CircularProgressIndicator(
                  value: loadingProgress.expectedTotalBytes != null
                      ? loadingProgress.cumulativeBytesLoaded /
                          loadingProgress.expectedTotalBytes!
                      : null,
                  color: AppColors.primaryColor,
                ),
              );
            },
            errorBuilder: (context, error, stackTrace) {
              return Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.error_outline,
                    size: 40,
                    color: AppColors.errorColor,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Gagal memuat gambar',
                    style: TextStyle(
                      color: AppColors.black.withValues(alpha: 0.7),
                    ),
                  ),
                ],
              );
            },
          ),
          Positioned(
            top: 8,
            right: 8,
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColors.primaryColor.withValues(alpha: 0.8),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Text(
                    'Existing',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyImagePlaceholder(bool isAfter, bool isTerkendala) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(
          Icons.add_photo_alternate_outlined,
          size: 48,
          color: AppColors.primaryColor.withValues(alpha: 0.7),
        ),
        const SizedBox(height: 8),
        Text(
          isTerkendala 
              ? 'Add photo (Optional)'
              : isAfter
                  ? 'Add after photo'
                  : 'Add before photo (Optional)',
          style: TextStyle(
            fontSize: 14,
            color: AppColors.black.withValues(alpha: 0.7),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final workOrderAsync = ref.watch(workOrderDetailProvider(widget.workOrderId));

    return workOrderAsync.when(
      loading: () => _buildLoadingScreen(),
      error: (e, _) => _buildErrorScreen(e),
      data: (workOrder) => _isInitialLoading 
          ? _buildLoadingScreen() 
          : _buildEditReportScreen(workOrder),
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

  Widget _buildEditReportScreen(WorkOrder workOrder) {
    return Scaffold(
      backgroundColor: AppColors.backgroundColor,
      appBar: AppBar(
        backgroundColor: AppColors.primaryColor,
        elevation: 0,
        title: const Text(
          'Edit Report',
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
        child: ListView(
          padding: const EdgeInsets.all(16),
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
            if (!widget.isTerkendala) ...[
              _buildImageSection(
                title: 'Before',
                isAfter: false,
                existingUrl: _beforeUrl,
                newImage: _newBefore,
                isTerkendala: widget.isTerkendala
              ),
              const SizedBox(height: 16),
            ],
            _buildImageSection(
              title: 'After',
              isAfter: true,
              existingUrl: _afterUrl,
              newImage: _newAfter,
              isRequired: !widget.isTerkendala,
              isTerkendala: widget.isTerkendala
            ),
            const SizedBox(height: 20),
            _buildNoteSection(widget.isTerkendala),
            const SizedBox(height: 24),
            _buildUpdateButton(workOrder),
          ],
        ),
      ),
    );
  }

  Widget _buildNoteSection(bool isTerkendala) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Text(
              'Note',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: AppColors.black,
              ),
            ),
            const SizedBox(width: 4),
            if (isTerkendala)
              const Text(
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

  Widget _buildUpdateButton(WorkOrder workOrder) {
    return ElevatedButton(
      onPressed: _isLoading ? null : () => _updateReport(workOrder.title),
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
              'Update Report',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
    );
  }
}