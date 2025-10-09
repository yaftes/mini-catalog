import 'package:dio/dio.dart';
import 'package:mini_catalog/core/const/api_constants.dart';
import '../models/product_model.dart';
import '../../../../core/errors/exceptions.dart';

abstract class ProductRemoteDataSource {
  Future<List<ProductModel>> getProducts({
    required int page,
    required int limit,
    String? query,
    String? category,
  });

  Future<List<String>> getCategories();
}

class ProductRemoteDataSourceImpl implements ProductRemoteDataSource {
  final Dio dio;

  ProductRemoteDataSourceImpl(this.dio);

  @override
  Future<List<ProductModel>> getProducts({
    required int page,
    required int limit,
    String? query,
    String? category,
  }) async {
    try {
      final response = await dio.get(
        ApiConstants.products,
        queryParameters: {
          'page': page,
          'limit': limit,
          if (query != null && query.isNotEmpty) 'q': query,
          if (category != null && category.isNotEmpty) 'category': category,
        },
      );

      if (response.statusCode == 200) {
        return (response.data as List)
            .map((json) => ProductModel.fromJson(json))
            .toList();
      } else {
        throw ServerException(
          'Failed to fetch products: ${response.statusCode}',
        );
      }
    } catch (e) {
      throw ServerException(e.toString());
    }
  }

  @override
  Future<List<String>> getCategories() async {
    try {
      final response = await dio.get(ApiConstants.categories);

      if (response.statusCode == 200) {
        return List<String>.from(response.data);
      } else {
        throw ServerException(
          'Failed to fetch categories: ${response.statusCode}',
        );
      }
    } catch (e) {
      throw ServerException(e.toString());
    }
  }
}
