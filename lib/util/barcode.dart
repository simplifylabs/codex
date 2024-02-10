import 'package:fast_barcode_scanner/fast_barcode_scanner.dart';

class Types {
  // Supported types by IOS
  static List<BarcodeType> ios = [
    BarcodeType.aztec,
    BarcodeType.code128,
    BarcodeType.code39,
    BarcodeType.code39mod43,
    BarcodeType.code93,
    BarcodeType.dataMatrix,
    BarcodeType.ean13,
    BarcodeType.ean8,
    BarcodeType.itf,
    BarcodeType.pdf417,
    BarcodeType.qr,
    BarcodeType.upcE,
    BarcodeType.interleaved,
  ];

  // Supported types by Android
  static List<BarcodeType> android = [
    BarcodeType.aztec,
    BarcodeType.code128,
    BarcodeType.code39,
    BarcodeType.code93,
    BarcodeType.codabar,
    BarcodeType.dataMatrix,
    BarcodeType.ean13,
    BarcodeType.ean8,
    BarcodeType.itf,
    BarcodeType.pdf417,
    BarcodeType.qr,
    BarcodeType.upcA,
    BarcodeType.upcE,
  ];
}
