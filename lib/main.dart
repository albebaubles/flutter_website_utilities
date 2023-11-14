import 'package:intl/intl.dart';
import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:xml/xml.dart' as xml;

void main() => runApp(const WebUtilitiesApp());

class WebUtilitiesApp extends StatelessWidget {
  const WebUtilitiesApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Dev Utilities',
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
  final TextEditingController _textInputController = TextEditingController(
      text:
          '[{"author": "Albebaubles", "framework": "Flutter", "language": "Dart", "source" : "https://github.com/albebaubles/flutter_website_utilities"}]');
  // <devutilities><author>Albebaubles</author><framework>Flutter</framework><language>Dart</language><source>https://github.com/albebaubles/flutter_website_utilities</source></devutilities>
  var formatter = NumberFormat('#,###,##0');

  String _formattedText = '';
  String _errorText = '';
  String _size = '0';
  final String _titleText = 'File Parser Validation';
  var _isHorizontal = true;
  List<bool> _selectedFormat = <bool>[true, false];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(title: Text(_titleText), actions: [
          _buildToggle(),
          const Spacer(),
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
                  color: _isHorizontal ? Colors.white : Colors.yellow),
              onPressed: () {
                setState(() {
                  _isHorizontal = false;
                });
              }),
          const SizedBox(width: 16),
        ]),
        // drawer: _buildDrawer(),
        body: _isHorizontal ? _buildRowLayout() : _buildColumnJson());
  }

  ToggleButtons _buildToggle() {
    return ToggleButtons(
      direction: Axis.horizontal,
      isSelected: _selectedFormat,
      onPressed: (int index) {
        setState(() {
          _selectedFormat = [index == 0, index != 0];
        });
      },
      children: <Widget>[
        Text("JSON",
            style: TextStyle(
                color:
                    _selectedFormat[0] == true ? Colors.yellow : Colors.white)),
        Text("XML",
            style: TextStyle(
                color:
                    _selectedFormat[0] == false ? Colors.yellow : Colors.white))
      ],
    );
  }

  Column _buildRowLayout() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: TextField(
            controller: _textInputController,
            maxLines: 10,
            decoration: InputDecoration(
              hintText: 'Enter JSON here...',
              errorText: _errorText.isNotEmpty ? _errorText : null,
            ),
          ),
        ),
        _columnActions(true),
        const SizedBox(height: 16),
        Expanded(
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text(_formattedText),
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
                child: Text("$_size bytes",
                    style: const TextStyle(color: Colors.white)),
              ),
              const SizedBox(width: 16),
            ],
          ),
        ),
      ],
    );
  }

  Row _buildColumnJson() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        Expanded(
          flex: 5,
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              controller: _textInputController,
              maxLines: 30,
              decoration: InputDecoration(
                hintText: 'Enter JSON here...',
                errorText: _errorText.isNotEmpty ? _errorText : null,
              ),
            ),
          ),
        ),
        Expanded(flex: 1, child: _columnActions(false)),
        Expanded(
            flex: 5,
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: SingleChildScrollView(child: Text(_formattedText)),
            )),
        Column(children: [
          const Spacer(),
          Text("$_size bytes", style: const TextStyle(color: Colors.black)),
          const SizedBox(width: 16, height: 16),
        ])
      ],
    );
  }

  // ignore: non_constant_identifier_names
  Widget _columnActions(bool alignVertical) {
    var buttons = [
      const SizedBox(width: 16, height: 16),
      Tooltip(
        message: 'Format',
        child: ElevatedButton(
          onPressed:
              _selectedFormat[0] == true ? _formatPrettyJson : _formatPrettyXml,
          child: const Icon(Icons.format_indent_increase_sharp, size: 24.0),
        ),
      ),
      const SizedBox(width: 16, height: 16),
      Tooltip(
          message: 'Compact',
          child: ElevatedButton(
            onPressed:
                _selectedFormat[0] == true ? _formatMiniJson : _formatMinifyXml,
            child: const Icon(Icons.format_indent_decrease_sharp, size: 24.0),
          )),
      const Spacer(),
      Tooltip(
          message: 'Copy to Clipboard',
          child: ElevatedButton(
            onPressed: _copyOutput,
            child: const Icon(Icons.copy_all, size: 24.0),
          )),
      const SizedBox(width: 16, height: 16),
      Tooltip(
          message: 'Clear',
          child: ElevatedButton(
            onPressed: _clear,
            child: const Icon(Icons.clear_all, size: 24.0),
          )),
      const SizedBox(width: 16, height: 16),
      const Spacer(),
      const Spacer()
    ];
    return (alignVertical) ? Row(children: buttons) : Column(children: buttons);
  }

  void _formatPrettyJson() {
    final inputJson = _textInputController.text;
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
    final inputJson = _textInputController.text;
    try {
      final dynamic parsedJson = jsonDecode(inputJson);
      var formattedJson = const JsonEncoder.withIndent('').convert(parsedJson);
      formattedJson = formattedJson.replaceAll("\t", "").replaceAll("\n", "");
      _setState(formattedJson,
          formatter.format(utf8.encode(formattedJson).length), '');
    } catch (e) {
      _setState('', '0', 'Invalid JSON format');
    }
  }

  void _formatPrettyXml() {
    final inputXml = _textInputController.text;
    try {
      final xmlDocument = xml.XmlDocument.parse(inputXml);
      final formattedXml = xmlDocument.toXmlString(pretty: true);
      setState(() {
        _formattedText = formattedXml;
        _errorText = '';
        _setState(formattedXml,
            formatter.format(utf8.encode(formattedXml).length), '');
      });
    } catch (e) {
      setState(() {
        _errorText = 'Invalid XML format';
        _formattedText = '';
      });
    }
  }

  void _formatMinifyXml() {
    final inputXml = _textInputController.text;
    try {
      final xmlDocument = xml.XmlDocument.parse(inputXml);
      final formattedXml = xmlDocument.toXmlString(pretty: false);
      setState(() {
        _formattedText = formattedXml;
        _errorText = '';
      });
    } catch (e) {
      setState(() {
        _errorText = 'Invalid XML format';
        _formattedText = '';
        _setState(_formattedText,
            formatter.format(utf8.encode(_formattedText).length), '');
      });
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
