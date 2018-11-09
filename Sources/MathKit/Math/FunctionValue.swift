//
//  FunctionValue.swift
//  MathKit
//
//  Created by Liam Stevenson on 12/16/16.
//  Copyright © 2016 Liam Stevenson. All rights reserved.
//

import Foundation

/// Represents a mathematical functioned used in a calculation.
/// Differs from `Function` in that it also stores arguments, so it is a `Value`
public class FunctionValue: Value {
    
    // MARK: Properties
    
    /// The function that `self` is of
    public let function: Function
    
    /// The values input to `self.function`
    public var arguments: [Value]
    
    internal override var isLinear: Bool {
        
        return function.value?.isLinear ?? false
        
    }
    
    // MARK: Initializers
    
    /**
     
    Initializes with given parameters
     
    - Parameter function: the function that `self` is of
    - Parameter arguments: the value input to `self.function`
     
    */
    public init(function: Function, arguments: [Value]) {
        
        self.function = function
        self.arguments = arguments
        
    }
    
    /**
     
    Initializes based on the given `String`
     
    - Parameter string: the `String` that `self` will be based on
    - Parameter system: the `System` that `self` is in
    - Precondition: `string` takes the form: "name(variable)"
     
    */
    public init(string: String, system: System) throws {
        
        let str = string.trimmingCharacters(in: CharacterSet.whitespaces)
        
        var args = [""]
        var name = ""
        var insetIndex = 0
        for c in str {
            
            var openParenthesis = false
            if "([{".contains(String(c)) { insetIndex += 1; openParenthesis = true }
            else if ")]}".contains(String(c)) { insetIndex -= 1 }
            else if insetIndex == 0 { name += String(c) }
            
            if insetIndex == 1 && c == "," { args.append("") }
            else if insetIndex != 0 && (!openParenthesis || insetIndex > 1) {
            
                args[args.count - 1] += String(c)
            
            }
            
        }
        
        self.arguments = []
        for arg in args {
            
            arguments.append(try Expression(string: arg, system: system))
            
        }
        
        self.function = system.function(withName: name, variables: [system.defaultVariable()])
        
    }
    
    // MARK: Functions
    
    public override func evaluate() throws -> Number {
        
        return try plugInValue().evaluate()
        
    }
    
