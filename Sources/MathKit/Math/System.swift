//
//  System.swift
//  MathKit
//
//  Created by Liam Stevenson on 12/1/16.
//  Copyright © 2016 Liam Stevenson. All rights reserved.
//

import Foundation

/// Represents a mathematical system that holds a set of equations and variables dependant upon each other,
/// along with different calculation modes
public class System {
    
    // MARK: Global Values
    
    /// String of characters that are open brackets
    public static let openBrackets = "([{"
    
    /// String of characters that are close brackets
    public static let closeBrackets = ")]}"
    
    /// String of characters that are additive
    internal static let additiveCharacters = "+-±"
    
    /// String of characters that are in numbers
    internal static let numberCharacters = "-+0123456789.ⅈ"
    
    // MARK: System Values
    
    /// List of equations that are part of the system
    public var equations = [Equation]()
    
    /// List of variables used in the system
    public var variables = [Variable]()
    
    /// List of functions part of the system
    public var functions = [Function]()
    
    /// The identifiers of deafault variables
    private var defaultVariableIdentifiers = [Int]()
    
    // MARK: Built-In System Variables and Functions
    
    public static var sineName = "sin"
    public static var cosineName = "cos"
    public static var tangentName = "tan"
    public static var cosecantName = "csc"
    public static var secantName = "sec"
    public static var cotangentName = "cot"
    
    public static var arcsineName = "asin"
    public static var arccosineName = "acos"
    public static var arctangentName = "atan"
    public static var arccosecantName = "acsc"
    public static var arcsecantName = "asec"
    public static var arccotangentName = "acot"
    
    public static var logName = "log"
    public static var naturalLogName = "ln"
    
    public static var derivativeName = "deriv"
    public static var numericalDerivativeName = "nderiv"
    public static var numericalIntegralName = "∫"
    
    public static var absoluteValueName = "abs"
    public static var factorialName = "fact"
    public static var floorName = "floor"
    
    public static var piName = "π"
    public static var eName = "e"
    
    static var parameter1Name = "%parameter variable1%"
    static var parameter2Name = "%parameter variable2%"
    static var parameter3Name = "%parameter variable3%"
    static var parameter4Name = "%parameter variable4%"
    
    var sine: Function { return function(withName: System.sineName, variables: [variable(withSymbol: System.parameter1Name)]) }
    var cosine: Function { return function(withName: System.cosineName, variables: [variable(withSymbol: System.parameter1Name)]) }
    var tangent: Function { return function(withName: System.tangentName, variables: [variable(withSymbol: System.parameter1Name)]) }
    var cosecant: Function { return function(withName: System.cosecantName, variables: [variable(withSymbol: System.parameter1Name)]) }
    var secant: Function { return function(withName: System.secantName, variables: [variable(withSymbol: System.parameter1Name)]) }
    var cotangent: Function { return function(withName: System.cotangentName, variables: [variable(withSymbol: System.parameter1Name)]) }
    
    var arcsine: Function { return function(withName: System.arcsineName, variables: [variable(withSymbol: System.parameter1Name)]) }
    var arccosine: Function { return function(withName: System.arccosineName, variables: [variable(withSymbol: System.parameter1Name)]) }
    var arctangent: Function { return function(withName: System.arctangentName, variables: [variable(withSymbol: System.parameter1Name)]) }
    var arccosecant: Function { return function(withName: System.arccosecantName, variables: [variable(withSymbol: System.parameter1Name)]) }
    var arcsecant: Function { return function(withName: System.arcsecantName, variables: [variable(withSymbol: System.parameter1Name)]) }
    var arccotangent: Function { return function(withName: System.arccotangentName, variables: [variable(withSymbol: System.parameter1Name)]) }
    
    var naturalLog: Function { return function(withName: System.naturalLogName, variables: [variable(withSymbol: System.parameter1Name)]) }
    var log: Function { return function(withName: System.logName, variables: [variable(withSymbol: System.parameter1Name), variable(withSymbol: System.parameter2Name)]) }
    
