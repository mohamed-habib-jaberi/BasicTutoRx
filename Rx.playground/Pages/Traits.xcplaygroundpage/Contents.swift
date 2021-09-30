//: [Previous](@previous)

/*:
 # Traits

 Observable represents the canonical objects used to work with RxSwift. You can use them along the way without any issues.

 However, some patterns/traits appear recurrently while developing application. Some of them are so common that they gain they own APIs
 in the framework. See them as `Observable` with some functions referring to they behaviors.

 The list of traits can be found on the [RxSwift](https://github.com/ReactiveX/RxSwift/blob/main/Documentation/Traits.md)

 We'll speak only about the `Single` trait here, but take a look at all the others `RxSwift` trait on the mentionned webpage above.
 (`RxCocoa` traits will be discussed indirectly during the workshop)


## Single

 A `Single` represents an `Observable` that either produce a value or an error. It perfectly abstract an api call for example.

 To better emphase this, you subscribe to it using `subscribe(onSuccess: (T) -> Void, onError: (Error) -> Void)`
 **NOTE**: This framework uses RxSwift 6 and some changes has been made since the 5 version to make the type more compatible with the `Swift.Result` type.
 More informations [here](https://github.com/ReactiveX/RxSwift/releases/tag/6.0.0)

 */

/*: Exercise: Using this [API documentation](https://geo.api.gouv.fr/decoupage-administratif/communes) on the `geo.api.gouv.fr` portal, creates a `Single`
 that provides the location and INSEE code of one town in france based on this zipcode.

 **Requirements**:
 - Use `URLSession` and `Decodable` (I am not mentionning using the `RxCocoa` extension to `URLSession` and uses `.rx` extension. Develop it from scratch)
 - Properly use `Disposables.create` to cancel the web request in case the subscription occurs before the response arrives
*/

struct Location: Decodable {
    let lat: Double
    let lng: Double

    private enum CodingKeys: String, CodingKey {
        case lat = "y"
        case lng = "x"
    }
}

import CoreLocation
import PlaygroundSupport
import RxSwift

// MARK: - CommuneElement
struct CommuneElement: Decodable {
    let code, nom: String
    let centre: Centre
    let codesPostaux: [String]
}

// MARK: - Centre
struct Centre: Decodable {
    let type: String
    let coordinates: [Double]
}



func createURL(from name: String) -> URL {
    return URL(string: "https://geo.api.gouv.fr/communes?nom=\(name)&fields=code,nom,centre,codesPostaux&limit=5")!

}

func searchCommune(name: String) -> Single<[CommuneElement]> {
    return Single.never() // EDIT HERE
}

// DO NOT EDIT
PlaygroundPage.current.needsIndefiniteExecution = true


do {
    _ = searchCommune(name: "Strasbourg").subscribe(onSuccess: { print("Info: \($0)")},
                                                    onFailure: { print("Error: \($0)")


                                                        DispatchQueue.main.asyncAfter(deadline: .now() + 10.0) {
                                                            PlaygroundPage.current.finishExecution()
                                                        }
                                                    })



}



//: [Next](@next)
