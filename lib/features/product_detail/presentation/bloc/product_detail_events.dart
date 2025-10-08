import 'package:equatable/equatable.dart';

abstract class ProductDetailEvent extends Equatable {
  const ProductDetailEvent();

  @override
  List<Object> get props => [];
}

class FetchProductDetailEvent extends ProductDetailEvent {
  final String productId;

  const FetchProductDetailEvent(this.productId);

  @override
  List<Object> get props => [productId];
}
