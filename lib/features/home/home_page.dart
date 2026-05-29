import 'package:flutter/material.dart';
import '../../services/api_service.dart';
import '../guidelines/guideline_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List<Map<String, dynamic>> _guidelines = [];
  List<dynamic> _categories = [];
  bool _isLoading = true;
  String? _errorMessage;
  int? _selectedCategoryId;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });
    try {
      final guidelines = await ApiService.getGuidelines();
      final categories = await ApiService.getCategories();
      setState(() {
        _guidelines = guidelines;
        _categories = categories;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = e.toString();
        _isLoading = false;
      });
    }
  }

  Future<void> _filterByCategory(int id) async {
    setState(() {
      _isLoading = true;
      _selectedCategoryId = id;
    });
    try {
      final filtered = await ApiService.getGuidelines(categoryId: id);
      setState(() {
        _guidelines = filtered;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = e.toString();
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('SudanRx'),
        actions: [
          IconButton(
            icon: const Icon(Icons.sync),
            onPressed: _loadData,
            tooltip: 'Refresh',
          ),
        ],
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (_errorMessage != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, size: 64, color: Colors.red),
              const SizedBox(height: 16),
              Text(
                'Failed to load data',
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Text(
                _errorMessage!,
                textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.grey),
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: _loadData,
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
      );
    }
    if (_guidelines.isEmpty && _categories.isEmpty) {
      return const Center(
        child: Text('No guidelines available.\nPull to refresh.'),
      );
    }
    return Column(
      children: [
        if (_categories.isNotEmpty)
          SizedBox(
            height: 50,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: _categories.length,
              itemBuilder: (context, index) {
                final cat = _categories[index];
                final isSelected = _selectedCategoryId == cat['id'];
                return GestureDetector(
                  onTap: () => _filterByCategory(cat['id']),
                  child: Container(
                    margin: const EdgeInsets.all(6),
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(
                      color: isSelected ? Colors.blue : Colors.grey[300],
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      cat['name'],
                      style: TextStyle(color: isSelected ? Colors.white : Colors.black),
                    ),
                  ),
                );
              },
            ),
          ),
        Expanded(
          child: _guidelines.isEmpty
              ? const Center(child: Text('No guidelines in this category'))
              : ListView.builder(
                  itemCount: _guidelines.length,
                  itemBuilder: (context, index) {
                    final item = _guidelines[index];
                    return Card(
                      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      child: ListTile(
                        title: Text(item['title']),
                        subtitle: Text(item['category_name'] ?? ''),
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => GuidelinePage(
                                title: item['title'],
                                slug: item['slug'],
                              ),
                            ),
                          );
                        },
                      ),
                    );
                  },
                ),
        ),
      ],
    );
  }
}
