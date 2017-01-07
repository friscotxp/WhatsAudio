//
//  ViewController.swift
//  WhatsAudio
//
//  Created by Francisco Palma on 03-01-17.
//  Copyright © 2017 Francisco Palma. All rights reserved.
//

import UIKit
import Speech
import AVFoundation
import Intents
//import CoreAudio
//import AudioToolbox

var audioPlayer: AVAudioPlayer?
var audioRecorder: AVAudioRecorder?

class MessageViewController: UIViewController , AVSpeechSynthesizerDelegate, AVAudioRecorderDelegate, UITextFieldDelegate {
    let speechSynthesizer = AVSpeechSynthesizer();
    let audioSession = AVAudioSession.sharedInstance()
    var hablar = true;
    var sendMessage = false;

    var rate = Float(0);
    var pitch = Float(0);
    var volume = Float(0);
    var language = "";
    var mensaje = "";
    
    var enLabels = ["Play",
                    "Send",
                    "Configure"]
    
    var esLabels = ["Reproducir",
                    "Enviar",
                    "Configurar"]
    
    var langLabels = ["","",""];
    
    var enVoices = ["Write down something.",
                    "I'm sorry, whatsapp is not available.",
                    "Error, please try again",
                    "Talk enabled",
                    "Talk disabled",
                    "Configure",
                    "Saved audio"]
    
    var esVoices = ["Escribe una frase.",
                    "Lo lamento Whatsapp no está disponible.",
                    "Error, intenta otra vez.",
                    "Hablar habilitado",
                    "Hablar deshabilitado",
                    "Configurar",
                    "Audio grabado"]
    
    var langVoices = ["","",""];
    
    @IBOutlet weak var fraseText: UITextField!
    @IBOutlet weak var fraseAudio: UILabel!
    @IBOutlet weak var btnReproducir: UIButton!
    @IBOutlet weak var btnEnviar: UIButton!
    @IBOutlet weak var btnConfigurar: UIButton!
    @IBOutlet weak var lblSavedAudio: UILabel!

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view, typically from a nib.
        self.audioRecordSetup();
        self.fraseText.delegate = self;

        if (mensaje != ""){
            fraseText.text  = mensaje;
        }
        
        if (rate == 0.0){
            rate = Float(0.5);
        }
        if (pitch == 0.0){
            pitch = Float(1);
        }
        if (volume == 0.0){
            volume = Float(1);
        }
        
        if (language == ""){
            let langCode = (Locale.current as NSLocale).object(forKey: .languageCode) as? String
            let countryCode = (Locale.current as NSLocale).object(forKey: .countryCode) as? String
            language = "\(langCode!)-\(countryCode!)" // en-US on my machine
        }
        
