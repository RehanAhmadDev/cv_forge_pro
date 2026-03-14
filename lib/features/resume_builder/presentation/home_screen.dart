import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../data/resume_model.dart';
import 'template_selection_screen.dart';
import 'resume_form_screen.dart'; // ⬅️ NAYA IMPORT: Editor screen yahan connect ki hai

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<ResumeModel> savedProfiles = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadProfiles();
  }

  // Database se saari CVs load karna
  Future<void> _loadProfiles() async {
    setState(() => isLoading = true);
    final prefs = await SharedPreferences.getInstance();
    final String? profilesJson = prefs.getString('cv_profiles_list');

    if (profilesJson != null) {
      final List<dynamic> decodedList = json.decode(profilesJson);
      setState(() {
        savedProfiles = decodedList.map((item) => ResumeModel.fromJson(item)).toList();
        isLoading = false;
      });
    } else {
      setState(() {
        savedProfiles = [];
        isLoading = false;
      });
    }
  }

  // CV delete karne ka logic
  Future<void> _deleteProfile(int index) async {
    bool confirm = await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Delete CV?"),
        content: const Text("Kya aap waqai is profile ko khatam karna chahte hain?"),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text("No")),
          TextButton(onPressed: () => Navigator.pop(context, true), child: const Text("Yes", style: TextStyle(color: Colors.red))),
        ],
      ),
    ) ?? false;

    if (confirm) {
      savedProfiles.removeAt(index);
      final prefs = await SharedPreferences.getInstance();
      final String encodedList = json.encode(savedProfiles.map((e) => e.toJson()).toList());
      await prefs.setString('cv_profiles_list', encodedList);
      _loadProfiles(); // Refresh list
    }
  }

  // Nayi CV banane ke liye template screen par jana
  void _createNewProfile() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const TemplateSelectionScreen()),
    ).then((_) => _loadProfiles());
  }

  // Purani CV open karna
  void _openEditor(ResumeModel model) {
    // ⬅️ ASAL FIX: Ab ye block nahi hai, seedha Editor par le jayega
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ResumeFormScreen(resumeData: model),
      ),
    ).then((_) => _loadProfiles()); // Wapas aane par list auto-update ho jayegi
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: AppBar(
        title: const Text('CV Forge Pro', style: TextStyle(fontWeight: FontWeight.w800)),
        backgroundColor: Colors.blueGrey.shade900,
        foregroundColor: Colors.white,
        centerTitle: true,
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : savedProfiles.isEmpty
          ? Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.document_scanner_outlined, size: 80, color: Colors.blueGrey.shade200),
            const SizedBox(height: 20),
            const Text("No CVs Found", style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
            const Text("Tap + to create your first resume.", style: TextStyle(color: Colors.grey)),
          ],
        ),
      )
          : ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: savedProfiles.length,
        itemBuilder: (context, index) {
          final profile = savedProfiles[index];
          return Card(
            elevation: 2,
            margin: const EdgeInsets.only(bottom: 12),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            child: ListTile(
              contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              leading: CircleAvatar(
                backgroundColor: Colors.blueGrey.shade50,
                child: const Icon(Icons.file_present, color: Colors.blueGrey),
              ),
              // Yahan default naam dikhayega
              title: Text(profile.profileName, style: const TextStyle(fontWeight: FontWeight.bold)),
              subtitle: Text(profile.fullName.isEmpty ? "Name not added" : profile.fullName),
              trailing: IconButton(
                icon: const Icon(Icons.delete_outline, color: Colors.redAccent),
                onPressed: () => _deleteProfile(index),
              ),
              onTap: () => _openEditor(profile),
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _createNewProfile,
        backgroundColor: Colors.blueGrey.shade900,
        foregroundColor: Colors.white,
        icon: const Icon(Icons.add),
        label: const Text("New CV"),
      ),
    );
  }
}