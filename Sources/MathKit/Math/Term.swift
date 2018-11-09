//
//  Term.swift
//  MathKit
//
//  Created by Liam Stevenson on 12/1/16.
//  Copyright © 2016 Liam Stevenson. All rights reserved.
//

import Foundation

/// Represents a mathematical term
public class Term: Value {
    
    // MARK: Term Values
    
    /// List of the objects multiplied together to form the term
    public var objects = [Object]()
    
    /// Is `self` a perfect square?
    internal var isSquare: Bool {
        
        for o in objects {
            
            if let exponent = try? o.exponent.evaluate() {
                
                if (try? exponent % Number(int: 2) != Number.zero) ?? true { return false }
                
            } else { return false }
            
        }
        
        return true
        
    }
    
    /// Is `self` a perfect cube?
    internal var isCube: Bool {
        
        for o in objects {
            
            if let exponent = try? o.exponent.evaluate() {
                
                if (try? exponent % Number(int: 3) != Number.zero) ?? true { return false }
                
            } else { return false }
            
        }
        
        return true
        
    }
    
    internal override var isLinear: Bool {
        
        var variableCounts = [Int : Int]()
        for o in objects {
            
            if !o.isLinear { return false }
            else {
                
                for v in o.getVariables() {
                    
                    variableCounts[v.identifier] = variableCounts[v.identifier] ?? 0 + 1
                    if variableCounts[v.identifier]! > 1 { return false }
                    
                }
                
            }
            
        }
        
        return true
        
    }
    
    // MARK: Initializers
    
    /**
     
    Initializes based on the given array of object
     
    - Parameter objects: the array that `self` will be based off of
     
    */
    public convenience init(objects: [Object]) {
        
        self.init()
        self.objects = objects
        
    }
    
    /**
     
    Initializes based on the given `String`
     
    - Parameter string: the `String` that `self` will be based on
    - Parameter system: the `System` that `self` is initialized within
     
    */
    public convenience init(string: String, system: System) throws {
        
        self.init()
        
        var str = string.replacingOccurrences(of: " ", with: "")
        
        var sign = Number.one
        guard str.count > 0 else { throw SolvingError.syntax }
        var firstCharacter = String(str[..<str.index(after: str.startIndex)])
        while System.additiveCharacters.contains(firstCharacter) {
            
            switch firstCharacter {
                
            case "-":
                sign *= Number.negativeOne
                
            default:
                break
                
            }
            
            str = String(str[str.index(after: str.startIndex)...])
            
            guard str.count > 0 else { throw SolvingError.syntax }
            firstCharacter = String(str[..<str.index(after: str.startIndex)])
            
        }
        
        if sign != Number.one { objects.append(Object(base: sign)) }
        
        var currentType = ""
        var currentItem = ""
        var base: String?
        var baseType: String?
        var bracketsIn = 0
        var dividing = false
        
        let endItem = {
            
            if currentItem != "" {
                
                let exponent: String?
                let exponentType: String?
                
                if base != nil {
                    
                    exponent = currentItem
                    exponentType = currentType
                    
                    currentItem = ""
                    currentType = ""
                    
                } else {
                    
                    base = currentItem
                    baseType = currentType
                    
                    currentItem = ""
                    currentType = ""
                    
                    exponent = nil
                    exponentType = nil
                    
                }
                
                var baseValue: Value
                switch baseType! {
                    
                case "number":
                    baseValue = try Number(string: base!, system: system)
                    
                case "expression":
                    guard base!.count > 2 else { throw SolvingError.syntax }
                    let trimmed = String(base![base!.index(after: base!.startIndex)..<base!.index(before: base!.endIndex)])
                    baseValue = try Value.getValueFrom(string: trimmed, system: system)
                    
                case "variable":
                    baseValue = Term()
                    for c in base! {
                        
                        (baseValue as? Term)?.objects.append(Object(base: try VariableValue(string: String(c), system: system)))
                        
                    }
                    if (baseValue as? Term)?.objects.count == 1 {
                        
                        baseValue = (baseValue as! Term).objects[0].base
                        
                    }
                    
                case "function":
                    baseValue = try FunctionValue(string: base!, system: system)
                    
                default:
                    baseValue = try Value.getValueFrom(string: base!, system: system)
                    
                }
                
                var exponentValue: Value?
                if let exponentType = exponentType {
                    
                    switch exponentType {
                        
                    case "number":
                        exponentValue = try Number(string: exponent!, system: system)
                        
                    case "expression":
                        guard exponent!.count > 2 else { throw SolvingError.syntax }
                        let trimmed = String(exponent![exponent!.index(after: exponent!.startIndex)..<exponent!.index(before: exponent!.endIndex)])
                        exponentValue = try Value.getValueFrom(string: trimmed, system: system)
                        
                    case "variable":
                        exponentValue = Term()
                        for c in base! {
                            
                            (exponentValue as? Term)?.objects.append(Object(base: try VariableValue(string: String(c), system: system)))
                            
                        }
                        if (exponentValue as? Term)?.objects.count == 1 {
                            
                            exponentValue = (exponentValue as! Term).objects[0].base
                            
                        }
                        
                    case "function":
                        exponentValue = try FunctionValue(string: base!, system: system)
                        
                    default:
                        exponentValue = try Value.getValueFrom(string: exponent!, system: system)
                        
                    }
                    
                } else { exponentValue = nil }
                
                let object = Object(base: baseValue, exponent: exponentValue)
                if dividing {
                    
                    self.objects.append(Object(base: object, exponent: Number.negativeOne))
                    
                } else { self.objects.append(object) }
                
                base = nil
                baseType = nil
                dividing = false
                
            }
            
        }
        
        for c in str {
            
            if bracketsIn == 0 {
                
                if System.numberCharacters.contains(c) {
                    
                    if currentType != "number" {
                        
                        try endItem()
                        
                    }
                    
                    currentType = "number"
                    currentItem += String(c)
                    
                } else if c == "*" {
                    
                    try endItem()
                    
                } else if c == "/" {
                    
                    try endItem()
                    
                    dividing = true
                    
                } else if c == "^" {
                    
                    base = currentItem
                    baseType = currentType
                    
                    currentItem = ""
                    currentType = ""
                    
                } else if !System.openBrackets.contains(c) {
                    
                    if currentType != "variable" {
                        
                        try endItem()
                        
                    }
                    
                    currentType = "variable"
                    currentItem += String(c)
                    
                }
                
            }
            
            if System.openBrackets.contains(c) {
                
                let functionExists = currentType == "variable" && system.hasFunction(withName: currentItem)
                
                if bracketsIn == 0 && !functionExists {
                    
                    try endItem()
                    currentType = "expression"
                    
                } else if bracketsIn == 0 && functionExists {
                    
                    currentType = "function"
                    
                }
                
                currentItem += String(c)
                
                bracketsIn += 1
            
            } else if System.closeBrackets.contains(c) {
                
                currentItem += String(c)
                
                bracketsIn -= 1
            
            } else if bracketsIn != 0 { currentItem += String(c) }
            
        }
        
        try endItem()
        
        if objects.count == 0 { objects.append(Object(base: Number.zero)) }
        
    }
    
