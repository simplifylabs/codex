// ignore_for_file: unnecessary_new

import 'package:version/version.dart';
import 'package:codex/util/storage.dart';
import 'package:codex/util/card.dart';

class CardVersion {
  static Version latest = new Version(1, 0, 1);

  static Version get current {
    if (Storage.get("version") != null) {
      return Version.parse(Storage.get("version"));
    }
    Storage.set("version", latest.toString());
    return latest;
  }

  static needsUpdate() {
    return current < latest;
  }

  static List<Card> update(List<Card> list) {

    Storage.set("version", latest.toString());

    return list;
  }
}
