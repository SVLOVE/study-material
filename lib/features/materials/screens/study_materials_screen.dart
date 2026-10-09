import 'package:go_router/go_router.dart';
import 'package:flutter/material.dart';

class StudyResource {
  final String id;
  final String title;
  final String type; // Notes, PDF, Video, Article
  final String subject;
  final String topic;
  final String language;
  final bool isPremium;
  final bool isBookmarked;
  final double? progress; // 0.0 to 1.0

  StudyResource({
    required this.id,
    required this.title,
    required this.type,
    required this.subject,
    required this.topic,
    required this.language,
    this.isPremium = false,
    this.isBookmarked = false,
    this.progress,
  });
}

class StudyMaterialsScreen extends StatefulWidget {
  const StudyMaterialsScreen({super.key});

  @override
  State<StudyMaterialsScreen> createState() => _StudyMaterialsScreenState();
}

class _StudyMaterialsScreenState extends State<StudyMaterialsScreen> {
  bool _isLoading = true;
  String _searchQuery = '';
  String _selectedFilter = 'All';

  final List<String> _filters = ['All', 'Notes', 'PDF', 'Video', 'Article'];
  List<StudyResource> _resources = [];
  List<StudyResource> _recentResources = [];

  final String _targetExam = 'UPSC Civil Services';

  @override
  void initState() {
    super.initState();
    _fetchMaterials();
  }

