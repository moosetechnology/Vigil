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
BTMRuleTest >> testWriteActionOn [

	| stream |
	stream := WriteStream with: ''.
	rule action: 'test'.

	self assert: ((rule writeActionOn: stream) contents copyUpTo: Character space) equals: 'DO'
]

{ #category : 'tests' }
BTMRuleTest >> testWriteActionOnRaiseErrorWhenNotDefined [

	self should: [ rule writeActionOn: (WriteStream with: '') ] raise: Error
]

{ #category : 'tests' }
BTMRuleTest >> testWriteAtOn [

	| stream |
	stream := WriteStream with: ''.
	rule at: 'test'.

	self assert: ((rule writeAtOn: stream) contents copyUpTo: Character space) equals: 'AT'
]

{ #category : 'tests' }
BTMRuleTest >> testWriteAtOnRaiseErrorWhenNotDefined [

	self should: [ rule writeAtOn: (WriteStream with: '') ] raise: Error
]

{ #category : 'tests' }
BTMRuleTest >> testWriteConditionOn [

	| stream |
	stream := WriteStream with: ''.
	rule condition: 'test'.

	self assert: ((rule writeConditionOn: stream) contents copyUpTo: Character space) equals: 'IF'
]

{ #category : 'tests' }
BTMRuleTest >> testWriteConditionOnRaiseErrorWhenNotDefined [

	self should: [ rule writeConditionOn: (WriteStream with: '') ] raise: Error
]

{ #category : 'tests' }
BTMRuleTest >> testWriteEndruleOn [

	| stream |
	stream := WriteStream with: ''.

	self assert: ((rule writeEndruleOn: stream) contents copyUpTo: Character space) equals: 'ENDRULE'
]

{ #category : 'tests' }
BTMRuleTest >> testWriteHelperOn [

	| stream |
	stream := WriteStream with: ''.
	rule helper: 'test'.

	self assert: ((rule writeHelperOn: stream) contents copyUpTo: Character space) equals: 'HELPER'
]

{ #category : 'tests' }
BTMRuleTest >> testWriteHelperOnRaiseErrorWhenNotDefined [

	self should: [ rule writeHelperOn: (WriteStream with: '') ] raise: Error
]

{ #category : 'tests' }
BTMRuleTest >> testWriteInstrumentedClassOn [

	| stream |
	stream := WriteStream with: ''.
	rule instrumentedClass: 'test'.

	self assert: ((rule writeInstumentedClassOn: stream) contents copyUpTo: Character space) equals: 'CLASS'
]

{ #category : 'tests' }
BTMRuleTest >> testWriteInstrumentedClassOnRaiseErrorWhenNotDefined [

	self should: [ rule writeInstumentedClassOn: (WriteStream with: '') ] raise: Error
]

{ #category : 'tests' }
BTMRuleTest >> testWriteInstumentedMethodOn [

	| stream |
	stream := WriteStream with: ''.
	rule instrumentedMethod: 'test'.

	self assert: ((rule writeInstumentedMethodOn: stream) contents copyUpTo: Character space) equals: 'METHOD'
]

{ #category : 'tests' }
BTMRuleTest >> testWriteMethodOnRaiseErrorWhenNotDefined [

	self should: [ rule writeInstumentedMethodOn: (WriteStream with: '') ] raise: Error
]

{ #category : 'tests' }
BTMRuleTest >> testWriteNameOn [

	| stream |
	stream := WriteStream with: ''.
	rule name: 'test'.

	self assert: ((rule writeNameOn: stream) contents copyUpTo: Character space) equals: 'RULE'
]

{ #category : 'tests' }
BTMRuleTest >> testWriteNameOnRaiseErrorWhenNotDefined [

	self should: [ rule writeNameOn: (WriteStream with: '') ] raise: Error
]
