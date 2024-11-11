import 'package:deep_link_requester/preference.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Deep Link Tester',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const DeepLinkTester(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class DeepLinkTester extends StatefulWidget {
  const DeepLinkTester({super.key});

  @override
  _DeepLinkTesterState createState() => _DeepLinkTesterState();
}

class _DeepLinkTesterState extends State<DeepLinkTester> {
  final TextEditingController _schemeController = TextEditingController();
  final TextEditingController _hostController = TextEditingController();
  final TextEditingController _pathController = TextEditingController();
  final TextEditingController _queryController = TextEditingController();

  final List<String> _history = [];

  @override
  void initState() {
    super.initState();
    loadUriHistory().then((value) {
      setState(() {
        _history.addAll(value);
      });
    });
  }

  Future<void> _launchDeepLink() async {
    final String scheme = _schemeController.text;
    final String host = _hostController.text;
    final String path = _pathController.text;
    final String query = _queryController.text;

    Uri uri = Uri(
      scheme: scheme,
      host: host,
      path: path,
      query: query,
    );

    try {
      await launchUrl(uri);
    } catch (e) {
      print(e);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Could not launch $e')),
      );
    }
    _addToHistory(uri.toString());
  }

  void _addToHistory(String uri) async {
    setState(() {
      if (!_history.contains(uri)) {
        _history.insert(0, uri);
      }
    });
    await saveUriHistory(_history);
  }

  void _reLaunchFromHistory(String uriString) async {
    Uri uri = Uri.parse(uriString);
    try {
      await launchUrl(uri);
    } catch (e) {
      print(e);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Could not launch $e')),
      );
    }
  }

  void _copyToTextFields(String uriString) {
    Uri uri = Uri.parse(uriString);
    setState(() {
      _schemeController.text = uri.scheme;
      _hostController.text = uri.host;
      _pathController.text = uri.path;
      _queryController.text = uri.query;
    });
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Copied to input fields')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Deep Link Tester'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _schemeController,
              decoration:
                  const InputDecoration(labelText: 'Scheme (e.g., myapp)'),
            ),
            TextField(
              controller: _hostController,
              decoration:
                  const InputDecoration(labelText: 'Host (e.g., example.com)'),
            ),
            TextField(
              controller: _pathController,
              decoration:
                  const InputDecoration(labelText: 'Path (e.g., /second)'),
            ),
            TextField(
              controller: _queryController,
              decoration: const InputDecoration(
                  labelText: 'Query (e.g., name=test&age=123)'),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _launchDeepLink,
              child: const Text('Launch Deep Link'),
            ),
            const SizedBox(height: 24),
            Expanded(
              child: ListView.builder(
                itemCount: _history.length,
                itemBuilder: (context, index) {
                  final uri = _history[index];
                  return ListTile(
                    title: Text(uri),
                    onTap: () => _reLaunchFromHistory(uri),
                    trailing: IconButton(
                      icon: const Icon(Icons.copy),
                      onPressed: () => _copyToTextFields(uri),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
