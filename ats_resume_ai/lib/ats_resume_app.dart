import 'dart:math';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';

void main() {
  runApp(const ATSResumeApp());
}

class ATSResumeApp extends StatelessWidget {
  const ATSResumeApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData.dark(useMaterial3: true),
      home: const MainScreen(),
    );
  }
}

/* ================= MAIN SCREEN ================= */

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int index = 0;
  int credits = 120;

  final generateKey = GlobalKey<GenerateATSPageState>();

  @override
  Widget build(BuildContext context) {
    final pages = [
      const SavedResumesPage(),
      GenerateATSPage(
        key: generateKey,
        onCreditUsed: () => setState(() => credits--),
      ),
      ProfilePage(credits: credits),
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text("ATS Resume AI"),
        actions: [
          Padding(
            padding: const EdgeInsets.all(12),
            child: Chip(
              label: Text("Credits: $credits"),
              avatar: const Icon(Icons.bolt),
            ),
          )
        ],
      ),
      body: Stack(
        children: [
          pages[index],

          /* ===== GLOBAL GLOW BUTTON ===== */
          Positioned(
            bottom: 20,
            left: 20,
            right: 20,
            child: GestureDetector(
              onTap: index == 1
                  ? () => generateKey.currentState?.generateATS()
                  : null,
              child: Opacity(
                opacity: index == 1 ? 1 : 0.4,
                child: Container(
                  height: 56,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(30),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.blueAccent.withOpacity(0.8),
                        blurRadius: 20,
                        spreadRadius: 2,
                      ),
                    ],
                    gradient: const LinearGradient(
                      colors: [Colors.blueAccent, Colors.purpleAccent],
                    ),
                  ),
                  child: const Center(
                    child: Text(
                      "Generate ATS Resume",
                      style: TextStyle(
                          fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: index,
        onTap: (i) => setState(() => index = i),
        items: const [
          BottomNavigationBarItem(
              icon: Icon(Icons.folder), label: "Resumes"),
          BottomNavigationBarItem(
              icon: Icon(Icons.upload_file), label: "Upload"),
          BottomNavigationBarItem(
              icon: Icon(Icons.person), label: "Profile"),
        ],
      ),
    );
  }
}

/* ================= SAVED RESUMES ================= */

class SavedResumesPage extends StatelessWidget {
  const SavedResumesPage({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: List.generate(3, (i) {
        return Card(
          child: ListTile(
            leading: const Icon(Icons.picture_as_pdf),
            title: Text("ATS_Resume_${i + 1}.pdf"),
            subtitle: const Text("ATS Score: 96%"),
            trailing: const Icon(Icons.download),
          ),
        );
      }),
    );
  }
}

/* ================= GENERATE ATS ================= */

class GenerateATSPage extends StatefulWidget {
  final VoidCallback onCreditUsed;
  const GenerateATSPage(
      {super.key, required this.onCreditUsed});

  @override
  GenerateATSPageState createState() => GenerateATSPageState();
}

class GenerateATSPageState extends State<GenerateATSPage> {
  String? fileName;
  bool loading = false;
  int? atsScore;

  final companyCtrl = TextEditingController();
  final jdCtrl = TextEditingController();

  Future<void> pickPDF() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf'],
    );
    if (result != null) {
      setState(() => fileName = result.files.single.name);
    }
  }

  Future<void> generateATS() async {
    if (fileName == null || loading) return;

    setState(() {
      loading = true;
      atsScore = null;
    });

    await Future.delayed(const Duration(seconds: 3));

    setState(() {
      atsScore = 95 + Random().nextInt(5);
      loading = false;
    });

    widget.onCreditUsed();
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
      child: Column(
        children: [
          ElevatedButton.icon(
            onPressed: pickPDF,
            icon: const Icon(Icons.upload),
            label: const Text("Upload Resume PDF"),
          ),
          if (fileName != null)
            Padding(
              padding: const EdgeInsets.all(8),
              child: Text("Uploaded: $fileName"),
            ),
          const SizedBox(height: 12),
          TextField(
            controller: companyCtrl,
            decoration: const InputDecoration(
              labelText: "Company Name",
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: jdCtrl,
            maxLines: 4,
            decoration: const InputDecoration(
              labelText: "Job Description",
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 20),
          if (loading) const CircularProgressIndicator(),
          if (atsScore != null) ...[
            const SizedBox(height: 20),
            Text("ATS Score: $atsScore%",
                style: const TextStyle(fontSize: 22)),
            const SizedBox(height: 8),
            const Text("Chances of Selection: HIGH ✅",
                style: TextStyle(color: Colors.greenAccent)),
            const SizedBox(height: 12),
            ElevatedButton.icon(
              onPressed: () {},
              icon: const Icon(Icons.download),
              label: const Text("Download ATS Resume PDF"),
            ),
          ]
        ],
      ),
    );
  }
}

/* ================= PROFILE ================= */

class ProfilePage extends StatelessWidget {
  final int credits;
  const ProfilePage({super.key, required this.credits});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        const CircleAvatar(radius: 40, child: Icon(Icons.person, size: 40)),
        const SizedBox(height: 10),
        const Center(child: Text("Harsha", style: TextStyle(fontSize: 18))),
        const Center(child: Text("harsha@email.com")),
        const Divider(height: 30),
        ListTile(
          leading: const Icon(Icons.bolt),
          title: const Text("Credits Balance"),
          trailing: Text("$credits"),
        ),
        const ListTile(
            leading: Icon(Icons.feedback), title: Text("Send Feedback")),
        const ListTile(
            leading: Icon(Icons.info),
            title: Text("About"),
            subtitle: Text("ATS Resume AI App")),
        const ListTile(
            leading: Icon(Icons.logout), title: Text("Sign Out")),
      ],
    );
  }
}
