//
//  Math.swift
//  MathKit
//
//  Created by Liam Stevenson on 2/16/17.
//  Copyright © 2017 Liam Stevenson. All rights reserved.
//

import Foundation

/// Does calculations
public class Math {
    
    /**
     
    Calculates logs
     
    - Parameter base: the base of the log
    - Parameter of: the antilogarithm
    - Returns: log base `base` of `of`
    
    */
    public static func log(base: Number = Number(int: 10), of: Number) throws -> Number {
        
        guard (try? of > Number.zero && base > Number.zero) ?? false else { throw CalculationError.domainError }
        
        let new = log2(of.realNum) / log2(base.realNum)
        
        return Number(double: new)
        
    }
    
    /**
     
    Get the smaller of two `Number`s
     
     - Parameter a: one of the numbers being compared
     - Parameter b: one of the numbers being compared
     - Returns: the smaller of the two arguments
     
    */
    public static func min(_ a: Number, _ b: Number) throws -> Number? {
        
        return try a < b ? a : b
        
    }
    
    // MARK: Trigonometry
    
    /**
 
    Calculates the sine of an angle
     
    - Parameter num: the angle measurement
    - Parameter angleMode: determines if radians or degrees
    - Returns: the sine of the angle
     
    */
    public static func sine(of num: Number, angleMode: AngleMode) throws -> Number {
        
        guard num.isReal else { throw CalculationError.domainError }
        
        if angleMode == .degree {
            
            return Number(double: sin(Double(Number(double: num.realNum) * Number.pi / Number(int: 180))!))
            
        } else {
            
            return Number(double: sin(num.realNum))
            
        }
        
    }
    
    /**
     
    Calculates the cosine of an angle
     
    - Parameter num: the angle measurement
    - Parameter angleMode: determines if radians or degrees
    - Returns: the cosine of the angle
     
    */
    public static func cosine(of num: Number, angleMode: AngleMode) throws -> Number {
        
        guard num.isReal else { throw CalculationError.domainError }
        
        if angleMode == .degree {
            
            return Number(double: cos(Double(Number(double: num.realNum) * Number.pi / Number(int: 180))!))
            
        } else {
            
            return Number(double: cos(num.realNum))
            
        }
        
    }
    
    /**
     
    Calculates the tangent of an angle
     
    - Parameter num: the angle measurement
    - Parameter angleMode: determines if radians or degrees
    - Returns: the tangent of the angle
     
    */
    public static func tangent(of num: Number, angleMode: AngleMode) throws -> Number {
        
        guard num.isReal else { throw CalculationError.domainError }
        
        if angleMode == .degree {
            
            return Number(double: tan(Double(Number(double: num.realNum) * Number.pi / Number(int: 180))!))
            
        } else {
            
            return Number(double: tan(num.realNum))
            
        }
        
    }
    
    /**
     
    Calculates the secant of an angle
     
    - Parameter num: the angle measurement
    - Parameter angleMode: determines if radians or degrees
    - Returns: the secant of the angle
     
    */
    public static func secant(of num: Number, angleMode: AngleMode) throws -> Number {
        
        return try Number.one / cosine(of: num, angleMode: angleMode)
        
    }
    
    /**
     
    Calculates the cosecant of an angle
     
    - Parameter num: the angle measurement
    - Parameter angleMode: determines if radians or degrees
    - Returns: the cosecant of the angle
     
    */
    public static func cosecant(of num: Number, angleMode: AngleMode) throws -> Number {
        
        return try Number.one / sine(of: num, angleMode: angleMode)
        
    }
    
    /**
     
    Calculates the cotangent of an angle
     
    - Parameter num: the angle measurement
    - Parameter angleMode: determines if radians or degrees
    - Returns: the cotangent of the angle
     
    */
    public static func cotangent(of num: Number, angleMode: AngleMode) throws -> Number {
        
        return try Number.one / tangent(of: num, angleMode: angleMode)
        
    }
    
    /**
     
    Calculates the inverse sine
     
    - Parameter num: the arguments of the function
    - Parameter angleMode: determines if radians or degrees
    - Returns: the inverse sine
     
    */
    public static func arcSine(of num: Number, angleMode: AngleMode) throws -> Number {
        
        guard num.isReal, (try? num.absoluteValue()! <= Number.one) ?? true else { throw CalculationError.domainError }
        
        let angle = asin(num.realNum)
        if angleMode == .degree {
            
            return Number(double: angle) * Number(int: 180) / Number.pi
            
        } else {
            
            return Number(double: angle)
            
        }
        
    }
    
