import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../../../catalog/domain/entities/product.dart';
import '../../domain/repositories/product_detail_repository.dart';
import '../datasources/product_detail_remote_data_source.dart';
import '../../../../core/network/network_info.dart';

class ProductDetailRepositoryImpl implements ProductDetailRepository {
  final ProductDetailRemoteDataSource remoteDataSource;
  final NetworkInfo networkInfo;

  ProductDetailRepositoryImpl({
    required this.remoteDataSource,
    required this.networkInfo,
  });

  @override
  Future<Either<Failure, Product>> fetchProductDetail(String id) async {
    if (await networkInfo.isConnected) {
      try {
        final result = await remoteDataSource.fetchProductDetail(id);
        return Right(result);
      } catch (e) {
        return Left(ServerFailure(e.toString()));
      }
    } else {
      return Left(NetworkFailure('No Internet Connection'));
    }
  }
}
