import 'package:flutter/material.dart';
import 'package:codex/bloc/cards.dart';
import 'package:codex/pages/index.dart';
import 'package:codex/pages/load.dart';
import 'package:codex/pages/scanner.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  MobileAds.instance.initialize();

  runApp(const Codex());
}

class Codex extends StatelessWidget {
  static const MaterialColor primary = MaterialColor(0xFF6366F1, {
    50: Color(0xFFEEF2FF),
    100: Color(0xFFE0E7FF),
    200: Color(0xFFC7D2FE),
    300: Color(0xFFA5B4FC),
    400: Color(0xFF818CF8),
    500: Color(0xFF6366F1),
    600: Color(0xFF4F46E5),
    700: Color(0xFF4338CA),
    800: Color(0xFF3730A3),
    900: Color(0xFF312E81),
  });

  const Codex({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocProvider<CardsBloc>(
        create: (context) => CardsBloc(),
        child: ScreenUtilInit(builder: (BuildContext _) {
          return MaterialApp(
            title: 'Codex',
            theme: ThemeData(
                fontFamily: "Inter",
                brightness: Brightness.light,
                primaryColor: primary,
                primarySwatch: primary,
                scaffoldBackgroundColor: const Color(0xFFF3F4F6),
                floatingActionButtonTheme: const FloatingActionButtonThemeData(
                    backgroundColor: primary,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                        borderRadius:
                            BorderRadius.all((Radius.circular(15)))))),
            routes: {
              "/": (context) => const Load(),
              "/load": (context) => const Load(),
              "/scanner": (context) => const Scanner(),
              "/index": (context) => const Index(),
            },
          );
        }));
  }
}
