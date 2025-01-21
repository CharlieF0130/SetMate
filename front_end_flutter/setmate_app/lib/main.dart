import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Stage 1 Demo',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: const HelloPage(),
    );
  }
}

class HelloPage extends StatefulWidget {
  const HelloPage({super.key});

  @override
  _HelloPageState createState() => _HelloPageState();
}

class _HelloPageState extends State<HelloPage> {
  String _message = "Press the button to call backend!";

  // Function to call the backend API
  Future<void> _callBackend() async {
    try {
      final response = await http.get(Uri.parse('http://127.0.0.1:8089/api/hello'));

      if (response.statusCode == 200) {
        setState(() {
          _message = response.body;
        });
      } else {
        setState(() {
          _message = "Failed to call backend: ${response.statusCode}";
        });
      }
    } catch (e) {
      setState(() {
        _message = "Error: $e";
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Stage 1 Demo"),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              _message,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 18),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _callBackend,
              child: const Text("Call Backend"),
            ),
          ],
        ),
      ),
    );
  }
}
