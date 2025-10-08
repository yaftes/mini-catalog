import 'package:dartz/dartz.dart';
import 'package:mini_catalog/features/catalog/data/models/product_model.dart';
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
    int limit = 20,
    String? query,
    String? category,
  }) async {
    try {
      final isOnline = await networkInfo.isConnected;
      List<Product> products;

      if (isOnline) {
        final productModels = await remote.getProducts();

        products = productModels.map((model) => model.toEntity()).toList();

        if (category != null && category.isNotEmpty) {
          products = products.where((p) => p.category == category).toList();
        }

        if (query != null && query.isNotEmpty) {
          products = products
              .where((p) => p.title.toLowerCase().contains(query.toLowerCase()))
              .toList();
        }

        if (page == 1) {
          final productModels = products
              .map(
                (product) => ProductModel(
                  id: product.id,
                  title: product.title,
                  price: product.price,
                  description: product.description,
                  category: product.category,
                  image: product.image,
                ),
              )
              .toList();

          await local.cacheProducts(productModels);
        }
      } else {
        final cached = await local.getCachedProducts();
        if (cached.isNotEmpty) {
          products = cached;
        } else {
          return Left(NetworkFailure('No internet connection'));
        }
      }

      final start = (page - 1) * limit;
      final end = start + limit;
      final paged = products.sublist(
        start,
        end > products.length ? products.length : end,
      );

      return Right(paged);
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
        return Left(NetworkFailure('No internet connection'));
      }
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }
}
