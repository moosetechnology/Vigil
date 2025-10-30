"
I represent a btm rule for a method instrumentation


### Variables
| Variable | description |
|---|
| `btmName` | Name of the rule |
| `btmClass` | The class where the rule should apply |
| `btmMethod` | The method where the rule should apply |
| `btmHelper` | The helper used for analysis |
| `btmAt` | When does the rule activate |
| `btmIf` | Condition of activation of the rule (can be a method)|
| `btmDo` | What to do when the rule activate |
"
Class {
	#name : 'BTMRule',
	#superclass : 'Object',
	#instVars : [
		'instrumentedClass',
		'at',
		'action',
		'condition',
		'instrumentedMethod',
		'name',
		'helper'
	],
	#category : 'Vigil-Core',
	#package : 'Vigil-Core'
}

{ #category : 'accessing' }
BTMRule >> action [

	^ action
]

{ #category : 'accessing' }
BTMRule >> action: aString [ 
	action := aString
]

{ #category : 'accessing' }
BTMRule >> at [

	^ at
]

{ #category : 'accessing' }
BTMRule >> at: aString [ 
	at := aString
]

{ #category : 'accessing' }
BTMRule >> atEntry [

	at := 'ENTRY'
]

{ #category : 'accessing' }
BTMRule >> atExit [
	self at: 'EXIT'
]

{ #category : 'accessing' }
BTMRule >> condition [

	^ condition
]

{ #category : 'accessing' }
BTMRule >> condition: aString [ 
	condition := aString
]

{ #category : 'accessing' }
BTMRule >> helper [

	^ helper
]

{ #category : 'accessing' }
BTMRule >> helper: aString [ 
	helper := aString
]

{ #category : 'accessing' }
BTMRule >> instrumentedClass [
	
	^ instrumentedClass
]

{ #category : 'accessing' }
BTMRule >> instrumentedClass: aString [ 
	instrumentedClass := aString
]

{ #category : 'accessing' }
BTMRule >> instrumentedMethod [

	^ instrumentedMethod
]

{ #category : 'accessing' }
BTMRule >> instrumentedMethod: aString [ 
	instrumentedMethod := aString
]

{ #category : 'accessing' }
BTMRule >> name [

	^ name
]

{ #category : 'accessing' }
BTMRule >> name: aString [ 
	name := aString
]

{ #category : 'accessing' }
BTMRule >> writeActionOn: aStream [

	action ifNil: [ Error signal: 'Action not defined' ].
	^ aStream
		  nextPutAll: 'DO ';
		  nextPutAll: action;
		  crlf;
		  yourself
]

{ #category : 'accessing' }
BTMRule >> writeAtOn: aStream [

	at ifNil: [ Error signal: 'At not defined' ].
	^ aStream
		  nextPutAll: 'AT ';
		  nextPutAll: at;
		  crlf;
		  yourself
]

{ #category : 'accessing' }
BTMRule >> writeConditionOn: aStream [

	condition ifNil: [ Error signal: 'no condition defined' ].
	^ aStream
		  nextPutAll: 'IF ';
		  nextPutAll: condition;
		  crlf;
		  yourself
]

{ #category : 'accessing' }
BTMRule >> writeEndruleOn: aStream [

	^ aStream
		  nextPutAll: 'ENDRULE';
		  crlf;
		  yourself
]

{ #category : 'accessing' }
BTMRule >> writeHelperOn: aStream [

	helper ifNil: [ Error signal: 'no helper defined' ].
	^ aStream
		  nextPutAll: 'HELPER ';
		  nextPutAll: helper;
		  crlf;
		  yourself
]

{ #category : 'accessing' }
BTMRule >> writeInstumentedClassOn: aStream [

	instrumentedClass ifNil: [ Error signal: 'no instrumented class defined' ].
	^ aStream
		  nextPutAll: 'CLASS ';
		  nextPutAll: instrumentedClass;
		  crlf;
		  yourself
]

{ #category : 'accessing' }
BTMRule >> writeInstumentedMethodOn: aStream [

	instrumentedMethod ifNil: [ Error signal: 'no instrumented method defined' ].
	^ aStream
		  nextPutAll: 'METHOD ';
		  nextPutAll: instrumentedMethod;
		  crlf;
		  yourself
]

{ #category : 'accessing' }
BTMRule >> writeNameOn: aStream [

	name ifNil: [ Error signal: 'rule name not defined' ].
	^ aStream
		  nextPutAll: 'RULE ';
		  nextPutAll: name;
		  crlf;
		  yourself
]

{ #category : 'writing' }
BTMRule >> writeOn: aStream [

	"Every writeXyzOn: methods must use crlf so that the byteman parser can understand the rules"
	self
		writeNameOn: aStream;
		writeInstumentedClassOn: aStream;
		writeInstumentedMethodOn: aStream;
		writeHelperOn: aStream;
		writeAtOn: aStream;
		writeConditionOn: aStream;
		writeActionOn: aStream;
		writeEndruleOn: aStream
]
