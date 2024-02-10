import 'package:http/http.dart' as http;
import 'package:store_redirect/store_redirect.dart';
import 'package:package_info/package_info.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:version/version.dart';
import 'dart:convert';
import 'dart:io';

class Server {
  static const dev = "http://10.0.0.41:3001/";
  static const prod = "https://api.codex.ml/";

  static get url {
    if (kReleaseMode) return prod;
    return dev;
  }

  static Future<bool> isOnline() async {
    try {
      final result = await InternetAddress.lookup("api.codex.ml");
      if (result.isNotEmpty && result[0].rawAddress.isNotEmpty) {
        return true;
      } else {
        return false;
      }
    } catch (e) {
      return false;
    }
  }
}

class Updater {
  static Future<bool> checkForUpdates(BuildContext context) async {
    if (kIsWeb || (!Platform.isAndroid && !Platform.isIOS)) return false;

    var isOnline = await Server.isOnline();
    if (!isOnline) return false;

    var latest = await fetchLatest();
    if (latest == null) return false;

    // Compare versions
    var result = await needsUpdate(latest);

    if (result) {
      showDialog<void>(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text('Update needed'),
            content: SingleChildScrollView(
              child: ListBody(
                children: <Widget>[
                  Text("New Version (" + latest + ") available!"),
                  const Text('Update app to continue.'),
                ],
              ),
            ),
            actions: <Widget>[
              TextButton(
                child: const Text('Update'),
                onPressed: () {
                  // TODO: Set IOeturn null;S
                  StoreRedirect.redirect(
                      androidAppId: "com.simplifylabs.codex", iOSAppId: "");
                },
              ),
            ],
          );
        },
      );
    }

    return result;
  }

  static Future<bool> needsUpdate(String version) async {
    PackageInfo info = await PackageInfo.fromPlatform();

    Version latest = Version.parse(version);
    Version current = Version.parse(info.version);

    return latest > current;
  }

  static Future<String?> fetchLatest() async {
    var platform = kIsWeb
        ? "web"
        : Platform.isIOS
            ? "ios"
            : "android";

    try {
      var url = Uri.parse(Server.url + platform + "/version");

      // Send it
      var res = await http.get(url);

      // Check if theres an error
      if (res.statusCode != 200) return null;

      var body = jsonDecode(res.body);

      if (body["error"] != null) return null;
      return body["version"];
    } catch (e) {
      return null;
    }
  }
}
