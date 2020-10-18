//
//  Renderer.swift
//  Flui
//
//  Created by Demian on 11.08.2020.
//  Copyright © 2020 Demian. All rights reserved.
//


import MetalKit
import AVFoundation
import AudioKit
 var width = Int()
   var height = Int()

struct VertexData {
    let position: float2
    let texCoord: float2
}

class Renderer: NSObject, MTKViewDelegate {
   var imageBuffer: CVImageBuffer?
    var textureCache: CVMetalTextureCache?
    var session = AVCaptureSession()
    var imageTexture: CVMetalTexture?
    var pixelBuffer:CVPixelBuffer?
    var device: MTLDevice!
     var textureCam: MTLTexture!
     let vertexData: [VertexData] = [
        VertexData(position: float2(x: -1.0, y: -1.0), texCoord: float2(x: 0.0, y: 1.0)),
        VertexData(position: float2(x: 1.0, y: -1.0), texCoord: float2(x: 1.0, y: 1.0)),
        VertexData(position: float2(x: -1.0, y: 1.0), texCoord: float2(x: 0.0, y: 0.0)),
        VertexData(position: float2(x: 1.0, y: 1.0), texCoord: float2(x: 1.0, y: 0.0)),
        ]

    static let indices: [UInt16] = [2, 1, 0, 1, 2, 3]

  var indexData: MTLBuffer?
  var vertData: MTLBuffer?
   // private let vertData = MtlDevice.sharedInstance.buffer(array: vertexData, storageMode: [.storageModeShared])
   // private let indexData = MtlDevice.sharedInstance.buffer(array: indices, storageMode: [.storageModeShared])

    private func vertexFunc(){
             
                 
                vertData =  device.makeBuffer(bytes: vertexData, length: vertexData.count * MemoryLayout<VertexData>.size, options: [])
        let indicesBufferSize = Renderer.indices.count * MemoryLayout.size(ofValue: Renderer.indices[0])
        indexData = device.makeBuffer(bytes: Renderer.indices, length: indicesBufferSize, options: .storageModeShared)
            }
            

    
 
  


    let commandQueue: MTLCommandQueue
     var defaultLibrary: MTLLibrary
    var ffft:MTLBuffer!
      var fft: AKFFTTap?
    
    
    
    
   //MARK: init
    init(_ metalView: MTKView,_ sound: AKNode) {
        device = MTLCreateSystemDefaultDevice()!
        metalView.device = device
        metalView.colorPixelFormat = .bgra8Unorm
        
      //  metalView.preferredFramesPerSecond = 15
       commandQueue =  device.makeCommandQueue()!
         defaultLibrary = device.makeDefaultLibrary()!
          super.init()
        
       // setupDevice()
         metalView.delegate = self
       // createTextureCache()
         fft = AKFFTTap.init(sound)
        setupPipeState()
      vertexFunc()
        setupTextures()
        
        
    }
       //MARK: init
    
    
    
    
    
    
    
    
    
    
    
       //MARK: setupTextures
    var tex: MTLTexture!
    func setupTextures(){

           let w = Int(Float(width))// / Renderer.ScreenScaleAdjustment)
             let h = Int(Float(height))// /
          
          let textureDescriptor = MTLTextureDescriptor()
                 textureDescriptor.pixelFormat = .rg16Float
                 textureDescriptor.usage = MTLTextureUsage(rawValue: MTLTextureUsage.shaderRead.rawValue | MTLTextureUsage.renderTarget.rawValue)
                textureDescriptor.width = 1000
                 textureDescriptor.height = 1000
               //  textureDescriptor.storageMode = .private

                  print("TEXTURE DESCRIPTOR FUNC")
                         ping = device.makeTexture(descriptor: textureDescriptor)
                         pong = device.makeTexture(descriptor: textureDescriptor)
        
        
        
        let texLoad = MTKTextureLoader(device: device)
        tex = try! texLoad.newTexture(name: "controlBackground", scaleFactor: 1, bundle: Bundle.main, options: nil)
        
        
    }
     //MARK: setupTextures
    
    
    
    
    
    
    
      //MARK: Pipe State
    
    var applyPipeState: MTLRenderPipelineState?
    var renderPipeState: MTLRenderPipelineState?
    
