//
//  ViewController.swift
//  Sandbox
//
//  Created by Max Gushlenko on 6/18/18.
//  Copyright © 2018 Max Gushlenko. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    @IBOutlet var animatedView: UIView!
    @IBOutlet var label: UILabel!
    
    @IBOutlet var firstView: UIView!
    @IBOutlet var secondView: UIView!
    
    let likeView = UIAnimatedLikeView()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        animatedView.layer.cornerRadius = 12
        animatedView.layer.borderWidth = 3
        animatedView.layer.borderColor = UIColor.purple.cgColor
        
        addAnimation(to: animatedView)
        
        drawLineBetween(topView: firstView, bottomView: secondView)
        
        
        likeView.frame = CGRect(x: 160, y: 0, width: 50, height: 350)
        likeView.backgroundColor = UIColor.purple
        likeView.setupUI(heartImage: UIImage(named: "tutorial_like_red")!, size: CGSize(width: 50, height: 50))
        
        view.addSubview(likeView)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    
    @IBAction func sendLike() {
        likeView.beginLikesAnimation()
    }
    
    @objc func sliderValueViewShow() {
        
        UIView.animate(withDuration: 0.2) {
            let shrink = CGAffineTransform(scaleX: 1, y: 1)
            let translate = CGAffineTransform(translationX: 0, y: 0)
            self.animatedView.transform = shrink.concatenating(translate)
        }
    }
    
    @objc func sliderValueViewHide() {
        
        UIView.animate(withDuration: 0.1) {
            let shrink = CGAffineTransform(scaleX: 0.01, y: 0.01)
            self.animatedView.transform = shrink
        }
    }
    
    func addAnimation(to view: UIView) {
        let scaleAnimation = CAKeyframeAnimation(keyPath: "transform.scale")
        scaleAnimation.duration = 2
        scaleAnimation.repeatCount = .infinity
        scaleAnimation.values = [1.16, 1.06]
        scaleAnimation.autoreverses = true
        scaleAnimation.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseOut)
        scaleAnimation.keyTimes = [0.233, 0.633, 0.933]
        
        view.layer.add(scaleAnimation, forKey: "pulse")
    }
    
    func drawLineBetween(topView: UIView, bottomView: UIView) {
        
        let distanceByY = bottomView.frame.minY - topView.frame.maxY
        let distanceByX = topView.frame.maxX - bottomView.frame.minY
        
        let bottomCenterPoint = CGPoint(x: bottomView.frame.origin.x + bottomView.frame.width / 2, y: bottomView.frame.origin.y)
        let topCenterPoint = CGPoint(x: topView.frame.origin.x + topView.frame.width / 2, y: topView.frame.maxY)
        let cornerRadius = distanceByY / 2
        
        /*
         Полоса рисуется от нижней вьюхе к верхней вьюхе.
         Создаём значения с направлением вправо.
         */
        
        var firstCornerEndPoint = CGPoint(x: bottomCenterPoint.x + cornerRadius, y: bottomCenterPoint.y - distanceByY / 2)
        var firstCornerControlPoint = CGPoint(x: firstCornerEndPoint.x - cornerRadius, y: firstCornerEndPoint.y)
        
        var secondHorizontalLineEndPoint = CGPoint(x: topCenterPoint.x - cornerRadius, y: firstCornerEndPoint.y)
        
        var thirdCornerEndPoint = CGPoint(x: topCenterPoint.x, y: topCenterPoint.y)
        var thirdCornerControlPoint = CGPoint(x: topCenterPoint.x, y: secondHorizontalLineEndPoint.y)
        
        /*
         Изменяем направление влево, если нужно.
         */
        
        if bottomCenterPoint.x > topCenterPoint.x {
            firstCornerEndPoint = CGPoint(x: bottomCenterPoint.x - cornerRadius, y: bottomCenterPoint.y - distanceByY / 2)
            firstCornerControlPoint = CGPoint(x: firstCornerEndPoint.x + cornerRadius, y: firstCornerEndPoint.y)
            
            secondHorizontalLineEndPoint = CGPoint(x: topCenterPoint.x + cornerRadius, y: firstCornerEndPoint.y)
            
            thirdCornerEndPoint = CGPoint(x: topCenterPoint.x, y: topCenterPoint.y)
            thirdCornerControlPoint = CGPoint(x: secondHorizontalLineEndPoint.x - cornerRadius, y: secondHorizontalLineEndPoint.y)
        }
        
        /*
         */
        
        let path = CGMutablePath()
        path.move(to: bottomCenterPoint)
        path.addQuadCurve(to: firstCornerEndPoint, control: firstCornerControlPoint)
        path.addLine(to: secondHorizontalLineEndPoint)
        path.addQuadCurve(to: thirdCornerEndPoint, control: thirdCornerControlPoint)
        
        let lineShapeLayer = CAShapeLayer(layer: view.layer)
        lineShapeLayer.path = path
        lineShapeLayer.strokeColor = #colorLiteral(red: 0.9176470588, green: 0.8, blue: 1, alpha: 1).cgColor
        lineShapeLayer.lineWidth = 2
        lineShapeLayer.lineJoin = kCALineJoinRound
        lineShapeLayer.backgroundColor = UIColor.clear.cgColor
        lineShapeLayer.fillColor = UIColor.clear.cgColor
        view.layer.addSublayer(lineShapeLayer)
    }
}

