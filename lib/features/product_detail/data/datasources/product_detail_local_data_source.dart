import 'package:hive/hive.dart';
import 'package:mini_catalog/core/const/cache_constants.dart';
import 'package:mini_catalog/features/catalog/data/models/product_model.dart';
import '../../../../core/errors/exceptions.dart';

abstract class ProductDetailLocalDataSource {
  Future<void> cacheProductDetail(ProductModel product);
  Future<ProductModel> getCachedProductDetail(String id);
}

class ProductDetailLocalDataSourceImpl implements ProductDetailLocalDataSource {
  final Box box;

  ProductDetailLocalDataSourceImpl({required this.box});

  @override
  Future<void> cacheProductDetail(ProductModel product) async {
    try {
      await box.put(
        '${CacheConstants.cachedProductDetail}_${product.id}',
        product.toJson(),
      );
    } catch (e) {
      throw CacheException('Failed to cache product detail: $e');
    }
  }

  @override
  Future<ProductModel> getCachedProductDetail(String id) async {
    try {
      final cached = box.get('${CacheConstants.cachedProductDetail}_$id');

      if (cached == null) {
        throw CacheException('No cached product found for id $id');
      }

      return ProductModel.fromJson(Map<String, dynamic>.from(cached));
    } catch (e) {
      throw CacheException('Failed to get cached product detail: $e');
    }
  }
}
