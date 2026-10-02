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
    setState(() => _products = filtered);
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
      MaterialPageRoute(builder: (context) => VideoScreen(product: product)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(),
            _buildDividerAccent(),
            const SizedBox(height: 12),
            _buildSearchSection(),
            const SizedBox(height: 10),
            _buildCategorySection(),
            _buildResultsLabel(),
            Expanded(child: _buildProductGrid()),
          ],
        ),
      ),
    );
  }

  // ── Header ────────────────────────────────────────────────────────────────────

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Logo icon — gradient square with 🎆
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFFFF6B35), Color(0xFFFFB347)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(11),
              boxShadow: [
                BoxShadow(
                  color: AppColors.primary.withValues(alpha: 0.3),
                  blurRadius: 12,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: const Center(
              child: Text('🎆', style: TextStyle(fontSize: 22)),
            ),
          ),
          const SizedBox(width: 12),
          // Titles
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Eyebrow label
                Text(
                  'SPARKSHOW',
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    color: AppColors.primary,
                    letterSpacing: 1.8,
                  ),
                ),
                const SizedBox(height: 1),
                const Text(
                  'Sky Shooter Catalog',
                  style: TextStyle(
                    fontSize: 19,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                    letterSpacing: -0.4,
                    height: 1.15,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Thin orange line — not full width, offset from left to feel editorial
  Widget _buildDividerAccent() {
    return Padding(
      padding: const EdgeInsets.only(left: 70),
      child: Container(
        height: 1.5,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              AppColors.primary.withValues(alpha: 0.7),
              AppColors.primary.withValues(alpha: 0.0),
            ],
          ),
        ),
      ),
    );
  }

  // ── Search ─────────────────────────────────────────────────────────────────────

  Widget _buildSearchSection() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: AppSearchBar(
        hintText: 'Search by name, shots, occasion…',
        onChanged: _onSearchChanged,
        value: _searchQuery,
      ),
    );
  }

  // ── Categories ─────────────────────────────────────────────────────────────────

  Widget _buildCategorySection() {
    return CategoryFilter(
      categories: _categories,
      selectedCategory: _selectedCategory,
      onCategorySelected: _onCategoryChanged,
    );
  }

  // ── Results count label ────────────────────────────────────────────────────────

  Widget _buildResultsLabel() {
    if (_isLoading) return const SizedBox(height: 8);
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
      child: Row(
        children: [
          Container(
            width: 3,
            height: 12,
            decoration: BoxDecoration(
              color: AppColors.primary,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(width: 8),
          Text(
            _searchQuery.isEmpty && _selectedCategory == 'All'
                ? '${_products.length} products'
                : '${_products.length} result${_products.length == 1 ? '' : 's'}',
            style: const TextStyle(
              fontSize: 11.5,
              fontWeight: FontWeight.w500,
              color: AppColors.textSecondary,
              letterSpacing: 0.2,
            ),
          ),
        ],
      ),
    );
  }

  // ── Grid ───────────────────────────────────────────────────────────────────────

  Widget _buildProductGrid() {
    if (_isLoading) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(
              width: 32,
              height: 32,
              child: CircularProgressIndicator(
                color: AppColors.primary,
                strokeWidth: 2,
                backgroundColor: AppColors.primary.withValues(alpha: 0.15),
              ),
            ),
            const SizedBox(height: 14),
            const Text(
              'Loading catalog…',
              style: TextStyle(color: AppColors.textSecondary, fontSize: 13),
            ),
          ],
        ),
      );
    }

    if (_products.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 40),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text('🔍', style: TextStyle(fontSize: 48)),
              const SizedBox(height: 14),
              const Text(
                'Nothing found',
                style: TextStyle(
                  fontSize: 17,
                  color: AppColors.textPrimary,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 6),
              const Text(
                'Try a different name, shot count,\nor occasion like "wedding"',
                style: TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 13,
                  height: 1.5,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      );
    }

    return GridView.builder(
      padding: const EdgeInsets.fromLTRB(14, 8, 14, 20),
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
