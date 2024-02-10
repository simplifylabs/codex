import 'package:flutter/material.dart';

class Type {
  Type({required this.color, required this.name});

  final Color color;
  final String name;

  static Type common = Type(name: "Common", color: const Color(0xFFBFBFBF));

  static Map<int, Type> rarities = {
    100: Type(name: "Legendary", color: const Color(0xFFFFFFFF)),
    90: Type(name: "Mythical", color: const Color(0xFFFF3838)),
    80: Type(name: "Epic", color: const Color(0xFFFF38F7)),
    70: Type(name: "Very Rare", color: const Color(0xFFA838FF)),
    60: Type(name: "Rare", color: const Color(0xFF3870FF)),
    50: Type(name: "Uncommon", color: const Color(0xFF3FBAFF)),
    0: common,
  };

  static Type? getType(int score) {
    int? first;

    for (var breakpoint in rarities.keys) {
      if (first != null) break;
      if (score >= breakpoint) first = breakpoint;
    }

    return rarities[first];
  }
}
