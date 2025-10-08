import 'package:dartz/dartz.dart';
import '../repositories/product_detail_repository.dart';
import '../../../../core/errors/failures.dart';
import '../../../catalog/domain/entities/product.dart';

class GetProductDetailUsecase {
  final ProductDetailRepository repository;

  GetProductDetailUsecase(this.repository);

  Future<Either<Failure, Product>> call(String id) async {
    return await repository.fetchProductDetail(id);
  }
}
