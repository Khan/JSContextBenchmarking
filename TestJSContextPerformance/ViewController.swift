//
//  ViewController.swift
//  TestJSContextPerformance
//
//  Created by Andy Matuschak on 8/27/14.
//  Copyright (c) 2014 Khan Academy. All rights reserved.
//

import UIKit
import JavaScriptCore

import Darwin

struct Benchmarker {
	static var t = mach_timebase_info(numer: 0, denom: 0)
	var startTime = UInt64(0)
	var duration = UInt64(0)

	var milliseconds: Double {
		return Double(duration) / 1_000_000
	}

	init() {
		if Benchmarker.t.denom == 0 {
			mach_timebase_info(&Benchmarker.t)
		}
	}

	mutating func start() {
		startTime = mach_absolute_time()
	}

	mutating func stop() {
		let delta = mach_absolute_time() - startTime
		duration = (delta * UInt64(Benchmarker.t.numer)) / UInt64(Benchmarker.t.denom)
	}
}
var benchmarker = Benchmarker()

func timeFunction(function: () -> Any) -> UInt64 {
	benchmarker.start()
	function()
	benchmarker.stop()
	return benchmarker.duration
}

func benchmarkJSFunction(JSFunction: String, action: (JSValue) -> Any) -> (evaluation: Double, execution: Double) {
	var totalEvaluationTime = UInt64(0)
	var totalExecutionTime = UInt64(0)
	let context = JSContext()
	let script = "var x = \(JSFunction); x;"
	let iterationCount = 100_000

	for i in 0..<iterationCount {
		autoreleasepool() {
			var testFunction: JSValue! = nil
			totalEvaluationTime += timeFunction() {
				testFunction = context.evaluateScript(script)
			}
			totalExecutionTime += timeFunction() {
				action(testFunction)
			}
		}
	}

	return (evaluation: Double(totalEvaluationTime) / Double(iterationCount), execution: Double(totalExecutionTime) / Double(iterationCount))
}

func printResult(result: (evaluation: Double, execution: Double)) {
	println("Evaluation: \(result.evaluation)ns\t\tExecution: \(result.execution)ns")
}


class ViewController: UIViewController {

	override func viewDidAppear(animated: Bool) {
		super.viewDidAppear(animated)
		println("Function returning constant literal:")
		printResult(benchmarkJSFunction("function() {return 3;}") { $0.callWithArguments([]) })

		println("Function returning string literal:")
		printResult(benchmarkJSFunction("function() {return \"HELLO\"}") { $0.callWithArguments([]) })

		println("Function returning object with one key (from argument):")
		printResult(benchmarkJSFunction("function(x) {return {'x': x}}") { $0.callWithArguments([3]) })

		println("Function returning object with one key (from argument) + accessing key:")
		printResult(benchmarkJSFunction("function(x) {return {'x': x}}") { $0.callWithArguments([3]).objectForKeyedSubscript("x") })

		println("Fibonacci(100):")
		printResult(benchmarkJSFunction("function(n) { var a = 0; var b = 1; for(var i = 0; i < n; i++) { var temp = b; b = a + b; a = temp; } return a; } ") { $0.callWithArguments([100]) })
	}
}

