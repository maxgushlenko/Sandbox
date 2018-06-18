//
//  UIPhotoEditorViewController.swift
//  SwiftLearning
//
//  Created by Maxim Gushlenko on 17/05/2018.
//  Copyright © 2018 Max Gushlenko. All rights reserved.
//

import UIKit

class UIPhotoEditorViewController: UIViewController, UIScrollViewDelegate, UIGestureRecognizerDelegate {

    @IBOutlet var imageView : UIImageView!
    @IBOutlet var aScrollView : UIScrollView!
    
    var layerObject: UILayerObject!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        imageView.image = UIImage(named: "BackgroundImage.png")
        imageView.isUserInteractionEnabled = true
        setupScrollView()
        
        let size: CGFloat = 200
        let centerRect = CGRect(x: view.frame.size.width / 2 - size / 2, y: view.frame.size.height / 2 - size / 2, width: size, height: size)
        
        layerObject = UILayerObject(frame: centerRect)
        view.addSubview(layerObject)
        layerObject.prepare()
        layerObject.imageView.image = UIImage(named: "LayerImage.png")
        
        let scrollViewTapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(scrollViewTapped(_:)))
        scrollViewTapGestureRecognizer.numberOfTapsRequired = 1
        scrollViewTapGestureRecognizer.isEnabled = false
        scrollViewTapGestureRecognizer.cancelsTouchesInView = false
        scrollViewTapGestureRecognizer.delegate = self
        aScrollView.addGestureRecognizer(scrollViewTapGestureRecognizer)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - Private method's
    private func setupScrollView () {
        aScrollView.delegate = self
    }

    @objc private func scrollViewTapped(_ sender: UITapGestureRecognizer) {
        /*
         Убираем активное состояние с слоя.
         */
        layerObject.changeState(.inactive)
    }
    
    // MARK: - UIScrollViewDelegate
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return imageView
    }
    
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldReceive touch: UITouch) -> Bool {
        /*
         Игнорируем нажатие, если оно было на subview.
         */
        
        let locationInSubview = touch.location(in: layerObject)
        let touchIsInSubview = layerObject.point(inside: locationInSubview, with: nil)
        
        return !touchIsInSubview
    }
}
