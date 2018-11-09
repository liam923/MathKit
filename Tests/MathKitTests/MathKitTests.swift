//
//  MathKitTests.swift
//  MathKitTests
//
//  Created by Liam Stevenson on 11/29/16.
//  Copyright © 2016 Liam Stevenson. All rights reserved.
//

import XCTest
@testable import MathKit

class MathKitTests: XCTestCase {
    
    let system = System()
    
    override func setUp() {
        
        super.setUp()
        
        let function = system.function(withName: "f", variables: [system.variable(withSymbol: "x")])
        function.value = Number(int: 2)
        
        let function2 = system.function(withName: "g", variables: [system.variable(withSymbol: "x")])
        function2.value = try! Expression(string: "3x+2", system: system)
        
    }
    
    override func tearDown() {
        
        super.tearDown()
        
    }
    
    func testPrinting() {
        
        let x = VariableValue(variable: Variable(symbol: "x", value: nil, identifier: 0))
        
        let object = Object(base: x, exponent: nil)
        
        let term1 = Term()
        term1.objects = [object]
        
        let term2 = Term()
        term2.objects = [Object(base: Number.one)]
        
        let expression = Expression()
        expression.terms = [term1, term2]
        
        XCTAssert(x.description == "x", x.description)
        XCTAssert(object.description == "x", object.description)
        XCTAssert(term1.description == "x", term1.description)
        XCTAssert(term2.description == "1", term2.description)
        XCTAssert(expression.description == "x + 1", expression.description)
        
    }
    
    func testTermFactoring() {
        
        let system = System()
        
        let x = VariableValue(variable: Variable(symbol: "x", value: nil, identifier: 0))
        let y = VariableValue(variable: Variable(symbol: "y", value: nil, identifier: 1))
        
        let object1 = Object(base: y, exponent: Number(double: 1))
        let object2 = Object(base: x, exponent: Object(base: Number(int: 2), exponent: Number(int: 3)))
        
        let term = Term()
        term.objects = [object1, object2]
        
        let termOuter = Term()
        termOuter.objects.append(Object(base: term, exponent: Number(int: -3)))
        
        let factored = try! term.factor(system: nil)
        
        let term2 = try! Term(string: ".5(x+1)/(x+1)^2", system: system)
        XCTAssert(term2.description == "0.5(x + 1)((x + 1)^(2))^(-1)", term2.description)
        let factored2 = try! term2.factor(system: system)
        
        XCTAssert(factored.description == "y(x)^(8)", factored.description)
        XCTAssert(factored2.description == "0.5(x + 1)^(-1)", factored2.description)
        
    }
    
    func testTermCombining() {
        
        let term1 = try! Term(string: "(x +1)(x+2)", system: system).factor(system: system)
        let term2 = try! Term(string: "(3(x)^(3) + 13(x)^(2) + 16x + 4)/(x+2)", system: system).factor(system: system)
        let term3 = try! Term(string: "(x+1)/(5(x)^(3) + 12(x)^(2) + 7x)", system: system).factor(system: system)
        let term4 = try! Term(string: "(x+1)^(5)*((x)^(2) + 2x + 1)^(2)", system: system).factor(system: system)
        let term5 = try! Term(string: "xyz", system: system).factor(system: system)
        
        XCTAssert(term1.description == "(x + 1)(x + 2)", term1.description)
        XCTAssert(term2.description == "(x + 2)(3x + 1)", term2.description)
        XCTAssert(term3.description == "(x)^(-1)(5x + 7)^(-1)", term3.description)
        XCTAssert(term4.description == "(x + 1)^(9)", term4.description)
        XCTAssert(term5.description == "xyz", term5.description)
        
    }
    
    func testEqual() {
        
        let system = System()
        
        let x = VariableValue(variable: Variable(symbol: "x", value: nil, identifier: 0))
        
        let object1 = Object(base: x, exponent: nil)
        let object2 = Object(base: Number(int: 2))
        
        let term1 = Term()
        term1.objects = [object1]
        
        let term2 = Term()
        term2.objects = [object2]
        
        let term3 = Term()
        term3.objects = [object1, object2]
        
        let term4 = Term()
        term4.objects = [object2, object1]
        
        let expression1 = Expression()
        expression1.terms = [term1, term2]
        
        let expression2 = Expression()
        expression2.terms = [term2, term1]
        
        let expression3 = Expression()
        expression3.terms = [term1, term1]
        
        XCTAssert(object1 == object1)
        XCTAssert(object1 != object2)
        XCTAssert(object2 == object2)
        
        XCTAssert(term1 == term1)
        XCTAssert(term1 != term2)
        XCTAssert(term1 != term3)
        XCTAssert(term1 != term4)
        XCTAssert(term2 == term2)
        XCTAssert(term2 != term3)
        XCTAssert(term2 != term4)
        XCTAssert(term3 == term3)
        XCTAssert(term3 == term4)
        XCTAssert(term4 == term4)
        
        XCTAssert(expression1 == expression1)
        XCTAssert(expression1 == expression2)
        XCTAssert(expression1 != expression3)
        XCTAssert(expression2 == expression2)
        XCTAssert(expression2 != expression3)
        XCTAssert(expression3 == expression3)
        
        XCTAssert(try! Expression(string: "x+1", system: system) == Expression(string: "1+x", system: system))
        
    }
    
    func testPlugIn() {
        
        let x = VariableValue(variable: Variable(symbol: "x", value: nil, identifier: 0))
        let y = VariableValue(variable: Variable(symbol: "y", value: nil, identifier: 1))
        
        let object1 = Object(base: y, exponent: Number(double: 1))
        let object2 = Object(base: x, exponent: Object(base: Number(int: 2), exponent: Number(int: 3)))
        
        let term = Term()
        term.objects = [object1, object2]
        
        let termOuter = Term()
        termOuter.objects.append(Object(base: term, exponent: Number(int: -3)))
        
        var factored = try! term.factor(system: nil)
        factored = try! factored.plugIn(value: x, forVariable: y.variable) as! Term
        
        XCTAssert(factored.description == "x(x)^(8)", factored.description)
        
    }
    
