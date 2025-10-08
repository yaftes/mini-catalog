import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../../../catalog/domain/entities/product.dart';

abstract class ProductDetailRepository {
  Future<Either<Failure, Product>> fetchProductDetail(String id);
}
