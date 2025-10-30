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

	self assert: rule at equals: 'ENTRY'.
	self assert: rule action equals: 'discoverTargetStack();'
]

{ #category : 'tests' }
BTMRuleGeneratorTest >> testGenerateEnterStackEntryRule [

	| rule |
	rule := generator enterStackEntryRuleFor: 'com.example.App.main'.

	self assert: rule name equals: 'com.example.App.main@IN'.
	self assert: rule at equals: 'ENTRY'.
	self assert: rule action equals: 'enterTargetStack($CLASS, $METHOD, $*);'
]

{ #category : 'tests' }
BTMRuleGeneratorTest >> testGenerateExitStackEntryRule [

	| rule |
	rule := generator enterStackExitRuleFor: 'com.example.App.main'.

	self assert: rule name equals: 'com.example.App.main@OUT'.
	self assert: rule at equals: 'EXIT'.
	self assert: rule action equals: 'exitTargetStack();'
]

{ #category : 'tests' }
BTMRuleGeneratorTest >> testRuleInitFor [

	| rule |
	rule := generator ruleInitFor: 'com.example.App.endChain'.

	self assert: rule name equals: 'com.example.App.endChain'.
	self assert: rule instrumentedClass equals: 'com.example.App'.
	self assert: rule instrumentedMethod equals: 'endChain'.
	self assert: rule helper equals: 'org.moosetechnology.vigil.VigilHelper'.
	self assert: rule condition equals: 'true'
]
