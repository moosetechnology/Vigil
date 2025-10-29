"
I'm the main class and entry point of Vigil.

"
Class {
	#name : 'Vigil',
	#superclass : 'Object',
	#instVars : [
		'vigilDirectory'
	],
	#category : 'Vigil-Core',
	#package : 'Vigil-Core'
}

{ #category : 'compiling' }
Vigil >> compileAgent [

	| command |
	"Going to the java directory"
	command := 'cd ' , vigilDirectory , '/java'.
	"Compiling the agent"
	command := command , ';./gradlew clean build'.

	^ LibC resultOfCommand: command
]

{ #category : 'initialization' }
Vigil >> initialize [

	super initialize.
	"Search for vigil repository to automatically launch java applications"
	vigilDirectory := (IceRepository repositories detect: [ :r | r name = 'Vigil' ])
		                  ifNotNil: [ :repo | repo repositoryDirectory pathString]
		                  ifNil: [ Error signal: 'Cannot find the Vigil repository' ]
]
