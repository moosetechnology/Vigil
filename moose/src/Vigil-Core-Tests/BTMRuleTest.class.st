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
	self
		assert: (rule btmAtLine splitOn: Character space) first
		equals: 'AT'
]

{ #category : 'tests' }
BTMRuleTest >> testBtmAtLineThrowErrorWhenNotDefined [

	self should: [rule btmAtLine] raise: Error
]

{ #category : 'tests' }
BTMRuleTest >> testBtmClassLinePrefix [

	rule btmClass: 'test'.
	self
		assert: (rule btmClassLine splitOn: Character space) first
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
		assert: (rule btmDoLine splitOn: Character space) first
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
		assert: (rule btmHelperLine splitOn: Character space) first
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
		assert: (rule btmIfLine splitOn: Character space) first
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
		assert: (rule btmMethodLine splitOn: Character space) first
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
		assert: (rule btmNameLine splitOn: Character space) first
		equals: 'RULE'
]

{ #category : 'tests' }
BTMRuleTest >> testBtmNameLineThrowErrorWhenNotDefined [

	self should: [rule btmNameLine] raise: Error
]