    // MARK: Functions
    
    public override func factor(system: System?) throws -> Term {
        
        var factors = [Object]()
        for o in objects {
            
            factors += try o.factor(system: system).objects
            
        }
        
        return try Term(objects: factors).combineObjects()
        
    }
    
    /**
 
    Combines like objects and removes objects to the power of 0
     
    - Return: `self` with the objects combined
     
    */
    internal func combineObjects() throws -> Term {
        
        //sort each factor by types
        var numbers = [Number]()
        var others = [Object]()
        for o in self.objects {
            
            if let n = try? o.evaluate() { numbers.append(n) }
            else { others.append(o.copy()) }
            
        }
        
        let term = Term()
        
        //combine numbers
        var number = Number.one
        for n in numbers {
            
            number *= n
            
        }
        term.objects.append(Object(base: number))
        if number == Number.zero { return term }
        
        //combine others
        var i = 0
        while i < others.count {
            
            let val = others[i]
            var match = false
            for o in term.objects {
                
                if o.base == val.base {
                    
                    let e1 = try val.exponent.evaluate()
                    let e2 = try o.exponent.evaluate()
                    
                    o.exponent = e1 + e2
                    
                    match = true
                    break
                    
                } else if let oBase = o.base as? Expression, let valBase = val.base as? Expression {
                    
                    if let num = valBase.compare(toExpression: oBase) {
                        
                        let e1 = try val.exponent.evaluate()
                        let e2 = try o.exponent.evaluate()
                        
                        o.exponent = e1 + e2
                        
                        if (try? num > Number.one || num < Number.negativeOne) ?? false {
                            
                            number *= try num^e1
                            
                        } else {
                            
                            number *= try (Number.one / num)^e2
                            o.base = valBase
                            
                        }
                        
                        match = true
                        break
                        
                    } else if let quotient = try valBase.divide(byExpression: oBase) {
                        
                        let e1 = try val.exponent.evaluate()
                        let e2 = try o.exponent.evaluate()
                        
                        o.exponent = e1 + e2
                        
                        others.append(Object(base: quotient, exponent: e1))
                        
                        match = true
                        break
                        
                    } else if let quotient = try oBase.divide(byExpression: valBase) {
                        
                        let e1 = try val.exponent.evaluate()
                        let e2 = try o.exponent.evaluate()
                        
                        o.base = valBase
                        o.exponent = e1 + e2
                        
                        others.append(Object(base: quotient, exponent: e2))
                        
                        match = true
                        break
                        
                    }
                    
                }
                
            }
            if !match {
                
                term.objects.append(val)
                
            }
            
            i += 1
            
        }
        
        //remove objects with power of 0
        term.objects = term.objects.filter { $0.exponent != Number.zero }
        i = term.objects.count - 1
        while i >= 0 {
            
            if term.objects[i].exponent == Number.zero {
                
                guard (try? term.objects[i].base.evaluate()) ?? Number.one == Number.zero else {
                    throw CalculationError.zeroToTheZero
                }
                
                term.objects.remove(at: i)
                
            }
            
            i -= 1
            
        }
        
        return term
        
    }
    
