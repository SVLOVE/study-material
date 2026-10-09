import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class HelpArticle {
  final String title;
  final String category;

  const HelpArticle({required this.title, required this.category});
}

class HelpCenterScreen extends ConsumerStatefulWidget {
  const HelpCenterScreen({super.key});

  @override
  ConsumerState<HelpCenterScreen> createState() => _HelpCenterScreenState();
}

class _HelpCenterScreenState extends ConsumerState<HelpCenterScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  final List<HelpArticle> _allArticles = const [
    HelpArticle(title: 'How to create an account', category: 'Getting Started'),
    HelpArticle(title: 'How to reset a password', category: 'Account & Security'),
    HelpArticle(title: 'How to select an exam', category: 'Exam Preparation'),
    HelpArticle(title: 'How to attempt a mock test', category: 'Practice & Mock Tests'),
    HelpArticle(title: 'How to review answers', category: 'Practice & Mock Tests'),
    HelpArticle(title: 'How to manage a subscription', category: 'Subscriptions & Payments'),
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

    final searchResults = _searchQuery.isEmpty 
        ? <HelpArticle>[] 
        : _allArticles.where((a) => a.title.toLowerCase().contains(_searchQuery)).toList();

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
            Text('Help Center', style: TextStyle(color: isDark ? Colors.white : const Color(0xFF0F0F11), fontSize: 16, fontWeight: FontWeight.bold)),
            Text('Find answers and get help', style: TextStyle(color: isDark ? Colors.grey[400] : Colors.grey[700], fontSize: 12)),
          ],
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 800),
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _buildSearchField(isDark),
                  const SizedBox(height: 32),
                  if (_searchQuery.isNotEmpty) 
                    _buildSearchResults(searchResults, isDark)
                  else ...[
                    _buildSectionTitle('Browse Help Categories', isDark),
                    _buildCategoriesGrid(isDark),
                    const SizedBox(height: 32),
                    _buildSectionTitle('Quick Help', isDark),
                    _buildPopularTopics(isDark),
                    const SizedBox(height: 32),
                    _buildContactSupportCard(isDark),
                    const SizedBox(height: 48),
                    _buildFooter(isDark),
                  ],
                ],
              ),
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
          hintText: 'Search help articles, topics, or questions...',
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

  Widget _buildSearchResults(List<HelpArticle> results, bool isDark) {
    if (results.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(32),
        alignment: Alignment.center,
        child: Column(
          children: [
            Icon(Icons.search_off, size: 48, color: isDark ? Colors.grey[600] : Colors.grey[400]),
            const SizedBox(height: 16),
            Text('No results found', style: TextStyle(fontWeight: FontWeight.bold, color: isDark ? Colors.white : const Color(0xFF0F0F11))),
            const SizedBox(height: 8),
            Text('Try adjusting your search query', style: TextStyle(color: isDark ? Colors.grey[400] : Colors.grey[600], fontSize: 14)),
          ],
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 8, bottom: 12),
          child: Text('Search Results', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: isDark ? Colors.white : const Color(0xFF0F0F11))),
        ),
        Container(
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: isDark ? const Color(0xFF333333) : const Color(0xFFF3F4F6)),
          ),
          child: Column(
            children: results.map((article) {
              return Column(
                children: [
                  ListTile(
                    title: Text(article.title, style: TextStyle(color: isDark ? Colors.white : const Color(0xFF0F0F11))),
                    subtitle: Text(article.category, style: TextStyle(color: isDark ? Colors.grey[500] : Colors.grey[600], fontSize: 12)),
                    trailing: Icon(Icons.chevron_right, color: isDark ? Colors.grey[600] : Colors.grey[400]),
                    onTap: () => _showNotImplementedSnackBar('Article viewer'),
                  ),
                  if (article != results.last)
                    const Divider(height: 1),
                ],
              );
            }).toList(),
          ),
        ),
      ],
    );
  }

  Widget _buildSectionTitle(String title, bool isDark) {
    return Padding(
      padding: const EdgeInsets.only(left: 8, bottom: 12),
      child: Text(title, style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: isDark ? Colors.white : const Color(0xFF0F0F11))),
    );
  }

  Widget _buildCategoriesGrid(bool isDark) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final crossAxisCount = constraints.maxWidth > 600 ? 3 : 2;
        return GridView.count(
          crossAxisCount: crossAxisCount,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          mainAxisSpacing: 16,
          crossAxisSpacing: 16,
          childAspectRatio: 1.1,
          children: [
            _buildCategoryCard(Icons.rocket_launch_outlined, 'Getting Started', 'Account setup and basics', () => context.push('/help/getting-started'), isDark),
            _buildCategoryCard(Icons.menu_book_outlined, 'Exam Prep', 'Choosing exams and planning', () => context.push('/help/exam-preparation-guide'), isDark),
            _buildCategoryCard(Icons.assignment_outlined, 'Mock Tests', 'Attempting and reviewing', () => context.push('/help/mock-test-guide'), isDark),
            _buildCategoryCard(Icons.library_books_outlined, 'Materials', 'Accessing learning resources', () => _showNotImplementedSnackBar('Materials category'), isDark),
            _buildCategoryCard(Icons.security_outlined, 'Security', 'Profiles, passwords, recovery', () => _showNotImplementedSnackBar('Security category'), isDark),
            _buildCategoryCard(Icons.payment_outlined, 'Billing', 'Subscriptions and payments', () => context.push('/help/subscription-faq'), isDark),
          ],
        );
      },
    );
  }

  Widget _buildCategoryCard(IconData icon, String title, String subtitle, VoidCallback onTap, bool isDark) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: isDark ? const Color(0xFF333333) : const Color(0xFFF3F4F6)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: const Color(0xFF5A31F4).withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: const Color(0xFF5A31F4), size: 24),
            ),
            const Spacer(),
            Text(title, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: isDark ? Colors.white : const Color(0xFF0F0F11))),
            const SizedBox(height: 4),
            Text(
              subtitle,
              style: TextStyle(color: isDark ? Colors.grey[400] : Colors.grey[600], fontSize: 12, height: 1.2),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPopularTopics(bool isDark) {
    return Container(
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: isDark ? const Color(0xFF333333) : const Color(0xFFF3F4F6)),
      ),
      child: Column(
        children: _allArticles.map((article) {
          return Column(
            children: [
              ListTile(
                title: Text(article.title, style: TextStyle(color: isDark ? Colors.white : const Color(0xFF0F0F11), fontSize: 14)),
                trailing: Icon(Icons.chevron_right, size: 20, color: isDark ? Colors.grey[600] : Colors.grey[400]),
                onTap: () => _showNotImplementedSnackBar('Article viewer'),
              ),
              if (article != _allArticles.last)
                const Divider(height: 1),
            ],
          );
        }).toList(),
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
          Icon(Icons.support_agent_outlined, size: 40, color: const Color(0xFF5A31F4)),
          const SizedBox(height: 16),
          Text('Still need help?', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: isDark ? Colors.white : const Color(0xFF0F0F11))),
          const SizedBox(height: 8),
          Text(
            "Couldn't find what you need? Explore the available support options.",
            textAlign: TextAlign.center,
            style: TextStyle(color: isDark ? Colors.grey[400] : Colors.grey[600], fontSize: 14),
          ),
          const SizedBox(height: 24),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () => context.push('/help/contact-support'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: const Color(0xFF5A31F4),
                    side: const BorderSide(color: Color(0xFF5A31F4)),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                  child: const Text('Contact Support'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton(
                  onPressed: () => _showNotImplementedSnackBar('Support Ticket'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF5A31F4),
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                  child: const Text('Create Ticket'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildFooter(bool isDark) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        TextButton(
          onPressed: () => context.push('/help/faq'),
          child: Text('FAQ', style: TextStyle(fontSize: 12, color: isDark ? Colors.grey[400] : Colors.grey[600])),
        ),
        Text('•', style: TextStyle(color: isDark ? Colors.grey[600] : Colors.grey[400])),
        TextButton(
          onPressed: () => _showNotImplementedSnackBar('Privacy Policy'),
          child: Text('Privacy Policy', style: TextStyle(fontSize: 12, color: isDark ? Colors.grey[400] : Colors.grey[600])),
        ),
        Text('•', style: TextStyle(color: isDark ? Colors.grey[600] : Colors.grey[400])),
        TextButton(
          onPressed: () => _showNotImplementedSnackBar('Terms & Conditions'),
          child: Text('Terms & Conditions', style: TextStyle(fontSize: 12, color: isDark ? Colors.grey[400] : Colors.grey[600])),
        ),
      ],
    );
  }
}
