import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:xml/xml.dart' as xml;


class WatermarkLogo extends StatelessWidget {
  const WatermarkLogo({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.center,
      children: [
        Positioned.fill(child: child),
        IgnorePointer(
            child: Center(
                child: Opacity(
                  opacity: 0.08,
                  child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 50,
                      ),
                      child: Image.asset('images/logo.png')),
                )))
      ],
    );
  }
}