//
//  SignalButton.swift
//  MyNewt
//
//  Created by David G. Simmons on 1/26/17.
//  Copyright © 2017 Dragonfly IoT. All rights reserved.
//

import UIKit

class SignalButton: UIButton {

    
    let NO_SIG = UIImage(named: "NoSignal-sm")
    let ONE_BAR = UIImage(named: "OneBar-sm")
    let TWO_BARS = UIImage(named: "TwoBars-sm")
    let THREE_BARS = UIImage(named: "ThreeBars-sm")
    let FOUR_BARS = UIImage(named: "FourBars-sm")
    
    
    
    func updateSignal(strength: Int){
        if(strength <= 60){
            self.setImage(FOUR_BARS, for: UIControlState.normal)
        } else if(strength <= 75){
            self.setImage(THREE_BARS, for: UIControlState.normal)
        } else if(strength <= 90){
            self.setImage(TWO_BARS, for: UIControlState.normal)
        } else if(strength <= 110){
            self.setImage(ONE_BAR, for: UIControlState.normal)
        } else {
            self.setImage(NO_SIG, for: UIControlState.normal)
        }
        self.setNeedsDisplay(self.bounds)
    }
    
    /*
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
    }
    */

}
