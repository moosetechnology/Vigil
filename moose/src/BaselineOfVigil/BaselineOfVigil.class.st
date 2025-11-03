Class {
	#name : 'BaselineOfVigil',
	#superclass : 'Object',
	#category : 'BaselineOfVigil',
	#package : 'BaselineOfVigil'
}

{ #category : 'baselines' }
BaselineOfVigil >> baseline: spec [

	<baseline>
	spec for: #common do: [
			spec
				package: 'Vigil-Core';
				package: 'Vigil-Core-Tests' with: [ spec requires: 'Vigil-Core' ] ]
]