    func testInit() {
        
        let term1 = try! Term(string: "12", system: system)
        let term2 = try! Term(string: "-12", system: system)
        let term3 = try! Term(string: "--12", system: system)
        let term4 = try! Term(string: "xyz", system: system)
        let term5 = try! Term(string: "x^2y", system: system)
        
        XCTAssert(term1.description == "12", term1.description)
        XCTAssert(term2.description == "(-1)*12", term2.description)
        XCTAssert(term3.description == "12", term3.description)
        XCTAssert(term4.description == "(xyz)", term4.description)
        XCTAssert(term5.description == "(x)^(2)y", term5.description)
        
        let expression1 = try! Expression(string: "3x^2y + 1/(1+x) + 2", system: system)
        let expression2 = try! Expression(string: "6x - 7y", system: system)
        let expression3 = try! Expression(string: "3*xy(x+1)", system: system)
        let expression4 = try! Expression(string: "1+2+3+4-4-3-2-1+x", system: system)
        let expression5 = try! Expression(string: "(3x+1)^(5z)/(x8y)^(4)", system: system)
        let expression6 = try! Expression(string: "f(x)", system: system)
        
        XCTAssert(expression1.description == "3(x)^(2)y + (1 + x)^(-1) + 2", expression1.description)
        XCTAssert(expression2.description == "6x - 7y", expression2.description)
        XCTAssert(expression3.description == "3(xy)(x + 1)", expression3.description)
        XCTAssert(expression4.description == "1 + 2 + 3 + 4 - 4 - 3 - 2 - 1 + x", expression4.description)
        XCTAssert(expression5.description == "(3x + 1)^(5z)((8xy)^(4))^(-1)", expression5.description)
        XCTAssert(expression6.description == "f(x)", expression6.description)
        
    }
    
    func testCalculations() {
        
        let system = System()
        
        let value1 = try! Expression(string: "1+3", system: system).evaluate()
        let value2 = try! Expression(string: "2^4 + 5*9/2 - 5^(2^2)", system: system).evaluate()
        let value3 = try! Expression(string: "7/2", system: system).evaluate()
        let value4 = try! Expression(string: "1000/1000*1000", system: system).evaluate()
        let value5 = try! Expression(string: "1/(8) * 4", system: system).evaluate()
        let value6 = try! Expression(string: "(-1)^(2)", system: system).evaluate()
        
        XCTAssert(value1 == Number(int: 4), value1.description)
        XCTAssert(value2 == Number(double: -586.5), value2.description)
        XCTAssert(value3 == Number(double: 3.5), value3.description)
        XCTAssert(value4 == Number(int: 1000), value4.description)
        XCTAssert(value5 == Number(double: 0.5), value5.description)
        XCTAssert(value6 == Number(int: 1), value6.description)
        
    }
    
    func testTermAdding() {
        
        let term1 = try! Term(string: "3x", system: system).factor(system: system).add(term: Term(string: "2x", system: system).factor(system: system), system: system)
        let term2 = try! Term(string: "3xy(x+1)", system: system).factor(system: system).add(term: Term(string: "7.5xy(x+1)", system: system).factor(system: system), system: system)
        let term3 = try! Term(string: "3x", system: system).factor(system: system).add(term: Term(string: "3y", system: system).factor(system: system), system: system)
        let term4 = try! Term(string: "3xy(x+1)", system: system).factor(system: system).add(term: Term(string: "7.5xy(x-1)", system: system).factor(system: system), system: system)
        let term5 = try! Term(string: "3xy(x+1)(x+1)", system: system).factor(system: system).add(term: Term(string: "-7.5xy(x+1)^2", system: system).factor(system: system), system: system)
        
        XCTAssert(term1?.description == "5x", term1?.description ?? "nil")
        XCTAssert(term2?.description == "10.5xy(x + 1)", term2?.description ?? "nil")
        XCTAssert(term3?.description == nil, term3?.description ?? "nil")
        XCTAssert(term4?.description == nil, term4?.description ?? "nil")
        XCTAssert(term5?.description == "(-4.5)xy(x + 1)^(2)", term5?.description ?? "nil")
        
    }
    
    func testSimplifying() {
        
        let system2 = System()
        system2.fractionMode = .combineAllTerms
        
        let system3 = System()
        system3.fractionMode = .combineAllFractions
    
        let expression1 = try! Expression(string: "(x + y) / z + x + y", system: system).simplify(system: system)
        let expression2 = try! Expression(string: "2y^2+(x+1)", system: system).simplify(system: system)
        let expression3 = try! Expression(string: "3(x+1)^(2.0)", system: system).simplify(system: system)
        let expression4 = try! Expression(string: "3(x+2)(x+1)^(-1)", system: system2).simplify(system: system2)
        let expression5 = try! Expression(string: "3(x+1)^(.5)(x+2)^(.5)", system: system).simplify(system: system)
        let expression6 = try! Expression(string: "3(x(x-1)+1) / (x+7) / (x + 8)", system: system).simplify(system: system)
        let expression7 = try! Expression(string: "x/y + y/x + xy", system: system3).simplify(system: system3)
        let expression8 = try! Expression(string: "(6(y)^(2) + 3/y)^(3) + 7(y)^(3) + 2", system: system).simplify(system: system)
        let expression9 = try! Expression(string: "sin(π/2)", system: system).simplify(system: system)
        
        XCTAssert(expression1.description == "x + y + (z)^(-1)(x + y)", expression1.description)
        XCTAssert(expression2.description == "x + 2(y)^(2) + 1", expression2.description)
        XCTAssert(expression3.description == "3(x)^(2) + 6x + 3", expression3.description)
        XCTAssert(expression4.description == "(3x + 6)(x + 1)^(-1)", expression4.description)
        XCTAssert(expression5.description == "3((x)^(2) + 3x + 2)^(0.5)", expression5.description)
        XCTAssert(expression6.description == "(3(x)^(2) - 3x + 3)((x)^(2) + 15x + 56)^(-1)", expression6.description)
        XCTAssert(expression7.description == "xy + (x)^(-1)(y)^(-1)((x)^(2) + (y)^(2))", expression7.description)
        XCTAssert(expression8.description == "216(y)^(6) + 331(y)^(3) + 27(y)^(-3) + 164", expression8.description)
        XCTAssert(expression9.description == "1", expression9.description)
    
    }
    
