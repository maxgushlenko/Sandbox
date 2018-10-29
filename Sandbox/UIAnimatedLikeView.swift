//
//  UIAnimatedLikeView.swift
//  PhotoEditor
//
//  Created by Maksim Gushlenko on 10/19/18.
//  Copyright © 2018 Appyfurious. All rights reserved.
//

import UIKit

class UIAnimatedLikeView: UIView {

    var likeImageView: UIImageView!
    var image: UIImage!
    var imageSize: CGSize = .zero
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    func setupUI(heartImage: UIImage , size: CGSize) {

        image = heartImage
        imageSize = size
        likeImageView = createLike()
        addSubview(likeImageView)
    }
    
    func createLike() -> UIImageView {
        let like = UIImageView(frame: CGRect(x: 0, y: frame.height - imageSize.height, width: imageSize.width, height: imageSize.height))
        like.image = image
        
        return like
    }
    
    func beginLikesAnimation() {
        
        /*
         1. В два раза меньше
         1.1 Диапазон по X позиции
         2. Увеличивается до конечной точки
         3. Поворачивается на 45 градусов до конечной точки
         4. Альфа = 0 до конечной точки
         */
        
        let delaysArray = makeListFLoat(300, from: 0.0, to: 4.0)
        let durationsDelay = makeListFLoat(300, from: 1.0, to: 2.0)
        let xPositionRange = makeList(300, from: 0, to: 40)
        let yPositionRange = makeList(300, from: 0, to: 200)
        
        var delaySum: Double = 0
        var delayAddition: Double = 0
        
        for i in 1...100 {
            
            let randomeDelay = delaysArray.randomElement()!
            delaySum += randomeDelay
            
            let bounds = delaySum / Double(i)
            
            if bounds > 2.0 {
                delayAddition += 2
//                delaySum = 0
            }
            
            let currentDelay = randomeDelay + delayAddition
            
            let container = UIView(frame: CGRect(x: 0, y: frame.height - imageSize.height, width: imageSize.width, height: imageSize.height))
            addSubview(container)
            
            let like = createLike()
            like.frame = CGRect(x: 0, y: 0, width: imageSize.width, height: imageSize.height)
            like.transform = CGAffineTransform.identity.scaledBy(x: 0.5, y: 0.5)
            
            container.addSubview(like)
            
            UIView.animate(withDuration: durationsDelay.randomElement()!, delay: currentDelay, options: .curveEaseOut, animations: {
                
                like.transform = CGAffineTransform(rotationAngle: CGFloat(Double.pi/4.0))
                like.alpha = 0
                
                container.frame = CGRect(x: 0 + CGFloat(xPositionRange.randomElement()!), y: CGFloat(yPositionRange.randomElement()!), width: self.imageSize.width, height: self.imageSize.height)
            }) { (success) in
                
            }
        }
    }
    
    func makeList(_ count: Int, from: Int, to: Int) -> [Int] {
        return (0..<count).map{ _ in Int.random(in: from ... to) }
    }
    
    func makeListFLoat(_ count: Int, from: Double, to: Double) -> [Double] {
        return (0..<count).map{ _ in Double.random(in: from ... to) }
    }
}
