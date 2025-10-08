import 'package:dio/dio.dart';
import '../models/product_model.dart';

abstract class ProductRemoteDataSource {
  Future<List<ProductModel>> getProducts();
  Future<List<String>> getCategories();
}

class ProductRemoteDataSourceImpl implements ProductRemoteDataSource {
  final Dio dio;

  ProductRemoteDataSourceImpl(this.dio);

  @override
  Future<List<ProductModel>> getProducts() async {
    final response = await dio.get('https://fakestoreapi.com/products');
    return (response.data as List)
        .map((json) => ProductModel.fromJson(json))
        .toList();
  }

  @override
  Future<List<String>> getCategories() async {
    final response = await dio.get(
      'https://fakestoreapi.com/products/categories',
    );
    return List<String>.from(response.data);
  }
}
