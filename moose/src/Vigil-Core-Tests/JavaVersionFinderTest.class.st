Class {
	#name : 'JavaVersionFinderTest',
	#superclass : 'TestCase',
	#instVars : [
		'vigil',
		'finder'
	],
	#category : 'Vigil-Core-Tests',
	#package : 'Vigil-Core-Tests'
}

{ #category : 'running' }
JavaVersionFinderTest >> setUp [

	super setUp.

	"Put here a common initialization logic for tests"
	finder := JavaVersionFinder new
]

{ #category : 'tests' }
JavaVersionFinderTest >> testJvmDirectoryExists [
	
	self assert: finder jvmDirectory exists
]
