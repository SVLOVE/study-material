import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

class CurrentAffairsArticle {
  final String id;
  final String title;
  final String category;
  final DateTime publishedDate;
  final String summary;
  final bool isRead;
  final bool isBookmarked;
  final List<String> tags;
  final String relevance;

  CurrentAffairsArticle({
    required this.id,
    required this.title,
    required this.category,
    required this.publishedDate,
    required this.summary,
    required this.isRead,
    required this.isBookmarked,
    required this.tags,
    required this.relevance,
  });
}

class CurrentAffairsAlertScreen extends ConsumerStatefulWidget {
  final String alertId;

  const CurrentAffairsAlertScreen({
    super.key,
    required this.alertId,
  });

  @override
  ConsumerState<CurrentAffairsAlertScreen> createState() => _CurrentAffairsAlertScreenState();
}

class _CurrentAffairsAlertScreenState extends ConsumerState<CurrentAffairsAlertScreen> {
  bool _isLoading = true;
  String? _error;
  CurrentAffairsArticle? _article;
  List<CurrentAffairsArticle> _relatedArticles = [];
  bool _isBookmarking = false;
  bool _isBookmarked = false;

  @override
  void initState() {
    super.initState();
    _fetchAlertDetails();
  }

  Future<void> _fetchAlertDetails() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      // Simulate backend fetch
      await Future.delayed(const Duration(milliseconds: 800));

