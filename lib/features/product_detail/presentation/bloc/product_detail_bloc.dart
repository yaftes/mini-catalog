import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mini_catalog/features/product_detail/domain/usecases/get_product_detail_usecase.dart';
import 'package:mini_catalog/features/product_detail/presentation/bloc/product_detail_events.dart';
import 'package:mini_catalog/features/product_detail/presentation/bloc/product_detail_states.dart';

class ProductDetailBloc extends Bloc<ProductDetailEvent, ProductDetailState> {
  final GetProductDetailUsecase getProductDetail;

  ProductDetailBloc({required this.getProductDetail})
    : super(ProductDetailInitial()) {
    on<FetchProductDetailEvent>(_onFetchProductDetail);
  }

  Future<void> _onFetchProductDetail(
    FetchProductDetailEvent event,
    Emitter<ProductDetailState> emit,
  ) async {
    emit(ProductDetailLoading());

    final result = await getProductDetail(event.productId);
    print(result);

    result.fold(
      (failure) => emit(ProductDetailError(failure.message)),
      (product) => emit(ProductDetailLoaded(product)),
    );
  }
}