    func testCompare() {
        
        let expression1 = try! Expression(string: "1x+1", system: system).simplify()
        let expression2 = try! Expression(string: "2x+2", system: system).simplify()
        let expression3 = try! Expression(string: "x+3y", system: system).simplify()
        let expression4 = try! Expression(string: "12y+4x", system: system).simplify()
        let expression5 = try! Expression(string: "x+2y", system: system).simplify()
        let expression6 = try! Expression(string: "x+y", system: system).simplify()
        
        XCTAssert(expression1.compare(toExpression: expression1) == Number(double: 1))
        XCTAssert(expression1.compare(toExpression: expression2) == Number(double: 0.5))
        XCTAssert(expression3.compare(toExpression: expression4) == Number(double: 0.25))
        XCTAssert(expression2.compare(toExpression: expression3) == nil)
        XCTAssert(expression5.compare(toExpression: expression6) == nil)
        
    }
    
    func testTermSimplifying() {
        
        let term1 = try! Term(string: "3xy", system: system).combineObjects()
        let term2 = try! Term(string: "3(x+1)(x+1)", system: system).combineObjects()
        let term3 = try! Term(string: "(5x+5)(x+1)^(-1.0)", system: system).combineObjects()
        let term4 = try! Term(string: "(x+1)(x+2)", system: system).combineObjects()
        let term5 = try! Term(string: "(x+1)^(4)*(4x+4)^(3)", system: system).combineObjects()
        
        XCTAssert(term1.description == "3(xy)", term1.description)
        XCTAssert(term2.description == "3(x + 1)^(2)", term2.description)
        XCTAssert(term3.description == "4.999999999999999", term3.description)
        XCTAssert(term4.description == "(x + 1)(x + 2)", term4.description)
        XCTAssert(term5.description == "64(x + 1)^(7)", term5.description)

    }
    
    func testGCF() {
        
        let gcf1 = try! Term(string: "12", system: system).gcf(with: Term(string: "15x", system: system))
        let gcf2 = try! Term(string: "1.5x", system: system).gcf(with: Term(string: "x", system: system))
        let gcf3 = try! Term(string: "(x+1)(y+1)", system: system).gcf(with: Term(string: "(x+1)", system: system))
        let gcf4 = try! Term(string: "(2x+2)", system: system).gcf(with: Term(string: "(4x+4)", system: system))
        let gcf5 = try! Term(string: "5(x)^(5)", system: system).gcf(with: Term(string: "(x)^(3)", system: system))
        let gcf6 = try! Term(string: "(16x+4)^(.5)", system: system).gcf(with: Term(string: "(8x+2)^(2)", system: system))
        
        XCTAssert(gcf1.description == "3", gcf1.description)
        XCTAssert(gcf2.description == "x", gcf2.description)
        XCTAssert(gcf3.description == "(x + 1)", gcf3.description)
        XCTAssert(gcf4.description == "(2x + 2)", gcf4.description)
        XCTAssert(gcf5.description == "(x)^(3)", gcf5.description)
        XCTAssert(gcf6.description == "(8x + 2)^(0.5)", gcf6.description)
        
    }
    
    func testFactoring() {
        
        let function = system.function(withName: "testFunc", variables: [system.variable(withSymbol: "x")])
        function.value = try! Expression(string: "deriv(x+1,x,x)", system: system)
        
        let term1 = try! Expression(string: "2x+2", system: system).factor(system: system)
        let term2 = try! Expression(string: "12(x)^(-1) + 15(y)^(-2)", system: system).factor(system: system)
        let term3 = try! Expression(string: "16xyz - 2(x)^(2)*(z)^(-3) + 8y", system: system).factor(system: system)
        let term4 = try! Expression(string: "-27(a)^(3) + 8(b)^(3)", system: system).factor(system: system)
        let term5 = try! Expression(string: "9(a)^(2) - 16", system: system).factor(system: system)
        let term6 = try! Expression(string: "(x)^(2) + 2x + 1", system: system).factor(system: system)
        let term7 = try! Expression(string: "18(x)^(4)(y)^(2) + 9(x)^(2)y - 14", system: system).factor(system: system)
        let term8 = try! Expression(string: "3(x)^(3) + 3(x)^(2) + x + 1", system: system).factor(system: system)
        let term9 = try! Expression(string: "15(x)^(5)(y)^(2) + 21(x)^(4)(y)^(2) + 6(x)^(3)(y)^(2) + 10(x)^(2)y + 14xy + 4y", system: system).factor(system: system)
        let term10 = try! Expression(string: "f(x)", system: system).factor(system: system)
        let term11 = try! Expression(string: "∫(testFunc(x),x,0,x)", system: system).factor(system: system)
        
        XCTAssert(term1.description == "2(x + 1)", term1.description)
        XCTAssert(term2.description == "3(x)^(-1)(y)^(-2)(5x + 4(y)^(2))", term2.description)
        XCTAssert(term3.description == "2(z)^(-3)(-(x)^(2) + 8xy(z)^(4) + 4y(z)^(3))", term3.description)
        XCTAssert(term4.description == "(9(a)^(2) + 6ba + 4(b)^(2))(-3a + 2b)", term4.description)
        XCTAssert(term5.description == "(3a + 4)(3a - 4)", term5.description)
        XCTAssert(term6.description == "(x + 1)^(2)", term6.description)
        XCTAssert(term7.description == "(6(x)^(2)y + 7)(3(x)^(2)y - 2)", term7.description)
        XCTAssert(term8.description == "(3(x)^(2) + 1)(x + 1)", term8.description)
        XCTAssert(term9.description == "y(3(x)^(3)y + 2)(x + 1)(5x + 2)", term9.description)
        XCTAssert(term10.description == "2", term10.description)
        XCTAssert(term11.description == "∫(testFunc(x),x,0,x)", term11.description)
        
    }
    
