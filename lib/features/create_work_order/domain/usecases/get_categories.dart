import 'package:pantau_app/features/create_work_order/data/repositories/category_repository_impl.dart';
import 'package:pantau_app/features/create_work_order/domain/entities/category.dart';

class GetCategories {
  final CategoryRepository repository;

  GetCategories(this.repository);

  Future<List<Category>> call() async {
    return await repository.getCategories();
  }
}