"
I'm the main class and entry point of Vigil.

### Exemple of use
```
vigil
		entryPoint: 'com.example.App'; ""Full name needed""
		endChainMethod: 'endMethod'; ""Can use the signature of the method""
		appDirectory: '/path/to/app/directory'; ""Directory to the app""
		buildPath: '/path/to/compiled/classes'; ""Relative path from the app directory to the compiled classes folder""
		jdkDirectory: '/path/to/jdk/contents/home/bin/java'. ""Directory to the jdk used in to launch the app""
```

### Variables
| Variable | description |
|---|
| `appDirectory` | The directory of the app to instrument (To define) |
| `endChainMethod` | The last method of the call stack (To define) |
| `buildPath` | relative path from the compiled classes (To define) |
| `entryPoint` | The full name of the class launching the application (To define) |
| `jdkDirectory` | The directory to the jdk used to launch the instrumented app (Initialize at 'java', using the $JAVA_HOME) |
| `vigilDirectory` | The directory where vigil is (Automatically found) |
| `ruleGenerator` | The generator of rule |
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
		'entryPoint'
	],
	#category : 'Vigil-Core',
	#package : 'Vigil-Core'
}

{ #category : 'as yet unclassified' }
Vigil >> appDirectory: aString [ 
	appDirectory := aString
]

{ #category : 'as yet unclassified' }
Vigil >> buildPath: aString [ 
	buildPath := aString
]

{ #category : 'as yet unclassified' }
Vigil >> classpathOption [

	^ '-classpath "' , appDirectory , buildPath , '" ' , entryPoint
]

{ #category : 'compiling' }
Vigil >> compileAgent [

	| command |
	"Going to the java directory"
	command := 'cd "' , vigilDirectory , '/java"'.
	"Compiling the agent"
	command := command , ';./gradlew clean build'.

	^ LibC resultOfCommand: command
]

{ #category : 'compiling' }
Vigil >> discorverApplication [

	| rule rulePath|
	rule := ruleGenerator discoverRuleFor: (entryPoint , '.' , endChainMethod).
	"Making sure the file is empty by deleting it"
	rulePath := self rulePathFor: rule.
	self writeAll: { rule } in: rulePath.

	^ self executeApplicationDiscoveryWith: rulePath
]

{ #category : 'as yet unclassified' }
Vigil >> endChainMethod: aString [ 
	endChainMethod := aString
]

{ #category : 'as yet unclassified' }
Vigil >> entryPoint: aString [ 
	entryPoint := aString
]

{ #category : 'compiling' }
Vigil >> executeApplicationDiscoveryWith: aPath [

	| command |
	"Use the selected jdk"
	command := jdkDirectory.
	"Adding the agent"
	command := command , ' ' , (self javaAgentOptionFor: aPath).
	"Setting the classpath"
	command := command , ' ' , self classpathOption.
	
	^ LibC resultOfCommand: command
]

{ #category : 'initialization' }
Vigil >> initialize [

	super initialize.

	ruleGenerator := BTMRuleGenerator new.
	"Search for vigil repository to automatically launch java applications"
	vigilDirectory := (IceRepository repositories detect: [ :r | r name = 'Vigil' ])
		                  ifNotNil: [ :repo | repo repositoryDirectory pathString ]
		                  ifNil: [ Error signal: 'Cannot find the Vigil repository' ].
	jdkDirectory := 'java'
]

{ #category : 'compiling' }
Vigil >> javaAgentOptionFor: aPath [

	^ '-javaagent:"' , vigilDirectory , '/java/build/libs/vigil-agent-1.0.jar"=script:"' , aPath pathString, '"'
]

{ #category : 'as yet unclassified' }
Vigil >> jdkDirectory: aString [ 
	jdkDirectory := aString
]

{ #category : 'compiling' }
Vigil >> rulePathFor: aRule [

	^ FileReference newTempFilePrefix: 'rule' suffix: 'btm'
]

{ #category : 'as yet unclassified' }
Vigil >> vigilDirectory [
	^ vigilDirectory
]

{ #category : 'compiling' }
Vigil >> writeAll: aCollection in: aPathReference [

	aPathReference asFileReference ensureCreateFile writeStreamDo: [ :stream | aCollection do: [ :rule | rule writeOn: stream ] ]
]
