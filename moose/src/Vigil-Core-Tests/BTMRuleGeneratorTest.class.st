"
A RuleGeneratorTest is a test class for testing the behavior of RuleGenerator
"
Class {
	#name : 'BTMRuleGeneratorTest',
	#superclass : 'TestCase',
	#instVars : [
		'generator'
	],
	#category : 'Vigil-Core-Tests',
	#package : 'Vigil-Core-Tests'
}

{ #category : 'running' }
BTMRuleGeneratorTest >> setUp [

	super setUp.
	generator := BTMRuleGenerator new
]

{ #category : 'tests' }
BTMRuleGeneratorTest >> testGenerateDiscoverRule [

	| rule |
	rule := generator discoverRuleFor: 'com.example.App.endChain'.

	self assert: rule btmAt equals: 'ENTRY'.
	self assert: rule btmIf equals: 'true'.
	self assert: rule btmDo equals: 'discoverTargetStack();'
]

{ #category : 'tests' }
BTMRuleGeneratorTest >> testRuleInitFor [

	| rule |
	rule := generator ruleInitFor: 'com.example.App.endChain'.

	self assert: rule btmName equals: 'com.example.App.endChain'.
	self assert: rule btmClass equals: 'com.example.App'.
	self assert: rule btmMethod equals: 'endChain'.
	self
		assert: rule btmHelper
		equals: 'org.moosetechnology.vigil.VigilHelper'
]
