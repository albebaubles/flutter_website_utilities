
import 'package:intl/intl.dart';
import 'dart:convert';
import 'package:xml/xml.dart' as xml;

class Markup {
  String raw = '';

  var formatter = NumberFormat('#,###,##0');

  Markup(this.raw);

  String prettyJson() {
    try {
      return const JsonEncoder.withIndent('  ')
          .convert(jsonDecode(raw.trimLeft().trimRight()));
    } catch (e) {
      return '[{"error" : "invalid JSON"}]';
    }
  }

  String miniJson() {
    try {
      return const JsonEncoder.withIndent('')
          .convert(jsonDecode(raw.trimLeft().trimRight()))
          .replaceAll("\t", "")
          .replaceAll("\n", "");
    } catch (e) {
      return '[{"error" : "invalid JSON"}]';
    }
  }

  String prettyXml() {
    try {
      return xml.XmlDocument.parse(raw)
          .toXmlString(pretty: true);
    } catch (e) {
      return '<xml>invalid xml</xml>';
    }
  }

  String miniXml() {
    try {
      return xml.XmlDocument.parse(raw)
          .toXmlString(pretty: false);
    } catch (e) {
      return '<xml>invalid XML</xml>';
    }
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
}
