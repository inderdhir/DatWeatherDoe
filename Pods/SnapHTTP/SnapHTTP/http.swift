/*
* SnapHTTP (http.swift)
*
* Copyright (C) 2015 ONcast, LLC. All Rights Reserved.
* Created by Josh Baker (joshbaker77@gmail.com)
*
* This software may be modified and distributed under the terms
* of the MIT license.  See the LICENSE file for details.
*
*/

import Foundation

/// A global HTTP instance.
public let http = HTTP()

/// The HTTP object provides support for creating server requests.
public class HTTP {
    /// The HTTP.Response object contains the results of a server request.
    public class Response : CustomStringConvertible {
        /// The raw binary data of the response body content.
        public let data : NSData
        /// The HTTP header keys and values.
        public let headers : [String: String]
        /// A connection error. This only occures when the request cannot establish an HTTP connection.
        public let error : ErrorType?
        /// The HTTP status code of the response.
        public let statusCode : Int
        private let resp : NSHTTPURLResponse
        private init(data : NSData, resp : NSHTTPURLResponse){
            self.data = data
            self.resp = resp
            var nheaders = [String: String]()
            for (key, value) in resp.allHeaderFields {
                if let skey = key as? String {
                    if let svalue = value as? String {
                        nheaders[skey] = svalue
                    }
                }
            }
            headers = nheaders
            error = nil
            statusCode = resp.statusCode
        }
        private init(error: NSError) {
            self.error = error
            (data, resp, headers, statusCode) = (NSData(), NSHTTPURLResponse(), [String: String](), 400)
        }
        private var _string : String?
        /// A string representation of the response body content.
        public var string : String {
            if _string == nil{
                _string = NSString(data: data, encoding: NSUTF8StringEncoding) as? String
            }
            if _string == nil {
                return ""
            }
            return _string!
        }
        private var _json : AnyObject?
        private var _jsonError : NSError?
        /// A deserialized JSON representation of the response body content.
        public var json : AnyObject {
            if _json == nil && _jsonError == nil {
                do {
                    _json = try NSJSONSerialization.JSONObjectWithData(data, options: .AllowFragments)
                } catch let error as NSError {
                    _jsonError = error
                    _json = nil
                }
                if _json == nil {
                    _json = Dictionary<String,AnyObject>()
                }
            }
            return _json!
        }
        private var _bytes : [UInt8]?
        /// An array of UInt8 as a representation of the response body content.
        public var bytes : [UInt8] {
            if _bytes == nil {
                _bytes = [UInt8](count: data.length, repeatedValue: 0)
                memcpy(&(_bytes!), data.bytes, data.length)
            }
            return _bytes!
        }
//        private var _image : UIImage?
//        /// A UIImage representation of the response body. The body must be valid image data.
//        public var image : UIImage {
//            if _image == nil {
//                _image = UIImage(data: data)
//                if _image == nil {
//                    _image = UIImage()
//                }
//            }
//            return _image!
//        }
        /// A serialized HTTP payload. This method is only intended for diagnostics and cannot be trusted for transmissions.
        public var description : String {
            let statusText : String
            if statusCode == 200 {
                statusText = "OK"
            } else {
                statusText = NSHTTPURLResponse.localizedStringForStatusCode(statusCode)
            }
            var string = "HTTP/1.1 \(statusCode) \(statusText)\r\n"
            for (key, value) in headers {
                string += "\(key): \(value)\r\n"
            }
            if let error = error as? NSError {
                string += "X-Client-Error-Code: \(error.code)\r\n"
                string += "X-Client-Error-Domain: \(error.domain)\r\n"
                string += "\r\n\(error.localizedDescription)"
            } else {
                let type = headers["Content-Type"]
                if type != nil && type!.hasPrefix("text/") || type!.hasPrefix("application/json") {
                    string += "\r\n\(self.string)"
                } else {
                    string += "\r\nexcluding binary data"
                }
            }
            return string
        }
    }
    private static let closure : (resp : Response)->Void = {_ in}