    var derivative: Function { return function(withName: System.derivativeName, variables: [variable(withSymbol: System.parameter1Name), variable(withSymbol: System.parameter2Name), variable(withSymbol: System.parameter3Name)], protectedVariables: [true, true, false]) }
    var numericalDerivative: Function { return function(withName: System.numericalDerivativeName, variables: [variable(withSymbol: System.parameter1Name), variable(withSymbol: System.parameter2Name), variable(withSymbol: System.parameter3Name)], protectedVariables: [true, true, false]) }
    var numericalIntegral: Function { return function(withName: System.numericalIntegralName, variables: [variable(withSymbol: System.parameter1Name), variable(withSymbol: System.parameter2Name), variable(withSymbol: System.parameter4Name), variable(withSymbol: System.parameter4Name)], protectedVariables: [true, true, false, false]) }
    
    var absoluteValue: Function { return  function(withName: System.absoluteValueName, variables: [variable(withSymbol: System.parameter1Name)]) }
    var factorial: Function { return  function(withName: System.factorialName, variables: [variable(withSymbol: System.parameter1Name)]) }
    var floor: Function { return  function(withName: System.floorName, variables: [variable(withSymbol: System.parameter1Name)]) }
    
    var pi: Variable { return variable(withSymbol: System.piName) }
    var e: Variable { return variable(withSymbol: System.eName) }
    
    // MARK: System Settings
    
    /// If true, constants in the system are evaluated
    public var evaluateConstants = true
    
    /// The mode for the units of angles in the system
    public var angleMode = AngleMode.radian {
        
        didSet {
            
            for f in functions {
                
                f.angleMode = angleMode
                
            }
            
        }
        
    }
    
    /// The mode for how numbers are evaluated in the system
    public var numberMode = NumberMode.decimal
    
    /// The mode for when fractions are combined when simplifying
    public var fractionMode = FractionMode.combineLikeFractions
    
    /// Identifiers
    private var usedIdentifierIndex: UInt8 = 0
    
    // MARK: Initializers
    
    public init() {
        
        loadDefaults()
        
    }
    
    // MARK: Functions
    
