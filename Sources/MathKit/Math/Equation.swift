//
//  Equation.swift
//  MathKit
//
//  Created by Liam Stevenson on 12/1/16.
//  Copyright © 2016 Liam Stevenson. All rights reserved.
//

import Foundation

/// Represents a mathematical equation
public class Equation: CustomStringConvertible {
    
    // MARK: Equation Values
    
    /// Left hand side of the equation
    public var leftHandSide: Expression
    
    /// Right hand side of the equation
    public var rightHandSide: Expression
    
    // MARK: Initializers
    
    /**
 
    Initializes with given `Expression`s
     
    - Parameter leftHandSide: the left hand side of the equation
    - Parameter rightHandSide: the right hand side of the equation
     
    */
    public init(leftHandSide: Expression, rightHandSide: Expression) {
        
        self.leftHandSide = leftHandSide
        self.rightHandSide = rightHandSide
        
    }
    
    /**
 
    Initializes based on a given `String`
     
    - Parameter string: the `String` the initialization is based on
    - Parameter system: the `System` the initialization is happening within
     
    */
    public convenience init(string: String, system: System) throws {
        
        let components = string.components(separatedBy: "=")
        assert(components.count >= 2)
        
        let leftHandSide = try Expression(string: components[0], system: system)
        let rightHandSide = try Expression(string: components[1], system: system)
        
        self.init(leftHandSide: leftHandSide, rightHandSide: rightHandSide)
        
    }
    
    // MARK: Functions
    
    /**
     
    Copies `self`
     
    - Returns: a copy of `self`
     
    */
    public func copy() -> Equation {
        
        let equation = Equation(leftHandSide: self.leftHandSide.copy(), rightHandSide: self.rightHandSide.copy())
        
        return equation
        
    }
    
    /**
 
    Solves `self` for a given `Variable`
     
    - Parameter variable: the `Variable` being solved for
    - Returns: array of found `Value`s of `variable`
     
    */
    public func solve(forVariable variable: Variable) throws -> [Value] {
        
        let expression = try rightHandSide.subtract(expression: leftHandSide).combineLikeTerms().simplify()
        let factors = try expression.factor().objects
        
        var outOfDomain = [Value]()
        var solutions = [Value]()
        
        for factor in factors {
            
            let exponent = try factor.exponent.evaluate()
            guard exponent.isReal else {
                throw CalculationError.raisedToComplexNumber
            }
            
            if try! exponent > Number.zero {
                
                if let base = factor.base as? VariableValue, base.variable.identifier == variable.identifier {
                    
                    solutions.append(Number(int: 0))
                    
                } else if let base = factor.base as? FunctionValue {
                    
                    solutions.append(base.function.value ?? base)
                    
                } else if let base = factor.base as? Expression {
                    
                    solutions += try base.solveFactor(forVariable: variable)

                }
                
            } else if try! exponent < Number.zero {
                
                outOfDomain.append(factor.base)
                
            }
            
        }
        
        //take out extranious solutions
        var i = solutions.count - 1
        while i >= 0 {
            
            for out in outOfDomain {
                
                do {
                    
                    let val = try out.plugIn(value: solutions[i], forVariable: variable).evaluate()
                    if val == Number.zero { solutions.remove(at: i) }
                    
                } catch { solutions.remove(at: i) }
                
            }
            
            i -= 1
            
        }
        
        return solutions
        
    }
    
    /**
 
    Plugs in a value for a variable
     
    - Parameter value: the value being plugged in
    - Parameter variable: the variable being plugged in for
    - Returns: `self` with `value` plugged in for `variable`
     
    */
    public func plugIn(value: Value, forVariable variable: Variable) throws -> Equation {
        
        let lhs = try leftHandSide.plugIn(value: value, forVariable: variable) as? Expression
        let rhs = try rightHandSide.plugIn(value: value, forVariable: variable) as? Expression
        
        return Equation(leftHandSide: lhs ?? leftHandSide, rightHandSide: rhs ?? rightHandSide)
        
    }
    
    /**
     
    Gets the `Variable`s `self` contains
     
    - Returns: the `Variable`s `self` contains
     
    */
    public func getVariables() -> [Variable] {
        
        let expression = try? leftHandSide.add(expression: rightHandSide)
        return expression?.getVariables() ?? []
        
    }
    
    // MARK: CustomStringConvertible
    
    public var description: String {
        
        return "\(leftHandSide) = \(rightHandSide)"
        
    }
    
}