        if (((Locale.current as NSLocale).object(forKey: .languageCode) as? String)=="es"){
            langVoices = esVoices
            langLabels = esLabels
        }else{
            langVoices = enVoices
            langLabels = enLabels
        }
        btnReproducir.setTitle(langLabels[0], for: .normal);
        btnEnviar.setTitle(langLabels[1], for: .normal);
        btnConfigurar.setTitle(langLabels[2], for: .normal);
        lblSavedAudio.text = langVoices[6] + " : 0 Kb.";
    }
    
    @IBAction func deleteText(_ sender: UIButton) {
        fraseText.text = "";
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?)    {
        self.view.endEditing(true)
    }

    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func displayStatus(status : Int){
        print("Status: " + String(status));
    }
    
    @IBAction func hablarOpciones(_ sender: UISwitch) {
        if (sender.isOn){
            hablar = true;
            speakString(phrase: langVoices[3]);
        }else{
            speakString(phrase: langVoices[4]);
            hablar = false;
        }
    }
    
    @IBAction func botonProbar(_ sender: Any) {
        if (fraseText.text! == ""){
            speakString(phrase: langVoices[0]);
        }else{
            sendMessage = false;
            speakString(phrase: fraseText.text!);
        }
    }

    @IBAction func botonEnviarWhatsapp(_ sender: Any) {
        if (fraseText.text! == ""){
            speakString(phrase: langVoices[0]);
        }else{
            sendMessage = true;
            speakString(phrase: fraseText.text!);
        }
    }

    func open(scheme: String) {
        if let url = URL(string: scheme) {
            if #available(iOS 10, *) {
                UIApplication.shared.open(url, options: [:],
                                          completionHandler: {
                                            (success) in
                                            print("Open \(scheme): \(success)")
                })
            } else {
                _ = UIApplication.shared.openURL(url)
            }
        }
    }
    
    func sendAudio(){
        do{
            var fileSize : UInt64 = 0;
            let fileMgr = FileManager.default;
            let dirPaths = fileMgr.urls(for: .documentDirectory, in: .userDomainMask)
            let soundFileURL = dirPaths[0].appendingPathComponent("mensaje.wav")
            let attr = try FileManager.default.attributesOfItem(atPath: soundFileURL.relativePath)
            fileSize = attr[FileAttributeKey.size] as! UInt64
            fraseAudio.text = langVoices[6] + " : " + String(Int(fileSize/1024)) + " Kb.";
            if (Int(fileSize/1024)>15){
                var controller = UIDocumentInteractionController()
                if UIApplication.shared.canOpenURL(NSURL(string:"whatsapp://app")! as URL) {
                    controller = UIDocumentInteractionController(url: soundFileURL)
                    controller.uti = "net.whatsapp.audio"
                    controller.presentOpenInMenu(from: CGRect.zero, in: self.view, animated: true)
                    //CGRectMake(0, 0, 0, 0)
                }else {
                    //print("error")
                    speakString(phrase: langVoices[1]);
                }
            }else{
                speechSynthesizer.stopSpeaking(at: .immediate);
                speakString(phrase: langVoices[2]);
            }
        } catch {
            print("Error: \(error)")
        }
    }
    
    func speakString(phrase : String){
        if (hablar){
            self.recordAudio();
            let speechUtterance = AVSpeechUtterance(string: String(describing: INSpeakableString.init(spokenPhrase: phrase)));
            speechUtterance.voice = AVSpeechSynthesisVoice(language: language);
            speechUtterance.rate = Float(rate);
            speechUtterance.pitchMultiplier = Float(pitch);
            speechUtterance.volume = Float(volume);
            speechSynthesizer.delegate = self
            speechSynthesizer.speak(speechUtterance);
            
        }
    }
    
    @IBAction func botonConfigurar(_ sender: Any) {
        speechSynthesizer.stopSpeaking(at: .immediate);
        speakString(phrase: langVoices[5]);
        //self.performSegue(withIdentifier: "configurar", sender: sender)
        
        mensaje = fraseText.text!;
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let configViewController = storyboard.instantiateViewController(withIdentifier: "config") as! ConfigViewController;
        configViewController.pitch = pitch;
        configViewController.rate = rate;
        configViewController.volume = volume;
        configViewController.language = language;
        configViewController.mensaje = mensaje;
        self.present(configViewController, animated: true, completion: nil)
    }

    func audioRecordSetup(){
        let fileMgr = FileManager.default
        let dirPaths = fileMgr.urls(for: .documentDirectory, in: .userDomainMask)
        let soundFileURL = dirPaths[0].appendingPathComponent("mensaje.wav")
        
        
        let recordSettings = [AVEncoderAudioQualityKey: AVAudioQuality.min.rawValue,
                              AVEncoderBitRateKey: 16,
                              AVNumberOfChannelsKey: 2,
                              AVSampleRateKey: 22050.0] as [String : Any] //44100
        do {
            try audioSession.setCategory(AVAudioSessionCategoryPlayAndRecord);
            try AVAudioSession.sharedInstance().overrideOutputAudioPort(AVAudioSessionPortOverride.speaker);
        } catch {
            print("Error: \(error)")
        }
        
        do {
            try audioRecorder = AVAudioRecorder(url: soundFileURL, settings: recordSettings as [String : AnyObject])
            audioRecorder?.delegate=self;
            audioRecorder?.prepareToRecord();
        } catch {
            print("Error: \(error)")
        }
    }
    
    func recordAudio() {
            if (audioRecorder?.isRecording) == false {
                audioRecorder?.record();
            }else{
                audioRecorder?.stop();
                audioRecorder?.prepareToRecord();
        }
    }
    
    func stopAudio() {
        do{
            if audioRecorder?.isRecording == true {
                audioRecorder?.stop()
            } else {
                audioPlayer?.stop()
            }
        }
    }
    
    @IBAction func botonPlay(_ sender: Any) {
        if audioRecorder?.isRecording == false {
            do {
                let fileMgr = FileManager.default
                let dirPaths = fileMgr.urls(for: .documentDirectory, in: .userDomainMask)
                let soundFileURL = dirPaths[0].appendingPathComponent("mensaje.wav")
                try audioPlayer = AVAudioPlayer(contentsOf: soundFileURL)
                guard let audioPlayer = audioPlayer else { return }
                audioPlayer.setVolume(1, fadeDuration: 0)
                audioPlayer.prepareToPlay()
                audioPlayer.play()
            } catch {
                print("Error: \(error)")
            }
        }
    }
    
    func speechSynthesizer(_ synthesizer: AVSpeechSynthesizer, didStart utterance: AVSpeechUtterance) {
        btnReproducir.isEnabled = false;
        btnReproducir.setTitleColor(UIColor.gray, for: UIControlState.disabled);
        btnEnviar.isEnabled = false;
        btnEnviar.setTitleColor(UIColor.gray, for: UIControlState.disabled);
//      btnConfigurar.isEnabled = false;
//      btnConfigurar.setTitleColor(UIColor.gray, for: UIControlState.disabled);
    }
    
    func speechSynthesizer(_ synthesizer: AVSpeechSynthesizer, didFinish utterance: AVSpeechUtterance) {
        //self.stopAudio();
        self.stopAudio();
        if (self.sendMessage){
            self.sendAudio();
        }
        self.sendMessage = false;
        btnReproducir.isEnabled = true;
        btnReproducir.setTitleColor(UIColor.white, for: UIControlState.disabled);
        btnEnviar.isEnabled = true;
        btnEnviar.setTitleColor(UIColor.white, for: UIControlState.normal);
//      btnConfigurar.isEnabled = true;
//      btnConfigurar.setTitleColor(UIColor.white, for: UIControlState.normal);
    }
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    var engine:AVAudioEngine!
    var playerTapNode:AVAudioPlayerNode!
    var playerNode:AVAudioPlayerNode!
    var mixer:AVAudioMixerNode!
    var audioFile:AVAudioFile!
    
    func initAudioEngine () {
        engine = AVAudioEngine()
        playerNode = AVAudioPlayerNode()
        playerTapNode = AVAudioPlayerNode()
        engine.attach(playerNode)
        engine.attach(playerTapNode)
        mixer = engine.mainMixerNode
        // engine.connect(playerNode, to: mixer, format: mixer.outputFormatForBus(0))
        //        engine.connect(playerNode, to: engine.mainMixerNode, format: mixer.outputFormatForBus(0))
        
        mixer.outputVolume = 1.0
        mixer.pan = 0.0 // -1 to +1
        let iformat = engine.inputNode?.inputFormat(forBus: 0)
        print("input format \(iformat)")
        
        do {
            try engine.start()
        } catch {
            print("error \(error.localizedDescription)")
        }
        
        NotificationCenter.default.addObserver(self,
                                               selector:#selector(MessageViewController.configChange(_:)),
                                               name:NSNotification.Name.AVAudioEngineConfigurationChange,
                                               object:engine)
        
        let format = mixer.outputFormat(forBus: 0)
        //engine.connect(playerNode, to: mixer, format: format)
        
        engine.connect(playerNode, to: reverbNode, format: format)
        // tapMixer()
    }
    
    func bounceEngine() {
        if engine.isRunning {
            engine.stop()
        } else {
            do {
                try engine.start()
            } catch {
                print("error \(error.localizedDescription)")
            }
            
        }
    }
    
    func engineStart() {
        do {
            try engine.start()
        } catch {
            print("error \(error.localizedDescription)")
        }
    }

    func configChange(_ notification:Notification) {
        print("config change")
    }
    
    var reverbNode:AVAudioUnitReverb!
    func reverb() {
        reverbNode = AVAudioUnitReverb()
        reverbNode.loadFactoryPreset(.cathedral)
        engine.attach(reverbNode)
        //The blend is specified as a percentage. The range is 0% (all dry) through 100% (all wet).
        reverbNode.wetDryMix = 0.0
        // engine.connect(playerNode, to: reverbNode, format: mixer.outputFormatForBus(0))
        // engine.connect(reverbNode, to: mixer, format: mixer.outputFormatForBus(0))
    }
    
    func tapInput() {
        let audioInputNode = engine.inputNode
        let frameLength:AVAudioFrameCount = 128
        audioInputNode?.installTap(onBus: 0, bufferSize:frameLength, format: audioInputNode?.outputFormat(forBus: 0), block: {(buffer, time) in
            for channelIndex in 0 ..< Int(buffer.format.channelCount) {
                var data = buffer.floatChannelData?[channelIndex]
                for frameIndex in 0 ..< Int(buffer.frameLength) {
                    // data[frameIndex] = blah blah
                    self.playerTapNode.scheduleBuffer(buffer, at: nil, options: [], completionHandler: nil)
                }
            }
        })
    }
    
    func recordInputNodeToFile() {
        let filename = "testrecord.wav"
        let docsDir = NSSearchPathForDirectoriesInDomains(FileManager.SearchPathDirectory.documentDirectory, FileManager.SearchPathDomainMask.userDomainMask, true)[0] as NSString
        let path = docsDir.appendingPathComponent(filename)
        let url = URL(fileURLWithPath: path)
        
        let settings = [
            AVFormatIDKey: kAudioFormatLinearPCM,
            AVSampleRateKey: 44100.0,
            AVNumberOfChannelsKey: 1 ] as [String : Any]
        
        do {
            audioFile = try AVAudioFile(forWriting: url, settings: settings)
        } catch {
            print("error \(error.localizedDescription)")
            
        }
        
        
        let input = engine.inputNode
        input?.installTap(onBus: 0, bufferSize: 4096, format: audioFile.processingFormat) {
            (buffer : AVAudioPCMBuffer!, when : AVAudioTime!) in
            //print("Got buffer of length: \(buffer.frameLength) at time: \(when)")
            
            do {
                try self.audioFile.write(from: buffer)
            } catch {
                print("error \(error.localizedDescription)")
                
            }
            
        }
        
        print("starting audio engine for recording")
        print("writing to \(path)")
        do {
            try engine.start()
        } catch {
            print("Error starting audio engine: \(error.localizedDescription)")
        }
        
        
    }
    func stopRecording() {
        self.engine.inputNode?.removeTap(onBus: 0)
        self.engine.stop()
    }
    
    
    func setSessionPlayAndRecord() {
        let session:AVAudioSession = AVAudioSession.sharedInstance()
        
        do {
            try session.setCategory(AVAudioSessionCategoryPlayAndRecord)
        } catch{
            print("could not set session category")
            print("error \(error.localizedDescription)")
            
        }
        do {
            try session.setActive(true)
        } catch{
            print("could not make session active")
            print("error \(error.localizedDescription)")
            
        }
        
    }
    
    func setSessionRecord() {
        let session = AVAudioSession.sharedInstance()
        do {
            try session.setCategory(AVAudioSessionCategoryRecord)
        } catch{
            print("could not set session category")
            print("error \(error.localizedDescription)")
            
        }
        do {
            try session.setActive(true)
        } catch{
            print("could not make session active")
            print("error \(error.localizedDescription)")
            
        }
    }   
    
}


