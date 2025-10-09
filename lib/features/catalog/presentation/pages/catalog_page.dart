import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mini_catalog/app/theme_cubit.dart';
import 'package:mini_catalog/features/catalog/presentation/widgets/catalog_shimmer.dart';
import 'package:mini_catalog/features/product_detail/presentation/bloc/product_detail_bloc.dart';
import 'package:mini_catalog/features/product_detail/presentation/pages/product_detail_page.dart';
import '../../domain/entities/product.dart';
import '../bloc/catalog_bloc.dart';
import '../bloc/catalog_events.dart';
import '../bloc/catalog_state.dart';

class CatalogPage extends StatefulWidget {
  const CatalogPage({super.key});

  @override
  State<CatalogPage> createState() => _CatalogPageState();
}

class _CatalogPageState extends State<CatalogPage> {
  final ScrollController _scrollController = ScrollController();
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    context.read<CatalogBloc>().add(CatalogStarted());

    _scrollController.addListener(() {
      if (_scrollController.position.pixels >=
              _scrollController.position.maxScrollExtent - 200 &&
          !_scrollController.position.outOfRange) {
        context.read<CatalogBloc>().add(CatalogLoadMore());
      }
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final themeCubit = context.read<ThemeCubit>();

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        surfaceTintColor: Colors.transparent,
        scrolledUnderElevation: 0,
        centerTitle: true,
        title: const Text('Products'),
        actions: [
          BlocBuilder<ThemeCubit, ThemeMode>(
            builder: (context, themeMode) {
              final isDark = themeMode == ThemeMode.dark;
              return IconButton(
                onPressed: () {
                  themeCubit.toggleTheme();
                },
                icon: Icon(isDark ? Icons.dark_mode : Icons.light_mode),
              );
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: TextField(
                controller: _searchController,
                onChanged: (value) {
                  context.read<CatalogBloc>().add(CatalogQueryChanged(value));
                },
                decoration: InputDecoration(
                  hintText: 'Search products...',
                  prefixIcon: const Icon(Icons.search),
                  fillColor: Theme.of(context).cardColor,
                  filled: true,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
            ),

            BlocBuilder<CatalogBloc, CatalogState>(
              builder: (context, state) {
                List<String> categories = [];
                String selected = '';

                if (state is CatalogSuccess) {
                  categories = state.categories;
                  selected = state.selectedCategory;
                } else if (state is CatalogEmpty) {
                  categories = state.categories;
                }

                if (categories.isNotEmpty) {
                  return SizedBox(
                    height: 50,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: categories.length + 1,
                      itemBuilder: (context, index) {
                        final isAll = index == 0;
                        final category = isAll ? 'All' : categories[index - 1];
                        final isSelected =
                            (selected.isEmpty && isAll) || selected == category;

                        return Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 6),
                          child: ChoiceChip(
                            label: Text(category),
                            selected: isSelected,
                            selectedColor: Colors.black,
                            backgroundColor: Colors.grey,
                            labelStyle: const TextStyle(color: Colors.white),
                            onSelected: (_) {
                              context.read<CatalogBloc>().add(
                                CatalogCategoryChanged(isAll ? '' : category),
                              );
                            },
                          ),
                        );
                      },
                    ),
                  );
                }
                return const SizedBox.shrink();
              },
            ),

            const SizedBox(height: 8),

            Expanded(
              child: BlocBuilder<CatalogBloc, CatalogState>(
                builder: (context, state) {
                  if (state is CatalogInitial || state is CatalogLoading) {
                    return const CatalogShimmer();
                  } else if (state is CatalogFailure) {
                    return Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(state.errorMessage),
                          const SizedBox(height: 8),
                          ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.black,
                            ),
                            onPressed: () {
                              context.read<CatalogBloc>().add(
                                CatalogRetryRequested(),
                              );
                            },
                            child: const Text('Retry'),
                          ),
                        ],
                      ),
                    );
                  } else if (state is CatalogEmpty) {
                    return const Center(child: Text('No products found'));
                  } else if (state is CatalogSuccess) {
                    final products = state.products;

                    return RefreshIndicator(
                      onRefresh: () async {
                        context.read<CatalogBloc>().add(CatalogRefreshed());
                      },
                      child: ListView.builder(
                        controller: _scrollController,
                        itemCount: products.length + 1,
                        itemBuilder: (context, index) {
                          if (index == products.length) {
                            if (state.hasMore) {
                              return Padding(
                                padding: const EdgeInsets.all(16),
                                child: Center(
                                  child: ElevatedButton(
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.black,
                                    ),
                                    onPressed: () {
                                      context.read<CatalogBloc>().add(
                                        CatalogLoadMore(),
                                      );
                                    },
                                    child: const Text(
                                      'Load More',
                                      style: TextStyle(color: Colors.white),
                                    ),
                                  ),
                                ),
                              );
                            } else {
                              return const SizedBox.shrink();
                            }
                          }

                          final Product product = products[index];

                          return Card(
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            margin: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 6,
                            ),
                            elevation: 4,
                            child: ListTile(
                              contentPadding: const EdgeInsets.all(8),
                              leading: ClipRRect(
                                borderRadius: BorderRadius.circular(8),
                                child: CachedNetworkImage(
                                  imageUrl: product.image,
                                  width: 60,
                                  height: 60,
                                  fit: BoxFit.cover,
                                  placeholder: (context, url) => const Center(
                                    child: SizedBox(
                                      width: 30,
                                      height: 30,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                      ),
                                    ),
                                  ),
                                  errorWidget: (context, url, error) =>
                                      const Icon(Icons.broken_image),
                                ),
                              ),
                              title: Text(
                                product.title,
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),
                              subtitle: Text(
                                '\$${product.price.toStringAsFixed(2)}',
                                style: TextStyle(
                                  color: Theme.of(
                                    context,
                                  ).textTheme.bodyMedium?.color,
                                ),
                              ),
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => BlocProvider.value(
                                      value: context.read<ProductDetailBloc>(),
                                      child: ProductDetailPage(
                                        productId: product.id.toString(),
                                      ),
                                    ),
                                  ),
                                );
                              },
                            ),
                          );
                        },
                      ),
                    );
                  }

                  return const SizedBox.shrink();
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
