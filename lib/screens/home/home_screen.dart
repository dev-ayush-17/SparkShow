import 'package:flutter/material.dart';
import '../../data/product_repository.dart';
import '../../models/product.dart';
import '../../widgets/product_card.dart';
import '../../widgets/search_bar.dart';
import '../../widgets/category_filter.dart';
import '../../utils/constants.dart';
import '../video/video_screen.dart';
import '../../services/update_service.dart';
import '../../widgets/update_dialog.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final ProductRepository _repository = ProductRepository();
  final UpdateService _updateService = UpdateService();
  List<Product> _products = [];
  List<String> _categories = [];
  String _selectedCategory = 'All';
  String _searchQuery = '';
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);

    try {
      final products = await _repository.getProducts();
      final categories = await _repository.getCategories();

      setState(() {
        _products = products;
        _categories = categories;
        _isLoading = false;
      });

      // Silently check for an OTA update after the UI is ready.
      // No-op when Firebase is not configured or device is offline.
      _checkForUpdate();
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Failed to load products'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  /// Checks Firestore for a new app version and shows the update dialog
  /// if one is available. Runs in the background — never blocks the UI.
  Future<void> _checkForUpdate() async {
    final result = await _updateService.checkForUpdate();
    if (!mounted) return;
    await UpdateDialog.show(context, result: result);
  }

  Future<void> _filterProducts() async {
    final filtered = await _repository.getFilteredProducts(
      category: _selectedCategory,
      searchQuery: _searchQuery,
    );

    setState(() {
      _products = filtered;
    });
  }

  void _onSearchChanged(String query) {
    setState(() => _searchQuery = query);
    _filterProducts();
  }

  void _onCategoryChanged(String category) {
    setState(() => _selectedCategory = category);
    _filterProducts();
  }

  void _onProductTap(Product product) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => VideoScreen(product: product),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(),
            _buildSearchSection(),
            _buildCategorySection(),
            Expanded(
              child: _buildProductGrid(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.fromLTRB(
        AppConstants.defaultPadding,
        AppConstants.defaultPadding,
        AppConstants.defaultPadding,
        AppConstants.smallPadding,
      ),
      child: Row(
        children: [
          Container(
            width: 46,
            height: 46,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFFFF6B35), Color(0xFFFFB347)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(13),
              boxShadow: [
                BoxShadow(
                  color: AppColors.primary.withValues(alpha: 0.35),
                  blurRadius: 10,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: const Center(
              child: Text('🎆', style: TextStyle(fontSize: 24)),
            ),
          ),
          const SizedBox(width: 12),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  AppConstants.appName,
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w800,
                    color: AppColors.textPrimary,
                    letterSpacing: -0.3,
                  ),
                ),
                Text(
                  'Sky Shooter Catalog',
                  style: TextStyle(
                    fontSize: 13,
                    color: AppColors.textSecondary,
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchSection() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppConstants.defaultPadding),
      child: AppSearchBar(
        onChanged: _onSearchChanged,
        value: _searchQuery,
      ),
    );
  }

  Widget _buildCategorySection() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppConstants.smallPadding),
      child: CategoryFilter(
        categories: _categories,
        selectedCategory: _selectedCategory,
        onCategorySelected: _onCategoryChanged,
      ),
    );
  }

  Widget _buildProductGrid() {
    if (_isLoading) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(color: AppColors.primary),
            SizedBox(height: 16),
            Text(
              'Loading products...',
              style: TextStyle(color: AppColors.textSecondary),
            ),
          ],
        ),
      );
    }

    if (_products.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('🔍', style: TextStyle(fontSize: 56)),
            const SizedBox(height: 16),
            const Text(
              'No products found',
              style: TextStyle(
                fontSize: 18,
                color: AppColors.textPrimary,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Try a different name, shot count, or occasion',
              style: TextStyle(color: AppColors.textSecondary, fontSize: 13),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }

    return GridView.builder(
      padding: const EdgeInsets.all(AppConstants.defaultPadding),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: AppConstants.gridCrossAxisCount,
        childAspectRatio: AppConstants.gridChildAspectRatio,
        crossAxisSpacing: AppConstants.gridCrossAxisSpacing,
        mainAxisSpacing: AppConstants.gridMainAxisSpacing,
      ),
      itemCount: _products.length,
      itemBuilder: (context, index) {
        final product = _products[index];
        return ProductCard(
          product: product,
          onTap: () => _onProductTap(product),
        );
      },
    );
  }
}
