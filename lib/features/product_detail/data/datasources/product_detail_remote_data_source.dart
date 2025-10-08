import 'package:dio/dio.dart';
import 'package:mini_catalog/core/const/api_constants.dart';
import '../../../catalog/data/models/product_model.dart';

abstract class ProductDetailRemoteDataSource {
  Future<ProductModel> fetchProductDetail(String productId);
}

class ProductDetailRemoteDataSourceImpl
    implements ProductDetailRemoteDataSource {
  final Dio dio;

  ProductDetailRemoteDataSourceImpl({required this.dio});

  @override
  Future<ProductModel> fetchProductDetail(String productId) async {
    try {
      final response = await dio.get('${ApiConstants.products}/$productId');

      if (response.statusCode == 200) {
        return ProductModel.fromJson(response.data);
      } else {
        throw Exception(
          'Failed to fetch product detail (status: ${response.statusCode})',
        );
      }
    } catch (e) {
      throw Exception('Failed to fetch product detail: $e');
    }
  }
}
