import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:xml/xml.dart' as xml;

import 'markup.dart';
import 'colors.dart';
import 'watermark.dart';

void main() => runApp(const WebUtilitiesApp());

class WebUtilitiesApp extends StatelessWidget {
  const WebUtilitiesApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Dev Utilities',
      theme: ThemeData(primarySwatch: kABMainLight3.toMaterialColor()),
      home: const WebUtilitiesMain(),
    );
  }
}

class WebUtilitiesMain extends StatefulWidget {
  const WebUtilitiesMain({super.key});

  @override
  _WebUtilitiesMainState createState() => _WebUtilitiesMainState();
}

class _WebUtilitiesMainState extends State<WebUtilitiesMain> {
  final _focusNode = FocusNode();
  final TextEditingController _textInputController = TextEditingController();
  final _markup = Markup('');
  final _formatter = NumberFormat('#,###,##0');

  String _formattedText = '';
  String _errorText = '';
  String _size = '0';
  final String _titleText = 'File Parser Validation';
  bool _isHorizontal = true;
  List<bool> _selectedFormat = <bool>[true, false];

  @override
  void initState() {
    super.initState();

    _textInputController.addListener(() {
      _markup.raw = _textInputController.text.trim();
    });
  }

  @override
  void dispose() {
    _focusNode.dispose();
    _textInputController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return WatermarkLogo(
      child: Scaffold(
        appBar: AppBar(
          title: Text(_titleText.trim()),
          backgroundColor: kABMain,
          actions: [
            _formatSelection(),
            const SizedBox(width: 8),
            Tooltip(
              message: 'Format',
              child: ElevatedButton(
                onPressed: _selectedFormat[0] ? _formatPrettyJson : _formatPrettyXml,
                child: const Icon(Icons.format_indent_increase_sharp, size: 24.0),
              ),
            ),
            Tooltip(
              message: 'Compact',
              child: ElevatedButton(
                onPressed: _selectedFormat[0] ? _formatMiniJson : _formatMinifyXml,
                child: const Icon(Icons.format_indent_decrease_sharp, size: 24.0),
              ),
            ),
            const SizedBox(width: 8),
            Tooltip(
              message: 'Copy to Clipboard',
              child: ElevatedButton(
                onPressed: _copyOutput,
                child: const Icon(Icons.copy_all, size: 24.0),
              ),
            ),
            Tooltip(
              message: 'Clear',
              child: ElevatedButton(
                onPressed: _clear,
                child: const Icon(Icons.clear_all, size: 24.0),
              ),
            ),
            IconButton(
              icon: Icon(Icons.horizontal_split,
                  color: _isHorizontal ? Colors.yellow : Colors.white),
              onPressed: () {
                setState(() {
                  _isHorizontal = true;
                });
              },
            ),
            IconButton(
              icon: Icon(Icons.vertical_split,
                  color: !_isHorizontal ? Colors.yellow : Colors.white),
              onPressed: () {
                setState(() {
                  _isHorizontal = false;
                });
              },
            ),
            const SizedBox(width: 16),
          ],
        ),
        body: _isHorizontal ? _buildRowLayout() : _buildColumnLayout(),
      ),
    );
  }

  ToggleButtons _formatSelection() {
    return ToggleButtons(
      color: kABMainLight3,
      direction: Axis.horizontal,
      isSelected: _selectedFormat,
      onPressed: (int index) {
        setState(() {
          _selectedFormat = [index == 0, index == 1];

          _textInputController.text = index == 0
              ? '[{"author": "Albebaubles", "framework": "Flutter", "language": "Dart", "source" : "https://github.com/albebaubles/flutter_website_utilities"}]'
              : '<root><row><author>Albebaubles</author><framework>Flutter</framework><language>Dart</language><source>https://github.com/albebaubles/flutter_website_utilities</source></row></root>';

          _markup.raw = _textInputController.text.trim();
        });
      },
      children: [
        Text("JSON",
            style: TextStyle(
                color: _selectedFormat[0] ? Colors.yellow : Colors.white)),
        Text("XML",
            style: TextStyle(
                color: _selectedFormat[1] ? Colors.yellow : Colors.white)),
      ],
    );
  }

  TextField rawText() {
    return TextField(
      focusNode: _focusNode,
      autofocus: true,
      controller: _textInputController,
      maxLines: null,
      decoration: InputDecoration(
        hintText: 'Enter text to format here...',
        errorText: _errorText.isNotEmpty ? _errorText : null,
        border: const OutlineInputBorder(),
      ),
    );
  }

  Widget _buildRowLayout() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Expanded(child: rawText()),
        Expanded(child: SingleChildScrollView(child: Text(_formattedText))),
        Container(
          color: kABMainLight2,
          height: 30,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              FittedBox(
                fit: BoxFit.contain,
                child: Text("$_size bytes",
                    style: const TextStyle(color: Colors.white),
                    textAlign: TextAlign.end),
              ),
              const SizedBox(width: 16),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildColumnLayout() {
    return Row(
      children: [
        Expanded(flex: 5, child: Padding(padding: const EdgeInsets.all(16), child: rawText())),
        Expanded(
            flex: 5,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: SingleChildScrollView(child: Text(_formattedText)),
            )),
        Column(
          children: [
            Text("$_size bytes", style: const TextStyle(color: Colors.black)),
            const SizedBox(height: 16, width: 16),
          ],
        )
      ],
    );
  }

  void _formatPrettyJson() {
    try {
      final pretty = _markup.prettyJson();
      _setState(pretty, _formatter.format(utf8.encode(pretty).length), '');
    } catch (e) {
      _setState('', '0', 'Invalid JSON: $e');
    }
  }

  void _formatMiniJson() {
    try {
      final mini = _markup.miniJson();
      _setState(mini, _formatter.format(utf8.encode(mini).length), '');
    } catch (e) {
      _setState('', '0', 'Invalid JSON: $e');
    }
  }

  void _formatPrettyXml() {
    try {
      final pretty = _markup.prettyXml();
      _setState(pretty, _formatter.format(utf8.encode(pretty).length), '');
    } catch (e) {
      _setState('', '0', 'Invalid XML: $e');
    }
  }

  void _formatMinifyXml() {
    try {
      final mini = _markup.miniXml();
      _setState(mini, _formatter.format(utf8.encode(mini).length), '');
    } catch (e) {
      _setState('', '0', 'Invalid XML: $e');
    }
  }

  void _setState(String formattedString, String size, String errorText) {
    setState(() {
      _errorText = errorText;
      _formattedText = formattedString;
      _size = size;
    });
  }

  void _copyOutput() {
    Clipboard.setData(ClipboardData(text: _formattedText));
  }

  void _clear() {
    _setState('', '0', '');
    _textInputController.clear();
  }
}