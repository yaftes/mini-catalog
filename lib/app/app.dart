import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mini_catalog/features/catalog/presentation/bloc/catalog_bloc.dart';
import 'package:mini_catalog/features/catalog/presentation/bloc/catalog_events.dart';
import 'package:mini_catalog/features/catalog/presentation/pages/catalog_page.dart';
import 'package:mini_catalog/features/product_detail/presentation/bloc/product_detail_bloc.dart';
import 'package:mini_catalog/injection_container.dart' as di;

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<CatalogBloc>(
          create: (_) => di.sl<CatalogBloc>()..add(CatalogStarted()),
        ),
        BlocProvider<ProductDetailBloc>(
          create: (_) => di.sl<ProductDetailBloc>(),
        ),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Mini Catalog',
        theme: ThemeData(primarySwatch: Colors.blue),
        home: const CatalogPage(),
      ),
    );
  }
}
