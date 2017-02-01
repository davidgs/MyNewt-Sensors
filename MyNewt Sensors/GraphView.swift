//
//  GraphView.swift
//  MyNewt
//
//  Created by David G. Simmons on 1/27/17.
//  Copyright © 2017 Dragonfly IoT. All rights reserved.
//

import UIKit

@IBDesignable class GraphView: UIView {
    
    //Weekly sample data
    var graphPoints:[Int] = [4, 2, 6, 4, 5, 8, 3]
    var pointsArray : [GraphObject] = []
    var dataColors : [UIColor] = [UIColor.white, UIColor.black, UIColor.blue, UIColor.brown, UIColor.darkGray, UIColor.gray]
    var legends : [UILabel] = []
    
    @IBOutlet weak var minLabel: UILabel!
    @IBOutlet weak var maxLabel: UILabel!
    //1 - the properties for the gradient
    @IBInspectable var startColor: UIColor = UIColor.red
    @IBInspectable var endColor: UIColor = UIColor.green
    
    
    
    override func draw(_ rect: CGRect) {
        
        let width = rect.width
        let height = rect.height
        
        //set up background clipping area
        let path = UIBezierPath(roundedRect: rect,
                                byRoundingCorners: UIRectCorner.allCorners,
                                cornerRadii: CGSize(width: 8.0, height: 8.0))
        path.addClip()
        
        //2 - get the current context
        let context = UIGraphicsGetCurrentContext()
        let colors = [startColor.cgColor, endColor.cgColor]
        
        //3 - set up the color space
        let colorSpace = CGColorSpaceCreateDeviceRGB()
        
        //4 - set up the color stops
        let colorLocations:[CGFloat] = [0.0, 1.0]
        
        //5 - create the gradient
        let gradient = CGGradient(colorsSpace: colorSpace,
                                  colors: colors as CFArray,
                                  locations: colorLocations)
        
        //6 - draw the gradient
        var startPoint = CGPoint.zero
        var endPoint = CGPoint(x:0, y:self.bounds.height)
        context?.drawLinearGradient(gradient!,
                                    start: startPoint,
                                    end: endPoint,
                                    options: CGGradientDrawingOptions(rawValue: 0))
        if(pointsArray.count < 1){
            return
        }
        var maxPoints = 0
        for i in 0..<pointsArray.count {
            if(pointsArray[i].vals.max()! > maxPoints){
                maxPoints = pointsArray[i].vals.max()!
            }
        }
        var minPoint = 0
        for i in 0..<pointsArray.count {
            if(pointsArray[i].vals.min()! < minPoint){
                minPoint = pointsArray[i].vals.min()!
            }
        }
        maxLabel.text = String(maxPoints)
        minLabel.text = String(minPoint)
        //calculate the x point
        
        let minY = CGFloat(425.0)
        let minH = self.minLabel.bounds.height
        let labelX = CGFloat(166.0)
        var newOrigin = minY + 25
        // print("Label Origin: \(minY) Height: \(minH) Next Origin: \(newOrigin)")

        
        
        let margin:CGFloat = 20.0
        let columnXPoint = { (column:Int) -> CGFloat in
            //Calculate gap between points
            let spacer = (width - margin*2 - 4) /
                CGFloat(20)
            var x:CGFloat = CGFloat(column) * spacer
            x += margin + 2
            return x
        }
        
        // calculate the y point
        
        let topBorder:CGFloat = 60
        let bottomBorder:CGFloat = 50
        let graphHeight = height - topBorder - bottomBorder
        let maxValue = maxPoints + 20
        let columnYPoint = { (graphPoint:Int) -> CGFloat in
            var y:CGFloat = CGFloat(graphPoint) /
                CGFloat(maxValue) * graphHeight
            y = graphHeight + topBorder - y // Flip the graph
            return y
        }
        for i in 0..<pointsArray.count{
           // draw the line graph
        
            dataColors[i].setFill()
            dataColors[i].setStroke()
            let l = UILabel()
            l.text = pointsArray[i].name
            l.font = UIFont(name: "Avenir Next Condensed Demi Bold", size: 14.0)
            l.textColor = dataColors[i]
            l.frame = CGRect(x: labelX, y: newOrigin, width: 200, height: 21)
            self.addSubview(l)
            newOrigin = newOrigin - 25
            // print("Next origin: \(l.bounds.origin.y) Height: \(l.bounds.height) New Origin: \(newOrigin)")
            let p = pointsArray[i]
            //set up the points line
            let graphPath = UIBezierPath()
            //go to start of line
            graphPath.move(to: CGPoint(x:columnXPoint(0),
                                   y:columnYPoint(p.vals[0])))
        
            //add points for each item in the graphPoints array
            //at the correct (x, y) for the point
            for x in 0..<p.vals.count {
                let y = p.vals[x]
                let nextPoint = CGPoint(x:columnXPoint(x),
                                    y:columnYPoint(p.vals[x]))
                graphPath.addLine(to: nextPoint)
            }
        
            /** /Create the clipping path for the graph gradient
        
            //1 - save the state of the context (commented out for now)
            context?.saveGState()
        
            //2 - make a copy of the path
            let clippingPath = graphPath.copy() as! UIBezierPath
        
            //3 - add lines to the copied path to complete the clip area
            clippingPath.addLine(to: CGPoint(
                x: columnXPoint(20),
                y:height))
            clippingPath.addLine(to: CGPoint(
                x:columnXPoint(0),
                y:height))
            clippingPath.close()
        
            //4 - add the clipping path to the context
            clippingPath.addClip()
        
            let highestYPoint = columnYPoint(maxValue)
            startPoint = CGPoint(x:margin, y: highestYPoint)
            endPoint = CGPoint(x:margin, y:self.bounds.height)
        
            context?.drawLinearGradient(gradient!, start: startPoint, end: endPoint, options: CGGradientDrawingOptions(rawValue: 0))
            context?.restoreGState()
        **/
            //draw the line on top of the clipped gradient
            graphPath.lineWidth = 2.0
            graphPath.stroke()
        
            //Draw the circles on top of graph stroke
            for x in 0..<p.vals.count {
                var point = CGPoint(x:columnXPoint(x), y:columnYPoint(p.vals[x]))
                point.x -= 5.0/2
                point.y -= 5.0/2
            
                let circle = UIBezierPath(ovalIn:
                    CGRect(origin: point,
                       size: CGSize(width: 5.0, height: 5.0)))
                circle.fill()
            }
        }
        
        
        
        //Draw horizontal graph lines on the top of everything
        let linePath = UIBezierPath()
        
        //top line
        linePath.move(to: CGPoint(x:margin, y: topBorder))
        linePath.addLine(to: CGPoint(x: width - margin,
                                     y:topBorder))
        let color = UIColor(white: 1.0, alpha: 0.3)
        color.setStroke()
        linePath.lineWidth = 1.0
        linePath.stroke()
        var linePos = topBorder - 10
        while linePos > (height - bottomBorder) {
            linePath.move(to: CGPoint(x:margin,
                                      y: linePos + topBorder))
            linePath.addLine(to: CGPoint(x:width - margin,
                                         y:linePos + topBorder))
            linePath.stroke()
            linePos = linePos - 10
        }
            

        //center line
    // linePath.move(to: CGPoint(x:margin,
    //                          y: graphHeight/2 + topBorder))
    // linePath.addLine(to: CGPoint(x:width - margin,
    //                             y:graphHeight/2 + topBorder))
        
        //bottom line
    //   linePath.move(to: CGPoint(x:margin,
    //                            y:height - bottomBorder))
    //  linePath.addLine(to: CGPoint(x:width - margin,
    //                                y:height - bottomBorder))
    //   let color = UIColor(white: 1.0, alpha: 0.3)
    //   color.setStroke()
        
    //   linePath.lineWidth = 1.0
    //  linePath.stroke()
        
        
    }
    
    func addDataSource(source: GraphObject){
        pointsArray.append(source)
    }
    
    func addDataPoint(data: Int, name: String){
        for i in 0..<pointsArray.count {
            if(pointsArray[i].name == name) {
                pointsArray[i].addValue(value: data)
                self.setNeedsDisplay(self.bounds)
                return
            }
        }
        let go = GraphObject(name: name)
        go.addValue(value: data)
        pointsArray.append(go)
        self.setNeedsDisplay()
    }
}