    func testDividing() {
        
        let expression1 = try! Expression(string: "2x+2", system: system).simplify().divide(byExpression: Expression(string: "2x+2", system: system).simplify())
        let expression2 = try! Expression(string: "3(x)^(3)+(x)^(2)+6x+2", system: system).simplify().divide(byExpression: Expression(string: "3x+1", system: system).simplify())
        let expression3 = try! Expression(string: "xy+x+y+1", system: system).simplify().divide(byExpression: Expression(string: "x+1", system: system).simplify())
        let expression4 = try! Expression(string: "z/y + zz/x + x + zy", system: system).simplify().divide(byExpression: Expression(string: "x/y + z", system: system).simplify())
        
        XCTAssert(expression1?.description == "1", expression1?.description ?? "nil")
        XCTAssert(expression2?.description == "(x)^(2) + 2", expression2?.description ?? "nil")
        XCTAssert(expression3?.description == "y + 1", expression3?.description ?? "nil")
        XCTAssert(expression4?.description == nil, expression4?.description ?? "nil")
        
    }
    
    func testExpressionAdding() {
        
        let expression1 = try! Expression(string: "x+1", system: system).add(expression: Expression(string: "x-1", system: system))
        let expression2 = try! Expression(string: "2x+2", system: system).add(expression: Expression(string: "-2x-2", system: system))
        let expression3 = try! Expression(string: "y+x+1", system: system).add(expression: Expression(string: "z+x-y", system: system))
        
        XCTAssert(expression1.description == "2x", expression1.description)
        XCTAssert(expression2.description == "0", expression2.description)
        XCTAssert(expression3.description == "2x + z + 1", expression3.description)
        
    }
    
    func testExpressionPatterns() {
        
        let expression1 = try! Expression(string: "x - 1", system: system).simplify()
        let expression2 = try! Expression(string: "-(x)^(2) + 1", system: system).simplify()
        let expression3 = try! Expression(string: "(x)^(2) - 1", system: system).simplify()
        let expression4 = try! Expression(string: "(x)^(3) - 1", system: system).simplify()
        let expression5 = try! Expression(string: "(x)^(3) + x", system: system).simplify()
        let expression6 = try! Expression(string: "(x)^(2) + x + 1", system: system).simplify()
        let expression7 = try! Expression(string: "(y)^(2) + y + 1", system: system).simplify()
        let expression8 = try! Expression(string: "(x)^(2) - xy - 2", system: system).simplify()
        let expression9 = try! Expression(string: "(x)^(4)(y)^(2) + (x)^(2)y + 1", system: system).simplify()
        let expression10 = try! Expression(string: "(x)^(2) + x + y", system: system).simplify()
        
        XCTAssert(!expression1.isDifferenceOfSquares)
        XCTAssert(expression2.isDifferenceOfSquares)
        XCTAssert(expression3.isDifferenceOfSquares)
        XCTAssert(!expression4.isDifferenceOfSquares)
        XCTAssert(!expression5.isDifferenceOfSquares)
        XCTAssert(!expression6.isDifferenceOfSquares)
        XCTAssert(!expression7.isDifferenceOfSquares)
        XCTAssert(!expression8.isDifferenceOfSquares)
        XCTAssert(!expression9.isDifferenceOfSquares)
        XCTAssert(!expression10.isDifferenceOfSquares)
        
        XCTAssert(!expression1.isSumOrDifferenceOfCubes)
        XCTAssert(!expression2.isSumOrDifferenceOfCubes)
        XCTAssert(!expression3.isSumOrDifferenceOfCubes)
        XCTAssert(expression4.isSumOrDifferenceOfCubes)
        XCTAssert(!expression5.isSumOrDifferenceOfCubes)
        XCTAssert(!expression6.isSumOrDifferenceOfCubes)
        XCTAssert(!expression7.isSumOrDifferenceOfCubes)
        XCTAssert(!expression8.isSumOrDifferenceOfCubes)
        XCTAssert(!expression9.isSumOrDifferenceOfCubes)
        XCTAssert(!expression10.isSumOrDifferenceOfCubes)
        
        XCTAssert(!expression1.isQuadraticPattern)
        XCTAssert(!expression2.isQuadraticPattern)
        XCTAssert(!expression3.isQuadraticPattern)
        XCTAssert(!expression4.isQuadraticPattern)
        XCTAssert(!expression5.isQuadraticPattern)
        XCTAssert(expression6.isQuadraticPattern)
        XCTAssert(expression7.isQuadraticPattern)
        XCTAssert(!expression8.isQuadraticPattern)
        XCTAssert(expression9.isQuadraticPattern)
        XCTAssert(!expression10.isQuadraticPattern)
        
    }
    
