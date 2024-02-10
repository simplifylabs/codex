import 'package:flutter/material.dart' hide Card;
import 'package:codex/util/rainbow.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter/foundation.dart';
import 'package:codex/bloc/cards.dart';
import 'package:codex/util/card.dart';

class Index extends StatefulWidget {
  const Index({Key? key}) : super(key: key);

  @override
  _IndexState createState() => _IndexState();
}

class _IndexState extends State<Index> with TickerProviderStateMixin {
  late RainbowAnimation rainbow;

  ScrollController scrollController = ScrollController();

  int? rowSize;
  int? cardSize;

  @override
  void initState() {
    // Initialize the rainbow animation
    rainbow = RainbowAnimation.init(this, setState);

    // Listen for scrolling
    scrollController.addListener(scrollListener);

    super.initState();
  }

  @override
  void dispose() {
    // Dispose fade animation
    rainbow.dispose();

    // Dispose the scrollController
    scrollController.removeListener(scrollListener);
    scrollController.dispose();

    super.dispose();
  }

  void testScoreCalculator() {
    int i = 0;
    int maxScoreCount = 0;

    while (true) {
      i++;

      String seed = Card.randomSeed();
      int score = Card.calculateScore(seed.hashCode);

      if (score == 100) {
        maxScoreCount++;
        if (maxScoreCount > 10) break;
      }
    }

    if (kDebugMode) {
      print("It took an average of " +
          (i / maxScoreCount).round().toString() +
          " cards to get max score.");
    }
  }

  void scrollListener() {
    // Check if user is near end
    if (scrollController.position.extentAfter < 350) {
      Card.nextPage(context);
    }
  }

  // Calculate row size depending on screen width
  int calculateRowSize() {
    // Result
    int calculated = (MediaQuery.of(context).size.width / 200).round();

    // Make sure its min 0
    if (calculated < 1) calculated = 1;

    // Sync with card
    if (calculated != Card.rowCount) Card.setColumnCount(context, calculated);

    return calculated;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          BlocBuilder<CardsBloc, List<Card>>(builder: (context, cards) {
            if (cards.isEmpty) {
              return Center(
                child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 50),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Image(
                            image: AssetImage("assets/images/tv.png"),
                            width: 150),
                        Container(
                          margin: const EdgeInsets.only(bottom: 2, top: 30),
                          child: const Text("Nothing here...",
                              style: TextStyle(
                                  color: Colors.black,
                                  fontSize: 31,
                                  fontWeight: FontWeight.bold),
                              textAlign: TextAlign.center),
                        ),
                        Text("Click the + to make your first scan!",
                            style: TextStyle(
                                color: Colors.grey[700], fontSize: 13),
                            textAlign: TextAlign.center),
                      ],
                    )),
              );
            }

            return GridView.builder(
                physics: const AlwaysScrollableScrollPhysics(),
                itemCount: cards.length,
                controller: scrollController,
                shrinkWrap: true,
                padding: EdgeInsets.only(
                    left: 30,
                    right: 30,
                    top: MediaQuery.of(context).padding.top + 30,
                    bottom: MediaQuery.of(context).padding.bottom + 30),
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: calculateRowSize(),
                    crossAxisSpacing: 15.0,
                    mainAxisSpacing: 15.0,
                    childAspectRatio: 1),
                itemBuilder: (context, index) {
                  var card = cards[index];
                  if (card.score == 100) {
                    return AnimatedBuilder(
                      animation: rainbow.animation,
                      builder: (context, _) {
                        return CardWidget(card: card, fade: rainbow.animation);
                      },
                    );
                  }

                  return CardWidget(
                    card: card,
                  );
                });
          }),
        ],
      ),
      floatingActionButton: FloatingActionButton(
          onPressed: () {
            // Card.box(context, 20);
            // return;

            // if ((defaultTargetPlatform == TargetPlatform.iOS) ||
            //     (defaultTargetPlatform == TargetPlatform.android)) {
            Navigator.of(context).pushNamed("/scanner");
            // } else {
            //   Card.random().preview(context, true);
            // }
          },
          child: const Icon(Icons.add)),
    );
  }
}

class CardWidget extends StatelessWidget {
  const CardWidget({
    Key? key,
    this.fade,
    required this.card,
  }) : super(key: key);

  final Card card;
  final Animation<Color>? fade;

  @override
  Widget build(context) {
    return GestureDetector(
      onTap: () {
        card.preview(context, false);
      },
      child: Container(
        height: 30,
        decoration: BoxDecoration(
            boxShadow: [
              BoxShadow(blurRadius: 8, color: Colors.black.withOpacity(0.1))
            ],
            color: const Color(0xFFFFFFFF),
            borderRadius: const BorderRadius.all(Radius.circular(15))),
        child: Column(
          children: [
            Container(
              decoration: BoxDecoration(
                color: fade != null ? fade?.value : card.color,
                borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(15),
                    topRight: Radius.circular(15)),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Text(card.score.toString(),
                          style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Colors.white)),
                      Text(
                        "Score",
                        style: TextStyle(color: Colors.grey[300], fontSize: 12),
                      )
                    ],
                  ),
                  Flexible(
                      child: LayoutBuilder(builder: (context, constraints) {
                    return card.image != null
                        ? Padding(
                            padding: const EdgeInsets.only(top: 5),
                            child: SvgPicture.string(
                              card.image ?? "",
                              width: constraints.maxWidth * 0.5,
                              placeholderBuilder: (context) {
                                return Container(
                                  width: constraints.maxWidth * 0.5,
                                  height: constraints.maxWidth * 0.5,
                                  padding: const EdgeInsets.all(15),
                                  child: const CircularProgressIndicator(
                                    strokeWidth: 2.5,
                                    color: Colors.white,
                                  ),
                                );
                              },
                            ))
                        : Container(
                            width: constraints.maxWidth * 0.5,
                            height: constraints.maxWidth * 0.5,
                            padding: const EdgeInsets.all(15),
                            child: const CircularProgressIndicator(
                              strokeWidth: 2.5,
                              color: Colors.white,
                            ),
                          );
                  }))
                ],
              ),
            ),
            Expanded(
                child: Container(
              padding: const EdgeInsets.only(right: 20, left: 20),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text(
                    card.firstname,
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1,
                    softWrap: false,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                        fontWeight: FontWeight.w800, fontSize: 21),
                  ),
                  Text(
                    card.type,
                    overflow: TextOverflow.fade,
                    maxLines: 1,
                    softWrap: false,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                        fontWeight: FontWeight.w400,
                        fontSize: 15,
                        color: fade != null ? fade!.value : card.color),
                  )
                ],
              ),
            ))
          ],
        ),
      ),
    );
  }
}
