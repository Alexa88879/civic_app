import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class UpdateChecker {
  static const String currentVersion = '1.0.0'; // Your current app version
  static const String versionUrl = 'https://raw.githubusercontent.com/Alexa88879/civic_app/main/version.json';

  static Future<void> checkForUpdate(BuildContext context) async {
    try {
      final response = await http.get(Uri.parse(versionUrl));
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final latestVersion = data['version'];
        final apkUrl = data['apk_url'];

        if (_isNewerVersion(latestVersion, currentVersion)) {
          // 🔐 Guard context use
          if (!context.mounted) return;

          showDialog(
            context: context,
            builder: (ctx) => AlertDialog(
              title: const Text('Update Available'),
              content: Text('A new version ($latestVersion) is available.'),
              actions: [
                TextButton(
                  child: const Text('Later'),
                  onPressed: () => Navigator.of(ctx).pop(),
                ),
                ElevatedButton(
                  child: const Text('Update Now'),
                  onPressed: () {
                    Navigator.of(ctx).pop();
                    _launchApkUrl(apkUrl);
                  },
                ),
              ],
            ),
          );
        }
      }
    } catch (e) {
      debugPrint('Version check failed: $e');
    }
  }

  static bool _isNewerVersion(String latest, String current) {
    final latestParts = latest.split('.').map(int.parse).toList();
    final currentParts = current.split('.').map(int.parse).toList();

    for (int i = 0; i < latestParts.length; i++) {
      if (i >= currentParts.length || latestParts[i] > currentParts[i]) return true;
      if (latestParts[i] < currentParts[i]) return false;
    }
    return false;
  }

  static void _launchApkUrl(String url) async {
    // Open the download URL using url_launcher
    // You must add url_launcher to pubspec.yaml and import it here:
    // import 'package:url_launcher/url_launcher.dart';
  }
}
