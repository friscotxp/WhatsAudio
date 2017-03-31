//
//  ConfigViewController.swift
//  WhatsAudio
//
//  Created by Francisco Palma on 03-01-17.
//  Copyright © 2017 Francisco Palma. All rights reserved.
//

import UIKit
import Speech
//import AVFoundation
import Intents
//import CoreAudio
//import AudioToolbox

class ConfigViewController: UIViewController,UIPickerViewDelegate, UIPickerViewDataSource,AVSpeechSynthesizerDelegate, AVAudioRecorderDelegate {
    var hablar = true;
    var rate = Float(0);
    var pitch = Float(0);
    var volume = Float(0);
    var language = "";
    var mensaje = "";
    var langMessage = "";
    
    @IBOutlet weak var langickerView: UIPickerView!
    @IBOutlet weak var pitchSlider: UISlider!
    @IBOutlet weak var rateSlider: UISlider!
    @IBOutlet weak var volumeSlider: UISlider!
    @IBOutlet weak var selectLang: UIPickerView!
    
    @IBOutlet weak var lblPitch: UILabel!
    @IBOutlet weak var lblRate: UILabel!
    @IBOutlet weak var lblVolume: UILabel!
    @IBOutlet weak var lblSpeakLang: UILabel!
    @IBOutlet weak var btnVolver: UIButton!
    @IBOutlet weak var lblMainText: UILabel!
    
    var enLabels = ["Back",
                    "Pitch",
                    "Rate",
                    "Volume",
                    "Speak Language",
                    "WhatsAudio Configuration"]
    
    var esLabels = ["Volver",
                    "Tono",
                    "Velocidad",
                    "Volumen",
                    "Lenguaje Hablado",
                    "Configuración de WhatsAudio"]
    
    var langLabels = ["","",""];
    
    var languages = ["Arabic Maged", "Czech Zuzana", "Danish Sara", "Dutch Anna", "Greek Melina", "English Karen", "English Daniel", "English Moira", "English Samantha", "English Tessa", "Spanish Monica", "Spanish Paulina", "Finnish Satu", "French Amelie", "French Thomas", "Hebrew Carmit","Hindi Lekha", "Hungarian Mariska", "Indonesian Damayanti", "Italian Alice", "Japanese Kyoko","Korean Yuna", "Dutch Ellen", "Dutch Xander", "Norwegian Nora", "Polish Zosia", "Portuguese Luciana", "Portuguese Joana","Romanian Ioana", "Russian Milena","Slovak Laura","Swedish Alva", "Thai Kanya", "Turkish Yelda", "Chinese Ting-Ting", "Chinese Sin-Ji","Chinese Mei-Jia"]
    
    var langCode = ["ar-SA","cs-CZ","da-DK","de-DE","el-GR","en-AU","en-GB","en-IE","en-US","en-ZA","es-ES","es-MX","fi-FI","fr-CA","fr-FR","he-IL","hi-IN","hu-HU","id-ID","it-IT","ja-JP","ko-KR","nl-BE","nl-NL","no-NO","pl-PL","pt-BR","pt-PT","ro-RO","ru-RU","sk-SK","sv-SE","th-TH","tr-TR","zh-CN","zh-HK","zh-TW"]
    
    let speechSynthesizer = AVSpeechSynthesizer()
    let audioSession = AVAudioSession.sharedInstance()

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        if (rate == 0.0){
            rate = Float(0.5);
        }else{
            rateSlider.value = rate;
        }
        if (pitch == 0.0){
            pitch = Float(1);
        }else{
            pitchSlider.value = pitch;
        }
        if (volume == 0.0){
            volume = Float(1);
        }else{
            volumeSlider.value = volume;
        }
        if (language == ""){
            let langCode = (Locale.current as NSLocale).object(forKey: .languageCode) as? String
            let countryCode = (Locale.current as NSLocale).object(forKey: .countryCode) as? String
            language = "\(langCode!)-\(countryCode!)" // en-US on my machine
        }

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
        
        if (((Locale.current as NSLocale).object(forKey: .languageCode) as? String)=="es"){
            langLabels = esLabels
            langMessage = "Escribe una frase..."
        }else{
            langLabels = enLabels
            langMessage = "Write down something..."
        }
        
        btnVolver.setTitle(langLabels[0], for: .normal);
        lblPitch.text = langLabels[1];
        lblRate.text = langLabels[2];
        lblVolume.text = langLabels[3];
        lblSpeakLang.text = langLabels[4];
        lblMainText.text = langLabels[5];
        
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
        
        if (mensaje == ""){
            speakString(phrase: langMessage);
        }else{
            speakString(phrase: mensaje);
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func volver(_ sender: Any) {
        speechSynthesizer.stopSpeaking(at: .immediate);
        speakString(phrase: langLabels[0]);
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let messaViewController = storyboard.instantiateViewController(withIdentifier: "view") as! MessageViewController;
        
        messaViewController.pitch = pitch;
        messaViewController.rate = rate;
        messaViewController.volume = volume;
        messaViewController.language = language;
        messaViewController.mensaje = mensaje;
        
        self.present(messaViewController, animated: true, completion: nil)
    }
    
    @IBAction func pitchChange(_ sender: UISlider) {
        pitch = Float(sender.value);
        //speakString(phrase: mensaje);
    }
    
    @IBAction func rateChange(_ sender: UISlider) {
        rate = Float(sender.value);
        //speakString(phrase: mensaje);
    }
    
    @IBAction func volumeChange(_ sender: UISlider) {
        volume = Float(sender.value);
        //speakString(phrase: mensaje);
    }
    
    func speakString(phrase : String){
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
    
    func audioRecordSetup(){
        let fileMgr = FileManager.default
        let dirPaths = fileMgr.urls(for: .documentDirectory,
                                    in: .userDomainMask)
        let soundFileURL = dirPaths[0].appendingPathComponent("mensaje.wav")
        let recordSettings = [AVEncoderAudioQualityKey: AVAudioQuality.min.rawValue,
                              AVEncoderBitRateKey: 16,
                              AVNumberOfChannelsKey: 2,
                              AVSampleRateKey: 22050.0] as [String : Any] //44100
        do {
            try audioSession.setCategory(AVAudioSessionCategoryPlayAndRecord)
        } catch let error as NSError {
            print("audioSession error: \(error.localizedDescription)")
        }
        
        do {
            try AVAudioSession.sharedInstance().overrideOutputAudioPort(AVAudioSessionPortOverride.speaker)
        } catch {
            print("Error: \(error)")
        }
        
        do {
            try audioRecorder = AVAudioRecorder(url: soundFileURL,
                                                settings: recordSettings as [String : AnyObject])
            audioRecorder?.prepareToRecord()
            audioRecorder?.delegate=self
        } catch {
            print("Error: \(error)")
        }
    }
    
    func recordAudio() {
        if audioRecorder?.isRecording == false {
            audioRecorder?.record()
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
}
