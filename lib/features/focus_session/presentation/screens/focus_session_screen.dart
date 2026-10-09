import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'dart:async';

import '../../../../core/widgets/glass_container.dart';
import '../../../../core/widgets/primary_button.dart';
import '../../domain/models/focus_session_model.dart';

class FocusSessionScreen extends StatefulWidget {
  final Map<String, dynamic> sessionData;

  const FocusSessionScreen({super.key, required this.sessionData});

  @override
  State<FocusSessionScreen> createState() => _FocusSessionScreenState();
}

class _FocusSessionScreenState extends State<FocusSessionScreen> {
  late FocusSessionModel _session;
  Timer? _timer;
  int _secondsRemaining = 0;

  @override
  void initState() {
    super.initState();
    _initializeSession();
  }

  void _initializeSession() {
    final durationMinutes = widget.sessionData['duration'] as int? ?? 25;
    _secondsRemaining = durationMinutes * 60;
    
    _session = FocusSessionModel(
      id: 'session_${DateTime.now().millisecondsSinceEpoch}',
      title: 'Focus Session',
      exam: widget.sessionData['exam'] ?? 'Exam',
      subject: widget.sessionData['subject'] ?? 'Subject',
      topic: widget.sessionData['topic'] ?? 'Topic',
      activityType: widget.sessionData['activity'] ?? 'Practice',
      durationMinutes: durationMinutes,
      startedAt: DateTime.now(),
      status: FocusSessionStatus.running,
      focusedSeconds: 0,
    );

    _startTimer();
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_secondsRemaining > 0 && _session.status == FocusSessionStatus.running) {
        setState(() {
          _secondsRemaining--;
          _session = _session.copyWith(focusedSeconds: _session.focusedSeconds + 1);
        });
      } else if (_secondsRemaining <= 0) {
        _completeSession();
      }
    });
  }

  void _togglePause() {
    setState(() {
      if (_session.status == FocusSessionStatus.running) {
        _session = _session.copyWith(status: FocusSessionStatus.paused);
      } else if (_session.status == FocusSessionStatus.paused) {
        _session = _session.copyWith(status: FocusSessionStatus.running);
      }
    });
  }

  void _completeSession() {
    _timer?.cancel();
    setState(() {
      _session = _session.copyWith(
        status: FocusSessionStatus.completed,
        endedAt: DateTime.now(),
      );
    });
    
    context.pushReplacement('/focus/summary', extra: _session);
  }

  void _confirmExit() {
    if (_session.status == FocusSessionStatus.completed) {
      context.pop();
      return;
    }
    
    _togglePause(); // Pause while asking
    
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Text('End this focus session?'),
        content: const Text('Your current progress will be saved. You can also resume the session.'),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        actions: [
          TextButton(
            onPressed: () {
              context.pop();
              _togglePause(); // Resume
            },
            child: const Text('Continue Session', style: TextStyle(color: Colors.grey)),
          ),
          ElevatedButton(
            onPressed: () {
              context.pop();
              _completeSession();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF0F0F11),
              foregroundColor: Colors.white,
            ),
            child: const Text('Save & Exit'),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  String _formatTime(int seconds) {
    final m = seconds ~/ 60;
    final s = seconds % 60;
    return '${m.toString().padLeft(2, '0')}:${s.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    // A calm, distraction-free layout
    return WillPopScope(
      onWillPop: () async {
        _confirmExit();
        return false;
      },
      child: Scaffold(
        backgroundColor: const Color(0xFFEAE4F7), // Calm background
        body: SafeArea(
          child: Column(
            children: [
              _buildFocusHeader(),
              Expanded(
                child: _buildWorkspace(),
              ),
              _buildBottomControls(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFocusHeader() {
    return Container(
      padding: const EdgeInsets.all(20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          IconButton(
            icon: const Icon(Icons.close, color: Color(0xFF0F0F11)),
            onPressed: _confirmExit,
          ),
          Expanded(
            child: Column(
              children: [
                Text(
                  _session.activityType,
                  style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.deepPurple),
                ),
                const SizedBox(height: 4),
                Text(
                  '${_session.exam} • ${_session.subject}',
                  style: const TextStyle(fontSize: 12, color: Color(0xFF555555)),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: const Color(0xFF0F0F11),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              _formatTime(_secondsRemaining),
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.white,
                fontFeatures: [FontFeature.tabularFigures()],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWorkspace() {
    // This connects to the actual underlying activity. For now, it's a calm placeholder.
    // In a real app, if activityType == 'Practice', we'd embed the PracticeArena widget here.
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20.0),
      child: GlassContainer(
        blur: 20,
        opacity: 0.9,
        borderRadius: BorderRadius.circular(24),
        child: _session.status == FocusSessionStatus.paused
            ? _buildPausedState()
            : _buildActiveState(),
      ),
    );
  }
  
  Widget _buildPausedState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.pause_circle_outline, size: 64, color: Colors.grey.shade400),
          const SizedBox(height: 24),
          const Text(
            'Session Paused',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Color(0xFF0F0F11)),
          ),
          const SizedBox(height: 12),
          const Text(
            'Your progress is saved. Take a breath.',
            style: TextStyle(fontSize: 16, color: Color(0xFF555555)),
          ),
          const SizedBox(height: 40),
          ElevatedButton(
            onPressed: _togglePause,
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF0F0F11),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            ),
            child: const Text('Resume Session', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  Widget _buildActiveState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: const Color(0xFFF3F4F6),
              shape: BoxShape.circle,
            ),
            child: Icon(_getActivityIcon(), size: 48, color: const Color(0xFF0F0F11)),
          ),
          const SizedBox(height: 32),
          Text(
            _session.topic,
            style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Color(0xFF0F0F11)),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          const Text(
            'Stay focused. Avoid distractions.',
            style: TextStyle(fontSize: 16, color: Color(0xFF555555)),
          ),
          const SizedBox(height: 40),
          const CircularProgressIndicator(color: Color(0xFF0F0F11)),
          const SizedBox(height: 24),
          Text(
            'Loading ${_session.activityType} engine...',
            style: const TextStyle(fontSize: 14, color: Colors.grey),
          ),
        ],
      ),
    );
  }

  IconData _getActivityIcon() {
    switch (_session.activityType) {
      case 'Practice': return Icons.edit_note;
      case 'Revision': return Icons.refresh;
      case 'Flashcards': return Icons.style;
      case 'Study Material': return Icons.menu_book;
      default: return Icons.computer;
    }
  }

  Widget _buildBottomControls() {
    return Container(
      padding: const EdgeInsets.all(24),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          _buildControlButton(
            icon: _session.status == FocusSessionStatus.paused ? Icons.play_arrow : Icons.pause,
            label: _session.status == FocusSessionStatus.paused ? 'Resume' : 'Pause',
            onTap: _togglePause,
            isPrimary: false,
          ),
          const SizedBox(width: 24),
          _buildControlButton(
            icon: Icons.check,
            label: 'Complete',
            onTap: _confirmExit,
            isPrimary: true,
          ),
        ],
      ),
    );
  }

  Widget _buildControlButton({required IconData icon, required String label, required VoidCallback onTap, required bool isPrimary}) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              color: isPrimary ? const Color(0xFF0F0F11) : const Color(0xFFFFFFFF),
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Icon(
              icon,
              size: 28,
              color: isPrimary ? Colors.white : const Color(0xFF0F0F11),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Color(0xFF555555)),
          ),
        ],
      ),
    );
  }
}
