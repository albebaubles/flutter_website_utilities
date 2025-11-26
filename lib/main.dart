import 'dart:convert';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:xml/xml.dart' as xml;

import 'colors.dart';
import 'markup.dart';
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
  final TextEditingController _textInputController = TextEditingController();
  final ScrollController _outputScrollController = ScrollController();
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
    _textInputController.addListener(_onTextChanged);
  }

  void _onTextChanged() {
    _markup.raw = _textInputController.text.trim();
  }

  @override
  void dispose() {
    _outputScrollController.dispose();
    _textInputController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return WatermarkLogo(
      child: Scaffold(
        appBar: AppBar(
          title: Text(_titleText),
          backgroundColor: kABMain,
          actions: [
            _formatSelection(),
            const Spacer(),
            Tooltip(
              message: 'Format',
              child: ElevatedButton(
                onPressed: _selectedFormat[0] ? _formatPrettyJson : _formatPrettyXml,
                child: const Icon(Icons.format_indent_increase_sharp, size: 24),
              ),
            ),
            Tooltip(
              message: 'Compact',
              child: ElevatedButton(
                onPressed: _selectedFormat[0] ? _formatMiniJson : _formatMinifyXml,
                child: const Icon(Icons.format_indent_decrease_sharp, size: 24),
              ),
            ),
            const SizedBox(width: 8),
            Tooltip(
              message: 'Copy to Clipboard',
              child: ElevatedButton(
                onPressed: _copyOutput,
                child: const Icon(Icons.copy_all, size: 24),
              ),
            ),
            Tooltip(
              message: 'Clear',
              child: ElevatedButton(
                onPressed: _clear,
                child: const Icon(Icons.clear_all, size: 24),
              ),
            ),
            const Spacer(flex: 3),
            IconButton(
              icon: Icon(
                Icons.horizontal_split,
                color: _isHorizontal ? Colors.yellow : Colors.white,
              ),
              onPressed: () => setState(() => _isHorizontal = true),
            ),
            IconButton(
              icon: Icon(
                Icons.vertical_split,
                color: !_isHorizontal ? Colors.yellow : Colors.white,
              ),
              onPressed: () => setState(() => _isHorizontal = false),
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
      isSelected: _selectedFormat,
      onPressed: (index) {
        setState(() {
          _selectedFormat = [index == 0, index != 0];
          _textInputController.text = index == 0
              ? '[{"author": "Albebaubles", "framework": "Flutter", "language": "Dart"}]'
              : '<root><row><author>Albebaubles</author><framework>Flutter</framework><language>Dart</language></row></root>';
          _markup.raw = _textInputController.text.trim();
        });
      },
      children: [
        Text("JSON", style: TextStyle(color: _selectedFormat[0] ? Colors.yellow : Colors.white)),
        Text("XML", style: TextStyle(color: !_selectedFormat[0] ? Colors.yellow : Colors.white)),
      ],
    );
  }

  TextField rawTextField() {
    return TextField(
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
      children: [
        Expanded(
          flex: 2,
          child: Padding(
            padding: const EdgeInsets.all(8),
            child: rawTextField(),
          ),
        ),
        Expanded(
          flex: 3,
          child: Scrollbar(
            controller: _outputScrollController,
            thumbVisibility: true,
            child: SingleChildScrollView(
              controller: _outputScrollController,
              child: SelectableText(_formattedText),
            ),
          ),
        ),
        Container(
          color: kABMainLight2,
          height: 30,
          alignment: Alignment.centerRight,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Text(
            '$_size bytes',
            style: const TextStyle(color: Colors.white),
          ),
        ),
      ],
    );
  }

  Widget _buildColumnLayout() {
    return Row(
      children: [
        Expanded(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: rawTextField(),
          ),
        ),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Scrollbar(
              controller: _outputScrollController,
              thumbVisibility: true,
              child: SingleChildScrollView(
                controller: _outputScrollController,
                child: SelectableText(_formattedText),
              ),
            ),
          ),
        ),
        Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Text('$_size bytes', style: const TextStyle(color: Colors.black)),
            const SizedBox(height: 16),
          ],
        ),
      ],
    );
  }

  void _formatPrettyJson() => _applyFormatting(_markup.prettyJson());

  void _formatMiniJson() => _applyFormatting(_markup.miniJson());

  void _formatPrettyXml() => _applyFormatting(_markup.prettyXml());

  void _formatMinifyXml() => _applyFormatting(_markup.miniXml());

  void _applyFormatting(String formatted) {
    setState(() {
      _formattedText = formatted;
      _errorText = (formatted.contains('invalid') || formatted.contains('error')) ? 'Invalid input' : '';
      _size = _formatter.format(utf8.encode(formatted).length);
    });
  }

  void _copyOutput() {
    Clipboard.setData(ClipboardData(text: _formattedText));
  }

  void _clear() {
    _textInputController.clear();
    setState(() {
      _formattedText = '';
      _errorText = '';
      _size = '0';
    });
  }
}