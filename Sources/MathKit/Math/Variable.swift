//
//  Variable.swift
//  MathKit
//
//  Created by Liam Stevenson on 1/2/17.
//  Copyright © 2017 Liam Stevenson. All rights reserved.
//

import Foundation

/// Represents a mathematical variable and can optionally hold a value
public class Variable: Equatable, Hashable, CustomStringConvertible {
    
    // MARK: Variable values
    
    /// The optional symbol used to represent the variable
    public var symbol: String?
    
    /// The current value for `self`
    public var value: Value?
    
    /// If true, the value will be plugged in when simplifying and factoring
    public var shouldPlugInValue = false
    
    /// The identifier used to identify variables
    internal let identifier: Int
    
    /**
     
    Initializers with the given parameters
     
    - Parameter symbol: the optional symbol used to represent the variable
    - Parameter value: the optional value for the variable
    - Parameter identifier: the identifier used to identify variables
    - Parameter isConstant: if true, `self` has a constant value
     
    */
    public init(symbol: String? = nil, value: Value? = nil, identifier: Int) {
        
        self.symbol = symbol
        self.value = value
        self.identifier = identifier
        
    }
    
    // MARK: Functions
    
    /**
     
    Copies `self`
     
    - Returns: a copy of `self`
     
    */
    public func copy() -> Variable {
        
        return Variable(symbol: self.symbol, value: self.value?.copy() as? Number, identifier: self.identifier)
        
    }
    
    // MARK: Hashable
    
    public var hashValue: Int {
        
        return (identifier % 31) * ((symbol ?? "").hashValue % 31) % 31
        
    }
    
    //MARK: CustomStringConvertible
    
    public var description: String {
        
        return symbol ?? identifier.description
        
    }
    
}

// MARK: Equatable

public func ==(lhs: Variable, rhs: Variable) -> Bool {
    
    return lhs.identifier == rhs.identifier
    
}
