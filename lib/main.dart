import 'package:intl/intl.dart';
import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:flutter/services.dart';

void main() {
  runApp(const WebUtilitiesApp());
}

class WebUtilitiesApp extends StatelessWidget {
  const WebUtilitiesApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Web Utilities',
      theme: ThemeData(primarySwatch: Colors.blueGrey),
      home: const WebUtitilitiesMain(),
    );
  }
}

class WebUtitilitiesMain extends StatefulWidget {
  const WebUtitilitiesMain({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _WebUtitilitiesMainState createState() => _WebUtitilitiesMainState();
}

class _WebUtitilitiesMainState extends State<WebUtitilitiesMain> {
  final TextEditingController _jsonController = TextEditingController(
      text:
          '[{"framework": "Flutter","language": "Dart","author": "Albebaubles"}]');
  var formatter = NumberFormat('#,###,##0');

  String _formattedJson = '';
  String _errorText = '';
  String _size = '0';
  String _titleText = 'JSON Formatter';
  var _isVertical = true;
  int _selectedIndex = 0;

  void _formatPrettyJson() {
    final inputJson = _jsonController.text;
    try {
      final dynamic parsedJson = jsonDecode(inputJson);
      final formattedJson =
          const JsonEncoder.withIndent('  ').convert(parsedJson);
      _setState(formattedJson,
          formatter.format(utf8.encode(formattedJson).length), '');
    } catch (e) {
      _setState('', '0', 'Invalid JSON format');
    }
  }

  void _formatMiniJson() {
    final inputJson = _jsonController.text;
    try {
      final dynamic parsedJson = jsonDecode(inputJson);
      var formattedJson = const JsonEncoder.withIndent('').convert(parsedJson);
      formattedJson = formattedJson.replaceAll("\t", "");
      formattedJson = formattedJson.replaceAll("\n", "");
      _setState(formattedJson,
          formatter.format(utf8.encode(formattedJson).length), '');
    } catch (e) {
      _setState('', '0', 'Invalid JSON format');
    }
  }

  void _setState(String formattedString, String size, String errorText) {
    setState(() {
      _errorText = errorText;
      _formattedJson = formattedString;
      _size = size;
    });
  }

  void _copyOutput() {
    Clipboard.setData(ClipboardData(text: _formattedJson));
  }

  void _clear() {
    setState(() {
      _formattedJson = '';
      _size = '0';
      _errorText = '';
    });
    _jsonController.clear();
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          title: Text(_titleText),
          // leading: IconButton(
          //   onPressed: () {},
          //   icon: const Icon(Icons.menu),
          // ),
          actions: [
            IconButton(
              icon: const Icon(Icons.vertical_split, color: Colors.white),
              onPressed: () {
                _isVertical = true;
              },
            ),
            IconButton(
                icon: const Icon(Icons.horizontal_split, color: Colors.white),
                onPressed: () {
                  _isVertical = false;
                }),
            const SizedBox(width: 16),
          ]),
      drawer: Drawer(
        // Add a ListView to the drawer. This ensures the user can scroll
        // through the options in the drawer if there isn't enough vertical
        // space to fit everything.
        child: ListView(
          // Important: Remove any padding from the ListView.
          padding: EdgeInsets.zero,
          children: [
            const DrawerHeader(
              decoration: BoxDecoration(
                color: Colors.blueGrey,
              ),
              child: Text('Utilities'),
            ),
            ListTile(
              title: const Text('JSON'),
              selected: _selectedIndex == 0,
              onTap: () {
                // Update the state of the app
                // _onItemTapped(0);
                // Then close the drawer
                Navigator.pop(context);
              },
            ),
            ListTile(
              title: const Text('XML'),
              selected: _selectedIndex == 1,
              onTap: () {
                // Update the state of the app
                // _onItemTapped(1);
                // Then close the drawer
                Navigator.pop(context);
              },
            ),
          ],
        ),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              controller: _jsonController,
              maxLines: 10,
              decoration: InputDecoration(
                hintText: 'Enter JSON here...',
                errorText: _errorText.isNotEmpty ? _errorText : null,
              ),
            ),
          ),
          Row(
            children: [
              const SizedBox(width: 16),
              ElevatedButton(
                onPressed: _formatPrettyJson,
                child: const Text('Pretty JSON'),
              ),
              const SizedBox(width: 16),
              ElevatedButton(
                onPressed: _formatMiniJson,
                child: const Text('Minify JSON'),
              ),
              const Spacer(),
              ElevatedButton(
                onPressed: _copyOutput,
                child: const Icon(
                  Icons.copy_all,
                  size: 24.0,
                ),
              ),
              const SizedBox(width: 16),
              ElevatedButton(
                onPressed: _clear,
                child: const Icon(
                  Icons.clear_all,
                  size: 24.0,
                ),
              ),
              const SizedBox(width: 16),
            ],
          ),
          const SizedBox(height: 16),
          Expanded(
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Text(
                  _formattedJson,
                ),
              ),
            ),
          ),
          Container(
            color: Colors.blueGrey,
            child: Row(
              children: [
                const Spacer(),
                Padding(
                  padding: const EdgeInsets.all(1.0),
                  child: Text(
                    "$_size bytes",
                    style: TextStyle(color: Colors.white),
                  ),
                ),
                const SizedBox(width: 16),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
