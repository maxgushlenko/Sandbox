//
//  LayerObject.swift
//  Sandbox
//
//  Created by Max Gushlenko on 6/20/18.
//  Copyright © 2018 Max Gushlenko. All rights reserved.
//

import UIKit

class LayerObject: UIView {

    var container: Container!
    
    class func create(_ frame: CGRect, imageName: String) -> LayerObject {
        let layerObject = LayerObject(frame: frame)
        layerObject.container = Container(frame: layerObject.bounds)
        layerObject.clipsToBounds = false
        layerObject.addSubview(layerObject.container)
        layerObject.container.prepare()
        let image = UIImage(named: imageName)
        layerObject.container.setImage(image!)
        
//        layerObject.container.backgroundColor = UIColor.orange
        layerObject.backgroundColor = UIColor.red
        
        return layerObject
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        let panGesture = UIPanGestureRecognizer(target: self, action: #selector(changePositionGesture(_:)))
        panGesture.cancelsTouchesInView = false
        addGestureRecognizer(panGesture)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    @objc private func changePositionGesture (_ sender: UIPanGestureRecognizer) {
        if container.state == .active && container.selectedBorderButton == nil && (sender.state == .began || sender.state == .changed) {
            let translation = sender.translation(in: self.superview)
            let changeX = self.center.x + translation.x
            let changeY = self.center.y + translation.y
            self.center = CGPoint(x: changeX, y: changeY)
            sender.setTranslation(CGPoint.zero, in: self.superview)
        }
    }
}
