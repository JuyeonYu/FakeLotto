//
//  BarcodeScannerViewController.swift
//  FakeLotto
//
//  Created by Juyeon on 2021/07/28.
//

import UIKit
import BarcodeScanner
import SnapKit
import Toaster


class ScannerViewController: UIViewController {
    let help = UIButton()
    var isFakeModeOn: Bool = false
    let baseURL = "https://m.dhlottery.co.kr/qr.do?method=winQr&v="
    override func viewDidLoad() {
        super.viewDidLoad()
        help.setImage(UIImage(systemName: "info.circle"), for: .normal)
        help.setTitle(" 사용법", for: .normal)
        help.contentMode = .scaleToFill
    }
    fileprivate func openScanner() {
        let viewController = BarcodeScannerViewController()
        viewController.codeDelegate = self
        viewController.errorDelegate = self
        viewController.view.addSubview(help)
        viewController.headerViewController.titleLabel.text = "로또 복권 QR코드 인식"
        viewController.headerViewController.navigationBar.barTintColor = .white
        viewController.headerViewController.closeButton.isHidden = true
        help.snp.makeConstraints {
            $0.width.equalTo(80)
            $0.height.equalTo(40)
            $0.leading.equalTo(viewController.cameraViewController.view)
            $0.bottom.equalTo(viewController.cameraViewController.view)
        }
        help.addTarget(self, action: #selector(onHelp(sender:)), for: .touchUpInside)
        viewController.modalPresentationStyle = .fullScreen
        viewController.messageViewController.imageView.image = UIImage(systemName: "qrcode")
        viewController.messageViewController.messages.scanningText = "로또 복권 상단에 위치한 QR코드를 카메라로 인식시켜 주세요."
        viewController.messageViewController.messages.processingText = "혹시... 로또 복권 QR코드를 인식시켜 주셨나요?"
        let touchDown = UILongPressGestureRecognizer(target:self, action: #selector(fakeModeTrigger(sender:)))
        touchDown.minimumPressDuration = 0
        touchDown.delegate = self
        viewController.view.addGestureRecognizer(touchDown)
        self.present(viewController, animated: true, completion: nil)
    }
    @objc func fakeModeTrigger(sender: UIGestureRecognizer) {
        if sender.state == .began {
            isFakeModeOn = true
        } else if sender.state == .ended {
            isFakeModeOn = false
        }
    }
    @objc func onHelp(sender: UIButton) {
        Toast(text: "화면을 터치한 상태로 QR코드를 인식하면 1등 당첨!").show()
    }
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        openScanner()
    }
}

extension ScannerViewController: BarcodeScannerCodeDelegate {
    func scanner(_ controller: BarcodeScannerViewController,
                 didCaptureCode code: String, type: String) {
        if code.contains("m.dhlottery.co.kr/") {
            let resultViewController = self.storyboard?.instantiateViewController(identifier: "ResultViewController") as! ResultViewController
            resultViewController.modalPresentationStyle = .fullScreen
            resultViewController.isFakeMode = isFakeModeOn
            resultViewController.url = baseURL + code.split(separator: "=")[1]
            controller.present(resultViewController, animated: true, completion: {
                self.isFakeModeOn = false
                controller.reset()
            })
        } else {
            controller.resetWithError(message: "로또복권 상단 QR 코드를 찍어주세요.")
        }
    }
}

extension ScannerViewController: BarcodeScannerErrorDelegate {
    func scanner(_ controller: BarcodeScannerViewController,
                 didReceiveError error: Error) {
        print(error)
    }
}

extension ScannerViewController: UIGestureRecognizerDelegate {
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldReceive touch: UITouch) -> Bool {
        if touch.view!.isKind(of: UIControl.self) {
             return false
        }
        return true
    }
}
