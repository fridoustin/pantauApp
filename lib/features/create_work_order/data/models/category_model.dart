import 'package:pantau_app/features/create_work_order/domain/entities/category.dart';

class CategoryModel extends Category {
  CategoryModel({required String id, required String name})
      : super(id: id, name: name);

  factory CategoryModel.fromJson(Map<String, dynamic> json) =>
      CategoryModel(
        id: json['category_id'] as String,
        name: json['lantai'] as String,
      );
}