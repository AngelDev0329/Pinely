//
//  Network.swift
//  Pinely
//

import Foundation
import Alamofire
import FirebaseAppCheck
import FirebaseInstallations

// swiftlint:disable type_body_length
// swiftlint:disable identifier_name
class Network {
    let session = Alamofire.Session()

    private func buildHeaders(_ headers: [String: String] = [:]) -> HTTPHeaders {
        var finalHeaders = [
            "User-Agent": ":[\\IekqUjR|4AcV1Cj\\g",
            "key-app": "S^99KRtA7}S7;Ly*ki}C"
        ] as HTTPHeaders
        for header in headers {
            finalHeaders[header.key] = header.value
        }
        return finalHeaders
    }

    func getObjectJs(useCache: Bool, route: RouteJS, args: [String: Any], delegate: @escaping (_ result: [String: Any], _ error: Error?) -> Void) {
        var fullUrl = route.url
        var isFirst = true
        args.keys.forEach { k in
            let v = "\(args[k]!)".addingPercentEncoding(withAllowedCharacters: .urlHostAllowed)!
            if isFirst {
                fullUrl += "?"
                isFirst = false
            } else {
                fullUrl += "&"
            }
            fullUrl += "\(k)=\(v)"
        }

        let url = URL(string: fullUrl)!
        var urlRequest = (try? URLRequest(url: url, method: .get, headers: nil)) ?? URLRequest(url: url)
        if !useCache {
            URLCache.shared.removeCachedResponse(for: urlRequest)
            urlRequest.cachePolicy = .reloadIgnoringCacheData
        }

        urlRequest.headers = buildHeaders()

        session.request(fullUrl)
            .responseString { (result) in
                if let str = try? result.result.get() {
                    print("Request: \(fullUrl)")
                    print("Response: \(str)")
                }
            }
            .responseJSON { (result) in
                switch result.result {
                case .success(let value):
                    if value is [Any] {
                        delegate([
                            "success": 1,
                            "results": value as? [Any] ?? []
                        ], nil)
                    } else {
                        delegate(value as? [String: Any] ?? [:], nil)
                    }

                case .failure(_):
                    delegate([:], NetworkError.serverError)
                }
            }
    }

    func postObjectJs(useCache: Bool, route: RouteJS, args: [String: Any], delegate: @escaping (_ result: [String: Any], _ error: Error?) -> Void) {
        let data: Data
        do {
            data = try JSONSerialization.data(withJSONObject: args, options: .fragmentsAllowed)
        } catch {
            print(error.localizedDescription)
            data = Data()
        }

        let fullUrl = route.url
        var urlRequest = URLRequest(url: URL(string: fullUrl)!)
        urlRequest.method = .post
        urlRequest.httpMethod = "POST"
        urlRequest.httpBody = data
        if !useCache {
            URLCache.shared.removeCachedResponse(for: urlRequest)
            urlRequest.cachePolicy = .reloadIgnoringCacheData
        }

        urlRequest.headers = buildHeaders([
            "Accept": Headers.applicationJson.rawValue,
            "Content-Type": Headers.applicationJson.rawValue
        ])

        session.request(urlRequest)
            .responseString { (result) in
                if let str = try? result.result.get() {
                    print("Request: \(fullUrl)")
                    print("Response: \(str)")
                }
            }
            .responseJSON { (result) in
                switch result.result {
                case .success(let value):
                    delegate(value as? [String: Any] ?? [:], nil)

                case .failure(_):
                    delegate([:], NetworkError.serverError)
                }
            }
    }

    private func createMultipartFormData(args: [String: Any], mimeType: String, multipartFormData: MultipartFormData) {
        args.keys.forEach {
            let val = args[$0]!
            if let valData = val as? Data {
                let fileName: String
                switch mimeType {
                case "image/jpeg":
                    fileName = "\($0).jpg"

                case "image/png":
                    fileName = "\($0).png"

                case "application/pdf":
                    fileName = "\($0).pdf"

                default:
                    fileName = "\($0)"
                }
                multipartFormData.append(valData, withName: $0, fileName: fileName, mimeType: mimeType)
            } else {
                multipartFormData.append("\(val)".data(using: .utf8)!, withName: $0)
            }
        }
    }

