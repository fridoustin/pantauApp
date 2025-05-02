import 'package:pantau_app/features/create_work_order/data/datasources/category_remote_data_source.dart';
import 'package:pantau_app/features/create_work_order/domain/entities/category.dart';

abstract class CategoryRepository {
  Future<List<Category>> getCategories();
}

class CategoryRepositoryImpl implements CategoryRepository {
  final CategoryRemoteDataSource remote;
  CategoryRepositoryImpl(this.remote);

  @override
  Future<List<Category>> getCategories() async {
    return await remote.fetchCategories();
  }
}