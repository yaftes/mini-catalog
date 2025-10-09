import 'package:dartz/dartz.dart';
import 'package:mini_catalog/features/catalog/domain/entities/product.dart';
import 'package:mini_catalog/features/catalog/domain/repositories/product_repository.dart';
import '../datasources/product_local_data_source.dart';
import '../datasources/product_remote_data_source.dart';
import '../../../../core/errors/exceptions.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/network/network_info.dart';

class ProductRepositoryImpl implements ProductRepository {
  final ProductRemoteDataSource remote;
  final ProductLocalDataSource local;
  final NetworkInfo networkInfo;

  ProductRepositoryImpl({
    required this.remote,
    required this.local,
    required this.networkInfo,
  });

  @override
  Future<Either<Failure, List<Product>>> fetchProducts({
    required int page,
    int limit = 10,
    String? query,
    String? category,
  }) async {
    try {
      final isOnline = await networkInfo.isConnected;

      if (isOnline) {
        final productModels = await remote.getProducts(
          page: page,
          limit: limit,
          query: query,
          category: category,
        );

        final products = productModels.map((e) => e.toEntity()).toList();

        if (page == 1) {
          await local.cacheProducts(productModels);
        }

        return Right(products);
      } else {
        final cached = await local.getCachedProducts();
        if (cached.isNotEmpty) {
          return Right(cached);
        } else {
          return Left(NetworkFailure('Please check your internet connection'));
        }
      }
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } on CacheException catch (e) {
      return Left(CacheFailure(e.message));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<String>>> fetchCategories() async {
    try {
      final isOnline = await networkInfo.isConnected;

      if (isOnline) {
        final categories = await remote.getCategories();
        return Right(categories);
      } else {
        return Left(NetworkFailure('Please check your internet connection'));
      }
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }
}
