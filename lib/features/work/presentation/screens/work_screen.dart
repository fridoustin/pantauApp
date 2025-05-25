import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pantau_app/common/widgets/custom_app_bar.dart';
import 'package:pantau_app/common/widgets/layout/app_scaffold.dart';
import 'package:pantau_app/core/constant/colors.dart';
import 'package:pantau_app/features/work/domain/models/work_order.dart';
import 'package:pantau_app/features/work/presentation/providers/work_order_provider.dart';
import 'package:pantau_app/features/work/presentation/widgets/work_order_card.dart';

// Enum for sorting options
enum SortOption {
  newest,
  oldest,
  title,
  status
}

// Provider for search query
final searchQueryProvider = StateProvider<String>((ref) => '');

// Provider for current sort option
final sortOptionProvider = StateProvider<SortOption>((ref) => SortOption.newest);

// Provider for category filter
final categoryFilterProvider = StateProvider<String?>((ref) => null);

// Provider for status filter
final statusFilterProvider = StateProvider<String?>((ref) => null);

// Provider for filtered work orders
final filteredWorkOrdersProvider = Provider.family<List<WorkOrder>, List<WorkOrder>>((ref, workOrders) {
  final searchQuery = ref.watch(searchQueryProvider).toLowerCase();
  final categoryFilter = ref.watch(categoryFilterProvider);
  final statusFilter = ref.watch(statusFilterProvider);
  final sortOption = ref.watch(sortOptionProvider);
  
  // Apply filters
  var filteredList = workOrders.where((order) {
    // Search filter
    final matchesSearch = searchQuery.isEmpty || 
                          order.title.toLowerCase().contains(searchQuery) ||
                          order.description.toLowerCase().contains(searchQuery);
    
    // Category filter
    final matchesCategory = categoryFilter == null || order.categoryId == categoryFilter;
    
    // Status filter
    final matchesStatus = statusFilter == null || order.status == statusFilter;
    
    return matchesSearch && matchesCategory && matchesStatus;
  }).toList();
  
  // Apply sorting
  switch (sortOption) {
    case SortOption.newest:
      filteredList.sort((a, b) => (b.createdAt).compareTo(a.createdAt));
      break;
    case SortOption.oldest:
      filteredList.sort((a, b) => (a.createdAt).compareTo(b.createdAt));
      break;
    case SortOption.title:
      filteredList.sort((a, b) => a.title.toLowerCase().compareTo(b.title.toLowerCase()));
      break;
    case SortOption.status:
      filteredList.sort((a, b) => a.status.compareTo(b.status));
      break;
  }
  
  return filteredList;
});

class WorkScreen extends ConsumerWidget {
  static const String route = '/work';
  const WorkScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final mode = ref.watch(workModeProvider);
    final asyncWorkOrders = mode == WorkMode.todo
        ? ref.watch(toDoWorkOrdersProvider)
        : ref.watch(historyWorkOrdersProvider);
    
