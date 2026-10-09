import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

class HistoricalNotification {
  final String id;
  final String title;
  final String description;
  final String category;
  final DateTime createdAt;
  final bool isRead;

  HistoricalNotification({
    required this.id,
    required this.title,
    required this.description,
    required this.category,
    required this.createdAt,
    required this.isRead,
  });
}

class NotificationHistoryScreen extends ConsumerStatefulWidget {
  const NotificationHistoryScreen({super.key});

  @override
  ConsumerState<NotificationHistoryScreen> createState() => _NotificationHistoryScreenState();
}

class _NotificationHistoryScreenState extends ConsumerState<NotificationHistoryScreen> {
  bool _isLoading = true;
  bool _isLoadingMore = false;
  String? _error;
  List<HistoricalNotification> _notifications = [];
  
  String _searchQuery = '';
  String _selectedFilter = 'All';
  String _selectedSort = 'Newest';
  
  DateTime? _startDate;
  DateTime? _endDate;

  final ScrollController _scrollController = ScrollController();

  final List<String> _filters = [
    'All',
    'Unread',
    'Read',
    'Study Reminders',
    'Exam Alerts',
    'Mock Test Reminders',
    'System Announcements'
  ];

  @override
  void initState() {
    super.initState();
    _fetchHistory();
    _scrollController.addListener(_onScroll);
  }
  
  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >= _scrollController.position.maxScrollExtent - 200) {
      if (!_isLoadingMore && !_isLoading) {
        _loadMore();
      }
    }
  }

  Future<void> _fetchHistory() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      // Simulate backend fetch
      await Future.delayed(const Duration(milliseconds: 800));

      final now = DateTime.now();
      _notifications = [
        HistoricalNotification(
          id: 'nh1',
          title: 'Daily Goal Achieved',
          description: 'You completed your 4-hour study goal for today.',
          category: 'Study Reminders',
          createdAt: now.subtract(const Duration(hours: 2)),
          isRead: true,
        ),
        HistoricalNotification(
          id: 'nh2',
          title: 'System Maintenance Complete',
          description: 'The scheduled database upgrade has finished.',
          category: 'System Announcements',
          createdAt: now.subtract(const Duration(days: 1)),
          isRead: true,
        ),
        HistoricalNotification(
          id: 'nh3',
          title: 'Upcoming Mock Test',
          description: 'Your full-length mock test starts in 24 hours.',
          category: 'Mock Test Reminders',
          createdAt: now.subtract(const Duration(days: 2)),
          isRead: false,
        ),
        HistoricalNotification(
          id: 'nh4',
          title: 'Exam Date Announced',
          description: 'The preliminary exam dates have been officially released.',
          category: 'Exam Alerts',
          createdAt: now.subtract(const Duration(days: 5)),
          isRead: true,
        ),
        HistoricalNotification(
          id: 'nh5',
          title: 'Missed Study Session',
          description: 'You missed your scheduled revision session yesterday.',
          category: 'Study Reminders',
          createdAt: now.subtract(const Duration(days: 10)),
          isRead: true,
        ),
      ];
    } catch (e) {
      _error = 'Failed to load notification history.';
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _loadMore() async {
    setState(() => _isLoadingMore = true);
    try {
      await Future.delayed(const Duration(milliseconds: 800));
      // Simulate more data
      final lastDate = _notifications.isNotEmpty ? _notifications.last.createdAt : DateTime.now();
      
      final more = List.generate(5, (index) => HistoricalNotification(
        id: 'nh_more_$index',
        title: 'Older Notification ${index + 1}',
        description: 'This is an older notification loaded from history.',
        category: 'Study Reminders',
        createdAt: lastDate.subtract(Duration(days: index + 2)),
        isRead: true,
      ));
      
      if (mounted) {
        setState(() {
          _notifications.addAll(more);
        });
      }
    } finally {
      if (mounted) {
        setState(() => _isLoadingMore = false);
      }
    }
  }

  List<HistoricalNotification> get _filteredNotifications {
    var result = _notifications;

    // Apply Search
    if (_searchQuery.isNotEmpty) {
      final q = _searchQuery.toLowerCase();
      result = result.where((n) => 
        n.title.toLowerCase().contains(q) || 
        n.description.toLowerCase().contains(q)
      ).toList();
    }

    // Apply Filter
    if (_selectedFilter != 'All') {
      if (_selectedFilter == 'Unread') {
        result = result.where((n) => !n.isRead).toList();
      } else if (_selectedFilter == 'Read') {
        result = result.where((n) => n.isRead).toList();
      } else {
        result = result.where((n) => n.category == _selectedFilter).toList();
      }
    }

    // Apply Date Range
    if (_startDate != null) {
      result = result.where((n) => n.createdAt.isAfter(_startDate!.subtract(const Duration(days: 1)))).toList();
    }
    if (_endDate != null) {
      result = result.where((n) => n.createdAt.isBefore(_endDate!.add(const Duration(days: 1)))).toList();
    }

    // Apply Sort
    if (_selectedSort == 'Newest') {
      result.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    } else {
      result.sort((a, b) => a.createdAt.compareTo(b.createdAt));
    }

    return result;
  }

  Future<void> _selectDateRange(BuildContext context) async {
    final picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
      initialDateRange: _startDate != null && _endDate != null
          ? DateTimeRange(start: _startDate!, end: _endDate!)
          : null,
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: Color(0xFF5A31F4),
              onPrimary: Colors.white,
              surface: Colors.white,
              onSurface: Color(0xFF0F0F11),
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() {
        _startDate = picked.start;
        _endDate = picked.end;
      });
    }
  }

  Future<void> _markAsRead(String id) async {
    setState(() {
      final index = _notifications.indexWhere((n) => n.id == id);
      if (index != -1 && !_notifications[index].isRead) {
        final old = _notifications[index];
        _notifications[index] = HistoricalNotification(
          id: old.id,
          title: old.title,
          description: old.description,
          category: old.category,
          createdAt: old.createdAt,
          isRead: true,
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
            const Text('Notification History', style: TextStyle(color: Color(0xFF0F0F11), fontSize: 16, fontWeight: FontWeight.bold)),
            Text('Review your past alerts and updates.', style: TextStyle(color: Colors.grey[700], fontSize: 12, fontWeight: FontWeight.normal)),
          ],
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: Color(0xFF5A31F4)),
            onPressed: _fetchHistory,
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
              onPressed: _fetchHistory,
              style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF5A31F4), foregroundColor: Colors.white),
              child: const Text('Retry'),
            ),
          ],
        ),
      );
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        return Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 900),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _buildSearchAndFilters(),
                Expanded(
                  child: _filteredNotifications.isEmpty
                      ? _buildEmptyState()
                      : _buildList(),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildSearchAndFilters() {
    return Container(
      color: const Color(0xFFEAE4F7),
      padding: const EdgeInsets.fromLTRB(24, 16, 24, 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Expanded(
                child: TextField(
                  decoration: InputDecoration(
                    hintText: 'Search history...',
                    prefixIcon: const Icon(Icons.search, color: Colors.grey),
                    suffixIcon: _searchQuery.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.clear, size: 18),
                            onPressed: () => setState(() => _searchQuery = ''),
                          )
                        : null,
                    filled: true,
                    fillColor: Colors.white,
                    contentPadding: const EdgeInsets.symmetric(vertical: 0),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: Colors.grey[300]!),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: Colors.grey[300]!),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: Color(0xFF5A31F4)),
                    ),
                  ),
                  onChanged: (val) => setState(() => _searchQuery = val),
                ),
              ),
              const SizedBox(width: 12),
              PopupMenuButton<String>(
                initialValue: _selectedSort,
                onSelected: (val) => setState(() => _selectedSort = val),
                icon: const Icon(Icons.sort, color: Color(0xFF0F0F11)),
                itemBuilder: (context) => [
                  const PopupMenuItem(value: 'Newest', child: Text('Newest First')),
                  const PopupMenuItem(value: 'Oldest', child: Text('Oldest First')),
                ],
              ),
            ],
          ),
          const SizedBox(height: 16),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                ActionChip(
                  avatar: const Icon(Icons.calendar_month, size: 16),
                  label: Text(_startDate != null && _endDate != null
                      ? '${DateFormat('MMM d').format(_startDate!)} - ${DateFormat('MMM d').format(_endDate!)}'
                      : 'Date Range'),
                  onPressed: () => _selectDateRange(context),
                  backgroundColor: _startDate != null ? const Color(0xFFE4DBF6) : Colors.white,
                  side: BorderSide(color: _startDate != null ? const Color(0xFF5A31F4) : Colors.grey[300]!),
                ),
                if (_startDate != null) ...[
                  const SizedBox(width: 8),
                  InkWell(
                    onTap: () => setState(() { _startDate = null; _endDate = null; }),
                    child: Container(
                      padding: const EdgeInsets.all(6),
                      decoration: const BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.close, size: 16, color: Colors.grey),
                    ),
                  ),
                ],
                const SizedBox(width: 16),
                Container(width: 1, height: 24, color: Colors.grey[400]),
                const SizedBox(width: 16),
                ..._filters.map((filter) {
                  final isSelected = _selectedFilter == filter;
                  return Padding(
                    padding: const EdgeInsets.only(right: 8),
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
                }),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    final hasActiveFilters = _searchQuery.isNotEmpty || _selectedFilter != 'All' || _startDate != null;
    
    return Container(
      padding: const EdgeInsets.all(48),
      alignment: Alignment.center,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(hasActiveFilters ? Icons.search_off : Icons.history, size: 64, color: Colors.grey[400]),
          const SizedBox(height: 24),
          Text(
            hasActiveFilters ? "No matching notifications" : "No notification history yet",
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF0F0F11)),
          ),
          const SizedBox(height: 8),
          Text(
            hasActiveFilters ? "Try another keyword or adjust your filters." : "Notifications you receive will appear here.",
            style: TextStyle(color: Colors.grey[600]),
            textAlign: TextAlign.center,
          ),
          if (hasActiveFilters) ...[
            const SizedBox(height: 24),
            TextButton(
              onPressed: () {
                setState(() {
                  _searchQuery = '';
                  _selectedFilter = 'All';
                  _startDate = null;
                  _endDate = null;
                });
              },
              child: const Text('Clear All Filters'),
            ),
          ]
        ],
      ),
    );
  }

  Widget _buildList() {
    final list = _filteredNotifications;
    return ListView.separated(
      controller: _scrollController,
      padding: const EdgeInsets.fromLTRB(24, 8, 24, 24),
      itemCount: list.length + (_isLoadingMore ? 1 : 0),
      separatorBuilder: (context, index) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        if (index == list.length) {
          return const Padding(
            padding: EdgeInsets.symmetric(vertical: 24),
            child: Center(child: CircularProgressIndicator(color: Color(0xFF5A31F4))),
          );
        }

        final item = list[index];
        
        IconData iconData;
        if (item.category == 'System Announcements') iconData = Icons.campaign_outlined;
        else if (item.category == 'Mock Test Reminders') iconData = Icons.timer_outlined;
        else if (item.category == 'Study Reminders') iconData = Icons.menu_book_outlined;
        else if (item.category == 'Exam Alerts') iconData = Icons.event_available_outlined;
        else iconData = Icons.notifications_none;

        return Container(
          decoration: BoxDecoration(
            color: item.isRead ? Colors.white : const Color(0xFFF9F8FD),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: item.isRead ? const Color(0xFFF3F4F6) : const Color(0xFFE4DBF6)),
          ),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: () {
                _markAsRead(item.id);
                context.go('/notifications/${item.id}');
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
                                item.category,
                                style: TextStyle(color: Colors.grey[600], fontSize: 11, fontWeight: FontWeight.bold),
                              ),
                              Text(
                                DateFormat('MMM d, yyyy').format(item.createdAt),
                                style: TextStyle(color: Colors.grey[500], fontSize: 11),
                              ),
                            ],
                          ),
                          const SizedBox(height: 6),
                          Text(
                            item.title,
                            style: TextStyle(
                              fontWeight: item.isRead ? FontWeight.w600 : FontWeight.bold,
                              fontSize: 15,
                              color: const Color(0xFF0F0F11),
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            item.description,
                            style: TextStyle(color: Colors.grey[700], height: 1.4, fontSize: 13),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                    if (!item.isRead) ...[
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
