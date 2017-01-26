//
//  DeviceCell.swift
//  MyNewt
//
//  Created by David G. Simmons on 12/19/16.
//  Copyright © 2016 Dragonfly IoT. All rights reserved.
//

import UIKit

class DeviceCell: UITableViewCell {

    var deviceNameLabel  = UILabel()
    var deviceValueLabel = UILabel()
    
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
        deviceNameLabel.font = UIFont(name: "HelveticaNeue", size: 14)
        deviceNameLabel.frame = CGRect(x: self.bounds.origin.x+self.layoutMargins.left * 0.5, y: self.bounds.origin.y, width: self.frame.width, height: self.frame.height)
        deviceNameLabel.textAlignment = NSTextAlignment.left
        deviceNameLabel.text = "Sensor Name Label"
        self.addSubview(deviceNameLabel)
        
        // sensor value
        
        deviceValueLabel.font = UIFont(name: "HelveticaNeue", size: 14)
        deviceValueLabel.textAlignment = NSTextAlignment.right
        deviceValueLabel.text = "Value"
        deviceValueLabel.frame = CGRect(x: self.bounds.origin.x-50, y: self.bounds.origin.y, width: self.frame.width, height: self.frame.height)
        self.addSubview(deviceValueLabel)
    }
    
    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }


}
