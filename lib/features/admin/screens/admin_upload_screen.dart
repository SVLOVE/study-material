import 'dart:io';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:go_router/go_router.dart';
import '../../../core/widgets/glass_container.dart';
import '../../../core/widgets/glow_button.dart';

class AdminUploadScreen extends StatefulWidget {
  const AdminUploadScreen({super.key});

  @override
  State<AdminUploadScreen> createState() => _AdminUploadScreenState();
}

class _AdminUploadScreenState extends State<AdminUploadScreen> {
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  
  List<dynamic> _exams = [];
  String? _selectedExamId;
  File? _selectedFile;
  bool _isLoadingExams = true;
  bool _isUploading = false;
  double _uploadProgress = 0;

  @override
  void initState() {
    super.initState();
    _fetchExams();
  }

  Future<void> _fetchExams() async {
    try {
      final response = await Supabase.instance.client.from('exams').select('id, name');
      if (mounted) {
        setState(() {
          _exams = response;
          _isLoadingExams = false;
        });
      }
    } catch (e) {
      if (mounted) setState(() => _isLoadingExams = false);
    }
  }

  Future<void> _pickFile() async {
    List<PlatformFile>? result = await FilePicker.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf'],
    );

    if (result != null && result.isNotEmpty && result.first.path != null) {
      setState(() {
        _selectedFile = File(result.first.path!);
      });
    }
  }

  Future<void> _uploadMaterial() async {
    if (_titleController.text.trim().isEmpty || _selectedExamId == null || _selectedFile == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select an Exam, fill Title, and pick a PDF.')),
      );
      return;
    }

    setState(() {
      _isUploading = true;
      _uploadProgress = 0.1;
    });

    try {
      final fileName = '${DateTime.now().millisecondsSinceEpoch}_${_selectedFile!.path.split('/').last}';
      
      // 1. Upload to Storage
      await Supabase.instance.client.storage
          .from('materials')
          .upload(fileName, _selectedFile!);

      setState(() => _uploadProgress = 0.6);

      // 2. Get Public URL
      final publicUrl = Supabase.instance.client.storage
          .from('materials')
          .getPublicUrl(fileName);

      setState(() => _uploadProgress = 0.8);

      // 3. Save to Database
      await Supabase.instance.client.from('study_materials').insert({
        'exam_id': _selectedExamId,
        'title': _titleController.text.trim(),
        'description': _descriptionController.text.trim(),
        'file_url': publicUrl,
      });

      setState(() => _uploadProgress = 1.0);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('PDF Uploaded Successfully!')),
        );
        _titleController.clear();
        _descriptionController.clear();
        setState(() {
          _selectedFile = null;
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Upload failed: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isUploading = false;
          _uploadProgress = 0;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: const Text('Admin: Upload Material', style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF1A1A2E), Color(0xFF16213E), Color(0xFF0F3460)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: GlassContainer(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Text('Select Exam Category', style: TextStyle(color: Colors.white70)),
                  const SizedBox(height: 8),
                  if (_isLoadingExams)
                    const CircularProgressIndicator(color: Colors.cyanAccent)
                  else
                    DropdownButtonFormField<String>(
                      dropdownColor: const Color(0xFF16213E),
                      style: const TextStyle(color: Colors.white),
                      decoration: InputDecoration(
                        enabledBorder: OutlineInputBorder(borderSide: BorderSide(color: Colors.white.withOpacity(0.3))),
                        focusedBorder: const OutlineInputBorder(borderSide: BorderSide(color: Colors.cyanAccent)),
                        filled: true,
                        fillColor: Colors.black.withOpacity(0.1),
                      ),
                      value: _selectedExamId,
                      items: _exams.map((exam) {
                        return DropdownMenuItem<String>(
                          value: exam['id'],
                          child: Text(exam['name']),
                        );
                      }).toList(),
                      onChanged: (val) => setState(() => _selectedExamId = val),
                    ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: _titleController,
                    style: const TextStyle(color: Colors.white),
                    decoration: InputDecoration(
                      labelText: 'Material Title',
                      labelStyle: const TextStyle(color: Colors.white70),
                      enabledBorder: OutlineInputBorder(borderSide: BorderSide(color: Colors.white.withOpacity(0.3))),
                      focusedBorder: const OutlineInputBorder(borderSide: BorderSide(color: Colors.cyanAccent)),
                      filled: true,
                      fillColor: Colors.black.withOpacity(0.1),
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: _descriptionController,
                    style: const TextStyle(color: Colors.white),
                    decoration: InputDecoration(
                      labelText: 'Description (Optional)',
                      labelStyle: const TextStyle(color: Colors.white70),
                      enabledBorder: OutlineInputBorder(borderSide: BorderSide(color: Colors.white.withOpacity(0.3))),
                      focusedBorder: const OutlineInputBorder(borderSide: BorderSide(color: Colors.cyanAccent)),
                      filled: true,
                      fillColor: Colors.black.withOpacity(0.1),
                    ),
                  ),
                  const SizedBox(height: 24),
                  InkWell(
                    onTap: _pickFile,
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.cyanAccent, style: BorderStyle.solid),
                        borderRadius: BorderRadius.circular(12),
                        color: Colors.cyanAccent.withOpacity(0.1),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.picture_as_pdf, color: Colors.cyanAccent),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              _selectedFile == null ? 'Select PDF File' : _selectedFile!.path.split('/').last,
                              style: const TextStyle(color: Colors.cyanAccent),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 32),
                  if (_isUploading)
                    Column(
                      children: [
                        LinearProgressIndicator(value: _uploadProgress, color: Colors.purpleAccent),
                        const SizedBox(height: 8),
                        Text('Uploading... \%', style: const TextStyle(color: Colors.white)),
                      ],
                    )
                  else
                    GlowButton(
                      text: 'UPLOAD PDF',
                      onPressed: _uploadMaterial,
                      glowColor: Colors.purpleAccent,
                    ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
