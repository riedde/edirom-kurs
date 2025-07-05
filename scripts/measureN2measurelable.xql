xquery version "3.0";

(:  generate, copy/update @n and @lable of <measure/> 

    This is to be used in oXygen XML editor with Saxon-EE.
    nbeer, 2018-03-28 :)

declare namespace mei="http://www.music-encoding.org/ns/mei";

let $sourceURI := '../data/essUser00/edirom_source_47dde5ab-b8ff-4004-bfde-b65ea5a9a15e.xml'
let $doc := doc($sourceURI)

for $measure in $doc//mei:mdiv//mei:measure
let $label := $measure/@n

let $n := if (contains($measure/@n, "'")) then (concat('2', format-number(number(substring-before($measure/@n, "'")), '00'))) else(concat('1', format-number($measure/@n, '00')))
return

(:replace value of node $measure/@n with $n:)
(:    update value $measure/@n with $n :)
    insert nodes (attribute label {$label}) as last into $measure
    
    
