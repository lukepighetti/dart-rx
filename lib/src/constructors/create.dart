library rx.constructors.create;

import 'package:rx/src/core/events.dart';
import 'package:rx/src/core/functions.dart';
import 'package:rx/src/core/observable.dart';
import 'package:rx/src/core/observer.dart';
import 'package:rx/src/core/subscriber.dart';
import 'package:rx/src/core/subscription.dart';

/// Creates an observable sequence from a specified subscribe method
/// implementation.
Observable<T> create<T>(Map1<Subscriber<T>, dynamic> subscribeFunction) =>
    _SubscribeObservable<T>(subscribeFunction);

class _SubscribeObservable<T> extends Observable<T> {
  final Map1<Subscriber<T>, dynamic> callback;

  _SubscribeObservable(this.callback);

  @override
  Subscription subscribe(Observer<T> observer) {
    final subscriber = Subscriber<T>(observer);
    final event = Event.map1(callback, subscriber);
    if (event is ErrorEvent) {
      subscriber.error(event.error, event.stackTrace);
    } else {
      subscriber.add(Subscription.of(event.value));
    }
    return subscriber;
  }
}
