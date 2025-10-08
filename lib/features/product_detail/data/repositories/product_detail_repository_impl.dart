import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../../../catalog/domain/entities/product.dart';
import '../../domain/repositories/product_detail_repository.dart';
import '../datasources/product_detail_remote_data_source.dart';
import '../datasources/product_detail_local_data_source.dart';
import '../../../../core/network/network_info.dart';
import '../../../../core/errors/exceptions.dart';

class ProductDetailRepositoryImpl implements ProductDetailRepository {
  final ProductDetailRemoteDataSource remoteDataSource;
  final ProductDetailLocalDataSource localDataSource;
  final NetworkInfo networkInfo;

  ProductDetailRepositoryImpl({
    required this.remoteDataSource,
    required this.localDataSource,
    required this.networkInfo,
  });

  @override
  Future<Either<Failure, Product>> fetchProductDetail(String id) async {
    if (await networkInfo.isConnected) {
      try {
        final product = await remoteDataSource.fetchProductDetail(id);
        await localDataSource.cacheProductDetail(product);

        return Right(product);
      } catch (e) {
        return Left(ServerFailure(e.toString()));
      }
    } else {
      try {
        final cachedProduct = await localDataSource.getCachedProductDetail(id);
        return Right(cachedProduct);
      } on CacheException catch (e) {
        return Left(CacheFailure(e.message));
      } catch (e) {
        return Left(CacheFailure('Unexpected error: $e'));
      }
    }
  }
}
