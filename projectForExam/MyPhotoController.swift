//
//  MyPhotoController.swift
//  projectForExam
//
//  Created by Stanislav Korolev on 28.03.18.
//  Copyright © 2018 Stanislav Korolev. All rights reserved.
//

import UIKit
import CoreML
import Vision

class MyPhotoController: UIViewController {
    
    let myImageView: UIImageView = {
        let imageView = UIImageView()
        //        imageView.image = UIImage(named: String)
        imageView.backgroundColor = UIColor.randomLightColor()
        
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.contentMode = .scaleAspectFill
        imageView.layer.cornerRadius = 0
        imageView.layer.masksToBounds = true
        
        
        return imageView
    }()
    let textLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        
        label.font = UIFont.systemFont(ofSize: 16)
        label.textColor = .black
        label.numberOfLines = 0
        label.text = ""
        label.textAlignment = .center
        //        label.sizeToFit()
        //        label.layer.borderColor = UIColor.black.cgColor
        //        label.layer.borderWidth = 3.0
        return label
    }()
    let placeholderLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        
        label.font = UIFont.boldSystemFont(ofSize: 24)
        label.textColor = .white
        label.numberOfLines = 0
        label.text = "SELECT IMAGE"
        label.textAlignment = .center
        //        label.sizeToFit()
        //        label.layer.borderColor = UIColor.black.cgColor
        //        label.layer.borderWidth = 3.0
        return label
    }()
    
    override var prefersStatusBarHidden: Bool {
        return true
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationController?.navigationBar.isHidden = true
        self.view.backgroundColor = .white
        print(myImageView.backgroundColor)

        setupView()
        setupTarget()
    }
    
    func setupView(){
        // myImageView
        view.addSubview(myImageView)
        myImageView.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        myImageView.topAnchor.constraint(equalTo: view.topAnchor, constant: 0).isActive = true
        myImageView.widthAnchor.constraint(equalToConstant: view.frame.width).isActive = true
        myImageView.heightAnchor.constraint(equalToConstant: 300).isActive = true
        
        view.addSubview(textLabel)
        textLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        textLabel.topAnchor.constraint(equalTo: myImageView.bottomAnchor, constant: 30).isActive = true
        textLabel.widthAnchor.constraint(equalToConstant: view.frame.width).isActive = true
        textLabel.heightAnchor.constraint(equalToConstant: 50).isActive = true
        
        view.addSubview(placeholderLabel)
        placeholderLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        placeholderLabel.centerYAnchor.constraint(equalTo: myImageView.centerYAnchor, constant:0).isActive = true
//        placeholderLabel.widthAnchor.constraint(equalToConstant: view.frame.width).isActive = true
//        texplaceholderLabeltLabel.heightAnchor.constraint(equalToConstant: 50).isActive = true
        
        
    }
    
    func setupTarget(){
        let tap = UITapGestureRecognizer(target: self, action: #selector(handleSelectMyImageView))
        myImageView.isUserInteractionEnabled = true
        myImageView.addGestureRecognizer(tap)
        
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    


}


// MARK: - Methods
extension MyPhotoController {
    
    func detectScene(image: CIImage) {
        
        
        self.textLabel.text = "detecting scene..."
        
        // Load the ML model through its generated class
        guard let model = try? VNCoreMLModel(for: GoogLeNetPlaces().model) else {
            fatalError("can't load Places ML model")
        }
        
        // Create a Vision request with completion handler
        let request = VNCoreMLRequest(model: model) { [weak self] request, error in
            guard let results = request.results as? [VNClassificationObservation],
                let topResult = results.first else {
                    fatalError("unexpected result type from VNCoreMLRequest")
            }
            
            // Update UI on main queue
            //            let article = (self?.vowels.contains(topResult.identifier.first!))! ? "an" : "a"
            DispatchQueue.main.async { [weak self] in
                self?.textLabel.text = "\(Int(topResult.confidence * 100))% it's  \(topResult.identifier)"
            }
        }
        
        // Run the Core ML GoogLeNetPlaces classifier on global dispatch queue
        let handler = VNImageRequestHandler(ciImage: image)
        DispatchQueue.global(qos: .userInteractive).async {
            do {
                try handler.perform([request])
            } catch {
                print(error)
            }
        }
    }
}