      private func setupPipeState(){
       
              guard let vertexFunction = defaultLibrary.makeFunction(name: "vertexShader") else {fatalError()}
              guard let fragmentFunctionVis = defaultLibrary.makeFunction(name: "visualizeScalar") else {fatalError()}
                     let pipelineStateDescriptorRendr = MTLRenderPipelineDescriptor()
                     pipelineStateDescriptorRendr.colorAttachments[0].pixelFormat = .bgra8Unorm
        // glEnable(GL_BLEND)
        pipelineStateDescriptorRendr.colorAttachments[0].isBlendingEnabled = true

        // glBlendFuncSeparate(GL_SRC_ALPHA,GL_ONE_MINUS_SRC_ALPHA,GL_ONE,GL_ONE_MINUS_SRC_ALPHA)
        pipelineStateDescriptorRendr.colorAttachments[0].sourceRGBBlendFactor = .sourceAlpha
        pipelineStateDescriptorRendr.colorAttachments[0].destinationRGBBlendFactor = .oneMinusSourceAlpha
        pipelineStateDescriptorRendr.colorAttachments[0].sourceAlphaBlendFactor = .one
        pipelineStateDescriptorRendr.colorAttachments[0].destinationAlphaBlendFactor = .oneMinusSourceAlpha

        // glBlendFuncSeparate(GL_SRC_ALPHA, GL_ONE, GL_SRC_ALPHA, GL_ONE)
//        pipelineStateDescriptorRendr.colorAttachments[0].sourceRGBBlendFactor = .sourceAlpha
//        pipelineStateDescriptorRendr.colorAttachments[0].destinationRGBBlendFactor = .one
//        pipelineStateDescriptorRendr.colorAttachments[0].sourceAlphaBlendFactor = .sourceAlpha
//        pipelineStateDescriptorRendr.colorAttachments[0].destinationAlphaBlendFactor = .one

                     pipelineStateDescriptorRendr.vertexFunction = vertexFunction
                     pipelineStateDescriptorRendr.fragmentFunction = fragmentFunctionVis
        //pipelineStateDescriptorRendr.colorAttachments[0]
                     renderPipeState = try! device.makeRenderPipelineState(descriptor: pipelineStateDescriptorRendr)
                     
                     
           // renderPipeState =  try! MtlDevice.createRenderPipeline(vertexFunctionName: "vertexShader", fragmentFunctionName: "visualizeScalar", pixelFormat: .bgra8Unorm)
        
        
       
                   guard let fragmentFunctionApply = defaultLibrary.makeFunction(name: "applyForceScalar") else {fatalError()}
                          let pipelineStateDescriptorApply = MTLRenderPipelineDescriptor()
                          pipelineStateDescriptorApply.colorAttachments[0].pixelFormat = .rg16Float
                          pipelineStateDescriptorApply.vertexFunction = vertexFunction
                          pipelineStateDescriptorApply.fragmentFunction = fragmentFunctionApply
             //pipelineStateDescriptorRendr.colorAttachments[0]
                          applyPipeState = try! device.makeRenderPipelineState(descriptor: pipelineStateDescriptorApply)
        
        
              // applyPipeState =  try! MtlDevice.createRenderPipeline(vertexFunctionName: "vertexShader", fragmentFunctionName: "applyForceScalar", pixelFormat: .rg16Float)
             }
        //MARK: Pipe State
    
    
    
    
    
     //MARK: createTextureCache
    func createTextureCache() {
        var newTextureCache: CVMetalTextureCache?
        if CVMetalTextureCacheCreate(kCFAllocatorDefault, nil, device, nil, &newTextureCache) == kCVReturnSuccess {
            textureCache = newTextureCache
        } else {
            assertionFailure("Unable to allocate texture cache")
        }
    }
     //MARK: createTextureCache
    

   

    
    
