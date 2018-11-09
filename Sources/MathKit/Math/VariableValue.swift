//
//  Variable.swift
//  MathKit
//
//  Created by Liam Stevenson on 12/1/16.
//  Copyright © 2016 Liam Stevenson. All rights reserved.
//

import Foundation

/// Represents a mathematical variable used in a calculation.
/// Differs from `Variable` in that it represents an instance of a `Variable` in a `Value`
public class VariableValue: Value {
    
    // MARK: VariableValue values
    
    public let variable: Variable
    
    // MARK: Initializers
    
    public init(variable: Variable) {
        
        self.variable = variable
        
    }
    
    /**
     
    Initializes based on the given `String`
     
    - Parameter string: the `String` that `self` will be based on
    - Parameter system: the `System` that `self` is initialized within
     
    */
    public convenience init(string: String, system: System) throws {
        
        let variable = system.variable(withSymbol: string)
        
        self.init(variable: variable)
        
    }
    
    // MARK: Functions
    
    override public func factor(system: System? = nil) throws -> Term {
        
        var term = Term()
        
        if let value = variable.value, variable.shouldPlugInValue {
            
            term = try value.factor(system: system)
            
        } else { term.objects.append(Object(base: self.copy())) }
        
        return term
        
    }
    
    public override func equals(_ value: Value) -> Bool {
        
        if !(value is VariableValue) { return false }
        
        return super.equals(value) && self.variable.identifier == (value as! VariableValue).variable.identifier
        
    }
    
    public override func copy() -> VariableValue {
        
        let variable = VariableValue(variable: self.variable)
        
        return variable
        
    }
    
    public override func plugIn(value: Value, forVariable variable: Variable) throws -> Value {
        
        if variable.identifier == self.variable.identifier { return value }
        else if let variableValue = self.variable.value { return try variableValue.plugIn(value: value, forVariable: variable) }
        else { return self }
        
    }
    
    public override func getVariables() -> [Variable] {
        
        return [self.variable.copy()]
        
    }
    
    public override func evaluate() throws -> Number {
        
        if let value = variable.value { return try value.evaluate() }
        else { throw SolvingError.nonAlgebraic }
        
    }
    
    public override func derivative(inTermsOf variable: Variable, system: System) throws -> Value {
        
        if self.variable.identifier == variable.identifier {
            
            return Number.one
            
        } else if let value = self.variable.value, self.variable.shouldPlugInValue {
            
            return try value.derivative(inTermsOf: variable, system: system)
            
        } else {
            
            return FunctionValue(function: system.function(withName: "nderiv", variables: []), arguments: [self.copy(), VariableValue(variable: variable), VariableValue(variable: variable)])
            
        }
        
    }
    
    //MARK: CustomStringConvertible
    
    public override var description: String {
        
        return super.description + variable.description
        
    }
    
}
