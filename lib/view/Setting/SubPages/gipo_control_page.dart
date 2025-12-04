import 'dart:io';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:http/http.dart' as http;

import 'package:install_plugin_v3/install_plugin_v3.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:path_provider/path_provider.dart';

class GPIOControlsPage extends StatefulWidget {
  const GPIOControlsPage({super.key});

  @override
  State<GPIOControlsPage> createState() => _GPIOControlsPageState();
}

class _GPIOControlsPageState extends State<GPIOControlsPage> {
  bool checking = false;
  bool updateAvailable = false;
  String description = "";
  String apkUrl = "";
  String latestVersion = "";
  String currentVersion = "";
  double progress = 0;
  bool downloading = false;

  @override
  void initState() {
    super.initState();
    checkForUpdate();
  }

  Future<void> checkForUpdate() async {
    setState(() => checking = true);

    try {
      final query = await FirebaseFirestore.instance
          .collection("activeVersions")
          .orderBy("uploadedAt", descending: true)
          .limit(1)
          .get();

      if (query.docs.isEmpty) {
        setState(() => checking = false);
        return;
      }

      final doc = query.docs.first;

      latestVersion = doc["versionName"];
      apkUrl = doc["fileUrl"];
      description = doc["description"];

      PackageInfo info = await PackageInfo.fromPlatform();
      currentVersion = info.version;

      if (latestVersion.trim() != currentVersion.trim()) {
        setState(() => updateAvailable = true);
      }
    } catch (e) {
      debugPrint("Update check failed: $e");
    }

    setState(() => checking = false);
  }

  Future<void> downloadAndInstallApk() async {
    setState(() => downloading = true);

    try {
      final dir = await getExternalStorageDirectory();
      final filePath = "${dir!.path}/update.apk";

      final request = await HttpClient().getUrl(Uri.parse(apkUrl));
      final response = await request.close();

      final file = File(filePath);
      final raf = file.openSync(mode: FileMode.write);

      final contentLength = response.contentLength;
      int downloaded = 0;

      await for (var chunk in response) {
        downloaded += chunk.length;
        raf.writeFromSync(chunk);

        setState(() {
          progress = downloaded / contentLength;
        });
      }

      await raf.close();

      // Install APK
      final res = await InstallPlugin.installApk(filePath);
      if (res['isSuccess'] == true) {
        setState(() => downloading = false);
      } else {
        setState(() => downloading = false);
      }
    } catch (e) {
      debugPrint("APK Download error: $e");
      setState(() => downloading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text("App Update"),
        elevation: 0,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black87,
      ),
      body: checking
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: updateAvailable
                    ? _buildUpdateAvailable()
                    : _buildUpToDate(),
              ),
            ),
    );
  }

  Widget _buildUpdateAvailable() {
    return Column(
      children: [
        const SizedBox(height: 20),
        // Update Icon
        Container(
          width: 120,
          height: 120,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.blue[400]!, Colors.blue[600]!],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: Colors.blue.withOpacity(0.3),
                blurRadius: 20,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: const Icon(
            Icons.system_update,
            size: 60,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 30),

        // Version Card
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 10,
                offset: const Offset(0, 5),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                "New Version Available",
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  _buildVersionChip(
                      currentVersion, Colors.grey[300]!, Colors.black54),
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 8),
                    child:
                        Icon(Icons.arrow_forward, size: 20, color: Colors.grey),
                  ),
                  _buildVersionChip(
                      latestVersion, Colors.blue[50]!, Colors.blue[700]!),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),

        // What's New Card
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 10,
                offset: const Offset(0, 5),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(Icons.new_releases, color: Colors.amber[700], size: 24),
                  const SizedBox(width: 8),
                  const Text(
                    "What's New",
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Text(
                description,
                style: TextStyle(
                  fontSize: 15,
                  color: Colors.grey[700],
                  height: 1.5,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 30),

        // Download Button or Progress
        downloading
            ? Container(
                width: double.infinity,
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 10,
                      offset: const Offset(0, 5),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    Text(
                      "Downloading Update",
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Colors.grey[800],
                      ),
                    ),
                    const SizedBox(height: 16),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: LinearProgressIndicator(
                        value: progress,
                        minHeight: 8,
                        backgroundColor: Colors.grey[200],
                        valueColor:
                            AlwaysStoppedAnimation<Color>(Colors.blue[600]!),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      "${(progress * 100).toStringAsFixed(0)}%",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.blue[700],
                      ),
                    ),
                  ],
                ),
              )
            : SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: downloadAndInstallApk,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue[600],
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    shadowColor: Colors.blue.withOpacity(0.5),
                  ),
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.download, size: 24),
                      SizedBox(width: 12),
                      Text(
                        "Download & Install",
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
        const SizedBox(height: 40),
      ],
    );
  }

  Widget _buildUpToDate() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const SizedBox(height: 60),
          Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.green[400]!, Colors.green[600]!],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: Colors.green.withOpacity(0.3),
                  blurRadius: 20,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: const Icon(
              Icons.check_circle,
              size: 60,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 30),
          const Text(
            "You're All Set!",
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            "Your app is up to date",
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 40),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            decoration: BoxDecoration(
              color: Colors.green[50],
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              "Version $currentVersion",
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Colors.green[700],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildVersionChip(String version, Color bgColor, Color textColor) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        "v$version",
        style: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          color: textColor,
        ),
      ),
    );
  }
}