    /**
 
    Solves the system 
     
    - Parameter variable: the `Variable` being solved for
    - Returns: found solutions
     
    */
    public func solve(forVariable variable: Variable) throws -> [Value] {
        
        var equationSolutions = [Variable:[[(Value, Int)]]]()
        
        var i = 0
        for equation in equations {
            
            for v in variables {
                
                if !isDefault(variable: v) {
                    
                    let solutions = try equation.solve(forVariable: v)
                    
                    var solutionTuples = [(Value, Int)]()
                    for sol in solutions {
                        
                        if sol.isLinear { solutionTuples.append((sol, i)) }
                        
                    }
                    
                    equationSolutions[v] = (equationSolutions[v] ?? []) + [solutionTuples]
                    
                }
                
            }
            i += 1
            
        }
        
        func combinationsA<T>(of arrs: [[T]]) -> [[T]] {
            
            var comb = [[T]]()
            
            if arrs.count <= 1 {
                
                for e in arrs.first ?? [] {
                    
                    comb.append([e])
                    
                }
                
                return comb
                
            }
            
            var arrsRemoved = [[T]]()
            for i in 1..<arrs.count {
                
                arrsRemoved.append(arrs[i])
                
            }
            let arrsRemovedCombinations = combinationsA(of: arrsRemoved)
            
            for e in arrs[0] {
                
                for f in arrsRemovedCombinations {
                    
                    comb += [[e] + f]
                    
                }
                
            }
            
            return comb
            
        }
        
        func combinationsB<A,B>(of dict: [A:[B]]) -> [[A:B]] {
            
            var comb = [[A:B]]()
            
            var keys = Array(dict.keys)
            
            if keys.count == 1 {
                
                for e in dict[keys[0]]! {
                    
                    comb.append([keys[0] : e])
                    
                }
                
            } else if keys.count == 0 { return [] }
            
            var dictRemoved = [A:[B]]()
            for i in 1..<keys.count {
                
                dictRemoved[keys[i]] = dict[keys[i]]!
                
            }
            let dictRemovedCombinations = combinationsB(of: dictRemoved)
            
            for e in dict[keys[0]]! {
                
                for f in dictRemovedCombinations {
                    
                    var d = f
                    d[keys[0]] = e
                    
                    comb += [d]
                    
                }
                
            }
            
            return comb
            
        }
        
        func solve(variable: Variable, forVariable: Variable, checkedVariables checked: [Variable], exceptedEquations: [Int]) -> [Value] {
            
            var checked = checked
            if checked.contains(variable) { return [] }
            else { checked += [variable] }
            
            var solutions = [Value]()
            for set in combinationsA(of: equationSolutions[variable] ?? []) {
                
                insideSet:
                for i in 0..<set.count {
                    
                    if !exceptedEquations.contains(set[i].1) {
                        
                        var variables = set[i].0.getVariables()
                        var variableSolutions = [Variable:[Value]]()
                        
                        if variables.count == 0 { solutions += [set[i].0]; break insideSet }
                        
                        var j = variables.count - 1
                        while j >= 0 {
                            
                            if checked.contains(variables[j]) { variables.remove(at: j) }
                            else if variables[j].value != nil { variables.remove(at: j) }
                            else {
                                
                                variableSolutions[variables[j]] = solve(variable: variables[j], forVariable: forVariable, checkedVariables: checked, exceptedEquations: exceptedEquations + [set[i].1])
                                if variableSolutions[variables[j]]! == [] && i == set.count - 1 { break insideSet }
                                
                            }
                            
                            j -= 1
                            
                        }
                        
                        if variables.count == 0 { solutions += [set[i].0]; break insideSet }
                        
                        for dict in combinationsB(of: variableSolutions) {
                            
                            var value = set[i].0.copy()
                            for (variable, variableValue) in dict {
                                
                                do { value = try value.plugIn(value: variableValue, forVariable: variable) }
                                catch { }
                                
                            }
                            solutions.append(value)
                            
                        }
                        
                        if solutions.count > 0 { break insideSet }
                        
                    }
                    
                }
                
            }
            
            return solutions
            
        }
        
        var solutions = [Value]()
        for value in solve(variable: variable, forVariable: variable, checkedVariables: [], exceptedEquations: []) {
            
            let lhs = Expression(terms: [Term(objects: [Object(base: VariableValue(variable: variable))])])
            let rhs = Expression(terms: [Term(objects: [Object(base: value)])])
            
            let equation = Equation(leftHandSide: lhs, rightHandSide: rhs)
            solutions += try equation.solve(forVariable: variable)
            
        }
        
        var checkedSolutions = [Value]()
        for solution in solutions {
            
            var works = true
            for equation in equations {
                
                let e = try equation.plugIn(value: solution, forVariable: variable)
                
                let lhs = try? e.leftHandSide.evaluate()
                let rhs = try? e.rightHandSide.evaluate()
                
                if lhs != nil && lhs != rhs {
                
                    works = false
                    break
                
                }
                
            }
            if works && !checkedSolutions.contains(solution) {
                
                checkedSolutions.append(solution)
            
            }
            
        }
        
        return checkedSolutions
        
    }
    
    /**
     
    If a function with the name exists, it is returned. Otherwise, it is created.
     
    - Parameter name: the name of the function
    - Returns: a function with the name
     
    */
    @discardableResult
    public func function(withName name: String, variables: [Variable], protectedVariables: [Bool]? = nil) -> Function {
        
        let function = functions.first(where: { $0.name == name })
        if let function = function {
            
            return function
            
        } else {
            
            usedIdentifierIndex += 1
            let newFunction = Function(name: name, variables: variables, value: nil, identifier: Int(usedIdentifierIndex), protectedVariables: protectedVariables, system: self)
            functions.append(newFunction)
            return newFunction
            
        }
        
    }
    
    /**
 
    Removes all functions with a given name
     
    - Parameter name: the name to be matched
     
    */
    public func removeFunction(withName name: String) {
        
        let startCount = functions.count
        for i in 0..<startCount {
            
            if functions[startCount - i - 1].name == name {
                
                functions.remove(at: startCount - i - 1)
                
            }
            
        }
        
    }
    
    /**

    Determines if `self` has an existing function with a given name
     
    - Parameter name: the function name in question
     
    */
    public func hasFunction(withName name: String) -> Bool {
        
        for f in functions {
            
            if f.name == name { return true }
            
        }
        
        return false
        
    }
    