    public override func equals(_ value: Value) -> Bool {
        
        if !(value is Term) { return false }
        if !super.equals(value) { return false }
        
        var remainingObjects = copy().objects
        for o in (value as! Term).objects {
            
            var match = false
            for i in 0..<remainingObjects.count {
                
                if o == remainingObjects[i] {
                    
                    remainingObjects.remove(at: i)
                    match = true
                    break
                    
                }
                
            }
            if !match { return false }
            
        }
        
        return remainingObjects.count == 0
        
    }
    
    /**
 
    Adds `self` with passed `Term`
     
    - Parameter term: the `Term` being added to self
    - Parameter system: the system that the expression is being simplified within; used for settings
    - Returns: `self` added to `term`; nil if they are not like terms
    - Precondition: `self` and `term` are factored
     
    */
    public func add(term: Term, system: System) -> Term? {
        
        let (numA, termA) = self.extractNumbers()
        let (numB, termB) = term.extractNumbers()
        
        if termA == termB {
            
            let num = numA + numB
            termA.objects.append(Object(base: num))
            
            return termA
            
        } else { return nil }
        
    }
    
    /**
 
    Multiplies self with the given `Term`
     
    - Parameter term: the `Term` being multiplied with `self`
    - Returns: the product of the two `Term`s
     
    */
    public func multiply(term: Term) throws -> Term {
        
        let product = Term()
        for o in self.objects {
            
            product.objects.append(o.copy())
            
        }
        for o in term.objects {
            
            product.objects.append(o.copy())
            
        }
        
        return try product.combineObjects()
        
    }
    
    /**
     
    Divides `self` by the given `Term`
     
    - Parameter term: the `Term` dividing `self`
    - Returns: the quotient
     
    */
    public func divide(term: Term) throws -> Term {
        
        let quotient = Term()
        for o in self.objects {
            
            quotient.objects.append(o.copy())
            
        }
        for o in term.objects {
            
            let newO = o.copy()
            if let exponent = newO.exponent as? Number {
                
                newO.exponent = exponent * Number.negativeOne
                quotient.objects.append(newO)
                
            } else { throw SolvingError.nonAlgebraic }
            
        }
        
        return try quotient.combineObjects()
        
    }
    
    /**
 
    Distributes the term
     
    - Returns: `self` distributed
    - Precondition: `self` is factored
     
    */
    internal func expand() throws -> Expression {
        
        let nonExpandable = Term(objects: [Object(base: Number.one)])
        var product = Expression()
        product.terms.append(Term(objects: [Object(base: Number.one)]))
        for o in objects {
            
            if let expanded = try o.expand() {
                
                product = try product.multiply(byExpression: expanded)
                
            } else { nonExpandable.objects.append(o.copy()) }
            
        }
        
        for i in 0..<product.terms.count {
            
            product.terms[i] = try product.terms[i].multiply(term: nonExpandable)
            
        }
        
        return product
        
    }
    
