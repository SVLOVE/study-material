import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'plans_screen.dart' show Plan; // Assuming we can reuse the Plan class from PlansScreen

// Extend the Plan model slightly for comparison purposes in this screen
class PlanComparisonData {
  final Plan plan;
  final Map<String, dynamic> featureValues;

  PlanComparisonData({required this.plan, required this.featureValues});
}

class PlanComparisonScreen extends StatefulWidget {
  const PlanComparisonScreen({super.key});

  @override
  State<PlanComparisonScreen> createState() => _PlanComparisonScreenState();
}

class _PlanComparisonScreenState extends State<PlanComparisonScreen> {
  bool _isLoading = true;
  String _billingPeriod = 'Monthly'; // 'Monthly' or 'Yearly'
  String _currentPlanId = 'free'; 
  bool _showDifferencesOnly = false;
  
  // Mobile only
  String _selectedMobilePlanId = 'pro';
  
  List<PlanComparisonData> _planData = [];
  
  final List<String> _featureCategories = [
    'Practice and Learning',
    'Mock Tests',
    'Progress and Personalization',
    'Usage and Access'
  ];
  
  final Map<String, List<String>> _featuresByCategory = {
    'Practice and Learning': [
      'Practice questions',
      'Topic-wise practice',
      'Previous-year papers',
      'Bookmarks',
    ],
    'Mock Tests': [
      'Full-length mock tests',
      'Sectional tests',
      'Performance reports',
    ],
    'Progress and Personalization': [
      'Study progress tracking',
      'Weak-topic analysis',
      'Personalized recommendations',
    ],
    'Usage and Access': [
      'Daily question limit',
      'Exam categories supported',
      'Premium study resources',
    ],
  };

  @override
  void initState() {
    super.initState();
    _fetchComparisonData();
  }

