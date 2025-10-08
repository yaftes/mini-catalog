import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/usecases/get_catagories_usecase.dart';
import '../../domain/usecases/get_products_usecase.dart';
import 'catalog_events.dart';
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

      // Convert dynamic to String
      final categories = categoriesResult
          .getOrElse(() => [])
          .map((e) => e.toString())
          .toList();

      final products = productsResult.getOrElse(() => []);

      if (products.isEmpty) {
        emit(CatalogEmpty(categories: categories));
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
          currentState.copyWith(
            products: allProducts,
            hasMore: products.length == _pageSize,
            page: nextPage,
          ),
        );
      },
    );
  }

  Future<void> _onQueryChanged(
    CatalogQueryChanged event,
    Emitter<CatalogState> emit,
  ) async {
    final categories = state is CatalogSuccess
        ? (state as CatalogSuccess).categories
        : state is CatalogEmpty
        ? (state as CatalogEmpty).categories
        : <String>[];

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
          emit(CatalogEmpty(categories: categories));
        } else {
          emit(
            CatalogSuccess(
              products: products,
              categories: categories,
              hasMore: products.length == _pageSize,
              page: 1,
              query: event.query,
              selectedCategory: '',
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
    final categories = state is CatalogSuccess
        ? (state as CatalogSuccess).categories
        : state is CatalogEmpty
        ? (state as CatalogEmpty).categories
        : <String>[];

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
          emit(CatalogEmpty(categories: categories));
        } else {
          emit(
            CatalogSuccess(
              products: products,
              categories: categories,
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
