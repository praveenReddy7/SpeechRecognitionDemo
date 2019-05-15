//
//  CLVoiceRegcognitionController.swift
//  SpeechRecognitionDemo
//
//  Created by praveen on 5/15/19.
//  Copyright © 2019 focussoftnet. All rights reserved.
//

import UIKit
import Speech

class CLSpeechRecognitionController: UIViewController {
    
    let searchLabel = UILabel()
    private let speechRecognizer = SFSpeechRecognizer(locale: Locale.init(identifier: "en-US"))!
    private var recognitionRequest: SFSpeechAudioBufferRecognitionRequest?
    private var recognitionTask: SFSpeechRecognitionTask?
    private let audioEngine = AVAudioEngine()
    var speechResult = SFSpeechRecognitionResult()
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        SFSpeechRecognizer.requestAuthorization { authStatus in
            // The callback may not be called on the main thread. Add an
            // operation to the main queue to update the record button's state.
            OperationQueue.main.addOperation {
                var alertTitle = ""
                var alertMsg = ""
                
                switch authStatus {
                case .authorized:
                    do {
                        try self.startRecording()
                    } catch {
                        alertTitle = "Recorder Error"
                        alertMsg = "There was a problem starting the speech recorder"
                    }
                case .denied:
                    alertTitle = "Speech recognizer not allowed"
                    alertMsg = "You enable the recognizer in Settings"
                    
                case .restricted, .notDetermined:
                    alertTitle = "Could not start the speech recognizer"
                    alertMsg = "Check your internect connection and try again"
                }
                if alertTitle != "" {
                    let alert = UIAlertController(title: alertTitle, message: alertMsg, preferredStyle: .alert)
                    alert.addAction(UIAlertAction(title: "OK", style: .cancel, handler: { (action) in
                        self.dismiss(animated: true, completion: nil)
                    }))
                    
                    self.present(alert, animated: true, completion: nil)
                }
            }
        }
    }
    
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
        micBtn.setImage(#imageLiteral(resourceName: "mic_image"), for: .normal)
        micBtn.addTarget(self, action: #selector(micBtnTapped(_:)), for: .touchUpInside)
        view.addSubview(micBtn)
        
        micBtn.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        micBtn.centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true
        micBtn.widthAnchor.constraint(equalToConstant: 60).isActive = true
        micBtn.heightAnchor.constraint(equalToConstant: 60).isActive = true
        
        
        searchLabel.translatesAutoresizingMaskIntoConstraints = false
        searchLabel.font = UIFont.systemFont(ofSize: 16, weight: .semibold)
        searchLabel.textColor = .white
        searchLabel.numberOfLines = 0
        view.addSubview(searchLabel)
        
        searchLabel.leadingAnchor.constraint(equalTo: indicatorLabel.leadingAnchor).isActive = true
        searchLabel.widthAnchor.constraint(equalTo: indicatorLabel.widthAnchor, multiplier: 0.7).isActive = true
        searchLabel.topAnchor.constraint(equalTo: indicatorLabel.bottomAnchor).isActive = true
        searchLabel.heightAnchor.constraint(equalToConstant: 80).isActive = true
        
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
        
        
        speechRecognizer.delegate = self
    }
    
    
    private func startRecording() throws {
        if !audioEngine.isRunning {
            let timer = Timer(timeInterval: 30.0, target: self, selector: #selector(timerEnded), userInfo: nil, repeats: false)
            RunLoop.current.add(timer, forMode: .commonModes)
            
            let audioSession = AVAudioSession.sharedInstance()
            try audioSession.setCategory(AVAudioSessionCategoryRecord)
            try audioSession.setMode(AVAudioSessionModeMeasurement)
            try audioSession.setActive(true, with: .notifyOthersOnDeactivation)
            
            recognitionRequest = SFSpeechAudioBufferRecognitionRequest()
            
           /* guard */let inputNode = audioEngine.inputNode/* else { fatalError("There was a problem with the audio engine") }*/
            guard let recognitionRequest = recognitionRequest else { fatalError("Unable to create the recognition request") }
            
            // Configure request so that results are returned before audio recording is finished
            recognitionRequest.shouldReportPartialResults = true
            
            // A recognition task is used for speech recognition sessions
            // A reference for the task is saved so it can be cancelled
            recognitionTask = speechRecognizer.recognitionTask(with: recognitionRequest) { result, error in
                var isFinal = false
                
                if let result = result {
                    print("result: \(result.isFinal)")
                    isFinal = result.isFinal
                    
                    self.speechResult = result
                    self.searchLabel.text = result.bestTranscription.formattedString
                    
                }
                
                if error != nil || isFinal {
                    self.audioEngine.stop()
                    inputNode.removeTap(onBus: 0)
                    
                    self.recognitionRequest = nil
                    self.recognitionTask = nil
                }
                
//                self.addNote.isEnabled = self.recordedTextLabel.text != ""
//                self.addReminder.isEnabled = self.recordedTextLabel.text != ""
            }
            
            let recordingFormat = inputNode.outputFormat(forBus: 0)
            inputNode.installTap(onBus: 0, bufferSize: 1024, format: recordingFormat) { (buffer: AVAudioPCMBuffer, when: AVAudioTime) in
                self.recognitionRequest?.append(buffer)
            }
            
            print("Begin recording")
            audioEngine.prepare()
            try audioEngine.start()
            
//            isRecordingLabel.text = "Recording"
        }
        
    }
    
    @objc func timerEnded() {
        // If the audio recording engine is running stop it and remove the SFSpeechRecognitionTask
        if audioEngine.isRunning {
            stopRecording()
//            checkForActionPhrases()
        }
    }
    
    
    func stopRecording() {
        audioEngine.stop()
        recognitionRequest?.endAudio()
        // Cancel the previous task if it's running
        if let recognitionTask = recognitionTask {
            recognitionTask.cancel()
            self.recognitionTask = nil
        }
    }
    
    @objc func micBtnTapped(_ sender: UIButton) {
        do {
            try startRecording()
        } catch {
            showTryAgainAlert()
        }
    }
    
    @objc func dismissBtnTapped(_ sender: UIButton) {
        self.dismiss(animated: true, completion: nil)
    }
    
    private func showTryAgainAlert() {
        let alert = UIAlertController(title: "There was a problem accessing the recognizer", message: "Please try again later", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .cancel, handler: { (action) in
            self.dismiss(animated: true, completion: nil)
        }))
        
        present(alert, animated: true, completion: nil)
    }
}


