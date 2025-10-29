"
I'm the main class and entry point of Vigil.

"
Class {
	#name : 'Vigil',
	#superclass : 'Object',
	#instVars : [
		'vigilDirectory',
		'appDirectory',
		'jdkDirectory',
		'appFullName',
		'ruleGenerator',
		'endChainMethod'
	],
	#category : 'Vigil-Core',
	#package : 'Vigil-Core'
}

{ #category : 'as yet unclassified' }
Vigil >> appDirectory: aString [ 
	appDirectory := aString
]

{ #category : 'as yet unclassified' }
Vigil >> appFullName: aString [ 
	appFullName := aString
]

{ #category : 'as yet unclassified' }
Vigil >> classpathOption [

	^ '-classpath "' , appDirectory , '/java/build/classes/java/test" '
, appFullName
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
	rule := ruleGenerator discoverRuleFor: (appFullName , '.' , endChainMethod).
	"Making sure the file is empty by deleting it"
	rulePath := self rulePathFor: rule.
	self writeAll: { rule } in: rulePath.

	^ self executeApplicationDiscoveryWith: rulePath
]

{ #category : 'as yet unclassified' }
Vigil >> endChainMethod: aString [ 
	endChainMethod := aString
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
	1halt.
	^ LibC resultOfCommand: command
]

{ #category : 'initialization' }
Vigil >> initialize [

	super initialize.

	ruleGenerator := BTMRuleGenerator new.
	"Search for vigil repository to automatically launch java applications"
	vigilDirectory := (IceRepository repositories detect: [ :r | r name = 'Vigil' ])
		                  ifNotNil: [ :repo | repo repositoryDirectory pathString ]
		                  ifNil: [ Error signal: 'Cannot find the Vigil repository' ]
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
