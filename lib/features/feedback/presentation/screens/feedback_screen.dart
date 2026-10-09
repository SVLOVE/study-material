import 'package:go_router/go_router.dart';
import 'package:flutter/material.dart';

enum ReportType {
  incorrectQuestion,
  incorrectAnswer,
  incorrectExplanation,
  outdatedInfo,
  duplicateQuestion,
  technicalIssue,
  uiIssue,
  paymentIssue,
  contentSuggestion,
  generalFeedback,
  other
}

class FeedbackScreen extends StatefulWidget {
  final String? questionId;
  final String? transactionId;

  const FeedbackScreen({
    super.key,
    this.questionId,
    this.transactionId,
  });

  @override
  State<FeedbackScreen> createState() => _FeedbackScreenState();
}

class _FeedbackScreenState extends State<FeedbackScreen> {
  ReportType? _selectedType;
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _expectedAnswerController = TextEditingController();
  bool _isSubmitting = false;
  bool _isSuccess = false;

  final Map<ReportType, String> _typeTitles = {
    ReportType.incorrectQuestion: 'Incorrect Question',
    ReportType.incorrectAnswer: 'Incorrect Answer',
    ReportType.incorrectExplanation: 'Incorrect Explanation',
    ReportType.outdatedInfo: 'Outdated Information',
    ReportType.duplicateQuestion: 'Duplicate Question',
    ReportType.technicalIssue: 'Technical Problem',
    ReportType.uiIssue: 'UI / Accessibility Issue',
    ReportType.paymentIssue: 'Payment / Subscription Issue',
    ReportType.contentSuggestion: 'Content Suggestion',
    ReportType.generalFeedback: 'General Feedback',
    ReportType.other: 'Other',
  };

  @override
  void initState() {
    super.initState();
    if (widget.questionId != null) {
      _selectedType = ReportType.incorrectQuestion;
    } else if (widget.transactionId != null) {
      _selectedType = ReportType.paymentIssue;
    }
  }

  @override
  void dispose() {
    _descriptionController.dispose();
    _expectedAnswerController.dispose();
    super.dispose();
  }

