import 'package:go_router/go_router.dart';
import 'package:flutter/material.dart';
import 'dart:async';

class SearchResult {
  final String id;
  final String category; // Exams, Syllabus, Questions, Materials, Current Affairs, Mock Tests, Help
  final String title;
  final String description;
  final String metadata; // e.g. "TNPSC • Indian Polity"
  final String routeTarget;
  final Map<String, dynamic> routeArgs;

  SearchResult({
    required this.id,
    required this.category,
    required this.title,
    required this.description,
    required this.metadata,
    required this.routeTarget,
    this.routeArgs = const {},
  });
}

class GlobalSearchScreen extends StatefulWidget {
  final String? initialQuery;

  const GlobalSearchScreen({super.key, this.initialQuery});

  @override
  State<GlobalSearchScreen> createState() => _GlobalSearchScreenState();
}

class _GlobalSearchScreenState extends State<GlobalSearchScreen> {
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocus = FocusNode();
  
  Timer? _debounce;
  bool _isLoading = false;
  String _selectedCategory = 'All';
  
  final List<String> _categories = [
    'All', 'Exams', 'Syllabus', 'Questions', 'Materials', 'Current Affairs', 'Mock Tests', 'Help'
  ];

  final List<String> _recentSearches = [
    'TNPSC Group 4',
    'Indian Polity',
    'Reasoning',
  ];

  List<SearchResult> _allResults = [];
  List<SearchResult> _filteredResults = [];

