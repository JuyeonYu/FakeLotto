//
//  CrawlManager.swift
//  FakeLotto
//
//  Created by Juyeon on 2021/07/28.
//

import Foundation
import Alamofire
import SwiftSoup

struct CrawlManager {
    static func crawl(url: String, completionHandler: @escaping ((String,
                                                                  String,
                                                                  String,
                                                                  String,
                                                                  [String],
                                                                  [MyNumberResult]) -> ())) {
        AF.request(url, method: .get).responseString { (response) in
            guard var html = response.value else {
                return
            }

            if let data = response.data {
                let encodedHtml = NSString(data: data, encoding: CFStringConvertEncodingToNSStringEncoding( 0x0422 ) )
                if let encodedHtml = encodedHtml {
                    html = encodedHtml as String
                }
            }
            do {
                let doc: Document = try SwiftSoup.parse(html)
                let roundNumber = try doc.select(".key_clr1").first()?.text() ?? ""
                let publicDate = try doc.select(".date").first()?.text() ?? ""
                var prizezMoney = ""
                if try doc.select(".key_clr1").count > 1 {
                    prizezMoney = try doc.select(".key_clr1")[1].text()
                }
                let noticeTop = try doc.select("#container > div > div.winner_number > div.bx_notice.winner > div > span").first()?.text() ?? ""
                let winNumbers = try doc.select("#container > div > div.winner_number > div.bx_winner.winner > div").text().split(separator: " ").map {
                    String($0)
                }
                guard !winNumbers.isEmpty else {
                    completionHandler("", "", "", "", [], [])
                    return
                }
                let myNumbersTable = try doc.select("#container > div > div.list_my_number > div > table > tbody > tr").text().split(separator: " ")
                var myResultSets: [MyNumberResult] = []
                for i in 0 ..< myNumbersTable.count / 8 {
                    myResultSets.append(MyNumberResult(order: String(myNumbersTable[i * 8]),
                                                       status: String(myNumbersTable[i * 8 + 1]),
                                                       numbers: [String(myNumbersTable[i * 8 + 2]),
                                                                String(myNumbersTable[i * 8 + 3]),
                                                                String(myNumbersTable[i * 8 + 4]),
                                                                String(myNumbersTable[i * 8 + 5]),
                                                                String(myNumbersTable[i * 8 + 6]),
                                                                String(myNumbersTable[i * 8 + 7])]))
                }
                completionHandler(roundNumber, publicDate, prizezMoney, noticeTop, winNumbers, myResultSets)
            } catch {
                print("crawl error")
            }
        }
    }

}
