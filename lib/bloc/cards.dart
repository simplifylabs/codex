import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:codex/util/card.dart';

abstract class CardsEvent {}

class SetCards extends CardsEvent {
  final List<Card> list;
  SetCards({required this.list});
}

class CardsBloc extends Bloc<CardsEvent, List<Card>> {
  CardsBloc() : super([]);

  @override
  Stream<List<Card>> mapEventToState(
    CardsEvent event,
  ) async* {
    if (event is SetCards) {
      yield event.list;
    }
  }
}
