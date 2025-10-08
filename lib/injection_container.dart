import 'package:get_it/get_it.dart';
import 'package:dio/dio.dart';
import 'package:hive/hive.dart';
import 'package:internet_connection_checker_plus/internet_connection_checker_plus.dart';
import 'package:mini_catalog/features/product_detail/presentation/bloc/product_detail_bloc.dart';
import 'package:path_provider/path_provider.dart';
import 'package:mini_catalog/core/const/cache_constants.dart';
import 'package:mini_catalog/core/network/network_info.dart';
import 'features/catalog/data/datasources/product_local_data_source.dart';
import 'features/catalog/data/datasources/product_remote_data_source.dart';
import 'features/catalog/data/repositories/product_repository_impl.dart';
import 'features/catalog/domain/repositories/product_repository.dart';
import 'features/catalog/domain/usecases/get_products_usecase.dart';
import 'features/catalog/domain/usecases/get_catagories_usecase.dart';
import 'features/catalog/presentation/bloc/catalog_bloc.dart';
import 'features/product_detail/data/datasources/product_detail_remote_data_source.dart';
import 'features/product_detail/data/repositories/product_detail_repository_impl.dart';
import 'features/product_detail/domain/repositories/product_detail_repository.dart';
import 'features/product_detail/domain/usecases/get_product_detail_usecase.dart';

final sl = GetIt.instance;

Future<void> init() async {
  final appDocumentDir = await getApplicationDocumentsDirectory();
  Hive.init(appDocumentDir.path);

  sl.registerLazySingleton(() => Dio());
  sl.registerLazySingleton(() => InternetConnection());
  sl.registerLazySingleton<NetworkInfo>(() => NetworkInfoImpl(sl()));

  final productBox = await Hive.openBox(CacheConstants.cachedProducts);
  sl.registerLazySingleton(() => productBox);

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

  sl.registerLazySingleton<ProductDetailRemoteDataSource>(
    () => ProductDetailRemoteDataSourceImpl(dio: sl()),
  );

  sl.registerLazySingleton<ProductDetailRepository>(
    () =>
        ProductDetailRepositoryImpl(remoteDataSource: sl(), networkInfo: sl()),
  );

  sl.registerLazySingleton(() => GetProductDetailUsecase(sl()));

  sl.registerFactory(() => ProductDetailBloc(getProductDetail: sl()));
}