    func testSolving() {
        
        let solutions1 = try! Equation(string: "3x=6", system: system).solve(forVariable: system.variable(withSymbol: "x"))
        let solutions2 = try! Equation(string: "15x=-(11x+2)/x", system: system).solve(forVariable: system.variable(withSymbol: "x"))
        let solutions3 = try! Equation(string: "(x)^(2)=9", system: system).solve(forVariable: system.variable(withSymbol: "x"))
        let solutions4 = try! Equation(string: "6xxx + 3xxxy = 3xxxx + 6xxy", system: system).solve(forVariable: system.variable(withSymbol: "y"))
        let solutions5 = try! Equation(string: "xxx + xy + yyy = 1", system: system).solve(forVariable: system.variable(withSymbol: "x"))
        let solutions6 = try! Equation(string: "xx = -1", system: system).solve(forVariable: system.variable(withSymbol: "x"))
        let solutions7 = try! Equation(string: "x / x = 1", system: system).solve(forVariable: system.variable(withSymbol: "x"))
        let solutions8 = try! Equation(string: "(x + 1)/(x - 1) = 2", system: system).solve(forVariable: system.variable(withSymbol: "x"))
        let solutions9 = try! Equation(string: "1/(x+2) + 1/(x+2) = 4/((x-2)(x+2))", system: system).solve(forVariable: system.variable(withSymbol: "x"))
        let solutions10 = try! Equation(string: "(x)^(0.5) = -4", system: system).solve(forVariable: system.variable(withSymbol: "x"))
        let solutions11 = try! Equation(string: "xx+y+z=0", system: system).solve(forVariable: system.variable(withSymbol: "x"))
        let solutions12 = try! Equation(string: "xx+y+z=0", system: system).solve(forVariable: system.variable(withSymbol: "y"))
        let solutions13 = try! Equation(string: "(x)^(4) - 16 = 0", system: system).solve(forVariable: system.variable(withSymbol: "x"))
        let solutions14 = try! Equation(string: "(x)^(4) + 5(x)^(2) - 36 = 0", system: system).solve(forVariable: system.variable(withSymbol: "x"))
        let solutions15 = try! Equation(string: "(x)^(12/5) - 19(x)^(6/5) = 20", system: system).solve(forVariable: system.variable(withSymbol: "x"))

        XCTAssert(solutions1.description == "[2]", solutions1.description)
        XCTAssert(solutions2.description == "[-0.3333333333333333, -0.4]", solutions2.description)
        XCTAssert(solutions3.description == "[-3, 3]", solutions3.description)
        XCTAssert(solutions4.description == "[x]", solutions4.description)
        XCTAssert(solutions5.description == "[]", solutions5.description)
        XCTAssert(solutions6.description == "[1ⅈ, (-1ⅈ)]", solutions6.description)
        XCTAssert(solutions7.description == "[]", solutions7.description)
        XCTAssert(solutions8.description == "[3]", solutions8.description)
        XCTAssert(solutions9.description == "[4]", solutions9.description)
        XCTAssert(solutions10.description == "[16]", solutions10.description)
        XCTAssert(solutions11.description == "[(-y - z)^(0.5), -(-y - z)^(0.5)]", solutions11.description)
        XCTAssert(solutions12.description == "[-(x)^(2) - z]", solutions12.description)
        XCTAssert(solutions13.description == "[2ⅈ, (-2ⅈ), -2, 2]", solutions13.description)
        XCTAssert(solutions14.description == "[-2, 3ⅈ, (-3ⅈ), 2]", solutions14.description)
        XCTAssert(solutions15.description == "[12.139244620058346, -12.139244620058346, 1ⅈ, (-1ⅈ)]", solutions15.description)
        
    }
    
    func testSystemSolving() {
        
        let system1 = System()
        system1.equations.append(try! Equation(string: "3x+1=4", system: system1))
        let des1 = try! system1.solve(forVariable: system1.variable(withSymbol: "x")).description
        XCTAssert(des1 == "[1]", des1)
        
        let system2 = System()
        system2.equations.append(try! Equation(string: "(x + 1)(x - 1) = 0", system: system2))
        let des2 = try! system2.solve(forVariable: system2.variable(withSymbol: "x")).description
        XCTAssert(des2 == "[-1, 1]", des2)
        
        let system3 = System()
        system3.equations.append(try! Equation(string: "y=x+1", system: system3))
        system3.equations.append(try! Equation(string: "y=2x-2", system: system3))
        let des3 = try! system3.solve(forVariable: system3.variable(withSymbol: "x")).description
        XCTAssert(des3 == "[3]", des3)
        
        let system4 = System()
        system4.equations.append(try! Equation(string: "(4x + 2)(x - 1) = 0", system: system4))
        system4.equations.append(try! Equation(string: "(8x + 4)(8x - 4) = 0", system: system4))
        let des4 = try! system4.solve(forVariable: system4.variable(withSymbol: "x")).description
        XCTAssert(des4 == "[-0.5]", des4)
        
        let system5 = System()
        system5.equations.append(try! Equation(string: "(x + 1)(x - 1) = 0", system: system5))
        system5.equations.append(try! Equation(string: "x + 1 = 0", system: system5))
        let des5 = try! system5.solve(forVariable: system5.variable(withSymbol: "x")).description
        XCTAssert(des5 == "[-1]", des5)
        
        let system6 = System()
        system6.equations.append(try! Equation(string: "y = 2(x)^(2) + x + 2", system: system6))
        system6.equations.append(try! Equation(string: "y = (x)^(2) + 3x + 1", system: system6))
        let des6 = try! system6.solve(forVariable: system6.variable(withSymbol: "x")).description
        XCTAssert(des6 == "[]", des6)

        let system7 = System()
        system7.equations.append(try! Equation(string: "y = 3x + 2z", system: system7))
        system7.equations.append(try! Equation(string: "y = x + z", system: system7))
        let des7 = try! system7.solve(forVariable: system7.variable(withSymbol: "x")).description
        XCTAssert(des7 == "[]", des7)

        let system8 = System()
        system8.equations.append(try! Equation(string: "y = 5x + 2", system: system8))
        system8.equations.append(try! Equation(string: "5y + 3x = 9x + 6 - y", system: system8))
        let des8 = try! system8.solve(forVariable: system8.variable(withSymbol: "x")).description
        XCTAssert(des8 == "[-0.25]", des8)
        
        let system9 = System()
        system9.equations.append(try! Equation(string: "0 = 2(z)^(2) - 3z + 1", system: system9))
        let des9 = try! system9.solve(forVariable: system9.variable(withSymbol: "z")).description
        XCTAssert(des9 == "[0.5, 1]", des9)
        
    }
    
