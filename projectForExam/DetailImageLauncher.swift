//
//  DetailNews.swift
//  Demo
//
//  Created by Stanislav Korolev on 06.01.18.
//  Copyright © 2018 Stanislav Korolev. All rights reserved.
//

import UIKit
import CoreML
import Vision



class DetailNews: UIView {
    
    
    
    private var startFrame: CGRect?
    private var color: UIColor?
    private var imageView: UIImageView?
    
    
   
    
    let fullView: UIView = {
        let view = UIView()
        view.layer.cornerRadius = 16
        
        // Тень
        view.layer.shadowRadius = 10.0
        view.layer.shadowColor = UIColor.black.cgColor
        view.layer.shadowOffset = CGSize(width: 0, height: 3)
        view.layer.shadowOpacity = 0.7
        return view
    }()
    var headerImageView: UIImageView = {
        let imageView = UIImageView()
        return imageView
    }()
   
    let textLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        
        label.font = UIFont.systemFont(ofSize: 18)
        label.textColor = UIColor.black
        label.numberOfLines = 0
        label.text = ""

        return label
    }()
    
  
    
    func setImageView(imageView: UIImageView){
       self.imageView = imageView
    }
    
    init(frame: CGRect, color: UIColor, imageView: UIImageView) {
        super.init(frame: frame)
        fullView.frame = frame
        self.imageView = imageView
        
        // запуск анализа изображения
        guard let ciImage = CIImage(image: imageView.image!) else {
            fatalError("couldn't convert UIImage to CIImage")
        }
        
        self.detectScene(image: ciImage)
        
        
        self.color = color
        
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.backgroundColor = .white
    }
    
    
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    

    // установка constrains
    func setupView(){
        
        addSubview(fullView)
        addSubview(fullView)
        fullView.addSubview(headerImageView)
        fullView.addSubview(textLabel)
        
        
        
        addConstraints(withFormat: "H:|[v0]|", views: fullView)
        addConstraints(withFormat: "V:|[v0]|", views: fullView)
        
        fullView.addConstraints(withFormat: "H:|[v0]|", views: headerImageView)
        fullView.addConstraints(withFormat: "H:|-70-[v0]-70-|", views: textLabel)
        fullView.addConstraints(withFormat: "V:|[v0(300)]-20-[v1]", views: headerImageView, textLabel)
        
    }
    
    func startAnimate(rectNews: CGRect){
        
        self.startFrame = rectNews
        
        // установка frame
        fullView.frame = CGRect(x: rectNews.minX, y: rectNews.minY, width: rectNews.width, height: rectNews.height)
        headerImageView = UIImageView(frame: CGRect(x: 0, y: 0, width: rectNews.width, height: rectNews.height))
        
        fullView.backgroundColor = .white
        headerImageView.backgroundColor = self.color
        headerImageView.image = self.imageView?.image
        
        
        setupView()
        
    }
    
    func endAnimate(rectNews: CGRect, rectFull: CGRect){
        
        let rectHeader = CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: rectNews.height - 100)
        
        headerImageView.frame = rectHeader
        fullView.frame = rectFull
    }
    
    
    
    
    // MARK: - PAN GESTURE RECOGNIZE
    
    // PAN лучше
    func configuratePanGestureRecognizer(){
        let pan = UIPanGestureRecognizer(target: self, action: #selector(self.handlePan(_:)))
        
        
        headerImageView.isUserInteractionEnabled = true
        headerImageView.addGestureRecognizer(pan)
    }
    
    @objc func handlePan(_ gesture: UIPanGestureRecognizer){
        let translation = gesture.translation(in: self.fullView)
        let yForClose: CGFloat = 100
        
        print(translation.y)
        if translation.y < 0 {
            return
        }
        
        if translation.y < yForClose{
            self.center = CGPoint(x: self.fullView.center.x, y: self.fullView.center.y + translation.y)
            self.fullView.center =  CGPoint(x: self.fullView.center.x, y: self.fullView.center.y + translation.y)

        }
        if gesture.state == .ended {
            
            if translation.y >= yForClose {
                self.frame = CGRect(x: 0, y: yForClose, width: self.frame.width, height: self.frame.height)
                self.fullView.frame = self.frame
                
              
                
                print("start \(self.frame)")
                print(self.fullView.frame)
                print(self.headerImageView.frame)
                print(UIScreen.main.bounds.width)
                
                
                self.textLabel.text = ""
                self.layoutIfNeeded()
                
                
                UIView.animate(withDuration: 0.5,
                               delay: 0,
                               usingSpringWithDamping: 1,
                               initialSpringVelocity: 1,
                               options: .curveEaseOut,
                               animations: {
                                // КОНЕЧНЫЙ frame
                                
                                print(self.frame)
                                print("end \(self.startFrame!)")
                                self.fullView.frame = self.startFrame!
                                self.frame = self.startFrame!
                                
                                self.fullView.layer.shadowOpacity = 0.1
                                
                                
                              
                                self.layoutIfNeeded()
                                
                                },
                               completion: { (completeAnimation) in
                                
                                print(self.frame)
                                print(self.fullView.frame)
                                // убрать status bar
                                UIApplication.shared.setStatusBarHidden(false, with: .fade)
                                self.removeFromSuperview()
                })
            } else {
                // вернуться в прежнюю позицию
                UIView.animate(withDuration: 0.3, animations: {
                    self.frame.origin = CGPoint.zero
                })
            }
        }
    }
    
}


class DetailImageLauncher: NSObject {
    
    
    
    func showDetailNews(imageView: UIImageView, rectNews: CGRect, color headerColor: UIColor){
        print("Showing detail news")
        print(imageView.image)
        
        // Получаю keyWindow окна, из которого вызываю и отображаю UIView
        if let keyWindow = UIApplication.shared.keyWindow {
            
            // проициализировали стартовый frame для анимации
            let detailNews = DetailNews(frame: keyWindow.frame, color: headerColor, imageView: imageView)
            
            // НАЧАЛЬНЫЙ frame
            detailNews.startAnimate(rectNews: rectNews)
            
            keyWindow.addSubview(detailNews)
        
            
            
            UIView.animate(withDuration: 0.5,
                           delay: 0,
                           usingSpringWithDamping: 1,
                           initialSpringVelocity: 1,
                           options: .curveEaseOut,
                           animations: {
                            // КОНЕЧНЫЙ frame
                            detailNews.endAnimate(rectNews: rectNews, rectFull: keyWindow.frame)
                            
                            },
                           completion: { (completeAnimation) in
                            // убрать status bar
                            
                            
                            
                            // инициализация
                            detailNews.setImageView(imageView: imageView)

                            // pan
                            detailNews.configuratePanGestureRecognizer()
                           

            })
            
        }
    }
    
}


// MARK: - Methods
extension DetailNews {
    
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
