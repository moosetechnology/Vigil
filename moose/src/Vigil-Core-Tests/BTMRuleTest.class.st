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
BTMRuleTest >> testWriteBtmAtOn [

	| stream |
	stream := WriteStream with: ''.
	rule btmAt: 'test'.

	self assert: ((rule writeBtmAtOn: stream) contents copyUpTo: Character space) equals: 'AT'
]

{ #category : 'tests' }
BTMRuleTest >> testWriteBtmClassOn [

	| stream |
	stream := WriteStream with: ''.
	rule btmClass: 'test'.

	self assert: ((rule writeBtmClassOn: stream) contents copyUpTo: Character space) equals: 'CLASS'
]

{ #category : 'tests' }
BTMRuleTest >> testWriteBtmDoOn [

	| stream |
	stream := WriteStream with: ''.
	rule btmDo: 'test'.

	self assert: ((rule writeBtmDoOn: stream) contents copyUpTo: Character space) equals: 'DO'
]

{ #category : 'tests' }
BTMRuleTest >> testWriteBtmEndruleOn [

	| stream |
	stream := WriteStream with: ''.

	self assert: ((rule writeBtmEndruleOn: stream) contents copyUpTo: Character space) equals: 'ENDRULE'
]

{ #category : 'tests' }
BTMRuleTest >> testWriteBtmHelperOn [

	| stream |
	stream := WriteStream with: ''.
	rule btmHelper: 'test'.

	self assert: ((rule writeBtmHelperOn: stream) contents copyUpTo: Character space) equals: 'HELPER'
]

{ #category : 'tests' }
BTMRuleTest >> testWriteBtmIfOn [

	| stream |
	stream := WriteStream with: ''.
	rule btmIf: 'test'.

	self assert: ((rule writeBtmIfOn: stream) contents copyUpTo: Character space) equals: 'IF'
]

{ #category : 'tests' }
BTMRuleTest >> testWriteBtmMethodOn [

	| stream |
	stream := WriteStream with: ''.
	rule btmMethod: 'test'.

	self assert: ((rule writeBtmMethodOn: stream) contents copyUpTo: Character space) equals: 'METHOD'
]

{ #category : 'tests' }
BTMRuleTest >> testWriteBtmNameOn [

	| stream |
	stream := WriteStream with: ''.
	rule btmName: 'test'.

	self assert: ((rule writeBtmNameOn: stream) contents copyUpTo: Character space) equals: 'RULE'
]

{ #category : 'tests' }
BTMRuleTest >> testwriteBtmAtOnRaiseErrorWhenNotDefined [

	self should: [ rule writeBtmAtOn: (WriteStream with: '') ] raise: Error
]

{ #category : 'tests' }
BTMRuleTest >> testwriteBtmClassOnRaiseErrorWhenNotDefined [

	self should: [ rule writeBtmClassOn: (WriteStream with: '') ] raise: Error
]

{ #category : 'tests' }
BTMRuleTest >> testwriteBtmDoOnRaiseErrorWhenNotDefined [

	self should: [ rule writeBtmDoOn: (WriteStream with: '') ] raise: Error
]

{ #category : 'tests' }
BTMRuleTest >> testwriteBtmHelperOnRaiseErrorWhenNotDefined [

	self should: [ rule writeBtmHelperOn: (WriteStream with: '') ] raise: Error
]

{ #category : 'tests' }
BTMRuleTest >> testwriteBtmIfOnRaiseErrorWhenNotDefined [

	self should: [ rule writeBtmIfOn: (WriteStream with: '') ] raise: Error
]

{ #category : 'tests' }
BTMRuleTest >> testwriteBtmMethodOnRaiseErrorWhenNotDefined [

	self should: [ rule writeBtmMethodOn: (WriteStream with: '') ] raise: Error
]

{ #category : 'tests' }
BTMRuleTest >> testwriteBtmNameOnRaiseErrorWhenNotDefined [

	self should: [ rule writeBtmNameOn: (WriteStream with: '') ] raise: Error
]
