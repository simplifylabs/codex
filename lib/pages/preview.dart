import 'package:flutter/material.dart' hide Card;
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:codex/util/rainbow.dart';
import 'package:codex/util/card.dart';
import 'package:tcard/tcard.dart';

class PreviewRoute extends PageRouteBuilder {
  final List<Card> cards;
  final bool isNew;

  PreviewRoute({required this.cards, required this.isNew})
      : super(
            pageBuilder: (
              BuildContext context,
              Animation<double> animation,
              Animation<double> secondaryAnimation,
            ) =>
                Preview(isNew: isNew, cards: cards),
            transitionsBuilder: (
              BuildContext context,
              Animation<double> animation,
              Animation<double> secondary,
              Widget child,
            ) =>
                FadeTransition(opacity: animation, child: child));
}

class Preview extends StatefulWidget {
  const Preview({
    Key? key,
    required this.isNew,
    required this.cards,
  }) : super(key: key);

  final List<Card> cards;
  final bool isNew;

  @override
  _PreviewState createState() => _PreviewState();
}

class _PreviewState extends State<Preview> with TickerProviderStateMixin {
  TCardController cardController = TCardController();

  late final AnimationController popController = AnimationController(
    duration: const Duration(milliseconds: 200),
    vsync: this,
  );

  late final Animation<double> popAnimation = CurvedAnimation(
    parent: popController,
    curve: Curves.fastOutSlowIn,
  );

  late RainbowAnimation rainbow;

  late Card current;

  int currentIndex = 0;
  bool loading = true;
  bool ready = false;

  @override
  void initState() {
    rainbow = RainbowAnimation.init(this, setState);

    currentIndex = 0;
    current = widget.cards[currentIndex];
    setState(() {});

    fetchImages();

    startTimeout();

    super.initState();
  }

  @override
  void dispose() {
    cardController.dispose();
    popController.dispose();
    rainbow.dispose();

    super.dispose();
  }

  void fetchImages() async {
    if (widget.cards.isNotEmpty && widget.cards[0].image == null) {
      for (var card in widget.cards) {
        await card.fetchImage();
      }
    }

    Card.saveList();

    setState(() {
      loading = false;
    });

    if (ready) popController.forward();
  }

  void startTimeout() {
    Future.delayed(const Duration(milliseconds: 300), () {
      ready = true;

      if (!loading) popController.forward();
    });
  }

  void onChange(int index) {
    setState(() {
      if (widget.cards.length - index > 0) {
        currentIndex = index;
        current = widget.cards[currentIndex];
      }
    });
  }

  void next() {
    if (cardController.state == null) return;

    if (currentIndex == widget.cards.length) {
      end();
      return;
    }

    cardController.forward();
  }

  void end() {
    Navigator.pop(context);
  }

