
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
          .convert(jsonDecode(raw));
    } catch (e) {
      return '';
    }
  }

  String miniJson() {
    try {
      return const JsonEncoder.withIndent('')
          .convert(jsonDecode(raw))
          .replaceAll("\t", "")
          .replaceAll("\n", "");
    } catch (e) {
      return '';
    }
  }

  // String prettyXml(String xml) {
  //   try {
  //     return xml.XmlDocument.parse(xml)
  //         .toXmlString(pretty: true);
  //   } catch (e) {
  //     return '';
  //   }
  // }
  //
  // String miniXml(String xml) {
  //   try {
  //     return xml.XmlDocument.parse(xml)
  //         .toXmlString(pretty: false);
  //   } catch (e) {
  //     return '';
  //   }
  // }

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
