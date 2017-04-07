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
import CoreAudio
import AudioToolbox

var audioPlayer: AVAudioPlayer?
var audioRecorder: AVAudioRecorder?

class MessageViewController: UIViewController , UIPickerViewDelegate, UIPickerViewDataSource, AVSpeechSynthesizerDelegate, AVAudioRecorderDelegate, UITextFieldDelegate {
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
    
    var languages = ["Arabic Maged", "Czech Zuzana", "Danish Sara", "Dutch Anna", "Greek Melina", "English Karen", "English Daniel", "English Moira", "English Samantha", "English Tessa", "Spanish Monica", "Spanish Paulina", "Finnish Satu", "French Amelie", "French Thomas", "Hebrew Carmit","Hindi Lekha", "Hungarian Mariska", "Indonesian Damayanti", "Italian Alice", "Japanese Kyoko","Korean Yuna", "Dutch Ellen", "Dutch Xander", "Norwegian Nora", "Polish Zosia", "Portuguese Luciana", "Portuguese Joana","Romanian Ioana", "Russian Milena","Slovak Laura","Swedish Alva", "Thai Kanya", "Turkish Yelda", "Chinese Ting-Ting", "Chinese Sin-Ji","Chinese Mei-Jia"]
    
    var langCode = ["ar-SA","cs-CZ","da-DK","de-DE","el-GR","en-AU","en-GB","en-IE","en-US","en-ZA","es-ES","es-MX","fi-FI","fr-CA","fr-FR","he-IL","hi-IN","hu-HU","id-ID","it-IT","ja-JP","ko-KR","nl-BE","nl-NL","no-NO","pl-PL","pt-BR","pt-PT","ro-RO","ru-RU","sk-SK","sv-SE","th-TH","tr-TR","zh-CN","zh-HK","zh-TW"]
    

    @IBOutlet weak var langickerView: UIPickerView!
    @IBOutlet weak var fraseText: UITextField!
    @IBOutlet weak var fraseAudio: UILabel!
    @IBOutlet weak var btnReproducir: UIButton!
    @IBOutlet weak var btnEnviar: UIButton!
    //@IBOutlet weak var btnConfigurar: UIButton!
    @IBOutlet weak var lblSavedAudio: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        print("viewDidLoad...");
        // Do any additional setup after loading the view, typically from a nib.
        //self.audioRecordSetup();
        self.audioRecordSetupMixes();
        
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
            volume = Float(0.75);
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
        //btnConfigurar.setTitle(langLabels[2], for: .normal);
        lblSavedAudio.text = langVoices[6] + " : 0 Kb.";
        