    /**
 
    If a variable with the symbol exists, it is returned. Otherwise, it is created.
     
    - Parameter symbol: the symbol of the variable
    - Returns: a variable with the name
     
    */
    @discardableResult
    public func variable(withSymbol symbol: String) -> Variable {
        
        let variable = variables.first(where: { $0.symbol == symbol })
        if let variable = variable {
            
            return variable
            
        } else {
            
            usedIdentifierIndex += 1
            let newVariable = Variable(symbol: symbol, value: nil, identifier: Int(usedIdentifierIndex))
            variables.append(newVariable)
            return newVariable
            
        }
        
    }
    
    public func removeVariable(withSymbol symbol: String) {
        
        var i = variables.count - 1
        while i >= 0 {
            
            if variables[i].symbol == symbol {
                
                variables.remove(at: i)
                
            }
            i -= 1
            
        }
        
    }
    
    /**
 
    Gets a default variable
     
    - Returns: the default variable
     
    */
    internal func defaultVariable() -> Variable {
        
        if let v = variables.first(where: {$0.value == nil}) {
            
            return v
            
        } else {
            
            usedIdentifierIndex += 1
            return Variable(symbol: "x", value: nil, identifier: Int(usedIdentifierIndex))
            
        }
        
    }
    
    /**
 
    Loads the default constants and functions, like pi, sine, and log
     
    */
    private func loadDefaults() {
        
        let param1 = variable(withSymbol: System.parameter1Name)
        let param2 = variable(withSymbol: System.parameter2Name)
        let param3 = variable(withSymbol: System.parameter3Name)
        let param4 = variable(withSymbol: System.parameter4Name)
        
        defaultVariableIdentifiers.append(param1.identifier)
        defaultVariableIdentifiers.append(param2.identifier)
        defaultVariableIdentifiers.append(param3.identifier)
        defaultVariableIdentifiers.append(param4.identifier)
        
        let e = variable(withSymbol: System.eName)
        defaultVariableIdentifiers.append(e.identifier)
        e.value = Number.e
        
        let pi = variable(withSymbol: System.piName)
        defaultVariableIdentifiers.append(pi.identifier)
        pi.value = Number.pi
        
        function(withName: System.sineName, variables: [param1])
        function(withName: System.cosineName, variables: [param1])
        function(withName: System.tangentName, variables: [param1])
        function(withName: System.cosecantName, variables: [param1])
        function(withName: System.secantName, variables: [param1])
        function(withName: System.cotangentName, variables: [param1])
        
        function(withName: System.arcsineName, variables: [param1])
        function(withName: System.arccosineName, variables: [param1])
        function(withName: System.arctangentName, variables: [param1])
        function(withName: System.arccosecantName, variables: [param1])
        function(withName: System.arcsecantName, variables: [param1])
        function(withName: System.arccotangentName, variables: [param1])
        
        function(withName: System.naturalLogName, variables: [param1])
        function(withName: System.logName, variables: [param1, param2])
        
        function(withName: System.derivativeName, variables: [param1, param2, param3], protectedVariables: [true, true, false])
        function(withName: System.numericalDerivativeName, variables: [param1, param2, param3], protectedVariables: [true, true, false])
        function(withName: System.numericalIntegralName, variables: [param1, param2, param3, param4], protectedVariables: [true, true, false, false])
        
        function(withName: System.absoluteValueName, variables: [param1])
        function(withName: System.factorialName, variables: [param1])
        function(withName: System.floorName, variables: [param1])
        
    }
    
    /**
 
    Determines if a given variable is a default system variable
     
    - Parameter variable: the `Variable` being checked
    - Returns: true is `variable` is a default
     
    */
    internal func isDefault(variable: Variable) -> Bool {
        
        return defaultVariableIdentifiers.contains(variable.identifier)
        
    }
    
    // MARK: Copying
    
    /**
 
    Copies `self`
     
    - Returns: a copy of `self`
     
    */
    public func copy() -> System {
        
        let system = System()
        
        for e in self.equations { system.equations.append(e.copy()) }
        for v in self.variables { system.variables.append(v.copy()) }
        for f in self.functions { system.functions.append(f.copy()) }
        
        system.evaluateConstants = self.evaluateConstants
        system.angleMode = self.angleMode
        system.numberMode = self.numberMode
        
        return system
        
    }
    
}