      if (widget.alertId == 'invalid') {
        _article = null;
      } else {
        _article = CurrentAffairsArticle(
          id: widget.alertId,
          title: 'India successfully tests new generation Agni-Prime missile',
          category: 'Science and Technology',
          publishedDate: DateTime.now().subtract(const Duration(hours: 2)),
          summary: 'The Defence Research and Development Organisation (DRDO) successfully test-fired the new generation nuclear-capable ballistic missile Agni-P from Dr APJ Abdul Kalam island off the coast of Odisha. The missile followed textbook trajectory, meeting all mission objectives with high level of accuracy.',
          isRead: false,
          isBookmarked: false,
          tags: ['Defence', 'DRDO', 'Missiles', 'Odisha'],
          relevance: 'Highly relevant for TNPSC Group 1 & 2 Science and Tech section, and UPSC Prelims.',
        );
        _isBookmarked = _article!.isBookmarked;

        _relatedArticles = [
          CurrentAffairsArticle(
            id: 'rel_1',
            title: 'ISRO launches meteorological satellite INSAT-3DS',
            category: 'Science and Technology',
            publishedDate: DateTime.now().subtract(const Duration(days: 2)),
            summary: 'ISRO successfully launched the GSLV-F14/INSAT-3DS mission from Sriharikota to enhance weather forecasting.',
            isRead: true,
            isBookmarked: true,
            tags: ['Space', 'ISRO', 'Satellites'],
            relevance: '',
          ),
          CurrentAffairsArticle(
            id: 'rel_2',
            title: 'Global Innovation Index 2026: India retains 40th rank',
            category: 'Economy',
            publishedDate: DateTime.now().subtract(const Duration(days: 5)),
            summary: 'India maintains its robust innovation trajectory in the latest Global Innovation Index rankings published by WIPO.',
            isRead: true,
            isBookmarked: false,
            tags: ['Index', 'Innovation', 'Economy'],
            relevance: '',
          ),
        ];
      }
    } catch (e) {
      _error = 'Failed to load current affairs alert.';
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _handleBookmarkToggle() async {
    setState(() => _isBookmarking = true);

    try {
      await Future.delayed(const Duration(milliseconds: 600));

      if (mounted) {
        setState(() {
          _isBookmarked = !_isBookmarked;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(_isBookmarked ? 'Article bookmarked successfully.' : 'Bookmark removed.'),
            backgroundColor: const Color(0xFF5A31F4),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isBookmarking = false);
      }
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
          onPressed: () {
            if (context.canPop()) {
              context.pop();
            } else {
              context.go('/notifications');
            }
          },
        ),
        title: const Text('Current Affairs Alert', style: TextStyle(color: Color(0xFF0F0F11), fontSize: 18, fontWeight: FontWeight.bold)),
        centerTitle: true,
      ),
      body: SafeArea(
        child: _buildBody(),
      ),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator(color: Color(0xFF5A31F4)));
    }

    if (_error != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 48, color: Colors.red),
            const SizedBox(height: 16),
            Text(_error!, style: const TextStyle(color: Color(0xFF0F0F11), fontSize: 16)),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: _fetchAlertDetails,
              style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF5A31F4), foregroundColor: Colors.white),
              child: const Text('Retry'),
            ),
          ],
        ),
      );
    }

    if (_article == null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.article_outlined, size: 48, color: Colors.grey[400]),
            const SizedBox(height: 16),
            const Text('Article Not Found', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF0F0F11))),
            const SizedBox(height: 8),
            Text('The requested current affairs article is unavailable.', style: TextStyle(color: Colors.grey[600])),
            const SizedBox(height: 24),
            OutlinedButton(
              onPressed: () => context.go('/dashboard'), // Assuming there's a CA section accessible from dashboard
              child: const Text('Browse Current Affairs'),
            ),
          ],
        ),
      );
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        final isDesktop = constraints.maxWidth > 900;

        return SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 900),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Text(
                    'Stay informed about important developments for your exams.',
                    style: TextStyle(color: Color(0xFF0F0F11), fontSize: 14),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 32),

                  if (isDesktop)
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          flex: 5,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              _buildFeaturedAlertCard(),
                              const SizedBox(height: 24),
                              _buildActions(),
                              const SizedBox(height: 24),
                              _buildRelatedArticles(),
                            ],
                          ),
                        ),
                        const SizedBox(width: 24),
                        Expanded(
                          flex: 3,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              _buildExamRelevanceCard(),
                            ],
                          ),
                        ),
                      ],
                    )
                  else
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        _buildFeaturedAlertCard(),
                        const SizedBox(height: 24),
                        _buildExamRelevanceCard(),
                        const SizedBox(height: 24),
                        _buildActions(),
                        const SizedBox(height: 24),
                        _buildRelatedArticles(),
                      ],
                    ),

                  const SizedBox(height: 32),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildFeaturedAlertCard() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFF3F4F6)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xFFE2ECE9),
                  borderRadius: BorderRadius.circular(100),
                ),
                child: Text(
                  _article!.category,
                  style: const TextStyle(
                    color: Color(0xFF2E6559),
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              Text(
                DateFormat('MMM d, yyyy • h:mm a').format(_article!.publishedDate),
                style: TextStyle(color: Colors.grey[600], fontSize: 13),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            _article!.title,
            style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Color(0xFF0F0F11), height: 1.3),
          ),
          const SizedBox(height: 16),
          Text(
            _article!.summary,
            style: TextStyle(fontSize: 15, color: Colors.grey[800], height: 1.6),
          ),
        ],
      ),
    );
  }

  Widget _buildExamRelevanceCard() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: const Color(0xFFFDF0D5),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.orange.withValues(alpha: 0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.lightbulb_outline, color: Colors.orange[800], size: 20),
              const SizedBox(width: 8),
              Text(
                'Why This Matters',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.orange[900]),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            _article!.relevance,
            style: TextStyle(fontSize: 14, color: Colors.orange[900], height: 1.5),
          ),
          const SizedBox(height: 16),
          const Divider(height: 1, color: Colors.black12),
          const SizedBox(height: 16),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: _article!.tags.map((tag) {
              return Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.5),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.orange.withValues(alpha: 0.2)),
                ),
                child: Text(
                  '#$tag',
                  style: TextStyle(color: Colors.orange[900], fontSize: 12),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildActions() {
    return Row(
      children: [
        Expanded(
          flex: 2,
          child: ElevatedButton.icon(
            onPressed: () => context.go('/dashboard'), // Replace with actual article view path when available
            icon: const Icon(Icons.article, size: 18),
            label: const Text('Read Full Article'),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF5A31F4),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              elevation: 0,
            ),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          flex: 1,
          child: OutlinedButton.icon(
            onPressed: _isBookmarking ? null : _handleBookmarkToggle,
            icon: _isBookmarking
                ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2))
                : Icon(_isBookmarked ? Icons.bookmark : Icons.bookmark_border, size: 18),
            label: Text(_isBookmarked ? 'Saved' : 'Save'),
            style: OutlinedButton.styleFrom(
              foregroundColor: _isBookmarked ? const Color(0xFF5A31F4) : const Color(0xFF0F0F11),
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              side: BorderSide(color: _isBookmarked ? const Color(0xFF5A31F4) : const Color(0xFFE4DBF6), width: 2),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildRelatedArticles() {
    if (_relatedArticles.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Related Current Affairs', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF0F0F11))),
        const SizedBox(height: 16),
        ListView.separated(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: _relatedArticles.length,
          separatorBuilder: (context, index) => const SizedBox(height: 12),
          itemBuilder: (context, index) {
            final article = _relatedArticles[index];
            return Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: const Color(0xFFF3F4F6)),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          article.category,
                          style: const TextStyle(color: Color(0xFF2E6559), fontSize: 11, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          article.title,
                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Color(0xFF0F0F11)),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          DateFormat('MMM d').format(article.publishedDate),
                          style: TextStyle(color: Colors.grey[500], fontSize: 12),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),
                  IconButton(
                    icon: const Icon(Icons.arrow_forward_ios, size: 14, color: Colors.grey),
                    onPressed: () => context.go('/dashboard'), // Link to related article when available
                  ),
                ],
              ),
            );
          },
        ),
      ],
    );
  }
}