    /// The HTTP.Response object provides support for connecting to the a server.
    public class Request {
        private var mutex = pthread_mutex_t()
        private var closure : (resp : Response)->Void
        private var method : String
        private var url : String
        private var content : Any
        private var interval = NSTimeInterval(10)
        private var policy = NSURLRequestCachePolicy.UseProtocolCachePolicy
        private var headers = [String: String]()
        private var params = [String: AnyObject]()
        private var requested = false
        private var cancelled = false
        private func lock(closure : ()->()) {
            pthread_mutex_lock(&mutex)
            closure()
            pthread_mutex_unlock(&mutex)
        }
        /// Cancels the request.
        public func cancel() {
            lock {
                self.cancelled = true
            }
        }
        /// Adds and Authorization header value to the request.
        public func auth(value : String, closure : (resp : Response)->Void = HTTP.closure) -> Request {
            return self.header(["Authorization": value], closure: closure)
        }
        /// Append header values to the request.
        public func header(keyValues : [String: String], closure : (resp : Response)->Void = HTTP.closure) -> Request {
            lock {
                for (key, value) in keyValues {
                    self.headers[key] = value
                }
                (self.closure, self.requested) = (closure, false)
            }
            return self
        }
        /// Assign body content to the request. This can be a String, [UInt8], NSData, NSInputStream, or an object that can be serialized to JSON.
        public func body(content : Any, closure : (resp : Response)->Void = HTTP.closure) -> Request {
            lock {
                self.content = content
                (self.closure, self.requested) = (closure, false)
            }
            return self
        }
        /// Assigns parameters to the request. For requests such as GET, HEAD, and those which have body content, this is assigned to the query of the URL. Otherwise this is serialized as form data in the body content of the request.
        public func params(keyValues : [String : AnyObject], closure : (resp : Response)->Void = HTTP.closure) -> Request {
            lock {
                for (key, value) in keyValues {
                    self.params[key] = value
                }
                (self.closure, self.requested) = (closure, false)
            }
            return self
        }
        /// Force a hard timeout for the request. Default is 10 seconds.
        public func timeout(interval : NSTimeInterval, closure : (resp : Response)->Void = HTTP.closure) -> Request {
            lock {
                self.interval = interval
                (self.closure, self.requested) = (closure, false)
            }
            return self
        }
        /// Set the cache policy of the request. Default is .UseProtocolCachePolicy.
        public func cache(policy : NSURLRequestCachePolicy, closure : (resp : Response)->Void = HTTP.closure) -> Request {
            lock {
                self.policy = policy
                (self.closure, self.requested) = (closure, false)
            }
            return self
        }
        private init(method : String, url : String, closure : (resp : Response)->Void = HTTP.closure){
            pthread_mutex_init(&mutex, nil)
            self.method = method
            self.url = url
            self.content = false
            (self.closure, self.requested) = (closure, false)
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 0), dispatch_get_main_queue()) {
                var cancelled = false
                self.lock {
                    cancelled = self.cancelled
                }
                if cancelled {
                    return
                }
                dispatch_async(dispatch_queue_create(nil, nil)) {
                    var closure = HTTP.closure
                    var error : NSError?
                    var req : NSMutableURLRequest?
                    self.lock {
                        var nilContent = false
                        if let b = self.content as? Bool {
                            nilContent = b == false
                        }
                        var urlStr = self.url
                        var formContent : String?
                        if self.params.count > 0 {
                            var (paramStr, paramArr) = ("", [String]())
                            for (key, value) in self.params {
                                let k = key.stringByAddingPercentEncodingWithAllowedCharacters(.URLHostAllowedCharacterSet())!
                                if let s = value as? [AnyObject] {
                                    for v in s {
                                        paramArr += ["\(k)=" + "\(v)".stringByAddingPercentEncodingWithAllowedCharacters(.URLHostAllowedCharacterSet())!]
                                    }
                                } else {
                                    paramArr += ["\(k)=" + "\(value)".stringByAddingPercentEncodingWithAllowedCharacters(.URLHostAllowedCharacterSet())!]
                                }
                            }
                            paramStr = paramArr.joinWithSeparator("&")
                            let query : Bool
                            switch self.method {
                            case "GET", "HEAD", "DELETE":
                                query = true
                            default:
                                query = !nilContent
                            }
                            if query {
                                if urlStr.rangeOfString("?") != nil {
                                    urlStr += "&" + paramStr
                                } else {
                                    urlStr += "?" + paramStr
                                }
                            } else {
                                formContent = paramStr
                            }
                        }
                        let url = NSURL(string: urlStr)
                        if url == nil {
                            error = NSError(domain: NSURLErrorDomain, code: NSURLErrorUnsupportedURL, userInfo: [NSLocalizedDescriptionKey: "unsupported URL"])
                            return
                        }
                        req = NSMutableURLRequest(URL: url!, cachePolicy: self.policy, timeoutInterval: self.interval)
                        req!.HTTPMethod = self.method
                        if let form = formContent {
                            req!.HTTPBody = form.dataUsingEncoding(NSUTF8StringEncoding)
                            req!.setValue("application/x-www-form-urlencoded; charset=UTF-8", forHTTPHeaderField: "Content-Type")
                        } else if !nilContent {
                            if let body = self.content as? NSData  {
                                req!.HTTPBody = body
                            } else if let body = self.content as? [UInt8] {
                                var bodym = body
                                req!.HTTPBody = NSData(bytes: &bodym, length: body.count)
                            } else if let body = self.content as? String {
                                req!.HTTPBody = body.dataUsingEncoding(NSUTF8StringEncoding)
                                req!.setValue("text/plain; charset=UTF-8", forHTTPHeaderField: "Content-Type")
                            } else if let stream = self.content as? NSInputStream {
                                req!.HTTPBodyStream = stream
                            } else if let dict : AnyObject = self.content as? AnyObject {
                                if dict is [AnyObject] || dict is [String: AnyObject] {
                                    do {
                                        req!.HTTPBody = try NSJSONSerialization.dataWithJSONObject(dict, options: NSJSONWritingOptions(rawValue: 0))
                                    } catch let error1 as NSError {
                                        error = error1
                                        req!.HTTPBody = nil
                                    } catch {
                                        fatalError()
                                    }
                                    req!.setValue("application/json", forHTTPHeaderField: "Content-Type")
                                } else {
                                    error = NSError(domain: NSURLErrorDomain, code: NSURLErrorDataNotAllowed, userInfo: [NSLocalizedDescriptionKey: "invalid body content"])
                                }
                            }
                        }
                        for (key, value) in self.headers {
                            req!.setValue(value, forHTTPHeaderField: key)
                        }
                        closure = self.closure
                    }
                    var hres : NSHTTPURLResponse?
                    var data : NSData?
                    if error == nil {
                        var res : NSURLResponse?
                        do {
                            data = try NSURLConnection.sendSynchronousRequest(req!, returningResponse: &res)
                        } catch let error1 as NSError {
                            error = error1
                            data = nil
                        } catch {
                            fatalError()
                        }
                        if error == nil {
                            hres = res as? NSHTTPURLResponse
                            if hres == nil {
                                error = NSError(domain: NSURLErrorDomain, code: NSURLErrorBadServerResponse, userInfo: [NSLocalizedDescriptionKey: "bad server response"])
                            } else {
                                if data == nil {
                                    data = NSData()
                                }
                            }
                        }
                    }
                    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 0), dispatch_get_main_queue()) {
                        if error != nil {
                            closure(resp: Response(error: error!))
                        } else {
                            closure(resp: Response(data: data!, resp: hres!))
                        }
                    }
                }
            }
        }
        deinit {
            pthread_mutex_destroy(&mutex)
        }
    }
    /// Make a POST request to the specified URL.
    public func get(url : String, closure : (resp : Response)->Void = HTTP.closure) -> Request {
        return Request(method: "GET", url: url, closure: closure)
    }
    /// Make a POST request to the specified URL.
    public func post(url : String, closure : (resp : Response)->Void = HTTP.closure) -> Request {
        return Request(method: "POST", url: url, closure: closure)
    }
    /// Make a PUT request to the specified URL.
    public func put(url : String, closure : (resp : Response)->Void = HTTP.closure) -> Request {
        return Request(method: "PUT", url: url, closure: closure)
    }
    /// Make a DELETE request to the specified URL.
    public func delete(url : String, closure : (resp : Response)->Void = HTTP.closure) -> Request {
        return Request(method: "DELETE", url: url, closure: closure)
    }
    /// Make a PATCH request to the specified URL.
    public func patch(url : String, closure : (resp : Response)->Void = HTTP.closure) -> Request {
        return Request(method: "PATCH", url: url, closure: closure)
    }
    /// Make a OPTIONS request to the specified URL.
    public func options(url : String, closure : (resp : Response)->Void = HTTP.closure) -> Request {
        return Request(method: "OPTIONS", url: url, closure: closure)
    }
    /// Make a HEAD request to the specified URL.
    public func head(url : String, closure : (resp : Response)->Void = HTTP.closure) -> Request {
        return Request(method: "HEAD", url: url, closure: closure)
    }
}
