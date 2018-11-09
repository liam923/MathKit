//
//  Point.swift
//  MathKit
//
//  Created by Liam Stevenson on 2/8/17.
//  Copyright © 2017 Liam Stevenson. All rights reserved.
//

import Foundation

/// Represents a point on a graph
public struct Point: CustomStringConvertible {
    
    /// Represents the x-coordinate
    public let x: Number
    
    /// Represents the y-coordinate
    public let y: Number
    
    /**
 
    Initializes with the given values
     
    - Parameter x: the x coordinate
    - Parameter y: the y coordinate
    
    */
    public init(x: Number, y: Number) {
        
        self.x = x
        self.y = y
        
    }
    
    // MARK: CustomStringConvertible
    
    public var description: String {
        
        return "(\(x), \(y))"
        
    }
    
}
