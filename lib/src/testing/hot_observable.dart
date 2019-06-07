library rx.testing.hot_observable;

import 'package:meta/meta.dart';
import 'package:rx/core.dart';
import 'package:rx/src/core/observer.dart';
import 'package:rx/src/core/subscription.dart';

import 'test_events.dart';
import 'test_observable.dart';
import 'test_scheduler.dart';

class HotObservable<T> extends TestObservable<T> {
  @protected
  final Subject<T> subject = Subject<T>();

  HotObservable(TestScheduler scheduler, List<TestEvent<T>> events)
      : super(scheduler, events);

  void initialize() {
    final subscriptionIndex = events
        .whereType<SubscribeEvent>()
        .map((event) => event.index)
        .firstWhere((index) => true, orElse: () => 0);
    for (final event in events) {
      final timestamp = scheduler.now
          .add(scheduler.stepDuration * (event.index - subscriptionIndex));
      scheduler.scheduleAbsolute(timestamp, () => event.observe(subject));
    }
  }

  @override
  Subscription subscribe(Observer<T> observer) {
    final subscriber = createSubscriber(observer);
    subject.subscribe(subscriber);
    return subscriber;
  }
}
