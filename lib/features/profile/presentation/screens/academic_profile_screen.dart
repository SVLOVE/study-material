import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AcademicProfileScreen extends ConsumerStatefulWidget {
  const AcademicProfileScreen({super.key});

  @override
  ConsumerState<AcademicProfileScreen> createState() => _AcademicProfileScreenState();
}

class _AcademicProfileScreenState extends ConsumerState<AcademicProfileScreen> {
  final _formKey = GlobalKey<FormState>();

  bool _isLoading = true;
  bool _isSaving = false;
  String? _error;

  // Form Fields
  String? _selectedEducationLevel;
  final _degreeController = TextEditingController();
  final _institutionController = TextEditingController();
  String? _selectedStudyStatus;
  final _graduationYearController = TextEditingController();

  // Original Values (for dirty checking)
  String? _originalEducationLevel;
  String _originalDegree = '';
  String _originalInstitution = '';
  String? _originalStudyStatus;
  String _originalGraduationYear = '';

  final List<String> _educationLevels = [
    'High School / 10th / 12th',
    'Diploma',
    'Undergraduate (Bachelor\'s)',
    'Postgraduate (Master\'s)',
    'Doctorate (PhD)',
  ];

  final List<String> _studyStatuses = [
    'Currently Pursuing',
    'Completed',
    'Planned / Dropped',
  ];

  @override
  void initState() {
    super.initState();
    _loadAcademicProfile();
  }

  @override
  void dispose() {
    _degreeController.dispose();
    _institutionController.dispose();
    _graduationYearController.dispose();
    super.dispose();
  }

