# Vigil

Automatic instrumentation for vulnerability analysis.


## Build

Run in terminal:
```sh
./gradlew clean :spotlessApply createHelperJar copyBytemanAgent
```
- `createHelperJar` creates a fat JAR with dependencies found at ./build/libs/vigil-*version*.jar
- `copyBytemanAgent` copies the Byteman agent JAR at ./build/byteman/byteman-*version*.jar

Run tests:
```sh
./gradlew clean :spotlessApply test
```


## Usage

Add to JVM args:
```
-javaagent:/path/to/byteman.jar=script:/path/to/rule.btm,boot:/path/to/byteman.jar:/path/to/helper.jar
```

- byteman.jar is the Byteman agent JAR
- script: points to one or more comma-separated rule files (.btm files)
- boot: lets you include JAR(s) to be added to the bootstrap classpath (necessary for helper classes and their dependencies)


## Rule Definition

Rules are meant to be automatically generated.
Coming up with the most efficient rule generation pattern for a particular objective is a complex task.
A good place to begin is understanding what rules can do.
See https://downloads.jboss.org/byteman/4.0.25/byteman-programmers-guide.html#the-byteman-rule-language.
```
RULE <rule name>
CLASS <fully.qualified.ClassName>
METHOD <methodSignature>
HELPER <fully.qualified.HelperClass>
AT <locationSpecifier>
IF <conditionExpression>
DO <actionStatements>
ENDRULE
```

Built-in variables, see https://downloads.jboss.org/byteman/4.0.25/byteman-programmers-guide.html#location-specifiers.
- `$*` is an object array containing the receiver (or null if static) followed by the arguments.
- `$CLASS` is a string with the fully qualified name of the trigger class for the rule.
- `$METHOD` is a string with the full name of the trigger method into which the rule has been injected, qualified with signature and return type.

Built-in methods, see explanation at https://downloads.jboss.org/byteman/4.0.25/byteman-programmers-guide.html#built-in-calls, and their enumeration at https://downloads.jboss.org/byteman/4.0.25/byteman-programmers-guide.html#byteman-rule-language-standard-built-ins.
- `setTriggering(boolean enabled)` enables/disables rule triggering during execution of subsequent expressions in the rule body.

Rules can be applied at the sub-method level, see https://downloads.jboss.org/byteman/4.0.25/byteman-programmers-guide.html#location-specifiers.
- [`AT/AFTER INVOKE`](https://downloads.jboss.org/byteman/4.0.25/byteman-programmers-guide.html#at-invoke-after-invoke) to identify invocations of methods or constructors within the trigger method as the trigger point.


### Rule JIT Optimization

See https://developer.jboss.org/docs/DOC-17213#how_can_i_make_my_rules_run_fast and https://downloads.jboss.org/byteman/4.0.25/byteman-programmers-guide.html#built-in-calls.
Rules are written in their own language, which is interpreted by default.
In case they need to be executed many times, which can be slow, they can be JIT-compiled at the cost of a slower first execution.
Either add the rule clause `COMPILE`, or add to JVM args:
```
-Dorg.jboss.byteman.compile.to.bytecode
```


### Debugging Rules

Add to JVM args:
```
-Dorg.jboss.byteman.verbose=true
```
