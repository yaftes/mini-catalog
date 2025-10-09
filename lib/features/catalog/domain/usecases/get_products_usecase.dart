import 'package:dartz/dartz.dart';
import '../entities/product.dart';
import '../repositories/product_repository.dart';
import '../../../../core/errors/failures.dart';

class GetProductsUsecase {
  final ProductRepository repository;

  GetProductsUsecase(this.repository);

  Future<Either<Failure, List<Product>>> call({
    required int page,
    int limit = 10,
    String? query,
    String? category,
  }) async {
    return await repository.fetchProducts(
      page: page,
      limit: limit,
      query: query,
      category: category,
    );
  }
}
