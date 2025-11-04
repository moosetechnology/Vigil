"
A VigilTest is a test class for testing the behavior of Vigil
"
Class {
	#name : 'VigilTest',
	#superclass : 'TestCase',
	#instVars : [
		'vigil'
	],
	#category : 'Vigil-Core-Tests',
	#package : 'Vigil-Core-Tests'
}

{ #category : 'running' }
VigilTest >> setUp [

	super setUp.

	"Put here a common initialization logic for tests"
	vigil := Vigil new.
	vigil
		entryPoint: 'com.example.App';
		endChainMethod: 'com.example.App.endChain';
		appDirectory: vigil vigilDirectory;
		buildPath: '/java/build/classes/java/test'
]

{ #category : 'tests' }
VigilTest >> testCompileAgentIsSuccessful [

	self assert:
		(Vigil new compileAgent includesSubstring: 'BUILD SUCCESSFUL')
]

{ #category : 'tests' }
VigilTest >> testCorrectArgumentOnCommand [

	| command arg |
	arg := 'arg'.
	vigil addArgument: arg.
	command := vigil createCommandWith: '' asFileReference.

	self assert: (command splitOn: Character space) last equals: arg
]

{ #category : 'tests' }
VigilTest >> testDepedenciesInClasspath [

	| dep1 dep2 result |
	dep1 := 'dep1'.
	dep2 := 'dep2'.
	vigil
		addDependencies: dep1;
		addDependencies: dep2.

	result := (vigil classpathOption splitOn: $:) allButFirst.
	self assert: result first equals: '"' , dep1 , '"'.
	self assert: result second equals: '"' , dep2 , '"'
]

{ #category : 'tests' }
VigilTest >> testDiscoverStack [

	| result expected |
	result := (vigil discoverStack contents splitOn: String lf) reject: [ :line | line isEmpty ].
	expected := OrderedCollection new
		            add: 'com.example.App.endChain';
		            add: 'com.example.App.midChain';
		            add: 'com.example.App.beginChain';
		            add: 'com.example.App.main';
		            yourself.
	self assertCollection: result hasSameElements: expected
]

{ #category : 'tests' }
VigilTest >> testDiscoverStackInJDK [

	| result expected |
	"Needing a version of java between 7 and 9 because byteman 3.0.20 cannot handle newer version"
	vigil
		endChainMethod: 'java.lang.Runtime.exec';
		jdkDirectory: (JavaVersionFinder new
				 min: 7;
				 max: 9;
				 findJavaPath) pathString. 
	result := (vigil discoverStack contents splitOn: String lf) reject: [ :line | line isEmpty ].
	expected := OrderedCollection new
		            add: 'com.example.App.endChain';
		            add: 'com.example.App.midChain';
		            add: 'com.example.App.beginChain';
		            add: 'com.example.App.main';
		            add: 'java.lang.Runtime.exec';
		            yourself.
	self assertCollection: result hasSameElements: expected
]

{ #category : 'tests' }
VigilTest >> testExtractStackResistToDuplicate [

	| result expected |
	result := vigil extractStack: (OrderedCollection new
			           add: 'com.example.App.endChain';
			           add: 'com.example.App.midChain';
			           add: 'com.example.App.beginChain';
			           add: 'com.example.App.beginChain';
			           add: 'com.example.App.main';
			           yourself).
	expected := (vigil vigilDirectory , '/java/ser/App.ser') asFileReference contents.

	self assert: result equals: expected
]

{ #category : 'tests' }
VigilTest >> testExtractStackWithArgument [

	| result expected |
	result := vigil extractStack: (OrderedCollection new
			           add: 'com.example.App.endChain';
			           add: 'com.example.App.midChain';
			           add: 'com.example.App.beginChain';
			           add: 'com.example.App.main';
			           yourself).
	expected := (vigil vigilDirectory , '/java/ser/App.ser') asFileReference contents.
	
	self assert: result equals: expected
]

{ #category : 'tests' }
VigilTest >> testExtractStackWithoutArgument [

	| result expected |
	result := vigil extractStack.
	expected := (vigil vigilDirectory , '/java/ser/App.ser') asFileReference contents.
	self assert: result equals: expected
]

{ #category : 'tests' }
VigilTest >> testRuleWriteOnUseOnlyCrLf [

	| rule stream contents |
	stream := WriteStream on: ''.
	rule := BTMRuleGenerator new discoverRuleFor: 'com.example.App.endChain'.
	rule writeOn: stream.

	"Making sure the new line are in the right format for byteman parser"
	contents := stream contents splitOn: String crlf.
	contents do: [ :line |
			self assert: (line includesSubstring: String cr) not.
			self assert: (line includesSubstring: String lf) not ]
]