    func testNumber() {
        
        let frac1 = Number(double: 0.2).approximateRational.debugDescription
        let frac2 = Number(double: -0.2).approximateRational.debugDescription
        let frac3 = Number(double: 0.0).approximateRational.debugDescription
        let frac4 = Number(double: 3.5).approximateRational.debugDescription
        let frac5 = Number(double: -6.7).approximateRational.debugDescription
        
        XCTAssert(frac1 == "Optional((1, 5))", frac1)
        XCTAssert(frac2 == "Optional((1, -5))", frac2)
        XCTAssert(frac3 == "Optional((0, 1))", frac3)
        XCTAssert(frac4 == "Optional((7, 2))", frac4)
        XCTAssert(frac5 == "Optional((67, -10))", frac5)
        
        let sum1 = (Number(double: 4.0) + Number(double: 2.0)).description
        let sum2 = (Number(double: 1.0) + Number(double: 8.0)).description
        let sum3 = (Number(double: -7.0) + Number(double: 21.0)).description
        let sum4 = (Number(real: 2.0, imaginary: 3.0) + Number(real: 2.0, imaginary: 3.0)).description
        let sum5 = (Number(real: 7.0, imaginary: 4.0) + Number(real: 2.0, imaginary: 1.0)).description
        
        XCTAssert(sum1 == "6", sum1)
        XCTAssert(sum2 == "9", sum2)
        XCTAssert(sum3 == "14", sum3)
        XCTAssert(sum4 == "4+6ⅈ", sum4)
        XCTAssert(sum5 == "9+5ⅈ", sum5)
        
        let difference1 = (Number(double: 4.0) - Number(double: 2.0)).description
        let difference2 = (Number(double: 1.0) - Number(double: 8.0)).description
        let difference3 = (Number(double: -7.0) - Number(double: 21.0)).description
        let difference4 = (Number(real: 2.0, imaginary: 3.0) - Number(real: 2.0, imaginary: 3.0)).description
        let difference5 = (Number(real: 7.0, imaginary: 4.0) - Number(real: 2.0, imaginary: 1.0)).description
        
        XCTAssert(difference1 == "2", difference1)
        XCTAssert(difference2 == "-7", difference2)
        XCTAssert(difference3 == "-28", difference3)
        XCTAssert(difference4 == "0", difference4)
        XCTAssert(difference5 == "5+3ⅈ", difference5)
        
        let product1 = (Number(double: 4.0) * Number(double: 2.0)).description
        let product2 = (Number(double: 1.0) * Number(double: 8.0)).description
        let product3 = (Number(double: -7.0) * Number(double: 21.0)).description
        let product4 = (Number(real: 2.0, imaginary: 3.0) * Number(real: 2.0, imaginary: 3.0)).description
        let product5 = (Number(real: 7.0, imaginary: 4.0) * Number(real: 2.0, imaginary: 1.0)).description
        
        XCTAssert(product1 == "8", product1)
        XCTAssert(product2 == "8", product2)
        XCTAssert(product3 == "-147", product3)
        XCTAssert(product4 == "-5+12ⅈ", product4)
        XCTAssert(product5 == "10+15ⅈ", product5)
        
        let quotient1 = (Number(double: 4.0) / Number(double: 2.0)).description
        let quotient2 = (Number(double: 1.0) / Number(double: 8.0)).description
        let quotient3 = (Number(double: -7.0) / Number(double: 21.0)).description
        let quotient4 = (Number(real: 2.0, imaginary: 3.0) / Number(real: 2.0, imaginary: 3.0)).description
        let quotient5 = (Number(real: 7.0, imaginary: 4.0) / Number(real: 2.0, imaginary: 1.0)).description
        
        XCTAssert(quotient1 == "2", quotient1)
        XCTAssert(quotient2 == "0.125", quotient2)
        XCTAssert(quotient3 == "-0.3333333333333333", quotient3)
        XCTAssert(quotient4 == "1", quotient4)
        XCTAssert(quotient5 == "3.6+0.2ⅈ", quotient5)
        
        let power1 = try! (Number(double: -4.0) ^ Number(double: 0.5)).description
        let power2 = try! (Number(double: 1.0) ^ Number(double: 8.0)).description
        let power3 = try! (Number(double: -7.0) ^ Number(double: 2.0)).description
        let power4 = (try? (Number(real: 2.0, imaginary: 3.0) ^ Number(real: 2.0, imaginary: 3.0)).description) ?? "nil"
        let power5 = (try? (Number(real: 7.0, imaginary: 4.0) ^ Number(real: 2.0, imaginary: 0.0)).description) ?? "nil"
        
        XCTAssert(power1 == "2ⅈ", power1)
        XCTAssert(power2 == "1", power2)
        XCTAssert(power3 == "49", power3)
        XCTAssert(power4 == "nil", power4)
        XCTAssert(power5 == "33+56ⅈ", power5)
        
    }
    
