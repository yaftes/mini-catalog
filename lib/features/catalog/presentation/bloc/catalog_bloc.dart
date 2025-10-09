import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/usecases/get_catagories_usecase.dart';
import '../../domain/usecases/get_products_usecase.dart';
import 'catalog_events.dart';
import 'catalog_state.dart';
import 'package:rxdart/rxdart.dart';

EventTransformer<E> debounce<E>(Duration duration) {
  return (events, mapper) => events.debounceTime(duration).switchMap(mapper);
}

class CatalogBloc extends Bloc<CatalogEvent, CatalogState> {
  final GetProductsUsecase getProductsUseCase;
  final GetCategoriesUsecase getCategoriesUseCase;

  static const int _pageSize = 10;

  CatalogBloc({
    required this.getProductsUseCase,
    required this.getCategoriesUseCase,
  }) : super(CatalogInitial()) {
    on<CatalogStarted>(_onStarted);
    on<CatalogRefreshed>(_onRefreshed);
    on<CatalogLoadMore>(_onLoadMore);
    on<CatalogCategoryChanged>(_onCategoryChanged);
    on<CatalogRetryRequested>(_onRetryRequested);

    on<CatalogQueryChanged>(
      _onQueryChanged,
      transformer: debounce(const Duration(milliseconds: 400)),
    );
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
        emit(CatalogEmpty(categories: categories));
      } else {
        emit(
          CatalogSuccess(
            products: products,
            categories: categories,
            hasMore: products.length == _pageSize,
            page: 1,
            query: '',
            selectedCategory: '',
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
      (failure) {
        emit(
          currentState.copyWith(
            errorMessage: failure.toString(),
            hasMore: false,
          ),
        );
      },
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
    emit(CatalogLoading());

    try {
      final categoriesResult = await getCategoriesUseCase();
      final categories = categoriesResult.fold(
        (failure) => <String>[],
        (cats) => cats,
      );

      final result = await getProductsUseCase(page: 1, limit: 100);

      result.fold(
        (failure) => emit(CatalogFailure(errorMessage: failure.toString())),
        (allProducts) {
          final filteredProducts = allProducts
              .where(
                (p) =>
                    p.title?.toLowerCase().contains(
                      event.query.toLowerCase(),
                    ) ??
                    false,
              )
              .toList();

          if (filteredProducts.isEmpty) {
            emit(CatalogEmpty(categories: categories));
          } else {
            emit(
              CatalogSuccess(
                products: filteredProducts,
                categories: categories,
                hasMore: false,
                page: 1,
                query: event.query,
                selectedCategory: '',
              ),
            );
          }
        },
      );
    } catch (e) {
      emit(CatalogFailure(errorMessage: e.toString()));
    }
  }

  Future<void> _onCategoryChanged(
    CatalogCategoryChanged event,
    Emitter<CatalogState> emit,
  ) async {
    final categories = _getCurrentCategories();
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
              query: '',
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

  List<String> _getCurrentCategories() {
    if (state is CatalogSuccess) {
      return (state as CatalogSuccess).categories;
    } else if (state is CatalogEmpty) {
      return (state as CatalogEmpty).categories;
    }
    return [];
  }
}
