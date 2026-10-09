import 'package:go_router/go_router.dart';
import 'package:flutter/material.dart';

class FaqItem {
  final String question;
  final String answer;

  FaqItem({required this.question, required this.answer});
}

class HelpCategory {
  final String title;
  final String description;
  final IconData icon;
  final int articleCount;

  HelpCategory({
    required this.title,
    required this.description,
    required this.icon,
    required this.articleCount,
  });
}

class HelpScreen extends StatefulWidget {
  const HelpScreen({super.key});

  @override
  State<HelpScreen> createState() => _HelpScreenState();
}

class _HelpScreenState extends State<HelpScreen> {
  final TextEditingController _searchController = TextEditingController();
  bool _isSearching = false;
  
  final List<HelpCategory> _categories = [
    HelpCategory(title: 'Account & Login', description: 'Manage access and security', icon: Icons.lock_outline, articleCount: 8),
    HelpCategory(title: 'Exams', description: 'Syllabus, targets, and exam hubs', icon: Icons.school_outlined, articleCount: 5),
    HelpCategory(title: 'Practice', description: 'Practice arena and questions', icon: Icons.fitness_center_outlined, articleCount: 12),
    HelpCategory(title: 'Mock Tests', description: 'Taking mock tests and reviewing', icon: Icons.timer_outlined, articleCount: 10),
    HelpCategory(title: 'Subscription', description: 'Plans, billing, and payments', icon: Icons.receipt_long_outlined, articleCount: 6),
  ];

