//
//  UIGraph.swift
//  MathKit
//
//  Created by Liam Stevenson on 2/8/17.
//  Copyright © 2017 Liam Stevenson. All rights reserved.
//

import Foundation
import SpriteKit

/// An SKView that displays a graphs of functions
public class GraphScene: SKScene {

    /// The window currently being displayed
    public var graphWindow = Window()
    
    /// The thickness of the line
    public var thickness: CGFloat = 1
    
    /// The color of points of interest on the graph
    public var pointColor = SKColor.black
    
    /// The color of the main axes
    public var mainAxesColor = SKColor.darkGray
    
    /// The thickness of the main axes
    public var mainAxesThickness: CGFloat = 2
    
    /// The color of the minor axes
    public var minorAxesColor = SKColor.lightGray
    
    /// The thickness of the minor axes
    public var minorAxesThickness: CGFloat = 1
    
    /// The font size of the axes labels
    public var labelFontSize: CGFloat = 15
    
    /// The font color of the axes labels
    public var labelFontColor = SKColor.black
    
    /// The background color of the axes labels
    public var labelBackgroundColor = SKColor.white
    
    /// The points of intersection
    private var intersectPoints = [Point]()
    
    /// The points of zeroes
    private var zeroPoints = [Point]()
    
    /// The extreme points
    private var extremePoints = [Point]()
    
    /// Array of the functions on the graph; associated booleans determine whether the function should be displayed; SKColor is the color of the line
    public var functions = [(Function, Bool, SKColor)]() {
        
        didSet {
            
            clearPoints()
            
        }
        
    }
    
