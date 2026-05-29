import 'package:flutter/material.dart';
import '../../services/api_service.dart';
import '../../services/bookmark_service.dart';

class GuidelinePage extends StatefulWidget {
  final String title;
  final String slug;
  const GuidelinePage({super.key, required this.title, required this.slug});

  @override
  State<GuidelinePage> createState() => _GuidelinePageState();
}

class _GuidelinePageState extends State<GuidelinePage> {
  Map<String, dynamic>? _data;
  bool _isLoading = true;
  bool _isBookmarked = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });
    try {
      final data = await ApiService.getGuideline(widget.slug);
      final bookmarked = await BookmarkService.isBookmarked(widget.slug);
      setState(() {
        _data = data;
        _isBookmarked = bookmarked;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  Future<void> _toggleBookmark() async {
    if (_isBookmarked) {
      await BookmarkService.removeBookmark(widget.slug);
    } else {
      await BookmarkService.addBookmark(_data!);
    }
    setState(() => _isBookmarked = !_isBookmarked);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(_isBookmarked ? 'Bookmarked' : 'Removed')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFE0E0E0),
      appBar: AppBar(
        title: Text(widget.title),
        actions: [
          IconButton(
            icon: Icon(_isBookmarked ? Icons.bookmark : Icons.bookmark_border),
            onPressed: _data != null ? _toggleBookmark : null,
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
    if (_error != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 48, color: Colors.red),
            const SizedBox(height: 16),
            Text('Error: $_error'),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _load,
              child: const Text('Retry'),
            ),
          ],
        ),
      );
    }
    if (_data == null) {
      return const Center(child: Text('No data available'));
    }
    return ListView(
      padding: const EdgeInsets.all(12),
      children: [
        _infoCard('Overview', _data!['overview']),
        _infoCard('Diagnosis', _data!['diagnosis']),
        _infoCard('Management', _data!['management']),
        _infoCard('Complications', _data!['complications']),
      ],
    );
  }

  Widget _infoCard(String title, String? content) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: Colors.grey.shade400),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          Text(content ?? 'Not available'),
        ],
      ),
    );
  }
}
