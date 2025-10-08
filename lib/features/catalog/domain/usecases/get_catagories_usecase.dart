import 'package:dartz/dartz.dart';
import '../repositories/product_repository.dart';
import '../../../../core/errors/failures.dart';

class GetCategoriesUsecase {
  final ProductRepository repository;

  GetCategoriesUsecase(this.repository);

  Future<Either<Failure, List<String>>> call() async {
    return await repository.fetchCategories();
  }
}
