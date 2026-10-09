import 'package:go_router/go_router.dart';
import 'package:flutter/material.dart';

class CurrentAffair {
  final String id;
  final String category;
  final String title;
  final String summary;
  final String date;
  final bool isBookmarked;
  final List<String> keyFacts;

  CurrentAffair({
    required this.id,
    required this.category,
    required this.title,
    required this.summary,
    required this.date,
    this.isBookmarked = false,
    this.keyFacts = const [],
  });
}

class CurrentAffairsScreen extends StatefulWidget {
  const CurrentAffairsScreen({super.key});

  @override
  State<CurrentAffairsScreen> createState() => _CurrentAffairsScreenState();
}

class _CurrentAffairsScreenState extends State<CurrentAffairsScreen> {
  bool _isLoading = true;
  String _searchQuery = '';
  String? _selectedCategory;
  
  final List<String> _categories = [
    'All',
    'National',
    'International',
    'Economy',
    'Polity',
    'Science & Tech'
  ];

  List<CurrentAffair> _articles = [];

  @override
  void initState() {
    super.initState();
    _selectedCategory = 'All';
    _fetchCurrentAffairs();
  }

  Future<void> _fetchCurrentAffairs() async {
    setState(() => _isLoading = true);
    try {
      await Future.delayed(const Duration(milliseconds: 800)); // Mock network fetch
      
      _articles = [
        CurrentAffair(
          id: 'ca_1',
          category: 'Economy',
          title: 'RBI Monetary Policy Update October 2026',
          summary: 'The Reserve Bank of India maintained the repo rate at 6.5% for the tenth consecutive time, focusing on inflation control while supporting growth.',
          date: 'Today · English',
          isBookmarked: true,
          keyFacts: ['Repo Rate: 6.5%', 'Stance: Withdrawal of accommodation', 'FY27 GDP Projection: 7.2%'],
        ),
        CurrentAffair(
          id: 'ca_2',
          category: 'Science & Tech',
          title: 'ISRO successfully launches new Earth Observation Satellite',
          summary: 'ISRO\'s PSLV-C62 successfully placed the EOS-09 satellite into intended orbit, enhancing agricultural and disaster management capabilities.',
          date: 'Yesterday · English',
          keyFacts: ['Launch Vehicle: PSLV-C62', 'Payload: EOS-09', 'Application: Agriculture & Disaster Management'],
        ),
      ];
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _showArticleDetail(BuildContext context, CurrentAffair article) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.85,
        decoration: const BoxDecoration(
          color: Color(0xFFFFFFFF),
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          children: [
            Container(
              margin: const EdgeInsets.symmetric(vertical: 12),
              width: 40,
              height: 4,
              decoration: BoxDecoration(color: const Color(0xFFEAE4F7), borderRadius: BorderRadius.circular(2)),
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(color: const Color(0xFFE4DBF6), borderRadius: BorderRadius.circular(6)),
                          child: Text(article.category.toUpperCase(), style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.deepPurple)),
                        ),
                        IconButton(
                          icon: Icon(article.isBookmarked ? Icons.bookmark : Icons.bookmark_border, color: article.isBookmarked ? Colors.deepPurple : const Color(0xFF0F0F11)),
                          onPressed: () {}, // Backend bookmark action
                        )
                      ],
                    ),
                    const SizedBox(height: 16),
                    Text(article.title, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Color(0xFF0F0F11))),
                    const SizedBox(height: 8),
                    Text(article.date, style: TextStyle(fontSize: 13, color: const Color(0xFF0F0F11).withValues(alpha: 0.6))),
                    const SizedBox(height: 24),
                    const Text('Summary', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF0F0F11))),
                    const SizedBox(height: 12),
                    Text(article.summary, style: TextStyle(fontSize: 15, height: 1.6, color: const Color(0xFF0F0F11).withValues(alpha: 0.8))),
                    const SizedBox(height: 32),
                    if (article.keyFacts.isNotEmpty) ...[
                      const Text('Key Facts', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF0F0F11))),
                      const SizedBox(height: 16),
                      ...article.keyFacts.map((fact) => Padding(
                            padding: const EdgeInsets.only(bottom: 8.0),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text('• ', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF0F0F11))),
                                Expanded(child: Text(fact, style: TextStyle(fontSize: 15, color: const Color(0xFF0F0F11).withValues(alpha: 0.8)))),
                              ],
                            ),
                          )),
                    ],
                    const SizedBox(height: 32),
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(color: const Color(0xFFFDF0D5), borderRadius: BorderRadius.circular(12)),
                      child: const Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Why This Matters', style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF0F0F11))),
                          SizedBox(height: 8),
                          Text('Important for questions related to Indian Economy and RBI policy changes.', style: TextStyle(fontSize: 13, color: Color(0xFF0F0F11))),
                        ],
                      ),
                    ),
                    const SizedBox(height: 48),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
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
        title: const Text('Current Affairs', style: TextStyle(color: Color(0xFF0F0F11), fontSize: 18, fontWeight: FontWeight.bold)),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Column(
          children: [
            _buildSearchAndFilters(),
            Expanded(
              child: _isLoading ? _buildLoading() : _buildContent(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchAndFilters() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      color: Colors.transparent,
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            decoration: BoxDecoration(
              color: const Color(0xFFFFFFFF),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: const Color(0xFFF3F4F6)),
            ),
            child: Row(
              children: [
                Icon(Icons.search, color: const Color(0xFF0F0F11).withValues(alpha: 0.4)),
                const SizedBox(width: 12),
                Expanded(
                  child: TextField(
                    onChanged: (val) => setState(() => _searchQuery = val),
                    decoration: InputDecoration(
                      hintText: 'Search current affairs...',
                      hintStyle: TextStyle(color: const Color(0xFF0F0F11).withValues(alpha: 0.4)),
                      border: InputBorder.none,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: _categories.map((cat) {
                final isSelected = _selectedCategory == cat;
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: ChoiceChip(
                    label: Text(cat),
                    selected: isSelected,
                    onSelected: (selected) {
                      if (selected) setState(() => _selectedCategory = cat);
                    },
                    selectedColor: const Color(0xFF0F0F11),
                    backgroundColor: const Color(0xFFFFFFFF),
                    labelStyle: TextStyle(
                      color: isSelected ? Colors.white : const Color(0xFF0F0F11),
                      fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLoading() {
    return const Center(child: CircularProgressIndicator(color: Color(0xFF0F0F11)));
  }

  Widget _buildContent() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 800),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildPracticeBanner(),
              const SizedBox(height: 32),
              const Text('Today\'s Current Affairs', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFF0F0F11))),
              const SizedBox(height: 16),
              if (_articles.isEmpty)
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(32),
                  decoration: BoxDecoration(color: const Color(0xFFFFFFFF), borderRadius: BorderRadius.circular(16)),
                  child: const Text('No current affairs available today. Check again later.', textAlign: TextAlign.center, style: TextStyle(color: Colors.grey)),
                )
              else
                ..._articles.map((article) => _buildArticleCard(article)),
                
              const SizedBox(height: 48),
              const Text('Monthly Capsule', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFF0F0F11))),
              const SizedBox(height: 16),
              _buildMonthlyCapsule('October 2026', '124 Articles'),
              _buildMonthlyCapsule('September 2026', '280 Articles'),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPracticeBanner() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: const LinearGradient(colors: [Color(0xFF0F0F11), Color(0xFF2C2C35)]),
        borderRadius: BorderRadius.circular(24),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Practice Current Affairs', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
                const SizedBox(height: 8),
                Text('Test your knowledge on recent events.', style: TextStyle(color: Colors.white.withValues(alpha: 0.7), fontSize: 13)),
              ],
            ),
          ),
          ElevatedButton(
            onPressed: () => context.push('/practice'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.white,
              foregroundColor: const Color(0xFF0F0F11),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            child: const Text('Start Practice', style: TextStyle(fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  Widget _buildArticleCard(CurrentAffair article) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: const Color(0xFFFFFFFF),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFF3F4F6)),
      ),
      child: InkWell(
        onTap: () => _showArticleDetail(context, article),
        borderRadius: BorderRadius.circular(20),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(color: const Color(0xFFF3F4F6), borderRadius: BorderRadius.circular(6)),
                    child: Text(article.category.toUpperCase(), style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Color(0xFF0F0F11))),
                  ),
                  Icon(article.isBookmarked ? Icons.bookmark : Icons.bookmark_border, size: 20, color: article.isBookmarked ? Colors.deepPurple : const Color(0xFF0F0F11).withValues(alpha: 0.4)),
                ],
              ),
              const SizedBox(height: 12),
              Text(article.title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF0F0F11))),
              const SizedBox(height: 8),
              Text(article.summary, maxLines: 2, overflow: TextOverflow.ellipsis, style: TextStyle(fontSize: 13, color: const Color(0xFF0F0F11).withValues(alpha: 0.6))),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(article.date, style: TextStyle(fontSize: 12, color: const Color(0xFF0F0F11).withValues(alpha: 0.5))),
                  const Text('Read', style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Colors.blueAccent)),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMonthlyCapsule(String month, String subtitle) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFFFFFFFF),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFF3F4F6)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(color: const Color(0xFFE2ECE9), borderRadius: BorderRadius.circular(12)),
            child: const Icon(Icons.archive_outlined, color: Colors.teal),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(month, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF0F0F11))),
                const SizedBox(height: 4),
                Text(subtitle, style: TextStyle(fontSize: 13, color: const Color(0xFF0F0F11).withValues(alpha: 0.6))),
              ],
            ),
          ),
          OutlinedButton(
            onPressed: () {}, // Backend logic to filter lists to this month
            style: OutlinedButton.styleFrom(
              side: const BorderSide(color: Color(0xFF0F0F11)),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            child: const Text('Open Capsule', style: TextStyle(color: Color(0xFF0F0F11))),
          ),
        ],
      ),
    );
  }
}
