/*: [Previous](@previous)


 # Observables

 The `R` from `FRP` means reactive and implies reaction to some `events`.
 
 Definition from [reactivex.io](http://reactivex.io)

 **In ReactiveX an observer subscribes to an Observable. Then that observer reacts to whatever item or sequence of items the Observable emits. This pattern facilitates concurrent operations because it does not need to block while waiting for the Observable to emit objects, but instead it creates a sentry in the form of an observer that stands ready to react appropriately at whatever future time the Observable does so.**

 ----

 An observable is an object we can subscribe/unsubscribe from to retrieve a set of event.

 it can emit 3 types of events:
 - A value is produced
 - Completion + Subscription is released/disposed
 - Error + Subscription is released/disposed

Despite the unsubscription in case of completion/error, there is no determined schema about which events will be sent:
- We can have an observable that produces no value, but just complete
- We can have an observable that produces values but never completes or errored
- We can have an observable that do nothing
- etc

Drawing the sequence of events along an axis, using a circle for a produced value, a cross for error and a dash for completion is called a marble diagram.

 Example:
      Value   Value        Completion
-------(3)-----(2)------------|->
      Value   Value          Error
-------(3)----(1)-------------x->

 Much more readable examples can be found on [RxMarble](https://rxmarbles.com/)

 ## Basics

 Let's start by importing the main reactive library
 */

import Foundation
import RxSwift

/*: Now let's create some `Observable` and let's try to get notified from them. An observable uses generic for the value it produces.
Let's create a new `Observable` of int elements:
*/

let simpleObservable = Observable.from([1, 2, 4, 5, 6])

//: We can use other convenient initializer for creating observers

// See exercise below
struct SimpleError: Error { }
let justOne = Observable<String>.just("Hello world")
let never = Observable<String>.never()
let justComplete = Observable<Int>.empty()
let error = Observable<()>.error(SimpleError())

//: To receive the events mentionned above an `Observable`, you subscribes to it. This provides you an handle you can use to unsubscribe from it.

let subscription = simpleObservable.subscribe(onNext: { print("Value: \($0)") }, onError: { print("Error: \($0)")}, onCompleted: { print("Completed")})
//: At the end we can unsubscribe from the observer
subscription.dispose()

//: Exercise: Could you draw the marble diagrams for every observables declare under `SimpleError`?
// DRAW HERE:


/*: Exercise: Using the `subscribe` method, creates different subscriptions to the upper defined observables
 and execute a print statements on:
- `justOne` completion and producing value event
- `justComplete` completion
- `error` error event
*/

// CODE HERE:

/*:
 ## Observable are typed in RxSwift

 There is an important thing to notice is that an observable is a construction about some generic type (Let's called it T).
 Remembers the rules upwards? There is an event producing a value. What's kind of value does it produce? The answer is T.

 On the opposite, the error event is not generic (aka. does not use static dispatch) and uses instead the polymorphism (aka. dynamic dispatch) to
 return any element conforming to the `Swift.Error` procotol.

 To sum up:
-   Observable is a generic construction around some type named T.
-   When the observable produces a value, it returns a value of type T.
-   When the observable produces an error, it returns any type conforming to the `Swift.Error` protocol.

This implies that an `Observable<String>` is different from a `Observable<String?>` or `Observable<Int>`.

**NOTE**: On Combine, the error event is using static dispatch, so every `Observable` (named `Publisher` in Combine) is defined by two generics.
*/

//: Exercise: Create an observable using the `just` that produces several `Observable<Int>` values.
// CODE HERE:

//: Exercise+: By taking a look at the `Combine` documentation, try to translate the two previous exercise from `RxSwift` to `Combine`
// CODE HERE:

/*:
 ## Create and dispose Observables

 The previous constructions were just basic basic Observables constructions. Let's use the canonical way of creating observers:
 */

let newAsync = Observable<String>.create { (obs) -> Disposable in

    obs.onNext("Hello")
    obs.onNext("World")
    obs.onCompleted()
    return Disposables.create()
}

/*: The closure passed to the `create` method is called the **subscription code** and it will be called every times
 some other other subject **subscript** to it.

 **NOTE**:
 This means that in general, most of the `Observable` you work with, will not starts to producing events unless you subscribe to them. (We speak about *Cold Observable*).
 In the opposite case, we speak about *Hot Observable*. We can create such using the `share` operator for example.
 */

let newSub = newAsync.subscribe(onNext: { print("\($0)")}) // This triggers the call to the **subscription code**
newSub.dispose()

/*:
 You're may be wondering what represents the `Disposable` returned at the end of the closure.

 This represents any `resources` you would need release once the observable ends to produces value (aka. either having a complete event or an error event).
 For example, let's imagine an `Observable` that is wrapping an async `Operation` element.
 */

let queue = OperationQueue()
queue.qualityOfService = .background
queue.maxConcurrentOperationCount = 10

struct ProducingError: Error {}
let disposableAsync = Observable<Int>.create { (obs) -> Disposable in

    var totalOperations: [Operation] = []

    // Creating a success operation that waits
    let operationSuccess = BlockOperation {
        Thread.sleep(forTimeInterval: 10.0) // Sleeps current thread's operation for 10 seconds
        obs.onCompleted()
    }
    totalOperations.append(operationSuccess)

    // Creating 10 operations producing elements.
    // Each operation picks up an number between 0 and 25

    let operations = (0..<9).map { _ in BlockOperation {
        Thread.sleep(forTimeInterval: 1.0)

        let random = Int.random(in: 0...25)
        if random % 2 == 0  && random % 3 == 0 {
            obs.onError(ProducingError())
        } else {
            obs.onNext(random)
        }
        }
    }

    totalOperations.append(contentsOf: operations)

    // Adding all elements to the queue
    for op in totalOperations {
        queue.addOperation(op)
    }

    return Disposables.create {
        // If all subscription to the Observable are disposed or if it completes,
        // the `Disposable` is run to allow releasing resources
        var totalFinished = 0
        for op in totalOperations {
            if op.isFinished {
                totalFinished += 1
            }
            op.cancel()
        }
        print("Total finished op: \(totalFinished) in \(totalOperations.count)")
    }
}

let sub = disposableAsync.subscribe(onNext: { print("Produced: \($0)") },
                                    onError: { print("Error: \($0)") },
                                    onCompleted: { print("Completed") },
                                    onDisposed: { print("Disposed !")})

//: **NOTE** The `subscribe` method has a callback when the observable is called

let randomDisposbale = Int.random(in: 8...12)
DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(randomDisposbale)) {
    sub.dispose()
}
/*:
 Despite the fact that 10 `Operation`s are scheduled on the `OperationQueue`, all of them may not have time to complete, because :
 - The subscription to the `Observable` may ends before the complete event is send
 - An error is produced by the `Observable` itself.

 In both cases, we need to cancel all the scheduled operations within the queue. This is where `Disposable` helps.

 If you have nothing to dispose, simply returns a `Dispoables.create()`.

 **NOTE**:
 By default, the **subscription code* is called on the same thread that the **subscribe** call is done.
 difference `subscribe` callbacks are called on the same thread that `onError`, `onNext`, `onCompleted` and `Disposable.create` are called.

 We'll see
 */
/*: Exercise: Creates an `Observable` that sends a 0 immediatly on subscription, waits 1 secondes and send 10, then completes */

// CODE HERE

/*: Exercise+: Creates an `Observable` producing incrementing values from 0 to 10 every seconds end complete */
// CODE HERE


//: [Next](@next)
