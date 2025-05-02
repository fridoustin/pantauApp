import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
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
  final _descController = TextEditingController();
  DateTime? _startTime;
  DateTime? _endTime;
  String _status = 'belum_mulai';
  String? _selectedCategoryId;

  @override
  void dispose() {
    _titleController.dispose();
    _descController.dispose();
    super.dispose();
  }

  Future<void> _pickDate(BuildContext context, bool isStart) async {
    final now = DateTime.now();
    final date = await showDatePicker(
      context: context,
      initialDate: now,
      firstDate: DateTime(now.year - 5),
      lastDate: DateTime(now.year + 5),
    );
    if (date != null) {
      setState(() {
        if (isStart) {
          _startTime = date;
        } else {
          _endTime = date;
        }
      });
    }
  }

  Widget _buildCategoryDropdown() {
    final asyncCats = ref.watch(categoryListProvider);
    return asyncCats.when(
      data: (cats) => DropdownButtonFormField<String>(
        decoration: const InputDecoration(labelText: 'Category'),
        hint: const Text('Pilih kategori (opsional)'),
        items: cats.map((c) => DropdownMenuItem(
          value: c.id,
          child: Text(c.name),
        )).toList(),
        value: _selectedCategoryId,
        onChanged: (val) => setState(() => _selectedCategoryId = val),
      ),
      loading: () => const SizedBox(),
      error: (e, _) => Text('Error loading categories: $e'),
    );
  }

  @override
  Widget build(BuildContext context) {
    ref.listen<AsyncValue<void>>(createWorkOrderProvider, (_, state) {
      state.when(
        data: (_) => Navigator.of(context).pop(),
        loading: () {},
        error: (e, _) => ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(e.toString()))),
      );
    });

    final state = ref.watch(createWorkOrderProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Create Work Order')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextFormField(
                controller: _titleController,
                decoration: const InputDecoration(labelText: 'Title'),
                validator: (v) => v == null || v.isEmpty ? 'Required' : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _descController,
                decoration: const InputDecoration(labelText: 'Description'),
                maxLines: 3,
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: Text(_startTime == null
                      ? 'Start Date (optional)'
                      : 'Start: ${_startTime!.toLocal().toIso8601String().split('T').first}'),
                  ),
                  TextButton(
                    onPressed: () => _pickDate(context, true),
                    child: const Text('Select'),
                  ),
                ],
              ),
              Row(
                children: [
                  Expanded(
                    child: Text(_endTime == null
                      ? 'End Date (optional)'
                      : 'End: ${_endTime!.toLocal().toIso8601String().split('T').first}'),
                  ),
                  TextButton(
                    onPressed: () => _pickDate(context, false),
                    child: const Text('Select'),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                value: _status,
                items: const [
                  DropdownMenuItem(value: 'belum_mulai', child: Text('Belum Mulai')),
                  DropdownMenuItem(value: 'dalam_pengerjaan', child: Text('Dalam Pengerjaan')),
                  DropdownMenuItem(value: 'selesai', child: Text('Selesai')),
                  DropdownMenuItem(value: 'terkendala', child: Text('Terkendala')),
                ],
                decoration: const InputDecoration(labelText: 'Status'),
                onChanged: (v) => setState(() => _status = v!),
              ),
              const SizedBox(height: 12),
              _buildCategoryDropdown(),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: state is AsyncLoading
                  ? null
                  : () async {
                      if (_formKey.currentState!.validate()) {
                        await ref.read(createWorkOrderProvider.notifier).create(
                          title: _titleController.text,
                          description: _descController.text,
                          startTime: _startTime,
                          endTime: _endTime,
                          status: _status,
                          categoryId: _selectedCategoryId
                        );
                      }
                    },
                child: state is AsyncLoading
                  ? const SizedBox(
                      height: 24,
                      width: 24,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Text('Submit'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}