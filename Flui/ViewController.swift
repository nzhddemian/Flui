//
//  ViewController.swift
//  Flui
//
//  Created by Demian on 11.08.2020.
//  Copyright © 2020 Demian. All rights reserved.
//


import UIKit
import MetalKit
import AudioKit
let MaxBuffers = 3
struct Mouse{
    var points = [float2]()
var mouse = float2()
}
var m = Mouse()
class ViewController: UIViewController {
 static let shared = ViewController()
    
    //AudioKitStuff
    var timer:  Timer!
    var amp = 0.0
    var t = 0.0
     let osc = AKOscillator()
     var mic: AKMicrophone!
    @objc func movv() {
              t+=0.01
              amp = abs(sin(t)/1)
              osc.amplitude = amp+1
             // print(fft?.fftData.max())
              osc.frequency = amp*3200
      
      }
      //AudioKitStuff
    
    
  //  let metalView = MTKView()
  
    var player: AKPlayer!
    var render: Renderer?
     let metalView = MTKView()
//    override func loadView() {
//                  self.view = MTKView()
//
//                  }
//
//    var width: CGFloat{return CGFloat(self.view.frame.width)}
//             var height: CGFloat{return CGFloat(self.view.frame.height)}
    var width: CGFloat{return CGFloat(self.view.frame.width)}
    var height: CGFloat{return CGFloat(self.view.frame.height)}
   
    override func viewDidLoad() {
        super.viewDidLoad()
         let img = UIImage(named: "Background2")
        
        let imgView = UIImageView(image: img)
        
        imgView.contentMode = .scaleAspectFill
        imgView.frame = self.view.frame
        self.view.backgroundColor = .black
      let url = Bundle.main.url(forResource: "Rachmaninov", withExtension: "wav")
        guard let akfile = try? AVAudioFile(forReading: url!) else { return }
       
         if akfile.channelCount != player?.audioFile?.processingFormat.channelCount ||
             akfile.sampleRate != player?.audioFile?.processingFormat.sampleRate {

             AKLog("Need to create new player as formats have changed.")
         }
        //let drumFile = try! AKAudioFile(readFileName: "Rachmaninov.mp3")
        player = AKPlayer(audioFile: akfile)
        player.isLooping = true
        player.buffering = .always
        print(player.processingFormat)
        
       // player.isStarted
         //AudioKitStuff
         mic = AKMicrophone()
          mic.start()
        Timer.scheduledTimer(timeInterval: 0.01, target: self, selector: #selector(ViewController.movv), userInfo: nil, repeats: true)
        AudioKit.output = player
                       do{
                           try! AudioKit.start()
                       
                       }
                
       player.play()
                       osc.start()
        //metalView.delegate = render
                          metalView.frame = CGRect(x: 0, y: 0, width: self.view.frame.width, height: self.view.frame.height)
        //metalView.frame = CGRect(x: 0, y: 0, width: width, height: height)
       // render?.mtkView(metalView, drawableSizeWillChange:  metalView.frame.size)
     //   print("TEXTURE DESCRIPTOR LOADED")
        metalView.frame = CGRect(x: 0, y: 0, width: width, height: height)
                       render = Renderer(metalView, player)
       
        
       // self.view.addSubview(imgView)
          self.view.layer.addSublayer(metalView.layer)
      metalView.isPaused = active
        if(metalView.isPaused){
          print("!!!!!!!! BACKGROUND")
            
        //self.view.insertSubview(meta, belowSubview: <#T##UIView#>)
        }
    }

    


    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()

        print("Got Memory Warning")
    }


}
