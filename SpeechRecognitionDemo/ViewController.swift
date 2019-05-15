//
//  ViewController.swift
//  SpeechRecognitionDemo
//
//  Created by praveen on 5/15/19.
//  Copyright © 2019 focussoftnet. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.title = "Speech Recoginition Demo"
        
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.numberOfLines = 0
        label.textColor = .lightGray
        view.addSubview(label)
        
        label.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20).isActive = true
        label.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20).isActive = true
        label.topAnchor.constraint(equalTo: view.topAnchor, constant: -60).isActive = true
        label.heightAnchor.constraint(equalTo: view.heightAnchor, multiplier: 0.4).isActive = true
        
        let btn = UIButton(type: .roundedRect)
        btn.translatesAutoresizingMaskIntoConstraints = false
        btn.setTitle("Start Voice Search", for: .normal)
        btn.addTarget(self, action: #selector(voiceSearchBtnTapped(_:)), for: .touchUpInside)
        btn.setTitleColor(.white, for: .normal)
        btn.backgroundColor = UIColor(red: 0/255, green: 125/255, blue: 248/255, alpha: 1)
        view.addSubview(btn)

        btn.topAnchor.constraint(equalTo: label.bottomAnchor, constant: 20).isActive = true
        btn.widthAnchor.constraint(equalToConstant: 250).isActive = true
        btn.heightAnchor.constraint(equalToConstant: 40).isActive = true
        btn.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
    }
    
    @objc func voiceSearchBtnTapped(_ sender: UIButton) {
        let voiceRecognitionCtl = CLSpeechRecognitionController()
        self.present(voiceRecognitionCtl, animated: true, completion: nil)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

