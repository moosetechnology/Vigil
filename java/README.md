## Build

Run in terminal:
```sh
./gradlew clean build
```
This builds the agent JAR with dependencies found at `./build/libs/vigil-agent-*version*.jar`.


## Usage

Add to JVM args:
> -javaagent:***/path/to/vigil-agent.jar***=script:***/path/to/rule.btm***
- `vigil-agent.jar` is the JAR built by this project
- script points to one or more comma-separated rule files (.btm)

Optionally define a file to output Vigil data:
> -Dorg.moosetechnology.vigil.output=***/path/to/output/file***


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


### Debugging

Add the following JVM args to help with debugging rule lifecycle and Vigil execution:
```
-Dorg.jboss.byteman.verbose=true
-Dorg.jboss.byteman.debug
```