  Future<void> _submitReport() async {
    if (_selectedType == null || _descriptionController.text.trim().isEmpty) return;

    setState(() => _isSubmitting = true);

    try {
      // Simulate backend report submission
      await Future.delayed(const Duration(seconds: 2));
      
      // In a real app, verify `auth.uid()` securely controls this data on the backend
      if (mounted) setState(() => _isSuccess = true);
    } catch (e) {
      if (mounted) {
        setState(() => _isSubmitting = false);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Couldn\'t submit report. Please try again.')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFEAE4F7),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: _isSubmitting || _isSuccess
            ? const SizedBox()
            : IconButton(
                icon: const Icon(Icons.arrow_back, color: Color(0xFF0F0F11)),
                onPressed: () => context.pop(),
              ),
        title: const Text('Feedback & Report', style: TextStyle(color: Color(0xFF0F0F11), fontSize: 18, fontWeight: FontWeight.bold)),
        centerTitle: true,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 800),
              child: _isSuccess ? _buildSuccessState() : _buildFormLayout(),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFormLayout() {
    if (MediaQuery.of(context).size.width >= 800) {
      return Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(flex: 3, child: _buildForm()),
          const SizedBox(width: 48),
          Expanded(flex: 2, child: _buildContextPanel()),
        ],
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildContextPanel(),
        if (widget.questionId != null || widget.transactionId != null) const SizedBox(height: 32),
        _buildForm(),
      ],
    );
  }

  Widget _buildContextPanel() {
    if (widget.questionId == null && widget.transactionId == null) {
      return const SizedBox();
    }

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: const Color(0xFFFFFFFF),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFF3F4F6)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Report Context', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF0F0F11))),
          const SizedBox(height: 16),
          if (widget.questionId != null) ...[
            _buildContextRow('Question ID', widget.questionId!),
            const SizedBox(height: 12),
            _buildContextRow('Exam', 'UPSC Civil Services'),
            const SizedBox(height: 12),
            _buildContextRow('Subject', 'History'),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFFF3F4F6),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Text(
                'Which of the following is correct regarding...',
                style: TextStyle(color: Color(0xFF0F0F11), fontStyle: FontStyle.italic),
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
          if (widget.transactionId != null) ...[
            _buildContextRow('Transaction', widget.transactionId!),
            const SizedBox(height: 12),
            _buildContextRow('Subscription', 'Pro Monthly'),
          ],
        ],
      ),
    );
  }

  Widget _buildContextRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: TextStyle(color: const Color(0xFF0F0F11).withValues(alpha: 0.6), fontSize: 13)),
        Text(value, style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF0F0F11), fontSize: 13)),
      ],
    );
  }

  Widget _buildForm() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Help us improve GovPrep AI by reporting problems or sharing feedback.', style: TextStyle(color: Color(0xFF0F0F11), fontSize: 14)),
        const SizedBox(height: 32),
        
        const Text('What is wrong?', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF0F0F11))),
        const SizedBox(height: 16),
        _buildTypeSelector(),
        
        const SizedBox(height: 32),
        const Text('Tell us more', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF0F0F11))),
        const SizedBox(height: 16),
        Container(
          decoration: BoxDecoration(
            color: const Color(0xFFFFFFFF),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: const Color(0xFFF3F4F6)),
          ),
          child: TextField(
            controller: _descriptionController,
            maxLines: 5,
            maxLength: 1000,
            onChanged: (_) => setState(() {}),
            decoration: InputDecoration(
              hintText: 'Describe the issue or feedback...',
              hintStyle: TextStyle(color: const Color(0xFF0F0F11).withValues(alpha: 0.4)),
              border: InputBorder.none,
              contentPadding: const EdgeInsets.all(20),
            ),
          ),
        ),

        if (_selectedType == ReportType.incorrectAnswer) ...[
          const SizedBox(height: 24),
          const Text('What should the answer be? (Optional)', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Color(0xFF0F0F11))),
          const SizedBox(height: 12),
          Container(
            decoration: BoxDecoration(
              color: const Color(0xFFFFFFFF),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: const Color(0xFFF3F4F6)),
            ),
            child: TextField(
              controller: _expectedAnswerController,
              decoration: InputDecoration(
                hintText: 'Provide the correct answer...',
                hintStyle: TextStyle(color: const Color(0xFF0F0F11).withValues(alpha: 0.4)),
                border: InputBorder.none,
                contentPadding: const EdgeInsets.all(20),
              ),
            ),
          ),
        ],

        const SizedBox(height: 32),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: const Color(0xFFFDF0D5),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.orange.withValues(alpha: 0.3)),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Icon(Icons.security, color: Colors.orange, size: 20),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  'Never include passwords, OTPs, UPI PINs, CVV, or other sensitive credentials in your report.',
                  style: TextStyle(color: const Color(0xFF0F0F11).withValues(alpha: 0.8), fontSize: 13),
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 32),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: (_selectedType == null || _descriptionController.text.trim().isEmpty || _isSubmitting) ? null : _submitReport,
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 16),
              backgroundColor: const Color(0xFF0F0F11),
              foregroundColor: Colors.white,
              disabledBackgroundColor: const Color(0xFF0F0F11).withValues(alpha: 0.1),
              disabledForegroundColor: const Color(0xFF0F0F11).withValues(alpha: 0.3),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            ),
            child: _isSubmitting
                ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                : const Text('Submit Report', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          ),
        ),
      ],
    );
  }

  Widget _buildTypeSelector() {
    List<ReportType> availableTypes = ReportType.values;
    
    if (widget.questionId != null) {
      availableTypes = [
        ReportType.incorrectQuestion,
        ReportType.incorrectAnswer,
        ReportType.incorrectExplanation,
        ReportType.outdatedInfo,
        ReportType.duplicateQuestion,
      ];
    } else if (widget.transactionId != null) {
      availableTypes = [
        ReportType.paymentIssue,
        ReportType.technicalIssue,
        ReportType.other,
      ];
    } else {
      availableTypes = [
        ReportType.technicalIssue,
        ReportType.uiIssue,
        ReportType.paymentIssue,
        ReportType.contentSuggestion,
        ReportType.generalFeedback,
        ReportType.other,
      ];
    }

    return Wrap(
      spacing: 12,
      runSpacing: 12,
      children: availableTypes.map((type) {
        final isSelected = _selectedType == type;
        return InkWell(
          onTap: () => setState(() => _selectedType = type),
          borderRadius: BorderRadius.circular(20),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            decoration: BoxDecoration(
              color: isSelected ? const Color(0xFFE4DBF6) : const Color(0xFFFFFFFF),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: isSelected ? const Color(0xFFE4DBF6) : const Color(0xFFF3F4F6)),
            ),
            child: Text(
              _typeTitles[type]!,
              style: TextStyle(
                color: const Color(0xFF0F0F11),
                fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                fontSize: 13,
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildSuccessState() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(48),
      decoration: BoxDecoration(
        color: const Color(0xFFFFFFFF),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: const Color(0xFFE2F0D9), width: 2),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.check_circle, size: 64, color: Colors.green),
          const SizedBox(height: 24),
          const Text('Thank You', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Color(0xFF0F0F11))),
          const SizedBox(height: 8),
          Text('Your feedback has been submitted. It will help us improve GovPrep AI.', textAlign: TextAlign.center, style: TextStyle(color: const Color(0xFF0F0F11).withValues(alpha: 0.6))),
          const SizedBox(height: 32),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(color: const Color(0xFFF3F4F6), borderRadius: BorderRadius.circular(12)),
            child: const Text('Report ID: REP-12345', style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF0F0F11), fontSize: 13)), // Mocked from backend
          ),
          const SizedBox(height: 32),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () => context.pop(),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                backgroundColor: const Color(0xFF0F0F11),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              ),
              child: const Text('Back', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            ),
          ),
        ],
      ),
    );
  }
}
