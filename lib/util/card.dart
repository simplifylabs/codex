// ignore_for_file: avoid_function_literals_in_foreach_calls

import 'package:flutter/material.dart' hide Card;
import 'package:http/http.dart' as http;
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:codex/pages/preview.dart';
import 'package:codex/util/storage.dart';
import 'package:codex/util/version.dart';
import 'package:codex/bloc/cards.dart';
import 'package:codex/util/name.dart';
import 'package:codex/util/type.dart';
import 'package:codex/util/internet.dart';
import 'dart:convert';
import 'dart:math';

class Card {
  // Current list of found cards
  static List<Card> list = [];

  // Count of "pages" loaded
  static int page = 1;

  // Default count of columns
  // (will be updated depending on screen)
  static int columnCount = 2;

  // How many colums should be rendered on 1 page
  static const int rowCount = 8;

  static const String chars =
      'AaBbCcDdEeFfGgHhIiJjKkLlMmNnOoPpQqRrSsTtUuVvWwXxYyZz1234567890';

  // Blacklisted words for svg
  static const List<dynamic> blacklist = [
    // Strings
    'xmlns:rdf="http://www.w3.org/1999/02/22-rdf-syntax-ns#"',
    'xmlns:dc="http://purl.org/dc/elements/1.1/"',
    'xmlns:cc="http://creativecommons.org/ns#"',
    'mask="url(#avatarsRadiusMask)"',
    'shape-rendering="crispEdges"',
  ];

  Card({
    required this.seed,
    required this.firstname,
    required this.lastname,
    required this.type,
    required this.age,
    required this.color,
    required this.score,
    image,
  });

  final String seed;
  final String firstname;
  final String lastname;
  final String type;
  final Color color;
  final int age;
  final int score;
  // Svg string
  String? image;

  // Parse card from string
  static parse(String str) {
    // Parse the json
    var data = jsonDecode(str);

    // Create the new card
    return Card(
        seed: data["seed"],
        color: HexColor.fromHex(data["color"]),
        firstname: data["firstname"],
        lastname: data["lastname"],
        type: data["type"],
        age: data["age"],
        score: data["score"],
        image: data["image"]);
  }

  @override
  String toString() {
    return jsonEncode({
      "seed": seed,
      "color": color.toHex(),
      "firstname": firstname,
      "lastname": lastname,
      "type": type,
      "age": age,
      "score": score,
      "image": image
    });
  }

  // Generate a card from a seed (string)
  static Card generate(String seedString) {
    Card? found = findBySeed(seedString);
    if (found != null) return found;

    // Convert seed to an int
    int seed = seedString.hashCode;

    // Calculate random age
    int age = Random().nextInt(82) + 18;

    // Generate a random name (from wordlist)
    List<String> names = Name.generate(seed);

    // Calculate the random score
    var score = calculateScore(seed);

    // Get type for score
    var type = Type.getType(score);
    // Dart wants this ._.
    type ??= Type.common;

    // Create the new card instance
    return Card(
      seed: seedString,
      firstname: names[0],
      lastname: names[1],
      age: age,
      color: type.color,
      type: type.name,
      score: score,
    );
  }

  // Get the full name
  get name {
    return firstname + " " + lastname;
  }

  // fetch the character image
  Future<void> fetchImage() async {
    if (!Internet.isOnline) return;

    // Create the uri
    var url = Uri.parse("https://api.dicebear.com/7.x/personas/svg?backgroundColor=transparent&seed=" + name);

    // Send it!
    var res = await http.get(url);

    // Check if theres an error
    if (res.statusCode != 200) return;

    String image = res.body;

    // Replace from blacklist
    blacklist.forEach((blacklisted) {
      image = image.replaceAll(blacklisted, "");
    });

    // image = image.replaceAll(new RegExp(r"<metadata(.*)metadata>"), "");
    // image = image.replaceAll(new RegExp(r"<mask(.*)mask>"), "");

    // Remove some empty spaces
    image = image.replaceAll('  ', " ");

    // Save it
    this.image = image;
    return;
  }

  // Generate a random card
  static Card random() {
    return generate(randomSeed());
  }

