import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class BenefitData {
  final String id;
  final String title;
  final String description;
  final IconData icon;
  final String category;
  final bool isPremiumOnly;
  final String requiredPlan;
  final String detailedDescription;

  BenefitData({
    required this.id,
    required this.title,
    required this.description,
    required this.icon,
    required this.category,
    required this.isPremiumOnly,
    required this.requiredPlan,
    required this.detailedDescription,
  });
}

class PremiumBenefitsScreen extends StatefulWidget {
  const PremiumBenefitsScreen({super.key});

  @override
  State<PremiumBenefitsScreen> createState() => _PremiumBenefitsScreenState();
}

class _PremiumBenefitsScreenState extends State<PremiumBenefitsScreen> {
  bool _isLoading = true;
  String _currentPlanId = 'free'; // Simulated backend entitlement
  int _selectedCategoryIndex = 0;
  
  List<BenefitData> _benefits = [];
  final List<String> _categories = [
    'All Benefits',
    'Practice',
    'Mock Tests',
    'Progress Insights',
    'Study Resources',
  ];

  @override
  void initState() {
    super.initState();
    _fetchBenefitsData();
  }

  Future<void> _fetchBenefitsData() async {
    setState(() => _isLoading = true);
    try {
      await Future.delayed(const Duration(milliseconds: 700));
      
      _benefits = [
        BenefitData(
          id: 'b1',
          title: 'Unlimited Practice',
          description: 'Access the entire question bank without daily limits.',
          icon: Icons.all_inclusive,
          category: 'Practice',
          isPremiumOnly: true,
          requiredPlan: 'Pro',
          detailedDescription: 'Break free from daily practice limits. Pro users can practice as many questions as they need across all subjects and topics.',
        ),
        BenefitData(
          id: 'b2',
          title: 'Full-Length Mock Tests',
          description: 'Take comprehensive mock tests modeled after real exams.',
          icon: Icons.quiz,
          category: 'Mock Tests',
          isPremiumOnly: true,
          requiredPlan: 'Basic',
          detailedDescription: 'Experience the real exam environment with our full-length mock tests, complete with detailed performance analysis.',
        ),
        BenefitData(
          id: 'b3',
          title: 'Advanced Analytics',
          description: 'Identify weak topics with AI-powered performance insights.',
          icon: Icons.analytics,
          category: 'Progress Insights',
          isPremiumOnly: true,
          requiredPlan: 'Pro',
          detailedDescription: 'Our advanced analytics engine breaks down your performance topic-by-topic, highlighting precisely where you need to focus your revision.',
        ),
        BenefitData(
          id: 'b4',
          title: 'Previous Year Papers',
          description: 'Practice with verified previous year question papers.',
          icon: Icons.history_edu,
          category: 'Study Resources',
          isPremiumOnly: true,
          requiredPlan: 'Basic',
          detailedDescription: 'Get access to our extensive archive of verified previous year question papers to understand exam patterns and trends.',
        ),
        BenefitData(
          id: 'b5',
          title: 'Personalized Study Plan',
          description: 'Get an AI-generated study schedule tailored to your goals.',
          icon: Icons.auto_awesome,
          category: 'Progress Insights',
          isPremiumOnly: true,
          requiredPlan: 'Pro',
          detailedDescription: 'Let GovPrep AI analyze your available time and weak areas to create a dynamic, personalized study schedule that adapts as you improve.',
        ),
        BenefitData(
          id: 'b6',
          title: 'Topic-wise Practice',
          description: 'Focus your preparation on specific syllabus topics.',
          icon: Icons.subject,
          category: 'Practice',
          isPremiumOnly: false,
          requiredPlan: 'Free',
          detailedDescription: 'Drill down into specific subjects and topics to master individual concepts before tackling mixed practice sets.',
        ),
      ];
      
    } finally {
      if (mounted) setState(() => _isLoading = false);
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
              context.go('/plans');
            }
          },
        ),
        title: const Text('Premium Benefits', style: TextStyle(color: Color(0xFF0F0F11), fontSize: 18, fontWeight: FontWeight.bold)),
        centerTitle: true,
      ),
      body: SafeArea(
        child: _isLoading ? const Center(child: CircularProgressIndicator(color: Color(0xFF0F0F11))) : _buildContent(),
      ),
    );
  }

  Widget _buildContent() {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeader(),
          const SizedBox(height: 24),
          _buildSubscriptionStatusBanner(),
          const SizedBox(height: 32),
          _buildCategoryFilters(),
          const SizedBox(height: 24),
          _buildBenefitsGrid(),
          const SizedBox(height: 64),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Unlock Your Potential',
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Color(0xFF0F0F11)),
        ),
        const SizedBox(height: 4),
        Text(
          'Explore the tools and resources available with your plan.',
          style: TextStyle(fontSize: 14, color: Colors.grey[700]),
        ),
      ],
    );
  }

  Widget _buildSubscriptionStatusBanner() {
    final bool isFree = _currentPlanId == 'free';
    
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFE4DBF6), width: 2),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: isFree ? Colors.grey[100] : const Color(0xFF5A31F4).withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  isFree ? Icons.lock_outline : Icons.workspace_premium, 
                  color: isFree ? Colors.grey[600] : const Color(0xFF5A31F4),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      isFree ? 'Current Plan: Free' : 'Current Plan: Pro (Active)',
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Color(0xFF0F0F11)),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      isFree 
                          ? 'Premium access depends on your selected subscription.'
                          : 'You have full access to all premium features.',
                      style: TextStyle(fontSize: 13, color: Colors.grey[600]),
                    ),
                  ],
                ),
              ),
            ],
          ),
          if (isFree) ...[
            const SizedBox(height: 16),
            const Divider(height: 1, color: Color(0xFFF3F4F6)),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: () => context.push('/plan-comparison'),
                  style: TextButton.styleFrom(foregroundColor: const Color(0xFF0F0F11)),
                  child: const Text('Compare Plans', style: TextStyle(fontWeight: FontWeight.bold)),
                ),
                const SizedBox(width: 16),
                ElevatedButton(
                  onPressed: () => context.push('/plans'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF0F0F11),
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: const Text('View Plans', style: TextStyle(fontWeight: FontWeight.bold)),
                ),
              ],
            )
          ]
        ],
      ),
    );
  }

  Widget _buildCategoryFilters() {
    return SizedBox(
      height: 48,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: _categories.length,
        separatorBuilder: (context, index) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          final isSelected = _selectedCategoryIndex == index;
          return ChoiceChip(
            label: Text(_categories[index]),
            selected: isSelected,
            onSelected: (selected) {
              if (selected) setState(() => _selectedCategoryIndex = index);
            },
            selectedColor: const Color(0xFF0F0F11),
            labelStyle: TextStyle(
              color: isSelected ? Colors.white : const Color(0xFF0F0F11),
              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            ),
            backgroundColor: Colors.white,
            side: BorderSide(color: isSelected ? Colors.transparent : const Color(0xFFF3F4F6)),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          );
        },
      ),
    );
  }

  Widget _buildBenefitsGrid() {
    final selectedCategory = _categories[_selectedCategoryIndex];
    final filteredBenefits = _benefits.where((b) {
      if (selectedCategory == 'All Benefits') return true;
      return b.category == selectedCategory;
    }).toList();

    if (filteredBenefits.isEmpty) {
      return _buildEmptyState();
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        final crossAxisCount = constraints.maxWidth > 700 ? 2 : 1;
        
        return GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: crossAxisCount,
            childAspectRatio: crossAxisCount == 1 ? 2.5 : 1.8,
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
            mainAxisExtent: 180, // Fixed height for predictable layout
          ),
          itemCount: filteredBenefits.length,
          itemBuilder: (context, index) {
            return _buildBenefitCard(filteredBenefits[index]);
          },
        );
      },
    );
  }

  Widget _buildBenefitCard(BenefitData benefit) {
    // Simulated entitlement check
    final bool hasAccess = _currentPlanId != 'free' || !benefit.isPremiumOnly;
    final Color iconColor = hasAccess ? const Color(0xFF5A31F4) : Colors.grey;

    return InkWell(
      onTap: () => _showBenefitDetailsModal(benefit, hasAccess),
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.all(20),
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
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: iconColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(benefit.icon, color: iconColor, size: 24),
                ),
                if (!hasAccess)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.grey[100],
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.lock, size: 12, color: Colors.grey),
                        const SizedBox(width: 4),
                        Text(benefit.requiredPlan, style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.grey)),
                      ],
                    ),
                  )
                else
                  const Icon(Icons.arrow_forward_ios, size: 14, color: Colors.grey),
              ],
            ),
            const Spacer(),
            Text(
              benefit.title,
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: hasAccess ? const Color(0xFF0F0F11) : Colors.grey[700]),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 4),
            Text(
              benefit.description,
              style: TextStyle(fontSize: 12, color: Colors.grey[600], height: 1.3),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }

  void _showBenefitDetailsModal(BenefitData benefit, bool hasAccess) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(24),
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(width: 40, height: 4, decoration: BoxDecoration(color: Colors.grey[300], borderRadius: BorderRadius.circular(2))),
              const SizedBox(height: 32),
              
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: (hasAccess ? const Color(0xFF5A31F4) : Colors.grey).withValues(alpha: 0.1), 
                  shape: BoxShape.circle
                ),
                child: Icon(benefit.icon, color: hasAccess ? const Color(0xFF5A31F4) : Colors.grey, size: 48),
              ),
              const SizedBox(height: 24),
              
              Text(benefit.title, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Color(0xFF0F0F11))),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xFFF3F4F6),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(benefit.category, style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.grey[700])),
              ),
              
              const SizedBox(height: 24),
              Text(benefit.detailedDescription, textAlign: TextAlign.center, style: TextStyle(fontSize: 14, color: Colors.grey[700], height: 1.5)),
              const SizedBox(height: 32),
              
              if (!hasAccess) ...[
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(color: const Color(0xFFFDF0D5), borderRadius: BorderRadius.circular(16)),
                  child: Row(
                    children: [
                      const Icon(Icons.info_outline, color: Colors.orange),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          'This feature is available on the ${benefit.requiredPlan} plan. Upgrade to unlock this and many other premium tools.',
                          style: const TextStyle(fontSize: 13, color: Color(0xFF0F0F11)),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      context.pop();
                      context.push('/plans');
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF0F0F11),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    ),
                    child: const Text('Explore Plans', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                  ),
                ),
              ] else ...[
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () => context.pop(),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF5A31F4),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    ),
                    child: const Text('Got it', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                  ),
                ),
              ],
              const SizedBox(height: 16),
            ],
          ),
        );
      },
    );
  }

  Widget _buildEmptyState() {
    return Container(
      padding: const EdgeInsets.all(32),
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: const Color(0xFFF3F4F6)),
      ),
      child: Column(
        children: [
          Icon(Icons.auto_awesome_mosaic, size: 48, color: Colors.grey[300]),
          const SizedBox(height: 16),
          const Text('No Benefits Found', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF0F0F11))),
          const SizedBox(height: 8),
          Text(
            'No additional benefits are available in this category right now. Explore your plan details to see the features currently included.',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 14, color: Colors.grey[600]),
          ),
          const SizedBox(height: 24),
          OutlinedButton(
            onPressed: () => setState(() => _selectedCategoryIndex = 0),
            style: OutlinedButton.styleFrom(
              foregroundColor: const Color(0xFF0F0F11),
              side: const BorderSide(color: Color(0xFFF3F4F6)),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            child: const Text('View All Benefits'),
          ),
        ],
      ),
    );
  }
}