        langickerView.dataSource = self
        langickerView.delegate = self
        var idx = langCode.index(of: language);
        if (idx != nil &&  idx!>0){
            langickerView.selectRow(langCode.index(of: language)!, inComponent: 0, animated: true)
        }else{
            languages.append("Other ["+language+"]");
            langCode.append(language);
            idx = langCode.index(of: language);
            langickerView.selectRow(langCode.index(of: language)!, inComponent: 0, animated: true)
        }
    }
    
    // DataSource
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return languages.count
    }
    
    // Delegate
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return languages[row]
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        speechSynthesizer.stopSpeaking(at: .immediate);
        language = langCode[row];
        if (fraseText.text == ""){
            speakString(phrase:  langVoices[0]);
        }else{
            speakString(phrase: fraseText.text!);
        }
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
        print("[botonProbar]")
        if (fraseText.text! == ""){
            speakString(phrase: langVoices[0]);
        }else{
            sendMessage = false;
            speakString(phrase: fraseText.text!);
        }
    }
    
    @IBAction func botonEnviarWhatsapp(_ sender: Any) {
        print("[botonEnviarWhatsapp]")
        if (fraseText.text! == ""){
            speakString(phrase: langVoices[0]);
        }else{
            sendMessage = true;
            speakString(phrase: fraseText.text!);
        }
    }
    
    func open(scheme: String) {
        print("[open]")
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
        print("[sendAudio]")
        do{
            var fileSize : UInt64 = 0;
            let fileMgr = FileManager.default;
            let dirPaths = fileMgr.urls(for: .documentDirectory, in: .userDomainMask)
            let soundFileURL = dirPaths[0].appendingPathComponent("mensaje.wav")
            let attr = try FileManager.default.attributesOfItem(atPath: soundFileURL.relativePath)
            fileSize = attr[FileAttributeKey.size] as! UInt64
            fraseAudio.text = langVoices[6] + " : " + String(Int(fileSize/1024)) + " Kb.";
            if (Int(fileSize/1024)>15){
                var controller = UIDocumentInteractionController();
                let url = NSURL (string: "whatsapp://send?text=Hello%2C%20World!");
                if UIApplication.shared.canOpenURL(url! as URL) {
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
        print("[speakString]")
        if (hablar){
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
        print("[botonConfigurar]")
        speechSynthesizer.stopSpeaking(at: .immediate);
        speakString(phrase: langVoices[5]);
        //self.performSegue(withIdentifier: "configurar", sender: sender)
        mensaje = fraseText.text!;
        
        /*
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let configViewController = storyboard.instantiateViewController(withIdentifier: "config") as! ConfigViewController;
        configViewController.pitch = pitch;
        configViewController.rate = rate;
        configViewController.volume = volume;
        configViewController.language = language;
        configViewController.mensaje = mensaje;
        self.present(configViewController, animated: true, completion: nil)
         */
    }
    
    func audioRecordSetup(){
        print("[audioRecordSetup]")
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
    
    func audioRecordSetupMixes(){
        let fileMgr = FileManager.default
        let dirPaths = fileMgr.urls(for: .documentDirectory,in: .userDomainMask)
        let soundFileURL = dirPaths[0].appendingPathComponent("mensaje.wav")
        
        let recordSettings =
            [AVEncoderAudioQualityKey: AVAudioQuality.min.rawValue,
             AVEncoderBitRateKey: 16,
             AVNumberOfChannelsKey: 2,
             AVSampleRateKey: 22050.0] as [String : Any]
        //44100
        
        let audioSession = AVAudioSession.sharedInstance()
        
        do {
            try audioSession.setCategory(AVAudioSessionCategoryPlayAndRecord);
            try audioSession.overrideOutputAudioPort(AVAudioSessionPortOverride.speaker);
            try audioSession.setInputGain(Float (0));
        } catch {
            print("Error: \(error)")
        }
        
        do {
            try audioRecorder = AVAudioRecorder(url: soundFileURL,
                                                settings: recordSettings as [String : AnyObject])
            audioRecorder?.delegate=self
            audioRecorder?.prepareToRecord()
        } catch {
            print("Error: \(error)")
        }
    }
    
    func recordAudio() {
        print("[recordAudio]")
        if (audioRecorder?.isRecording) == false {
            audioRecorder?.record();
        }else{
            audioRecorder?.stop();
            audioRecorder?.prepareToRecord();
        }
    }

    func stopAudio() {
        print("[stopAudio]")
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
                print("Reproduciendo Audio...");
                
                var fileSize : UInt64 = 0;
                let fileMgr = FileManager.default
                let dirPaths = fileMgr.urls(for: .documentDirectory, in: .userDomainMask)
                let soundFileURL = dirPaths[0].appendingPathComponent("mensaje.wav")
                let attr = try FileManager.default.attributesOfItem(atPath: soundFileURL.relativePath)
                fileSize = attr[FileAttributeKey.size] as! UInt64
                fraseAudio.text = langVoices[6] + " : " + String(Int(fileSize/1024)) + " Kb.";
                
                try audioPlayer = AVAudioPlayer(contentsOf: soundFileURL)
                guard let audioPlayer = audioPlayer else { return }
                //audioPlayer.setVolume(1, fadeDuration: 0)
                audioPlayer.prepareToPlay()
                audioPlayer.play()
                
                print("Fin de reproduciendo Audio...: " + fileSize.description);
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
        self.recordAudio();
    }
    
    func speechSynthesizer(_ synthesizer: AVSpeechSynthesizer, didFinish utterance: AVSpeechUtterance) {
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
}
