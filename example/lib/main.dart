import 'package:flutter/material.dart';
import 'package:ngrok_flutter/ngrok_flutter.dart';

void main() {
  runApp(
    const MaterialApp(debugShowCheckedModeBanner: false, home: NgrokTestApp()),
  );
}

class NgrokTestApp extends StatefulWidget {
  const NgrokTestApp({super.key});

  @override
  State<NgrokTestApp> createState() => _NgrokTestAppState();
}

class _NgrokTestAppState extends State<NgrokTestApp> {
  final _tokenController = TextEditingController();
  final _portController = TextEditingController(text: '8080');
  String _status = 'Idle';
  bool _isLoading = false;

  Future<void> _start() async {
    if (_tokenController.text.trim().isEmpty) {
      setState(() => _status = 'Please enter an ngrok authtoken');
      return;
    }

    setState(() {
      _isLoading = true;
      _status = 'Connecting to Ngrok...';
    });

    try {
      final port = int.tryParse(_portController.text) ?? 8080;
      final url = await NgrokFlutter.startTunnel(
        authtoken: _tokenController.text.trim(),
        localPort: port,
      );
      setState(() => _status = 'Tunnel active:\n$url');
    } catch (e) {
      setState(() => _status = 'Error: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Ngrok Flutter Demo')),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextField(
              controller: _tokenController,
              decoration: const InputDecoration(
                labelText: 'Ngrok Auth Token',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _portController,
              decoration: const InputDecoration(
                labelText: 'Local Port to Forward',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _isLoading ? null : _start,
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.all(16),
              ),
              child: _isLoading
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Text('Start Ngrok Tunnel'),
            ),
            const SizedBox(height: 28),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.grey.shade300),
              ),
              child: SelectableText(
                _status,
                style: const TextStyle(fontSize: 15, fontFamily: 'monospace'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
