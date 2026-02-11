import 'package:flutter/material.dart';
import 'dart:ui';
import '../services/authservice.dart';
import 'TILIDashboard.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'dart:convert';

class FlashcardCreatorPage extends StatefulWidget {
  const FlashcardCreatorPage({super.key});

  @override
  State<FlashcardCreatorPage> createState() => _FlashcardCreatorPageState();
}

class _FlashcardCreatorPageState extends State<FlashcardCreatorPage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _descController = TextEditingController();
  final _topicController = TextEditingController();
  String _selectedSubject = 'custom';
  bool _isSubmitting = false;
  final AuthService _authService = AuthService();
  final _storage = const FlutterSecureStorage();

  final List<String> _subjects = ['math', 'physics', 'technical knowledge', 'reading', 'custom'];

  Future<void> _createCard() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSubmitting = true);

    try {
      final token = await _storage.read(key: 'token');
      if (token == null) return;

      final userInfoRes = await _authService.getinfo(token);
      final userId = userInfoRes.data['_id'];

      final response = await _authService.addFlashcard(
        index: DateTime.now().millisecondsSinceEpoch,
        name: _nameController.text,
        description: _descController.text,
        subject: _selectedSubject,
        imageUrl: "",
        userId: userId,
        topic: _topicController.text,
      );

      print("DEBUG: addFlashcard response status: ${response.statusCode}");
      print("DEBUG: addFlashcard response data: ${response.data}");

      // Backend update: if success
      if (response.data['success']) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Flashcard created successfully!")),
          );
          Navigator.pop(context);
        }
      }
    } catch (e) {
      print("Error creating card: $e");
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bg = isDark ? BentoColors.darkBg : BentoColors.lightBg;
    final text = isDark ? BentoColors.darkTextPrimary : BentoColors.lightTextPrimary;
    final cardBg = isDark ? const Color(0xFF1E1E1E) : Colors.white;

    return Scaffold(
      backgroundColor: bg,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: Icon(Icons.close_rounded, color: text),
        ),
        title: Text("Create Flashcard", style: TextStyle(color: text, fontWeight: FontWeight.bold)),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(MediaQuery.of(context).size.width < 768 ? 16 : 24),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildFieldLabel("Flashcard Name (Question)", text),
              _buildTextField(_nameController, "e.g. Newton's Second Law", text, cardBg),
              const SizedBox(height: 24),
              _buildFieldLabel("Description (Answer)", text),
              _buildTextField(_descController, "e.g. F = ma", text, cardBg, maxLines: 4),
              const SizedBox(height: 24),
              _buildDropdown(text, cardBg, isDark),
              const SizedBox(height: 24),
              _buildFieldLabel("Topic / Set Name", text),
              _buildTextField(_topicController, "e.g. Vocabulary Set 1", text, cardBg),
              const SizedBox(height: 48),
              SizedBox(
                width: double.infinity,
                height: 60,
                child: ElevatedButton(
                  onPressed: _isSubmitting ? null : _createCard,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.teal,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                    elevation: 0,
                  ),
                  child: _isSubmitting 
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text("Create Flashcard", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFieldLabel(String label, Color text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8, left: 4),
      child: Text(label, style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: text.withOpacity(0.6))),
    );
  }

  Widget _buildTextField(TextEditingController controller, String hint, Color text, Color cardBg, {int maxLines = 1}) {
    return TextFormField(
      controller: controller,
      maxLines: maxLines,
      style: TextStyle(color: text),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: TextStyle(color: text.withOpacity(0.3)),
        filled: true,
        fillColor: cardBg,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: text.withOpacity(0.05)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: Colors.teal, width: 2),
        ),
      ),
      validator: (value) => value == null || value.isEmpty ? "Required" : null,
    );
  }

  Widget _buildDropdown(Color text, Color cardBg, bool isDark) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: text.withOpacity(0.05)),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: _selectedSubject,
          isExpanded: true,
          dropdownColor: isDark ? const Color(0xFF2C2C2C) : Colors.white,
          onChanged: (String? newValue) {
            setState(() {
              _selectedSubject = newValue!;
            });
          },
          items: _subjects.map<DropdownMenuItem<String>>((String value) {
            return DropdownMenuItem<String>(
              value: value,
              child: Text(value.toUpperCase(), style: TextStyle(color: text, fontWeight: FontWeight.bold, fontSize: 13)),
            );
          }).toList(),
        ),
      ),
    );
  }
}
