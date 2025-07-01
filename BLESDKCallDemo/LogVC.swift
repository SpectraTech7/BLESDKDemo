//
//  LogVC.swift
//  BLESDKCallDemo
//
//  Created by Spectra-iOS on 23/05/25.
//

import Foundation
import UIKit


class LogVC: UIViewController {
    var logs: String = ""

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white

        let textView = UITextView(frame: view.bounds)
        textView.text = logs
        textView.isEditable = false
        textView.font = UIFont.systemFont(ofSize: 14)
        view.addSubview(textView)
    }
}
