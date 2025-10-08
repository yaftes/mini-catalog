import 'package:hive/hive.dart';
import 'package:mini_catalog/core/const/cache_constants.dart';
import '../models/product_model.dart';
import '../../../../core/errors/exceptions.dart';

abstract class ProductLocalDataSource {
  Future<void> cacheProducts(List<ProductModel> products);
  Future<List<ProductModel>> getCachedProducts();
}

class ProductLocalDataSourceImpl implements ProductLocalDataSource {
  final Box box;

  ProductLocalDataSourceImpl(this.box);

  @override
  Future<void> cacheProducts(List<ProductModel> products) async {
    try {
      final jsonList = products.map((p) => p.toJson()).toList();
      await box.put(CacheConstants.cachedProducts, jsonList);
    } catch (e) {
      throw CacheException('Failed to cache products: $e');
    }
  }

  @override
  Future<List<ProductModel>> getCachedProducts() async {
    try {
      final cached = box.get(CacheConstants.cachedProducts);

      if (cached == null || cached is! List) return [];

      return cached
          .map((json) => ProductModel.fromJson(Map<String, dynamic>.from(json)))
          .toList();
    } catch (e) {
      throw CacheException('Failed to get cached products: $e');
    }
  }
}
