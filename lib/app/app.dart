import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mini_catalog/features/catalog/presentation/bloc/catalog_bloc.dart';
import 'package:mini_catalog/features/catalog/presentation/pages/catalog_page.dart';
import 'package:mini_catalog/injection_container.dart' as di;

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<CatalogBloc>(create: (_) => di.sl<CatalogBloc>()),
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