    /**
     
    Calculates the inverse cosine
     
    - Parameter num: the arguments of the function
    - Parameter angleMode: determines if radians or degrees
    - Returns: the inverse cosine
     
    */
    public static func arcCosine(of num: Number, angleMode: AngleMode) throws -> Number {
        
        guard num.isReal, (try? num.absoluteValue()! <= Number.one) ?? true else { throw CalculationError.domainError }
        
        let angle = acos(num.realNum)
        if angleMode == .degree {
            
            return Number(double: angle) * Number(int: 180) / Number.pi
            
        } else {
            
            return Number(double: angle)
            
        }
        
    }
    
    /**
     
    Calculates the inverse tangent
     
    - Parameter num: the arguments of the function
    - Parameter angleMode: determines if radians or degrees
    - Returns: the inverse tangent
     
    */
    public static func arcTangent(of num: Number, angleMode: AngleMode) throws -> Number {
        
        let angle = atan(num.realNum)
        if angleMode == .degree {
            
            return Number(double: angle) * Number(int: 180) / Number.pi
            
        } else {
            
            return Number(double: angle)
            
        }
        
    }
    
    /**
     
    Calculates the inverse secant
     
    - Parameter num: the arguments of the function
    - Parameter angleMode: determines if radians or degrees
    - Returns: the inverse secant
    
    */
    public static func arcSecant(of num: Number, angleMode: AngleMode) throws -> Number {
        
        return try arcCosine(of: Number.one / num, angleMode: angleMode)
        
    }
    
    /**
     
    Calculates the inverse cosecant
     
    - Parameter num: the arguments of the function
    - Parameter angleMode: determines if radians or degrees
    - Returns: the inverse cosecant
     
    */
    public static func arcCosecant(of num: Number, angleMode: AngleMode) throws -> Number {
        
        return try arcSine(of: Number.one / num, angleMode: angleMode)
        
    }
    
    /**
     
    Calculates the inverse cotangent
     
    - Parameter num: the arguments of the function
    - Parameter angleMode: determines if radians or degrees
    - Returns: the inverse cotangent
     
    */
    public static func arcCotangent(of num: Number, angleMode: AngleMode) throws -> Number {
        
        return try arcTangent(of: Number.one / num, angleMode: angleMode)
        
    }
    
    // MARK: Calculus
    
    /**
 
    Estimates the derivative of a value
     
    - Parameter function: the value whose derivative is being found
    - Parameter variable: the variable that the derivative is in terms of
    - Parameter location: the value at which the derivative is being evaluated
    - Returns: d/dx(`function`) at `location`
     
    */
    public static func numericalDerivative(of function: Value, inTermsOf variable: Variable, at location: Number) throws -> Number {
        
        let h = Number(double: 0.0000000148996644)
        let locPlusH = location + h
        let locMinusH = location - h
        let dx = locPlusH - locMinusH
        
        return try (function.plugIn(value: locPlusH, forVariable: variable).evaluate() - function.plugIn(value: locMinusH, forVariable: variable).evaluate()) / dx
        
    }
    
