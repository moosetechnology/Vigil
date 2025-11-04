"
Find a jdk with a java version between `min` and `max`

## Usage
```
JavaVersionFinder new
	min: 7; ""version minimum of java""
	max: 9; ""version maximum of java""
	findJavaPath
```
"
Class {
	#name : 'JavaVersionFinder',
	#superclass : 'Object',
	#instVars : [
		'min',
		'max'
	],
	#category : 'Vigil-Core',
	#package : 'Vigil-Core'
}

{ #category : 'as yet unclassified' }
JavaVersionFinder >> findJavaPath [

	| paths version |
	paths := self possibleJavaPathsIn: self jvmDirectory.

	paths do: [ :path |
			(self isValidJavaExecutable: path) ifTrue: [
					version := self getJavaVersion: path.
					(self isVersionInRange: version) ifTrue: [ ^ path ] ] ].
	Error signal: 'No java version found between ' , min asString , ' and ' , max asString
]

{ #category : 'as yet unclassified' }
JavaVersionFinder >> getJavaVersion: aJavaPath [
	"Extract the version number"

	| output versionLine versionString |
	output := Smalltalk os resultOfCommand: aJavaPath pathString , ' -version 2>&1'.

	"Find the line with 'java version"
	versionLine := output lines detect: [ :line | line includesSubstring: 'java version' ]. 
	"Extract version between quotation marks" 
	versionString := (versionLine splitOn: $") second. 
	^ self parseVersionString: versionString
]

{ #category : 'as yet unclassified' }
JavaVersionFinder >> isValidJavaExecutable: aPath [

	| result |
	result := Smalltalk os resultOfCommand: aPath pathString , ' -version 2>&1'.
	^ result notNil and: [ result includesSubstring: 'java version' ]
]

{ #category : 'as yet unclassified' }
JavaVersionFinder >> isVersionInRange: anInteger [

	^ anInteger between: min and: max
]

{ #category : 'as yet unclassified' }
JavaVersionFinder >> jvmDirectory [

	^ '/Library/Java/JavaVirtualMachines/' asFileLocatorOrReference
]

{ #category : 'as yet unclassified' }
JavaVersionFinder >> max: anInteger [ 
	max := anInteger
]

{ #category : 'as yet unclassified' }
JavaVersionFinder >> min: anInteger [ 
	min := anInteger
]

{ #category : 'as yet unclassified' }
JavaVersionFinder >> parseVersionString: aString [

	| versionCol |
	versionCol := (aString splitOn: $.) collect: #asNumber.
	versionCol first = 1
		ifTrue: [ ^ versionCol second ]
		ifFalse: [ ^ versionCol first ]
]

{ #category : 'as yet unclassified' }
JavaVersionFinder >> possibleJavaPathsIn: aDirectory [
	
	^ aDirectory children
		  collect: [ :path | (path / self relativeJavaPath ) asFileReference ]
		  thenSelect: [ :path | path exists ]
]

{ #category : 'as yet unclassified' }
JavaVersionFinder >> relativeJavaPath [

	^ 'Contents/Home/bin/java' 
]
