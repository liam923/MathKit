//
//  Value.swift
//  MathKit
//
//  Created by Liam Stevenson on 12/1/16.
//  Copyright © 2016 Liam Stevenson. All rights reserved.
//

import Foundation

/// Represents an element that can be used as the value of something
public class Value: Equatable, CustomStringConvertible {
    
    // MARK: Value values
    
    /// True if `self` is linear
    internal var isLinear: Bool {
        
        return true
        
    }
    
    // MARK: Initializers
    
    /**
 
    Initializes a `Value` based on the given `String`
     
    - Parameter string: the `String` that the `Value` will be based on
    - Parameter system: the `System` that the `Value` is initialized within
     
    */
    static func getValueFrom(string: String, system: System) throws -> Value {
        
        let str = string.replacingOccurrences(of: " ", with: "")
        
        var allNumbers = true
        var containsAddition = false
        var bracketsIn = 0
        for c in str {
            
            if !System.numberCharacters.contains(String(c)) { allNumbers = false }
            else if System.openBrackets.contains(String(c)) { bracketsIn += 1 }
            else if System.closeBrackets.contains(String(c)) { bracketsIn -= 1 }
            else if bracketsIn == 0 && System.additiveCharacters.contains(String(c)) { containsAddition = true }
            
        }
        
        if containsAddition { return try Expression(string: str, system: system) }
        else if allNumbers { return try Number(string: str, system: system) }
        else { return try Term(string: str, system: system) }
        
    }
    
    // MARK: Functions
    
    /**
     
    Factors `self`
     
    - Parameter system: the system that `self` is being factored within; used for settings
    - Returns: a factored version of `self`
     
    */
    public func factor(system: System? = nil) throws -> Term {
        
        let term = Term()
        term.objects.append(Object(base: self.copy()))
        
        return term
        
    }
    
    /**
 
    Compares `self` with another value
     
    - Returns: `true` if `self` and the parameter passed are the same type and are equal
     
    */
    public func equals(_ value: Value) -> Bool {
        
        return true
        
    }
    
    /**
 
    Evaluates if `self` is numeric
     
    - Returns: the numeric evaluation of `self`
    - Throws: if the number cannot be computed
     
    */
    public func evaluate() throws -> Number {
        
        throw SolvingError.nonAlgebraic
        
    }
    
    /**
     
    Copies `self`
     
    - Returns: a copy of `self`
     
    */
    public func copy() -> Value {
        
        return Value()
        
    }
    
    /**
 
    Plugs in a `Value` for given `Variable`
     
    - Parameter value: `Value` being plugged in
    - Parameter forVariable: `Varialbe` being replaced
    - Returns: a `Value` with `value` plugged in
     
    */
    public func plugIn(value: Value, forVariable variable: Variable) throws -> Value {
        
        return self.copy()
        
    }
    
    /**
 
    Gets the `Variable`s `self` contains
     
    - Returns: the `Variable`s `self` contains
     
    */
    public func getVariables() -> [Variable] {
        
        return []
        
    }
    
    /**
 
    Finds the derivative of `self`
     
    - Parameter variable: the `Variable` that the derivative is in terms of
    - Parameter system: the `System` the derivative is being taken in
    - Returns: the derivative of `self`
     
    */
    public func derivative(inTermsOf variable: Variable, system: System) throws -> Value {
        
        return Number.zero
        
    }
    
    //MARK: CustomStringConvertible
    
    public var description: String {

        return ""
        
    }
    
}

// MARK: Equatable

public func ==(lhs: Value, rhs: Value) -> Bool {
    
    return lhs.equals(rhs)
    
}
