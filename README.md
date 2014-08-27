# JSContext Benchmark

iOS 7 shipped with an API to access the JavaScript VM outside of WebKit. This is interesting to us because we might want to use JavaScript for business logic to share across iOS, Android, web, etc.

## Results

On an iPad 3 / iOS 7.1:

```
Function returning constant literal:
Evaluation: 81565.93627ns		Execution: 43664.78665ns
Function returning string literal:
Evaluation: 82746.05486ns		Execution: 41440.88344ns
Function returning object with one key (from argument):
Evaluation: 85707.85658ns		Execution: 138649.57941ns
Function returning object with one key (from argument) + accessing key:
Evaluation: 85242.50534ns		Execution: 161120.68051ns
Fibonacci(100):
Evaluation: 86722.66728ns		Execution: 151734.33105ns