  Future<void> _loadAcademicProfile() async {
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

      // We attempt to fetch academic details from profiles table.
      // If the backend doesn't support these columns yet, it will throw an error or return null for those fields.
      // We'll gracefully handle it and fallback to empty values, documenting the missing dependency.
      final response = await Supabase.instance.client
          .from('profiles')
          .select('education_level, degree, institution, study_status, graduation_year')
          .eq('id', user.id)
          .maybeSingle();

      if (response != null) {
        _originalEducationLevel = response['education_level'] as String?;
        _originalDegree = (response['degree'] as String?) ?? '';
        _originalInstitution = (response['institution'] as String?) ?? '';
        _originalStudyStatus = response['study_status'] as String?;
        _originalGraduationYear = (response['graduation_year'] as String?) ?? '';
      }
    } catch (e) {
      // Missing columns will throw here, meaning the backend doesn't support academic fields yet.
      debugPrint('Academic profile columns not found or error occurred: $e');
    } finally {
      // Set initial values
      _selectedEducationLevel = _originalEducationLevel;
      _degreeController.text = _originalDegree;
      _institutionController.text = _originalInstitution;
      _selectedStudyStatus = _originalStudyStatus;
      _graduationYearController.text = _originalGraduationYear;

      if (mounted) setState(() => _isLoading = false);
    }
  }

  bool get _hasChanges {
    return _selectedEducationLevel != _originalEducationLevel ||
        _degreeController.text.trim() != _originalDegree ||
        _institutionController.text.trim() != _originalInstitution ||
        _selectedStudyStatus != _originalStudyStatus ||
        _graduationYearController.text.trim() != _originalGraduationYear;
  }

  Future<bool> _onWillPop() async {
    if (!_hasChanges || _isSaving) return true;

    final shouldPop = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.white,
        title: const Text('Discard changes?', style: TextStyle(color: Color(0xFF0F0F11), fontWeight: FontWeight.bold)),
        content: const Text('You have unsaved academic information. Are you sure you want to leave?', style: TextStyle(color: Color(0xFF0F0F11))),
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
    if (!_formKey.currentState!.validate()) return;
    if (!_hasChanges) return;

    setState(() => _isSaving = true);
    try {
      final user = Supabase.instance.client.auth.currentUser;
      if (user != null) {
        await Supabase.instance.client.from('profiles').update({
          'education_level': _selectedEducationLevel,
          'degree': _degreeController.text.trim(),
          'institution': _institutionController.text.trim(),
          'study_status': _selectedStudyStatus,
          'graduation_year': _graduationYearController.text.trim(),
          'updated_at': DateTime.now().toIso8601String(),
        }).eq('id', user.id);

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Academic profile updated successfully.')),
          );
          
          _originalEducationLevel = _selectedEducationLevel;
          _originalDegree = _degreeController.text.trim();
          _originalInstitution = _institutionController.text.trim();
          _originalStudyStatus = _selectedStudyStatus;
          _originalGraduationYear = _graduationYearController.text.trim();
          
          setState(() {});
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to save changes. Your backend might not support academic profile fields yet.')),
        );
      }
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
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
              const Text('Academic Profile', style: TextStyle(color: Color(0xFF0F0F11), fontSize: 16, fontWeight: FontWeight.bold)),
              Text('Organize your educational background.', style: TextStyle(color: Colors.grey[700], fontSize: 12)),
            ],
          ),
          centerTitle: true,
          actions: [
            if (!_isLoading && _error == null)
              TextButton(
                onPressed: _isSaving || !_hasChanges ? null : _saveChanges,
                child: _isSaving
                    ? const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(strokeWidth: 2, color: Color(0xFF5A31F4)),
                      )
                    : Text(
                        'Save',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: _hasChanges ? const Color(0xFF5A31F4) : Colors.grey,
                        ),
                      ),
              ),
          ],
        ),
        body: SafeArea(
          child: _buildBody(),
        ),
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
              onPressed: _loadAcademicProfile,
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
            constraints: const BoxConstraints(maxWidth: 600),
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Form(
                key: _formKey,
                onChanged: () => setState(() {}),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _buildEligibilityInfo(),
                    const SizedBox(height: 24),
                    _buildFormCard(),
                    const SizedBox(height: 24),
                    _buildExamPreferencesIntegration(),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildEligibilityInfo() {
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
          const Icon(Icons.info_outline, color: Color(0xFF5A31F4)),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Exam Eligibility', style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF0F0F11))),
                const SizedBox(height: 4),
                Text(
                  'Your academic details are used to provide better study recommendations. Educational eligibility criteria differ strictly by official examination notifications. Always verify official notifications for true eligibility.',
                  style: TextStyle(color: Colors.grey[700], fontSize: 13, height: 1.4),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFormCard() {
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
          const Text('Education Details', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF0F0F11))),
          const SizedBox(height: 24),
          
          DropdownButtonFormField<String>(
            value: _selectedEducationLevel,
            decoration: InputDecoration(
              labelText: 'Education Level',
              prefixIcon: const Icon(Icons.school_outlined, color: Colors.grey),
              filled: true,
              fillColor: Colors.white,
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.grey[300]!)),
              enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.grey[300]!)),
              focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFF5A31F4))),
            ),
            items: _educationLevels.map((level) {
              return DropdownMenuItem(value: level, child: Text(level, style: const TextStyle(fontSize: 14)));
            }).toList(),
            onChanged: (val) => setState(() => _selectedEducationLevel = val),
          ),
          const SizedBox(height: 16),
          
          _buildTextField(
            label: 'Degree or Course (Optional)',
            controller: _degreeController,
            icon: Icons.workspace_premium_outlined,
          ),
          const SizedBox(height: 16),
          
          _buildTextField(
            label: 'Institution Name (Optional)',
            controller: _institutionController,
            icon: Icons.account_balance_outlined,
          ),
          const SizedBox(height: 16),
          
          DropdownButtonFormField<String>(
            value: _selectedStudyStatus,
            decoration: InputDecoration(
              labelText: 'Study Status',
              prefixIcon: const Icon(Icons.timeline_outlined, color: Colors.grey),
              filled: true,
              fillColor: Colors.white,
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.grey[300]!)),
              enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.grey[300]!)),
              focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFF5A31F4))),
            ),
            items: _studyStatuses.map((status) {
              return DropdownMenuItem(value: status, child: Text(status, style: const TextStyle(fontSize: 14)));
            }).toList(),
            onChanged: (val) => setState(() => _selectedStudyStatus = val),
          ),
          const SizedBox(height: 16),
          
          _buildTextField(
            label: 'Graduation Year (Optional)',
            controller: _graduationYearController,
            icon: Icons.calendar_today_outlined,
            keyboardType: TextInputType.number,
            validator: (val) {
              if (val != null && val.isNotEmpty) {
                final year = int.tryParse(val);
                if (year == null || year < 1950 || year > 2100) {
                  return 'Please enter a valid year';
                }
              }
              return null;
            },
          ),
        ],
      ),
    );
  }

  Widget _buildTextField({
    required String label,
    required TextEditingController controller,
    required IconData icon,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      validator: validator,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: Colors.grey[600]),
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.grey[300]!)),
        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.grey[300]!)),
        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFF5A31F4))),
        errorBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Colors.red)),
        focusedErrorBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Colors.red)),
      ),
      style: const TextStyle(color: Color(0xFF0F0F11)),
    );
  }

  Widget _buildExamPreferencesIntegration() {
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
          const Text('Exam Preferences', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF0F0F11))),
          const SizedBox(height: 8),
          Text(
            'Keep your target exams updated. We use your academic profile to help filter the best suited exams for you.',
            style: TextStyle(color: Colors.grey[600], fontSize: 13, height: 1.4),
          ),
          const SizedBox(height: 16),
          OutlinedButton.icon(
            onPressed: () {
              // Phase 149 route
              final nav = GoRouter.of(context);
              final scaffold = ScaffoldMessenger.of(context);
              nav.push('/profile/exam-preferences').catchError((e) {
                scaffold.showSnackBar(
                  const SnackBar(content: Text('Exam Preferences route not available yet.')),
                );
                return null;
              });
            },
            icon: const Icon(Icons.assignment_outlined, color: Color(0xFF0F0F11)),
            label: const Text('Manage Exam Preferences', style: TextStyle(color: Color(0xFF0F0F11), fontWeight: FontWeight.bold)),
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              side: const BorderSide(color: Color(0xFFE4DBF6)),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
          ),
        ],
      ),
    );
  }
}