    /**
 
    Estimates integrals using adaptive Simpson's method
     
    - Parameter a: the lower-bound of integration
    - Parameter b: the upper-bound of integration
    - Parameter function: the integrand
    - Parameter dummyVariable: the variable of integration
     
    */
    public static func integral(from a: Number, to b: Number, of function: Value, d dummyVariable: Variable) throws -> Number {
        
        let accuracy = Number(double: 0.0000000000001)
        let maxRecursionDepth = 10
        
        func recursiveSimpsons(a: Number, b: Number, epsilon: Number, S: Number, fa: Number, fb: Number, fc: Number, recursionIndex: Int) throws -> Number {

            let h = b - a
            let c = (a + b) / Number(int: 2)
            let d = (a + c) / Number(int: 2)
            let e = (b + c) / Number(int: 2)
            let fd = try function.plugIn(value: d, forVariable: dummyVariable).evaluate()
            let fe = try function.plugIn(value: e, forVariable: dummyVariable).evaluate()
            let Sleft = h * (fa + Number(int: 4) * fd + fc) / Number(int: 12)
            let Sright = h * (fc + Number(int: 4) * fe + fb) / Number(int: 12)
            let S2 = Sleft + Sright
            
            if try recursionIndex <= 0 || (S2 - S).absoluteValue() ?? Number.zero <= Number(int: 15) * epsilon {
                
                return S2 + (S2 - S) / Number(int: 15)
                
            } else {
                
                let newE = epsilon / Number(int: 2)
                return try recursiveSimpsons(a: a, b: c, epsilon: newE, S: Sleft, fa: fa, fb: fc, fc: fd, recursionIndex: recursionIndex - 1) + recursiveSimpsons(a: c, b: b, epsilon: newE, S: Sright, fa: fc, fb: fb, fc: fe, recursionIndex: recursionIndex - 1)
                
            }
            
        }
        
        let c = (b + a) / Number(int: 2)
        let fa = try function.plugIn(value: a, forVariable: dummyVariable).evaluate()
        let fb = try function.plugIn(value: b, forVariable: dummyVariable).evaluate()
        let fc = try function.plugIn(value: c, forVariable: dummyVariable).evaluate()
        let S = (b - a) * (fa + Number(int: 4) * fc + fb) / Number(int: 6)
        
        return try recursiveSimpsons(a: a, b: b, epsilon: accuracy, S: S, fa: fa, fb: fb, fc: fc, recursionIndex: maxRecursionDepth)
        
    }
    
    // MARK: Points of Interest
    
    /**
     
    Finds a zero near a given value using Newton's method
     
    - Parameter function: the function whose zero is being found
    - Parameter a: the starting point
    - Parameter variable: the variable being plugged in for
    - Returns: the zero; nil if none is found
     
    */
    public static func findZero(of function: Value, near a: Number, withVariable variable: Variable) throws -> Number? {
        
        let simplified = try? Expression(terms: [Term(objects: [Object(base: function)])]).simplify().evaluate()
        if simplified != nil { return nil }
        
        return try findZeroRecursive(of: function, near: a, withVariable: variable)
        
    }
    
    private static func findZeroRecursive(of function: Value, near a: Number, withVariable variable: Variable) throws -> Number? {
        
        let accuracy = Number(double: 0.00000000001)
        
        let m = try Math.numericalDerivative(of: function, inTermsOf: variable, at: a)
        let fa = try function.plugIn(value: a, forVariable: variable).evaluate()
        
        let newX = a - (fa / m)
        let fNewX = try function.plugIn(value: newX, forVariable: variable).evaluate()
        
        if try fNewX.absoluteValue()! <= accuracy { return newX }
        else if try m.absoluteValue()! < accuracy { return nil }
        else { return try findZero(of: function, near: newX, withVariable: variable) }
        
    }
    
    /**
     
    Finds a zero near a given value using Newton's method
     
    - Parameter function1: the first function whose intersection is being found
    - Parameter function2: the first function whose intersection is being found
    - Parameter a: the starting point
    - Parameter variable: the variable being plugged in for
    - Returns: the zero; nil if none is found
     
    */
    public static func findIntersect(of function1: Value, and function2: Value, near a: Number, withVariable variable: Variable) throws -> Number? {
        
        let function = Expression(terms: [Term(objects: [Object(base: function1)]), Term(objects: [Object(base: Number.negativeOne), Object(base: function2)])])
        
        return try findZero(of: function, near: a, withVariable: variable)
        
    }
    
    /**
 
    Finds a relitive minimum or maximum of a function near a given value
     
    - Parameter function: the function whose max or min is being found
    - Parameter a: the starting point
    - Parameter variable: the variable being plugged in for
    - Parameter system: the system the max or min is being found in
    - Returns: the x coordinate of the max or min; nil if none is found
     
    */
    public static func findExtreme(of function: Value, near a: Number, withVariable variable: Variable, inSystem system: System) throws -> Number? {
        
        let derivative = try function.derivative(inTermsOf: variable, system: system)
        let dZero = try? Math.findZero(of: derivative, near: a, withVariable: variable)
        if let dZero = dZero, dZero != nil {
            
            if (try? (derivative.plugIn(value: dZero! + Number(double: 0.001), forVariable: variable).evaluate() > Number.zero) != (derivative.plugIn(value: dZero! - Number(double: 0.001), forVariable: variable).evaluate() > Number.zero)) ?? false {
                
                return dZero!
                
            } else { return nil }
            
        } else { return nil }
        
    }
    
}
