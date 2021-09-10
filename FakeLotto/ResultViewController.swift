//
//  ResultViewController.swift
//  FakeLotto
//
//  Created by Juyeon on 2021/07/28.
//

import UIKit
import WebKit
import Alamofire
import Toaster
import BonMot

class ResultViewController: UIViewController {
    @IBOutlet weak var header: UILabel!
    @IBOutlet weak var winDate: UILabel!
    @IBOutlet weak var status: UILabel!
    @IBOutlet weak var statusHelp: UILabel!
    @IBOutlet weak var winNumbers: UIStackView!
    @IBOutlet weak var myNumberVStackView: UIStackView!
    @IBOutlet weak var winNumber1: UILabel!
    @IBOutlet weak var winNumber2: UILabel!
    @IBOutlet weak var winNumber3: UILabel!
    @IBOutlet weak var winNumber4: UILabel!
    @IBOutlet weak var winNumber5: UILabel!
    @IBOutlet weak var winNumber6: UILabel!
    @IBOutlet weak var winNumber7: UILabel!
    @IBAction func onClose(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    var url: String!
    var isFakeMode = false
    let blueStyle = StringStyle(.color(#colorLiteral(red: 0.1641863585, green: 0.4864094853, blue: 0.7653210759, alpha: 1)))
    lazy var lottoStyle = StringStyle(
        .font(UIFont.boldSystemFont(ofSize: 17)),
        .color(.black),
        .xmlRules([.style("blue", blueStyle),])
    )
    fileprivate func setHeaderData(_ roundNumber: String,
                                   _ publicDate: String,
                                   _ noticeTop: String,
                                   _ prizezMoney: String,
                                   _ winNumbers: [String],
                                   fake myNumber: [String] = []) {
        
        self.header.attributedText = "로또 6/45 <blue>\(roundNumber)</blue>".styled(with: lottoStyle)
        self.winDate.text = publicDate
        let prizeMoney = !isFakeMode ? "총 <blue>\(prizezMoney)</blue> 당첨" : "총 3,265,051,390원 당첨"
        self.statusHelp.attributedText = prizeMoney.styled(with: lottoStyle)
        self.winNumber1.text = !isFakeMode ? winNumbers[0] : myNumber[0]
        self.winNumber2.text = !isFakeMode ? winNumbers[1] : myNumber[1]
        self.winNumber3.text = !isFakeMode ? winNumbers[2] : myNumber[2]
        self.winNumber4.text = !isFakeMode ? winNumbers[3] : myNumber[3]
        self.winNumber5.text = !isFakeMode ? winNumbers[4] : myNumber[4]
        self.winNumber6.text = !isFakeMode ? winNumbers[5] : myNumber[5]
        self.winNumber7.text = !isFakeMode ? winNumbers[6] : "\((Int(myNumber[5]) ?? 0) + 1)"
        
        self.winNumbers.subviews.forEach {
            self.setWinNumberBackgroundColor(label: $0 as! UILabel)
        }
    }
    
    fileprivate func setBodyData(_ myResultSets: [MyNumberResult], winNumbers: [String]) {
        for i in 0 ..< myResultSets.count - 5 {
            self.myNumberVStackView.subviews[i].removeFromSuperview()
        }
        myResultSets.enumerated().forEach { idx, value in
            let hStackView = self.myNumberVStackView.subviews[idx]
            hStackView.layer.borderWidth = 0.5
            hStackView.layer.borderColor = #colorLiteral(red: 0.8591541648, green: 0.8592576981, blue: 0.8591189384, alpha: 1)
            
            let order = hStackView.subviews[0] as! UILabel
            order.backgroundColor = #colorLiteral(red: 0.969401896, green: 0.9695178866, blue: 0.9693624377, alpha: 1)
            order.layer.borderWidth = 0.5
            order.layer.borderColor = #colorLiteral(red: 0.8591541648, green: 0.8592576981, blue: 0.8591189384, alpha: 1)
            order.text = value.order
            let status = hStackView.subviews[1] as! UILabel
            status.layer.borderWidth = 0.5
            status.layer.borderColor = #colorLiteral(red: 0.8591541648, green: 0.8592576981, blue: 0.8591189384, alpha: 1)
            if idx == 0 {
                status.text = !isFakeMode ? value.status : "1등 당첨"
            } else {
                status.text = value.status
            }
            
            let myNumberStackView = hStackView.subviews[2].subviews[0] as! UIStackView
            myNumberStackView.subviews.forEach {
                $0.layer.cornerRadius = $0.frame.width / 2
                $0.layer.masksToBounds = true
            }
            (myNumberStackView.subviews[0] as! UILabel).text = value.numbers[0]
            (myNumberStackView.subviews[1] as! UILabel).text = value.numbers[1]
            (myNumberStackView.subviews[2] as! UILabel).text = value.numbers[2]
            (myNumberStackView.subviews[3] as! UILabel).text = value.numbers[3]
            (myNumberStackView.subviews[4] as! UILabel).text = value.numbers[4]
            (myNumberStackView.subviews[5] as! UILabel).text = value.numbers[5]
            setMyNumberBackgroundColor(stackView: myNumberStackView, winNumbers: !isFakeMode ? winNumbers : myResultSets[0].numbers)
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let url = "https://m.dhlottery.co.kr/qr.do?method=winQr&v=0968q031326293233q081014182840q051220243040q011027293443q0816222630431959312034"
        isFakeMode = true
        winNumbers.subviews.forEach {
            $0.layer.cornerRadius = $0.frame.width / 2
            $0.backgroundColor = .clear
            $0.clipsToBounds = true
        }
        CrawlManager.crawl(url: url) { roundNumber, publicDate, prizezMoney, noticeTop, winNumbers, myResultSets in
            guard !winNumbers.isEmpty else {
                self.dismiss(animated: true) {
                    Toast(text: "미추첨 회차입니다.").show()
                }
                return
            }
            self.setHeaderData(roundNumber, publicDate, noticeTop, prizezMoney, winNumbers, fake: myResultSets[0].numbers)
            self.setBodyData(myResultSets, winNumbers: winNumbers)
        }
    }
    fileprivate func setColors(_ number: Int, _ label: UILabel) {
        if number < 10 {
            label.backgroundColor = #colorLiteral(red: 0.8956145644, green: 0.6592151523, blue: 0.08474140614, alpha: 1)
        } else if number < 20 {
            label.backgroundColor = #colorLiteral(red: 0.1971307397, green: 0.5790087581, blue: 0.8545309305, alpha: 1)
        } else if number < 30 {
            label.backgroundColor = #colorLiteral(red: 0.9108455777, green: 0.3902371824, blue: 0.3226678371, alpha: 1)
        } else if number < 40 {
            label.backgroundColor = #colorLiteral(red: 0.5609748363, green: 0.5610445142, blue: 0.5609511137, alpha: 1)
        }
        label.textColor = .white
    }
    
    func setWinNumberBackgroundColor(label: UILabel) {
        guard let number = Int(label.text ?? "") else { return }
        setColors(number, label)
    }
    func setMyNumberBackgroundColor(stackView: UIStackView, winNumbers: [String]) {
        let winNumbers = winNumbers.map { Int($0) }
        for winNumber in winNumbers {
            for label in stackView.subviews {
                let label = label as! UILabel
                guard let number = Int(label.text ?? "") else { return }
                if winNumber == number {
                    setColors(number, label)
                    break
                }
            }
        }
    }
}
