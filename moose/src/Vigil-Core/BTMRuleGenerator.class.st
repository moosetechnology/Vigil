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
	rule := self ruleInitEntryFor: aString.
	^ rule
		  action: 'discoverTargetStack();';
		  yourself
]

{ #category : 'as yet unclassified' }
BTMRuleGenerator >> enterStackEntryRuleFor: aString [

	| rule |
	rule := self ruleInitEntryFor: aString.
	^ rule action: 'enterTargetStack($CLASS, $METHOD, $*);'
]

{ #category : 'as yet unclassified' }
BTMRuleGenerator >> enterStackExitRuleFor: aString [

	| rule |
	rule := self ruleInitExitFor: aString.
	^ rule
		  action: 'exitTargetStack();';
		  yourself
]

{ #category : 'as yet unclassified' }
BTMRuleGenerator >> helperName [

	^ 'org.moosetechnology.vigil.VigilHelper'
]

{ #category : 'as yet unclassified' }
BTMRuleGenerator >> lastMethodRuleFor: aString [

	| rule |
	rule := self ruleInitEntryFor: aString.
	^ rule
		  conditionInTarget;
		  action: 'foundTargetStack($CLASS, $METHOD, $*);';
		  yourself
]

{ #category : 'as yet unclassified' }
BTMRuleGenerator >> midStackEntryRuleFor: aString [

	| rule |
	rule := self ruleInitEntryFor: aString.
	^ rule conditionInTarget;
		  action: 'enterTargetMethod($CLASS, $METHOD, $*);';
		  yourself
]

{ #category : 'as yet unclassified' }
BTMRuleGenerator >> midStackExitRuleFor: aString [

	| rule |
	rule := self ruleInitExitFor: aString.
	^ rule
		  conditionInTarget;
		  action: 'exitTargetMethod();';
		  yourself
]

{ #category : 'as yet unclassified' }
BTMRuleGenerator >> ruleInitEntryFor: aString [

	| rule |
	rule := self ruleInitFor: aString.
	^ rule
		  atEntry;
		  name: rule name , '@IN'
]

{ #category : 'as yet unclassified' }
BTMRuleGenerator >> ruleInitExitFor: aString [

	| rule |
	rule := self ruleInitFor: aString.
	^ rule
		  atExit;
		  name: rule name , '@OUT'
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
		  condition: 'true';
		  yourself
]

{ #category : 'as yet unclassified' }
BTMRuleGenerator >> rulesForStack: aCollection [

	| rules entry mids last |
	entry := aCollection last.
	last := aCollection first.
	mids := aCollection allButLast allButFirst.
	rules := OrderedCollection new.
	rules
		add: (self enterStackEntryRuleFor: entry);
		add: (self enterStackExitRuleFor: entry).
	rules add: (self lastMethodRuleFor: entry).
	mids do: [ :frame |
			rules
				add: (self midStackEntryRuleFor: frame);
				add: (self midStackExitRuleFor: frame) ].
	^ rules
]
