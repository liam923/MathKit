//
//  Object.swift
//  MathKit
//
//  Created by Liam Stevenson on 12/1/16.
//  Copyright © 2016 Liam Stevenson. All rights reserved.
//

import Foundation

/// Represents a part of a term and consists of a base to an exponent
public class Object: Value {
    
    // MARK: Object Values
    
    /// The base of the object
    public var base: Value
    
    /// The exponent of the object
    public var exponent: Value
    
    public override var isLinear: Bool {
        
        if exponent == Number.one {
            
            return base.isLinear
            
        } else { return base is Number }
        
    }
    
    // MARK: Initializers
    
    /**
 
    Initializes with given paremeters
     
    - Parameter base: the base of the object
    - Parameter exponent: the exponent of the object; defaults to 1
     
    */
    public init(base: Value, exponent: Value? = nil) {
        
        self.base = base
        self.exponent = exponent ?? Number.one
        
    }
    
    /**
     
    Initializes based on the given `String`
     
    - Parameter string: the `String` that `self` will be based on
    - Parameter system: the `System` that `self` is initialized within
     
    */
    public convenience init(string: String, system: System) throws {
        
        var base = ""
        var exponent = ""
        
        var bracketsIn = 0
        var i = 0
        for c in string {
            
            if bracketsIn == 0 && c == "^" {
                
                exponent = String(string[string.index(string.startIndex, offsetBy: i + 1)..<string.endIndex])
                break
                
            } else {
                
                base += String(c)
                if System.openBrackets.contains(c) {
                    
                    bracketsIn += 1
                    
                } else if System.closeBrackets.contains(c) {
                    
                    bracketsIn -= 1
                    
                }
                
            }
            
            i += 1
            
        }
        
        let baseArr = Array(base)
        let exponentArr = Array(exponent)
        
        if System.openBrackets.contains(baseArr.first!) && System.closeBrackets.contains(baseArr.last!) {
            
            base = String(base[base.index(after: base.startIndex)..<base.index(before: base.endIndex)])
            
        }
        if System.openBrackets.contains(exponentArr.first!) && System.closeBrackets.contains(exponentArr.last!) {
            
            exponent = String(exponent[exponent.index(after: exponent.startIndex)..<exponent.index(before: exponent.endIndex)])
            
        }
        
        if exponent == "" {
            
            self.init(base: try Expression(string: base, system: system))
            
        } else {
            
            self.init(base: try Expression(string: base, system: system), exponent: try Expression(string: exponent, system: system))
            
        }
        
    }
    
    // MARK: Functions
    
    public override func factor(system: System?) throws -> Term {
        
        let base = self.base
        
        let term = try base.factor(system: system)
            
        for o in term.objects {
            
            let e1 = try o.exponent.evaluate()
            let e2 = try self.exponent.evaluate()
            
            guard e1 * e2 != Number.zero || base != Number.zero else {
                throw CalculationError.zeroToTheZero
            }
                
            o.exponent = e1 * e2
            
            if let base = try? o.base.evaluate(), base == Number.zero {
                
                if let exponent = try? o.exponent.evaluate(), try exponent < Number.zero {
                    
                    throw CalculationError.divideByZero
                    
                }
                
            }
            
        }
        
        return term
        
    }
    
    /**
    
    Expands `self` if it can be expanded
     
    - Returns: expanded verison of `self`; nil if it cannot be expanded
     
    */
    internal func expand() throws -> Expression? {
        
        let exponent = try self.exponent.evaluate()
        guard exponent.isReal else {
            throw CalculationError.raisedToComplexNumber
        }
        
        if let base = base as? Expression, exponent.asInteger != nil, try! exponent > Number.zero {
            
            var product = Expression()
            product.terms = [Term(objects: [Object(base: Number.one)])]
            
            var i = 0
            while try! Number(int: i) < exponent {
                
                product = try product.multiply(byExpression: base)
                
                i += 1
                
            }
            
            return product
            
        } else { return nil }
        
    }
    
    public override func equals(_ value: Value) -> Bool {
        
        if !(value is Object) { return false }
        
        return super.equals(value) && self.base == (value as! Object).base && self.exponent == (value as! Object).exponent
        
    }
    
    public override func copy() -> Object {
        
        let object = Object(base: self.base.copy(), exponent: self.exponent.copy())
        
        return object
        
    }
    
    public override func evaluate() throws -> Number {
        
        let exponent = try self.exponent.evaluate()
        guard exponent.isReal else {
            throw CalculationError.raisedToComplexNumber
        }
        
        if exponent == Number.zero {
            
            guard base != Number.zero else {
                throw CalculationError.zeroToTheZero
            }
            return Number.one
            
        } else {
            
            let base = try self.base.evaluate()
            guard try! base != Number.zero || exponent > Number.zero else {
                throw CalculationError.divideByZero
            }
            return try (base.evaluate())^exponent
            
        }
        
    }
    
    public override func plugIn(value: Value, forVariable variable: Variable) throws -> Value {
        
        return Object(base: try base.plugIn(value: value, forVariable: variable),
                      exponent: try exponent.plugIn(value: value, forVariable: variable))
        
    }
    
    public override func getVariables() -> [Variable] {
        
        var arr1 = base.getVariables()
        let arr2 = exponent.getVariables()
        
        for v2 in arr2 {
            
            var match = false
            for v1 in arr1 {
                
                if v2 == v1 { match = false; break }
                
            }
            if !match { arr1.append(v2) }
            
        }
        
        var copied = [Variable]()
        for v in arr1 { copied.append(v.copy()) }
        
        return copied
        
    }
    
    public override func derivative(inTermsOf variable: Variable, system: System) throws -> Value {
        
        let chain = try base.derivative(inTermsOf: variable, system: system)
        let oldExp = try exponent.evaluate()
        let newExp = oldExp - Number.one
        
        let derive = Term(objects: [Object(base: oldExp), Object(base: base.copy(), exponent: newExp), Object(base: chain)])
        
        return derive
        
    }
    
    //MARK: CustomStringConvertible
    
    public override var description: String {
        
        if exponent == Number.one {
            
            return super.description + base.description
            
        } else {
            
            return super.description + "(\(base))^(\(exponent))"
            
        }
        
    }
    
}