  Future<void> _fetchComparisonData() async {
    setState(() => _isLoading = true);
    try {
      await Future.delayed(const Duration(milliseconds: 700));
      
      final freePlan = Plan(
        id: 'free',
        name: 'Free',
        description: 'Start preparing at no cost.',
        features: [],
        isFree: true,
      );
      
      final basicPlan = Plan(
        id: 'basic',
        name: 'Basic',
        description: 'More practice for consistent preparation.',
        priceMonthly: '₹299',
        priceYearly: '₹2,999',
        features: [],
      );
      
      final proPlan = Plan(
        id: 'pro',
        name: 'Pro',
        description: 'Complete preparation for serious exam goals.',
        priceMonthly: '₹599',
        priceYearly: '₹5,999',
        isRecommended: true,
        features: [],
      );
      
      _planData = [
        PlanComparisonData(
          plan: freePlan,
          featureValues: {
            'Practice questions': 'Limited',
            'Topic-wise practice': true,
            'Previous-year papers': false,
            'Bookmarks': false,
            'Full-length mock tests': '2 per month',
            'Sectional tests': false,
            'Performance reports': 'Basic',
            'Study progress tracking': true,
            'Weak-topic analysis': false,
            'Personalized recommendations': false,
            'Daily question limit': '50 questions',
            'Exam categories supported': '1 Category',
            'Premium study resources': false,
          },
        ),
        PlanComparisonData(
          plan: basicPlan,
          featureValues: {
            'Practice questions': 'Unlimited',
            'Topic-wise practice': true,
            'Previous-year papers': true,
            'Bookmarks': true,
            'Full-length mock tests': '10 per month',
            'Sectional tests': true,
            'Performance reports': 'Detailed',
            'Study progress tracking': true,
            'Weak-topic analysis': true,
            'Personalized recommendations': false,
            'Daily question limit': 'Unlimited',
            'Exam categories supported': 'All Categories',
            'Premium study resources': false,
          },
        ),
        PlanComparisonData(
          plan: proPlan,
          featureValues: {
            'Practice questions': 'Unlimited',
            'Topic-wise practice': true,
            'Previous-year papers': true,
            'Bookmarks': true,
            'Full-length mock tests': 'Unlimited',
            'Sectional tests': true,
            'Performance reports': 'Advanced',
            'Study progress tracking': true,
            'Weak-topic analysis': true,
            'Personalized recommendations': true,
            'Daily question limit': 'Unlimited',
            'Exam categories supported': 'All Categories',
            'Premium study resources': true,
          },
        ),
      ];
      
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  bool _doesFeatureDiffer(String feature) {
    if (_planData.isEmpty) return false;
    final firstValue = _planData[0].featureValues[feature];
    for (int i = 1; i < _planData.length; i++) {
      if (_planData[i].featureValues[feature] != firstValue) {
        return true;
      }
    }
    return false;
  }

  void _handleSelectPlan(Plan plan) {
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
          onPressed: () {
            if (context.canPop()) {
              context.pop();
            } else {
              context.go('/plans');
            }
          },
        ),
        title: const Text('Compare Plans', style: TextStyle(color: Color(0xFF0F0F11), fontSize: 18, fontWeight: FontWeight.bold)),
        centerTitle: true,
      ),
      body: SafeArea(
        child: _isLoading ? const Center(child: CircularProgressIndicator(color: Color(0xFF0F0F11))) : _buildContent(),
      ),
    );
  }

  Widget _buildContent() {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isMobile = constraints.maxWidth < 768;
        
        return SingleChildScrollView(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                child: Column(
                  children: [
                    Text(
                      'Find the right study plan',
                      style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: const Color(0xFF0F0F11)),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Compare features and choose the right plan for your preparation.',
                      style: TextStyle(fontSize: 14, color: Colors.grey[700]),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 24),
                    _buildBillingToggle(),
                    const SizedBox(height: 24),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Switch(
                          value: _showDifferencesOnly,
                          onChanged: (val) => setState(() => _showDifferencesOnly = val),
                          activeColor: const Color(0xFF5A31F4),
                        ),
                        const SizedBox(width: 8),
                        Text('Show differences only', style: TextStyle(color: const Color(0xFF0F0F11), fontWeight: FontWeight.w500)),
                      ],
                    ),
                  ],
                ),
              ),
              
              if (isMobile) _buildMobileComparison() else _buildDesktopComparison(),
              const SizedBox(height: 64),
            ],
          ),
        );
      },
    );
  }

  Widget _buildBillingToggle() {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: const Color(0xFFFFFFFF),
        borderRadius: BorderRadius.circular(30),
        border: Border.all(color: const Color(0xFFF3F4F6)),
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
          color: isSelected ? const Color(0xFFE4DBF6) : Colors.transparent,
          borderRadius: BorderRadius.circular(26),
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

  Widget _buildDesktopComparison() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: const Color(0xFFF3F4F6)),
      ),
      child: Column(
        children: [
          // Table Header
          Padding(
            padding: const EdgeInsets.all(24),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                const Expanded(flex: 2, child: SizedBox()), // Empty space for feature column
                ..._planData.map((data) => Expanded(
                  flex: 1, 
                  child: _buildPlanColumnHeader(data.plan),
                )),
              ],
            ),
          ),
          const Divider(height: 1, color: Color(0xFFF3F4F6)),
          
          // Table Body
          ..._featureCategories.expand((category) {
            final categoryFeatures = _featuresByCategory[category]!;
            final featuresToShow = _showDifferencesOnly 
                ? categoryFeatures.where((f) => _doesFeatureDiffer(f)).toList()
                : categoryFeatures;
                
            if (featuresToShow.isEmpty) return <Widget>[];
            
            return [
              // Category Header
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                color: const Color(0xFFF3F4F6).withValues(alpha: 0.5),
                child: Text(category, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Color(0xFF0F0F11))),
              ),
              
              // Feature Rows
              ...featuresToShow.map((feature) {
                return Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
                      child: Row(
                        children: [
                          Expanded(
                            flex: 2,
                            child: Text(feature, style: const TextStyle(color: Color(0xFF0F0F11), fontWeight: FontWeight.w500)),
                          ),
                          ..._planData.map((data) => Expanded(
                            flex: 1,
                            child: Center(
                              child: _buildFeatureValue(data.featureValues[feature]),
                            ),
                          )),
                        ],
                      ),
                    ),
                    const Divider(height: 1, color: Color(0xFFF3F4F6)),
                  ],
                );
              }),
            ];
          }),
        ],
      ),
    );
  }

  Widget _buildMobileComparison() {
    return Column(
      children: [
        // Mobile Plan Selector
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Row(
            children: _planData.map((data) {
              final isSelected = data.plan.id == _selectedMobilePlanId;
              return Padding(
                padding: const EdgeInsets.only(right: 12),
                child: ChoiceChip(
                  label: Text(data.plan.name),
                  selected: isSelected,
                  onSelected: (selected) {
                    if (selected) setState(() => _selectedMobilePlanId = data.plan.id);
                  },
                  selectedColor: const Color(0xFF0F0F11),
                  labelStyle: TextStyle(
                    color: isSelected ? Colors.white : const Color(0xFF0F0F11),
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                  ),
                  backgroundColor: Colors.white,
                  side: BorderSide(color: isSelected ? Colors.transparent : const Color(0xFFF3F4F6)),
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                ),
              );
            }).toList(),
          ),
        ),
        
        const SizedBox(height: 24),
        
        // Selected Plan Details
        Builder(builder: (context) {
          final selectedData = _planData.firstWhere((p) => p.plan.id == _selectedMobilePlanId);
          return Container(
            margin: const EdgeInsets.symmetric(horizontal: 24),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: selectedData.plan.isRecommended ? const Color(0xFFE4DBF6) : const Color(0xFFF3F4F6), width: selectedData.plan.isRecommended ? 2 : 1),
            ),
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(24),
                  child: _buildPlanColumnHeader(selectedData.plan, isMobile: true),
                ),
                const Divider(height: 1, color: Color(0xFFF3F4F6)),
                
                ..._featureCategories.expand((category) {
                  final categoryFeatures = _featuresByCategory[category]!;
                  final featuresToShow = _showDifferencesOnly 
                      ? categoryFeatures.where((f) => _doesFeatureDiffer(f)).toList()
                      : categoryFeatures;
                      
                  if (featuresToShow.isEmpty) return <Widget>[];
                  
                  return [
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                      color: const Color(0xFFF3F4F6).withValues(alpha: 0.5),
                      child: Text(category, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Color(0xFF0F0F11))),
                    ),
                    ...featuresToShow.map((feature) {
                      return Column(
                        children: [
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Expanded(child: Text(feature, style: const TextStyle(color: Color(0xFF0F0F11), fontSize: 14))),
                                const SizedBox(width: 16),
                                _buildFeatureValue(selectedData.featureValues[feature]),
                              ],
                            ),
                          ),
                          const Divider(height: 1, color: Color(0xFFF3F4F6)),
                        ],
                      );
                    }),
                  ];
                }),
              ],
            ),
          );
        }),
      ],
    );
  }

  Widget _buildPlanColumnHeader(Plan plan, {bool isMobile = false}) {
    final isCurrent = plan.id == _currentPlanId;
    
    return Column(
      crossAxisAlignment: isMobile ? CrossAxisAlignment.start : CrossAxisAlignment.center,
      children: [
        if (plan.isRecommended)
          Container(
            margin: const EdgeInsets.only(bottom: 12),
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(color: const Color(0xFFE4DBF6), borderRadius: BorderRadius.circular(6)),
            child: const Text('RECOMMENDED', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Color(0xFF0F0F11))),
          )
        else if (isMobile)
          const SizedBox(height: 24),
          
        Text(plan.name, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFF0F0F11))),
        const SizedBox(height: 8),
        
        if (plan.isFree)
          const Text('₹0', style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Color(0xFF0F0F11)))
        else
          Row(
            mainAxisAlignment: isMobile ? MainAxisAlignment.start : MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(_billingPeriod == 'Monthly' ? plan.priceMonthly! : plan.priceYearly!, style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Color(0xFF0F0F11))),
              Padding(
                padding: const EdgeInsets.only(bottom: 4, left: 4),
                child: Text(_billingPeriod == 'Monthly' ? '/ mo' : '/ yr', style: TextStyle(fontSize: 12, color: const Color(0xFF0F0F11).withValues(alpha: 0.6))),
              ),
            ],
          ),
          
        const SizedBox(height: 24),
        
        if (isCurrent)
          SizedBox(
            width: isMobile ? double.infinity : null,
            child: OutlinedButton(
              onPressed: null,
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 24), 
                disabledForegroundColor: const Color(0xFF0F0F11).withValues(alpha: 0.5), 
                side: const BorderSide(color: Color(0xFFF3F4F6)),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              child: const Text('Current Plan', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
            ),
          )
        else
          SizedBox(
            width: isMobile ? double.infinity : null,
            child: ElevatedButton(
              onPressed: () => _handleSelectPlan(plan),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 24),
                backgroundColor: plan.isRecommended ? const Color(0xFF5A31F4) : const Color(0xFF0F0F11),
                foregroundColor: Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              child: const Text('Select', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
            ),
          ),
      ],
    );
  }

  Widget _buildFeatureValue(dynamic value) {
    if (value is bool) {
      if (value) {
        return const Icon(Icons.check_circle, color: Color(0xFFE2F0D9), size: 24);
      } else {
        return const Icon(Icons.remove, color: Colors.grey, size: 24);
      }
    } else if (value is String) {
      return Text(value, style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF0F0F11), fontSize: 13), textAlign: TextAlign.center);
    }
    return const SizedBox();
  }
}
