//
//  ImageController.swift
//  projectForExam
//
//  Created by Stanislav Korolev on 28.03.18.
//  Copyright © 2018 Stanislav Korolev. All rights reserved.
//

import UIKit

private let reuseIdentifier = "cell"

class ImageController: UICollectionViewController, UICollectionViewDelegateFlowLayout {
    
    static var currentOffsetY: CGFloat = 0.0
    
    var imageURLs: [String] =
                    [""]
    
    
    override var prefersStatusBarHidden: Bool {
        return true
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        self.navigationController?.isNavigationBarHidden = true
        self.collectionView?.backgroundColor = UIColor.white
        // Register cell classes
        self.collectionView!.register(ImageCell.self, forCellWithReuseIdentifier: reuseIdentifier)
        self.collectionView?.contentInset = UIEdgeInsets(top: 10,left: 0,bottom: 0,right: 0)

       
    }
    
    

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

  

    // MARK: UICollectionViewDataSource


    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of items
        return imageURLs.count
    }

    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath) as! ImageCell
    
        // Configure the cell
        cell.imageURL = URL(string: imageURLs[indexPath.row])
        
        return cell
    }

    // Размер NewsCard
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: view.frame.width, height: 250)
    }

    
    // SCROLL
    override func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        let currentOffset = scrollView.contentOffset.y
        ImageController.currentOffsetY = currentOffset
        
    }

  

}


class ImageCell: UICollectionViewCell {
    
    /// Is Pressed State
    private var isPressed: Bool = false
    
    
    var imageURL: URL? {
        didSet {
            mainImageView.image = nil
            loadImage()
        }
    }
    
    let spinner: UIActivityIndicatorView = UIActivityIndicatorView()
    
    let mainImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.backgroundColor = .white
        imageView.layer.cornerRadius = 16
        
        
        // Тень
        imageView.layer.shadowRadius = 5.0
        imageView.layer.shadowColor = UIColor.black.cgColor
        imageView.layer.shadowOffset = CGSize(width: 0, height: 2)
        imageView.layer.shadowOpacity = 0.2
        
        imageView.layer.masksToBounds = true
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupViews()
        configureGestureRecognizer()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setupViews(){
        addSubview(mainImageView)
        mainImageView.addSubview(spinner)
        
        addConstraints(withFormat: "H:|-10-[v0]-10-|", views: mainImageView)
        addConstraints(withFormat: "V:|-5-[v0]-5-|", views: mainImageView)
        
        spinner.centerXAnchor.constraint(equalTo: mainImageView.centerXAnchor).isActive = true
        spinner.centerYAnchor.constraint(equalTo: mainImageView.centerYAnchor).isActive = true
        spinner.widthAnchor.constraint(equalToConstant: 30).isActive = true
        spinner.heightAnchor.constraint(equalToConstant: 30).isActive = true
    }
    
    
    
    private func loadImage() {
            if let url = imageURL {
                self.spinner.startAnimating()
                DispatchQueue.global(qos: .userInitiated).async {
                    let contentsOfURL = try? Data(contentsOf: url)
                    DispatchQueue.main.async {
                        if url == self.imageURL {
                            if let imageData = contentsOfURL {
                                self.mainImageView.image = UIImage(data: imageData)
                            }
                            self.spinner.stopAnimating()
                        }
                    }
                }
            }
        }
    
    
    
    // MARK: - Gesture Recognizer
    
    func configureGestureRecognizer() {
        let tapGesture = UILongPressGestureRecognizer(target: self, action: #selector(handleCardGesture(_:)))
        //        // минимальное нажатие
        tapGesture.minimumPressDuration = 0.2
        
        mainImageView.isUserInteractionEnabled = true
        mainImageView.addGestureRecognizer(tapGesture)
    }
    
    @objc func handleCardGesture(_ gestureRecognizer: UILongPressGestureRecognizer){
        //        print(gestureRecognizer.state)
        
        // Получаем нажатое view относительно корненого view, а не ячеек (cell)
        let rectInRootView = self.convert(mainImageView.frame, to: self.superview)
        //        print("tap \(rectInRootView)")
        
        let rectInScreen = CGRect(x: rectInRootView.minX, y: rectInRootView.minY - ImageController.currentOffsetY, width: rectInRootView.width, height: rectInRootView.height)
        
        
        //        print(rectInScreen)
        
        
        if gestureRecognizer.state == .began {
            handleCardBegan(fromRectAnimate: rectInScreen)
        } else if gestureRecognizer.state == .ended || gestureRecognizer.state == .cancelled {
            handleLongPressEnded()
        }
    }
    
    private func handleCardBegan(fromRectAnimate: CGRect){
        print("tap began")
        
        guard !isPressed else {
            return
        }
        
        isPressed = true
        UIView.animate(withDuration: 1,
                       delay: 0.0,
                       usingSpringWithDamping: 0.8,
                       initialSpringVelocity: 0.2,
                       options: .beginFromCurrentState,
                       animations: {
                        self.mainImageView.transform = CGAffineTransform(scaleX: 0.95, y: 0.95)
        },
                       completion: { (value: Bool) in
                        
                        // отображение детально новости
                        let detailImageLauncher = DetailImageLauncher()
                        detailImageLauncher.showDetailNews(imageView: self.mainImageView, rectNews: fromRectAnimate, color: self.mainImageView.backgroundColor!)
        })
    }
    
    private func handleLongPressEnded() {
        print("tap end")
        guard isPressed else {
            return
        }
        
        UIView.animate(withDuration: 1,
                       delay: 0.0,
                       usingSpringWithDamping: 0.5,
                       initialSpringVelocity: 0.2,
                       options: .beginFromCurrentState,
                       animations: {
                        self.mainImageView.transform = CGAffineTransform(scaleX: 1, y: 1)
        }) { (finished) in
            self.isPressed = false
        }
    }
    
}
