//
//  FirstViewController.swift
//  MyNewt Sensors
//
//  Created by David G. Simmons on 12/13/16.
//  Copyright © 2016 Dragonfly IoT. All rights reserved.
//


import UIKit

class myNewtCell: UITableViewCell {
    
    var sensorNameLabel  = UILabel()
    var sensorValueLabel = UILabel()
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        // sensor name
        sensorNameLabel.font = UIFont(name: "HelveticaNeue", size: 14)
        sensorNameLabel.frame = CGRect(x: self.bounds.origin.x+self.layoutMargins.left * 0.5, y: self.bounds.origin.y, width: self.frame.width, height: self.frame.height)
        sensorNameLabel.textAlignment = NSTextAlignment.left
        sensorNameLabel.text = "Sensor Name Label"
        self.addSubview(sensorNameLabel)

        // sensor value
        
        sensorValueLabel.font = UIFont(name: "HelveticaNeue", size: 14)
              sensorValueLabel.textAlignment = NSTextAlignment.right
        sensorValueLabel.text = "Value"
        sensorValueLabel.frame = CGRect(x: self.bounds.origin.x-50, y: self.bounds.origin.y, width: self.frame.width, height: self.frame.height)
        self.addSubview(sensorValueLabel)
    }
    
    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
