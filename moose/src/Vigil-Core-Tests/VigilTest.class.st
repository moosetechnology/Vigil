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