    /**
 
    Redraws based on `graphWindow`, `xAxisPixels`, and `yAxisPixels`
     
    */
    public func update() {
        
        removeAllChildren()
        
        let increment = (graphWindow.width) / Number(int: Int(size.width) - 1)
        
        //draw main axes
        if try! graphWindow.minX <= Number.zero && Number.zero <= graphWindow.maxX {
            
            let convertedX = CGFloat(Double(Number.zero - graphWindow.minX)!) * (self.frame.width) / CGFloat(Double(graphWindow.width)!) + self.frame.minX
            
            let pointA = CGPoint(x: convertedX, y: self.frame.minY)
            let pointB = CGPoint(x: convertedX, y: self.frame.maxY)
            
            let shape = SKShapeNode()
            let path = CGMutablePath()
            path.move(to: pointA)
            path.addLine(to: pointB)
            
            shape.zPosition = -1
            shape.path = path
            shape.strokeColor = mainAxesColor
            shape.lineWidth = mainAxesThickness
            addChild(shape)
            
        }
        if try! graphWindow.minY <= Number.zero && Number.zero <= graphWindow.maxY {
            
            let convertedY = CGFloat(Double(Number.zero - graphWindow.minY)!) * (self.frame.height) / CGFloat(Double(graphWindow.height)!) + self.frame.minY
            
            let pointA = CGPoint(x: self.frame.minX, y: convertedY)
            let pointB = CGPoint(x: self.frame.maxX, y: convertedY)
            
            let shape = SKShapeNode()
            let path = CGMutablePath()
            path.move(to: pointA)
            path.addLine(to: pointB)
            
            shape.zPosition = -1
            shape.path = path
            shape.strokeColor = mainAxesColor
            shape.lineWidth = mainAxesThickness
            addChild(shape)
            
        }
        
        //draw x minor axes
        let xTenToThe = try! Math.log(of: graphWindow.height)
        let xOrderOfMagnitude = try! Number(int: 10).exponentiate(xTenToThe.floor() - (xTenToThe >= Number.zero ? Number.one : Number(int: 3)))
        
        let a = (graphWindow.height * Number(int: 2)) / Number(int: 10) + Number(double: 0.5) * xOrderOfMagnitude
        let xAxisIncrement = try! (a - a % xOrderOfMagnitude) / Number(int: 2)
        
        var y = graphWindow.minY - (try! graphWindow.minY % xAxisIncrement)
        while try! y <= graphWindow.maxY {
            
            if try! y.absoluteValue()! > xAxisIncrement / Number(int: 2) {
                
                let convertedY = CGFloat(Double(y - graphWindow.minY)!) * (self.frame.height) / CGFloat(Double(graphWindow.height)!) + self.frame.minY
                
                let pointA = CGPoint(x: self.frame.minX, y: convertedY)
                let pointB = CGPoint(x: self.frame.maxX, y: convertedY)
                
                let shape = SKShapeNode()
                let path = CGMutablePath()
                path.move(to: pointA)
                path.addLine(to: pointB)
                
                shape.path = path
                shape.strokeColor = minorAxesColor
                shape.lineWidth = minorAxesThickness
                shape.zPosition = -1.5
                addChild(shape)
                
                if try! ((y % (xAxisIncrement * Number(int: 2))).absoluteValue()! - xAxisIncrement).absoluteValue()! > xAxisIncrement / Number(int: 2) {
                
                    let label = SKLabelNode(text: y.asInteger?.description ?? Double(y)!.description)
                    label.fontSize = labelFontSize
                    label.fontColor = labelFontColor
                    
                    var labelXPosition = CGFloat(Double(Number.zero - graphWindow.minX)!) * (self.frame.width) / CGFloat(Double(graphWindow.width)!) + self.frame.minX + label.frame.width / 2
                    labelXPosition = max(min(labelXPosition, self.frame.maxX - label.frame.width / 2), self.frame.minX + label.frame.width / 2)
                    
                    label.position = CGPoint(x: labelXPosition, y: convertedY)
                    
                    addChild(label)
                    
                }
                
            }
            
            y += xAxisIncrement
            
        }
        
        //draw y minor axes
        let yTenToThe = try! Math.log(of: graphWindow.width)
        let yOrderOfMagnitude = try! Number(int: 10).exponentiate(yTenToThe.floor() - (yTenToThe >= Number.zero ? Number.one : Number(int: 3)))
        
        let b = (graphWindow.width * Number(int: 2)) / Number(int: 10) + Number(double: 0.5) * yOrderOfMagnitude
        let yAxisIncrement = try! (b - b % yOrderOfMagnitude) / Number(int: 2)
        
        var x = graphWindow.minX - (try! graphWindow.minX % yAxisIncrement)
        while try! x <= graphWindow.maxX {
            
            if try! x.absoluteValue()! > yAxisIncrement / Number(int: 2) {
                
                let convertedX = CGFloat(Double(x - graphWindow.minX)!) * (self.frame.width) / CGFloat(Double(graphWindow.width)!) + self.frame.minX
                
                let pointA = CGPoint(x: convertedX, y: self.frame.minY)
                let pointB = CGPoint(x: convertedX, y: self.frame.maxY)
                
                let shape = SKShapeNode()
                let path = CGMutablePath()
                path.move(to: pointA)
                path.addLine(to: pointB)
                
                shape.path = path
                shape.strokeColor = minorAxesColor
                shape.lineWidth = minorAxesThickness
                shape.zPosition = -1.5
                addChild(shape)
                
                if try! ((x % (yAxisIncrement * Number(int: 2))).absoluteValue()! - yAxisIncrement).absoluteValue()! > yAxisIncrement / Number(int: 2) {
                    
                    let label = SKLabelNode(text: x.asInteger?.description ?? Double(x)!.description)
                    label.fontSize = labelFontSize
                    label.fontColor = labelFontColor
                    
                    var labelYPosition = CGFloat(Double(Number.zero - graphWindow.minY)!) * (self.frame.height) / CGFloat(Double(graphWindow.height)!) + self.frame.minY
                    labelYPosition = max(min(labelYPosition, self.frame.maxY), self.frame.minY)
                    
                    label.position = CGPoint(x: convertedX + label.frame.width / 2.0, y: labelYPosition)
                    
                    addChild(label)
                    
                }
                
            }
            
            x += yAxisIncrement
            
        }
        
        //draw graphs
        var realX = graphWindow.minX.copy() as! Number
        var lastChanges = [Number?](repeating: nil, count: functions.count)
        var lasts = [Number?](repeating: nil, count: functions.count)
        var arrayses = [[[CGPoint]]](repeating: [[CGPoint]](), count: functions.count)
        while (try? realX <= graphWindow.maxX) ?? false {
            
            var i = 0
            for (function, shouldDraw, _) in functions {
                
                if shouldDraw {
                    
                    if let realY = try? function.evaluateAt(arguments: [realX]).evaluate(), realY.isReal, try! graphWindow.minY <= realY && realY <= graphWindow.maxY {
                        
                        let convertedX = CGFloat(Double(realX - graphWindow.minX)!) * (self.frame.width) / CGFloat(Double(graphWindow.width)!) + self.frame.minX
                        let convertedY = CGFloat(Double(realY - graphWindow.minY)!) * (self.frame.height) / CGFloat(Double(graphWindow.height)!) + self.frame.minY
                        
                        if lastChanges[i] != nil {
                            
                            let change = realY - lasts[i]!
                            
                            if try! (lasts[i]! + lastChanges[i]! - realY).absoluteValue()! <= lastChanges[i]!.absoluteValue()! * Number(double: 3.0) {
                                
                                arrayses[i][arrayses[i].count - 1].append(CGPoint(x: convertedX, y: convertedY))
                                
                            } else {
                                
                                arrayses[i].append([CGPoint(x: convertedX, y: convertedY)])
                                
                            }
                            
                            lastChanges[i] = change
                            
                        } else {
                            
                            if let last = lasts[i] {
                                
                                arrayses[i][arrayses[i].count - 1].append(CGPoint(x: convertedX, y: convertedY))
                                
                                lastChanges[i] = realY - last
                                
                            } else {
                                
                                arrayses[i].append([CGPoint(x: convertedX, y: convertedY)])
                                
                            }
                            
                        }
                        
                        lasts[i] = realY
                        
                    } else { lastChanges[i] = nil; lasts[i] = nil }
                    
                    
                    
                }
            
                i += 1
                
            }
            
            realX += increment
            
        }
        
        var i = 0
        for arrays in arrayses {
            
            if functions[i].1 {
                
                for array in arrays {
                    
                    if array.count > 1 {
                        
                        let shape = SKShapeNode()
                        let path = CGMutablePath()
                        path.move(to: array[0])
                        
                        for point in array {
                            
                            path.addLine(to: point)
                            
                        }
                        
                        shape.path = path
                        shape.strokeColor = functions[i].2
                        shape.lineWidth = thickness
                        addChild(shape)
                        
                    }
                    
                }
                
            }
            
            i += 1
            
        }
        
        var z = CGFloat(2)
        for point in zeroPoints + intersectPoints + extremePoints {
            
            let convertedX = CGFloat(Double(point.x - graphWindow.minX)!) * (self.frame.width) / CGFloat(Double(graphWindow.width)!) + self.frame.minX
            let convertedY = CGFloat(Double(point.y - graphWindow.minY)!) * (self.frame.height) / CGFloat(Double(graphWindow.height)!) + self.frame.minY
            
            let node = SKShapeNode(circleOfRadius: thickness * 2.5)
            node.fillColor = pointColor
            node.strokeColor = pointColor
            node.position = CGPoint(x: convertedX, y: convertedY)
            
            let label = SKLabelNode(text: point.description)
            label.fontSize = labelFontSize * 1.2
            label.fontColor = labelFontColor
            label.position = CGPoint(x: convertedX, y: convertedY + label.frame.height)
            
            let averageLetterLength = label.frame.width / CGFloat(label.text!.count)
            let frame = CGRect(x: label.frame.minX - averageLetterLength, y: label.frame.minY - label.frame.height * 0.25, width: label.frame.width + 2 * averageLetterLength, height: label.frame.height * 1.5)
            let labelBackground = SKShapeNode(rect: frame, cornerRadius: 1.0)
            labelBackground.fillColor = backgroundColor
            labelBackground.strokeColor = labelFontColor
            
            node.zPosition = 1
            addChild(node)
            
            labelBackground.zPosition = z
            z += 1
            addChild(labelBackground)
            
            label.zPosition = z
            z += 1
            addChild(label)
            
        }
        
    }
    