  // Generate a random seed
  static randomSeed() {
    return List.generate(15, (index) => chars[Random().nextInt(chars.length)])
        .join();
  }

  // TODO: Add UI to open boxes (Daily Boxes?)
  // Open a mystery box with [count] cards in it
  static void box(BuildContext context, int count) {
    List<Card> list = [];
    for (var i = 0; i < count; i++) {
      list.add(random());
    }
    previewList(context, list);
  }

  // Preview the card
  preview(BuildContext context, bool isNew, [Function? callback]) async {
    // Fetch the image, if not yet fetched
    if (image == null) await fetchImage();

    // Open the preview
    Navigator.of(context)
        .push(PreviewRoute(cards: [this], isNew: isNew))
        .then((_) {
      if (callback != null) callback();
    });

    // Save it (delay so card doesn't get spoilered in the list)
    Future.delayed(
        const Duration(milliseconds: 500), () => Card.addList(context, [this]));
    return true;
  }

  // Preview multiple cards
  static previewList(BuildContext context, List<Card> list) async {
    // Open the preview
    Navigator.of(context).push(PreviewRoute(cards: list, isNew: true));

    // Save it (delay so card doesn't get spoilered in the list)
    Future.delayed(
        const Duration(milliseconds: 500), () => Card.addList(context, list));
  }

  static int calculateScore(int seed) {
    return Random(seed).nextInt(101);
  }

  // Load saved cards from local storage
  static loadSaved(BuildContext context) async {
    List<String>? strings = Storage.getStringList("list");

    // Set default value for strings
    strings ??= [];

    // Parse all strings
    List<Card> parsed = [];
    strings.forEach((str) {
      parsed.add(Card.parse(str));
    });

    list = parsed;

    if (CardVersion.needsUpdate()) list = CardVersion.update(list);

    for (int i = 0; i < list.length; i++) {
      if (list[i].image == null) await list[i].fetchImage();
    }

    updateList(context);
  }

  // Add list of cards to current list
  static addList(BuildContext context, List<Card> addition) {
    for (var card in addition) {
      if (!cardExists(card)) list.add(card);
    }

    updateList(context);
  }

  // Update the list in the UI
  static updateList(BuildContext context) {
    BlocProvider.of<CardsBloc>(context).add(SetCards(
        list: sort(list).take(page * (rowCount * columnCount)).toList()));

    saveList();
  }

  // Save the list to local storage
  static saveList() async {
    List<String> strings = [];

    list.forEach((card) {
      strings.add(card.toString());
    });

    await Storage.setStringList("list", strings);
  }

  // Check if card exists
  static bool cardExists(Card addition) {
    var contain = list.where((card) => card.seed == addition.seed);
    return contain.isNotEmpty;
  }

  // Sort the list by score
  static List<Card> sort(List<Card> list) {
    list.sort((a, b) => b.score - a.score);
    return list;
  }

  static Card? findBySeed(String seed) {
    int index = list.indexWhere((card) => card.seed == seed);
    if (index == -1) return null;
    return list[index];
  }

  static nextPage(BuildContext context) {
    // Make sure theres more to load
    if (page * rowCount * columnCount >= list.length) return;

    // Increase the page number
    page++;

    // Update the UI
    updateList(context);
  }

  // Update the column count depending on screen size
  static setColumnCount(BuildContext context, int to) {
    columnCount = to;
  }
}

extension HexColor on Color {
  // Get color from hex string
  static Color fromHex(String hexString) {
    final buffer = StringBuffer();
    if (hexString.length == 6 || hexString.length == 7) buffer.write('ff');
    buffer.write(hexString.replaceFirst('#', ''));
    return Color(int.parse(buffer.toString(), radix: 16));
  }

  // Convert color to hex
  String toHex({bool leadingHashSign = false}) =>
      '${leadingHashSign ? '#' : ''}'
      '${red.toRadixString(16).padLeft(2, '0')}'
      '${green.toRadixString(16).padLeft(2, '0')}'
      '${blue.toRadixString(16).padLeft(2, '0')}';
}
