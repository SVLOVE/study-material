import 'package:go_router/go_router.dart';
import 'package:flutter/material.dart';

class FlashcardSessionScreen extends StatefulWidget {
  final String source;
  const FlashcardSessionScreen({super.key, required this.source});

  @override
  State<FlashcardSessionScreen> createState() => _FlashcardSessionScreenState();
}

class _FlashcardSessionScreenState extends State<FlashcardSessionScreen> {
  bool _isLoading = true;
  bool _isRevealed = false;
  int _currentIndex = 0;
  final int _totalCards = 12; // Mock total count based on today's practice mock

  @override
  void initState() {
    super.initState();
    _fetchSession();
  }

  Future<void> _fetchSession() async {
    setState(() => _isLoading = true);
    await Future.delayed(const Duration(milliseconds: 600)); // Mock network
    if (mounted) setState(() => _isLoading = false);
  }

  void _revealCard() {
    setState(() {
      _isRevealed = true;
    });
  }

  void _nextCard(String assessment) {
    // In real app, we'd record assessment to the spaced-repetition backend here.
    if (_currentIndex < _totalCards - 1) {
      setState(() {
        _currentIndex++;
        _isRevealed = false;
      });
    } else {
      _showCompletion();
    }
  }

  void _showCompletion() {
    showModalBottomSheet(
      context: context,
      isDismissible: false,
      enableDrag: false,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        padding: const EdgeInsets.all(24),
        decoration: const BoxDecoration(
          color: Color(0xFFFFFFFF),
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.check_circle, size: 64, color: Colors.green),
              const SizedBox(height: 16),
              const Text('Memory Practice Complete', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Color(0xFF0F0F11))),
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _buildCompletionStat('$_totalCards', 'Reviewed'),
                  _buildCompletionStat('${(_totalCards * 0.7).toInt()}', 'Remembered'),
                  _buildCompletionStat('${(_totalCards * 0.3).toInt()}', 'Needs review'),
                ],
              ),
              const SizedBox(height: 32),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    context.pop(); // Close sheet
                    context.pop(); // Close session
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF0F0F11),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: const Text('Continue Learning', style: TextStyle(fontWeight: FontWeight.bold)),
                ),
              ),
              const SizedBox(height: 12),
              TextButton(
                onPressed: () {
                  context.pop();
                  setState(() {
                    _currentIndex = 0;
                    _isRevealed = false;
                  });
                },
                child: const Text('Review Again', style: TextStyle(color: Color(0xFF0F0F11), fontWeight: FontWeight.bold)),
              )
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCompletionStat(String value, String label) {
    return Column(
      children: [
        Text(value, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Color(0xFF0F0F11))),
        const SizedBox(height: 4),
        Text(label, style: const TextStyle(fontSize: 12, color: Colors.grey, fontWeight: FontWeight.bold)),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFEAE4F7),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.close, color: Color(0xFF0F0F11)),
          onPressed: () => context.pop(),
        ),
        title: _isLoading ? null : Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Expanded(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: LinearProgressIndicator(
                  value: (_currentIndex + 1) / _totalCards,
                  backgroundColor: const Color(0xFFF3F4F6),
                  valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF0F0F11)),
                  minHeight: 8,
                ),
              ),
            ),
            const SizedBox(width: 16),
            Text('${_currentIndex + 1} / $_totalCards', style: const TextStyle(color: Color(0xFF0F0F11), fontSize: 14, fontWeight: FontWeight.bold)),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.bookmark_border, color: Color(0xFF0F0F11)),
            onPressed: () => ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Card bookmarked'))),
          ),
          PopupMenuButton<String>(
            icon: const Icon(Icons.more_vert, color: Color(0xFF0F0F11)),
            onSelected: (val) {
              if (val == 'report') ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Report opened')));
            },
            itemBuilder: (context) => [
              const PopupMenuItem(value: 'report', child: Text('Report Content')),
            ],
          )
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
        Expanded(
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 800),
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: _buildFlashcard(),
              ),
            ),
          ),
        ),
        _buildBottomActions(),
      ],
    );
  }

  Widget _buildFlashcard() {
    return GestureDetector(
      onTap: !_isRevealed ? _revealCard : null,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        width: double.infinity,
        padding: const EdgeInsets.all(32),
        decoration: BoxDecoration(
          color: const Color(0xFFFFFFFF),
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: const Color(0xFFF3F4F6)),
          boxShadow: [
            BoxShadow(color: const Color(0xFF0F0F11).withValues(alpha: 0.05), blurRadius: 20, offset: const Offset(0, 10)),
          ],
        ),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(color: const Color(0xFFF3F4F6), borderRadius: BorderRadius.circular(8)),
                    child: const Text('TNPSC • Indian Polity', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.grey)),
                  ),
                ],
              ),
              const SizedBox(height: 32),
              const Text(
                'What is the fundamental principle behind judicial review in the Indian Constitution?',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Color(0xFF0F0F11), height: 1.4),
              ),
              
              if (_isRevealed) ...[
                const SizedBox(height: 32),
                const Divider(color: Color(0xFFF3F4F6)),
                const SizedBox(height: 32),
                const Text(
                  'The Rule of Law and the Supremacy of the Constitution',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.deepPurple),
                ),
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFDF0D5).withValues(alpha: 0.5),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Text(
                    'Explanation: It ensures that all laws and executive actions comply with the Constitution. It acts as a mechanism to protect Fundamental Rights.',
                    style: TextStyle(fontSize: 14, color: Color(0xFF0F0F11), height: 1.5),
                  ),
                ),
              ] else ...[
                const SizedBox(height: 48),
                const Text('Tap to reveal', style: TextStyle(fontSize: 14, color: Colors.grey, fontWeight: FontWeight.bold)),
              ]
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBottomActions() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: const Color(0xFFFFFFFF),
        border: Border(top: BorderSide(color: const Color(0xFF0F0F11).withValues(alpha: 0.05))),
      ),
      child: SafeArea(
        top: false,
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 800),
            child: _isRevealed ? _buildSelfAssessment() : _buildRevealButton(),
          ),
        ),
      ),
    );
  }

  Widget _buildRevealButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: _revealCard,
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF0F0F11),
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 20),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        ),
        child: const Text('Reveal Answer', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
      ),
    );
  }

  Widget _buildSelfAssessment() {
    return Column(
      children: [
        const Text('How well did you remember?', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.grey)),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: _buildAssessmentButton('Again', 'Review soon', Colors.red, () => _nextCard('again')),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: _buildAssessmentButton('Hard', 'Short interval', Colors.orange, () => _nextCard('hard')),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: _buildAssessmentButton('Good', 'Normal interval', Colors.green, () => _nextCard('good')),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: _buildAssessmentButton('Easy', 'Longer interval', Colors.blue, () => _nextCard('easy')),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildAssessmentButton(String title, String subtitle, MaterialColor color, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 4),
        decoration: BoxDecoration(
          color: color.shade50,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.shade200),
        ),
        child: Column(
          children: [
            Text(title, style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: color.shade700)),
            const SizedBox(height: 4),
            Text(subtitle, style: TextStyle(fontSize: 10, color: color.shade700, fontWeight: FontWeight.w500), textAlign: TextAlign.center),
          ],
        ),
      ),
    );
  }
}
