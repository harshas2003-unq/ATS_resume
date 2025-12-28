import 'dart:io';
import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:path_provider/path_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  MobileAds.instance.initialize();
  runApp(const ATSApp());
}

class ATSApp extends StatelessWidget {
  const ATSApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData.dark(useMaterial3: true),
      home: const HomeScreen(),
    );
  }
}

/* ---------------- HOME ---------------- */

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int index = 0;
  int credits = 0;

  @override
  Widget build(BuildContext context) {
    final pages = [
      const SavedResumesPage(),
      GeneratePage(
        credits: credits,
        onCreditUsed: () => setState(() => credits--),
        onRewardEarned: () => setState(() => credits++),
      ),
      const ProfilePage(),
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text("ATS Resume AI"),
        actions: [
          Padding(
            padding: const EdgeInsets.all(12),
            child: Chip(label: Text("Credits: $credits")),
          )
        ],
      ),
      body: pages[index],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: index,
        onTap: (i) => setState(() => index = i),
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.folder), label: "Resumes"),
          BottomNavigationBarItem(icon: Icon(Icons.auto_fix_high), label: "Generate"),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: "Profile"),
        ],
      ),
    );
  }
}

/* ---------------- SAVED ---------------- */

class SavedResumesPage extends StatelessWidget {
  const SavedResumesPage({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: const [
        Card(child: ListTile(title: Text("ATS_Resume_1.pdf"), subtitle: Text("Score: 92%"))),
        Card(child: ListTile(title: Text("ATS_Resume_2.pdf"), subtitle: Text("Score: 95%"))),
      ],
    );
  }
}

/* ---------------- GENERATE ---------------- */

class GeneratePage extends StatefulWidget {
  final int credits;
  final VoidCallback onCreditUsed;
  final VoidCallback onRewardEarned;

  const GeneratePage({
    super.key,
    required this.credits,
    required this.onCreditUsed,
    required this.onRewardEarned,
  });

  @override
  State<GeneratePage> createState() => _GeneratePageState();
}

class _GeneratePageState extends State<GeneratePage> {
  RewardedAd? rewardedAd;
  bool loading = false;

  final companyCtrl = TextEditingController();
  final jdCtrl = TextEditingController();

  void loadAd() {
    RewardedAd.load(
      adUnitId: 'ca-app-pub-3940256099942544/5224354917', // TEST ID
      request: const AdRequest(),
      rewardedAdLoadCallback: RewardedAdLoadCallback(
        onAdLoaded: (ad) => rewardedAd = ad,
        onAdFailedToLoad: (_) => rewardedAd = null,
      ),
    );
  }

  Future<void> generatePDF() async {
    setState(() => loading = true);

    final pdf = pw.Document();
    pdf.addPage(
      pw.Page(
        build: (_) => pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.Text("ATS Optimized Resume", style: pw.TextStyle(fontSize: 20)),
            pw.SizedBox(height: 10),
            pw.Text("Company: ${companyCtrl.text}"),
            pw.SizedBox(height: 10),
            pw.Text("Skills: Flutter, Firebase, REST API, Git"),
            pw.SizedBox(height: 10),
            pw.Text("Experience: Software Developer"),
            pw.SizedBox(height: 10),
            pw.Text("ATS Score: 92%"),
          ],
        ),
      ),
    );

    final dir = await getApplicationDocumentsDirectory();
    final file = File("${dir.path}/ATS_Resume.pdf");
    await file.writeAsBytes(await pdf.save());

    widget.onCreditUsed();
    setState(() => loading = false);

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Resume Generated"),
        content: const Text("ATS Score: 92%\nPDF saved successfully."),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("OK"))
        ],
      ),
    );
  }

  void onGenerate() {
    if (widget.credits > 0) {
      generatePDF();
    } else {
      loadAd();
      rewardedAd?.show(
        onUserEarnedReward: (_, __) {
          widget.onRewardEarned();
          generatePDF();
        },
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          TextField(
            controller: companyCtrl,
            decoration: const InputDecoration(labelText: "Company Name"),
          ),
          const SizedBox(height: 10),
          TextField(
            controller: jdCtrl,
            maxLines: 4,
            decoration: const InputDecoration(labelText: "Job Description"),
          ),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: loading ? null : onGenerate,
            child: loading
                ? const CircularProgressIndicator()
                : const Text("Generate ATS Resume"),
          ),
        ],
      ),
    );
  }
}

/* ---------------- PROFILE ---------------- */

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: const [
        CircleAvatar(radius: 40, child: Icon(Icons.person, size: 40)),
        SizedBox(height: 10),
        Center(child: Text("Harsha", style: TextStyle(fontSize: 18))),
        Center(child: Text("harsha@email.com")),
        Divider(),
        ListTile(leading: Icon(Icons.feedback), title: Text("Send Feedback")),
        ListTile(leading: Icon(Icons.info), title: Text("About App")),
        ListTile(leading: Icon(Icons.logout), title: Text("Sign Out")),
      ],
    );
  }
}
