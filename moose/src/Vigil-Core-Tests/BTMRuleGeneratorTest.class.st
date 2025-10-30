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

	self assert: rule action equals: 'discoverTargetStack();'
]

{ #category : 'tests' }
BTMRuleGeneratorTest >> testGenerateEnterStackEntryRule [

	| rule |
	rule := generator enterStackEntryRuleFor: 'com.example.App.main'.

	self assert: rule action equals: 'enterTargetStack($CLASS, $METHOD, $*);'
]

{ #category : 'tests' }
BTMRuleGeneratorTest >> testGenerateExitStackEntryRule [

	| rule |
	rule := generator enterStackExitRuleFor: 'com.example.App.main'.

	self assert: rule action equals: 'exitTargetStack();'
]

{ #category : 'tests' }
BTMRuleGeneratorTest >> testGenerateLastMethodRule [

	| rule |
	rule := generator lastMethodRuleFor: 'com.example.App.midMethod'.

	self assert: rule isConditionInTarget .
	self assert: rule action equals: 'foundTargetStack($CLASS, $METHOD, $*);'
]

{ #category : 'tests' }
BTMRuleGeneratorTest >> testGenerateMidStackEntryRule [

	| rule |
	rule := generator midStackEntryRuleFor: 'com.example.App.midMethod'.

	self assert: rule isConditionInTarget.
	self assert: rule action equals: 'enterTargetMethod($CLASS, $METHOD, $*);'
]

{ #category : 'tests' }
BTMRuleGeneratorTest >> testGenerateMidStackExitRule [

	| rule |
	rule := generator midStackExitRuleFor: 'com.example.App.midMethod'.

	self assert: rule isConditionInTarget.
	self assert: rule action equals: 'exitTargetMethod();'
]

{ #category : 'tests' }
BTMRuleGeneratorTest >> testGenerateRulesForStack [

	| stack rules |
	stack := OrderedCollection new
		         add: 'com.example.App.endChain';
		         add: 'com.example.App.midChain';
		         add: 'com.example.App.beginChain';
		         add: 'com.example.App.main';
		         yourself.
	rules := generator rulesForStack: stack.
	"Should have two rules for every stack frame, expect for the last one"
	self assert: rules size equals: stack size * 2 - 1.
	self assert: (rules select: [ :rule | rule name endsWith: '@IN' ]) size equals: 4.
	self assert: (rules select: [ :rule | rule name endsWith: '@OUT' ]) size equals: 3
]

{ #category : 'tests' }
BTMRuleGeneratorTest >> testRuleInitEntryFor [

	| rule |
	rule := generator ruleInitEntryFor: 'com.example.App.endChain'.

	self assert: rule name equals: 'com.example.App.endChain@IN'.
	self assert: rule at equals: 'ENTRY'
]

{ #category : 'tests' }
BTMRuleGeneratorTest >> testRuleInitExitFor [

	| rule |
	rule := generator ruleInitExitFor: 'com.example.App.endChain'.

	self assert: rule name equals: 'com.example.App.endChain@OUT'.
	self assert: rule at equals: 'EXIT'
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
