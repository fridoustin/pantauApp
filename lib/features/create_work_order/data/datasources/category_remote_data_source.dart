import 'package:pantau_app/features/create_work_order/data/models/category_model.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class CategoryRemoteDataSource {
  final SupabaseClient client;
  CategoryRemoteDataSource(this.client);

  Future<List<CategoryModel>> fetchCategories() async {
    // Supabase v2: select returns List<dynamic> directly
    final result = await client
      .from('category')
      .select()
      .order('lantai', ascending: true);

    return result.map((json) => CategoryModel.fromJson(json)).toList();
  }
}