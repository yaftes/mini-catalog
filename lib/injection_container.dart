import 'package:get_it/get_it.dart';
import 'package:dio/dio.dart';
import 'package:hive/hive.dart';
import 'package:internet_connection_checker_plus/internet_connection_checker_plus.dart';
import 'package:mini_catalog/core/const/cache_constants.dart';
import 'package:mini_catalog/features/catalog/domain/usecases/get_catagories_usecase.dart';
import 'features/catalog/data/datasources/product_local_data_source.dart';
import 'features/catalog/data/datasources/product_remote_data_source.dart';
import 'features/catalog/data/repositories/product_repository_impl.dart';
import 'features/catalog/domain/repositories/product_repository.dart';
import 'features/catalog/domain/usecases/get_products_usecase.dart';
import 'features/catalog/presentation/bloc/catalog_bloc.dart';
import 'core/network/network_info.dart';

final sl = GetIt.instance;

Future<void> init() async {
  sl.registerLazySingleton(() => Dio());
  final productBox = await Hive.openBox(CacheConstants.cachedProducts);
  sl.registerLazySingleton(() => productBox);
  sl.registerLazySingleton(() => InternetConnection());

  sl.registerLazySingleton<NetworkInfo>(() => NetworkInfoImpl(sl()));

  sl.registerLazySingleton<ProductRemoteDataSource>(
    () => ProductRemoteDataSourceImpl(sl()),
  );

  sl.registerLazySingleton<ProductLocalDataSource>(
    () => ProductLocalDataSourceImpl(sl()),
  );

  sl.registerLazySingleton<ProductRepository>(
    () => ProductRepositoryImpl(remote: sl(), local: sl(), networkInfo: sl()),
  );

  sl.registerLazySingleton(() => GetProductsUsecase(sl()));
  sl.registerLazySingleton(() => GetCategoriesUsecase(sl()));

  sl.registerFactory(
    () => CatalogBloc(getProductsUseCase: sl(), getCategoriesUseCase: sl()),
  );
}
