import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:pantau_app/common/widgets/custom_app_bar.dart';
import 'package:pantau_app/common/widgets/layout/app_scaffold.dart';
import 'package:pantau_app/core/constant/colors.dart';
import 'package:pantau_app/features/work/domain/models/work_order.dart';
import 'package:pantau_app/features/work_order_edit/presentation/viewmodels/work_order_edit_viewmodel.dart';

class WorkOrderEditScreen extends ConsumerStatefulWidget {
  static const String route = '/workorder/edit';
  final WorkOrder workOrder;

  const WorkOrderEditScreen({
    super.key,
    required this.workOrder,
  });

  @override
  ConsumerState<WorkOrderEditScreen> createState() => _WorkOrderEditScreenState();
}

class _WorkOrderEditScreenState extends ConsumerState<WorkOrderEditScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _titleController;
  late TextEditingController _descriptionController;
  String? _selectedCategoryId;
  DateTime? _endTime;
  bool _isSubmitting = false;
  bool _hasUnsavedChanges = false;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.workOrder.title);
    _descriptionController = TextEditingController(text: widget.workOrder.description);
    _selectedCategoryId = widget.workOrder.categoryId;
    _endTime = widget.workOrder.endTime;
    
    // Add listeners to detect changes
    _titleController.addListener(_onFormChanged);
    _descriptionController.addListener(_onFormChanged);
  }

  void _onFormChanged() {
    if (!_hasUnsavedChanges) {
      setState(() => _hasUnsavedChanges = true);
    }
  }

  @override
  void dispose() {
    _titleController.removeListener(_onFormChanged);
    _descriptionController.removeListener(_onFormChanged);
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: _onWillPop,
      child: Scaffold(
        appBar: const CustomAppBar(
          title: "Edit Work Order",
          showBackButton: true,
          // actions: [
          //   if (_hasUnsavedChanges)
          //     Container(
          //       margin: const EdgeInsets.only(right: 16),
          //       child: Chip(
          //         label: const Text('Unsaved'),
          //         labelStyle: const TextStyle(color: Colors.white, fontSize: 12),
          //         backgroundColor: AppColors.warningColor,
          //         padding: EdgeInsets.zero,
          //         visualDensity: VisualDensity.compact,
          //       ),
          //     ),
          // ],
        ),
        body: Form(
          key: _formKey,
          child: _buildBody(),
        ),
      ),
    );
  }

  Widget _buildBody() {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildInfoCard(),
          const SizedBox(height: 24),
          _buildBasicInfoSection(),
          const SizedBox(height: 24),
          _buildDateTimeSection(),
          const SizedBox(height: 32),
          _buildActionButtons(),
        ],
      ),
    );
  }

  Widget _buildInfoCard() {
    return Card(
      elevation: 0,
      color: AppColors.primaryColor.withOpacity(0.1),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: AppColors.primaryColor.withOpacity(0.3)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            const Icon(
              Icons.info_outline,
              color: AppColors.primaryColor,
              size: 24,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Editing Work Order',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: AppColors.primaryColor,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'ID: ${widget.workOrder.id.substring(0, 8)}...',
                    style: TextStyle(
                      color: Colors.grey[700],
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
            _buildStatusChip(widget.workOrder.status),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusChip(String status) {
    final Map<String, Map<String, dynamic>> statusConfig = {
      'belum_mulai': {
        'color': Colors.grey,
        'label': 'Not Started',
      },
      'dalam_pengerjaan': {
        'color': AppColors.primaryColor,
        'label': 'In Progress',
      },
      'terkendala': {
        'color': AppColors.warningColor,
        'label': 'Blocked',
      },
      'selesai': {
        'color': AppColors.successColor,
        'label': 'Completed',
      },
    };
    
    final config = statusConfig[status] ?? statusConfig['belum_mulai']!;
    
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: config['color'].withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: config['color'], width: 1),
      ),
      child: Text(
        config['label'],
        style: TextStyle(
          color: config['color'],
          fontWeight: FontWeight.bold,
          fontSize: 12,
        ),
      ),
    );
  }

  Widget _buildBasicInfoSection() {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: Colors.grey.shade200),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSectionHeader('Basic Information', Icons.edit_document),
            const SizedBox(height: 16),
            
            // Title Field
            _buildFieldLabel('Title', isRequired: true),
            const SizedBox(height: 8),
            TextFormField(
              controller: _titleController,
              decoration: InputDecoration(
                hintText: 'Enter work order title',
                filled: true,
                fillColor: AppColors.backgroundColor,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide.none,
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 16,
                ),
              ),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Please enter a title';
                }
                return null;
              },
            ),
            const SizedBox(height: 20),
            
            // Description Field
            _buildFieldLabel('Description', isRequired: true),
            const SizedBox(height: 8),
            TextFormField(
              controller: _descriptionController,
              decoration: InputDecoration(
                hintText: 'Enter work order description',
                filled: true,
                fillColor: AppColors.backgroundColor,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide.none,
                ),
                contentPadding: const EdgeInsets.all(16),
              ),
              maxLines: 5,
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Please enter a description';
                }
                return null;
              },
            ),
            const SizedBox(height: 20),
            
            // Category Dropdown
            _buildFieldLabel('Category'),
            const SizedBox(height: 8),
            _buildCategoryDropdown(),
          ],
        ),
      ),
    );
  }

  Widget _buildCategoryDropdown() {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.backgroundColor,
        borderRadius: BorderRadius.circular(10),
      ),
      child: DropdownButtonFormField<String>(
        value: _selectedCategoryId,
        decoration: InputDecoration(
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: BorderSide.none,
          ),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 16,
          ),
        ),
        items: const [
          DropdownMenuItem<String>(
            value: null,
            child: Text('General'),
          ),
          DropdownMenuItem<String>(
            value: '81e188a8-e7e4-401b-8a16-300d92e53abe',
            child: Text('Basement'),
          ),
          DropdownMenuItem<String>(
            value: '3b39fcc9-710c-4dd4-a26a-f5ce854cb038',
            child: Text('GF'),
          ),
          DropdownMenuItem<String>(
            value: '1f0973f6-f92c-4b65-9cd8-8d82e897d1ae',
            child: Text('Lt. 1'),
          ),
          DropdownMenuItem<String>(
            value: '156d317c-d94a-4e3d-9cf5-da90681b3a60',
            child: Text('Lt. 2'),
          ),
          DropdownMenuItem<String>(
            value: 'b3955121-15ec-4b75-acc7-20be78921f66',
            child: Text('Lt. 3'),
          ),
          DropdownMenuItem<String>(
            value: '45cc0e22-76b3-42a5-b61f-6ffde101624b',
            child: Text('Rooftop'),
          ),
        ],
        onChanged: (value) {
          setState(() {
            _selectedCategoryId = value;
            _hasUnsavedChanges = true;
          });
        },
        icon: const Icon(Icons.keyboard_arrow_down),
        isExpanded: true,
        hint: const Text('Select a category'),
      ),
    );
  }

  Widget _buildDateTimeSection() {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: Colors.grey.shade200),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSectionHeader('Schedule', Icons.calendar_today),
            const SizedBox(height: 16),
            
            // Start Time (read-only)
            _buildReadOnlyTimeField(
              'Start Time',
              widget.workOrder.startTime != null 
                ? DateFormat('dd MMM yyyy, HH:mm').format(widget.workOrder.startTime!)
                : 'Not scheduled',
              Icons.play_circle_outline,
            ),
            const SizedBox(height: 20),
            
            // Due Date (editable)
            _buildFieldLabel('Due Date'),
            const SizedBox(height: 8),
            InkWell(
              onTap: () => _selectDateTime(context),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                decoration: BoxDecoration(
                  color: AppColors.backgroundColor,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.event, color: AppColors.primaryColor),
                    const SizedBox(width: 12),
                    Text(
                      _endTime != null
                          ? DateFormat('dd MMM yyyy, HH:mm').format(_endTime!)
                          : 'Select due date and time',
                      style: TextStyle(
                        color: _endTime != null ? Colors.black : Colors.grey[600],
                      ),
                    ),
                    const Spacer(),
                    if (_endTime != null)
                      IconButton(
                        icon: const Icon(Icons.clear, size: 20),
                        onPressed: () {
                          setState(() {
                            _endTime = null;
                            _hasUnsavedChanges = true;
                          });
                        },
                        color: Colors.grey[600],
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(),
                      ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildReadOnlyTimeField(String label, String value, IconData icon) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildFieldLabel(label),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          decoration: BoxDecoration(
            color: Colors.grey[100],
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: Colors.grey[300]!, width: 1),
          ),
          child: Row(
            children: [
              Icon(icon, color: Colors.grey[600]),
              const SizedBox(width: 12),
              Text(
                value,
                style: TextStyle(color: Colors.grey[800]),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSectionHeader(String title, IconData icon) {
    return Row(
      children: [
        Icon(icon, color: AppColors.primaryColor, size: 20),
        const SizedBox(width: 8),
        Text(
          title,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  Widget _buildFieldLabel(String label, {bool isRequired = false}) {
    return RichText(
      text: TextSpan(
        children: [
          TextSpan(
            text: label,
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[700],
              fontWeight: FontWeight.w500,
            ),
          ),
          if (isRequired)
            const TextSpan(
              text: ' *',
              style: TextStyle(
                fontSize: 14,
                color: AppColors.errorColor,
                fontWeight: FontWeight.bold,
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildActionButtons() {
    return Column(
      children: [
        SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            onPressed: _isSubmitting || !_hasUnsavedChanges ? null : _submitForm,
            icon: _isSubmitting
                ? const SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.white,
                    ),
                  )
                : const Icon(
                  Icons.save,
                  color: Colors.white,
                ),
            label: Text(_isSubmitting ? 'Saving...' : 'Save Changes'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primaryColor,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              elevation: 0,
              disabledBackgroundColor: AppColors.primaryColor.withOpacity(0.3),
            ),
          ),
        ),
        const SizedBox(height: 16),
        SizedBox(
          width: double.infinity,
          child: OutlinedButton.icon(
            onPressed: _isSubmitting ? null : () => Navigator.pop(context),
            icon: const Icon(Icons.cancel),
            label: const Text('Cancel'),
            style: OutlinedButton.styleFrom(
              foregroundColor: Colors.grey[700],
              side: BorderSide(color: Colors.grey[400]!),
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Future<void> _selectDateTime(BuildContext context) async {
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: _endTime ?? DateTime.now(),
      firstDate: DateTime.now().subtract(const Duration(days: 365)),
      lastDate: DateTime.now().add(const Duration(days: 365 * 2)),
      builder: (BuildContext context, Widget? child) {
        return Theme(
          data: ThemeData.light().copyWith(
            colorScheme: const ColorScheme.light(
              primary: AppColors.primaryColor,
              onPrimary: Colors.white,
              surface: Colors.white,
              onSurface: Colors.black,
            ),
          ),
          child: child!,
        );
      },
    );

    if (pickedDate != null) {
      // ignore: use_build_context_synchronously
      final TimeOfDay? pickedTime = await showTimePicker(
        context: context,
        initialTime: _endTime != null
            ? TimeOfDay.fromDateTime(_endTime!)
            : TimeOfDay.now(),
        builder: (BuildContext context, Widget? child) {
          return Theme(
            data: ThemeData.light().copyWith(
              colorScheme: const ColorScheme.light(
                primary: AppColors.primaryColor,
                onPrimary: Colors.white,
                surface: Colors.white,
                onSurface: Colors.black,
              ),
            ),
            child: child!,
          );
        },
      );

      if (pickedTime != null) {
        setState(() {
          _endTime = DateTime(
            pickedDate.year,
            pickedDate.month,
            pickedDate.day,
            pickedTime.hour,
            pickedTime.minute,
          );
          _hasUnsavedChanges = true;
        });
      }
    }
  }

  void _submitForm() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isSubmitting = true;
      });

      try {
        final data = {
          'title': _titleController.text,
          'description': _descriptionController.text,
          'category_id': _selectedCategoryId,
          'end_time': _endTime?.toIso8601String(),
        };

        final result = await ref.read(workOrderEditViewModelProvider.notifier).updateWorkOrder(
          widget.workOrder.id,
          data,
        );

        if (context.mounted) {
          if (result) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Work order updated successfully'),
                backgroundColor: AppColors.successColor,
              ),
            );
            Navigator.pop(context);
            Navigator.pop(context); // Pop dua kali untuk kembali ke yang ada navbar
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Failed to update work order'),
                backgroundColor: AppColors.errorColor,
              ),
            );
            setState(() {
              _isSubmitting = false;
            });
          }
        }
      } catch (e) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error: ${e.toString()}'),
              backgroundColor: AppColors.errorColor,
            ),
          );
          setState(() {
            _isSubmitting = false;
          });
        }
      }
    }
  }

  Future<bool> _onWillPop() async {
    if (!_hasUnsavedChanges) {
      return true;
    }

    // Show confirmation dialog
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Discard changes?'),
        content: const Text('You have unsaved changes. Are you sure you want to discard them?'),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.errorColor,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
            child: const Text('Discard'),
          ),
        ],
      ),
    );

    return result ?? false;
  }
}