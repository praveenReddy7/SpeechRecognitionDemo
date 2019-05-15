//
//  CLVoiceRegcognitionController.swift
//  SpeechRecognitionDemo
//
//  Created by praveen on 5/15/19.
//  Copyright © 2019 focussoftnet. All rights reserved.
//

import UIKit

class CLVoiceRecognitionController: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = .clear
        self.view.isOpaque = false
        self.view.backgroundColor = UIColor.black.withAlphaComponent(0.5)
        self.modalTransitionStyle = .crossDissolve
        self.modalPresentationStyle = .overCurrentContext
        
        let indicatorLabel = UILabel()
        indicatorLabel.translatesAutoresizingMaskIntoConstraints = false
        indicatorLabel.font = UIFont.systemFont(ofSize: 30, weight: .bold)
        indicatorLabel.text = "Listening..."
        indicatorLabel.textColor = .white
        view.addSubview(indicatorLabel)
        
        indicatorLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 100).isActive = true
        indicatorLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
        NSLayoutConstraint(item: indicatorLabel,
                           attribute: .centerY,
                           relatedBy: .equal,
                           toItem: view,
                           attribute: .centerY,
                           multiplier: 0.3,
                           constant: 0).isActive = true
        indicatorLabel.heightAnchor.constraint(equalToConstant: 40).isActive = true
        
        
        let micBtn = UIButton()
        micBtn.translatesAutoresizingMaskIntoConstraints = false
        micBtn.setImage(UIImage(named: "Microphone.png"), for: .normal)
        micBtn.addTarget(self, action: #selector(voiceSearchiInitiated(_:)), for: .touchUpInside)
        view.addSubview(micBtn)

        micBtn.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        micBtn.centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true
        micBtn.widthAnchor.constraint(equalToConstant: 60).isActive = true
        micBtn.heightAnchor.constraint(equalToConstant: 60).isActive = true
        
        let dismissBtn = UIButton()
        dismissBtn.translatesAutoresizingMaskIntoConstraints = false
        dismissBtn.titleLabel?.font = UIFont(name: "crm", size: 28)
        dismissBtn.setTitle("\u{e0ba}", for: .normal)
        dismissBtn.setTitleColor(UIColor.white, for: .normal)
        dismissBtn.addTarget(self, action: #selector(dismissBtnTapped(_:)), for: .touchUpInside)
        view.addSubview(dismissBtn)
        
        dismissBtn.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        dismissBtn.widthAnchor.constraint(equalToConstant: 40).isActive = true
        dismissBtn.heightAnchor.constraint(equalToConstant: 40).isActive = true
        dismissBtn.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -50).isActive = true
    }
    
    @objc func voiceSearchiInitiated(_ sender: UIButton) {
        
    }
    
    @objc func dismissBtnTapped(_ sender: UIButton) {
        self.dismiss(animated: true, completion: nil)
    }
}
