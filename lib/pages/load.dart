// import 'package:codex/util/ad.dart';
import 'package:flutter/material.dart' hide Card;
import 'package:codex/util/internet.dart';
import 'package:codex/util/updater.dart';
import 'package:codex/util/storage.dart';
import 'package:codex/util/card.dart';
import 'package:flutter/services.dart';

class Load extends StatefulWidget {
  const Load({Key? key}) : super(key: key);

  @override
  _LoadState createState() => _LoadState();
}

class _LoadState extends State<Load> {
  @override
  void initState() {
    init();
    super.initState();
  }

  void init() async {
    // Make sure theres an internet connection
    await Internet.init();

    // Check for updates
    // if (Internet.isOnline) {
    //   var needsUpdate = await Updater.checkForUpdates(context);
    //   if (needsUpdate) return;
    // }

    // Load all static values
    await Storage.init();
    // await Storage.clear();

    bool? isNew = Storage.get("new");
    if (isNew == null) {
      Storage.set("new", false);
      // Ad.isFirstLaunch = true;
    }

    // Ad.init();

    // Load saved cards
    await Card.loadSaved(context);

    // Only allow portrait
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
    ]);

    // Goto index page
    Navigator.pushReplacementNamed(context, "/index");
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(body: Center(child: CircularProgressIndicator()));
  }
}