extension CLSpeechRecognitionController: SFSpeechRecognizerDelegate {
    func speechRecognizer(_ speechRecognizer: SFSpeechRecognizer, availabilityDidChange available: Bool) {
        print("Recognizer availability changed: \(available)")
        
        if !available {
           showTryAgainAlert()
        }
    }
}



/*
 
 import UIKit
 import Speech
 
 class CLSearchBar: UIView {
 
 let backButton = UIButton(type: UIButtonType.roundedRect)
 let searchField = UITextField()
 
 convenience init() {
 self.init(frame: CGRect.zero)
 }
 
 override init(frame: CGRect) {
 super.init(frame: frame)
 self.backgroundColor = .white
 self.layer.cornerRadius = 5.0
 
 backButton.translatesAutoresizingMaskIntoConstraints = false
 backButton.setTitle("\u{e079}", for: UIControlState.normal)
 backButton.titleLabel?.font = UIFont.iconFont(ofSize: 22)
 self.addSubview(backButton)
 
 backButton.centerYAnchor.constraint(equalTo: self.centerYAnchor).isActive = true
 backButton.leadingAnchor.constraint(equalTo: self.leadingAnchor).isActive = true
 backButton.widthAnchor.constraint(equalToConstant: 40).isActive = true
 backButton.heightAnchor.constraint(equalTo: self.heightAnchor).isActive = true
 
 searchField.translatesAutoresizingMaskIntoConstraints = false
 //        let searchFieldPlaceholder = NSAttributedString(string: " Search", attributes: [NSAttributedStringKey.foregroundColor: UIColor.orange])
 //        searchField.attributedPlaceholder = searchFieldPlaceholder
 //        searchField.tintColor = .orange
 searchField.becomeFirstResponder()
 searchField.returnKeyType = .search
 searchField.autocorrectionType = .no
 searchField.clearButtonMode = .always
 self.addSubview(searchField)
 
 searchField.centerYAnchor.constraint(equalTo: self.centerYAnchor).isActive = true
 searchField.leadingAnchor.constraint(equalTo: backButton.trailingAnchor, constant: 8).isActive = true
 searchField.trailingAnchor.constraint(equalTo: trailingAnchor, constant: 0).isActive = true
 searchField.heightAnchor.constraint(equalTo: backButton.heightAnchor).isActive = true
 
 //        searchField.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -50).isActive = true
 
 // TODO:
 /*if #available(iOS 10.0, *) {
 let microphoneButton = CLSearchBarMicButton(searchBar: searchField)
 microphoneButton.translatesAutoresizingMaskIntoConstraints = false
 self.addSubview(microphoneButton)
 
 microphoneButton.centerYAnchor.constraint(equalTo: self.centerYAnchor).isActive = true
 microphoneButton.trailingAnchor.constraint(equalTo: self.trailingAnchor).isActive = true
 microphoneButton.widthAnchor.constraint(equalTo: backButton.widthAnchor).isActive = true
 microphoneButton.heightAnchor.constraint(equalTo: backButton.heightAnchor).isActive = true
 //        speechRecognizer.delegate = self
 } else {
 // Fallback on earlier versions
 }*/
 
 }
 
 required init?(coder aDecoder: NSCoder) {
 fatalError("init(coder:) has not been implemented")
 }
 
 }
 
 @available(iOS 10.0, *)
 class CLSearchBarMicButton: UIButton, SFSpeechRecognizerDelegate {
 let speechRecognizer = SFSpeechRecognizer(locale: Locale(identifier: "en-US"))!
 var recognitionRequest: SFSpeechAudioBufferRecognitionRequest?
 var recognitionTask: SFSpeechRecognitionTask?
 let audioEngine = AVAudioEngine()
 var searchBar: UITextField?
 
 override var buttonType: UIButtonType {
 return .roundedRect
 }
 
 convenience init(searchBar: UITextField) {
 self.init(frame: CGRect.zero)
 self.searchBar = searchBar
 }
 
 override init(frame: CGRect) {
 super.init(frame: frame)
 self.setImage(UIImage.init(named: "microphone.png"), for: UIControlState.normal)
 self.tintColor = .orange
 self.imageEdgeInsets = UIEdgeInsetsMake(5, 5, 5, 5)
 self.addTarget(self, action: #selector(microphoneButtonTapped), for: UIControlEvents.touchUpInside)
 self.speechRecognizer.delegate = self
 }
 
 @objc func microphoneButtonTapped() {
 SFSpeechRecognizer.requestAuthorization { authStatus in
 
 }
 if audioEngine.isRunning {
 audioEngine.stop()
 recognitionRequest?.endAudio()
 self.tintColor = .orange
 } else {
 try! startRecording()
 self.tintColor = .red
 }
 }
 
 private func startRecording() throws {
 // Cancel the previous task if it's running.
 if let recognitionTask = recognitionTask {
 recognitionTask.cancel()
 self.recognitionTask = nil
 }
 
 let audioSession = AVAudioSession.sharedInstance()
 try audioSession.setCategory(AVAudioSessionCategoryRecord)
 try audioSession.setMode(AVAudioSessionModeMeasurement)
 try audioSession.setActive(true, with: .notifyOthersOnDeactivation)
 
 recognitionRequest = SFSpeechAudioBufferRecognitionRequest()
 
 //        guard let inputNode = audioEngine.inputNode else { fatalError("Audio engine has no input node") }
 let inputNode = audioEngine.inputNode
 guard let recognitionRequest = recognitionRequest else { fatalError("Unable to created a SFSpeechAudioBufferRecognitionRequest object") }
 
 // Configure request so that results are returned before audio recording is finished
 recognitionRequest.shouldReportPartialResults = true
 
 // A recognition task represents a speech recognition session.
 // We keep a reference to the task so that it can be cancelled.
 recognitionTask = speechRecognizer.recognitionTask(with: recognitionRequest) { result, error in
 var isFinal = false
 
 if let result = result {
 self.searchBar?.text = result.bestTranscription.formattedString
 isFinal = result.isFinal
 }
 //            else if let error = error {
 //                CLAlertView.showAlert(alertMessage: "There has been a speech recognition error.")
 //                print(error)
 //            }
 
 if error != nil || isFinal {
 self.audioEngine.stop()
 inputNode.removeTap(onBus: 0)
 self.tintColor = .orange
 self.recognitionRequest = nil
 self.recognitionTask = nil
 }
 }
 
 let recordingFormat = inputNode.outputFormat(forBus: 0)
 inputNode.installTap(onBus: 0, bufferSize: 1024, format: recordingFormat) { (buffer: AVAudioPCMBuffer, when: AVAudioTime) in
 self.recognitionRequest?.append(buffer)
 }
 audioEngine.prepare()
 
 try audioEngine.start()
 searchBar?.becomeFirstResponder()
 //        searchField.text = "(Go ahead, I'm listening)"
 }
 
 // MARK: SFSpeechRecognizerDelegate
 public func speechRecognizer(_ speechRecognizer: SFSpeechRecognizer, availabilityDidChange available: Bool) {
 if available {
 self.isEnabled = true
 } else {
 self.isEnabled = false
 }
 }
 
 
 required init?(coder aDecoder: NSCoder) {
 fatalError("init(coder:) has not been implemented")
 }
 }
 

 
 */


