//: [Previous](@previous)

/*:
 # Schedulers

 This is the last pages about the basics of before we move to the workshop to develop a real application. We'll talk about schedulers.

 Schedulers are the object abstracting how observable code is executed on the operating system. We already know that the the observable subscription code
 execute on the same thread the subscribe method is called and callback are called on the same thread that the completion callback from the observable are called.

 What if we want to schedule it differently? That's where schedulers enter the game.

 ## CurrentThreadScheduler
 This is the scheduler abstracting executing observables on the current thread.

 ## MainScheduler
 This is the scheduler abstracting executing observables on the main thread. It help's ensuring observables are executed on the UI thread in a serial manner.

 ## SerialDispatchQueueScheduler
 This is the scheduler abstracting executing observables on a serial `DispatchQueue`.

 ## ConcurrentDispatchQueueScheduler
 This is the scheduler abstracting executing observables on a concurrent `DispatchQueue`.

 ## OperationQueueScheduler
 This is the scheduler abstracting executing observables on one `OperationQueue`.

 ## TestScheduler
 A special scheduler used when testing. You'll see it in action in the workshop.

 You can dispatch either the subscription code using `subscribeOn` or the observation callback using `observeOn`.
 */

//: Exercise: Try to 

import RxSwift

import Foundation
import PlaygroundSupport

Thread.current.name = "[Starting Thread]"

class ThreadGenerator: Thread {

    private var obs: AnyObserver<Int>
    init(obs: AnyObserver<Int>) {
        self.obs = obs
        super.init()
        self.name = "ThreadGenerator"
    }

    override func main() {

        for i in stride(from: 0, to: 5, by: 1) {
            guard !self.isCancelled else { return }
            obs.onNext(i)
            Thread.sleep(forTimeInterval: 1.0)
        }
        obs.onCompleted()
    }
}

let customObs = Observable<Int>.create { obs in
    print("[Subscription Thread: \(Thread.current.name)]")

    let generator = ThreadGenerator(obs: obs)

    generator.start()
    return Disposables.create {
        generator.cancel()
    }
}

PlaygroundPage.current.needsIndefiniteExecution = true
_ = customObs.subscribe(onNext: { print("[Current Thread:\(Thread.current.name)] - Element: \($0)") }, onCompleted: { PlaygroundPage.current.finishExecution() })

//: Exercise, using `OperationQueueScheduler` and `OperationQueue`, create two schedulers with two different names and modify `customObs` chain
//: in order to have the following stdout

/*
 [Subscription Queue: NAME_OF_SUBSCRIBER_QUEUE]
 [Current Queue: NAME_OF_OBSERVER_QUEUE] - Element: 0
 ...
 */
//: [Next](@next)
