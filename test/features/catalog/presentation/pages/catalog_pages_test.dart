import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mini_catalog/features/catalog/presentation/bloc/catalog_bloc.dart';
import 'package:mini_catalog/features/catalog/presentation/bloc/catalog_events.dart';
import 'package:mini_catalog/features/catalog/presentation/bloc/catalog_state.dart';
import 'package:mini_catalog/features/catalog/presentation/pages/catalog_page.dart';
import 'package:bloc_test/bloc_test.dart';
import 'package:mini_catalog/features/catalog/domain/entities/product.dart';
import 'package:mocktail/mocktail.dart';

class MockCatalogBloc extends Mock implements CatalogBloc {}

void main() {
  late MockCatalogBloc mockCatalogBloc;

  setUp(() {
    mockCatalogBloc = MockCatalogBloc();
  });

  Widget makeTestableWidget(Widget child) {
    return MaterialApp(
      home: BlocProvider<CatalogBloc>.value(
        value: mockCatalogBloc,
        child: child,
      ),
    );
  }

  testWidgets('shows shimmer, then list tiles, tap retry on error', (
    tester,
  ) async {
    final products = [
      Product(
        id: 1,
        title: 'Product 1',
        price: 10.0,
        image: '',
        category: '',
        description: '',
      ),
    ];

    whenListen(
      mockCatalogBloc,
      Stream.fromIterable([
        CatalogLoading(),
        CatalogSuccess(
          page: 1,
          query: 'sdl',
          products: products,
          hasMore: false,
          categories: [],
          selectedCategory: '',
        ),
      ]),
      initialState: CatalogLoading(),
    );

    await tester.pumpWidget(makeTestableWidget(const CatalogPage()));

    expect(find.byType(Center), findsOneWidget);

    await tester.pumpAndSettle();

    expect(find.text('Product 1'), findsOneWidget);

    whenListen(
      mockCatalogBloc,
      Stream.fromIterable([CatalogFailure(errorMessage: 'Network Error')]),
      initialState: CatalogLoading(),
    );

    await tester.pumpWidget(makeTestableWidget(const CatalogPage()));
    await tester.pumpAndSettle();

    expect(find.text('Network Error'), findsOneWidget);
    expect(find.byType(ElevatedButton), findsOneWidget);

    await tester.tap(find.byType(ElevatedButton));
    verify(() => mockCatalogBloc.add(CatalogRetryRequested())).called(1);
  });
}