    public override func getVariables() -> [Variable] {
        
        var arr1 = function.value?.getVariables() ?? []
        var arr2 = [Variable]()
        
        for a in arguments { arr2 += a.getVariables() }
        
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
    
    /**
 
    Plugs `value` into `function`
     
    - Returns: `function.evaluateAt(value: value)`
     
    */
    public func plugInValue() throws -> Value {
        
        return try function.evaluateAt(arguments: arguments)
        
    }
    
    public override func equals(_ value: Value) -> Bool {
        
        if !(value is FunctionValue) { return false }
        else { return super.equals(value) && (value as! FunctionValue).function.identifier == function.identifier && (value as! FunctionValue).arguments == arguments }
        
    }
    
    public override func copy() -> Value {
        
        var arguments = self.arguments
        for i in 0..<arguments.count { arguments[i] = arguments[i].copy() }
        
        let function = FunctionValue(function: self.function, arguments: arguments)
        
        return function
        
    }
    
    public override func plugIn(value: Value, forVariable variable: Variable) throws -> Value {
        
        var arguments = self.arguments
        for i in 0..<arguments.count {
            
            if !function.protectedVariables[i] {
                
                arguments[i] = try arguments[i].plugIn(value: value, forVariable: variable)
                
            }
        
        }
        
        return FunctionValue(function: function, arguments: arguments)
        
    }
    
    public override func derivative(inTermsOf variable: Variable, system: System) throws -> Value {
        
        guard function.variables.count == arguments.count else { throw CalculationError.missingFunctionArgument }
        
        switch function.name ?? "" {
            
        case System.sineName:
            let cos = Object(base: FunctionValue(function: system.cosine, arguments: arguments))
            
            var chains = [Object]()
            for arg in arguments { chains.append(try Object(base: arg.derivative(inTermsOf: variable, system: system))) }
            
            if system.angleMode == .degree {
                
                chains += [Object(base: VariableValue(variable: system.pi)), Object(base: Number(int: 180), exponent: Number(int: -1))]
                
            }
            
            return Expression(terms: [Term(objects: [cos] + chains)])
            
        case System.cosineName:
            let sin = Object(base: FunctionValue(function: system.sine, arguments: arguments))
            
            var chains = [Object]()
            for arg in arguments { chains.append(try Object(base: arg.derivative(inTermsOf: variable, system: system))) }
            
            if system.angleMode == .degree {
                
                chains += [Object(base: VariableValue(variable: system.pi)), Object(base: Number(int: 180), exponent: Number(int: -1))]
                
            }
            
            return Expression(terms: [Term(objects: [sin, Object(base: Number.negativeOne)] + chains)])
            
        case System.tangentName:
            let secSquared = Object(base: FunctionValue(function: system.secant, arguments: arguments), exponent: Number(int: 2))
            
            var chains = [Object]()
            for arg in arguments { chains.append(try Object(base: arg.derivative(inTermsOf: variable, system: system))) }
            
            if system.angleMode == .degree {
                
                chains += [Object(base: VariableValue(variable: system.pi)), Object(base: Number(int: 180), exponent: Number(int: -1))]
                
            }
            
            return Expression(terms: [Term(objects: [secSquared] + chains)])
            
        case System.secantName:
            let tan = Object(base: FunctionValue(function: system.tangent, arguments: arguments))
            let sec = Object(base: FunctionValue(function: system.secant, arguments: arguments))
            
            var chains = [Object]()
            for arg in arguments { chains.append(try Object(base: arg.derivative(inTermsOf: variable, system: system))) }
            
            if system.angleMode == .degree {
                
                chains += [Object(base: VariableValue(variable: system.pi)), Object(base: Number(int: 180), exponent: Number(int: -1))]
                
            }
            
            return Expression(terms: [Term(objects: [tan, sec] + chains)])
            
        case System.cosecantName:
            let cot = Object(base: FunctionValue(function: system.cotangent, arguments: arguments))
            let csc = Object(base: FunctionValue(function: system.cosecant, arguments: arguments))
            
            var chains = [Object]()
            for arg in arguments { chains.append(try Object(base: arg.derivative(inTermsOf: variable, system: system))) }
            
            if system.angleMode == .degree {
                
                chains += [Object(base: VariableValue(variable: system.pi)), Object(base: Number(int: 180), exponent: Number(int: -1))]
                
            }
            
            return Expression(terms: [Term(objects: [csc, cot, Object(base: Number.negativeOne)] + chains)])
            
        case System.cotangentName:
            let cscSquared = Object(base: FunctionValue(function: system.cosecant, arguments: arguments), exponent: Number(int: 2))
            
            var chains = [Object]()
            for arg in arguments { chains.append(try Object(base: arg.derivative(inTermsOf: variable, system: system))) }
            
            if system.angleMode == .degree {
                
                chains += [Object(base: VariableValue(variable: system.pi)), Object(base: Number(int: 180), exponent: Number(int: -1))]
            
            }
                
            return Expression(terms: [Term(objects: [cscSquared, Object(base: Number.negativeOne)] + chains)])
            
        case System.arcsineName:
            let radicand = Expression(terms: [Term(objects: [Object(base: Number.one)]), Term(objects: [Object(base: Number.negativeOne), Object(base: arguments[0], exponent: Number(int: 2))])])
            let radical = Object(base: radicand, exponent: Number.negativeOne / Number(int: 2))
            
            var chains = [Object]()
            for arg in arguments { chains.append(try Object(base: arg.derivative(inTermsOf: variable, system: system))) }
            
            if system.angleMode == .degree {
                
                chains += [Object(base: VariableValue(variable: system.pi), exponent: Number(int: -1)), Object(base: Number(int: 180))]
                
            }
            
            return Expression(terms: [Term(objects: [radical] + chains)])
            
        case System.arccosineName:
            let radicand = Expression(terms: [Term(objects: [Object(base: Number.one)]), Term(objects: [Object(base: Number.negativeOne), Object(base: arguments[0], exponent: Number(int: 2))])])
            let radical = Object(base: radicand, exponent: Number.negativeOne / Number(int: 2))
            
            var chains = [Object]()
            for arg in arguments { chains.append(try Object(base: arg.derivative(inTermsOf: variable, system: system))) }
            
            if system.angleMode == .degree {
                
                chains += [Object(base: VariableValue(variable: system.pi), exponent: Number(int: -1)), Object(base: Number(int: 180))]
                
            }
            
            return Expression(terms: [Term(objects: [radical, Object(base: Number.negativeOne)] + chains)])
            
        case System.arctangentName:
            let denominator = Expression(terms: [Term(objects: [Object(base: Number.one)]), Term(objects: [Object(base: arguments[0], exponent: Number(int: 2))])])
            let fraction = Object(base: denominator, exponent: Number.negativeOne)
            
            var chains = [Object]()
            for arg in arguments { chains.append(try Object(base: arg.derivative(inTermsOf: variable, system: system))) }
            
            if system.angleMode == .degree {
                
                chains += [Object(base: VariableValue(variable: system.pi), exponent: Number(int: -1)), Object(base: Number(int: 180))]
                
            }
            
            return Expression(terms: [Term(objects: [fraction] + chains)])
            
        case System.arcsecantName:
            let radicand = Expression(terms: [Term(objects: [Object(base: Number.negativeOne), Object(base: Number.one)]), Term(objects: [Object(base: arguments[0], exponent: Number(int: 2))])])
            let radical = Object(base: radicand, exponent: Number.negativeOne / Number(int: 2))
            let fraction = [radical, Object(base: FunctionValue(function: system.absoluteValue, arguments: arguments), exponent: Number.negativeOne)]
            
            var chains = [Object]()
            for arg in arguments { chains.append(try Object(base: arg.derivative(inTermsOf: variable, system: system))) }
            
            if system.angleMode == .degree {
                
                chains += [Object(base: VariableValue(variable: system.pi), exponent: Number(int: -1)), Object(base: Number(int: 180))]
                
            }
            
            return Expression(terms: [Term(objects: fraction + chains)])
            
        case System.arccosecantName:
            let radicand = Expression(terms: [Term(objects: [Object(base: Number.negativeOne), Object(base: Number.one)]), Term(objects: [Object(base: arguments[0], exponent: Number(int: 2))])])
            let radical = Object(base: radicand, exponent: Number.negativeOne / Number(int: 2))
            let fraction = [radical, Object(base: FunctionValue(function: system.absoluteValue, arguments: arguments), exponent: Number.negativeOne)]
            
            var chains = [Object]()
            for arg in arguments { chains.append(try Object(base: arg.derivative(inTermsOf: variable, system: system))) }
            
            if system.angleMode == .degree {
                
                chains += [Object(base: VariableValue(variable: system.pi), exponent: Number(int: -1)), Object(base: Number(int: 180))]
                
            }
            
            return Expression(terms: [Term(objects: fraction + [Object(base: Number.negativeOne)] + chains)])
            
        case System.arccotangentName:
            let denominator = Expression(terms: [Term(objects: [Object(base: Number.one)]), Term(objects: [Object(base: arguments[0], exponent: Number(int: 2))])])
            let fraction = Object(base: denominator, exponent: Number.negativeOne)
            
            var chains = [Object]()
            for arg in arguments { chains.append(try Object(base: arg.derivative(inTermsOf: variable, system: system))) }
            
            if system.angleMode == .degree {
                
                chains += [Object(base: VariableValue(variable: system.pi), exponent: Number(int: -1)), Object(base: Number(int: 180))]
                
            }
            
            return Expression(terms: [Term(objects: [fraction, Object(base: Number.negativeOne)] + chains)])
            
        case System.naturalLogName:
            var chains = [Object]()
            for arg in arguments { chains.append(try Object(base: arg.derivative(inTermsOf: variable, system: system))) }
            
            return Expression(terms: [Term(objects: [Object(base: arguments[0], exponent: Number.negativeOne)] + chains)])
            
        case System.logName:
            let baseChange = Object(base: FunctionValue(function: system.naturalLog, arguments: [arguments[1]]), exponent: Number.negativeOne)
            
            let chains = [try Object(base: arguments[0].derivative(inTermsOf: variable, system: system))]
            
            return Expression(terms: [Term(objects: [baseChange, Object(base: arguments[0], exponent: Number.negativeOne)] + chains)])
            
        case System.derivativeName:
            let firstDerivative = try Expression(terms: [Term(objects: [Object( base: self.plugInValue())])]).simplify()
            let secondDerivative = try Expression(terms: [Term(objects: [Object( base: firstDerivative.derivative(inTermsOf: variable, system: system))])]).simplify()
            
            return secondDerivative
            
        case System.numericalIntegralName:
            let function = arguments[0]
            let variableOfIntegration = arguments[1].getVariables()[0]
            let a = arguments[2]
            let b = arguments[3]
            
            let dadx = try a.derivative(inTermsOf: variable, system: system)
            let dbdx = try b.derivative(inTermsOf: variable, system: system)
            let fa = try function.plugIn(value: a, forVariable: variableOfIntegration)
            let fb = try function.plugIn(value: b, forVariable: variableOfIntegration)
            
            return Expression(terms: [Term(objects: [Object(base: fb), Object(base: dbdx)]), Term(objects: [Object(base: Number.negativeOne), Object(base: fa), Object(base: dadx)])])
            
        case System.numericalDerivativeName, System.absoluteValueName, System.factorialName, System.floorName:
            return FunctionValue(function: system.numericalDerivative, arguments: [self.copy(), VariableValue(variable: variable), VariableValue(variable: variable)])
            
        default:
            let pluggedIn = try self.plugInValue()
            return try pluggedIn.derivative(inTermsOf: variable, system: system)
            
        }
        
    }
    
    override public func factor(system: System? = nil) throws -> Term {
        
        if function.name == System.derivativeName || function.value != nil {
            
            return try plugInValue().factor(system: system)
            
        } else {
            
            let copy = self.copy() as! FunctionValue
            for i in 0..<copy.arguments.count {
                
                if !copy.function.protectedVariables[i] {
                    
                    let a = Expression(terms: [Term(objects: [Object(base: copy.arguments[i])])])
                    copy.arguments[i] = (try? a.simplify()) ?? a
                    
                }
                
            }
            
            let term = Term()
            term.objects.append(Object(base: copy))
            
            return term
            
        }
        
    }
    
    // MARK: CustomStringConvertible
    
    public override var description: String {
        
        var args = ""
        
        var first = true
        for a in arguments {
            
            if first { first = false }
            else { args += "," }
            
            args += a.description
            
        }
        
        return super.description + "\(function.name ?? function.identifier.description)(\(args))"
        
    }
    
}