    func testPoints() {
        
        let system = System()
        let x = system.variable(withSymbol: "x")
        
        let val01 = try! Math.findZero(of: Expression(string: "2x-1", system: system), near: Number(double: 2), withVariable: x)
        let val02 = try! Math.findZero(of: Expression(string: "cos(x)", system: system), near: Number(double: 1.5), withVariable: x)
        let val03 = try! Math.findZero(of: Expression(string: "x^2", system: system), near: Number(double: 9.32489), withVariable: x)
        
        XCTAssert(val01?.description == "0.5", val01?.description ?? "")
        XCTAssert(val02?.description == "1.5707963267943417", val02?.description ?? "")
        XCTAssert(val03?.description == "2.2232270038814686*10^(-6)", val03?.description ?? "")
        
        let val11 = try! Math.findIntersect(of: Expression(string: "3x^2", system: system), and: Expression(string: "6x", system: system), near: Number(double: 3.0), withVariable: x)
        let val12 = try! Math.findIntersect(of: Expression(string: "cos(x)", system: system), and: Expression(string: "x", system: system), near: Number(double: 0.5), withVariable: x)
        let val13 = try! Math.findIntersect(of: Expression(string: "x^3", system: system), and: Expression(string: "x^2", system: system), near: Number(double: 0.5), withVariable: x)
        
        XCTAssert(val11?.description == "2.0000000000000013", val11?.description ?? "")
        XCTAssert(val12?.description == "0.7390851332151607", val12?.description ?? "")
        XCTAssert(val13?.description == "0", val13?.description ?? "")
        
    }
    
