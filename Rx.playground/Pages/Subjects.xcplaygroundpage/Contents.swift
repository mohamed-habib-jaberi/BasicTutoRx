//: [Previous](@previous)

/*:
 # Subjects

 Once one `Observable` is created (see [Previous](@previous)), you can only act on it by subscribing to events.
 */
import RxSwift

// Declare the observable
let obs = Observable.just(1)

// Now the only option we have is to subscribe to it to receive events

/*:
 FRP framworks provide a kind of `Observable` that can be manipulatedwithout using
 the previous construction but in a way the events can be inserted along the way.

 Those elements are named `Subjects`. We aslo say that they operate as both an observable and an observer object (they can accept new events).

 The following list of `Subject` is not exhaustive and only present the most used in day to day work.
 */

/*:
 ## PublishSubject

 This kind of subject simply transfer the events to already subscribed observer. Observers may loses event if they subscribed too late.
 */

do {
    print("🚀 PublishSubject")
    let subject = PublishSubject<Int>()

    let obs1 = subject.subscribe(onNext: { print("Obs 1: \($0)")});

    subject.onNext(1)
    subject.onNext(2)

    let obs2 = subject.subscribe(onNext: { print("Obs 2: \($0)")});
    subject.on(.next(3)) // Alternative to `onNext`

    obs1.dispose()
    obs2.dispose()
}

//: Excercise: What would be the output here?
// WRITE HERE

/*:
 ## BehaviorSubject

 This subject has the notion of behavior and always start with a value. The last value it has ever produced
 is passed to new subscribers as soon as they subscribe.
 */

do {
    print("🚀 BehaviorSubject")
    let subject = BehaviorSubject<Int>(value: 1)

    let obs1 = subject.subscribe(onNext: { print("Obs 1: \($0)")});
    subject.onNext(2)

    let obs2 = subject.subscribe(onNext: { print("Obs 2: \($0)")});
    subject.on(.next(3)) // Alternative to `onNext`
    subject.onCompleted()

    obs1.dispose()
    obs2.dispose()
}


//: Excercise: What would be the output here?
// WRITE HERE

/*:
 ## ReplaySubject

 This subject is an extension of `BehaviorSubject` where instead of buffer 1 value that is replayed to new
 subscribers, you can select the size of the buffer
 */

do {
    print("🚀 ReplaySubject")
    let subject = ReplaySubject<Int>.create(bufferSize: 2)
    subject.onNext(1)
    subject.onNext(2)
    subject.onNext(3)
    let obs1 = subject.subscribe(onNext: { print("Obs 1: \($0)")});
    subject.onNext(4)
    let obs2 = subject.subscribe(onNext: { print("Obs 2: \($0)")});
    subject.on(.next(5)) // Alternative to `onNext`

    obs1.dispose()
    obs2.dispose()
}
//: Excercise: What would be the output here?
// WRITE HERE
//: [Next](@next)


