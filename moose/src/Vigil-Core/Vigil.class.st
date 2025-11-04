"
I'm the main class and entry point of Vigil.

### Exemple of use
```
vigil
		entryPoint: 'com.example.App'; ""Full name needed""
		endChainMethod: 'com.example.App.endMethod'; ""Fully qualified method name""
		appDirectory: '/path/to/app/directory'; ""Directory to the app""
		buildPath: '/path/to/compiled/classes'; ""Relative path from the app directory to the compiled classes folder""
		jdkDirectory: '/path/to/jdk/contents/home/bin/java'. ""Directory to the jdk used in to launch the app (Default: java)""
```
"
Class {
	#name : 'Vigil',
	#superclass : 'Object',
	#instVars : [
		'vigilDirectory',
		'appDirectory',
		'jdkDirectory',
		'ruleGenerator',
		'endChainMethod',
		'buildPath',
		'entryPoint',
		'dependencies',
		'arguments'
	],
	#category : 'Vigil-Core',
	#package : 'Vigil-Core'
}

{ #category : 'accessing' }
Vigil >> addArgument: aString [

	arguments add: aString
]

{ #category : 'accessing' }
Vigil >> addDependencies: aString [

	dependencies add: aString
]

{ #category : 'accessing' }
Vigil >> appDirectory: aString [ 
	appDirectory := aString
]

{ #category : 'accessing' }
Vigil >> buildPath: aString [ 
	buildPath := aString
]

{ #category : 'util' }
Vigil >> classpathOption [

	| stream |
	stream := WriteStream on: ''.
	stream
		nextPutAll: '-classpath "';
		nextPutAll: appDirectory;
		nextPutAll: buildPath;
		nextPutAll: '"'.
	dependencies do: [ :dep |
			stream
				nextPut: $:;
				nextPut: $";
				nextPutAll: dep;
				nextPut: $" ].
	^ stream contents
]

{ #category : 'execution' }
Vigil >> compileAgent [

	| command |
	"Going to the java directory"
	command := 'cd "' , vigilDirectory , '/java"'.
	"Compiling the agent"
	command := command , ';./gradlew clean build'.

	^ Smalltalk os resultOfCommand: command
]

{ #category : 'util' }
Vigil >> createCommandWith: aPath [

	| stream |
	stream := WriteStream on: ''.
	"Use the selected jdk"
	stream nextPutAll: jdkDirectory.
	"Adding the agent"
	stream
		space;
		nextPutAll: (self javaAgentOptionFor: aPath).
	"Allowing byteman to instrument all method"
	stream
		space;
		nextPutAll: '-Dorg.jboss.byteman.transform.all=true'.

	"Setting the classpath"
	stream
		space;
		nextPutAll: self classpathOption.
	"Adding application"
	stream
		space;
		nextPutAll: entryPoint.
	"Adding arguments"
	arguments do: [ :arg |
			stream
				space;
				nextPutAll: arg ].
	
	^ stream contents
]

{ #category : 'accessing' }
Vigil >> dependencies: aString [

	dependencies := aString
]

{ #category : 'execution' }
Vigil >> discoverStack [

	| rule rulePath |
	rule := ruleGenerator discoverRuleFor: endChainMethod.
	"Making sure the file is empty by deleting it"
	rulePath := self generateRulePathFor: rule.
	self writeAll: { rule } in: rulePath.

	^ self executeApplicationWith: rulePath
]

{ #category : 'accessing' }
Vigil >> endChainMethod: aString [ 
	endChainMethod := aString
]

{ #category : 'accessing' }
Vigil >> entryPoint: aString [ 
	entryPoint := aString
]

{ #category : 'execution' }
Vigil >> executeApplicationWith: aPath [
	
	^ Smalltalk os resultOfCommand: (self createCommandWith: aPath)
]

{ #category : 'execution' }
Vigil >> extractStack [

	| stack |
	stack := (self discoverStack splitOn: String lf) reject: [ :line | line isEmpty ].
	^ self extractStack: stack
]

{ #category : 'execution' }
Vigil >> extractStack: aCollection [

	| rules rulesPath |
	rules := ruleGenerator rulesForStack: aCollection.
	rulesPath := self generateRulePathFor: rules.
	self writeAll: rules in: rulesPath.
	
	"Removing the suffix is important for both test and future parsing"
	^ (self executeApplicationWith: rulesPath) removeSuffix: String lf
]

{ #category : 'util' }
Vigil >> generateRulePathFor: aRule [

	^ FileReference newTempFilePrefix: 'rule' suffix: 'btm'
]

{ #category : 'initialization' }
Vigil >> initialize [

	super initialize.

	ruleGenerator := BTMRuleGenerator new.
	"Search for vigil repository to automatically launch java applications"
	vigilDirectory := (IceRepository repositories detect: [ :r | r name = 'Vigil' ])
		                  ifNotNil: [ :repo | repo repositoryDirectory pathString ]
		                  ifNil: [ Error signal: 'Cannot find the Vigil repository' ].
	jdkDirectory := 'java'.
	dependencies := OrderedCollection new.
	arguments := OrderedCollection new
]

{ #category : 'util' }
Vigil >> javaAgentOptionFor: aPath [
	|agent|
	agent := '"', vigilDirectory , '/java/build/libs/vigil-agent-1.0.jar"'.
	"Need to use the agentm both as the agentm and on boot, to be able to instrument jdk"
	^ '-javaagent:' , agent , '=boot:', agent ,',script:"' , aPath pathString, '"'
]

{ #category : 'accessing' }
Vigil >> jdkDirectory: aString [ 
	jdkDirectory := aString
]

{ #category : 'accessing' }
Vigil >> vigilDirectory [
	^ vigilDirectory
]

{ #category : 'writing' }
Vigil >> writeAll: aCollection in: aPathReference [

	aPathReference asFileReference ensureCreateFile writeStreamDo: [ :stream | aCollection do: [ :rule | rule writeOn: stream ] ]
]
