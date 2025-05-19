import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:pantau_app/core/constant/colors.dart';
import 'package:pantau_app/features/create_work_order/presentation/providers/create_work_order_provider.dart';

class CreateWorkOrderScreen extends ConsumerStatefulWidget {
  static const String route = '/createworkorder';

  const CreateWorkOrderScreen({super.key});

  @override
  ConsumerState<CreateWorkOrderScreen> createState() => _CreateWorkOrderScreenState();
}

class _CreateWorkOrderScreenState extends ConsumerState<CreateWorkOrderScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  DateTime? _endTime;
  String? _selectedCategoryId;
  bool _isSubmitting = false;

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    ref.listen<AsyncValue<void>>(createWorkOrderProvider, (_, state) {
      state.when(
        data: (_) => _createSuccess(),
        loading: () => setState(() => _isSubmitting = true),
        error: (e, _) {
          setState(() => _isSubmitting = false);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(e.toString()),
              backgroundColor: AppColors.errorColor,
            ),
          );
        },
      );
    });

    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.backgroundColor,
        scrolledUnderElevation: 0,
        elevation: 0,
        title: const Text(
          "Create Work Order",
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold
          ) 
        ),
        centerTitle: true,
      ),
      backgroundColor: AppColors.backgroundColor,
      body: Form(
        key: _formKey,
        child: _buildBody(),
      ),
    );
  }

  void _createSuccess() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Work order created successfully'),
        backgroundColor: AppColors.successColor,
      ),
    );
    Navigator.of(context).pop();
  }

  Widget _buildBody() {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildBasicInfoSection(),
          const SizedBox(height: 24),
          _buildDateTimeSection(),
          const SizedBox(height: 32),
          _buildActionButtons(),
        ],
      ),
    );
  }

  Widget _buildBasicInfoSection() {
    return Card(
      elevation: 0,
      color: AppColors.cardColor,
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
                hintText: 'Enter work order title...',
                filled: true,
                fillColor: AppColors.cardColor,
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
                hintText: 'Enter work order description...',
                filled: true,
                fillColor: AppColors.cardColor,
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
        color: AppColors.cardColor,
        borderRadius: BorderRadius.circular(10),
      ),
      child: DropdownButtonFormField<String>(
        dropdownColor: AppColors.cardColor,
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
            child: Text('-'),
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
      color: AppColors.cardColor,
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
            
            // Due Date (editable)
            _buildFieldLabel('Due Date'),
            const SizedBox(height: 8),
            InkWell(
              onTap: () => _selectDateTime(context),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                decoration: BoxDecoration(
                  color: AppColors.cardColor,
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
            onPressed: _isSubmitting ? null : () async {
              if (_formKey.currentState!.validate()) {
                await ref.read(createWorkOrderProvider.notifier).create(
                  title: _titleController.text,
                  description: _descriptionController.text,
                  endTime: _endTime,
                  categoryId: _selectedCategoryId
                );
              }
            },
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
            label: Text(_isSubmitting ? 'Saving...' : 'Create Work Order'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primaryColor,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              elevation: 0,
              disabledBackgroundColor: AppColors.primaryColor.withAlpha(77),
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
        });
      }
    }
  }
}