    /**
 
    Cancels objects and combines ones with equivalent exponents
     
    - Returns: simplified version of `self`; `nil` if `self` = 0
     
    */
    public func simplify() throws -> Term? {
        
        let term = Term()
        
        for o in self.objects {
            
            var match = false
            for i in 0..<term.objects.count {
                
                if let base1 = o.base as? Expression, let base2 = term.objects[i].base as? Expression, o.exponent == term.objects[i].exponent {
                    
                    term.objects[i] = Object(base: try base1.multiply(byExpression: base2).simplify(), exponent: o.exponent.copy())
                    
                    match = true
                    break
                    
                }
                
            }
            
            if !match {
                
                if let base = o.base as? Expression {
                    
                    try term.objects.append(Object(base: base.simplify(), exponent: o.exponent.copy()))
                    
                } else { term.objects.append(o.copy()) }
            
            }
            
        }
        
        let combined = try term.combineObjects()
        if (combined.objects.count == 1 && combined.objects[0].base == Number.zero) || combined.objects.count == 0 { return nil }
        else {
            
            let (num, others) = combined.extractNumbers()
            
            if num == Number.one && others.objects.count > 0 { return others }
            else { return combined }
        
        }
        
    }
    
    /**
 
    Seperates the numbers from the rest of the term
     
    - Returns: tuple of the `Number` portion of `self` and the rest of `self`
    - Precondition: `self` and `term` are factored
     
    */
    internal func extractNumbers() -> (Number, Term) {
        
        var num = Number.one
        let term = Term()
        for o in objects {
            
            if let n = try? o.evaluate() {
                
                num *= n
                
            } else {
                
                term.objects.append(o.copy())
                
            }
            
        }
        
        return (num, term)
        
    }
    
    /**
 
    Extracts a given `Variable` from `self`
     
    - Parameter variable: the `Variable` being extracted
    - Returns: tuple of the variable's degree and the rest of the term
    - Precondition: `self` is combined
     
    */
    internal func extract(variable: Variable) throws -> (Number, Term) {
        
        var exponent = Number(int: 0)
        var otherObjects = self.copy().objects
        
        var i = otherObjects.count - 1
        while i >= 0 {
            
            if (otherObjects[i].base as? VariableValue)?.variable.identifier == variable.identifier {
                
                exponent += try otherObjects[i].exponent.evaluate()
                otherObjects.remove(at: i)
                
            }
            
            i -= 1
            
        }
        
        return (exponent, Term(objects: otherObjects))
        
    }
    
    public override func copy() -> Term {
        
        let term = Term()
        
        for o in self.objects { term.objects.append(o.copy()) }
        
        return term
        
    }
    
    public override func evaluate() throws -> Number {
        
        var product = Number.one
        for o in objects {
            
            product *= try o.evaluate()
            
        }
        
        return product
        
    }
    
    public override func plugIn(value: Value, forVariable variable: Variable) throws -> Value {
        
        let term = Term()
        for o in objects {
            
            let plugged = try o.plugIn(value: value, forVariable: variable)
            
            if let pluggedO = plugged as? Object {
                
                term.objects.append(pluggedO)
                
            } else {
                
                term.objects.append(Object(base: plugged))
                
            }
            
        }
        
        return term
        
    }
    
    /**
 
    Gets the numerator of `self`
     
    - Returns: the numerator of `self`
     
    */
    public func getNumerator() throws -> Term {
        
        let term = Term()
        for o in objects {
            
            if try o.exponent.evaluate() > Number.zero {
                
                term.objects.append(o.copy())
                
            }
            
        }
        
        if term.objects.count == 0 { term.objects.append(Object(base: Number.one)) }
        
        return term
        
    }
    
    /**
     
    Gets the denominator of `self`
     
    - Returns: the denominator of `self` (with negative exponents); nil if there is no denominator
     
    */
    public func getDenominator() throws -> Term? {
        
        let term = Term()
        for o in objects {
            
            if try o.exponent.evaluate() < Number.zero {
                
                term.objects.append(o.copy())
                
            }
            
        }
        
        if term.objects.count == 0 { return nil }
        
        return term
        
    }
    
