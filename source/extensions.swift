//
//  extensions.swift
//  instagram
//
//  Created by Andre Martingo on 19.08.19.
//  Copyright © 2019 Andre Martingo. All rights reserved.
//

import Foundation

extension String {
    
    func getInstagramStatus() -> InstagramDB.Status? {
        guard let content = self.range(of: "meta content")?.lowerBound else { return nil }
        let initial = self.index(content, offsetBy: Constants.instagramOffset)
        guard let final = self.range(of: "Posts")?.upperBound else { return nil }
        let range = initial ..< final
        let status = String(self[range]).split(separator: " ")
        guard
            let followers = Int(status[0]),
            let following = Int(status[2]),
            let posts = Int(status[4])
        else { return nil}
        return InstagramDB.Status(followers: followers, following: following, posts: posts)
    }
    
    enum Constants {
        static let instagramOffset = 14
    }
}

extension Date {

    func stripTime() -> Date {
        var calendar = Calendar.current
        calendar.timeZone = TimeZone(identifier: "GMT")!
        let components = calendar.dateComponents([.year, .month, .day], from: self)
        return calendar.date(from: components)!
    }

}

struct InstagramDB: Codable {
    struct Status: Codable {
        let followers: Int
        let following: Int
        let posts: Int
    }
    var storage: [Date: Status]
    
    func getLastStatus() -> (Date,Status)? {
        let status = storage.keys.sorted().last.flatMap { storage[$0] }
        let date = storage.keys.sorted().last
        return status.flatMap { status in
            date.flatMap { ($0,status) }
        }
    }
}

func updateValue(with status: InstagramDB.Status) {
    let storedValue: InstagramDB? = LocalStorage.read()
    let instagram: InstagramDB = {
        if var value = storedValue {
            value.storage[Date().stripTime()] = status
            return value
        } else {
            return InstagramDB(storage: [Date().stripTime(): status])
        }
    }()
    try? LocalStorage.write(collection: instagram)
}

func printToday(status: InstagramDB.Status) {
    print("📅 TODAY:")
    print("Followers: \(status.followers)")
    print("Following: \(status.following)")
    print("Posts:     \(status.posts)")
    print("------------------------------------------------")
}

func printDifference(status: InstagramDB.Status, lastStatus: (Date,InstagramDB.Status)?) {
    let dateFormatter = DateFormatter()
    let formatter = NumberFormatter()
    formatter.minimumFractionDigits = 0
    dateFormatter.dateFormat = "dd-MM-yyyy"
    lastStatus.flatMap {
        let followersDifference: Double = Double(status.followers - $0.1.followers) / Double($0.1.followers) * 100
        let followingDifference: Double = Double(status.following - $0.1.following) / Double($0.1.following) * 100
        let postsDifference: Double = Double(status.posts - $0.1.posts) / Double($0.1.posts) * 100
        print("🚀 LAST TIME (\(dateFormatter.string(from: $0.0))):")
        print("Followers: \($0.1.followers)  ->  \(status.followers) \(String(describing: formatter.string(from: followersDifference as NSNumber)!))%")
        print("Following: \($0.1.following)  ->  \(status.following) \(String(describing: formatter.string(from: followingDifference as NSNumber)!))%")
        print("Posts:     \($0.1.posts)   ->  \(status.posts)  \(String(describing: formatter.string(from: postsDifference as NSNumber)!))%")
      }
    print("------------------------------------------------")
}
