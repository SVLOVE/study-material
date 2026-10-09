import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

class SystemAnnouncement {
  final String id;
  final String title;
  final String summary;
  final String category;
  final DateTime publishedDate;
  final bool isRead;
  final String priority; // 'High', 'Medium', 'Low'
  final DateTime? effectiveDate;
  final DateTime? endDate;
  final String? affectedService;

  SystemAnnouncement({
    required this.id,
    required this.title,
    required this.summary,
    required this.category,
    required this.publishedDate,
    required this.isRead,
    required this.priority,
    this.effectiveDate,
    this.endDate,
    this.affectedService,
  });
}

class SystemAnnouncementsScreen extends ConsumerStatefulWidget {
  const SystemAnnouncementsScreen({super.key});

  @override
  ConsumerState<SystemAnnouncementsScreen> createState() => _SystemAnnouncementsScreenState();
}

class _SystemAnnouncementsScreenState extends ConsumerState<SystemAnnouncementsScreen> {
  bool _isLoading = true;
  String? _error;
  List<SystemAnnouncement> _announcements = [];
  String _selectedFilter = 'All';

  final List<String> _filters = [
    'All',
    'Unread',
    'Platform Updates',
    'Maintenance',
    'Feature Updates',
    'Security and Policy'
  ];

  @override
  void initState() {
    super.initState();
    _fetchAnnouncements();
  }

  Future<void> _fetchAnnouncements() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      // Simulate backend fetch
      await Future.delayed(const Duration(milliseconds: 800));

