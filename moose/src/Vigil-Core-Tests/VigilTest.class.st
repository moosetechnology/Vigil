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

	| vigil |
	self flag: #todo. "here we just hard code the search of a jdk, we should find another solution"
	vigil := Vigil new.
	vigil
		appFullName: 'com.example.App';
		endChainMethod: 'endChain';
		appDirectory: vigil vigilDirectory;
		buildPath: '/java/build/classes/java/test';
		jdkDirectory: 'java'.

	vigil compileAgent.
	self assert: vigil discorverApplication equals: 'com.example.App.endChain
com.example.App.midChain
com.example.App.beginChain
com.example.App.main'
]
