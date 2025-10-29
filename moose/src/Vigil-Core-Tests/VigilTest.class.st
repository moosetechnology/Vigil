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

	| vigil expected |
	self flag: #todo. "here we just hard code the search of a jdk, we should find another solution"
	vigil := Vigil new.
	vigil
		appFullName: 'com.example.App';
		endChainMethod: 'endChain';
		appDirectory: vigil vigilDirectory;
		jdkDirectory: '/Library/Java/JavaVirtualMachines/jdk-24.jdk/Contents/Home/bin/java'.
	expected := String streamContents: [ :s |
			            s
				            nextPutAll: 'com.example.App.endChain';
				            cr.
			            s
				            nextPutAll: 'com.example.App.midChain';
				            cr.
			            s
				            nextPutAll: 'com.example.App.beginChain';
				            cr.
			            s nextPutAll: 'com.example.App.main' ].
	vigil compileAgent.
	self assert: vigil discorverApplication equals: expected
]
