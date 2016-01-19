#SnapHTTP

An incredibly simple HTTP client library for Swift.

**Built for Swift 2.0** - For Swift 1.2 support use v0.1.10 or earlier.

## Features

- Super simple Closure API with chaining.
- Support for JSON, NSData, [UInt8], String body content.
- QueryString and Form encoding.
- Builtin JSON serialization
- Supports GET, POST, PUT, HEAD, DELETE, PATCH, OPTIONS.

## Examples

```swift
// GET - Basic request.
http.get("http://www.google.com") { resp in
    println("response: \(resp.string)")
}

// GET - Adding parameters to the request.
http.get("http://www.google.com").params(["q": "swift lang"]) { resp in
    println("response: \(resp.string)")
}

// GET - JSON response.
http.get("https://ajax.googleapis.com/ajax/services/search/web").params(["q": "Emily Dickinson", "v": "1.0"]) { resp in
    println("JSON: \(resp.json)")
}

// GET - Binary data response. NSData or [UInt8].
http.get("https://www.google.com/images/logo.png") { resp in
    println("[UInt8]: \(resp.data.length) bytes")
    println("NSData: \(count(resp.bytes)) bytes")
}

// POST - Using the `params` method will serialize the input as form data.
http.post("https://api.twitter.com/1.1/statuses/update.json").params(["status": "Or else a peacock’s purple train"]) { resp in
    println("response: \(resp.string)")
}

// POST - Posting JSON.
http.post("https://api.twitter.com/1.1/statuses/update.json").body(["status": "Or else a peacock’s purple train"]) { resp in
    println("response: \(resp.string)")
}

// POST - Posting a string.
http.post("http://domain.com").body("plain text sent to server") { resp in
    println("response: \(resp.string)")
}

// POST - Posting binary. This can be a [UInt8], NSData, or NSInputStream
var data : [UInt8] = [/* some good data */]
http.post("http://domain.com").body(data) { resp in
    println("response: \(resp.string)")
}

// Custom Headers
var imageData = NSData() // pretend we have some jpeg data 
http.post("http://domain.com").header(["Content-Type": "image/jpeg"]).body(imageData) { resp in
    println("response: \(resp.string)")
}

// Cancelling
var req = http.get("http://google.com") { resp in
    println("response: \(resp.string)")
}
req.cancel()

// Error Handling
var req = http.get("badscheme://google.com") { resp in
    if resp.error != nil {
        println("Connection error: \(resp.error!)")
        return
    }
    println("response: \(resp.string)")
}
```

##Installation (iOS and OS X)

### [Carthage]

[Carthage]: https://github.com/Carthage/Carthage

Add the following to your Cartfile:

```
github "tidwall/SnapHTTP"
```

Then run `carthage update`.

Follow the current instructions in [Carthage's README][carthage-installation]
for up to date installation instructions.

[carthage-installation]: https://github.com/Carthage/Carthage#adding-frameworks-to-an-application

The `import SnapHTTP` directive is required in order to access SnapHTTP features.

### [CocoaPods]

[CocoaPods]: http://cocoapods.org

Add the following to your [Podfile](http://guides.cocoapods.org/using/the-podfile.html):

```ruby
use_frameworks!
pod 'SnapHTTP'
```

Then run `pod install` with CocoaPods 0.36 or newer.

The `import SnapHTTP` directive is required in order to access SnapHTTP features.

###Manually

Copy the `SnapHTTP\http.swift` file into your project.  

There is no need for `import SnapHTTP` when manually installing.



## Contact
Josh Baker [@tidwall](http://twitter.com/tidwall)

## License

The SnapHTTP source code is available under the MIT License.
