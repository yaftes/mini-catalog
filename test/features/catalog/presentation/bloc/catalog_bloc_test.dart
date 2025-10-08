import 'package:bloc_test/bloc_test.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mini_catalog/features/catalog/domain/usecases/get_catagories_usecase.dart';
import 'package:mocktail/mocktail.dart';
import 'package:mini_catalog/features/catalog/presentation/bloc/catalog_bloc.dart';
import 'package:mini_catalog/features/catalog/presentation/bloc/catalog_events.dart';
import 'package:mini_catalog/features/catalog/presentation/bloc/catalog_state.dart';
import 'package:mini_catalog/features/catalog/domain/usecases/get_products_usecase.dart';
import 'package:mini_catalog/features/catalog/domain/entities/product.dart';
import 'package:mini_catalog/core/errors/failures.dart';

class MockGetProductsUsecase extends Mock implements GetProductsUsecase {}

class MockGetCategoriesUsecase extends Mock implements GetCategoriesUsecase {}

void main() {
  late CatalogBloc catalogBloc;
  late MockGetProductsUsecase mockGetProductsUsecase;
  late MockGetCategoriesUsecase mockGetCategoriesUsecase;

  setUp(() {
    mockGetProductsUsecase = MockGetProductsUsecase();
    mockGetCategoriesUsecase = MockGetCategoriesUsecase();
    catalogBloc = CatalogBloc(
      getProductsUseCase: mockGetProductsUsecase,
      getCategoriesUseCase: mockGetCategoriesUsecase,
    );
  });

  final productsPage1 = [
    Product(
      id: 1,
      title: 'Product 1',
      price: 10.0,
      image: '',
      category: '',
      description: '',
    ),
    Product(
      id: 2,
      title: 'Product 2',
      price: 15.0,
      image: '',
      category: '',
      description: '',
    ),
  ];

  blocTest<CatalogBloc, CatalogState>(
    'emits [Loading, Success] when CatalogStarted loads first page',
    build: () {
      when(
        () => mockGetProductsUsecase.call(page: 1, query: '', category: ''),
      ).thenAnswer((_) async => Right(productsPage1));
      return catalogBloc;
    },
    act: (bloc) => bloc.add(CatalogStarted()),
    expect: () => [
      CatalogLoading(),
      CatalogSuccess(
        page: 1,
        products: productsPage1,
        hasMore: false,
        categories: [],
        selectedCategory: '',
      ),
    ],
  );

  blocTest<CatalogBloc, CatalogState>(
    'emits only final query after debounce',
    build: () {
      when(
        () =>
            mockGetProductsUsecase.call(page: 1, query: 'final', category: ''),
      ).thenAnswer((_) async => Right(productsPage1));
      return catalogBloc;
    },
    act: (bloc) {
      bloc.add(CatalogQueryChanged('first'));
      bloc.add(CatalogQueryChanged('second'));
      bloc.add(CatalogQueryChanged('final'));
    },
    wait: const Duration(milliseconds: 500),
    expect: () => [
      CatalogLoading(),
      CatalogSuccess(
        page: 1,
        products: productsPage1,
        hasMore: false,
        categories: [],
        selectedCategory: '',
      ),
    ],
  );

  blocTest<CatalogBloc, CatalogState>(
    'LoadMore appends data and toggles hasMore',
    build: () {
      when(
        () => mockGetProductsUsecase.call(page: 1, query: '', category: ''),
      ).thenAnswer((_) async => Right(productsPage1));
      when(
        () => mockGetProductsUsecase.call(page: 2, query: '', category: ''),
      ).thenAnswer((_) async => Right(productsPage1));
      return catalogBloc;
    },
    act: (bloc) async {
      bloc.add(CatalogStarted());
      await Future.delayed(const Duration(milliseconds: 100));
      bloc.add(CatalogLoadMore());
    },
    expect: () => [
      CatalogLoading(),
      CatalogSuccess(
        page: 1,
        products: productsPage1,
        hasMore: false,
        categories: [],
        selectedCategory: '',
      ),
      CatalogSuccess(
        page: 1,
        products: [...productsPage1, ...productsPage1],
        hasMore: false,
        categories: [],
        selectedCategory: '',
      ),
    ],
  );

  blocTest<CatalogBloc, CatalogState>(
    'Network error triggers failure; RetryRequested recovers',
    build: () {
      when(
        () => mockGetProductsUsecase.call(page: 1, query: '', category: ''),
      ).thenAnswer((_) async => Left(ServerFailure('Network Error')));
      return catalogBloc;
    },
    act: (bloc) async {
      bloc.add(CatalogStarted());
      await Future.delayed(const Duration(milliseconds: 50));

      when(
        () => mockGetProductsUsecase.call(page: 1, query: '', category: ''),
      ).thenAnswer((_) async => Right(productsPage1));
      bloc.add(CatalogRetryRequested());
    },
    expect: () => [
      CatalogLoading(),
      isA<CatalogFailure>(),
      CatalogLoading(),
      CatalogSuccess(
        page: 1,
        products: productsPage1,
        hasMore: false,
        categories: [],
        selectedCategory: '',
      ),
    ],
  );
}
