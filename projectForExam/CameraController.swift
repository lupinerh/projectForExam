//
//  CameraViewController.swift
//  projectForExam
//
//  Created by Stanislav Korolev on 29.03.18.
//  Copyright © 2018 Stanislav Korolev. All rights reserved.
//

import UIKit
import AVKit
import Vision


class CameraController: UIViewController, AVCaptureVideoDataOutputSampleBufferDelegate {
    
    let captureSession = AVCaptureSession()
    
    override var prefersStatusBarHidden: Bool {
        return true
    }

    let textContainerView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.white
        return view
    }()
    let textLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        
        label.font = UIFont.systemFont(ofSize: 16)
        label.textColor = UIColor.black
        label.numberOfLines = 0
        label.text = ""
        label.textAlignment = .center
        //        label.sizeToFit()
        //        label.layer.borderColor = UIColor.black.cgColor
        //        label.layer.borderWidth = 3.0
        return label
    }()
    
    override func viewWillAppear(_ animated: Bool) {
        print("appear")
        self.setupCamera()
    }
    override func viewWillDisappear(_ animated: Bool) {
        print("disappear")
        self.captureSession.stopRunning()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationController?.isNavigationBarHidden = true
        self.view.backgroundColor = .white

        

    }
    
    func setupCamera(){
//        self.captureSession = AVCaptureSession()
//        captureSession.sessionPreset = .photo
        
        guard let captureDevice = AVCaptureDevice.default(for: .video) else {
            return
        }
        guard let input = try? AVCaptureDeviceInput(device: captureDevice) else {
            return
        }
        self.captureSession.addInput(input)
        
        self.captureSession.startRunning()
        
        let previewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
        view.layer.addSublayer(previewLayer)
        previewLayer.frame = CGRect(x: 0, y: 30, width: self.view.frame.width, height: self.view.frame.height)
        
        let dataOutput = AVCaptureVideoDataOutput()
        dataOutput.setSampleBufferDelegate(self, queue: DispatchQueue(label: "videoQueue"))
        self.captureSession.addOutput(dataOutput)
        
        print(dataOutput)
       
        setupView()
    }
    
    func setupView(){
        
        view.addSubview(textLabel)
        
        self.textLabel.centerXAnchor.constraint(equalTo: self.view.centerXAnchor).isActive = true
        self.textLabel.topAnchor.constraint(equalTo: self.view.topAnchor, constant: 0).isActive = true


    }
    

    func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {


        guard let pixelBuffer: CVPixelBuffer = CMSampleBufferGetImageBuffer(sampleBuffer) else {
            print("pixelBuffer out")
            return
        }

        guard let model = try? VNCoreMLModel(for: Resnet50().model) else {
            print("model out")
            return
        }
        let request = VNCoreMLRequest(model: model) {
             (finishedReq, err) in

            // perhaps check the err
            guard let result = finishedReq.results as? [VNClassificationObservation] else {
                return
            }
            guard let firstObservation = result.first else {
                return
            }

            print(firstObservation.identifier, firstObservation.confidence)
            
            let text = String(firstObservation.identifier) + " " + String(firstObservation.confidence)
            
            DispatchQueue.main.async {
                self.textLabel.text = text
            }
        
        }

        try? VNImageRequestHandler(cvPixelBuffer: pixelBuffer, options: [ : ]).perform([request])
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

  

}