  Future<void> _fetchMaterials() async {
    setState(() => _isLoading = true);
    try {
      await Future.delayed(const Duration(milliseconds: 600)); // Mock network

      _recentResources = [
        StudyResource(
          id: 'res_1',
          title: 'Indian Polity - Fundamental Rights Summary',
          type: 'Notes',
          subject: 'Indian Polity',
          topic: 'Fundamental Rights',
          language: 'English',
          progress: 0.65,
        ),
      ];

      _resources = [
        StudyResource(
          id: 'res_2',
          title: 'Modern History Timeline - 1857 to 1947',
          type: 'PDF',
          subject: 'History',
          topic: 'Modern History',
          language: 'English',
          isPremium: true,
        ),
        StudyResource(
          id: 'res_3',
          title: 'Geography - Physical Features of India',
          type: 'Video',
          subject: 'Geography',
          topic: 'Physical Geography',
          language: 'தமிழ்',
          isBookmarked: true,
        ),
        StudyResource(
          id: 'res_4',
          title: 'Constitution of India Overview',
          type: 'Article',
          subject: 'Indian Polity',
          topic: 'Constitution',
          language: 'English',
        ),
      ];
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _openResource(StudyResource resource) {
    if (resource.isPremium) {
      // Mock entitlement check failure routing to plans
      context.push('/plans');
      return;
    }
    
    if (resource.type == 'PDF') {
      context.push('/pdf-viewer', extra: {'url': 'mock_url', 'title': resource.title});
    } else {
      // Mock article/video detail screen flow conceptually
      _showResourceDetail(resource);
    }
  }

  void _showResourceDetail(StudyResource resource) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.9,
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
                          decoration: BoxDecoration(color: const Color(0xFFF3F4F6), borderRadius: BorderRadius.circular(6)),
                          child: Text(resource.type.toUpperCase(), style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Color(0xFF0F0F11))),
                        ),
                        IconButton(
                          icon: Icon(resource.isBookmarked ? Icons.bookmark : Icons.bookmark_border, color: resource.isBookmarked ? Colors.deepPurple : const Color(0xFF0F0F11)),
                          onPressed: () {},
                        )
                      ],
                    ),
                    const SizedBox(height: 16),
                    Text(resource.title, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Color(0xFF0F0F11))),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Text('${resource.subject} • ${resource.topic}', style: TextStyle(fontSize: 13, color: const Color(0xFF0F0F11).withValues(alpha: 0.6))),
                      ],
                    ),
                    const SizedBox(height: 32),
                    const Text('Content', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF0F0F11))),
                    const SizedBox(height: 16),
                    Text(
                      'This is a placeholder for the structured article or notes content retrieved securely from the backend. The reading experience is clean with comfortable line heights.',
                      style: TextStyle(fontSize: 16, height: 1.6, color: const Color(0xFF0F0F11).withValues(alpha: 0.8)),
                    ),
                    const SizedBox(height: 48),
                    Container(
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF9FAFB),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: const Color(0xFFF3F4F6)),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Practice This Topic', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF0F0F11))),
                          const SizedBox(height: 12),
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
                              onPressed: () => context.push('/practice'), // Existing practice integration
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF0F0F11),
                                foregroundColor: Colors.white,
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                padding: const EdgeInsets.symmetric(vertical: 16),
                              ),
                              child: const Text('Practice Questions'),
                            ),
                          )
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                    Center(
                      child: TextButton(
                        onPressed: () => context.push('/syllabus'),
                        child: const Text('View in Syllabus', style: TextStyle(color: Colors.deepPurple, fontWeight: FontWeight.bold)),
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

  IconData _getTypeIcon(String type) {
    switch (type) {
      case 'PDF': return Icons.picture_as_pdf;
      case 'Video': return Icons.play_circle;
      case 'Article': return Icons.article;
      case 'Notes': return Icons.description;
      default: return Icons.insert_drive_file;
    }
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
        title: const Text('Study Materials', style: TextStyle(color: Color(0xFF0F0F11), fontSize: 18, fontWeight: FontWeight.bold)),
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
                      hintText: 'Search study materials...',
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
              children: _filters.map((filter) {
                final isSelected = _selectedFilter == filter;
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: ChoiceChip(
                    label: Text(filter),
                    selected: isSelected,
                    onSelected: (selected) {
                      if (selected) setState(() => _selectedFilter = filter);
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
    if (_resources.isEmpty && _recentResources.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.menu_book, size: 64, color: Colors.grey),
              const SizedBox(height: 16),
              const Text('No Study Materials Yet', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFF0F0F11))),
              const SizedBox(height: 8),
              const Text('Learning resources for this exam haven\'t been added yet.', textAlign: TextAlign.center, style: TextStyle(color: Colors.grey)),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: () => context.push('/syllabus'),
                style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF0F0F11), foregroundColor: Colors.white),
                child: const Text('Explore Syllabus'),
              )
            ],
          ),
        ),
      );
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1100),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Target Exam: $_targetExam', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: const Color(0xFF0F0F11).withValues(alpha: 0.6))),
              const SizedBox(height: 24),

              if (_recentResources.isNotEmpty) ...[
                const Text('Continue Learning', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFF0F0F11))),
                const SizedBox(height: 16),
                _buildResourceGrid(_recentResources),
                const SizedBox(height: 32),
              ],

              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Recommended Resources', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFF0F0F11))),
                  TextButton(
                    onPressed: () {}, // Backend logic to view saved materials conceptually
                    child: const Text('Saved Materials'),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              _buildResourceGrid(_resources),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildResourceGrid(List<StudyResource> items) {
    return LayoutBuilder(
      builder: (context, constraints) {
        int columns = constraints.maxWidth >= 800 ? 3 : (constraints.maxWidth >= 600 ? 2 : 1);
        
        return GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: columns,
            mainAxisSpacing: 16,
            crossAxisSpacing: 16,
            childAspectRatio: 1.5,
          ),
          itemCount: items.length,
          itemBuilder: (context, index) {
            return _buildResourceCard(items[index]);
          },
        );
      },
    );
  }

  Widget _buildResourceCard(StudyResource resource) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFFFFFFF),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFF3F4F6)),
      ),
      child: InkWell(
        onTap: () => _openResource(resource),
        borderRadius: BorderRadius.circular(20),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(color: const Color(0xFFE4DBF6), borderRadius: BorderRadius.circular(8)),
                        child: Icon(_getTypeIcon(resource.type), size: 16, color: Colors.deepPurple),
                      ),
                      const SizedBox(width: 8),
                      Text(resource.type, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFF0F0F11))),
                    ],
                  ),
                  if (resource.isPremium)
                    const Icon(Icons.lock_outline, size: 16, color: Colors.orange)
                  else
                    Icon(resource.isBookmarked ? Icons.bookmark : Icons.bookmark_border, size: 16, color: resource.isBookmarked ? Colors.deepPurple : Colors.grey),
                ],
              ),
              const Spacer(),
              Text(resource.title, maxLines: 2, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF0F0F11))),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(child: Text('${resource.subject} • ${resource.language}', maxLines: 1, overflow: TextOverflow.ellipsis, style: TextStyle(fontSize: 12, color: const Color(0xFF0F0F11).withValues(alpha: 0.6)))),
                ],
              ),
              if (resource.progress != null) ...[
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(2),
                        child: LinearProgressIndicator(
                          value: resource.progress,
                          backgroundColor: const Color(0xFFF3F4F6),
                          color: const Color(0xFF0F0F11),
                          minHeight: 4,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text('${(resource.progress! * 100).toInt()}%', style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold)),
                  ],
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