    /**
 
    Finds a zero near the point if one exists and displays it on the graph
    
    - Parameter point: the nearby point
     
    */
    public func findZero(near point: Point) {
        
        var nearestLineDistance: Number?
        var nearestLineIndex: Int?
        var i = 0
        for (function, draw, _) in functions {
            
            if draw {
                
                let distance = try? (point.y - function.evaluateAt(arguments: [point.x]).evaluate()).absoluteValue()!
                if let distance = distance {
                    
                    if let nearestLineDistance2 = nearestLineDistance {
                        
                        if try! distance < nearestLineDistance2 {
                            
                            nearestLineIndex = i
                            nearestLineDistance = distance
                            
                        }
                        
                    } else {
                        
                        nearestLineIndex = i
                        nearestLineDistance = distance
                        
                    }
                    
                }
                
            }
            
            i += 1
            
        }
        
        if let index = nearestLineIndex {
            
            let function = functions[index].0
            
            let zero = try? Math.findZero(of: FunctionValue(function: function, arguments: [VariableValue(variable: function.variables[0])]), near: point.x, withVariable: function.variables[0])
            if let zero = zero, zero != nil {
                
                zeroPoints.append(Point(x: zero!, y: Number.zero))
                update()
                
            }
            
        }
        
    }
    
    /**
     
    Finds an intersection near the point if one exists and displays it on the graph
    
    - Parameter point: the nearby point
     
    */
    public func findIntersect(near point: Point) {
        
        var nearestLineDistance: Number?
        var nearestLineIndex: Int?
        var i = 0
        for (function, draw, _) in functions {
            
            if draw {
                
                let distance = try? (point.y - function.evaluateAt(arguments: [point.x]).evaluate()).absoluteValue()!
                if let distance = distance {
                    
                    if let nearestLineDistance2 = nearestLineDistance {
                        
                        if try! distance < nearestLineDistance2 {
                            
                            nearestLineIndex = i
                            nearestLineDistance = distance
                            
                        }
                        
                    } else {
                        
                        nearestLineIndex = i
                        nearestLineDistance = distance
                        
                    }
                    
                }
                
            }
            
            i += 1
            
        }
        
        if let index = nearestLineIndex {
            
            let functionValue1 = FunctionValue(function: functions[index].0, arguments: [VariableValue(variable: functions[index].0.variables[0])])
            
            var nearestIntersect: Point?
            i = 0
            for (function2, draw, _) in functions {
                
                if draw && i != index {
                    
                    let functionValue2 = FunctionValue(function: function2, arguments: [VariableValue(variable: function2.variables[0])])
                    
                    if let intersect = try? Math.findIntersect(of: functionValue1, and: functionValue2, near: point.x, withVariable: function2.variables[0]), intersect != nil {
                        
                        if try! nearestIntersect == nil || (nearestIntersect!.x - point.x).absoluteValue()! > (intersect! - point.x).absoluteValue()! {
                            
                            nearestIntersect = try! Point(x: intersect!, y: function2.evaluateAt(arguments: [intersect!]).evaluate())
                            
                        }
                        
                    }
                    
                }
                i += 1
                
            }
            
            if let intersectPoint = nearestIntersect { intersectPoints.append(intersectPoint); update() }
            
        }
        
    }
    
