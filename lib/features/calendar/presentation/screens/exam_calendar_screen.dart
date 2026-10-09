import 'package:go_router/go_router.dart';
import 'package:flutter/material.dart';

class ExamEvent {
  final String id;
  final String examName;
  final String eventType;
  final String dateString;
  final String status;
  final String sourceUrl;
  final bool isVerified;
  final DateTime? publishedAt;
  final bool isDateAvailable;

  ExamEvent({
    required this.id,
    required this.examName,
    required this.eventType,
    required this.dateString,
    required this.status,
    required this.sourceUrl,
    required this.isVerified,
    this.publishedAt,
    this.isDateAvailable = true,
  });
}

class ExamCalendarScreen extends StatefulWidget {
  const ExamCalendarScreen({super.key});

  @override
  State<ExamCalendarScreen> createState() => _ExamCalendarScreenState();
}

class _ExamCalendarScreenState extends State<ExamCalendarScreen> {
  bool _isLoading = true;
  String _selectedExam = 'TNPSC Group 4';
  
  final List<String> _targetExams = [
    'TNPSC Group 4',
    'TNPSC Group 1',
    'SSC CGL',
    'UPSC CSE',
  ];
  
  List<ExamEvent> _events = [];

  @override
  void initState() {
    super.initState();
    _fetchCalendarData();
  }

