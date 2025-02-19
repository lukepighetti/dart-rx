library rx.operators.sample;

import 'package:rx/src/core/observable.dart';
import 'package:rx/src/core/observer.dart';
import 'package:rx/src/core/operator.dart';
import 'package:rx/src/core/scheduler.dart';
import 'package:rx/src/core/subscriber.dart';
import 'package:rx/src/core/subscription.dart';
import 'package:rx/src/observers/inner.dart';

/// Emits the most recently emitted value from the source [Observable] whenever
/// the `trigger` [Observable] emits.
Operator<T, T> sample<T>(Observable trigger, {Scheduler scheduler}) =>
    (subscriber, source) =>
        source.subscribe(_SampleSubscriber(subscriber, trigger));

class _SampleSubscriber<T> extends Subscriber<T>
    implements InnerEvents<T, void> {
  T lastValue;
  bool hasValue = false;

  _SampleSubscriber(Observer<T> destination, Observable trigger)
      : super(destination) {
    add(InnerObserver(trigger, this));
  }

  @override
  void onNext(T value) {
    lastValue = value;
    hasValue = true;
  }

  @override
  void notifyNext(Subscription subscription, void state, T value) =>
      emitValue();

  @override
  void notifyError(Subscription subscription, void state, Object error,
          [StackTrace stackTrace]) =>
      doError(error, stackTrace);

  @override
  void notifyComplete(Subscription subscription, void state) => emitValue();

  void emitValue() {
    if (hasValue) {
      doNext(lastValue);
      hasValue = false;
    }
  }
}