    func testDerivatives() {
    
        let system = System()
        let x = system.variable(withSymbol: "x")
        
        let der01 = try! (Expression(string: "5x^2 + 2x - 6", system: system).derivative(inTermsOf: x, system: system) as! Expression).simplify(system: system)
        let der02 = try! (Expression(string: "(3x^2 + 2)^(1/2)", system: system).derivative(inTermsOf: x, system: system) as! Expression).simplify(system: system)
        let der03 = try! (Expression(string: "(3x)/(6x^2)", system: system).derivative(inTermsOf: x, system: system) as! Expression).simplify(system: system)
        
        XCTAssertEqual(der01.description, "10x + 2")
        XCTAssertEqual(der02.description, "3x(3(x)^(2) + 2)^(-0.5)")
        XCTAssertEqual(der03.description, "-0.5(x)^(-2)")
        
        //trig:
        
        system.angleMode = .radian
        let der04 = try! (Expression(string: "sin(x)", system: system).derivative(inTermsOf: x, system: system) as! Expression).simplify(system: system)
        let der05 = try! (Expression(string: "sin(x^2)", system: system).derivative(inTermsOf: x, system: system) as! Expression).simplify(system: system)
        system.angleMode = .degree
        let der06 = try! (Expression(string: "sin(x)", system: system).derivative(inTermsOf: x, system: system) as! Expression).simplify(system: system)
        let der07 = try! (Expression(string: "sin(x^2)", system: system).derivative(inTermsOf: x, system: system) as! Expression).simplify(system: system)
        system.angleMode = .radian
        
        XCTAssertEqual(der04.description, "cos(x)")
        XCTAssertEqual(der05.description, "2x*cos((x)^(2))")
        XCTAssertEqual(der06.description, "0.017453292519943295cos(x)")
        XCTAssertEqual(der07.description, "0.03490658503988659x*cos((x)^(2))")
        
        let der08 = try! (Expression(string: "cos(x)", system: system).derivative(inTermsOf: x, system: system) as! Expression).simplify(system: system)
        let der09 = try! (Expression(string: "cos(x^2)", system: system).derivative(inTermsOf: x, system: system) as! Expression).simplify(system: system)
        
        XCTAssertEqual(der08.description, "-sin(x)")
        XCTAssertEqual(der09.description, "-2x*sin((x)^(2))")
        
        let der10 = try! (Expression(string: "tan(x)", system: system).derivative(inTermsOf: x, system: system) as! Expression).simplify(system: system)
        let der11 = try! (Expression(string: "tan(x^2)", system: system).derivative(inTermsOf: x, system: system) as! Expression).simplify(system: system)
        
        XCTAssertEqual(der10.description, "(sec(x))^(2)")
        XCTAssertEqual(der11.description, "2x(sec((x)^(2)))^(2)")
        
        let der12 = try! (Expression(string: "csc(x)", system: system).derivative(inTermsOf: x, system: system) as! Expression).simplify(system: system)
        let der13 = try! (Expression(string: "csc(x^2)", system: system).derivative(inTermsOf: x, system: system) as! Expression).simplify(system: system)
        
        XCTAssertEqual(der12.description, "-csc(x)cot(x)")
        XCTAssertEqual(der13.description, "-2x*csc((x)^(2))cot((x)^(2))")
        
        let der14 = try! (Expression(string: "sec(x)", system: system).derivative(inTermsOf: x, system: system) as! Expression).simplify(system: system)
        let der15 = try! (Expression(string: "sec(x^2)", system: system).derivative(inTermsOf: x, system: system) as! Expression).simplify(system: system)
        
        XCTAssertEqual(der14.description, "tan(x)sec(x)")
        XCTAssertEqual(der15.description, "2x*tan((x)^(2))sec((x)^(2))")
        
        let der16 = try! (Expression(string: "cot(x)", system: system).derivative(inTermsOf: x, system: system) as! Expression).simplify(system: system)
        let der17 = try! (Expression(string: "cot(x^2)", system: system).derivative(inTermsOf: x, system: system) as! Expression).simplify(system: system)
        
        XCTAssertEqual(der16.description, "-(csc(x))^(2)")
        XCTAssertEqual(der17.description, "-2x(csc((x)^(2)))^(2)")
        
        //inverse trig:
        
        system.angleMode = .radian
        let der26 = try! (Expression(string: "asin(x)", system: system).derivative(inTermsOf: x, system: system) as! Expression).simplify(system: system)
        let der27 = try! (Expression(string: "asin(x^2)", system: system).derivative(inTermsOf: x, system: system) as! Expression).simplify(system: system)
        system.angleMode = .degree
        let der28 = try! (Expression(string: "asin(x)", system: system).derivative(inTermsOf: x, system: system) as! Expression).simplify(system: system)
        let der29 = try! (Expression(string: "asin(x^2)", system: system).derivative(inTermsOf: x, system: system) as! Expression).simplify(system: system)
        system.angleMode = .radian
        
        XCTAssertEqual(der26.description, "(-(x)^(2) + 1)^(-0.5)")
        XCTAssertEqual(der27.description, "2x(-(x)^(4) + 1)^(-0.5)")
        XCTAssertEqual(der28.description, "57.29577951308232(-(x)^(2) + 1)^(-0.5)")
        XCTAssertEqual(der29.description, "114.59155902616465x(-(x)^(4) + 1)^(-0.5)")
        
        let der30 = try! (Expression(string: "acos(x)", system: system).derivative(inTermsOf: x, system: system) as! Expression).simplify(system: system)
        let der31 = try! (Expression(string: "acos(x^2)", system: system).derivative(inTermsOf: x, system: system) as! Expression).simplify(system: system)
        
        XCTAssertEqual(der30.description, "-(-(x)^(2) + 1)^(-0.5)")
        XCTAssertEqual(der31.description, "-2x(-(x)^(4) + 1)^(-0.5)")
        
        let der32 = try! (Expression(string: "atan(x)", system: system).derivative(inTermsOf: x, system: system) as! Expression).simplify(system: system)
        let der33 = try! (Expression(string: "atan(x^2)", system: system).derivative(inTermsOf: x, system: system) as! Expression).simplify(system: system)
        
        XCTAssertEqual(der32.description, "((x)^(2) + 1)^(-1)")
        XCTAssertEqual(der33.description, "2x((x)^(4) + 1)^(-1)")
        
        let der34 = try! (Expression(string: "acsc(x)", system: system).derivative(inTermsOf: x, system: system) as! Expression).simplify(system: system)
        let der35 = try! (Expression(string: "acsc(x^2)", system: system).derivative(inTermsOf: x, system: system) as! Expression).simplify(system: system)
        
        XCTAssertEqual(der34.description, "-((x)^(2) - 1)^(-0.5)(abs(x))^(-1)")
        XCTAssertEqual(der35.description, "-2x((x)^(4) - 1)^(-0.5)(abs((x)^(2)))^(-1)")
        
        let der36 = try! (Expression(string: "asec(x)", system: system).derivative(inTermsOf: x, system: system) as! Expression).simplify(system: system)
        let der37 = try! (Expression(string: "asec(x^2)", system: system).derivative(inTermsOf: x, system: system) as! Expression).simplify(system: system)
        
        XCTAssertEqual(der36.description, "((x)^(2) - 1)^(-0.5)(abs(x))^(-1)")
        XCTAssertEqual(der37.description, "2x((x)^(4) - 1)^(-0.5)(abs((x)^(2)))^(-1)")
        
        let der38 = try! (Expression(string: "acot(x)", system: system).derivative(inTermsOf: x, system: system) as! Expression).simplify(system: system)
        let der39 = try! (Expression(string: "acot(x^2)", system: system).derivative(inTermsOf: x, system: system) as! Expression).simplify(system: system)
        
        XCTAssertEqual(der38.description, "-((x)^(2) + 1)^(-1)")
        XCTAssertEqual(der39.description, "-2x((x)^(4) + 1)^(-1)")
        
        //others:
        
        let der18 = try! (Expression(string: "ln(x)", system: system).derivative(inTermsOf: x, system: system) as! Expression).simplify(system: system)
        let der19 = try! (Expression(string: "ln(x^2)", system: system).derivative(inTermsOf: x, system: system) as! Expression).simplify(system: system)
        
        XCTAssertEqual(der18.description, "(x)^(-1)")
        XCTAssertEqual(der19.description, "2(x)^(-1)")
        
        let der20 = try! (Expression(string: "log(x, 10)", system: system).derivative(inTermsOf: x, system: system) as! Expression).simplify(system: system)
        let der21 = try! (Expression(string: "log(x^2, 10)", system: system).derivative(inTermsOf: x, system: system) as! Expression).simplify(system: system)
        
        XCTAssertEqual(der20.description, "0.43429448190325187(x)^(-1)")
        XCTAssertEqual(der21.description, "0.8685889638065037(x)^(-1)")
        
        let der22 = try! (Expression(string: "abs(x)", system: system).derivative(inTermsOf: x, system: system) as! Expression).simplify(system: system)
        let der23 = try! (Expression(string: "abs(x^2)", system: system).derivative(inTermsOf: x, system: system) as! Expression).simplify(system: system)
        
        XCTAssertEqual(der22.description, "nderiv(abs(x),x,x)")
        XCTAssertEqual(der23.description, "nderiv(abs((x)^(2)),x,x)")
        
        let der24 = try! (Expression(string: "∫(t,t,-2x,x^2)", system: system).derivative(inTermsOf: x, system: system) as! Expression).simplify(system: system)
        let der25 = try! (Expression(string: "∫(t^2,t,x^.5, ln(x))", system: system).derivative(inTermsOf: x, system: system) as! Expression).simplify(system: system)
        
        XCTAssertEqual(der24.description, "2(x)^(3) - 4x")
        XCTAssertEqual(der25.description, "-0.5(x)^(0.5) + (x)^(-1)(ln(x))^(2)")
        
        let der40 = try! Expression(string: "deriv(.5x^2 + x, x, x)", system: system).simplify()
        let der41 = try! Expression(string: "deriv(y^2, x, y)", system: system).simplify()
        
        XCTAssertEqual(der40.description, "x + 1")
        XCTAssertEqual(der41.description, "2y*nderiv(y,x,y)")
        
    }

}