      //MARK: DRAW
    
    
    var res:float2 = float2()
   var tt = Float(0)
    var ping: MTLTexture!
    var pong: MTLTexture!
    
    
    func draw(in view: MTKView) {
       
      //  view.waitUntilScheduled()
        //print(view.isPaused)
        let commandBuffer = commandQueue.makeCommandBuffer()!
         
//        guard let previewPixelBuffer = pixelBuffer else {
//             return
//     }
        
        res.x = Float(view.frame.width)
                       res.y = Float(view.frame.height)
  //     CamTexture
//let width = CVPixelBufferGetWidth(previewPixelBuffer)
//let height = CVPixelBufferGetHeight(previewPixelBuffer)
//         var cvTextureOut: CVMetalTexture?
//         CVMetalTextureCacheCreateTextureFromImage(kCFAllocatorDefault,textureCache!,previewPixelBuffer,nil,.bgra8Unorm,width,height,0,&cvTextureOut)
//         guard let cvTexture = cvTextureOut, let texture = CVMetalTextureGetTexture(cvTexture) else {return}
//

         //CamTexture
        
        
          var ft = [Float]()
        for i in 0...128{ft.append(Float((self.fft?.fftData[i])!))}
        print(ft.count)
        ffft = device.makeBuffer(bytes: ft, length: ft.count*MemoryLayout<Float>.stride, options:[])
        tt+=0.1

        if let renderPipelineState = applyPipeState {
                    let renderPassDescriptor = MTLRenderPassDescriptor()
                          renderPassDescriptor.colorAttachments[0].texture = pong
                          renderPassDescriptor.colorAttachments[0].clearColor = MTLClearColorMake(0.0, 0.0, 0.0, 0.0)
                     //  print("!!!!!!RenderShader calculateWithCommandBuffer!!!!!!!")
                   if let commandEncoder = commandBuffer.makeRenderCommandEncoder(descriptor: renderPassDescriptor) {
                       
                     
                    //   configureEncoder(commandEncoder)
                        commandEncoder.setVertexBuffer(self.vertData, offset: 0, index: 0)
                       commandEncoder.setFragmentTexture(ping, index: 0)
                     //CamTexture
                   //    commandEncoder.setFragmentTexture(texture, index: 5)
                       
                       
                       
                    var mx = Float((self.fft?.fftData.max())!)
            commandEncoder.setFragmentBuffer(ffft, offset: 0, index: 4)
            commandEncoder.setFragmentBytes(&tt, length: MemoryLayout<Float>.stride, index: 3)
            commandEncoder.setFragmentBytes(&mx, length: MemoryLayout<Float>.stride, index: 5)
            commandEncoder.setFragmentBytes(&res, length: MemoryLayout<float2>.stride, index: 1)
                       
               // commandEncoder.setFragmentBuffer(dataBuffer, offset: 0, index: 1)
                       commandEncoder.setRenderPipelineState(renderPipelineState)
                       
                       commandEncoder.drawIndexedPrimitives(type: .triangle, indexCount: Renderer.indices.count, indexType: .uint16, indexBuffer: indexData!, indexBufferOffset: 0)
                       
                       commandEncoder.endEncoding()
        
            }
        
        }

            
        let temp = ping
        ping = pong
        pong = temp
        
         let drawable = view.currentDrawable

       //  renderScalar.calculateWithCommandBuffer(buffer: commandBuffer, indices: indexData, count: Renderer.indices.count, texture: drawable.texture) { (commandEncoder) in
            
            
            
            if let renderPipelineState = renderPipeState {
                       let renderPassDescriptor = MTLRenderPassDescriptor()
                renderPassDescriptor.colorAttachments[0].texture = drawable?.texture
                            renderPassDescriptor.colorAttachments[0].clearColor = MTLClearColorMake(0.0, 0.0, 0.0, 0.0)
                          //print("!!!!!!RenderShader calculateWithCommandBuffer!!!!!!!")
                      if let commandEncoder = commandBuffer.makeRenderCommandEncoder(descriptor: renderPassDescriptor) {
            commandEncoder.setRenderPipelineState(renderPipelineState)
            commandEncoder.setVertexBuffer(self.vertData, offset: 0, index: 0)
                        commandEncoder.setFragmentTexture(tex, index: 6)
            commandEncoder.setFragmentBytes(&res, length: MemoryLayout<float2>.stride, index: 1)
            commandEncoder.setFragmentBytes(&tt, length: MemoryLayout<Float>.stride, index: 3)
            commandEncoder.setFragmentBuffer(ffft, offset: 0, index: 4)
            commandEncoder.setFragmentTexture(ping, index: 0)
            commandEncoder.drawIndexedPrimitives(type: .triangle, indexCount: Renderer.indices.count, indexType: .uint16, indexBuffer: indexData!, indexBufferOffset: 0)
commandEncoder.endEncoding()
                  }
            }
            commandBuffer.addCompletedHandler { cb in
                let executionDuration = cb.gpuEndTime - cb.gpuStartTime
              //  cb.waitUntilScheduled()
               // print(executionDuration)
            }
            ///commandBuffer.present(drawable!)
        
        
        commandBuffer.commit()
        commandBuffer.waitUntilScheduled()
      //  view.isPaused = active
        drawable!.present()
       
    }
   //MARK: DRAW
    
    
    
    
    
    
    
    //MARK: MTKView
    func mtkView(_ view: MTKView, drawableSizeWillChange size: CGSize) {
        print(view.frame.width)
    
//
    }
}

   //MARK: MTKView






















//MARK: - CAMERA


//extension Renderer: AVCaptureVideoDataOutputSampleBufferDelegate{
//    
//    
//    func setupDevice() {
//          // guard let capDevice = AVCaptureDevice.default(for: .video) else {return}
//            guard let capDevice = AVCaptureDevice.DiscoverySession(deviceTypes: [.builtInWideAngleCamera], mediaType: AVMediaType.video, position: .back).devices.first else {return}
//            guard let input = try? AVCaptureDeviceInput(device: capDevice) else {return}
//            session.sessionPreset = .inputPriority
//           session.sessionPreset = AVCaptureSession.Preset.inputPriority
//          
//            session.addInput(input)
//            session.startRunning()
//            let dataOutput = AVCaptureVideoDataOutput()
//        dataOutput.videoSettings = [
//                   kCVPixelBufferPixelFormatTypeKey as String: Int(kCVPixelFormatType_32BGRA)
//               ]
//            dataOutput.setSampleBufferDelegate(self, queue: DispatchQueue(label: "videoQueue"))
//            session.addOutput(dataOutput)
//            //changeCamera()
//               //currentCamera = getFrontCamera()
//         }
//        
//          
//        
//        func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
//              
//            connection.videoOrientation = .portrait
//              //  self.ppixelFormat = pixelFormat
//              pixelBuffer = CMSampleBufferGetImageBuffer(sampleBuffer)
//            
//            
//       }
//       
//    
//}
//MARK: - CAMERA




//MARK: - CAMERA PIXEL FORMAT
public enum MetalCameraPixelFormat {
    case rgb
    case yCbCr
    
    var coreVideoType: OSType {
        switch self {
        case .rgb:
            return kCVPixelFormatType_32BGRA
        case .yCbCr:
            return kCVPixelFormatType_420YpCbCr8BiPlanarVideoRange
        }
    }
}
