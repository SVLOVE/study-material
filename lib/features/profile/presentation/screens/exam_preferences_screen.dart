import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../exams/domain/exam_definition.dart';

class ExamPreferencesScreen extends ConsumerStatefulWidget {
  const ExamPreferencesScreen({super.key});

  @override
  ConsumerState<ExamPreferencesScreen> createState() => _ExamPreferencesScreenState();
}

class _ExamPreferencesScreenState extends ConsumerState<ExamPreferencesScreen> {
  bool _isLoading = true;
  bool _isSaving = false;
  String? _error;

  // Selected exams (set of IDs)
  final Set<String> _selectedExams = {};
  Set<String> _originalSelectedExams = {};

  // Preparation State (Location)
  String? _selectedState;
  String? _originalState;

  // UI State
  String _searchQuery = '';
  String? _expandedCategoryId;

  final List<String> _indianStates = [
    'Andhra Pradesh', 'Arunachal Pradesh', 'Assam', 'Bihar', 'Chhattisgarh',
    'Goa', 'Gujarat', 'Haryana', 'Himachal Pradesh', 'Jharkhand', 'Karnataka',
    'Kerala', 'Madhya Pradesh', 'Maharashtra', 'Manipur', 'Meghalaya', 'Mizoram',
    'Nagaland', 'Odisha', 'Punjab', 'Rajasthan', 'Sikkim', 'Tamil Nadu',
    'Telangana', 'Tripura', 'Uttar Pradesh', 'Uttarakhand', 'West Bengal',
    'Delhi', 'Jammu & Kashmir'
  ];

  @override
  void initState() {
    super.initState();
    _loadPreferences();
  }

  Future<void> _loadPreferences() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final user = Supabase.instance.client.auth.currentUser;
      if (user == null) {
        if (mounted) context.go('/login');
        return;
      }

      // Try fetching both a singular 'selected_exam_id' and an array 'preferred_exams' 
      // depending on backend support. Also fetch 'preparation_state'.
      final response = await Supabase.instance.client
          .from('profiles')
          .select('selected_exam_id, preferred_exams, preparation_state')
          .eq('id', user.id)
          .maybeSingle();

