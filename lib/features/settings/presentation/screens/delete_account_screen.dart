import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class DeleteAccountScreen extends ConsumerStatefulWidget {
  const DeleteAccountScreen({super.key});

  @override
  ConsumerState<DeleteAccountScreen> createState() => _DeleteAccountScreenState();
}

class _DeleteAccountScreenState extends ConsumerState<DeleteAccountScreen> {
  bool _isDeleting = false;

  void _showDeleteConfirmationDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext dialogContext) {
        return StatefulBuilder(
          builder: (context, setStateDialog) {
            return AlertDialog(
              backgroundColor: Theme.of(context).brightness == Brightness.dark 
                  ? const Color(0xFF1E1E1E) 
                  : Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              title: Row(
                children: [
                  const Icon(Icons.warning_amber_rounded, color: Colors.red),
                  const SizedBox(width: 12),
                  Text('Confirm Deletion', style: TextStyle(
                    color: Theme.of(context).brightness == Brightness.dark ? Colors.white : const Color(0xFF0F0F11),
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  )),
                ],
              ),
              content: const Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('This action is irreversible and will permanently delete your profile, study progress, and associated data.'),
                  SizedBox(height: 16),
                  Text('Are you absolutely sure you want to delete your account?'),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: _isDeleting ? null : () => Navigator.of(dialogContext).pop(),
                  style: TextButton.styleFrom(
                    foregroundColor: Theme.of(context).brightness == Brightness.dark ? Colors.grey[400] : Colors.grey[600],
                  ),
                  child: const Text('Cancel'),
                ),
                ElevatedButton(
                  onPressed: _isDeleting ? null : () async {
                    setStateDialog(() => _isDeleting = true);
                    
                    // Artificial delay to simulate processing before hitting the known limitation
                    await Future.delayed(const Duration(seconds: 1));
                    
                    if (context.mounted) {
                      setStateDialog(() => _isDeleting = false);
                      Navigator.of(dialogContext).pop();
                      _showBackendLimitationError();
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                  child: _isDeleting 
                      ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                      : const Text('Delete my account permanently'),
                ),
              ],
            );
          }
        );
      },
    );
  }

  void _showBackendLimitationError() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        final isDark = Theme.of(context).brightness == Brightness.dark;
        return AlertDialog(
          backgroundColor: isDark ? const Color(0xFF1E1E1E) : Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: Row(
            children: [
              Icon(Icons.error_outline, color: isDark ? Colors.orange[400] : Colors.orange[700]),
              const SizedBox(width: 12),
              const Text('Deletion Unavailable'),
            ],
          ),
          content: const Text(
            'Account deletion requires a secure server-side function (e.g., Supabase Edge Function or RPC) that is not currently configured in the backend environment. Client-side deletion using service-role keys is strictly prohibited for security reasons.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Understood'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF121212) : const Color(0xFFEAE4F7),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: isDark ? Colors.white : const Color(0xFF0F0F11)),
          onPressed: () => context.pop(),
        ),
        title: Column(
          children: [
            Text('Delete Account', style: TextStyle(color: isDark ? Colors.white : const Color(0xFF0F0F11), fontSize: 16, fontWeight: FontWeight.bold)),
            Text('Review what happens before permanently deleting your account.', style: TextStyle(color: isDark ? Colors.grey[400] : Colors.grey[700], fontSize: 12)),
          ],
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 800),
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _buildWarningCard(isDark),
                  const SizedBox(height: 32),
                  _buildSectionTitle('What happens when you delete your account?', isDark),
                  _buildConsequencesList(isDark),
                  const SizedBox(height: 32),
                  _buildSectionTitle('Before You Continue', isDark),
                  _buildChecklist(isDark),
                  const SizedBox(height: 48),
                  _buildDeletionAction(isDark),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildWarningCard(bool isDark) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF2C1919) : const Color(0xFFFFF0F0),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: isDark ? Colors.red[900]! : Colors.red[200]!),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.warning_amber_rounded, color: isDark ? Colors.red[400] : Colors.red[700]),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              "Deleting your account may permanently remove your profile, study progress, bookmarks, preferences, and other associated data according to the application's deletion policy. Review the details before continuing.",
              style: TextStyle(color: isDark ? Colors.grey[300] : Colors.red[900], fontSize: 14, height: 1.5),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title, bool isDark) {
    return Padding(
      padding: const EdgeInsets.only(left: 8, bottom: 12),
      child: Text(title, style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: isDark ? Colors.white : const Color(0xFF0F0F11))),
    );
  }

  Widget _buildConsequencesList(bool isDark) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: isDark ? const Color(0xFF333333) : const Color(0xFFF3F4F6)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildConsequenceItem(
            Icons.person_remove_outlined, 
            'Account profile and preferences', 
            'Your personal profile data and configuration settings will be deleted.', 
            isDark
          ),
          const Divider(height: 24),
          _buildConsequenceItem(
            Icons.auto_graph_outlined, 
            'Exam preparation progress', 
            'Your study history, mock test results, and analytics will be permanently removed.', 
            isDark
          ),
          const Divider(height: 24),
          _buildConsequenceItem(
            Icons.bookmark_remove_outlined, 
            'Saved questions and bookmarks', 
            'All personal collections, notes, and bookmarked questions will be lost.', 
            isDark
          ),
          const Divider(height: 24),
          _buildConsequenceItem(
            Icons.info_outline, 
            'Legal and operational records', 
            'Some financial and support records may be retained temporarily to comply with legal obligations.', 
            isDark
          ),
        ],
      ),
    );
  }

  Widget _buildConsequenceItem(IconData icon, String title, String description, bool isDark) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 20, color: isDark ? Colors.grey[400] : Colors.grey[600]),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: TextStyle(fontWeight: FontWeight.bold, color: isDark ? Colors.white : const Color(0xFF0F0F11), fontSize: 14)),
              const SizedBox(height: 4),
              Text(description, style: TextStyle(color: isDark ? Colors.grey[400] : Colors.grey[600], fontSize: 13, height: 1.4)),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildChecklist(bool isDark) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF2C2C2E) : const Color(0xFFF9F8FD),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: isDark ? const Color(0xFF333333) : const Color(0xFFE4DBF6)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildChecklistItem('Review saved study materials and bookmarks.', isDark),
          const SizedBox(height: 12),
          _buildChecklistItem('Consider exporting important information if an export feature exists.', isDark),
          const SizedBox(height: 12),
          _buildChecklistItem('Review any active subscription and its cancellation requirements.', isDark),
          const SizedBox(height: 12),
          _buildChecklistItem('Make sure you understand the permanent consequences of deletion.', isDark),
        ],
      ),
    );
  }

  Widget _buildChecklistItem(String text, bool isDark) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(Icons.check_circle_outline, size: 18, color: const Color(0xFF5A31F4)),
        const SizedBox(width: 12),
        Expanded(
          child: Text(text, style: TextStyle(color: isDark ? Colors.grey[300] : Colors.grey[800], fontSize: 14)),
        ),
      ],
    );
  }

  Widget _buildDeletionAction(bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Permanently delete account', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.red[700])),
        const SizedBox(height: 8),
        Text(
          'Once you delete your account, there is no going back. Please be certain.',
          style: TextStyle(color: isDark ? Colors.grey[400] : Colors.grey[600], fontSize: 14),
        ),
        const SizedBox(height: 16),
        SizedBox(
          width: double.infinity,
          height: 48,
          child: OutlinedButton(
            onPressed: _showDeleteConfirmationDialog,
            style: OutlinedButton.styleFrom(
              foregroundColor: Colors.red,
              side: const BorderSide(color: Colors.red),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            child: const Text('Continue to deletion confirmation', style: TextStyle(fontWeight: FontWeight.bold)),
          ),
        ),
      ],
    );
  }
}
