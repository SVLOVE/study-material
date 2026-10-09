import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class StudyCommunityScreen extends StatefulWidget {
  const StudyCommunityScreen({super.key});

  @override
  State<StudyCommunityScreen> createState() => _StudyCommunityScreenState();
}

class _StudyCommunityScreenState extends State<StudyCommunityScreen> with SingleTickerProviderStateMixin {
  bool _isLoading = true;
  late TabController _tabController;
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _fetchCommunityData();
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _fetchCommunityData() async {
    setState(() => _isLoading = true);
    // Simulate backend fetch for community data (friends, requests, groups)
    await Future.delayed(const Duration(milliseconds: 700));
    if (mounted) setState(() => _isLoading = false);
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
              context.go('/home');
            }
          },
        ),
        title: const Text('Study Community', style: TextStyle(color: Color(0xFF0F0F11), fontSize: 18, fontWeight: FontWeight.bold)),
        centerTitle: true,
        actions: [
          Stack(
            alignment: Alignment.center,
            children: [
              IconButton(
                icon: const Icon(Icons.person_add, color: Color(0xFF0F0F11)),
                onPressed: () => _tabController.animateTo(1),
              ),
              Positioned(
                right: 8,
                top: 8,
                child: Container(
                  padding: const EdgeInsets.all(4),
                  decoration: const BoxDecoration(
                    color: Colors.red,
                    shape: BoxShape.circle,
                  ),
                  child: const Text('2', style: TextStyle(color: Colors.white, fontSize: 8, fontWeight: FontWeight.bold)),
                ),
              ),
            ],
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: SafeArea(
        child: _isLoading ? const Center(child: CircularProgressIndicator(color: Color(0xFF0F0F11))) : _buildContent(),
      ),
    );
  }

  Widget _buildContent() {
    return Column(
      children: [
        _buildHeader(),
        TabBar(
          controller: _tabController,
          labelColor: const Color(0xFF5A31F4),
          unselectedLabelColor: Colors.grey[600],
          indicatorColor: const Color(0xFF5A31F4),
          indicatorWeight: 3,
          labelStyle: const TextStyle(fontWeight: FontWeight.bold),
          tabs: const [
            Tab(text: 'My Connections'),
            Tab(text: 'Requests (2)'),
            Tab(text: 'Study Groups'),
          ],
        ),
        Expanded(
          child: TabBarView(
            controller: _tabController,
            children: [
              _buildConnectionsTab(),
              _buildRequestsTab(),
              _buildGroupsTab(),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 0, 24, 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Friends & Community', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Color(0xFF0F0F11))),
          const SizedBox(height: 4),
          Text('Connect, share motivation, and prepare together.', style: TextStyle(fontSize: 14, color: Colors.grey[700])),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: const Color(0xFFF3F4F6)),
            ),
            child: Row(
              children: [
                const Icon(Icons.search, color: Colors.grey),
                const SizedBox(width: 8),
                Expanded(
                  child: TextField(
                    controller: _searchController,
                    decoration: const InputDecoration(
                      hintText: 'Search aspirants by name or exam...',
                      border: InputBorder.none,
                      hintStyle: TextStyle(color: Colors.grey, fontSize: 14),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildConnectionsTab() {
    return RefreshIndicator(
      onRefresh: _fetchCommunityData,
      child: ListView(
        padding: const EdgeInsets.all(24),
        children: [
          _buildCommunityOverview(),
          const SizedBox(height: 24),
          const Text('Your Friends', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF0F0F11))),
          const SizedBox(height: 16),
          _buildFriendCard(
            name: 'Anand S.',
            exam: 'TNPSC Group 1',
            status: 'Studying Indian Polity',
            isOnline: true,
            avatarColor: Colors.blue,
          ),
          _buildFriendCard(
            name: 'Priya K.',
            exam: 'UPSC CSE',
            status: 'Completed a Mock Test',
            isOnline: false,
            avatarColor: Colors.purple,
          ),
          _buildFriendCard(
            name: 'Karthik R.',
            exam: 'SSC CGL',
            status: 'Active 2 hours ago',
            isOnline: false,
            avatarColor: Colors.orange,
          ),
        ],
      ),
    );
  }

  Widget _buildRequestsTab() {
    return RefreshIndicator(
      onRefresh: _fetchCommunityData,
      child: ListView(
        padding: const EdgeInsets.all(24),
        children: [
          const Text('Pending Invitations', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF0F0F11))),
          const SizedBox(height: 16),
          _buildRequestCard(
            name: 'Suresh V.',
            exam: 'TNPSC Group 2',
            date: '2 days ago',
            isOutgoing: false,
            avatarColor: Colors.teal,
          ),
          _buildRequestCard(
            name: 'Divya M.',
            exam: 'Banking PO',
            date: 'Today',
            isOutgoing: false,
            avatarColor: Colors.pink,
          ),
          const SizedBox(height: 32),
          const Text('Find Study Partners', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF0F0F11))),
          const SizedBox(height: 16),
          _buildSuggestedPartnerCard(name: 'Ramesh K.', exam: 'TNPSC Group 1', avatarColor: Colors.indigo),
          _buildSuggestedPartnerCard(name: 'Lakshmi N.', exam: 'TNPSC Group 1', avatarColor: Colors.deepOrange),
        ],
      ),
    );
  }

  Widget _buildGroupsTab() {
    return RefreshIndicator(
      onRefresh: _fetchCommunityData,
      child: ListView(
        padding: const EdgeInsets.all(24),
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Your Study Groups', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF0F0F11))),
              TextButton(onPressed: () {}, child: const Text('Create New', style: TextStyle(color: Color(0xFF5A31F4), fontWeight: FontWeight.bold))),
            ],
          ),
          const SizedBox(height: 16),
          _buildStudyGroupCard(
            name: 'TNPSC Group 1 Achievers',
            category: 'TNPSC',
            members: 124,
            description: 'Daily discussions and shared mock tests for Group 1.',
            isMember: true,
          ),
          _buildStudyGroupCard(
            name: 'UPSC Current Affairs',
            category: 'UPSC',
            members: 45,
            description: 'Focus on daily news analysis and editorial breakdown.',
            isMember: true,
          ),
          const SizedBox(height: 24),
          const Text('Discover Groups', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF0F0F11))),
          const SizedBox(height: 16),
          _buildStudyGroupCard(
            name: 'SSC Practice Circle',
            category: 'SSC',
            members: 89,
            description: 'Quantitative aptitude and reasoning practice.',
            isMember: false,
          ),
        ],
      ),
    );
  }

  Widget _buildCommunityOverview() {
    return Row(
      children: [
        Expanded(child: _buildMetricCard('Friends', '12')),
        const SizedBox(width: 16),
        Expanded(child: _buildMetricCard('Groups', '2')),
        const SizedBox(width: 16),
        Expanded(child: _buildMetricCard('Requests', '2', isAlert: true)),
      ],
    );
  }

  Widget _buildMetricCard(String title, String value, {bool isAlert = false}) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isAlert ? const Color(0xFFFDF0D5) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: isAlert ? Colors.orange.withValues(alpha: 0.3) : const Color(0xFFF3F4F6)),
      ),
      child: Column(
        children: [
          Text(value, style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: isAlert ? Colors.orange : const Color(0xFF0F0F11))),
          const SizedBox(height: 4),
          Text(title, style: TextStyle(fontSize: 12, color: Colors.grey[600])),
        ],
      ),
    );
  }

  Widget _buildFriendCard({required String name, required String exam, required String status, required bool isOnline, required Color avatarColor}) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFF3F4F6)),
      ),
      child: Row(
        children: [
          Stack(
            children: [
              CircleAvatar(
                backgroundColor: avatarColor.withValues(alpha: 0.2),
                radius: 24,
                child: Text(name[0], style: TextStyle(color: avatarColor, fontWeight: FontWeight.bold, fontSize: 20)),
              ),
              if (isOnline)
                Positioned(
                  right: 0,
                  bottom: 0,
                  child: Container(
                    width: 12,
                    height: 12,
                    decoration: BoxDecoration(color: Colors.green, shape: BoxShape.circle, border: Border.all(color: Colors.white, width: 2)),
                  ),
                ),
            ],
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                const SizedBox(height: 2),
                Text(exam, style: const TextStyle(fontSize: 12, color: Color(0xFF5A31F4), fontWeight: FontWeight.bold)),
                const SizedBox(height: 4),
                Text(status, style: TextStyle(fontSize: 12, color: Colors.grey[600]), overflow: TextOverflow.ellipsis),
              ],
            ),
          ),
          IconButton(
            icon: const Icon(Icons.more_vert, color: Colors.grey),
            onPressed: () {
              // Show bottom sheet with profile/remove options
            },
          ),
        ],
      ),
    );
  }

  Widget _buildRequestCard({required String name, required String exam, required String date, required bool isOutgoing, required Color avatarColor}) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFF3F4F6)),
      ),
      child: Row(
        children: [
          CircleAvatar(
            backgroundColor: avatarColor.withValues(alpha: 0.2),
            radius: 24,
            child: Text(name[0], style: TextStyle(color: avatarColor, fontWeight: FontWeight.bold, fontSize: 20)),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                const SizedBox(height: 2),
                Text(exam, style: TextStyle(fontSize: 12, color: Colors.grey[700])),
                const SizedBox(height: 2),
                Text('Received $date', style: TextStyle(fontSize: 10, color: Colors.grey[500])),
              ],
            ),
          ),
          Row(
            children: [
              IconButton(
                icon: const Icon(Icons.close, color: Colors.red),
                style: IconButton.styleFrom(backgroundColor: Colors.red.withValues(alpha: 0.1)),
                onPressed: () {},
              ),
              const SizedBox(width: 8),
              IconButton(
                icon: const Icon(Icons.check, color: Colors.green),
                style: IconButton.styleFrom(backgroundColor: Colors.green.withValues(alpha: 0.1)),
                onPressed: () {},
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSuggestedPartnerCard({required String name, required String exam, required Color avatarColor}) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFF3F4F6)),
      ),
      child: Row(
        children: [
          CircleAvatar(
            backgroundColor: avatarColor.withValues(alpha: 0.2),
            radius: 20,
            child: Text(name[0], style: TextStyle(color: avatarColor, fontWeight: FontWeight.bold, fontSize: 16)),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                const SizedBox(height: 2),
                Text('Preparing for $exam', style: TextStyle(fontSize: 12, color: Colors.grey[600])),
              ],
            ),
          ),
          TextButton(
            onPressed: () {},
            style: TextButton.styleFrom(
              backgroundColor: const Color(0xFF5A31F4).withValues(alpha: 0.1),
              foregroundColor: const Color(0xFF5A31F4),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
            child: const Text('Connect', style: TextStyle(fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  Widget _buildStudyGroupCard({required String name, required String category, required int members, required String description, required bool isMember}) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFF3F4F6)),
        boxShadow: [
          BoxShadow(color: const Color(0xFF0F0F11).withValues(alpha: 0.05), blurRadius: 10, offset: const Offset(0, 4)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(child: Text(name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Color(0xFF0F0F11)))),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xFFFDF0D5),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(category, style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.orange)),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(description, style: TextStyle(fontSize: 13, color: Colors.grey[700])),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Icon(Icons.people, size: 16, color: Colors.grey[600]),
                  const SizedBox(width: 4),
                  Text('$members members', style: TextStyle(fontSize: 12, color: Colors.grey[600])),
                ],
              ),
              ElevatedButton(
                onPressed: () {},
                style: ElevatedButton.styleFrom(
                  backgroundColor: isMember ? const Color(0xFFE4DBF6) : const Color(0xFF0F0F11),
                  foregroundColor: isMember ? const Color(0xFF5A31F4) : Colors.white,
                  elevation: 0,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                ),
                child: Text(isMember ? 'Open Group' : 'Join Group', style: const TextStyle(fontWeight: FontWeight.bold)),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