  Size getSize() {
    var size = 0.8.sw;
    if (size > 300) size = 300;
    return Size(size, size);
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
        onTap: () {
          next();
        },
        child: Scaffold(
            body: loading
                ? const Center(child: CircularProgressIndicator())
                : Stack(
                    children: [
                      Positioned(
                        top: MediaQuery.of(context).padding.top +
                            MediaQuery.of(context).size.height * 0.075,
                        child: IgnorePointer(
                          ignoring: true,
                          child: Opacity(
                            opacity: widget.isNew ? 1 : 0,
                            child: SizedBox(
                              width: MediaQuery.of(context).size.width,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text("FOUND",
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                          letterSpacing: 1.5,
                                          color: current.score == 100
                                              ? rainbow.animation.value
                                              : current.color,
                                          fontSize: 14.sp)),
                                  Padding(
                                    padding:
                                        const EdgeInsets.symmetric(horizontal: 50),
                                    child: Text(current.name,
                                        textAlign: TextAlign.center,
                                        style: TextStyle(
                                            fontSize: 25.sp,
                                            fontWeight: FontWeight.w700)),
                                  )
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                      Center(
                        child: ScaleTransition(
                            scale: popAnimation,
                            child: TCard(
                              delaySlideFor: 200,
                              slideSpeed: 10,
                              cards: List.generate(
                                widget.cards.length,
                                (index) {
                                  var card = widget.cards[index];
                                  if (card.score == 100) {
                                    return AnimatedBuilder(
                                      animation: rainbow.animation,
                                      builder: (context, _) {
                                        return CardWidget(
                                            card: card,
                                            fade: rainbow.animation);
                                      },
                                    );
                                  } else {
                                    return CardWidget(
                                      card: card,
                                    );
                                  }
                                },
                              ),
                              size: getSize(),
                              onEnd: end,
                              onForward: (index, _) {
                                onChange(index);
                              },
                              onBack: (index, _) {
                                onChange(index);
                              },
                              controller: cardController,
                            )),
                      ),
                    ],
                  )));
  }
}

class CardWidget extends StatelessWidget {
  const CardWidget({
    Key? key,
    required this.card,
    this.fade,
  }) : super(key: key);

  final Card card;
  final Animation<Color>? fade;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
          boxShadow: [
            BoxShadow(blurRadius: 5, color: Colors.black.withOpacity(0.15))
          ],
          color: Colors.white,
          borderRadius: const BorderRadius.all(Radius.circular(30))),
      child: Column(
        children: [
          Container(
            decoration: BoxDecoration(
              color: fade != null ? fade?.value : card.color,
              borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(30), topRight: Radius.circular(30)),
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
                            fontSize: 35,
                            color: Colors.white,
                            fontWeight: FontWeight.bold)),
                    Text(
                      "Score",
                      style: TextStyle(color: Colors.grey[300], fontSize: 15),
                    )
                  ],
                ),
                Flexible(child: LayoutBuilder(builder: (context, constraints) {
                  return card.image != null
                      ? Padding(
                          padding: const EdgeInsets.only(top: 0),
                          child: SvgPicture.string(
                            card.image ?? "",
                            width: constraints.maxWidth * 0.5,
                            placeholderBuilder: (context) {
                              return Container(
                                width: constraints.maxWidth * 0.5,
                                height: constraints.maxWidth * 0.5,
                                padding: const EdgeInsets.all(40),
                                child: const CircularProgressIndicator(
                                  strokeWidth: 3.0,
                                  color: Colors.white,
                                ),
                              );
                            },
                          ))
                      : Container(
                          width: constraints.maxWidth * 0.5,
                          height: constraints.maxWidth * 0.5,
                          padding: const EdgeInsets.all(40),
                          child: const CircularProgressIndicator(
                            strokeWidth: 3.0,
                            color: Colors.white,
                          ),
                        );
                }))
              ],
            ),
          ),
          Expanded(
              child: Container(
            padding: const EdgeInsets.only(right: 30, left: 30, bottom: 15),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text(
                      "Name",
                      style: TextStyle(
                          fontWeight: FontWeight.w300,
                          fontSize: 15,
                          color: fade != null ? fade?.value : card.color),
                    ),
                    Text(
                      card.name,
                      overflow: TextOverflow.fade,
                      maxLines: 1,
                      softWrap: false,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                          fontWeight: FontWeight.w800,
                          color: Colors.grey[800],
                          fontSize: 24),
                    )
                  ],
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Text(
                          "Age",
                          style: TextStyle(
                              fontWeight: FontWeight.w300,
                              fontSize: 15,
                              color: fade != null ? fade?.value : card.color),
                        ),
                        Text(
                          card.age.toString(),
                          overflow: TextOverflow.fade,
                          maxLines: 1,
                          softWrap: false,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                              fontWeight: FontWeight.w500,
                              fontSize: 18,
                              color: Colors.grey[700]),
                        )
                      ],
                    ),
                    Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Text(
                          "Type",
                          style: TextStyle(
                              fontWeight: FontWeight.w300,
                              fontSize: 15,
                              color: fade != null ? fade?.value : card.color),
                        ),
                        Text(
                          card.type,
                          overflow: TextOverflow.fade,
                          maxLines: 1,
                          softWrap: false,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                              fontWeight: FontWeight.w500,
                              fontSize: 18,
                              color: Colors.grey[800]),
                        )
                      ],
                    )
                  ],
                )
              ],
            ),
          ))
        ],
      ),
    );
  }
}
