# RxSwift vs. ReactiveSwift (feat. MVVM and Clean Swift)

## Overview

The initial purpose of this project was to compare the differences between [RxSwift](https://github.com/ReactiveX/RxSwift), [ReactiveCocoa](https://github.com/ReactiveCocoa/ReactiveCocoa), and [ReactiveSwift](https://github.com/ReactiveCocoa/ReactiveSwift), three popular libraries for adding [Functional Reactive Programming (FRP)](https://en.wikipedia.org/wiki/Functional_reactive_programming) paradigms to iOS Applications. In a nutshell, FRP makes [asynchronous programming](https://en.wikipedia.org/wiki/Asynchrony_(computer_programming)) (a struggle for devs of all creeds) elegant and centralized. 

What do I mean by centralized? Well, there are almost too many use cases for asynchronous programming for me to count, but essentially asynchronous programming is necessary whenever we have some **event** that we'd like to **observe**—a button tap, a network response, or a change in user's location are all great examples. 

Swift has an army of powerful tools such as [Key-Value Observing](https://developer.apple.com/library/archive/documentation/Cocoa/Conceptual/KeyValueObserving/Articles/KVOImplementation.html), [callbacks](https://docs.swift.org/swift-book/LanguageGuide/Closures.html), and [Protocol-Delegate patterns](https://docs.swift.org/swift-book/LanguageGuide/Protocols.html) to help us, but getting used to all of them can take quite a long time (not to mention, there are many tools on the way: see [async-await for Swift](https://gist.github.com/lattner/429b9070918248274f25b714dcfc7619)). FRP, and most notably the aforementioned frameworks, define a standard interface for events of all kinds. This allows us to map and filter (even reduce!) them quickly and easily.

I mentioned the "initial" purpose of this project was to compare RxSwift, ReactiveCocoa, and ReactiveSwift, and the astute will notice that ReactiveCocoa is missing from the title of this README. Well, what I didn't know is that ReactiveCocoa is essentially built on top of/an extension of ReactiveSwift, so I decided that it would suffice to do a direct comparison between just RxSwift and ReactiveSwift.

## The Test

When thinking of an appropriate project to build, I naturally jumped to something of large socioeconomic value—a cat fact generator (Actually, it was more like I was looking for cool APIs to use… and I found [this Medium article](https://medium.com/@vicbergquist/18-fun-apis-for-your-next-project-8008841c7be9) with a good list of them). In all seriousness, I decided the event that I wanted to simulate was a network call/response, which APIs are perfect for.

In addition to evaluating both frameworks, I also wanted to test how they would fit into two architectures for iOS Projects: MVVM and Clean Swift. Keep reading if you want a brief overview with each, else <a href="#here">click here</a> to skip ahead.

### MVVM

[MVVM](https://en.wikipedia.org/wiki/Model–view–viewmodel) (which stands for Model-View-ViewModel) relies pretty heavily on reactive programming. It essentially involves a ViewModel object that contains almost all of the "logic" for a given scene/screen in an app. It is owned by a View Controller which is supposed to be a completely dumb object that sets label texts, images, views, etc. as the ViewModel sees fit. 

As an example, suppose I have a text field and a button (objects owned by the View Controller). On a button tap, I want to [POST](https://en.wikipedia.org/wiki/POST_(HTTP)) whatever the user entered into the text field to some URL. Then, I'll wait for a response containing some text and once I receive it, I'll display it to the user (using a label or something). In pseudocode, MVVM would handle the scenario like this:

```swift
class ViewController: UIViewController {
    @IBOutlet var textField: UITextField!
    @IBOutlet var showLabel: UILabel!
    
    var viewModel = ViewModel()
    
    @IBAction func didTapButton(_ sender: UIButton!) {
        viewModel.send(text: textField.text)
    }
    
    func showText(text: String) {
        showLabel.text = text
    }
}

class ViewModel {
    weak var viewController: ViewController!
    
    func send(text: String!) {
        postToURL(text, onResponse: { (responseText) in
            viewController.showText(text: responseText)
        })
    }
}
```

This code is not optimal by any means! Even assuming we have a nice elegant function like `postToURL()`, notice that in this example the ViewController class needs a reference to its ViewModel and the ViewModel class needs a reference to its ViewController… a potential for [strong reference cycles](https://cocoacasts.com/what-are-strong-reference-cycles) (luckily I, as a stellar pseudocoder, have avoided this `:^)`). You'll see in the project how using reactive programming makes this code a little cleaner and gets rid of cycles.

### Clean Swift

[Clean Swift](https://clean-swift.com) is a relatively new, somewhat [hipster](https://www.urbandictionary.com/define.php?term=Before%20it%20was%20cool) archiecture largely based on the [VIPER](https://www.objc.io/issues/13-architecture/viper/) architecture. It mainly involves View Controller, Interactor, and Presenter objects that interface with each other to perform a "VIP Cycle" everytime some independent task needs to be done. Although it seems like overkill, Clean Swift makes [test-driven development (TDD)](https://en.wikipedia.org/wiki/Test-driven_development), which has relatively poor support despite its value, insanely simple. Let's break down each of the components in slightly more detail.

The View Controller, unlike in MVVM, isn't completely dumb: it owns all view-related logic. For example, it's okay to construct additional subviews in the View Controller in Clean Swift—in MVVM, it would be more correct to ask the ViewModel to construct them, then do a quick `view.addSubview()` in the View Controller once the ViewModel graciously returns them. 

The Interactor is in charge of all [business logic](https://whatis.techtarget.com/definition/business-logic) (i.e. anything related to the back-end of your app). It's responsible for making all network calls and awaiting for their responses. More technically, it can employ some Worker objects to help out, but again it's mostly useful to think of the Interactor as in charge of the "behind-the-scenes" logic.

The Presenter is in charge of taking the raw data retrieved by the Interactor and formatting it as needed. This can include extracting the necessary fields from JSON dictionaries, determining what [colour](http://www.lukemastin.com/testing/spelling/cgi-bin/database.cgi?action=rules) text should be displayed in, and ensuring that strings are capitalized. 

Data needs to flow between the View Controller, Interactor, and Presenter, and as an added constraint Clean Swift requires that this data is only of **simple** types—no classes, just value types, collections, and structs. We use RequestData, ResponseData, and ViewData objects to encapsulate these. Here's a fun diagram:

```
V  --RequestData-->  I  --ResponseData--> P  --ViewData-->  V
```

Let's put it all together! Using the same example as above, let's mock out its VIP Cycle:

1. On button tap, View Controller sends data to the Interactor.
2. The Interactor POSTs the data to the proper URL and awaits a response.
3. On response, it sends the data to the Presenter.
4. The Presenter formats the data and passes it back to the View Controller
5. The View Controller displays the data and the cycle is complete.

And in pseudocode:

```Swift
struct RequestData {
    var text: String
}
struct ResponseData {
    var responseText: String
}
struct ViewData {
    var displayText: String
}

class ViewController: UIViewController {
    @IBOutlet var textField: UITextField!
    @IBOutlet var showLabel: UILabel!
    
    var interactor: Interactor!
    
    @IBAction func didTapButton(_ sender: UIButton!) {
        // VIP Cycle starts here
        
        let request = RequestData(text: textField.text!)
        interactor.getResource(request)
    }
    
    func displayResource(_ viewData: ViewData) {
        // VIP Cycle ends here
        let displayText = viewData.displayText
        
        showLabel.text = displayText
    }
}

class Interactor {
    var presenter: Presenter!
    
    func getResource(_ request: RequestData) {
        let text = request.text
        
        postToURL(text, onResponse: { (responseText) in
            let response = ResponseData(responseText: responseText)
            presenter.presentResource(response)
        })
    }
}

class Presenter {
    weak var viewController: ViewController!
    
    func presentResource(_ response: ResponseData) {
        let responseText = response.responseText
        
        let displayText = responseText.capitalized
        let viewData = ViewData(displayText: displayText)
        viewController.displayResource(viewData)
    }
}
```

Again, seems like overkill for something so trivial. But notice how all of the logic is **decoupled**—this makes bug-catching pretty easy in the future. And although this implementation is by no means how true Clean Swift works, trust me when I say that it makes writing Unit Tests trivial!

<a id="here"></a>