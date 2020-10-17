////
////  MetalDevicor.swift
////  Flui
////
////  Created by Demian on 11.08.2020.
////  Copyright © 2020 Demian. All rights reserved.
////
//
//import MetalKit
//
//enum MetalDevicor: Error {
//    case failedToCreateFunction(name: String)
//}
//
//class MtlDevice {
//    static let sharedInstance = MtlDevice()
//    
//  
//    
//    let queue = DispatchQueue.global(qos: .background)
//    
//    let device: MTLDevice
//    private let commandQueue: MTLCommandQueue
//    
//    var activeCommandBuffer: MTLCommandBuffer
//    var defaultLibrary: MTLLibrary
//    
//    internal var inputTexture: MTLTexture?
//    internal var outputTexture: MTLTexture?
//    
//    private init() {
//        device = MTLCreateSystemDefaultDevice()!
//        commandQueue = device.makeCommandQueue()!
//         print("!!!!!!initMtlDevice!!!!!!!")
//        activeCommandBuffer = commandQueue.makeCommandBuffer()!
//       
//        defaultLibrary = device.makeDefaultLibrary()!
//    }
//    
//    //Convenience methods
//    
////    final class func createRenderPipeline(vertexFunctionName: String = "basicVertexFunction", fragmentFunctionName: String, pixelFormat: MTLPixelFormat) throws -> MTLRenderPipelineState {
////          print("!!!!!!MtlDevicecreateRenderPipeline!!!!!!!")
////        return try self.sharedInstance.createRenderPipeline(vertexFunctionName: vertexFunctionName, fragmentFunctionName: fragmentFunctionName, pixelFormat: pixelFormat)
////    }
//    
//
//    
//    final class func createTexture(descriptor: MTLTextureDescriptor) -> MTLTexture {
//            print("!!!!!!MtlDevicemakeTexture!!!!!!!")
//        return self.sharedInstance.device.makeTexture(descriptor: descriptor)!
//    }
//    
//
//    
////    final func buffer<T>(array: Array<T>, storageMode: MTLResourceOptions = []) -> MTLBuffer {
////        let size = array.count * MemoryLayout.size(ofValue: array[0])
////        return device.makeBuffer(bytes: array, length: size, options: storageMode)!
////    }
//    
////    final func newCommandBuffer() -> MTLCommandBuffer {
////         print("!!!!!!MtlDevicemakeCommandBuffer!!!!!!!")
////        return commandQueue.makeCommandBuffer()!
////    }
//    
////    final func createRenderPipeline(vertexFunctionName: String = "basicVertexFunction", fragmentFunctionName: String, pixelFormat: MTLPixelFormat) throws -> MTLRenderPipelineState {
////         print("!!!!!!MtlDevicecreateRenderPipeline!!!!!!!")
////
////
////
////
////
////        guard let vertexFunction = defaultLibrary.makeFunction(name: vertexFunctionName) else {fatalError()}
////        guard let fragmentFunction = defaultLibrary.makeFunction(name: fragmentFunctionName) else {fatalError()}
////        let pipelineStateDescriptor = MTLRenderPipelineDescriptor()
////        pipelineStateDescriptor.colorAttachments[0].pixelFormat = pixelFormat
////        pipelineStateDescriptor.vertexFunction = vertexFunction
////        pipelineStateDescriptor.fragmentFunction = fragmentFunction
////        let pipelineState = try device.makeRenderPipelineState(descriptor: pipelineStateDescriptor)
////
////
////
////        return pipelineState
////    }
////
//}
