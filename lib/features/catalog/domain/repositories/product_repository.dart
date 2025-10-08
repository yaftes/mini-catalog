import 'package:dartz/dartz.dart';
import '../entities/product.dart';
import '../../../../core/errors/failures.dart';

abstract class ProductRepository {
  Future<Either<Failure, List<Product>>> fetchProducts({
    required int page,
    int limit = 20,
    String? query,
    String? category,
  });

  Future<Either<Failure, List<String>>> fetchCategories();

  Future<Either<Failure, Product>> fetchProductDetail(int id);
}
