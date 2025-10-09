import 'package:equatable/equatable.dart';
import '../../domain/entities/product.dart';

abstract class CatalogState extends Equatable {
  const CatalogState();
  @override
  List<Object?> get props => [];
}

class CatalogInitial extends CatalogState {}

class CatalogLoading extends CatalogState {}

class CatalogSuccess extends CatalogState {
  final List<Product> products;
  final List<String> categories;
  final bool hasMore;
  final int page;
  final String query;
  final String selectedCategory;
  final String? errorMessage;

  const CatalogSuccess({
    required this.products,
    required this.categories,
    required this.hasMore,
    required this.page,
    this.query = '',
    this.selectedCategory = '',
    this.errorMessage,
  });

  CatalogSuccess copyWith({
    List<Product>? products,
    List<String>? categories,
    bool? hasMore,
    int? page,
    String? query,
    String? selectedCategory,
    String? errorMessage,
  }) {
    return CatalogSuccess(
      products: products ?? this.products,
      categories: categories ?? this.categories,
      hasMore: hasMore ?? this.hasMore,
      page: page ?? this.page,
      query: query ?? this.query,
      selectedCategory: selectedCategory ?? this.selectedCategory,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  @override
  List<Object?> get props => [
    products,
    categories,
    hasMore,
    page,
    query,
    selectedCategory,
  ];
}

class CatalogFailure extends CatalogState {
  final String errorMessage;

  const CatalogFailure({required this.errorMessage});

  @override
  List<Object?> get props => [errorMessage];
}

class CatalogEmpty extends CatalogState {
  final List<String> categories;

  const CatalogEmpty({this.categories = const []});

  @override
  List<Object?> get props => [categories];
}
