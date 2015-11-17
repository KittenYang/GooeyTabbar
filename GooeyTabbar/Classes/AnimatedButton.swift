//
//  AnimatedButton.swift
//  GooeyTabbar
//
//  Created by KittenYang on 11/16/15.
//  Copyright © 2015 KittenYang. All rights reserved.
//

import UIKit

class AnimatedButton: UIButton
{
  /// 按钮的回调
  var didTapped : ((button:UIButton)->())?
  
  private var firstLine : CALayer!
  private var secondLine : CALayer!
  var animating : Bool = false
  /// 是否打开
  private var opened : Bool = false
  /// 是否正在动画中
  
  override init(frame: CGRect) {
    super.init(frame: frame)
    setUpLines()
  }
  

  required init?(coder aDecoder: NSCoder) {
      fatalError("init(coder:) has not been implemented")
  }
  
  
  private func setUpLines() {
    firstLine = CALayer()
    firstLine.position = CGPoint(x: self.frame.width / 2, y: self.frame.height / 2 - 5)
    firstLine.bounds = CGRect(x: 0, y: 0, width: self.frame.width/2, height: 3)
    setLineSetting(firstLine)
    self.layer.addSublayer(firstLine)
    
    secondLine = CALayer()
    secondLine.position = CGPoint(x: self.frame.width / 2, y: self.frame.height / 2 + 5)
    secondLine.bounds = CGRect(x: 0, y: 0, width: self.frame.width/2, height: 3)
    setLineSetting(secondLine)
    self.layer.addSublayer(secondLine)
    
    self.addTarget(self, action: "animate", forControlEvents: .TouchUpInside)
  }
  
  
  private func setLineSetting(line:CALayer) {
    line.backgroundColor = UIColor.whiteColor().CGColor
    line.cornerRadius = line.frame.height / 2
  }
  
  
  @objc private func animate() {
    
    if animating {
      return
    }

    didTapped?(button: self)
    animating = true
    if !opened {
      opened = true
  
      let moveUp = CABasicAnimation(keyPath: "transform.translation.y")
      moveUp.duration = 0.3
      moveUp.delegate = self
      moveUp.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseOut)
      moveUp.toValue = -5.0
      moveUp.fillMode = kCAFillModeForwards
      moveUp.removedOnCompletion = false
      secondLine.addAnimation(moveUp, forKey: "moveUp_2")
      
      let moveDown = CABasicAnimation(keyPath: "transform.translation.y")
      moveDown.duration = 0.3
      moveDown.delegate = self
      moveDown.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseOut)
      moveDown.toValue = 5.0
      moveDown.fillMode = kCAFillModeForwards
      moveDown.removedOnCompletion = false
      firstLine.addAnimation(moveDown, forKey: "moveDown_1")
      
    }else{
      opened = false
      
      let rotation_second = CAKeyframeAnimation(keyPath: "transform.rotation.z")
      rotation_second.duration = 0.3
      rotation_second.values = [45 * (M_PI/180),70 * (M_PI/180),0]
      rotation_second.keyTimes = [0.0,0.4,1.0]
      rotation_second.fillMode = kCAFillModeForwards
      rotation_second.removedOnCompletion = false
      rotation_second.delegate = self
      secondLine.addAnimation(rotation_second, forKey: "rotation_second_close")
    
      let rotation_first = CAKeyframeAnimation(keyPath: "transform.rotation.z")
      rotation_first.duration = 0.4
      rotation_first.values = [135 * (M_PI/180),170 * (M_PI/180),0]
      rotation_first.keyTimes = [0.0,0.4,1.0]
      rotation_first.fillMode = kCAFillModeForwards
      rotation_first.removedOnCompletion = false
      rotation_first.delegate = self
      firstLine.addAnimation(rotation_first, forKey: "rotation_first_close")
    
    }

  }
  
  
  override func animationDidStart(anim: CAAnimation) {
    

  }
  
  override func animationDidStop(anim: CAAnimation, finished flag: Bool) {
    if anim == secondLine.animationForKey("moveUp_2") {
      let rotation_second = CAKeyframeAnimation(keyPath: "transform.rotation.z")
      rotation_second.duration = 0.5
      rotation_second.values = [0,70 * (M_PI/180),45 * (M_PI/180)]
      rotation_second.keyTimes = [0.0,0.6,1.0]
      rotation_second.fillMode = kCAFillModeForwards
      rotation_second.removedOnCompletion = false
      secondLine.addAnimation(rotation_second, forKey: "rotation_second_open")
      
    }else if anim == firstLine.animationForKey("moveDown_1") {
      let rotation_first = CAKeyframeAnimation(keyPath: "transform.rotation.z")
      rotation_first.duration = 0.6
      rotation_first.values = [0,170 * (M_PI/180),135 * (M_PI/180)]
      rotation_first.keyTimes = [0.0,0.6,1.0]
      rotation_first.fillMode = kCAFillModeForwards
      rotation_first.removedOnCompletion = false
      rotation_first.delegate = self
      firstLine.addAnimation(rotation_first, forKey: "rotation_first_open")
      
    }else if anim == secondLine.animationForKey("rotation_second_close") {
      let moveUp = CABasicAnimation(keyPath: "transform.translation.y")
      moveUp.duration = 0.2
      moveUp.delegate = self
      moveUp.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseOut)
      moveUp.toValue = 0.0
      moveUp.fillMode = kCAFillModeForwards
      moveUp.removedOnCompletion = false
      secondLine.addAnimation(moveUp, forKey: "moveDown_2")
      
    }else if anim == firstLine.animationForKey("rotation_first_close") {
      let moveDown = CABasicAnimation(keyPath: "transform.translation.y")
      moveDown.duration = 0.2
      moveDown.delegate = self
      moveDown.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseOut)
      moveDown.toValue = 0.0
      moveDown.fillMode = kCAFillModeForwards
      moveDown.removedOnCompletion = false
      firstLine.addAnimation(moveDown, forKey: "moveUp_1")
      
    }
      
    if anim == firstLine.animationForKey("rotation_first_open")  || anim == firstLine.animationForKey("moveUp_1"){
      animating = false
    }
  }
  
}





