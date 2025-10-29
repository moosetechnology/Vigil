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
BTMRule >> btmAtLine [
	btmAt ifNil: [ Error signal: 'btm at not defined' ].
	^ 'AT ', btmAt
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
BTMRule >> btmClassLine [
	btmClass ifNil: [ Error signal: 'btm class not defined' ].
	^ 'CLASS ', btmClass
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
BTMRule >> btmEndruleLine [

	^ 'ENDRULE'
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
BTMRule >> btmHelperLine [
	btmHelper ifNil: [ Error signal: 'btm Helper not defined' ].
	^ 'HELPER ', btmHelper
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
BTMRule >> btmIfLine [
	btmIf ifNil: [ Error signal: 'btm if not defined' ].
	^ 'IF ', btmIf
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
BTMRule >> btmMethodLine [
	btmMethod ifNil: [ Error signal: 'btm method not defined' ].
	^ 'METHOD ', btmMethod
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
BTMRule >> btmNameLine [
	btmName ifNil: [ Error signal: 'btm name not defined' ].
	^ 'RULE ', btmName
]

{ #category : 'writing' }
BTMRule >> writeOn: aStream [

	aStream
		nextPutAll: self btmNameLine;
		cr;
		nextPutAll: self btmClassLine;
		cr;
		nextPutAll: self btmMethodLine;
		cr;
		nextPutAll: self btmHelperLine;
		cr;
		nextPutAll: self btmAtLine;
		cr;
		nextPutAll: self btmIfLine;
		cr;
		nextPutAll: self btmDoLine;
		cr;
		nextPutAll: self btmEndruleLine
]