  final List<FaqItem> _faqs = [
    FaqItem(question: 'How do I reset my password?', answer: 'Go to the login screen and tap "Forgot Password". Enter your registered email address and follow the instructions in the email to reset your password.'),
    FaqItem(question: 'How do I change my target exam?', answer: 'You can change your target exam at any time by going to your Profile, tapping "Edit Profile", and selecting a new exam from the Target Exam dropdown.'),
    FaqItem(question: 'How do mock tests work?', answer: 'Mock tests simulate the actual exam environment. They are timed and scored identically to the real exam. Once submitted, you can review detailed answer explanations in the Answer Review screen.'),
    FaqItem(question: 'How do I cancel my subscription?', answer: 'Go to Profile > Billing & Subscription > Manage Subscription to manage or cancel your active recurring plan.'),
  ];

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchChanged(String query) {
    setState(() {
      _isSearching = query.trim().isNotEmpty;
    });
    // In a real app, this would trigger a debounced backend search
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFEAE4F7),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF0F0F11)),
          onPressed: () => context.pop(),
        ),
        title: const Text('Help Center', style: TextStyle(color: Color(0xFF0F0F11), fontSize: 18, fontWeight: FontWeight.bold)),
        centerTitle: true,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 1000),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildHeader(),
                  const SizedBox(height: 32),
                  _buildSearchBar(),
                  const SizedBox(height: 48),
                  
                  if (_isSearching)
                    _buildSearchResults()
                  else ...[
                    _buildLayout(),
                    const SizedBox(height: 48),
                    _buildContactSupport(),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('How can we help?', style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: Color(0xFF0F0F11))),
        const SizedBox(height: 8),
        Text('Find answers, troubleshoot issues, or contact support.', style: TextStyle(fontSize: 16, color: const Color(0xFF0F0F11).withValues(alpha: 0.6))),
      ],
    );
  }

  Widget _buildSearchBar() {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFFFFFFF),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 10, offset: const Offset(0, 4)),
        ],
      ),
      child: TextField(
        controller: _searchController,
        onChanged: _onSearchChanged,
        decoration: InputDecoration(
          hintText: 'Search for answers (e.g. "reset password")...',
          hintStyle: TextStyle(color: const Color(0xFF0F0F11).withValues(alpha: 0.4)),
          prefixIcon: const Icon(Icons.search, color: Color(0xFF0F0F11)),
          suffixIcon: _isSearching
              ? IconButton(
                  icon: const Icon(Icons.clear, color: Color(0xFF0F0F11)),
                  onPressed: () {
                    _searchController.clear();
                    _onSearchChanged('');
                  },
                )
              : null,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
          filled: true,
          fillColor: const Color(0xFFFFFFFF),
          contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        ),
      ),
    );
  }

  Widget _buildSearchResults() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(48),
      decoration: BoxDecoration(
        color: const Color(0xFFFFFFFF),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: const Color(0xFFF3F4F6)),
      ),
      child: Column(
        children: [
          Icon(Icons.search_off, size: 48, color: const Color(0xFF0F0F11).withValues(alpha: 0.3)),
          const SizedBox(height: 16),
          const Text('No results found', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF0F0F11))),
          const SizedBox(height: 8),
          Text('Try different keywords or browse a help category below.', textAlign: TextAlign.center, style: TextStyle(color: const Color(0xFF0F0F11).withValues(alpha: 0.6))),
        ],
      ),
    );
  }

  Widget _buildLayout() {
    if (MediaQuery.of(context).size.width >= 800) {
      return Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(flex: 3, child: _buildCategories()),
          const SizedBox(width: 48),
          Expanded(flex: 2, child: _buildFaqsAndTroubleshooting()),
        ],
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildCategories(),
        const SizedBox(height: 48),
        _buildFaqsAndTroubleshooting(),
      ],
    );
  }

  Widget _buildCategories() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Browse Categories', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFF0F0F11))),
        const SizedBox(height: 24),
        LayoutBuilder(
          builder: (context, constraints) {
            int crossAxisCount = constraints.maxWidth > 500 ? 2 : 1;
            return GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: crossAxisCount,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
                childAspectRatio: 2.5,
              ),
              itemCount: _categories.length,
              itemBuilder: (context, index) {
                final cat = _categories[index];
                return _buildCategoryCard(cat);
              },
            );
          },
        ),
      ],
    );
  }

  Widget _buildCategoryCard(HelpCategory cat) {
    return Material(
      color: const Color(0xFFFFFFFF),
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        onTap: () {},
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: const Color(0xFFF3F4F6)),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFFEAE4F7),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(cat.icon, color: const Color(0xFF0F0F11)),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(cat.title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: Color(0xFF0F0F11))),
                    const SizedBox(height: 4),
                    Text(cat.description, style: TextStyle(color: const Color(0xFF0F0F11).withValues(alpha: 0.6), fontSize: 12), maxLines: 1, overflow: TextOverflow.ellipsis),
                    const SizedBox(height: 8),
                    Text('${cat.articleCount} articles →', style: const TextStyle(color: Colors.blueAccent, fontSize: 12, fontWeight: FontWeight.bold)),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFaqsAndTroubleshooting() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Frequently Asked Questions', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFF0F0F11))),
        const SizedBox(height: 24),
        Container(
          decoration: BoxDecoration(
            color: const Color(0xFFFFFFFF),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: const Color(0xFFF3F4F6)),
          ),
          child: ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: _faqs.length,
            separatorBuilder: (context, index) => const Divider(height: 1, color: Color(0xFFF3F4F6)),
            itemBuilder: (context, index) {
              final faq = _faqs[index];
              return ExpansionTile(
                title: Text(faq.question, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14, color: Color(0xFF0F0F11))),
                iconColor: const Color(0xFF0F0F11),
                collapsedIconColor: const Color(0xFF0F0F11).withValues(alpha: 0.5),
                children: [
                  Padding(
                    padding: const EdgeInsets.only(left: 16, right: 16, bottom: 16),
                    child: Text(faq.answer, style: TextStyle(color: const Color(0xFF0F0F11).withValues(alpha: 0.7), height: 1.5, fontSize: 14)),
                  ),
                ],
              );
            },
          ),
        ),
        const SizedBox(height: 48),
        const Text('Quick Troubleshooting', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFF0F0F11))),
        const SizedBox(height: 24),
        Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: const Color(0xFFFFFFFF),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: const Color(0xFFF3F4F6)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildTroubleshootingRow('Login problems'),
              const Divider(height: 24, color: Color(0xFFF3F4F6)),
              _buildTroubleshootingRow('Premium access not updated'),
              const Divider(height: 24, color: Color(0xFFF3F4F6)),
              _buildTroubleshootingRow('Mock test submission issue'),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildTroubleshootingRow(String title) {
    return InkWell(
      onTap: () {},
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(title, style: const TextStyle(fontWeight: FontWeight.w500, color: Color(0xFF0F0F11))),
          Icon(Icons.chevron_right, color: const Color(0xFF0F0F11).withValues(alpha: 0.5)),
        ],
      ),
    );
  }

  Widget _buildContactSupport() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: const Color(0xFFE2F0D9), // Pale Green
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        children: [
          const Icon(Icons.support_agent, size: 48, color: Colors.green),
          const SizedBox(height: 16),
          const Text('Need more help?', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFF0F0F11))),
          const SizedBox(height: 8),
          Text(
            'Support contact options are not configured yet.\n\nPlease do not include passwords, OTPs, or payment details when contacting support.',
            textAlign: TextAlign.center,
            style: TextStyle(color: const Color(0xFF0F0F11).withValues(alpha: 0.7), height: 1.5),
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: null, // Disabled until backend support system exists
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
              backgroundColor: const Color(0xFF0F0F11),
              disabledBackgroundColor: const Color(0xFF0F0F11).withValues(alpha: 0.1),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            ),
            child: const Text('Contact Support (Unavailable)', style: TextStyle(fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }
}
