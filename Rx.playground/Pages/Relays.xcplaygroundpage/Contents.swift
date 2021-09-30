//: [Previous](@previous)

import RxSwift
import RxRelay

/*:
 # Relays

 `Relay` are special types of `Subject` with the following behavior :
 - can not generate an error event
 - can not complete (nevers end)
 */
/*:
 ## PublishRelay

 This relay wraps an `PublishRelay` and behaves the same but as they can not error out/complete,
 you can not send values using `on`/`onNext`/,`onError`,`onComplete`, you send using `accept`
 */
do {
    print("🚀 PublishRelay")
    let subject = PublishRelay<Int>()

    let obs1 = subject.subscribe(onNext: { print("Obs 1: \($0)")});

    subject.accept(1)
    subject.accept(2)

    let obs2 = subject.subscribe(onNext: { print("Obs 2: \($0)")});
    subject.accept(3) // Alternative to `onNext`

    obs1.dispose()
    obs2.dispose()
}

//: Excercise: What would be the output here?
// WRITE HERE

/*:
 ## BehaviorRelay

 This relay wraps an `BehaviorSubject` and behaves the same but as they can not error out/complete,
 you can not send values using `on`/`onNext`/,`onError`,`onComplete`, you send using `accept`

 As it is ensure to have a current value, you can access it through the `value` property.
 */

do {
    print("🚀 BehaviorRelay")
    let subject = BehaviorRelay<Int>(value: 1)

    print("Subject value: \(subject.value)")
    let obs1 = subject.subscribe(onNext: { print("Obs 1: \($0)")});
    subject.accept(2)


    let obs2 = subject.subscribe(onNext: { print("Obs 2: \($0)")});
    print("Subject value: \(subject.value)")
    subject.accept(3) // Alternative to `onNext`

    obs1.dispose()
    obs2.dispose()
}


//: Excercise: What would be the output here?
// WRITE HERE

/*:
 ## ReplaySubject

 This relay wraps an `ReplaySubject` and behaves the same but as they can not error out/complete,
 you can not send values using `on`/`onNext`/,`onError`,`onComplete`, you send using `accept`
 */

do {
    print("🚀 ReplaySubject")
    let subject = ReplayRelay<Int>.create(bufferSize: 2)
    subject.accept(1)
    subject.accept(2)
    subject.accept(3)
    let obs1 = subject.subscribe(onNext: { print("Obs 1: \($0)")});
    subject.accept(4)
    let obs2 = subject.subscribe(onNext: { print("Obs 2: \($0)")});
    subject.accept(5) // Alternative to `onNext`


    obs1.dispose()
    obs2.dispose()
}

//: Excercise: What would be the output here?
// WRITE HERE

//: [Next](@next)


