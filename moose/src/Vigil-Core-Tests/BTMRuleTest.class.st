"
A BTMRuleTest is a test class for testing the behavior of BTMRule
"
Class {
	#name : 'BTMRuleTest',
	#superclass : 'TestCase',
	#instVars : [
		'rule'
	],
	#category : 'Vigil-Core-Tests',
	#package : 'Vigil-Core-Tests'
}

{ #category : 'running' }
BTMRuleTest >> setUp [

	super setUp.

	rule := BTMRule new
]

{ #category : 'tests' }
BTMRuleTest >> testBtmAtLinePrefix [

	rule btmAt: 'test'.
	self assert: (rule btmAtLine copyUpTo: Character space) equals: 'AT'
]

{ #category : 'tests' }
BTMRuleTest >> testBtmAtLineThrowErrorWhenNotDefined [

	self should: [rule btmAtLine] raise: Error
]

{ #category : 'tests' }
BTMRuleTest >> testBtmClassLinePrefix [

	rule btmClass: 'test'.
	self
		assert: (rule btmClassLine copyUpTo: Character space) 
		equals: 'CLASS'
]

{ #category : 'tests' }
BTMRuleTest >> testBtmClassLineThrowErrorWhenNotDefined [

	self should: [rule btmClassLine] raise: Error
]

{ #category : 'tests' }
BTMRuleTest >> testBtmDoLinePrefix [

	rule btmDo: 'test'.
	self
		assert: (rule btmDoLine copyUpTo: Character space) 
		equals: 'DO'
]

{ #category : 'tests' }
BTMRuleTest >> testBtmDoLineThrowErrorWhenNotDefined [

	self should: [rule btmDoLine] raise: Error
]

{ #category : 'tests' }
BTMRuleTest >> testBtmEndruleLine [

	self
		assert: rule btmEndruleLine
		equals: 'ENDRULE'
]

{ #category : 'tests' }
BTMRuleTest >> testBtmHelperLinePrefix [

	rule btmHelper: 'test'.
	self
		assert: (rule btmHelperLine copyUpTo: Character space) 
		equals: 'HELPER'
]

{ #category : 'tests' }
BTMRuleTest >> testBtmHelperLineThrowErrorWhenNotDefined [

	self should: [rule btmHelperLine] raise: Error
]

{ #category : 'tests' }
BTMRuleTest >> testBtmIfLinePrefix [

	rule btmIf: 'test'.
	self
		assert: (rule btmIfLine copyUpTo: Character space) 
		equals: 'IF'
]

{ #category : 'tests' }
BTMRuleTest >> testBtmIfLineThrowErrorWhenNotDefined [

	self should: [rule btmIfLine] raise: Error
]

{ #category : 'tests' }
BTMRuleTest >> testBtmMethodLinePrefix [

	rule btmMethod: 'test'.
	self
		assert: (rule btmMethodLine copyUpTo: Character space) 
		equals: 'METHOD'
]

{ #category : 'tests' }
BTMRuleTest >> testBtmMethodLineThrowErrorWhenNotDefined [

	self should: [rule btmMethodLine] raise: Error
]

{ #category : 'tests' }
BTMRuleTest >> testBtmNameLinePrefix [

	rule btmName: 'test'.
	self
		assert: (rule btmNameLine copyUpTo: Character space) 
		equals: 'RULE'
]

{ #category : 'tests' }
BTMRuleTest >> testBtmNameLineThrowErrorWhenNotDefined [

	self should: [rule btmNameLine] raise: Error
]