      _announcements = [
        SystemAnnouncement(
          id: 'sa1',
          title: 'Scheduled Maintenance for Mock Test Engine',
          summary: 'The mock test evaluation engine will undergo scheduled upgrades to improve scoring speed. Tests cannot be submitted during this window.',
          category: 'Maintenance',
          publishedDate: DateTime.now().subtract(const Duration(hours: 5)),
          isRead: false,
          priority: 'High',
          affectedService: 'Mock Test Engine',
          effectiveDate: DateTime.now().add(const Duration(days: 2, hours: 10)),
          endDate: DateTime.now().add(const Duration(days: 2, hours: 12)),
        ),
        SystemAnnouncement(
          id: 'sa2',
          title: 'New Feature: AI-Powered Essay Grading',
          summary: 'GovPrep Pro users can now access instant, AI-driven feedback for descriptive answers in the Mains preparation module.',
          category: 'Feature Updates',
          publishedDate: DateTime.now().subtract(const Duration(days: 2)),
          isRead: true,
          priority: 'Medium',
        ),
        SystemAnnouncement(
          id: 'sa3',
          title: 'Updated Privacy Policy',
          summary: 'We have updated our privacy policy regarding data retention limits for free accounts. Please review the changes.',
          category: 'Security and Policy',
          publishedDate: DateTime.now().subtract(const Duration(days: 15)),
          isRead: true,
          priority: 'Low',
          effectiveDate: DateTime.now().subtract(const Duration(days: 1)),
        ),
      ];
    } catch (e) {
      _error = 'Failed to load system announcements.';
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  List<SystemAnnouncement> get _filteredAnnouncements {
    if (_selectedFilter == 'All') return _announcements;
    if (_selectedFilter == 'Unread') return _announcements.where((a) => !a.isRead).toList();
    if (_selectedFilter == 'Platform Updates') return _announcements.where((a) => a.category == 'Platform Updates').toList();
    if (_selectedFilter == 'Maintenance') return _announcements.where((a) => a.category == 'Maintenance').toList();
    if (_selectedFilter == 'Feature Updates') return _announcements.where((a) => a.category == 'Feature Updates').toList();
    if (_selectedFilter == 'Security and Policy') return _announcements.where((a) => a.category == 'Security and Policy').toList();
    return _announcements;
  }

  Future<void> _markAsRead(String id) async {
    setState(() {
      final index = _announcements.indexWhere((a) => a.id == id);
      if (index != -1 && !_announcements[index].isRead) {
        final old = _announcements[index];
        _announcements[index] = SystemAnnouncement(
          id: old.id,
          title: old.title,
          summary: old.summary,
          category: old.category,
          publishedDate: old.publishedDate,
          isRead: true,
          priority: old.priority,
          effectiveDate: old.effectiveDate,
          endDate: old.endDate,
          affectedService: old.affectedService,
        );
      }
    });
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
        title: Column(
          children: [
            const Text('System Announcements', style: TextStyle(color: Color(0xFF0F0F11), fontSize: 16, fontWeight: FontWeight.bold)),
            Text('Important updates and service information.', style: TextStyle(color: Colors.grey[700], fontSize: 12, fontWeight: FontWeight.normal)),
          ],
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: Color(0xFF5A31F4)),
            onPressed: _fetchAnnouncements,
          ),
        ],
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
              onPressed: _fetchAnnouncements,
              style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF5A31F4), foregroundColor: Colors.white),
              child: const Text('Retry'),
            ),
          ],
        ),
      );
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        return SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 900),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _buildFilters(),
                  const SizedBox(height: 24),
                  
                  if (_filteredAnnouncements.isNotEmpty) ...[
                    if (_selectedFilter == 'All' || _selectedFilter == 'Unread') ...[
                      const Text('Featured Announcement', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Colors.grey)),
                      const SizedBox(height: 12),
                      _buildFeaturedAnnouncement(_filteredAnnouncements.first),
                      const SizedBox(height: 32),
                      const Text('Recent Announcements', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Colors.grey)),
                      const SizedBox(height: 12),
                    ],
                    _buildAnnouncementsList(),
                  ] else ...[
                    _buildEmptyState(),
                  ],
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildFilters() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: _filters.map((filter) {
          final isSelected = _selectedFilter == filter;
          return Padding(
            padding: const EdgeInsets.only(right: 12),
            child: FilterChip(
              label: Text(filter),
              selected: isSelected,
              onSelected: (selected) {
                if (selected) setState(() => _selectedFilter = filter);
              },
              backgroundColor: Colors.white,
              selectedColor: const Color(0xFFE4DBF6),
              labelStyle: TextStyle(
                color: isSelected ? const Color(0xFF5A31F4) : Colors.grey[700],
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
                side: BorderSide(
                  color: isSelected ? const Color(0xFF5A31F4) : const Color(0xFFE5E7EB),
                ),
              ),
              showCheckmark: false,
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Container(
      padding: const EdgeInsets.all(48),
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFF3F4F6)),
      ),
      child: Column(
        children: [
          Icon(Icons.campaign_outlined, size: 64, color: Colors.grey[300]),
          const SizedBox(height: 24),
          const Text(
            "No announcements yet",
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF0F0F11)),
          ),
          const SizedBox(height: 8),
          Text(
            "Important platform updates will appear here when available.",
            style: TextStyle(color: Colors.grey[600]),
            textAlign: TextAlign.center,
          ),
          if (_selectedFilter != 'All') ...[
            const SizedBox(height: 24),
            TextButton(
              onPressed: () => setState(() => _selectedFilter = 'All'),
              child: const Text('View All Announcements'),
            ),
          ]
        ],
      ),
    );
  }

  Widget _buildFeaturedAnnouncement(SystemAnnouncement announcement) {
    Color priorityColor;
    if (announcement.priority == 'High') {
      priorityColor = Colors.orange[800]!;
    } else if (announcement.priority == 'Medium') {
      priorityColor = const Color(0xFF5A31F4);
    } else {
      priorityColor = Colors.grey[600]!;
    }

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: const Color(0xFFE4DBF6), width: 2),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF5A31F4).withValues(alpha: 0.05),
            blurRadius: 20,
            offset: const Offset(0, 10),
          )
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: priorityColor.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(100),
                    ),
                    child: Text(
                      announcement.category.toUpperCase(),
                      style: TextStyle(color: priorityColor, fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 1),
                    ),
                  ),
                  if (announcement.priority == 'High') ...[
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.red.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(100),
                      ),
                      child: const Row(
                        children: [
                          Icon(Icons.warning_rounded, color: Colors.red, size: 12),
                          SizedBox(width: 4),
                          Text(
                            'URGENT',
                            style: TextStyle(color: Colors.red, fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 1),
                          ),
                        ],
                      ),
                    ),
                  ]
                ],
              ),
              if (!announcement.isRead)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: const Color(0xFF5A31F4),
                    borderRadius: BorderRadius.circular(100),
                  ),
                  child: const Text('NEW', style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold)),
                ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            announcement.title,
            style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Color(0xFF0F0F11), height: 1.3),
          ),
          const SizedBox(height: 12),
          Text(
            announcement.summary,
            style: TextStyle(color: Colors.grey[700], height: 1.5, fontSize: 15),
          ),
          if (announcement.category == 'Maintenance' && announcement.effectiveDate != null) ...[
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFFFDF0D5),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.orange.withValues(alpha: 0.2)),
              ),
              child: Row(
                children: [
                  Icon(Icons.schedule, color: Colors.orange[800], size: 20),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Maintenance Window', style: TextStyle(color: Colors.orange[900], fontWeight: FontWeight.bold, fontSize: 12)),
                        const SizedBox(height: 4),
                        Text(
                          '${DateFormat('MMM d, h:mm a').format(announcement.effectiveDate!)} - ${DateFormat('h:mm a').format(announcement.endDate ?? announcement.effectiveDate!.add(const Duration(hours: 2)))}',
                          style: TextStyle(color: Colors.orange[900], fontSize: 14),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
          const SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Published ${DateFormat('MMM d, yyyy').format(announcement.publishedDate)}',
                style: TextStyle(color: Colors.grey[500], fontSize: 12),
              ),
              TextButton.icon(
                onPressed: () {
                  _markAsRead(announcement.id);
                  context.go('/notifications/${announcement.id}');
                },
                style: TextButton.styleFrom(
                  foregroundColor: const Color(0xFF5A31F4),
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  backgroundColor: const Color(0xFFE4DBF6).withValues(alpha: 0.5),
                ),
                icon: const Text('Read Announcement', style: TextStyle(fontWeight: FontWeight.bold)),
                label: const Icon(Icons.arrow_forward_ios, size: 14),
              ),
            ],
          )
        ],
      ),
    );
  }

  Widget _buildAnnouncementsList() {
    final list = (_selectedFilter == 'All' || _selectedFilter == 'Unread') 
        ? _filteredAnnouncements.skip(1).toList() 
        : _filteredAnnouncements;

    if (list.isEmpty) return const SizedBox.shrink();

    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: list.length,
      separatorBuilder: (context, index) => const SizedBox(height: 16),
      itemBuilder: (context, index) {
        final a = list[index];

        IconData iconData;
        if (a.category == 'Maintenance') {
          iconData = Icons.build_circle_outlined;
        } else if (a.category == 'Feature Updates') {
          iconData = Icons.new_releases_outlined;
        } else if (a.category == 'Security and Policy') {
          iconData = Icons.gavel_outlined;
        } else {
          iconData = Icons.campaign_outlined;
        }

        return Container(
          decoration: BoxDecoration(
            color: a.isRead ? Colors.white : const Color(0xFFF9F8FD),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: a.isRead ? const Color(0xFFF3F4F6) : const Color(0xFFE4DBF6)),
          ),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: () {
                _markAsRead(a.id);
                context.go('/notifications/${a.id}');
              },
              borderRadius: BorderRadius.circular(16),
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: const Color(0xFFE2ECE9),
                        shape: BoxShape.circle,
                        border: Border.all(color: const Color(0xFF2E6559).withValues(alpha: 0.1)),
                      ),
                      child: Icon(iconData, color: const Color(0xFF2E6559), size: 24),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                a.category,
                                style: TextStyle(color: Colors.grey[600], fontSize: 11, fontWeight: FontWeight.bold),
                              ),
                              Text(
                                DateFormat('MMM d').format(a.publishedDate),
                                style: TextStyle(color: Colors.grey[500], fontSize: 11),
                              ),
                            ],
                          ),
                          const SizedBox(height: 6),
                          Text(
                            a.title,
                            style: TextStyle(
                              fontWeight: a.isRead ? FontWeight.w600 : FontWeight.bold,
                              fontSize: 16,
                              color: const Color(0xFF0F0F11),
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            a.summary,
                            style: TextStyle(color: Colors.grey[700], height: 1.4, fontSize: 14),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                    if (!a.isRead) ...[
                      const SizedBox(width: 16),
                      Container(
                        width: 8,
                        height: 8,
                        margin: const EdgeInsets.only(top: 8),
                        decoration: const BoxDecoration(
                          color: Color(0xFF5A31F4),
                          shape: BoxShape.circle,
                        ),
                      ),
                    ]
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
