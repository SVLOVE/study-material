import 'package:go_router/go_router.dart';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class Plan {
  final String id;
  final String name;
  final String description;
  final String? priceMonthly;
  final String? priceYearly;
  final List<String> features;
  final bool isRecommended;
  final bool isFree;

  Plan({
    required this.id,
    required this.name,
    required this.description,
    this.priceMonthly,
    this.priceYearly,
    required this.features,
    this.isRecommended = false,
    this.isFree = false,
  });
}

class PlansScreen extends StatefulWidget {
  const PlansScreen({super.key});

  @override
  State<PlansScreen> createState() => _PlansScreenState();
}

class _PlansScreenState extends State<PlansScreen> {
  bool _isLoading = true;
  String _billingPeriod = 'Monthly'; // 'Monthly' or 'Yearly'
  final String _currentPlanId = 'free'; // Mocked backend entitlement
  final String _subscriptionStatus = 'Active'; 
  List<Plan> _plans = [];
  final bool _isCheckoutPending = false;

  @override
  void initState() {
    super.initState();
    _fetchPlans();
  }

  Future<void> _fetchPlans() async {
    setState(() => _isLoading = true);
    try {
      // Simulating backend fetch for plans and entitlement
      await Future.delayed(const Duration(milliseconds: 800));
      
      _plans = [
        Plan(
          id: 'free',
          name: 'Free',
          description: 'Start preparing at no cost.',
          features: [
            'Daily practice (Limited)',
            'Limited mock tests',
            'Question bank access',
            'Basic performance tracking',
          ],
          isFree: true,
        ),
        Plan(
          id: 'basic',
          name: 'Basic',
          description: 'More practice for consistent preparation.',
          priceMonthly: '₹299',
          priceYearly: '₹2,999',
          features: [
            'Expanded daily practice',
            'More mock tests',
            'Expanded question bank',
            'Detailed performance analysis',
            'Bookmarks',
          ],
        ),
        Plan(
          id: 'pro',
          name: 'Pro',
          description: 'Complete preparation for serious exam goals.',
          priceMonthly: '₹599',
          priceYearly: '₹5,999',
          isRecommended: true,
          features: [
            'Unlimited practice limits',
            'Full mock-test access',
            'Advanced performance analytics',
            'Personalized recommendations',
            'Premium preparation resources',
          ],
        ),
      ];

      // In a real app, we would query the backend or Supabase profiles table for the actual entitlement:
      final user = Supabase.instance.client.auth.currentUser;
      if (user != null) {
        // e.g. _currentPlanId = await EntitlementService.getCurrentPlan(user.id);
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _handleUpgrade(Plan plan) async {
    if (plan.id == _currentPlanId) return;

    final price = _billingPeriod == 'Monthly' ? plan.priceMonthly : plan.priceYearly;
    if (price != null) {
      context.push(Uri(
        path: '/checkout',
        queryParameters: {
          'planId': plan.id,
          'billingPeriod': _billingPeriod,
          'planName': plan.name,
          'price': price,
        },
      ).toString());
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
        title: Text(_currentPlanId == 'free' ? 'Choose Your Plan' : 'Your Plan', style: const TextStyle(color: Color(0xFF0F0F11), fontSize: 18, fontWeight: FontWeight.bold)),
        centerTitle: true,
      ),
      body: SafeArea(
        child: _isLoading ? _buildLoading() : _buildContent(),
      ),
    );
  }

  Widget _buildLoading() {
    return const Center(
      child: CircularProgressIndicator(color: Color(0xFF0F0F11)),
    );
  }

  Widget _buildContent() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1100),
          child: Column(
            children: [
              Text(
                _currentPlanId == 'free' 
                    ? 'Get the preparation tools that fit your exam goals.'
                    : 'Manage your current GovPrep AI plan.',
                style: TextStyle(fontSize: 16, color: const Color(0xFF0F0F11).withValues(alpha: 0.6)),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 32),
              
              if (_currentPlanId != 'free') _buildCurrentSubscriptionStatus(),
              
              const SizedBox(height: 32),
              _buildBillingToggle(),
              const SizedBox(height: 48),
              
              LayoutBuilder(
                builder: (context, constraints) {
                  if (constraints.maxWidth >= 900) {
                    return Row(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: _plans.map((p) => Expanded(child: _buildPlanCard(p))).toList(),
                    );
                  } else {
                    return Column(
                      children: _plans.map((p) => Padding(
                        padding: const EdgeInsets.only(bottom: 24),
                        child: _buildPlanCard(p),
                      )).toList(),
                    );
                  }
                },
              ),
              
              const SizedBox(height: 64),
              _buildFeatureComparison(),
              const SizedBox(height: 48),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCurrentSubscriptionStatus() {
    final currentPlan = _plans.firstWhere((p) => p.id == _currentPlanId, orElse: () => _plans.first);
    
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: const Color(0xFFFFFFFF),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFF3F4F6)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text('Current Plan: ${currentPlan.name}', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF0F0F11))),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: const Color(0xFFE2F0D9), // Pale Green
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(_subscriptionStatus, style: const TextStyle(color: Colors.green, fontWeight: FontWeight.bold, fontSize: 12)),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text('Renews on 24 Nov 2026', style: TextStyle(color: const Color(0xFF0F0F11).withValues(alpha: 0.6))),
          const SizedBox(height: 16),
          OutlinedButton(
            onPressed: () {},
            style: OutlinedButton.styleFrom(
              foregroundColor: const Color(0xFF0F0F11),
              side: const BorderSide(color: Color(0xFFF3F4F6)),
            ),
            child: const Text('Manage Subscription'),
          ),
        ],
      ),
    );
  }

  Widget _buildBillingToggle() {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: const Color(0xFFF3F4F6),
        borderRadius: BorderRadius.circular(30),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildToggleButton('Monthly'),
          _buildToggleButton('Yearly'),
        ],
      ),
    );
  }

  Widget _buildToggleButton(String type) {
    final isSelected = _billingPeriod == type;
    return GestureDetector(
      onTap: () => setState(() => _billingPeriod = type),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFFFFFFFF) : Colors.transparent,
          borderRadius: BorderRadius.circular(26),
          boxShadow: isSelected ? [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 4, offset: const Offset(0, 2))] : [],
        ),
        child: Row(
          children: [
            Text(type, style: TextStyle(fontWeight: isSelected ? FontWeight.bold : FontWeight.w500, color: const Color(0xFF0F0F11))),
            if (type == 'Yearly') ...[
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(color: const Color(0xFFFDF0D5), borderRadius: BorderRadius.circular(4)),
                child: const Text('Save 15%', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.orange)),
              ),
            ]
          ],
        ),
      ),
    );
  }

  Widget _buildPlanCard(Plan plan) {
    final isCurrent = plan.id == _currentPlanId;
    final isRecommended = plan.isRecommended;
    
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 12),
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: const Color(0xFFFFFFFF),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: isCurrent || isRecommended ? const Color(0xFFE4DBF6) : const Color(0xFFF3F4F6), width: isCurrent || isRecommended ? 2 : 1),
        boxShadow: [
          if (isCurrent || isRecommended) BoxShadow(color: const Color(0xFFE4DBF6).withValues(alpha: 0.3), blurRadius: 20, offset: const Offset(0, 10))
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (isRecommended)
            Container(
              margin: const EdgeInsets.only(bottom: 16),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(color: const Color(0xFFE4DBF6), borderRadius: BorderRadius.circular(8)),
              child: const Text('RECOMMENDED', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Color(0xFF0F0F11))),
            ),
          Text(plan.name, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Color(0xFF0F0F11))),
          const SizedBox(height: 8),
          Text(plan.description, style: TextStyle(color: const Color(0xFF0F0F11).withValues(alpha: 0.6), height: 1.4)),
          const SizedBox(height: 24),
          
          if (plan.isFree)
            const Text('₹0', style: TextStyle(fontSize: 40, fontWeight: FontWeight.bold, color: Color(0xFF0F0F11)))
          else
            Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(_billingPeriod == 'Monthly' ? plan.priceMonthly! : plan.priceYearly!, style: const TextStyle(fontSize: 40, fontWeight: FontWeight.bold, color: Color(0xFF0F0F11))),
                Padding(
                  padding: const EdgeInsets.only(bottom: 8, left: 4),
                  child: Text(_billingPeriod == 'Monthly' ? '/ month' : '/ year', style: TextStyle(color: const Color(0xFF0F0F11).withValues(alpha: 0.6))),
                ),
              ],
            ),
            
          const SizedBox(height: 32),
          
          if (isCurrent)
            SizedBox(
              width: double.infinity,
              child: OutlinedButton(
                onPressed: null,
                style: OutlinedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 16), disabledForegroundColor: const Color(0xFF0F0F11).withValues(alpha: 0.5), side: BorderSide(color: const Color(0xFFF3F4F6))),
                child: const Text('Current Plan', style: TextStyle(fontWeight: FontWeight.bold)),
              ),
            )
          else
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _isCheckoutPending ? null : () => _handleUpgrade(plan),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  backgroundColor: plan.isRecommended ? const Color(0xFF0F0F11) : const Color(0xFFF3F4F6),
                  foregroundColor: plan.isRecommended ? Colors.white : const Color(0xFF0F0F11),
                  elevation: 0,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                ),
                child: _isCheckoutPending ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white)) : const Text('Upgrade', style: TextStyle(fontWeight: FontWeight.bold)),
              ),
            ),
            
          const SizedBox(height: 32),
          const Divider(height: 1, color: Color(0xFFF3F4F6)),
          const SizedBox(height: 24),
          
          ...plan.features.map((feature) => Padding(
            padding: const EdgeInsets.only(bottom: 16),
            child: Row(
              children: [
                const Icon(Icons.check_circle, color: Color(0xFFE2F0D9), size: 20),
                const SizedBox(width: 12),
                Expanded(child: Text(feature, style: const TextStyle(color: Color(0xFF0F0F11), fontSize: 14))),
              ],
            ),
          )),
        ],
      ),
    );
  }

  Widget _buildFeatureComparison() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: const Color(0xFFFFFFFF),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: const Color(0xFFF3F4F6)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Feature Comparison', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFF0F0F11))),
          const SizedBox(height: 24),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: DataTable(
              headingRowColor: WidgetStateProperty.all(const Color(0xFFF3F4F6)),
              dataRowColor: WidgetStateProperty.all(Colors.transparent),
              dividerThickness: 1,
              columns: const [
                DataColumn(label: Text('Feature', style: TextStyle(fontWeight: FontWeight.bold))),
                DataColumn(label: Text('Free', style: TextStyle(fontWeight: FontWeight.bold))),
                DataColumn(label: Text('Basic', style: TextStyle(fontWeight: FontWeight.bold))),
                DataColumn(label: Text('Pro', style: TextStyle(fontWeight: FontWeight.bold))),
              ],
              rows: const [
                DataRow(cells: [
                  DataCell(Text('Practice Questions')),
                  DataCell(Text('Limited')),
                  DataCell(Text('More')),
                  DataCell(Text('Full')),
                ]),
                DataRow(cells: [
                  DataCell(Text('Mock Tests')),
                  DataCell(Text('Limited')),
                  DataCell(Text('More')),
                  DataCell(Text('Full')),
                ]),
                DataRow(cells: [
                  DataCell(Text('Performance Analysis')),
                  DataCell(Text('Basic')),
                  DataCell(Text('Detailed')),
                  DataCell(Text('Advanced')),
                ]),
                DataRow(cells: [
                  DataCell(Text('Personalized Recommendations')),
                  DataCell(Text('—', style: TextStyle(color: Colors.grey))),
                  DataCell(Icon(Icons.check, color: Colors.green, size: 20)),
                  DataCell(Icon(Icons.check, color: Colors.green, size: 20)),
                ]),
                DataRow(cells: [
                  DataCell(Text('Premium Resources')),
                  DataCell(Text('—', style: TextStyle(color: Colors.grey))),
                  DataCell(Text('—', style: TextStyle(color: Colors.grey))),
                  DataCell(Icon(Icons.check, color: Colors.green, size: 20)),
                ]),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
