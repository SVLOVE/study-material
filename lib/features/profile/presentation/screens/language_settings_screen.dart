import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class LanguageSettingsScreen extends ConsumerStatefulWidget {
  const LanguageSettingsScreen({super.key});

  @override
  ConsumerState<LanguageSettingsScreen> createState() => _LanguageSettingsScreenState();
}

class _LanguageSettingsScreenState extends ConsumerState<LanguageSettingsScreen> {
  bool _isLoading = true;
  bool _isSaving = false;

  String _currentLanguage = 'English'; // Default
  String _selectedLanguage = 'English'; // Selection

  // Preview translations mapped by language key
  final Map<String, Map<String, String>> _previews = {
    'English': {
      'home': 'Home',
      'my_exams': 'My Exams',
      'practice': 'Practice',
      'mock_tests': 'Mock Tests',
      'study_materials': 'Study Materials',
      'profile': 'Profile',
      'description': 'Use the application in English.',
    },
    'Tamil': {
      'home': 'முகப்பு',
      'my_exams': 'எனது தேர்வுகள்',
      'practice': 'பயிற்சி',
      'mock_tests': 'மாதிரி தேர்வுகள்',
      'study_materials': 'படிப்பிற்கான பொருட்கள்',
      'profile': 'சுயவிவரம்',
      'description': 'பயன்பாட்டை தமிழில் பயன்படுத்தவும்.',
    }
  };

  @override
  void initState() {
    super.initState();
    _loadLanguagePreference();
  }

  Future<void> _loadLanguagePreference() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final user = Supabase.instance.client.auth.currentUser;
      if (user == null) {
        if (mounted) context.go('/login');
        return;
      }

      final response = await Supabase.instance.client
          .from('profiles')
          .select('language_preference')
          .eq('id', user.id)
          .maybeSingle();

