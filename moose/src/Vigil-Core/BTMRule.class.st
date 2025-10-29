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
		'btmName',
		'btmClass',
		'btmMethod',
		'btmHelper',
		'btmAt',
		'btmIf',
		'btmDo'
	],
	#category : 'Vigil-Core',
	#package : 'Vigil-Core'
}

{ #category : 'accessing' }
BTMRule >> btmAt [

	^ btmAt
]

{ #category : 'accessing' }
BTMRule >> btmAt: aString [ 
	btmAt := aString
]

{ #category : 'accessing' }
BTMRule >> btmAtEntry [

	btmAt := 'ENTRY'
]

{ #category : 'accessing' }
BTMRule >> btmClass [
	
	^ btmClass
]

{ #category : 'accessing' }
BTMRule >> btmClass: aString [ 
	btmClass := aString
]

{ #category : 'accessing' }
BTMRule >> btmDo [

	^ btmDo
]

{ #category : 'accessing' }
BTMRule >> btmDo: aString [ 
	btmDo := aString
]

{ #category : 'accessing' }
BTMRule >> btmDoLine [
	btmDo ifNil: [ Error signal: 'btm do not defined' ].
	^ 'DO ', btmDo
]

{ #category : 'accessing' }
BTMRule >> btmHelper [

	^ btmHelper
]

{ #category : 'accessing' }
BTMRule >> btmHelper: aString [ 
	btmHelper := aString
]

{ #category : 'accessing' }
BTMRule >> btmIf [

	^ btmIf
]

{ #category : 'accessing' }
BTMRule >> btmIf: aString [ 
	btmIf := aString
]

{ #category : 'accessing' }
BTMRule >> btmMethod [

	^ btmMethod
]

{ #category : 'accessing' }
BTMRule >> btmMethod: aString [ 
	btmMethod := aString
]

{ #category : 'accessing' }
BTMRule >> btmName [

	^ btmName
]

{ #category : 'accessing' }
BTMRule >> btmName: aString [ 
	btmName := aString
]

{ #category : 'accessing' }
BTMRule >> writeBtmAtOn: aStream [

	btmAt ifNil: [ Error signal: 'btm at not defined' ].
	^ aStream
		  nextPutAll: 'AT ';
		  nextPutAll: btmAt;
		  cr;
		  yourself
]

{ #category : 'accessing' }
BTMRule >> writeBtmClassOn: aStream [

	btmClass ifNil: [ Error signal: 'btm class not defined' ].
	^ aStream
		  nextPutAll: 'CLASS ';
		  nextPutAll: btmClass;
		  cr;
		  yourself
]

{ #category : 'accessing' }
BTMRule >> writeBtmDoOn: aStream [

	btmDo ifNil: [ Error signal: 'btm do not defined' ].
	^ aStream
		  nextPutAll: 'DO ';
		  nextPutAll: btmDo;
		  cr;
		  yourself
]

{ #category : 'accessing' }
BTMRule >> writeBtmEndruleOn:aStream [

	^ aStream
		  nextPutAll: 'ENDRULE';
		  yourself
]

{ #category : 'accessing' }
BTMRule >> writeBtmHelperOn: aStream [

	btmHelper ifNil: [ Error signal: 'btm helper not defined' ].
	^ aStream
		  nextPutAll: 'HELPER ';
		  nextPutAll: btmHelper;
		  cr;
		  yourself
]

{ #category : 'accessing' }
BTMRule >> writeBtmIfOn: aStream [

	btmIf ifNil: [ Error signal: 'btm if not defined' ].
	^ aStream
		  nextPutAll: 'IF ';
		  nextPutAll: btmIf;
		  cr;
		  yourself
]

{ #category : 'accessing' }
BTMRule >> writeBtmMethodOn: aStream [

	btmMethod ifNil: [ Error signal: 'btm method not defined' ].
	^ aStream
		  nextPutAll: 'METHOD ';
		  nextPutAll: btmMethod;
		  cr;
		  yourself
]

{ #category : 'accessing' }
BTMRule >> writeBtmNameOn: aStream [

	btmName ifNil: [ Error signal: 'btm name not defined' ].
	^ aStream
		  nextPutAll: 'RULE ';
		  nextPutAll: btmName;
		  cr;
		  yourself
]

{ #category : 'writing' }
BTMRule >> writeOn: aStream [

	self
		writeBtmNameOn: aStream;
		writeBtmClassOn: aStream;
		writeBtmMethodOn: aStream;
		writeBtmHelperOn: aStream;
		writeBtmAtOn: aStream;
		writeBtmIfOn: aStream;
		writeBtmDoOn: aStream;
		writeBtmEndruleOn: aStream
]
