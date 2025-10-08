import 'package:hive/hive.dart';
import '../models/product_model.dart';

abstract class ProductLocalDataSource {
  Future<void> cacheProducts(List<ProductModel> products);
  Future<List<ProductModel>> getCachedProducts();
}

class ProductLocalDataSourceImpl implements ProductLocalDataSource {
  final Box box;

  ProductLocalDataSourceImpl(this.box);

  @override
  Future<void> cacheProducts(List<ProductModel> products) async {
    await box.put('cached_products', products.map((p) => p.toJson()).toList());
  }

  @override
  Future<List<ProductModel>> getCachedProducts() async {
    final cached = box.get('cached_products', defaultValue: []);
    return (cached as List)
        .map((json) => ProductModel.fromJson(Map<String, dynamic>.from(json)))
        .toList();
  }
}