      if (response != null) {
        String lang = response['language_preference'] as String? ?? 'English';
        // Normalize 'en'/'ta' if they exist from older setups
        if (lang == 'en') lang = 'English';
        if (lang == 'ta') lang = 'Tamil';
        
        setState(() {
          _currentLanguage = lang;
          _selectedLanguage = lang;
        });
      }
    } catch (e) {
      debugPrint('Failed to load language preference: $e');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _saveLanguage() async {
    if (_currentLanguage == _selectedLanguage) return;

    setState(() => _isSaving = true);
    try {
      final user = Supabase.instance.client.auth.currentUser;
      if (user != null) {
        await Supabase.instance.client
            .from('profiles')
            .update({
              'language_preference': _selectedLanguage,
              'updated_at': DateTime.now().toIso8601String(),
            })
            .eq('id', user.id);

        if (mounted) {
          setState(() {
            _currentLanguage = _selectedLanguage;
          });
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Language preference updated successfully.')),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to save language: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  bool get _hasChanges => _currentLanguage != _selectedLanguage;

  Future<bool> _onWillPop() async {
    if (!_hasChanges || _isSaving) return true;

    final shouldPop = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.white,
        title: const Text('Discard changes?', style: TextStyle(color: Color(0xFF0F0F11), fontWeight: FontWeight.bold)),
        content: const Text('You have unsaved language changes. Are you sure you want to leave?', style: TextStyle(color: Color(0xFF0F0F11))),
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
              const Text('Language Settings', style: TextStyle(color: Color(0xFF0F0F11), fontSize: 16, fontWeight: FontWeight.bold)),
              Text('Choose the language you\'re most comfortable learning in.', style: TextStyle(color: Colors.grey[700], fontSize: 12)),
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

    return LayoutBuilder(
      builder: (context, constraints) {
        final isDesktop = constraints.maxWidth > 800;
        return Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 900),
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24).copyWith(bottom: 120),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _buildCurrentLanguageCard(),
                  const SizedBox(height: 32),
                  
                  if (isDesktop)
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(child: _buildLanguageSelectionList()),
                        const SizedBox(width: 24),
                        Expanded(child: _buildLanguagePreviewPanel()),
                      ],
                    )
                  else
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        _buildLanguageSelectionList(),
                        const SizedBox(height: 32),
                        _buildLanguagePreviewPanel(),
                      ],
                    ),
                  
                  const SizedBox(height: 32),
                  _buildInfoCard(),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildCurrentLanguageCard() {
    final preview = _previews[_currentLanguage] ?? _previews['English']!;
    final isTamil = _currentLanguage == 'Tamil';

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: const Color(0xFFE4DBF6), width: 2),
        boxShadow: [BoxShadow(color: const Color(0xFF0F0F11).withValues(alpha: 0.03), blurRadius: 10, offset: const Offset(0, 4))],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFFF9F8FD),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Text(
              isTamil ? 'அ' : 'A',
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Color(0xFF5A31F4)),
            ),
          ),
          const SizedBox(width: 20),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Current Application Language', style: TextStyle(fontSize: 13, color: Colors.grey, fontWeight: FontWeight.w600)),
                const SizedBox(height: 4),
                Text(
                  isTamil ? 'தமிழ்' : 'English',
                  style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFF0F0F11)),
                ),
                const SizedBox(height: 4),
                Text(
                  preview['description']!,
                  style: TextStyle(fontSize: 13, color: Colors.grey[700]),
                ),
              ],
            ),
          ),
          const Icon(Icons.check_circle, color: Colors.green, size: 28),
        ],
      ),
    );
  }

  Widget _buildLanguageSelectionList() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Available Languages', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF0F0F11))),
        const SizedBox(height: 16),
        _buildLanguageOptionCard(
          languageKey: 'English',
          nativeName: 'English',
          languageCode: 'en',
          description: _previews['English']!['description']!,
        ),
        const SizedBox(height: 16),
        _buildLanguageOptionCard(
          languageKey: 'Tamil',
          nativeName: 'தமிழ்',
          languageCode: 'ta',
          description: _previews['Tamil']!['description']!,
        ),
      ],
    );
  }

  Widget _buildLanguageOptionCard({
    required String languageKey,
    required String nativeName,
    required String languageCode,
    required String description,
  }) {
    final isSelected = _selectedLanguage == languageKey;

    return InkWell(
      onTap: () {
        setState(() {
          _selectedLanguage = languageKey;
        });
      },
      borderRadius: BorderRadius.circular(16),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFFF9F8FD) : Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? const Color(0xFF5A31F4) : const Color(0xFFF3F4F6),
            width: isSelected ? 2 : 1,
          ),
          boxShadow: isSelected
              ? [BoxShadow(color: const Color(0xFF5A31F4).withValues(alpha: 0.1), blurRadius: 8, offset: const Offset(0, 4))]
              : [],
        ),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: isSelected ? const Color(0xFF5A31F4) : const Color(0xFFF3F4F6),
                shape: BoxShape.circle,
              ),
              alignment: Alignment.center,
              child: Text(
                languageCode.toUpperCase(),
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: isSelected ? Colors.white : Colors.grey[600],
                ),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    nativeName,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: isSelected ? const Color(0xFF5A31F4) : const Color(0xFF0F0F11),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    description,
                    style: TextStyle(fontSize: 13, color: Colors.grey[600]),
                  ),
                ],
              ),
            ),
            Icon(
              isSelected ? Icons.radio_button_checked : Icons.radio_button_unchecked,
              color: isSelected ? const Color(0xFF5A31F4) : Colors.grey[400],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLanguagePreviewPanel() {
    final preview = _previews[_selectedLanguage] ?? _previews['English']!;
    
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: const Color(0xFFF3F4F6)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            decoration: const BoxDecoration(
              border: Border(bottom: BorderSide(color: Color(0xFFF3F4F6))),
            ),
            child: Row(
              children: [
                const Icon(Icons.visibility_outlined, size: 20, color: Color(0xFF5A31F4)),
                const SizedBox(width: 12),
                Text('Language Preview', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.grey[800])),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                _buildPreviewItem(Icons.home_outlined, preview['home']!),
                const SizedBox(height: 12),
                _buildPreviewItem(Icons.assignment_outlined, preview['my_exams']!),
                const SizedBox(height: 12),
                _buildPreviewItem(Icons.psychology_outlined, preview['practice']!),
                const SizedBox(height: 12),
                _buildPreviewItem(Icons.timer_outlined, preview['mock_tests']!),
                const SizedBox(height: 12),
                _buildPreviewItem(Icons.menu_book_outlined, preview['study_materials']!),
                const SizedBox(height: 12),
                _buildPreviewItem(Icons.person_outline, preview['profile']!),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPreviewItem(IconData icon, String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: const Color(0xFFF9F8FD),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(icon, size: 20, color: Colors.grey[700]),
          const SizedBox(width: 16),
          Text(label, style: const TextStyle(fontWeight: FontWeight.w500, color: Color(0xFF0F0F11))),
        ],
      ),
    );
  }

  Widget _buildInfoCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFFFDF0D5).withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFFDF0D5)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.info_outline, color: Color(0xFFB8860B)),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('About Language Settings', style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF0F0F11))),
                const SizedBox(height: 8),
                Text(
                  '• The selected language controls translated application interface text.\n'
                  '• Exam names, official documents, and specific question content may remain in their original language when translations are unavailable.\n'
                  '• Changing your language does not affect your study progress, saved exams, or account data.',
                  style: TextStyle(color: Colors.grey[800], fontSize: 13, height: 1.5),
                ),
              ],
            ),
          ),
        ],
      ),
    );
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
                setState(() => _selectedLanguage = _currentLanguage);
              },
              child: const Text('Discard', style: TextStyle(color: Colors.grey, fontWeight: FontWeight.bold)),
            ),
            const SizedBox(width: 16),
            ElevatedButton(
              onPressed: _isSaving ? null : _saveLanguage,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF5A31F4),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              child: _isSaving
                  ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                  : const Text('Save Language', style: TextStyle(fontWeight: FontWeight.bold)),
            ),
          ],
        ),
      ),
    );
  }
}
