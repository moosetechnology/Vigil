"
A VigilTest is a test class for testing the behavior of Vigil
"
Class {
	#name : 'VigilTest',
	#superclass : 'TestCase',
	#category : 'Vigil-Core-Tests',
	#package : 'Vigil-Core-Tests'
}

{ #category : 'tests' }
VigilTest >> testCompileAgentIsSuccessful [

	self assert:
		(Vigil new compileAgent includesSubstring: 'BUILD SUCCESSFUL')
]

{ #category : 'tests' }
VigilTest >> testDiscoverApplication [

	| vigil result expected |
	vigil := Vigil new.
	vigil
		entryPoint: 'com.example.App';
		endChainMethod: 'endChain';
		appDirectory: vigil vigilDirectory;
		buildPath: '/java/build/classes/java/test';
		jdkDirectory: 'java'.

	vigil compileAgent.
	self flag: #todo. "find a way to not compile at every test"
	result := vigil discorverApplication.

	result := (result splitOn: String lf) reject: [ :line | line isEmpty ].
	expected := OrderedCollection new
		            add: 'com.example.App.endChain';
		            add: 'com.example.App.midChain';
		            add: 'com.example.App.beginChain';
		            add: 'com.example.App.main';
		            yourself.
	self assertCollection: result hasSameElements: expected
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
