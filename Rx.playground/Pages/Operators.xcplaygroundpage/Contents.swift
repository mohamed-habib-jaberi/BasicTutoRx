//: [Previous](@previous)
/*: # Operators

 The `F` from `FRP` means `Functional` as in `Functional` Programming

 One killer features are operators on RxSwift. They allows us to manipulate and transform streams
 in a functional way.
 You can find an exhaustiv list of operators and their categories on http://reactivex.io/documentation/operators.html
 ## Basic operators

 ### map

 A basic operator is `map` that behaves exactly like its correspondant inside the swift iterators.
 You can transform an `Observable<T>` to some `Observable<U>`
 */
import RxSwift

do {
    print("⚙️ map ")
    let base = Observable.from([1, 2, 3, 4, 5])
    let subscription = base.map { $0 + 1 }
        .subscribe(onNext: { print("\($0)" )})
    subscription.dispose()
}

//: Exercise - What does the upper code prints?


// WRITE HERE

/*:
 ### filter

 As its name implies, it filters values out of the stream of values.
 */

do {
    print("⚙️ filter ")
    let base = Observable.from(stride(from: 0, to: 10, by: 1))
    let subscription = base.filter { $0.isMultiple(of: 2) }
        .subscribe(onNext: { print("\($0)" )})
    subscription.dispose()

}

//: Exercise - What does the upper code prints?


// WRITE HERE


/*:
 ### distinctUntilChanged

 As its name implies, it filters values out of the stream of values.
 */

do {
    print("⚙️ distinctUntilChanged ")
    let base =  Observable.from([1, 2, 2, 3, 3, 4, 5])
    let subscription = base.distinctUntilChanged()
        .subscribe(onNext: { print("\($0)" )})
    subscription.dispose()

}

//: Exercise - What does the upper code prints?
// WRITE HERE

/*:
 ### Others
 A lot of operators are available and we are not intending to write an exhaustive list here.
 Check on [ReactiveX.io](http://reactivex.io/documentation/operators.html) and the RxSwift reference for more.

 //: Exercise - Go on [ReactiveX.io](http://reactivex.io/documentation/operators.html) and try to explain with words what
  are doing the following operators:

 - `do`
 - `take`
 - `reduce`
 - `combineLatest`
 - `withLatestFrom`
 - `flatMap`
 - `switchToLatest`
 // WRITE HERE

 ## Chaining operators

 As in the functional paradigm, you can chain operators to create more complex streanms
 */

do {
    print("⚙️ Chaining")
    let sub = Observable.from(stride(from: 0, to: 20, by: 1))
        .filter { $0 != 0 }
        .map { $0*2 }
        .distinctUntilChanged()
        .subscribe(onNext: { print("Value: \($0)")})
    sub.dispose()
}

/*:
 You need to think the chained operators as a completely new observable. And again, most of the times it will not start producing
 values until you subscribe to it.

 This also means if any of the element of the chain is producing an error or complete, this error will be propagated as the error of the whole chain
 and cause the unsubscription.
 */

do {
    struct ChainError: Error { }
    print("⚙️ Chaining error")
    let sub = Observable.from(stride(from: 0, to: 20, by: 1))
        .filter { $0 != 0 }
        .map { $0*2 }
        .flatMap { previous -> Observable<Int> in
            if previous == 20 {
                return Observable.error(ChainError())
            }
            return .just(previous)
        }
        .subscribe(onNext: { print("Value: \($0)")})
    sub.dispose()
}

import PlaygroundSupport
/*
 ## Error operators

 Some operators exists to handle/transform/react in case there is an error that is propagated to the chain. We mainly use `catch` and `retry` operator.

 //: Exercise: take a look at the documentation of those operators on reactivex.io and transform this `Observable` into a new one successfully producing
 // values from 0 to 1 without editing the code of the `flatMap` function.
 */

do {
    print("⚙️ Error with catch")

    struct MultipleError: Error {
        let value: Int
    }
    let _ = Observable.from(stride(from: 0, to: 10, by: 1)).flatMap { i -> Observable<Int> in
        if i > 1 && (i % 2 == 0 || i % 3 == 0) {
            return .error(MultipleError(value: i))
        } else {
            return .just(i)
        }

    }
    .subscribe(onNext: { print("Value: \($0)")}, onError: { print("Error: \($0)")});
}

//: Exercise: Transform the following observable that it prints "Youpi!" (using retry(_ maxAttemptCount))
//: Exercise+: Transform the following observable that it prints "Youpi!" for any value of `trigger`. ((using retry(when:))
do {
    print("⚙️ Error with retry")

    struct TriggerError: Error {
        let attemptToSucceed: Int
    }
    var trigger: Int = -30
    let obs = Observable<String>.create { obs -> Disposable in
        trigger += 1

        if trigger < 0 {
            obs.onError(TriggerError(attemptToSucceed: -1 * trigger))
        } else {
            obs.onNext("Youpi!")
            obs.onCompleted()
        }

        return Disposables.create()
    }


    _ = obs
        .subscribe(onNext: { print("Success: \($0)")}, onError: { print("Error: \($0)") })
}


//: [Next](@next)
