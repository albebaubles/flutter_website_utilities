import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:xml/xml.dart' as xml;
import 'watermark.dart';
import 'colors.dart';
import 'markup.dart';

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
  // ignore: library_private_types_in_public_api
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
  var _isHorizontal = true;
  List<bool> _selectedFormat = <bool>[true, false];

  @override
  void initState() {
    _textInputController.addListener(() { _markup.raw = _textInputController.text.trim(); });
    // _focusNode.addListener(() {
    //   if (_focusNode.hasFocus) {
    //     _markup.raw = _textInputController.text.trim();
    //   }
    // });
    _selectedFormat[0] == true;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return
      WatermarkLogo(child:
      Scaffold(
          appBar: AppBar(
            title: Text(_titleText.trimLeft().trimRight()),
            actions: [
              _formatSelection(),
              Spacer(),
              Tooltip(
                message: 'Format',
                child: ElevatedButton(
                  onPressed:
                  _selectedFormat[0] == true ? _formatPrettyJson : _formatPrettyXml,
                  child: const Icon(Icons.format_indent_increase_sharp, size: 24.0),
                ),
              ),
              Tooltip(
                  message: 'Compact',
                  child: ElevatedButton(
                    onPressed:
                    _selectedFormat[0] == true ? _formatMiniJson : _formatMinifyXml,
                    child: const Icon(Icons.format_indent_decrease_sharp, size: 24.0),
                  )),
              const SizedBox(width: 8, height: 16),
              Tooltip(
                  message: 'Copy to Clipboard',
                  child: ElevatedButton(
                    onPressed: _copyOutput,
                    child: const Icon(Icons.copy_all, size: 24.0),
                  )),
              Tooltip(
                  message: 'Clear',
                  child: ElevatedButton(
                    onPressed: _clear,
                    child: const Icon(Icons.clear_all, size: 24.0),
                  )),
              const Spacer(flex: 3),
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
            ],
            backgroundColor: kABMain,
          ),
          // drawer: _buildDrawer(),
          body: _isHorizontal ? _buildRowLayout() : _buildColumnJson()
      ));
  }

  ToggleButtons _formatSelection() {
    return ToggleButtons(
      color: kABMainLight3,
      direction: Axis.horizontal,
      isSelected: _selectedFormat,
      onPressed: (int index) {
        setState(() {
          _selectedFormat = [index == 0, index != 0];
          _textInputController.text = (index == 0)
              ? '[{"author": "Albebaubles", "framework": "Flutter", "language": "Dart", "source" : "https://github.com/albebaubles/flutter_website_utilities"}]'
              : '<root><row><author>Albebaubles</author><framework>Flutter</framework><language>Dart</language><source>https://github.com/albebaubles/flutter_website_utilities</source></row></root>';
          _markup.raw = _textInputController.text.trim();
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

  TextField rawText() {
    return TextField(
      focusNode: _focusNode,
      autofocus: true,
      controller: _textInputController,
      maxLines: 10,
      decoration: InputDecoration(
        hintText: 'Enter text to format here...',
        errorText: _errorText.isNotEmpty ? _errorText : null,
      ),
    );
  }

  Column _buildRowLayout() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        rawText(),
        Expanded(child: SingleChildScrollView(child: Text(_formattedText))),
        Container(
            color: kABMainLight2,
            height: 30,
            child: Row(
              children: [
                const Spacer(),
                FittedBox(
                  fit: BoxFit.contain,
                  child: Text("$_size bytes",
                      style: const TextStyle(color: Colors.white),
                      textAlign: TextAlign.end),
                ),
                const SizedBox(width: 16)
              ],
            ))
      ],
    );
  }

  Row _buildColumnJson() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: <Widget>[
        Expanded(
          flex: 5,
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: rawText(),
          ),
        ),
        Expanded(
            flex: 5,
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: SingleChildScrollView(child: Text(_formattedText)),
            )),
        Column(children: [
          // const Spacer(),
          Text("$_size bytes", style: const TextStyle(color: Colors.black)),
          const SizedBox(width: 16, height: 16),
        ])
      ],
    );
  }

  void _formatPrettyJson() {
    final pretty = _markup.prettyJson();
    _setState(pretty, _formatter.format(utf8
        .encode(pretty)
        .length), '');
  }

  void _formatMiniJson() {
    final mini = _markup.miniJson();
    _setState(mini,
        _formatter.format(utf8
            .encode(mini)
            .length), '');
  }

  void _formatPrettyXml() {
    final pretty = _markup.prettyXml();
    _setState(pretty,
        _formatter.format(utf8
            .encode(pretty)
            .length), '');
  }

  void _formatMinifyXml() {
    final mini = _markup.miniXml();
    _setState(mini,
        _formatter.format(utf8
            .encode(mini)
            .length), '');
  }

  String jsonToXml(Map<String, dynamic> jsonData, String rootElement) {
    var builder = xml.XmlBuilder();
    builder.element(rootElement, nest: () {
      _mapJsonToXml(jsonData, builder);
    });

    var xmlDoc = builder.buildFragment();
    return xmlDoc.toXmlString(pretty: true);
  }

  void _mapJsonToXml(dynamic json, xml.XmlBuilder builder) {
    if (json is Map) {
      json.forEach((key, value) {
        builder.element(key, nest: () {
          _mapJsonToXml(value, builder);
        });
      });
    } else if (json is List) {
      for (var item in json) {
        builder.element('item', nest: () {
          _mapJsonToXml(item, builder);
        });
      }
    } else {
      builder.text(json.toString());
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