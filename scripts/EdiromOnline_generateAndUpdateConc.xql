xquery version "1.0";
(: 
    @author Nikolaos Beer
    @author Benjamin W. Bohl
    @author Dennis Ried
:)

declare default element namespace "http://www.edirom.de/ns/1.3";

declare namespace mei = "http://www.music-encoding.org/ns/mei";
declare namespace xlink = "http://www.w3.org/1999/xlink";
declare namespace functx = "http://www.functx.com";

declare function functx:escape-for-regex
($arg as xs:string?) as xs:string {
    
    replace($arg,
    '(\.|\[|\]|\\|\||\-|\^|\$|\?|\*|\+|\{|\}|\(|\))', '\\$1')
};

declare function functx:substring-after-last
($arg as xs:string?,
$delim as xs:string) as xs:string {
    
    replace($arg, concat('^.*', functx:escape-for-regex($delim)), '')
};

let $users := ('00')


for $user in $users

let $editionDoc := doc(concat('../data/essUser',$user,'/essEdiromEdition_',$user,'.xml'))

for $work in $editionDoc//work


let $workID := $work/@xml:id/fn:string()
let $workDoc := collection(concat('../data/essUser',$user,'/'))//mei:mei[@xml:id=$workID]


let $workNavSourceColl := doc(concat('../data/essUser',$user,'/essEdiromEdition_',$user,'.xml'))//work[./@xml:id = $workID]//navigatorCategory//navigatorItem[contains(@targets, 'edirom_source_') or contains(@targets, 'edirom_edition_')]

let $sourceColl := for $source in $workNavSourceColl
            let $sourceID := substring-before(functx:substring-after-last($source/@targets/fn:string(), '/'), '.xml')
            return
                collection(concat('../data/essUser',$user,'/'))//mei:mei[@xml:id = $sourceID]


let $workSources := $sourceColl//mei:manifestation[.//mei:relation/@target[contains(., concat($workID, '.xml#', $workID, '_exp1'))]]/root()/mei:mei

let $referenceSource := $workSources//mei:manifestation[@type='ed' and contains(.//mei:relation/@target, concat($workID, '.xml#', $workID, '_exp1'))]/root()/mei:mei

let $plistPrefix := concat('xmldb:exist:///db/apps/essEdiromData/data/essUser',$user,'/')

let $concFileName := concat('ediromMusicConc_essUser',$user,'_', $workID, '.xml')

let $concordance := element concordance {
    attribute name {"Edition"},
    element names {
        element name {
            attribute xml:lang {'de'}, 'Edition'
        },
        element name {
            attribute xml:lang {'en'}, 'Edition'
        }
    },
    element groups {
        attribute label {"Song"},
        element names {
            element name {
                attribute xml:lang {'de'}, 'Lied'
            },
            element name {
                attribute xml:lang {'en'}, 'Song'
            }
        },
        for $mdiv at $n in $referenceSource//mei:mdiv
(:        where $n = 11:)
        return
            element group {
                element names {
                    element name {
                        attribute xml:lang {'de'}, string($mdiv/@label)
                    },
                    element name {
                        attribute xml:lang {'en'},
                        if (contains($mdiv/@label, 'Nr.'))
                        then
                            concat('No. ', substring-after(string($mdiv/@label), 'Nr. '))
                        else
                            (string($mdiv/@label))
                    }
                },
                
                 element connections{
                                                attribute label {"Takt"},
                                                for $measure in $mdiv//mei:measure
                                                order by number($measure/@n)
                                                return
                                                    element connection{
                                                        attribute name {if ($measure/@label) then ($measure/@label) else ($measure/@n)},
                                                        attribute plist {
                                                            for $match in $sourceColl//mei:measure[ancestor::mei:mdiv[contains(@label, $mdiv/@label) and ./*[not(self::mei:parts)]] and @n = $measure/@n]
                                                            let $matchID := $match/@xml:id
                                                            let $sourceID := $match/ancestor::mei:mei/@xml:id
                                                            (:let $sourceTypeCollectionName := if ( $match/root()//mei:sourceDesc/mei:source/mei:classification/text() = 'MusPr')
                                                            then ('prints')
                                                            else if ( $match/root()//mei:sourceDesc/mei:source/mei:classification/text() = 'MusMs')
                                                            then ('manuscripts')
                                                            else if ( $match/root()//mei:sourceDesc/mei:source/mei:classification/text() = 'MusEd')
                                                            then ('editions/II_07')
                                                            else ():)
                                                            return concat($plistPrefix,$sourceID,'.xml#',$matchID)
                                                            (:,
                                                            for $matchPart in $sourceColl//mei:part[1]//mei:measure[ancestor::mei:mdiv[contains(@label, $mdiv/@label) and ./*[self::mei:parts]] and @n = $measure/@n]
                                                            (\:let $matchIDPart := $matchPart/@xml:id:\)
                                                            let $matchPartmdivID := $matchPart/ancestor::mei:mdiv/@xml:id
                                                            let $matchPartMeasureNo := $matchPart/@n
                                                            let $sourceIDPart := $matchPart/ancestor::mei:mei/@xml:id
                                                            let $sourceTypeCollectionName := if ( $matchPart/root()//mei:sourceDesc/mei:source/mei:classification/text() = 'MusPr')
                                                            then ('prints')
                                                            else if ( $matchPart/root()//mei:sourceDesc/mei:source/mei:classification/text() = 'MusMs')
                                                            then ('manuscripts')
                                                            else if ( $matchPart/root()//mei:sourceDesc/mei:source/mei:classification/text() = 'MusEd')
                                                            then ('editions')
                                                            else ()
                                                            return concat($plistPrefix,$sourceTypeCollectionName,'/',$sourceIDPart,'.xml#measure_',$matchPartmdivID,'_',$matchPartMeasureNo):) (: Fehler bei $matchPartmdivID :)
                                                        }
                                                    }
                                            }
            } 
    }
}


return
(:    $concordance:)
    replace node $editionDoc//work[@xml:id = $workID]/concordances//concordance[1] with $concordance
    
    (:xmldb:store('xmldb:exist:///db/contents/edition-rwa/resources/xml/concs/rwaVol_II-8/', $concFileName, $concordance):)