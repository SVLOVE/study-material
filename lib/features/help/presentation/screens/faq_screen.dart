import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class FaqItem {
  final String question;
  final String answer;
  final String category;

  const FaqItem({
    required this.question,
    required this.answer,
    required this.category,
  });
}

class FaqScreen extends ConsumerStatefulWidget {
  const FaqScreen({super.key});

  @override
  ConsumerState<FaqScreen> createState() => _FaqScreenState();
}

class _FaqScreenState extends ConsumerState<FaqScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  String _selectedCategory = 'All Topics';

  final List<String> _categories = [
    'All Topics',
    'Getting Started',
    'Exams & Preparation',
    'Practice & Mock Tests',
    'Account & Security',
    'Subscriptions & Payments',
  ];

  final List<FaqItem> _allFaqs = const [
    FaqItem(
      question: 'How do I create an account?',
      answer: 'You can create an account by clicking the "Sign Up" button on the login page and providing your email, password, and basic profile details.',
      category: 'Getting Started',
    ),
    FaqItem(
      question: 'How can I change my target exam?',
      answer: 'Navigate to Profile > Account Settings > Exam Preferences to update your target exam. This will re-calibrate your study plan and recommended materials.',
      category: 'Exams & Preparation',
    ),
    FaqItem(
      question: 'Are mock tests timed?',
      answer: 'Yes, full-length mock tests are timed exactly like the real examination to help you build time management skills. Practice sets are untimed.',
      category: 'Practice & Mock Tests',
    ),
    FaqItem(
      question: 'How do I review answers after a test?',
      answer: 'Once you submit a mock test or practice set, you can view a detailed performance report. Click on any question in the report to see the correct answer and a detailed explanation.',
      category: 'Practice & Mock Tests',
    ),
    FaqItem(
      question: 'How do I reset my password?',
      answer: 'If you are logged out, click "Forgot Password" on the login screen. If you are logged in, go to Profile > Account Settings > Change Password.',
      category: 'Account & Security',
    ),
    FaqItem(
      question: 'How do I manage my subscription?',
      answer: 'Go to Profile > Account Settings and select Subscription to view your current plan, billing history, or to cancel your subscription.',
      category: 'Subscriptions & Payments',
    ),
  ];

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchChanged(String query) {
    setState(() {
      _searchQuery = query.toLowerCase();
    });
  }

  void _clearSearch() {
    _searchController.clear();
    setState(() {
      _searchQuery = '';
    });
  }

  void _showNotImplementedSnackBar(String feature) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('$feature is not yet implemented in this phase.')),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final filteredFaqs = _allFaqs.where((faq) {
      final matchesCategory = _selectedCategory == 'All Topics' || faq.category == _selectedCategory;
      final matchesSearch = _searchQuery.isEmpty || 
          faq.question.toLowerCase().contains(_searchQuery) || 
          faq.answer.toLowerCase().contains(_searchQuery);
      return matchesCategory && matchesSearch;
    }).toList();

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF121212) : const Color(0xFFEAE4F7),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: isDark ? Colors.white : const Color(0xFF0F0F11)),
          onPressed: () => context.pop(),
        ),
        title: Column(
          children: [
            Text('Frequently Asked Questions', style: TextStyle(color: isDark ? Colors.white : const Color(0xFF0F0F11), fontSize: 16, fontWeight: FontWeight.bold)),
            Text('Find quick answers to common questions', style: TextStyle(color: isDark ? Colors.grey[400] : Colors.grey[700], fontSize: 12)),
          ],
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 800),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(24, 24, 24, 16),
                  child: _buildSearchField(isDark),
                ),
                Padding(
                  padding: const EdgeInsets.only(bottom: 16),
                  child: _buildCategoryFilters(isDark),
                ),
                Expanded(
                  child: filteredFaqs.isEmpty
                      ? _buildEmptyState(isDark)
                      : ListView.builder(
                          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
                          itemCount: filteredFaqs.length + 1,
                          itemBuilder: (context, index) {
                            if (index == filteredFaqs.length) {
                              return Padding(
                                padding: const EdgeInsets.only(top: 32, bottom: 48),
                                child: _buildContactSupportCard(isDark),
                              );
                            }
                            return _buildFaqAccordion(filteredFaqs[index], isDark);
                          },
                        ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSearchField(bool isDark) {
    return Container(
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: isDark ? const Color(0xFF333333) : const Color(0xFFF3F4F6)),
      ),
      child: TextField(
        controller: _searchController,
        onChanged: _onSearchChanged,
        style: TextStyle(color: isDark ? Colors.white : const Color(0xFF0F0F11)),
        decoration: InputDecoration(
          hintText: 'Search questions or answers...',
          hintStyle: TextStyle(color: isDark ? Colors.grey[500] : Colors.grey[400], fontSize: 15),
          prefixIcon: Icon(Icons.search, color: isDark ? Colors.grey[400] : Colors.grey[600]),
          suffixIcon: _searchQuery.isNotEmpty
              ? IconButton(
                  icon: Icon(Icons.clear, color: isDark ? Colors.grey[400] : Colors.grey[600]),
                  onPressed: _clearSearch,
                )
              : null,
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        ),
      ),
    );
  }

  Widget _buildCategoryFilters(bool isDark) {
    return SizedBox(
      height: 40,
      child: ListView.separated(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        scrollDirection: Axis.horizontal,
        itemCount: _categories.length,
        separatorBuilder: (context, index) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          final category = _categories[index];
          final isSelected = _selectedCategory == category;
          return FilterChip(
            label: Text(category),
            selected: isSelected,
            onSelected: (selected) {
              setState(() {
                _selectedCategory = category;
              });
            },
            backgroundColor: isDark ? const Color(0xFF1E1E1E) : Colors.white,
            selectedColor: const Color(0xFF5A31F4).withValues(alpha: 0.1),
            labelStyle: TextStyle(
              color: isSelected ? const Color(0xFF5A31F4) : (isDark ? Colors.grey[400] : Colors.grey[700]),
              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
              side: BorderSide(
                color: isSelected ? const Color(0xFF5A31F4) : (isDark ? const Color(0xFF333333) : const Color(0xFFE4DBF6)),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildFaqAccordion(FaqItem faq, bool isDark) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: isDark ? const Color(0xFF333333) : const Color(0xFFF3F4F6)),
      ),
      child: Theme(
        data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          iconColor: const Color(0xFF5A31F4),
          collapsedIconColor: isDark ? Colors.grey[400] : Colors.grey[600],
          title: Text(
            faq.question,
            style: TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: 15,
              color: isDark ? Colors.white : const Color(0xFF0F0F11),
            ),
          ),
          childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
          expandedCrossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              faq.answer,
              style: TextStyle(
                color: isDark ? Colors.grey[300] : Colors.grey[700],
                fontSize: 14,
                height: 1.5,
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Text('Was this helpful?', style: TextStyle(color: isDark ? Colors.grey[500] : Colors.grey[500], fontSize: 12)),
                const SizedBox(width: 8),
                InkWell(
                  onTap: () => _showNotImplementedSnackBar('Feedback recorded'),
                  borderRadius: BorderRadius.circular(4),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    child: Text('Yes', style: TextStyle(color: isDark ? Colors.grey[400] : Colors.grey[600], fontSize: 12, fontWeight: FontWeight.bold)),
                  ),
                ),
                InkWell(
                  onTap: () => _showNotImplementedSnackBar('Feedback recorded'),
                  borderRadius: BorderRadius.circular(4),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    child: Text('No', style: TextStyle(color: isDark ? Colors.grey[400] : Colors.grey[600], fontSize: 12, fontWeight: FontWeight.bold)),
                  ),
                ),
              ],
            )
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState(bool isDark) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.search_off, size: 48, color: isDark ? Colors.grey[600] : Colors.grey[400]),
          const SizedBox(height: 16),
          Text('No matching questions found', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: isDark ? Colors.white : const Color(0xFF0F0F11))),
          const SizedBox(height: 8),
          Text('Try another search term or choose a different topic.', style: TextStyle(color: isDark ? Colors.grey[400] : Colors.grey[600], fontSize: 14)),
          const SizedBox(height: 24),
          if (_searchQuery.isNotEmpty || _selectedCategory != 'All Topics')
            OutlinedButton(
              onPressed: () {
                setState(() {
                  _searchController.clear();
                  _searchQuery = '';
                  _selectedCategory = 'All Topics';
                });
              },
              style: OutlinedButton.styleFrom(
                foregroundColor: const Color(0xFF5A31F4),
                side: const BorderSide(color: Color(0xFF5A31F4)),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              child: const Text('Reset Search'),
            ),
        ],
      ),
    );
  }

  Widget _buildContactSupportCard(bool isDark) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF2C2C2E) : const Color(0xFFF9F8FD),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: isDark ? const Color(0xFF333333) : const Color(0xFFE4DBF6)),
      ),
      child: Column(
        children: [
          Icon(Icons.help_outline, size: 32, color: const Color(0xFF5A31F4)),
          const SizedBox(height: 12),
          Text('Need More Help?', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: isDark ? Colors.white : const Color(0xFF0F0F11))),
          const SizedBox(height: 8),
          Text(
            "Still need help? Explore the Help Center or contact support through the available support options.",
            textAlign: TextAlign.center,
            style: TextStyle(color: isDark ? Colors.grey[400] : Colors.grey[600], fontSize: 14),
          ),
          const SizedBox(height: 24),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () => context.pop(), // Go back to Help Center
                  style: OutlinedButton.styleFrom(
                    foregroundColor: const Color(0xFF5A31F4),
                    side: const BorderSide(color: Color(0xFF5A31F4)),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                  child: const Text('Help Center'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton(
                  onPressed: () => _showNotImplementedSnackBar('Contact Support'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF5A31F4),
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                  child: const Text('Contact Support'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
