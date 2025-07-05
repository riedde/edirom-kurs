xquery version "3.0";
(:
    ESS2020, dried, 2020
    >>>Skript muss lokal ausgeführt werden.<<<
    Oxygen-Preferences: Update 'on'; Tree 'linked'; Backup 'on'
:)

declare default element namespace "http://www.music-encoding.org/ns/mei";

let $docWithMeasuresToInsert := doc('../../TrueberAbschiedEdition.mei')


let $docToUpdate := doc('../data/essUser00/edirom_edition_7bade454-c1b2-499f-8100-7b3e369e2d65.xml')

let $oldMeasures := $docToUpdate//measure
let $newMeasures := $docWithMeasuresToInsert//measure

let $scoreDefOld := $docToUpdate//scoreDef
let $scoreDefNew := $docWithMeasuresToInsert//scoreDef


return
	(
       	replace node $scoreDefOld with $scoreDefNew,
       	
       	for $i in 1 to count($newMeasures)
       		let $measuresToInsert := $newMeasures[$i]/node()
       		return
           		insert nodes $measuresToInsert as last into $oldMeasures[$i]
    )
    		
