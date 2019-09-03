#!/usr/bin/env xcrun swift

//swiftc *.swift -o run
import Foundation

let username = "martingo.studio"

let url = URL(string: "https://www.instagram.com/\(username)/")!

URLSession.shared.dataTask(with: url, completionHandler: { data, response, error in
    
    guard
        let data = data,
        (response as? HTTPURLResponse)?.statusCode == 200
    else {
        print("Username \(username) not found!")
        exit(EXIT_FAILURE)
    }
    
    guard let str = String(data: data, encoding: String.Encoding.utf8) else {
        print("Username \(username) not found!")
        exit(EXIT_FAILURE)
    }
    
    guard let status = str.getInstagramStatus() else {
        print("Username \(username) not found!")
        exit(EXIT_FAILURE)

    }
    
    let lastStatus: (Date,InstagramDB.Status)? = {
        guard let storedValue: InstagramDB = LocalStorage.read() else { return nil }
        return storedValue.getLastStatus()
    }()
    
    printToday(status: status)
    printDifference(status: status, lastStatus: lastStatus)
    
    updateValue(with: status)
    
    exit(EXIT_SUCCESS)
}).resume()

RunLoop.main.run()