    func uploadObjectJs(route: RouteJS, args: [String: Any], mimeType: String,
                        delegate: @escaping (_ result: [String: Any], _ error: Error?) -> Void) {
        var fullUrl = route.url
        var argsProcessed: [String: Any] = [:]
        for arg in args {
            if arg.key.starts(with: "$") {
                fullUrl = fullUrl.replacingOccurrences(of: arg.key, with: "\(arg.value)")
            } else {
                argsProcessed[arg.key] = arg.value
            }
        }
        session
            .upload(
                multipartFormData: { (multipartFormData) in
                    self.createMultipartFormData(args: args, mimeType: mimeType, multipartFormData: multipartFormData)
                },
                to: fullUrl
            )
            .responseString { (result) in
                if let resultString = try? result.result.get() {
                    print("Request: \(fullUrl)")
                    print("Response: \(resultString)")
                }
            }
            .responseJSON { (result) in
                switch result.result {
                case .success(let value):
                    delegate(value as? [String: Any] ?? [:], nil)

                case .failure(_):
                    delegate([:], NetworkError.serverError)
                }
            }
    }

    func uploadObjectCf(route: RouteCF, args: [String: Any], delegate: @escaping (_ result: [String: Any], _ error: Error?) -> Void) {
        let fullUrl = route.url
        session
            .upload(
                multipartFormData: { (multipartFormData) in
                    self.createMultipartFormData(args: args, mimeType: "image/jpeg", multipartFormData: multipartFormData)
                },
                to: fullUrl
            )
            .responseString { (result) in
                if let str = try? result.result.get() {
                    print("Request: \(fullUrl)")
                    print("Response: \(str)")
                }
            }
            .responseJSON { (result) in
                switch result.result {
                case .success(let value):
                    delegate(value as? [String: Any] ?? [:], nil)

                case .failure(_):
                    delegate([:], NetworkError.serverError)
                }
            }
    }

    func postObjectCf(useCache: Bool, route: RouteCF, args: [String: Any], delegate: @escaping (_ result: [String: Any], _ error: Error?) -> Void) {
        var isFirst = true
        var dataString = ""
        args.keys.forEach { k in
            let v = "\(args[k]!)".addingPercentEncoding(withAllowedCharacters: .urlHostAllowed)!
                .replacingOccurrences(of: "&", with: "%26").replacingOccurrences(of: "+", with: "%2B")
            if isFirst {
                isFirst = false
            } else {
                dataString += "&"
            }
            dataString += "\(k)=\(v)"
        }

        let data = dataString.data(using: .utf8)

        let fullUrl = route.url
        var urlRequest = URLRequest(url: URL(string: fullUrl)!)
        urlRequest.method = .post
        urlRequest.httpMethod = "POST"
        urlRequest.httpBody = data
        if !useCache {
            URLCache.shared.removeCachedResponse(for: urlRequest)
            urlRequest.cachePolicy = .reloadIgnoringCacheData
        }

        urlRequest.headers = buildHeaders()

        session.request(urlRequest)
            .responseString { (result) in
                if let str = try? result.result.get() {
                    print("Request: \(fullUrl)")
                    print("Response: \(str)")
                }
            }
            .responseJSON { (result) in
                switch result.result {
                case .success(let value):
                    if let r = value as? [String: Any] {
                        delegate(r, nil)
                    } else if let r = value as? [Any] {
                        delegate([
                            "success": 1,
                            "results": r
                        ], nil)
                    } else {
                        delegate([:], nil)
                    }

                case .failure(_):
                    delegate([:], NetworkError.serverError)
                }
            }
    }

    func getObjectCf(useCache: Bool, route: RouteCF, args: [String: Any], delegate: @escaping (_ result: [String: Any], _ error: Error?) -> Void) {
        var isFirst = true
        var dataString = ""
        args.keys.forEach { k in
            let v = "\(args[k]!)".addingPercentEncoding(withAllowedCharacters: .urlHostAllowed)!
                .replacingOccurrences(of: "&", with: "%26").replacingOccurrences(of: "+", with: "%2B")
            if isFirst {
                isFirst = false
            } else {
                dataString += "&"
            }
            dataString += "\(k)=\(v)"
        }

        var fullUrl = route.url
        if !dataString.isEmpty {
            fullUrl += "?\(dataString)"
        }
        var urlRequest = URLRequest(url: URL(string: fullUrl)!)
        urlRequest.method = .get
        urlRequest.httpMethod = "GET"
        if !useCache {
            URLCache.shared.removeCachedResponse(for: urlRequest)
            urlRequest.cachePolicy = .reloadIgnoringCacheData
        }

        urlRequest.headers = buildHeaders()

        session.request(urlRequest)
            .responseString { (result) in
                if let resultString = try? result.result.get() {
                    print("Request: \(fullUrl)")
                    print("Response: \(resultString)")
                }
            }
            .responseJSON { (result) in
                switch result.result {
                case .success(let value):
                    if let r = value as? [String: Any] {
                        delegate(r, nil)
                    } else if let r = value as? [Any] {
                        delegate([
                            "success": 1,
                            "results": r
                        ], nil)
                    } else {
                        delegate([:], nil)
                    }

                case .failure(_):
                    delegate([:], NetworkError.serverError)
                }
            }
    }
    
}
