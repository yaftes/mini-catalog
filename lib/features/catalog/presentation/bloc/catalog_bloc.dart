import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mini_catalog/features/catalog/domain/usecases/get_catagories_usecase.dart';
import 'package:mini_catalog/features/catalog/presentation/bloc/catalog_events.dart';
import '../../domain/usecases/get_products_usecase.dart';
import 'catalog_state.dart';

class CatalogBloc extends Bloc<CatalogEvent, CatalogState> {
  final GetProductsUsecase getProductsUseCase;
  final GetCategoriesUsecase getCategoriesUseCase;

  static const int _pageSize = 20;

  CatalogBloc({
    required this.getProductsUseCase,
    required this.getCategoriesUseCase,
  }) : super(CatalogInitial()) {
    on<CatalogStarted>(_onStarted);
    on<CatalogRefreshed>(_onRefreshed);
    on<CatalogLoadMore>(_onLoadMore);
    on<CatalogQueryChanged>(_onQueryChanged);
    on<CatalogCategoryChanged>(_onCategoryChanged);
    on<CatalogRetryRequested>(_onRetryRequested);
  }

  Future<void> _onStarted(
    CatalogStarted event,
    Emitter<CatalogState> emit,
  ) async {
    emit(CatalogLoading());

    try {
      final categoriesResult = await getCategoriesUseCase();
      final productsResult = await getProductsUseCase(
        page: 1,
        limit: _pageSize,
      );

      final categories = categoriesResult.getOrElse(() => []);
      final products = productsResult.getOrElse(() => []);

      if (products.isEmpty) {
        emit(CatalogEmpty());
      } else {
        emit(
          CatalogSuccess(
            products: products,
            categories: categories,
            hasMore: products.length == _pageSize,
            page: 1,
          ),
        );
      }
    } catch (e) {
      emit(CatalogFailure(errorMessage: e.toString()));
    }
  }

  Future<void> _onRefreshed(
    CatalogRefreshed event,
    Emitter<CatalogState> emit,
  ) async {
    add(CatalogStarted());
  }

  Future<void> _onLoadMore(
    CatalogLoadMore event,
    Emitter<CatalogState> emit,
  ) async {
    final currentState = state;
    if (currentState is! CatalogSuccess || !currentState.hasMore) return;

    emit(CatalogLoading());

    final nextPage = currentState.page + 1;

    final result = await getProductsUseCase(
      page: nextPage,
      limit: _pageSize,
      query: currentState.query,
      category: currentState.selectedCategory,
    );

    result.fold(
      (failure) => emit(CatalogFailure(errorMessage: failure.toString())),
      (products) {
        final allProducts = [...currentState.products, ...products];
        emit(
          CatalogSuccess(
            products: allProducts,
            categories: currentState.categories,
            hasMore: products.length == _pageSize,
            page: nextPage,
            query: currentState.query,
            selectedCategory: currentState.selectedCategory,
          ),
        );
      },
    );
  }

  Future<void> _onQueryChanged(
    CatalogQueryChanged event,
    Emitter<CatalogState> emit,
  ) async {
    emit(CatalogLoading());

    final result = await getProductsUseCase(
      page: 1,
      limit: _pageSize,
      query: event.query,
      category: '',
    );

    result.fold(
      (failure) => emit(CatalogFailure(errorMessage: failure.toString())),
      (products) {
        if (products.isEmpty) {
          emit(CatalogEmpty());
        } else {
          emit(
            CatalogSuccess(
              products: products,
              categories: [],
              hasMore: products.length == _pageSize,
              page: 1,
              query: event.query,
            ),
          );
        }
      },
    );
  }

  Future<void> _onCategoryChanged(
    CatalogCategoryChanged event,
    Emitter<CatalogState> emit,
  ) async {
    emit(CatalogLoading());

    final result = await getProductsUseCase(
      page: 1,
      limit: _pageSize,
      category: event.category,
      query: '',
    );

    result.fold(
      (failure) => emit(CatalogFailure(errorMessage: failure.toString())),
      (products) {
        if (products.isEmpty) {
          emit(CatalogEmpty());
        } else {
          emit(
            CatalogSuccess(
              products: products,
              categories: [],
              hasMore: products.length == _pageSize,
              page: 1,
              selectedCategory: event.category,
            ),
          );
        }
      },
    );
  }

  Future<void> _onRetryRequested(
    CatalogRetryRequested event,
    Emitter<CatalogState> emit,
  ) async {
    add(CatalogStarted());
  }
}
