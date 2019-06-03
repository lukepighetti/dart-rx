library rx.test.core;

import 'package:more/collection.dart' show IntegerRange;
import 'package:rx/constructors.dart';
import 'package:rx/core.dart';
import 'package:rx/operators.dart';

Observer<T> printObserver<T>(String name) => AnonymousObserver(
      (value) => print('$name.next($value)'),
      (error, [stackTrace]) => print('$name.error($error)'),
      () => print('$name.complete()'),
    );

void main() {
  // create
  final create$ = create((subscriber) {
    for (var i = 0; i < 3; i++) {
      subscriber.next(i);
    }
    subscriber.complete();
  });
  create$.subscribe(printObserver('create\$'));

  // empty
  final empty$ = empty();
  empty$.subscribe(printObserver('empty\$'));

  // future
  final future$ = fromFuture(Future.value(42));
  future$.subscribe(printObserver('future\$'));

  // just
  final just$ = just(42);
  just$.subscribe(printObserver('just\$'));

  // iterable
  final iterable$ = fromIterable([1, 2, 3]);
  iterable$.subscribe(printObserver('iterable\$'));

  // never
  final never$ = never();
  never$.subscribe(printObserver('never\$'));

  // stream
  final stream$ = fromStream(Stream.fromIterable([1, 2, 3]));
  stream$.subscribe(printObserver('stream\$'));

  // throw
  final throw$ = throwError(Exception('Hello World'));
  throw$.subscribe(printObserver('throw\$'));

  // Other:
  final transformed = fromIterable(IntegerRange(0, 100))
      .lift(filter((value) => value.isEven))
      .lift(map((value) => '${value * value}'))
      .lift(filter((value) => value.length < 3));

  transformed.subscribe(printObserver('One'));
  transformed.subscribe(printObserver('Two'));

  final obs = timer(
      delay: Duration(seconds: 2),
      period: Duration(milliseconds: 500));
  final subs1 = obs.subscribe(printObserver('1'));
  final subs2 = obs.subscribe(printObserver('2'));

  timer(delay: Duration(seconds: 3))
      .subscribe(Observer(complete: () => subs1.unsubscribe()));
  timer(delay: Duration(seconds: 5))
      .subscribe(Observer(complete: () => subs2.unsubscribe()));
}
