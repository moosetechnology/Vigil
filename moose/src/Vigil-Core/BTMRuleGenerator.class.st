"
I am a generator of btm rule.
I offer a simple API to generalize rule generation.

### Primary interface
- discorverRuleFor:, create the rule for the discovering of an application
"
Class {
	#name : 'BTMRuleGenerator',
	#superclass : 'Object',
	#category : 'Vigil-Core',
	#package : 'Vigil-Core'
}

{ #category : 'as yet unclassified' }
BTMRuleGenerator >> discoverRuleFor: aString [

	| rule |
	rule := self ruleInitFor: aString.
	^ rule
		  atEntry;
		  condition: 'true';
		  action: 'discoverTargetStack();';
		  yourself
]

{ #category : 'as yet unclassified' }
BTMRuleGenerator >> helperName [

	^ 'org.moosetechnology.vigil.VigilHelper'
]

{ #category : 'as yet unclassified' }
BTMRuleGenerator >> ruleInitFor: aString [

	| splited class method |
	splited := aString splitOn: $..
	class := splited allButLast joinUsing: $..
	method := splited last.

	^ BTMRule new
		  name: aString;
		  instrumentedClass: class;
		  instrumentedMethod: method;
		  helper: self helperName;
		  yourself
]
