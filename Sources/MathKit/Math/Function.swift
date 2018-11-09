//
//  Function.swift
//  MathKit
//
//  Created by Liam Stevenson on 12/1/16.
//  Copyright © 2016 Liam Stevenson. All rights reserved.
//

import Foundation

/// Represents a mathematical function
public class Function {
    
    // MARK: Function values
    
    /// The name of the function
    public var name: String?
    
    /// The independent variables of the function
    public var variables: [Variable]
    
    /// If true, the corresponding variable is not plugged in for; used for passing functions
    internal let protectedVariables: [Bool]
    
    /// The value that the function is equal to
    public var value: Value?
    
    /// The identifier for this function
    internal let identifier: Int
    
    /// The `AngleMode` to be used
    internal var angleMode = AngleMode.radian
    
    /// The `System` `self` is in
    internal weak var system: System?
    
    // MARK: Initializers
    
    /**
 
    Initializes with given parameters
     
    - Parameter name: name of the function
    - Parameter variable: the independent variable of the function
    - Parameter expression: the expression that the function is equal to
     
    */
    internal init(name: String?, variables: [Variable], value: Value?, identifier: Int, protectedVariables: [Bool]? = nil, system: System?) {
        
        self.name = name
        self.variables = variables
        self.value = value
        self.identifier = identifier
        self.system = system
        
        if let protectedVariables = protectedVariables {
            
            self.protectedVariables = protectedVariables
            
        } else {
            
            var arr = [Bool]()
            for _ in variables { arr.append(false) }
            self.protectedVariables = arr
            
        }
        
    }
    
    // MARK: Functions
    
    /**
     
     Replaces a function call with the function itself and its arguments plugged in
     
     - Parameter arguments: the values to plug into a function
     - Returns: the `Value` that the function represents with the arguments plugged in
     
     */
    public func evaluateAt(arguments: [Value]) throws -> Value {
        
        switch self.name ?? "" {
            
        case System.sineName:
            guard variables.count == arguments.count else { throw CalculationError.missingFunctionArgument }
            
            return try Math.sine(of: try arguments[0].evaluate(), angleMode: angleMode)
            
        case System.cosineName:
            guard variables.count == arguments.count else { throw CalculationError.missingFunctionArgument }
            return try Math.cosine(of: try arguments[0].evaluate(), angleMode: angleMode)
            
        case System.tangentName:
            guard variables.count == arguments.count else { throw CalculationError.missingFunctionArgument }
            return try Math.tangent(of: try arguments[0].evaluate(), angleMode: angleMode)
            
        case System.secantName:
            guard variables.count == arguments.count else { throw CalculationError.missingFunctionArgument }
            return try Math.secant(of: try arguments[0].evaluate(), angleMode: angleMode)
            
        case System.cosecantName:
            guard variables.count == arguments.count else { throw CalculationError.missingFunctionArgument }
            return try Math.cosecant(of: try arguments[0].evaluate(), angleMode: angleMode)
            
        case System.cotangentName:
            guard variables.count == arguments.count else { throw CalculationError.missingFunctionArgument }
            return try Math.cotangent(of: try arguments[0].evaluate(), angleMode: angleMode)
            
        case System.arcsineName:
            guard variables.count == arguments.count else { throw CalculationError.missingFunctionArgument }
            return try Math.arcSine(of: try arguments[0].evaluate(), angleMode: angleMode)
            
        case System.arccosineName:
            guard variables.count == arguments.count else { throw CalculationError.missingFunctionArgument }
            return try Math.arcCosine(of: try arguments[0].evaluate(), angleMode: angleMode)
            
        case System.arctangentName:
            guard variables.count == arguments.count else { throw CalculationError.missingFunctionArgument }
            return try Math.arcTangent(of: try arguments[0].evaluate(), angleMode: angleMode)
            
        case System.arcsecantName:
            guard variables.count == arguments.count else { throw CalculationError.missingFunctionArgument }
            return try Math.arcSecant(of: try arguments[0].evaluate(), angleMode: angleMode)
            
        case System.arccosecantName:
            guard variables.count == arguments.count else { throw CalculationError.missingFunctionArgument }
            return try Math.arcCosecant(of: try arguments[0].evaluate(), angleMode: angleMode)
            
        case System.arccotangentName:
            guard variables.count == arguments.count else { throw CalculationError.missingFunctionArgument }
            return try Math.arcCotangent(of: try arguments[0].evaluate(), angleMode: angleMode)
            
        case System.naturalLogName:
            guard variables.count == arguments.count else { throw CalculationError.missingFunctionArgument }
            return try Math.log(base: Number.e, of: arguments[0].evaluate())
            
        case System.logName:
            guard variables.count == arguments.count else { throw CalculationError.missingFunctionArgument }
            return try Math.log(base: arguments[1].evaluate(), of: arguments[0].evaluate())
            
        case System.derivativeName:
            guard variables.count == arguments.count else { throw CalculationError.missingFunctionArgument }
            let vars = arguments[1].getVariables()
            guard vars.count == 1 else { throw CalculationError.domainError }
            let derivative = try arguments[0].derivative(inTermsOf: vars[0], system: system!)
            return try derivative.plugIn(value: arguments[2], forVariable: vars[0])
            
        case System.numericalDerivativeName:
            guard variables.count == arguments.count else { throw CalculationError.missingFunctionArgument }
            let vars = arguments[1].getVariables()
            guard vars.count == 1 else { throw CalculationError.domainError }
            return try Math.numericalDerivative(of: arguments[0], inTermsOf: vars[0], at: arguments[2].evaluate())
            
        case System.numericalIntegralName:
            guard variables.count == arguments.count else { throw CalculationError.missingFunctionArgument }
            let vars = arguments[1].getVariables()
            guard vars.count == 1 else { throw CalculationError.domainError }
            return try Math.integral(from: arguments[2].evaluate(), to: arguments[3].evaluate(), of: arguments[0], d: vars[0])
            
        case System.absoluteValueName:
            guard variables.count == arguments.count else { throw CalculationError.missingFunctionArgument }
            if let abs = (try? arguments[0].evaluate().absoluteValue()), abs != nil { return abs! }
            else { throw CalculationError.domainError }
            
        case System.factorialName:
            guard variables.count == arguments.count else { throw CalculationError.missingFunctionArgument }
            if let num = try? arguments[0].evaluate(), num.isReal {
                
                let fact = tgamma(Double(num)! + 1.0)
                guard !fact.isNaN && !fact.isInfinite else { throw CalculationError.domainError }
                
                return Number(double: fact)
                
            }
            else { throw CalculationError.domainError }
            
        case System.floorName:
            guard variables.count == arguments.count else { throw CalculationError.missingFunctionArgument }
            if let num = try? arguments[0].evaluate(), num.isReal {
                
                return Number(double: floor(Double(num)!))
                
            }
            else { throw CalculationError.domainError }
            
        default:
            break
            
        }
        
        if var value = self.value?.copy() {
            
            guard variables.count == arguments.count else {
                throw CalculationError.missingFunctionArgument
            }
            
            for i in 0..<arguments.count {
                
                value = try value.plugIn(value: arguments[i], forVariable: variables[i])
                
            }
            return value
            
        } else { throw CalculationError.missingFunctionDefinition }
        
    }
    
    /**
     
    Copies `self`
     
    - Returns: a copy of `self`
     
    */
    public func copy() -> Function {
        
        var variables = self.variables
        for i in 0..<variables.count { variables[i] = variables[i].copy() }
        
        return Function(name: name, variables: variables, value: value?.copy(), identifier: identifier, system: system)
        
    }
    
}