    /**
 
    Gets the greatest common factor with another `Term`
     
    - Parameter term: the other `Term`
    - Returns: the gcf of `self` and `term`
    - Precondition: `self` and `term` are both factored
     
    */
    internal func gcf(with term: Term) throws -> Term {
        
        let gcf = Term()
        
        var uncheckedObjects = term.copy().objects
        var num1 = Number.one
        var num2 = Number.one
        for o in uncheckedObjects {
            
            if let num = try? o.evaluate() {
                
                num2 *= num
                
            }
            
        }
        for o in self.copy().objects {
            
            if let num = try? o.evaluate() {
                
                num1 *= num
                
            } else {
                
                for i in 0..<uncheckedObjects.count {
                    
                    if o.base == uncheckedObjects[i].base {
                        
                        try gcf.objects.append(Object(base: o.base.copy(),
                                                  exponent: Math.min(o.exponent.evaluate(), uncheckedObjects[i].exponent.evaluate())))
                        uncheckedObjects.remove(at: i)
                        break
                        
                    } else if let base1 = o.base as? Expression, let base2 = uncheckedObjects[i].base as? Expression,
                              let compared = base1.compare(toExpression: base2) {
                        
                        let e1 = try o.exponent.evaluate()
                        let e2 = try uncheckedObjects[i].exponent.evaluate()
                        
                        uncheckedObjects.remove(at: i)
                        
                        if (try? compared > Number.one || compared < Number.negativeOne) ?? false {
                            
                            do {
                                
                                try gcf.objects.append(Object(base: base2, exponent: Math.min(e1, e2)))
                                num1 *= compared
                                
                            } catch { throw CalculationError.raisedToComplexNumber }
                            
                        } else {
                            
                            do {
                            
                                try gcf.objects.append(Object(base: base1, exponent: Math.min(e1, e2)))
                                num2 /= compared
                                
                            } catch { throw CalculationError.raisedToComplexNumber }
                            
                        }
                        
                    }
                    
                }
                
            }
            
        }
        
        gcf.objects.append(Object(base: num1.gcf(with: num2)))
        
        return gcf
        
    }
    
    /**
     
    Gets the least common multiple with another `Term`
     
    - Parameter term: the other `Term`
    - Returns: the lcm of `self` and `term`
     
    */
    internal func lcm(with term: Term) throws -> Term {
        
        return try self.multiply(term: term).divide(term: self.gcf(with: term))
        
    }
    
    internal func getReciprocal() throws -> Term {
        
        let reciprocal = Term()
        for o in objects {
            
            let reciprocalO = o.copy()
            reciprocalO.exponent = try reciprocalO.exponent.evaluate() * Number.negativeOne
            reciprocal.objects.append(reciprocalO)
            
        }
        
        return reciprocal
        
    }
    
    public override func getVariables() -> [Variable] {
        
        var arr = [Variable]()
        
        for o in objects {
            
            for v in o.getVariables() {
                
                var match = false
                for a in arr {
                    
                    if v == a { match = false; break }
                    
                }
                if !match { arr.append(v) }
                
            }
            
        }
        
        var copied = [Variable]()
        for v in arr { copied.append(v.copy()) }
        
        return copied
        
    }
    
    public override func derivative(inTermsOf variable: Variable, system: System) throws -> Value {
        
        let objects = self.objects
        
        var terms = [Term]()
        for i in 0..<objects.count {
            
            let der = try objects[i].derivative(inTermsOf: variable, system: system)
            let term = Term(objects: [Object(base: der)])
            for j in 0..<objects.count {
                
                if i != j {
                    
                    term.objects.append(objects[j].copy())
                    
                }
                
            }
            
            terms.append(term)
            
        }
        
        return Expression(terms: terms)
        
    }
    
    //MARK: CustomStringConvertible
    
    public override var description: String {
        
        var numbers = [Object]()
        var variables = [Object]()
        var others = [Object]()
        var functions = [Object]()
        for o in objects {
            
            if o.base is Number { numbers.append(o) }
            else if o.base is VariableValue { variables.append(o) }
            else if o.base is FunctionValue && o.exponent == Number.one { functions.append(o) }
            else { others.append(o) }
            
        }
        
        var str = ""
        
        var first = true
        for n in numbers {
            
            if n.description != "1" {
                
                if !first { str += "*" }
                let ifComplex = variables.count + others.count + functions.count > 0 || (n.base as! Number).imaginaryNum < 0.0 || (n.base as! Number).realNum < 0.0
                if (try? n.exponent == Number.one && (n.base as! Number) < Number.zero) ?? ifComplex { str += "(\(n.description))" }
                else { str += n.description }
                first = false
                
            }
            
        }
        
        for v in variables {
            
            str += v.description
            
        }
        
        for o in others {
            
            if (o.base is Expression || o.base is Term) && o.exponent == Number.one {
                
                str += "(\(o.description))"
                
            } else { str += o.description }
            
        }
        
        if variables.count > 0 && others.count == 0 && functions.count > 0 { str += "*" }
        for f in functions {
            
            str += f.description
            
        }
        
        if str == "" { str = "1" }
        return super.description + str
        
    }
    
}
