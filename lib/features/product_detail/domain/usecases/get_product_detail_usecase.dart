import 'package:dartz/dartz.dart';
import '../repositories/product_detail_repository.dart';
import '../../../../core/errors/failures.dart';
import '../../../catalog/domain/entities/product.dart';

class GetProductDetail {
  final ProductDetailRepository repository;

  GetProductDetail(this.repository);

  Future<Either<Failure, Product>> call(int id) async {
    return await repository.fetchProductDetail(id);
  }
}
