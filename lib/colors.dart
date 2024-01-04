// Copyright 2018-present the Flutter authors. All Rights Reserved.
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
// http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.

import 'package:flutter/material.dart';

const kShrineErrorRed = Color(0xFFC5032B);

const kABMain = Color(0xFF07579A);
const kABMainDark1 = Color(0xFF2068a4);
const kABMainDark2 = Color(0xFF06467b);
const kABMainDark3 = Color(0xFF053d6c);
const kABMainDark4 = Color(0xFF04345c);
const kABMainDark5 = Color(0xFF07579A);
const kABMainDark6 = Color(0xFF07579A);
const kABMainLight1 = Color(0xFF07579A);
const kABMainLight2 = Color(0xFF2068a4);
const kABMainLight3 = Color(0xFF3979ae);
const kABMainLight4 = Color(0xFF5189b8);
const kABMainLight5 = Color(0xFF6a9ac2);
const kABMainLight6 = Color(0xFF83abcd);
const kABMainLight7 = Color(0xFF9cbcd7);
const kABMainLight8 = Color(0xFFb5cde1);



extension ColorsExt on Color {

  MaterialColor toMaterialColor() {
    final int red = this.red;
    final int green = this.green;
    final int blue = this.blue;

    final Map<int, Color> shades = {
      50: Color.fromRGBO(red, green, blue, .1),
      100: Color.fromRGBO(red, green, blue, .2),
      200: Color.fromRGBO(red, green, blue, .3),
      300: Color.fromRGBO(red, green, blue, .4),
      400: Color.fromRGBO(red, green, blue, .5),
      500: Color.fromRGBO(red, green, blue, .6),
      600: Color.fromRGBO(red, green, blue, .7),
      700: Color.fromRGBO(red, green, blue, .8),
      800: Color.fromRGBO(red, green, blue, .9),
      900: Color.fromRGBO(red, green, blue, 1),
    };

    return MaterialColor(value, shades);
  }
}