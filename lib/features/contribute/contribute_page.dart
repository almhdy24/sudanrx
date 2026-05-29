import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class ContributePage extends StatelessWidget {
  const ContributePage({super.key});

  Future<void> _launchUrl(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Contribute to SudanRx')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const Card(
            child: Padding(
              padding: EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Join the Community',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'SudanRx is built by Sudanese doctors, pharmacists, and students. '
                    'Your expertise can help improve healthcare across Sudan.',
                    style: TextStyle(fontSize: 16),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),
          const Card(
            child: Padding(
              padding: EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Ways to Contribute',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 12),
                  Text('• Submit or review guidelines', style: TextStyle(fontSize: 16)),
                  SizedBox(height: 8),
                  Text('• Report errors or suggest improvements', style: TextStyle(fontSize: 16)),
                  SizedBox(height: 8),
                  Text('• Help with translations (Arabic/English)', style: TextStyle(fontSize: 16)),
                  SizedBox(height: 8),
                  Text('• Develop the open-source app', style: TextStyle(fontSize: 16)),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Technical Contributions',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    'Flutter app & CodeIgniter backend are open-source. '
                    'Contribute on GitHub:',
                    style: TextStyle(fontSize: 16),
                  ),
                  const SizedBox(height: 12),
                  InkWell(
                    onTap: () => _launchUrl('https://github.com/sudanrx/sudanrx'),
                    child: const Text(
                      'github.com/sudanrx/sudanrx',
                      style: TextStyle(color: Colors.blue, fontSize: 16),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Contact Us',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 12),
                  InkWell(
                    onTap: () => _launchUrl('mailto:contact@sudanrx.org'),
                    child: const Text(
                      'contact@sudanrx.org',
                      style: TextStyle(color: Colors.blue, fontSize: 16),
                    ),
                  ),
                  const SizedBox(height: 8),
                  InkWell(
                    onTap: () => _launchUrl('https://t.me/sudanrx'),
                    child: const Text(
                      'Telegram: @sudanrx',
                      style: TextStyle(color: Colors.blue, fontSize: 16),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
