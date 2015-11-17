//
//  TabbarMenu.swift
//  GooeyTabbar
//
//  Created by KittenYang on 11/16/15.
//  Copyright © 2015 KittenYang. All rights reserved.
//

import UIKit

class TabbarMenu: UIView{
  
  /// 是否打开
  var opened : Bool = false

  private var normalRect : UIView!
  private var springRect : UIView!
  private var keyWindow  : UIWindow!
  private var blurView   : UIVisualEffectView!
  private var displayLink : CADisplayLink!
  private var animationCount : Int = 0
  private var diff : CGFloat = 0
  private var terminalFrame : CGRect?
  private var initialFrame : CGRect?
  private var animateButton : AnimatedButton?
  
  let TOPSPACE : CGFloat = 64.0 //留白
  private var tabbarheight : CGFloat? //tabbar高度
  
  init(tabbarHeight : CGFloat)
  {
    tabbarheight = tabbarHeight
    terminalFrame = CGRect(x: 0, y: 0, width: UIScreen.mainScreen().bounds.size.width, height: UIScreen.mainScreen().bounds.size.height)
    initialFrame = CGRect(x: 0, y: UIScreen.mainScreen().bounds.height - tabbarHeight - TOPSPACE, width: terminalFrame!.width, height: terminalFrame!.height)
    super.init(frame: initialFrame!)
    setUpViews()
  }
  
  
  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  
  override func drawRect(rect: CGRect)
  {
    let path = UIBezierPath()
    path.moveToPoint(CGPoint(x: 0, y: self.frame.height))
    path.addLineToPoint(CGPoint(x: self.frame.width, y: self.frame.height))
    path.addLineToPoint(CGPoint(x: self.frame.width, y: TOPSPACE))
    path.addQuadCurveToPoint(CGPoint(x: 0, y: TOPSPACE), controlPoint: CGPoint(x: self.frame.width/2, y: TOPSPACE-diff))
    path.closePath()
    
    let context = UIGraphicsGetCurrentContext()
    CGContextAddPath(context, path.CGPath)
    UIColor(colorLiteralRed: 50/255.0, green: 58/255.0, blue: 68/255.0, alpha: 1.0).set()
    CGContextFillPath(context)
  }
  
  
  private func setUpViews()
  {
    keyWindow = UIApplication.sharedApplication().keyWindow
    
    blurView = UIVisualEffectView(effect: UIBlurEffect(style: .Dark))
    blurView.frame = self.bounds
    blurView.alpha = 0.0
    keyWindow.addSubview(blurView)
    
    self.backgroundColor = UIColor.clearColor()
    keyWindow.addSubview(self)
    
    normalRect = UIView(frame: CGRect(x: 0, y: UIScreen.mainScreen().bounds.size.height - 30 - 50, width: 30, height: 30))
    normalRect.backgroundColor = UIColor.blueColor()
    normalRect.hidden = true
    keyWindow.addSubview(normalRect)
    
    springRect = UIView(frame: CGRect(x: UIScreen.mainScreen().bounds.size.width/2 - 30/2, y: normalRect.frame.origin.y, width: 30, height: 30))
    springRect.backgroundColor = UIColor.yellowColor()
    springRect.hidden = true
    keyWindow.addSubview(springRect)
    
    animateButton = AnimatedButton(frame: CGRect(x: 0, y: TOPSPACE + (tabbarheight! - 30)/2, width: 50, height: 30))
    self.addSubview(animateButton!)
    animateButton!.didTapped = { (button) -> () in
      self.triggerAction()
    }
    
  }
  
  func triggerAction()
  {
    if animateButton!.animating {
      return
    }
    
    /**
    *  展开
    */
    if !opened {
      opened = true
      startAnimation()
      UIView.animateWithDuration(0.3, delay: 0.0, options: .CurveEaseOut, animations: { () -> Void in
        self.springRect.center = CGPoint(x: self.springRect.center.x, y: self.springRect.center.y - 40)
        }) { (finish) -> Void in
          UIView.animateWithDuration(0.3, delay: 0.0, options: .CurveEaseOut, animations: { () -> Void in
            self.frame = self.terminalFrame!
            }, completion: nil)
          
          UIView.animateWithDuration(0.3, delay: 0.2, options: .CurveEaseOut, animations: { () -> Void in
            self.normalRect.center = CGPoint(x: self.normalRect.center.x, y: 100)
            self.blurView.alpha = 1.0
            }, completion: nil)
          
          UIView.animateWithDuration(1.0, delay: 0.2, usingSpringWithDamping: 0.6, initialSpringVelocity: 0.0, options: .CurveEaseOut, animations: { () -> Void in
            self.springRect.center = CGPoint(x: self.springRect.center.x, y: 100)
            }, completion: { (finish) -> Void in
              self.finishAnimation()
          })
      }
    }else{
      /**
      *  收缩
      */
      opened = false
      startAnimation()
      UIView.animateWithDuration(0.3, delay: 0.0, options: .CurveEaseOut, animations: { () -> Void in
        self.frame = self.initialFrame!
        }, completion: nil)
      
      UIView.animateWithDuration(0.3, delay: 0.0, options: .CurveEaseOut, animations: { () -> Void in
        self.normalRect.center = CGPoint(x: self.normalRect.center.x, y: UIScreen.mainScreen().bounds.size.height - 30 - 50)
        self.blurView.alpha = 0.0
        }, completion: nil)
      
      UIView.animateWithDuration(0.2, delay:0.0, options: .CurveEaseOut, animations: { () -> Void in
        self.springRect.center = CGPoint(x: self.springRect.center.x, y: UIScreen.mainScreen().bounds.size.height - 30 - 50 + 10)
        }, completion: { (finish) -> Void in
          UIView.animateWithDuration(0.2, delay: 0.0, options: .CurveEaseOut, animations: { () -> Void in
            self.springRect.center = CGPoint(x: self.springRect.center.x, y: UIScreen.mainScreen().bounds.size.height - 30 - 50 - 40)
            }, completion: { (finish) -> Void in
              UIView.animateWithDuration(0.2, delay: 0.0, options: .CurveEaseOut, animations: { () -> Void in
                self.springRect.center = CGPoint(x: self.springRect.center.x, y: UIScreen.mainScreen().bounds.size.height - 30 - 50)
                }, completion: { (finish) -> Void in
                  self.finishAnimation()
              })
          })
      })
    }
  }

  
  @objc private func update(displayLink: CADisplayLink)
  {
    let normalRectLayer = normalRect.layer.presentationLayer()
    let springRectLayer = springRect.layer.presentationLayer()
    
    let normalRectFrame = normalRectLayer!.valueForKey("frame")!.CGRectValue
    let springRectFrame = springRectLayer!.valueForKey("frame")!.CGRectValue
    
    diff = normalRectFrame.origin.y - springRectFrame.origin.y
    print("=====\(diff)")
    
    self.setNeedsDisplay()
  }
  
  private func startAnimation()
  {
    if displayLink == nil
    {
      self.displayLink = CADisplayLink(target: self, selector: "update:")
      self.displayLink.addToRunLoop(NSRunLoop.mainRunLoop(), forMode: NSDefaultRunLoopMode)
    }
    animationCount++
  }
  
  private func finishAnimation()
  {
    animationCount--
    if animationCount == 0
    {
      displayLink.invalidate()
      displayLink = nil
    }
  }
  
  
}