    /**
     
    Finds an extreme near the point if one exists and displays it on the graph
     
    - Parameter point: the nearby point
    - Parameter system: the system that the extreme is being found within
     
    */
    public func findExtreme(near point: Point, inSystem system: System) {
        
        var nearestLineDistance: Number?
        var nearestLineIndex: Int?
        var i = 0
        for (function, draw, _) in functions {
            
            if draw {
                
                let distance = try? (point.y - function.evaluateAt(arguments: [point.x]).evaluate()).absoluteValue()!
                if let distance = distance {
                    
                    if let nearestLineDistance2 = nearestLineDistance {
                        
                        if try! distance < nearestLineDistance2 {
                            
                            nearestLineIndex = i
                            nearestLineDistance = distance
                            
                        }
                        
                    } else {
                        
                        nearestLineIndex = i
                        nearestLineDistance = distance
                        
                    }
                    
                }
                
            }
            
            i += 1
            
        }
        
        if let index = nearestLineIndex {
            
            let function = functions[index].0
            
            let extreme = try? Math.findExtreme(of: FunctionValue(function: function, arguments: [VariableValue(variable: function.variables[0])]), near: point.x, withVariable: function.variables[0], inSystem: system)
            if let extreme = extreme, extreme != nil {
                
                try! extremePoints.append(Point(x: extreme!, y: function.evaluateAt(arguments: [extreme!]).evaluate()))
                update()
                
            }
            
        }
        
    }
    
    /**
 
    Clears points currently drawn on the screen
     
    */
    public func clearPoints() {
        
        intersectPoints = []
        zeroPoints = []
        extremePoints = []
        
    }
    
}
