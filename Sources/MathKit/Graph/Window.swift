//
//  Window.swift
//  MathKit
//
//  Created by Liam Stevenson on 2/8/17.
//  Copyright © 2017 Liam Stevenson. All rights reserved.
//

import Foundation

/// Represents the drawing window of a graph
public struct Window {
    
    /// Minimum value of the x-axis
    public var minX = Number(int: -10)
    
    /// Maximum value of the x-axis
    public var maxX = Number(int: 10)
    
    /// Minimum value of the y-axis
    public var minY = Number(int: -10)
    
    /// Maximum value of the y-axis
    public var maxY = Number(int: 10)
    
    /// The width of the window
    public var width: Number {
        
        return maxX - minX
        
    }
    
    /// The height of the window
    public var height: Number {
        
        return maxY - minY
        
    }
    
    /**
 
    Initializes with default values
     
    */
    public init() {
    
        
    
    }
    
    /**
 
    Initializes with given values
     
    - Parameter minX: minimum value of the x-axis
    - Parameter maxX: maximum value of the x-axis
    - Parameter minY: minimum value of the y-axis
    - Parameter maxY: maximum value of the y-axis
     
    */
    public init(minX: Number, maxX: Number, minY: Number, maxY: Number) {
        
        self.minX = minX
        self.maxX = maxX
        self.minY = minY
        self.maxY = maxY
        
    }
    
    /**
     
    Initializes with given values
     
    - Parameter minX: minimum value of the x-axis
    - Parameter maxX: maximum value of the x-axis
    - Parameter minY: minimum value of the y-axis
    - Parameter maxY: maximum value of the y-axis
     
    */
    public init(minX: Int, maxX: Int, minY: Int, maxY: Int) {
        
        self.minX = Number(int: minX)
        self.maxX = Number(int: maxX)
        self.minY = Number(int: minY)
        self.maxY = Number(int: maxY)
        
    }
    
}