    return AppScaffold(
      appBar: const CustomAppBar(title: "Work"),
      currentIndex: 1,
      floatingActionButton: FloatingActionButton(
        onPressed: () => Navigator.pushNamed(context, '/createworkorder'),
        backgroundColor: AppColors.primaryColor,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: const Icon(Icons.add, color: Colors.white),
      ),
      child: Column(
        children: [
          // Mode Selector (To Do & History)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.05),
                    spreadRadius: 1,
                    blurRadius: 3,
                    offset: const Offset(0, 1),
                  ),
                ],
              ),
              child: Padding(
                padding: const EdgeInsets.all(4.0),
                child: Row(
                  children: [
                    Expanded(
                      child: _ModeButton(
                        title: "To Do",
                        isSelected: mode == WorkMode.todo,
                        onPressed: () {
                          ref.read(workModeProvider.notifier).state = WorkMode.todo;
                          // Reset filters when switching modes
                          ref.read(searchQueryProvider.notifier).state = '';
                          ref.read(categoryFilterProvider.notifier).state = null;
                          ref.read(statusFilterProvider.notifier).state = null;
                        },
                      ),
                    ),
                    Expanded(
                      child: _ModeButton(
                        title: "History",
                        isSelected: mode == WorkMode.history,
                        onPressed: () {
                          ref.read(workModeProvider.notifier).state = WorkMode.history;
                          // Reset filters when switching modes
                          ref.read(searchQueryProvider.notifier).state = '';
                          ref.read(categoryFilterProvider.notifier).state = null;
                          ref.read(statusFilterProvider.notifier).state = null;
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          
          // Search Bar
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: _SearchBar(),
          ),
          
          // Filter and Sort Options
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: _FilterSortBar(),
          ),
          
          // Work Order List
          Expanded(
            child: asyncWorkOrders.when(
              data: (workOrderList) {
                // Apply filters and sorting
                final filteredList = ref.watch(filteredWorkOrdersProvider(workOrderList));
                
                return filteredList.isEmpty
                  ? _buildEmptyState(mode)
                  : ListView.builder(
                      padding: const EdgeInsets.all(16),
                      itemCount: filteredList.length,
                      itemBuilder: (context, index) {
                        final workOrder = filteredList[index];
                        return WorkOrderCard(workOrder: workOrder);
                      },
                    );
              },
              loading: () => const Center(child: CircularProgressIndicator(color: AppColors.primaryColor)),
              error: (e, _) => Center(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(
                        Icons.error_outline,
                        size: 64,
                        color: AppColors.errorColor,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Terjadi kesalahan',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      // const SizedBox(height: 8),
                      // Text(
                      //   'Error: ${error.toString()}',
                      //   style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      //     color: Colors.grey[600],
                      //   ),
                      //   textAlign: TextAlign.center,
                      // ),
                      const SizedBox(height: 24),
                      ElevatedButton.icon(
                        onPressed: () {
                          final currentMode = ref.read(workModeProvider);
                          if (currentMode == WorkMode.todo) {
                            ref.invalidate(toDoWorkOrdersProvider);
                          } else {
                            ref.invalidate(historyWorkOrdersProvider);
                          }
                        },
                        icon: const Icon(
                          Icons.refresh,
                          color: Colors.white
                        ),
                        label: const Text('Coba Lagi'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primaryColor,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 24,
                            vertical: 12,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildEmptyState(WorkMode mode) {
    String message = mode == WorkMode.todo 
      ? "No work orders" 
      : "No completed work orders";
    
    IconData icon = mode == WorkMode.todo 
      ? Icons.assignment_outlined 
      : Icons.history;
    
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 64, color: Colors.grey[400]),
            const SizedBox(height: 16),
            Text(
              message,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w500,
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 8),
            Text(
              mode == WorkMode.todo 
                ? "Your not completed work orders will appear here." 
                : "Your completed work orders will appear here.",
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.grey[500],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ModeButton extends StatelessWidget {
  final String title;
  final bool isSelected;
  final VoidCallback onPressed;

  const _ModeButton({
    required this.title,
    required this.isSelected,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onPressed,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primaryColor : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Center(
          child: Text(
            title,
            style: TextStyle(
              color: isSelected ? Colors.white : AppColors.black,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            ),
          ),
        ),
      ),
    );
  }
}

class _SearchBar extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            spreadRadius: 1,
            blurRadius: 3,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: TextField(
        onChanged: (value) {
          ref.read(searchQueryProvider.notifier).state = value;
        },
        decoration: InputDecoration(
          hintText: 'Search work orders...',
          prefixIcon: const Icon(Icons.search, color: AppColors.primaryColor),
          suffixIcon: Consumer(
            builder: (context, ref, _) {
              final query = ref.watch(searchQueryProvider);
              return query.isNotEmpty
                ? IconButton(
                    icon: const Icon(Icons.clear, color: Colors.grey),
                    onPressed: () {
                      ref.read(searchQueryProvider.notifier).state = '';
                    },
                  )
                : const SizedBox.shrink();
            },
          ),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
        ),
      ),
    );
  }
}

class _FilterSortBar extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final hasActiveFilters = ref.watch(categoryFilterProvider) != null || 
                            ref.watch(statusFilterProvider) != null;
    
    return Row(
      children: [
        // Filter Button
        Expanded(
          child: InkWell(
            onTap: () => _showFilterDialog(context, ref),
            borderRadius: BorderRadius.circular(12),
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
              decoration: BoxDecoration(
                color: hasActiveFilters ? AppColors.primaryColor.withValues(alpha: 0.1) : Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: hasActiveFilters ? AppColors.primaryColor : Colors.grey[300]!,
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.filter_list,
                    color: hasActiveFilters ? AppColors.primaryColor : Colors.grey[600],
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Filter',
                    style: TextStyle(
                      color: hasActiveFilters ? AppColors.primaryColor : Colors.grey[800],
                      fontWeight: hasActiveFilters ? FontWeight.bold : FontWeight.normal,
                    ),
                  ),
                  if (hasActiveFilters) ...[
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.all(6),
                      decoration: const BoxDecoration(
                        color: AppColors.primaryColor,
                        shape: BoxShape.circle,
                      ),
                      child: const Text(
                        '!',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 10,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
        
        const SizedBox(width: 12),
        
        // Sort Button
        Expanded(
          child: InkWell(
            onTap: () => _showSortDialog(context, ref),
            borderRadius: BorderRadius.circular(12),
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey[300]!),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.sort,
                    color: Colors.grey[600],
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Sort',
                    style: TextStyle(
                      color: Colors.grey[800],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
  
  void _showFilterDialog(BuildContext context, WidgetRef ref) {
    final categories = {
      '81e188a8-e7e4-401b-8a16-300d92e53abe': 'Basement',
      '3b39fcc9-710c-4dd4-a26a-f5ce854cb038': 'GF',
      '1f0973f6-f92c-4b65-9cd8-8d82e897d1ae': 'Lt. 1',
      '156d317c-d94a-4e3d-9cf5-da90681b3a60': 'Lt. 2',
      'b3955121-15ec-4b75-acc7-20be78921f66': 'Lt. 3',
      '45cc0e22-76b3-42a5-b61f-6ffde101624b': 'Rooftop',
    };
    
    final statuses = {
      'selesai': 'Selesai',
      'dalam_pengerjaan': 'Dalam Pengerjaan',
      'terkendala': 'Terkendala',
      'belum_mulai': 'Belum Mulai',
    };
    
    showDialog(
      context: context,
      builder: (context) {
        return Consumer(
          builder: (context, ref, _) {
            final selectedCategory = ref.watch(categoryFilterProvider);
            final selectedStatus = ref.watch(statusFilterProvider);
            
            return AlertDialog(
              title: const Text('Filter Work Orders'),
              backgroundColor: AppColors.cardColor,
              content: SizedBox(
                width: double.maxFinite,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Categories',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        ...categories.entries.map(
                          (entry) => _FilterChip(
                            label: entry.value,
                            isSelected: selectedCategory == entry.key,
                            onTap: () {
                              ref.read(categoryFilterProvider.notifier).state = 
                                selectedCategory == entry.key ? null : entry.key;
                            },
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'Status',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        ...statuses.entries.map(
                          (entry) => _FilterChip(
                            label: entry.value,
                            isSelected: selectedStatus == entry.key,
                            onTap: () {
                              ref.read(statusFilterProvider.notifier).state = 
                                selectedStatus == entry.key ? null : entry.key;
                            },
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    // Reset all filters
                    ref.read(categoryFilterProvider.notifier).state = null;
                    ref.read(statusFilterProvider.notifier).state = null;
                    Navigator.of(context).pop();
                  },
                  child: const Text('Clear All'),
                ),
                ElevatedButton(
                  onPressed: () => Navigator.of(context).pop(),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryColor,
                    foregroundColor: Colors.white,
                  ),
                  child: const Text('Apply'),
                ),
              ],
            );
          },
        );
      },
    );
  }
  
  void _showSortDialog(BuildContext context, WidgetRef ref) {
    final sortOptions = {
      SortOption.newest: 'Newest First',
      SortOption.oldest: 'Oldest First',
      SortOption.title: 'Title (A-Z)',
      SortOption.status: 'Status',
    };
    
    showDialog(
      context: context,
      builder: (context) {
        return Consumer(
          builder: (context, ref, _) {
            final selectedOption = ref.watch(sortOptionProvider);
            
            return AlertDialog(
              title: const Text('Sort By'),
              backgroundColor: AppColors.cardColor,
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: sortOptions.entries.map(
                  (entry) => RadioListTile<SortOption>(
                    title: Text(entry.value),
                    value: entry.key,
                    groupValue: selectedOption,
                    onChanged: (value) {
                      ref.read(sortOptionProvider.notifier).state = value!;
                      Navigator.of(context).pop();
                    },
                    activeColor: AppColors.primaryColor,
                  ),
                ).toList(),
              ),
            );
          },
        );
      },
    );
  }
}

class _FilterChip extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _FilterChip({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primaryColor : Colors.grey[100],
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? AppColors.primaryColor : Colors.grey[300]!,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? Colors.white : Colors.grey[800],
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          ),
        ),
      ),
    );
  }
}