  @override
  void initState() {
    super.initState();
    if (widget.initialQuery != null && widget.initialQuery!.isNotEmpty) {
      _searchController.text = widget.initialQuery!;
      _performSearch(widget.initialQuery!);
    } else {
      Future.delayed(const Duration(milliseconds: 100), () => _searchFocus.requestFocus());
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    _searchFocus.dispose();
    _debounce?.cancel();
    super.dispose();
  }

  void _onSearchChanged(String query) {
    if (_debounce?.isActive ?? false) _debounce!.cancel();
    _debounce = Timer(const Duration(milliseconds: 500), () {
      _performSearch(query);
    });
  }

  Future<void> _performSearch(String query) async {
    if (query.trim().isEmpty) {
      setState(() {
        _allResults.clear();
        _filteredResults.clear();
        _isLoading = false;
      });
      return;
    }

    setState(() => _isLoading = true);

    try {
      await Future.delayed(const Duration(milliseconds: 600)); // Mock network delay
      
      // Mock search results mapping to different modules
      final mockData = [
        SearchResult(
          id: 's_1',
          category: 'Exams',
          title: 'TNPSC Group 4',
          description: 'Tamil Nadu Public Service Commission Group 4 Exam.',
          metadata: 'Exam',
          routeTarget: '/exams/tnpsc-group-4',
        ),
        SearchResult(
          id: 's_2',
          category: 'Syllabus',
          title: 'Fundamental Rights',
          description: 'TNPSC → General Studies → Indian Polity',
          metadata: 'Syllabus Topic',
          routeTarget: '/syllabus', // Should ideally deep-link to the topic
        ),
        SearchResult(
          id: 's_3',
          category: 'Questions',
          title: 'Which article deals with Fundamental Rights?',
          description: 'Article 12-35 of the Indian Constitution.',
          metadata: 'TNPSC • Indian Polity',
          routeTarget: '/practice',
        ),
        SearchResult(
          id: 's_4',
          category: 'Materials',
          title: 'Fundamental Rights — Notes',
          description: 'Comprehensive study material for fundamental rights.',
          metadata: 'TNPSC • Polity • English',
          routeTarget: '/study-materials',
        ),
        SearchResult(
          id: 's_5',
          category: 'Current Affairs',
          title: 'Supreme Court ruling on Article 19',
          description: 'Recent developments regarding freedom of speech.',
          metadata: 'Published: Oct 2026',
          routeTarget: '/current-affairs',
        ),
        SearchResult(
          id: 's_6',
          category: 'Mock Tests',
          title: 'Indian Polity Full Mock',
          description: 'Test your knowledge on the constitution and polity.',
          metadata: '50 Questions',
          routeTarget: '/mock-tests',
        ),
        SearchResult(
          id: 's_7',
          category: 'Help',
          title: 'How to access premium materials?',
          description: 'Guide to subscribing and unlocking premium content.',
          metadata: 'Help Center • Subscriptions',
          routeTarget: '/help',
        ),
      ];

      // Very simple local mock filtering based on query
      final q = query.toLowerCase();
      _allResults = mockData.where((r) => r.title.toLowerCase().contains(q) || r.category.toLowerCase().contains(q) || r.description.toLowerCase().contains(q)).toList();
      
      _applyFilter();
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _applyFilter() {
    setState(() {
      if (_selectedCategory == 'All') {
        _filteredResults = _allResults;
      } else {
        _filteredResults = _allResults.where((r) => r.category == _selectedCategory).toList();
      }
    });
  }

  void _handleResultTap(SearchResult result) {
    if (result.routeTarget.isNotEmpty) {
      context.push(result.routeTarget, extra: result.routeArgs);
    }
  }

  IconData _getCategoryIcon(String category) {
    switch (category) {
      case 'Exams': return Icons.school;
      case 'Syllabus': return Icons.account_tree;
      case 'Questions': return Icons.quiz;
      case 'Materials': return Icons.menu_book;
      case 'Current Affairs': return Icons.newspaper;
      case 'Mock Tests': return Icons.timer;
      case 'Help': return Icons.help_outline;
      default: return Icons.article;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFEAE4F7),
      appBar: _buildSearchAppBar(),
      body: SafeArea(
        child: Column(
          children: [
            if (_searchController.text.isNotEmpty) _buildCategoryTabs(),
            Expanded(
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator(color: Color(0xFF0F0F11)))
                  : _buildBody(),
            ),
          ],
        ),
      ),
    );
  }

  PreferredSizeWidget _buildSearchAppBar() {
    return AppBar(
      backgroundColor: const Color(0xFFFFFFFF),
      elevation: 1,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back, color: Color(0xFF0F0F11)),
        onPressed: () => context.pop(),
      ),
      titleSpacing: 0,
      title: Padding(
        padding: const EdgeInsets.only(right: 16.0),
        child: TextField(
          controller: _searchController,
          focusNode: _searchFocus,
          onChanged: _onSearchChanged,
          style: const TextStyle(fontSize: 16, color: Color(0xFF0F0F11)),
          decoration: InputDecoration(
            hintText: 'Search exams, topics, questions, materials...',
            hintStyle: TextStyle(color: const Color(0xFF0F0F11).withValues(alpha: 0.4)),
            border: InputBorder.none,
            suffixIcon: _searchController.text.isNotEmpty
                ? IconButton(
                    icon: const Icon(Icons.clear, color: Color(0xFF0F0F11)),
                    onPressed: () {
                      _searchController.clear();
                      _onSearchChanged('');
                    },
                  )
                : const Icon(Icons.search, color: Color(0xFF0F0F11)),
          ),
        ),
      ),
    );
  }

  Widget _buildCategoryTabs() {
    return Container(
      width: double.infinity,
      color: const Color(0xFFFFFFFF),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: _categories.map((category) {
            final isSelected = _selectedCategory == category;
            return Padding(
              padding: const EdgeInsets.only(right: 8),
              child: ChoiceChip(
                label: Text(category),
                selected: isSelected,
                onSelected: (selected) {
                  if (selected) {
                    setState(() {
                      _selectedCategory = category;
                      _applyFilter();
                    });
                  }
                },
                selectedColor: const Color(0xFF0F0F11),
                backgroundColor: const Color(0xFFF3F4F6),
                labelStyle: TextStyle(
                  color: isSelected ? Colors.white : const Color(0xFF0F0F11),
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                ),
              ),
            );
          }).toList(),
        ),
      ),
    );
  }

  Widget _buildBody() {
    if (_searchController.text.isEmpty) {
      return _buildIdleState();
    }

    if (_filteredResults.isEmpty) {
      return _buildEmptyState();
    }

    return _buildResultsList();
  }

  Widget _buildIdleState() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 800),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (_recentSearches.isNotEmpty) ...[
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Recent Searches', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF0F0F11))),
                    TextButton(
                      onPressed: () => setState(() => _recentSearches.clear()),
                      child: const Text('Clear All', style: TextStyle(color: Colors.grey)),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: _recentSearches.map((query) => InkWell(
                    onTap: () {
                      _searchController.text = query;
                      _onSearchChanged(query);
                    },
                    borderRadius: BorderRadius.circular(16),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFFFFFF),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: const Color(0xFFF3F4F6)),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.history, size: 16, color: Colors.grey),
                          const SizedBox(width: 8),
                          Text(query, style: const TextStyle(color: Color(0xFF0F0F11))),
                        ],
                      ),
                    ),
                  )).toList(),
                ),
                const SizedBox(height: 32),
              ],

              const Text('Quick Discovery', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF0F0F11))),
              const SizedBox(height: 16),
              Wrap(
                spacing: 12,
                runSpacing: 12,
                children: _categories.where((c) => c != 'All').map((category) => InkWell(
                  onTap: () {
                    setState(() {
                      _selectedCategory = category;
                      _searchController.text = category;
                      _onSearchChanged(category);
                    });
                  },
                  borderRadius: BorderRadius.circular(16),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFFFFFF),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: const Color(0xFFF3F4F6)),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(_getCategoryIcon(category), size: 20, color: Colors.deepPurple),
                        const SizedBox(width: 8),
                        Text(category, style: const TextStyle(fontWeight: FontWeight.w600, color: Color(0xFF0F0F11))),
                      ],
                    ),
                  ),
                )).toList(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.search_off, size: 64, color: Colors.grey),
            const SizedBox(height: 16),
            const Text('No results found', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFF0F0F11))),
            const SizedBox(height: 8),
            Text('Try a different keyword, exam, subject, or topic.', textAlign: TextAlign.center, style: TextStyle(color: const Color(0xFF0F0F11).withValues(alpha: 0.6))),
            const SizedBox(height: 24),
            OutlinedButton(
              onPressed: () {
                _searchController.clear();
                _onSearchChanged('');
              },
              style: OutlinedButton.styleFrom(
                side: const BorderSide(color: Color(0xFF0F0F11)),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              child: const Text('Clear Search', style: TextStyle(color: Color(0xFF0F0F11))),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildResultsList() {
    return ListView.builder(
      padding: const EdgeInsets.all(24),
      itemCount: _filteredResults.length,
      itemBuilder: (context, index) {
        final result = _filteredResults[index];
        return Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 800),
            child: Container(
              margin: const EdgeInsets.only(bottom: 16),
              decoration: BoxDecoration(
                color: const Color(0xFFFFFFFF),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: const Color(0xFFF3F4F6)),
              ),
              child: InkWell(
                onTap: () => _handleResultTap(result),
                borderRadius: BorderRadius.circular(16),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: const Color(0xFFF3F4F6),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Row(
                              children: [
                                Icon(_getCategoryIcon(result.category), size: 12, color: const Color(0xFF0F0F11)),
                                const SizedBox(width: 4),
                                Text(result.category.toUpperCase(), style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Color(0xFF0F0F11))),
                              ],
                            ),
                          ),
                          const Icon(Icons.arrow_forward_ios, size: 14, color: Colors.grey),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Text(result.title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF0F0F11))),
                      const SizedBox(height: 8),
                      Text(result.description, style: TextStyle(fontSize: 14, color: const Color(0xFF0F0F11).withValues(alpha: 0.8))),
                      const SizedBox(height: 12),
                      Text(result.metadata, style: TextStyle(fontSize: 12, color: const Color(0xFF0F0F11).withValues(alpha: 0.5))),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