      if (response != null) {
        _originalState = response['preparation_state'] as String?;
        _selectedState = _originalState;

        // If backend supports the new 'preferred_exams' array:
        if (response['preferred_exams'] != null) {
          final List<dynamic> exams = response['preferred_exams'];
          _originalSelectedExams = exams.map((e) => e.toString()).toSet();
        } else if (response['selected_exam_id'] != null) {
          // Fallback to legacy single exam selection
          _originalSelectedExams = {response['selected_exam_id'].toString()};
        } else {
          _originalSelectedExams = {};
        }

        _selectedExams.addAll(_originalSelectedExams);
      }
    } catch (e) {
      debugPrint('Failed to load exam preferences. Some columns may not exist: $e');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  bool get _hasChanges {
    if (_selectedState != _originalState) return true;
    if (_selectedExams.length != _originalSelectedExams.length) return true;
    return !_selectedExams.containsAll(_originalSelectedExams);
  }

  Future<bool> _onWillPop() async {
    if (!_hasChanges || _isSaving) return true;

    final shouldPop = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.white,
        title: const Text('Discard changes?', style: TextStyle(color: Color(0xFF0F0F11), fontWeight: FontWeight.bold)),
        content: const Text('You have unsaved exam preferences. Are you sure you want to leave?', style: TextStyle(color: Color(0xFF0F0F11))),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Stay', style: TextStyle(color: Color(0xFF5A31F4))),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Discard', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    return shouldPop ?? false;
  }

  Future<void> _saveChanges() async {
    if (!_hasChanges) return;

    setState(() => _isSaving = true);
    try {
      final user = Supabase.instance.client.auth.currentUser;
      if (user != null) {
        // Prepare the payload. 
        // We set 'selected_exam_id' to the first item for legacy support, 
        // and 'preferred_exams' array for new multi-select support if backend handles it.
        final payload = <String, dynamic>{
          'preparation_state': _selectedState,
          'updated_at': DateTime.now().toIso8601String(),
        };

        if (_selectedExams.isNotEmpty) {
          payload['selected_exam_id'] = _selectedExams.first;
          payload['preferred_exams'] = _selectedExams.toList();
        } else {
          payload['selected_exam_id'] = null;
          payload['preferred_exams'] = [];
        }

        await Supabase.instance.client
            .from('profiles')
            .update(payload)
            .eq('id', user.id);

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Exam preferences updated successfully.')),
          );
          
          _originalState = _selectedState;
          _originalSelectedExams = Set.from(_selectedExams);
          setState(() {});
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Failed to save. Your backend schema might not support "preferred_exams" or "preparation_state" columns yet.'),
            duration: Duration(seconds: 4),
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  void _toggleExamSelection(String examId) {
    setState(() {
      if (_selectedExams.contains(examId)) {
        _selectedExams.remove(examId);
      } else {
        _selectedExams.add(examId);
      }
    });
  }

  void _removeExam(String examId) {
    setState(() {
      _selectedExams.remove(examId);
    });
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) async {
        if (didPop) return;
        if (await _onWillPop()) {
          if (context.mounted) context.pop();
        }
      },
      child: Scaffold(
        backgroundColor: const Color(0xFFEAE4F7),
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Color(0xFF0F0F11)),
            onPressed: () async {
              if (await _onWillPop()) {
                if (context.mounted) context.pop();
              }
            },
          ),
          title: Column(
            children: [
              const Text('Exam Preferences', style: TextStyle(color: Color(0xFF0F0F11), fontSize: 16, fontWeight: FontWeight.bold)),
              Text('Choose the exams you are preparing for.', style: TextStyle(color: Colors.grey[700], fontSize: 12)),
            ],
          ),
          centerTitle: true,
        ),
        body: SafeArea(
          child: _buildBody(),
        ),
        bottomNavigationBar: _hasChanges ? _buildStickyActions() : null,
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
            Text(_error!, style: const TextStyle(fontSize: 16, color: Color(0xFF0F0F11))),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: _loadPreferences,
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
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24).copyWith(bottom: 120),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _buildGuidanceCard(),
                  const SizedBox(height: 24),
                  _buildPreparationState(),
                  const SizedBox(height: 24),
                  _buildSelectedExamsSummary(),
                  const SizedBox(height: 32),
                  _buildSearchField(),
                  const SizedBox(height: 24),
                  _buildExamCatalog(constraints.maxWidth),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildGuidanceCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFFF9F8FD),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE4DBF6)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.auto_awesome, color: Color(0xFF5A31F4)),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Personalize Your Journey', style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF0F0F11))),
                const SizedBox(height: 4),
                Text(
                  'Selecting relevant exams allows GovPrep AI to personalize question practice, mock tests, syllabus views, and study materials specifically for your targets.',
                  style: TextStyle(color: Colors.grey[700], fontSize: 13, height: 1.4),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPreparationState() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: const Color(0xFFF3F4F6)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Preparation Region', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF0F0F11))),
          const SizedBox(height: 8),
          Text('Select your primary state to prioritize regional notifications.', style: TextStyle(color: Colors.grey[600], fontSize: 13)),
          const SizedBox(height: 16),
          DropdownButtonFormField<String>(
            value: _selectedState,
            decoration: InputDecoration(
              prefixIcon: const Icon(Icons.map_outlined, color: Colors.grey),
              filled: true,
              fillColor: Colors.white,
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.grey[300]!)),
              enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.grey[300]!)),
              focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFF5A31F4))),
              hintText: 'Select a state (Optional)',
            ),
            items: _indianStates.map((state) {
              return DropdownMenuItem(value: state, child: Text(state));
            }).toList(),
            onChanged: (val) => setState(() => _selectedState = val),
          ),
        ],
      ),
    );
  }

  Widget _buildSelectedExamsSummary() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: const Color(0xFFF3F4F6)),
        boxShadow: [BoxShadow(color: const Color(0xFF0F0F11).withValues(alpha: 0.02), blurRadius: 10, offset: const Offset(0, 4))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Selected Exams (${_selectedExams.length})',
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF0F0F11)),
              ),
              if (_selectedExams.isNotEmpty)
                TextButton(
                  onPressed: () => setState(() => _selectedExams.clear()),
                  child: const Text('Clear All', style: TextStyle(color: Colors.red)),
                )
            ],
          ),
          const SizedBox(height: 16),
          if (_selectedExams.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 16.0),
              child: Text(
                'No exams selected. Please search or select from the categories below.',
                style: TextStyle(color: Colors.grey[500], fontStyle: FontStyle.italic),
              ),
            )
          else
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: _selectedExams.map((examId) {
                final examDef = staticExams.firstWhere(
                  (e) => e.id == examId, 
                  orElse: () => ExamDefinition(id: examId, categoryId: '', name: 'Unknown Exam', description: '', subjects: [])
                );
                return Chip(
                  label: Text(examDef.name, style: const TextStyle(fontWeight: FontWeight.w600, color: Color(0xFF5A31F4))),
                  backgroundColor: const Color(0xFFE4DBF6).withValues(alpha: 0.5),
                  deleteIcon: const Icon(Icons.close, size: 16, color: Color(0xFF5A31F4)),
                  onDeleted: () => _removeExam(examId),
                  side: BorderSide.none,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                );
              }).toList(),
            ),
        ],
      ),
    );
  }

  Widget _buildSearchField() {
    return TextField(
      onChanged: (val) => setState(() => _searchQuery = val),
      decoration: InputDecoration(
        hintText: 'Search exams or categories...',
        prefixIcon: const Icon(Icons.search, color: Colors.grey),
        suffixIcon: _searchQuery.isNotEmpty 
          ? IconButton(icon: const Icon(Icons.clear, color: Colors.grey), onPressed: () => setState(() => _searchQuery = ''))
          : null,
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
      ),
    );
  }

  Widget _buildExamCatalog(double maxWidth) {
    // Filter categories based on search
    final query = _searchQuery.toLowerCase();
    
    final matchingExams = staticExams.where((exam) {
      return exam.name.toLowerCase().contains(query) || 
             exam.description.toLowerCase().contains(query);
    }).toList();

    final matchingCategories = staticCategories.where((cat) {
      if (cat.name.toLowerCase().contains(query)) return true;
      return matchingExams.any((e) => e.categoryId == cat.id);
    }).toList();

    if (matchingCategories.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32.0),
          child: Column(
            children: [
              Icon(Icons.search_off, size: 48, color: Colors.grey[400]),
              const SizedBox(height: 16),
              Text('No exams or categories found for "$_searchQuery".', style: TextStyle(color: Colors.grey[600])),
            ],
          ),
        ),
      );
    }

    // Determine grid columns
    int crossAxisCount = 1;
    if (maxWidth > 900) {
      crossAxisCount = 3;
    } else if (maxWidth > 600) {
      crossAxisCount = 2;
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: matchingCategories.map((category) {
        final categoryExams = query.isEmpty 
            ? staticExams.where((e) => e.categoryId == category.id).toList()
            : matchingExams.where((e) => e.categoryId == category.id).toList();

        if (categoryExams.isEmpty && query.isNotEmpty) {
           // If a category matches search but has no matching exams
           // (e.g. searching for "TNPSC" matches category but not specific exam names unless included).
           // We will list all exams for that category.
           categoryExams.addAll(staticExams.where((e) => e.categoryId == category.id));
        }

        final isExpanded = _expandedCategoryId == category.id || _searchQuery.isNotEmpty;

        return Card(
          margin: const EdgeInsets.only(bottom: 16),
          color: Colors.white,
          elevation: 0,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16), side: BorderSide(color: Colors.grey[300]!)),
          child: Theme(
            data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
            child: ExpansionTile(
              initiallyExpanded: isExpanded,
              onExpansionChanged: (expanded) {
                if (expanded) {
                  setState(() => _expandedCategoryId = category.id);
                }
              },
              title: Text(category.name, style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF0F0F11))),
              subtitle: Text('${categoryExams.length} available exams', style: TextStyle(fontSize: 12, color: Colors.grey[600])),
              leading: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: const Color(0xFFF9F8FD),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(_getCategoryIcon(category.id), color: const Color(0xFF5A31F4)),
              ),
              children: [
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: crossAxisCount,
                      mainAxisSpacing: 12,
                      crossAxisSpacing: 12,
                      childAspectRatio: 2.5,
                    ),
                    itemCount: categoryExams.length,
                    itemBuilder: (context, index) {
                      final exam = categoryExams[index];
                      final isSelected = _selectedExams.contains(exam.id);
                      
                      return InkWell(
                        onTap: () => _toggleExamSelection(exam.id),
                        borderRadius: BorderRadius.circular(12),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                          decoration: BoxDecoration(
                            color: isSelected ? const Color(0xFFE4DBF6).withValues(alpha: 0.3) : Colors.white,
                            border: Border.all(color: isSelected ? const Color(0xFF5A31F4) : Colors.grey[300]!),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Row(
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text(
                                      exam.name,
                                      style: TextStyle(fontWeight: FontWeight.bold, color: isSelected ? const Color(0xFF5A31F4) : const Color(0xFF0F0F11)),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      exam.description,
                                      style: TextStyle(fontSize: 11, color: Colors.grey[600]),
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(width: 8),
                              Icon(
                                isSelected ? Icons.check_circle : Icons.circle_outlined,
                                color: isSelected ? const Color(0xFF5A31F4) : Colors.grey[400],
                                size: 24,
                              )
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                )
              ],
            ),
          ),
        );
      }).toList(),
    );
  }

  IconData _getCategoryIcon(String categoryId) {
    switch (categoryId) {
      case 'tnpsc': return Icons.account_balance;
      case 'ssc': return Icons.engineering;
      case 'rrb': return Icons.train;
      case 'banking': return Icons.monetization_on;
      case 'upsc': return Icons.policy;
      case 'defence': return Icons.security;
      case 'teaching': return Icons.school;
      case 'police': return Icons.local_police;
      default: return Icons.assignment;
    }
  }

  Widget _buildStickyActions() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), offset: const Offset(0, -4), blurRadius: 10)],
      ),
      child: SafeArea(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            TextButton(
              onPressed: _isSaving ? null : () {
                setState(() {
                  _selectedExams.clear();
                  _selectedExams.addAll(_originalSelectedExams);
                  _selectedState = _originalState;
                });
              },
              child: const Text('Discard', style: TextStyle(color: Colors.grey, fontWeight: FontWeight.bold)),
            ),
            const SizedBox(width: 16),
            ElevatedButton(
              onPressed: _isSaving ? null : _saveChanges,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF5A31F4),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              child: _isSaving
                  ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                  : const Text('Save Preferences', style: TextStyle(fontWeight: FontWeight.bold)),
            ),
          ],
        ),
      ),
    );
  }
}