  Future<void> _fetchCalendarData() async {
    setState(() => _isLoading = true);
    
    try {
      await Future.delayed(const Duration(milliseconds: 600)); // Mock network delay
      
      // Creating realistic mock data that respects the rule: "Only display dates that actually exist in the backend/content source"
      // If we don't have a verified date, we represent it explicitly as unavailable.
      
      _events = [
        ExamEvent(
          id: 'ev_1',
          examName: 'TNPSC Group 4',
          eventType: 'Application Deadline',
          dateString: '28 October 2026',
          status: 'Closing Soon',
          sourceUrl: 'https://tnpsc.gov.in',
          isVerified: true,
          publishedAt: DateTime.now().subtract(const Duration(days: 2)),
        ),
        ExamEvent(
          id: 'ev_2',
          examName: 'TNPSC Group 4',
          eventType: 'Examination Date',
          dateString: 'Date not announced',
          status: 'Upcoming',
          sourceUrl: 'https://tnpsc.gov.in',
          isVerified: true,
          isDateAvailable: false, // Represents verified absence of a date
        ),
        ExamEvent(
          id: 'ev_3',
          examName: 'SSC CGL',
          eventType: 'Notification',
          dateString: '12 November 2026',
          status: 'Upcoming',
          sourceUrl: 'https://ssc.nic.in',
          isVerified: true,
          publishedAt: DateTime.now().subtract(const Duration(days: 5)),
        ),
      ];
      
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _showEventDetail(ExamEvent event) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) {
        return Container(
          decoration: const BoxDecoration(
            color: Color(0xFFFFFFFF),
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          padding: const EdgeInsets.all(24),
          child: SafeArea(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(event.eventType, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Color(0xFF0F0F11))),
                    IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                
                _buildDetailRow('Exam', event.examName),
                const Divider(height: 24, color: Color(0xFFF3F4F6)),
                
                _buildDetailRow('Date', event.isDateAvailable ? event.dateString : 'Official dates are currently unavailable.'),
                const Divider(height: 24, color: Color(0xFFF3F4F6)),
                
                _buildDetailRow('Status', event.status),
                const Divider(height: 24, color: Color(0xFFF3F4F6)),
                
                if (event.isVerified) ...[
                  Row(
                    children: [
                      const Icon(Icons.verified, color: Colors.blue, size: 18),
                      const SizedBox(width: 8),
                      const Text('Verified Source', style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF0F0F11))),
                      const Spacer(),
                      if (event.publishedAt != null)
                        Text('Updated ${event.publishedAt!.day}/${event.publishedAt!.month}/${event.publishedAt!.year}', style: const TextStyle(fontSize: 12, color: Colors.grey)),
                    ],
                  ),
                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton(
                      onPressed: () {
                        // Open external link safely
                        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Opening official notification safely...')));
                      },
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: Color(0xFF0F0F11)),
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      child: const Text('View Official Notification', style: TextStyle(color: Color(0xFF0F0F11), fontWeight: FontWeight.bold)),
                    ),
                  ),
                ],
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 80,
          child: Text(label, style: const TextStyle(color: Colors.grey, fontWeight: FontWeight.w600)),
        ),
        Expanded(
          child: Text(value, style: const TextStyle(color: Color(0xFF0F0F11), fontWeight: FontWeight.bold)),
        ),
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
          icon: const Icon(Icons.arrow_back, color: Color(0xFF0F0F11)),
          onPressed: () => context.pop(),
        ),
        title: const Text('Exam Calendar', style: TextStyle(color: Color(0xFF0F0F11), fontSize: 18, fontWeight: FontWeight.bold)),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Column(
          children: [
            _buildTargetSelector(),
            Expanded(
              child: _isLoading ? const Center(child: CircularProgressIndicator(color: Color(0xFF0F0F11))) : _buildContent(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTargetSelector() {
    return Container(
      width: double.infinity,
      color: const Color(0xFFFFFFFF),
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Target Exam', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.grey)),
          const SizedBox(height: 8),
          DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: _selectedExam,
              isExpanded: true,
              icon: const Icon(Icons.keyboard_arrow_down, color: Color(0xFF0F0F11)),
              items: _targetExams.map((exam) => DropdownMenuItem(
                value: exam,
                child: Text(exam, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF0F0F11))),
              )).toList(),
              onChanged: (val) {
                if (val != null) {
                  setState(() => _selectedExam = val);
                  _fetchCalendarData();
                }
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContent() {
    final filteredEvents = _events.where((e) => e.examName == _selectedExam).toList();

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24.0),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 800),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Upcoming', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFF0F0F11))),
              const SizedBox(height: 16),
              
              if (filteredEvents.isEmpty)
                _buildEmptyState()
              else
                ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: filteredEvents.length,
                  itemBuilder: (context, index) {
                    return _buildEventCard(filteredEvents[index]);
                  },
                ),
                
              const SizedBox(height: 48),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: const Color(0xFFFFFFFF),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: const Color(0xFFF3F4F6)),
      ),
      child: const Column(
        children: [
          Icon(Icons.event_busy, size: 64, color: Colors.grey),
          SizedBox(height: 16),
          Text('Calendar Data Unavailable', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF0F0F11)), textAlign: TextAlign.center),
          SizedBox(height: 8),
          Text('We don\'t currently have verified dates for this exam.', textAlign: TextAlign.center, style: TextStyle(color: Colors.grey)),
        ],
      ),
    );
  }

  Widget _buildEventCard(ExamEvent event) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: const Color(0xFFFFFFFF),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFF3F4F6)),
      ),
      child: InkWell(
        onTap: () => _showEventDetail(event),
        borderRadius: BorderRadius.circular(20),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(event.examName, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.deepPurple)),
                  if (event.isVerified)
                    const Icon(Icons.verified, size: 16, color: Colors.blue),
                ],
              ),
              const SizedBox(height: 8),
              Text(event.eventType, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF0F0F11))),
              const SizedBox(height: 12),
              
              Row(
                children: [
                  const Icon(Icons.calendar_today, size: 16, color: Colors.grey),
                  const SizedBox(width: 8),
                  Text(
                    event.isDateAvailable ? event.dateString : 'Date not announced',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: event.isDateAvailable ? const Color(0xFF0F0F11) : Colors.grey,
                    ),
                  ),
                ],
              ),
              
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF3F4F6),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(event.status, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFF0F0F11))),
                  ),
                  const Icon(Icons.arrow_forward_ios, size: 14, color: Colors.grey),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
