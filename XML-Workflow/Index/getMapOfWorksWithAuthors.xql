xquery version "3.1";

declare namespace tei="http://www.tei-c.org/ns/1.0";
declare namespace map="http://www.w3.org/2005/xpath-functions/map";
declare namespace output = "http://www.w3.org/2010/xslt-xquery-serialization";
declare option output:method "json";

let $registry-persons := doc("../../../documents/Schoenberg-UE/data/Indices/Personen.xml")//tei:TEI
let $registry-works := doc("../../../documents/Schoenberg-UE/data/Indices/Werke.xml")//tei:TEI

(: Zunächst werden alle Personen aus dem Personenregister ausgelesen und in die Datenstruktur aufgenommen :)

let $persons := for $person in $registry-persons//tei:person
                    let $id := $person/@xml:id/data()
                    let $regName := if ($person/tei:persName[@type = 'reg']/tei:surname/text() or $person/tei:persName[@type = 'reg']/tei:forename/text()) then $person/tei:persName[@type = 'reg'] else $person/tei:persName[@type = 'alt'][1]
                    let $forename := $regName//tei:forename/data()
                    let $surname := $regName//tei:surname/data()
                    let $nameLink := $regName//tei:nameLink/data()
                    let $birthdate := substring($person/tei:birth/tei:date/@when, 1, 4)
                    let $deathdate := substring($person/tei:death/tei:date/@when, 1, 4)
                    let $completeName := (if ($nameLink != '')
                                         then (   if (ends-with($nameLink, '&#8217;'))
                                                  then ($nameLink || $surname || ', ' || $forename)
                                                  else ($surname || ', ' || $forename || ' ' || $nameLink))
                                        else (    if ($surname != '')
                                                  then ($surname || (if ($forename != '') then (', ' || $forename) else ''))
                                                  else ( if ($forename != '') then $forename else $regName/data())))
                                                  ||
                                           (if ($birthdate != '' or $deathdate != '')
                                            then (' (' || (if ($birthdate != '') then $birthdate else '?') || '–' || (if ($deathdate != '') then $deathdate else '?') || ')')
                                            else ())
                                              (:string-join($surname, " ") || (if ($surname != "" and $forename != "") then ", " || string-join($forename, " ") else ()) || (if ($nameLink != "") then " " || $nameLink else ()):)
                    let $altnames := if (($person/tei:persName[@type = 'reg']/tei:surname/text() or $person/tei:persName[@type = 'reg']/tei:forename/text()) and $person/tei:persName[@type = 'alt'])
                                     then (for $name in $person/tei:persName[@type = 'alt'][not(@subtype = 'referencemark')]
                                            let $type := if ($name/@subtype) then $name/@subtype/data() else "other"
                                            let $forename := $name/tei:forename
                                            let $surname := $name/tei:surname
                                            let $nameLink := $name/tei:nameLink
                                            (:return map:entry($type, $surname || (if ($surname != "" and $forename != "") then ", " || $forename else ()))):)
                                            return <altName type="{$type}">{ $surname || (if ($surname != "" and $forename != "") then ", " || $forename else ()) || (if ($nameLink != '') then $nameLink else ()) }</altName>
                                            )
                                     else ()
                    return  <entry key="{$id}">
                                <persName>{$completeName}</persName>
                                {if ($altnames != '') then <altNames>{$altnames}</altNames> else ()}
                            </entry>

(: Jetzt loop über alle Einträge im Werkregister :)

let $allWorks := $registry-works//tei:listBibl[@type = "artwork"]/tei:bibl
(:let $musicalWorks := $allWorks[starts-with(@xml:id, 'werke')]
let $writings := $allWorks[starts-with(@xml:id, 'schriften')]:)

let $personsWithWorks := for $work in $allWorks
                            let $id := $work/@xml:id/data()
                            let $type := if (starts-with($id, 'werke') and $work/@type = 'arrangement') then 'Bearbeitung' else (if (starts-with($id, 'werke')) then 'Komposition' else 'Schrift') 
                            let $title := $work/tei:title/normalize-space()
                            let $subtitle := if ($type eq 'Bearbeitung') then $work/tei:note/tei:bibl[not(@*)][1]/tei:title/normalize-space() else ()
                            let $authors := if ($type eq 'Komposition') then ($work/tei:author[@role = 'composition']) else if ($type eq 'Bearbeitung') then ($work/tei:author[@role = ('arrangement', 'composition')]) else $work/tei:author[@role eq 'text']
                            (: else if ($type eq 'Bearbeitung') then ($work/tei:author[@role = ('composition', 'arrangement')]) => soll zum Beispiel Schönberg op. 11/2 konzertmäßige Interpretation durch Busoni auch in Eintrag Schönberg auftauchen? :)
                            let $result := for $author in $authors
                                                let $authorName := $author/tei:persName
                                                let $forename := $authorName//tei:forename/data()
                                                let $surname := $authorName//tei:surname/data()
                                                let $nameLink := $authorName//tei:nameLink/data()
                                                let $completeName := if ($nameLink != '')
                                         then (   if (ends-with($nameLink, '&#8217;'))
                                                  then ($nameLink || $surname || ', ' || $forename)
                                                  else ($surname || ', ' || $forename || ' ' || $nameLink))
                                        else (    if ($surname != '')
                                                  then ($surname || (if ($forename != '') then (', ' || $forename) else ''))
                                                  else (if ($forename != '') then $forename else ('unbekannt' || index-of($allWorks, $work)))
                                                  )
                                                let $arrangers := $work/tei:author[@role = 'arrangement']/tei:persName
                                                let $composers := $work/tei:author[@role = 'composition']/tei:persName
                                                let $arrName := for $arr in $arrangers
                                                                    let $name := if ($arr/tei:forename/data() != '' and $arr/tei:surname/data() != '') then ((if ($arr/tei:forename/data() != '') then ($arr/tei:forename/data() || ' ') else ()) || $arr/tei:surname/data()) else ('unbekannt')
                                                                    return $name
                                                let $compName := for $comp in $composers
                                                                    let $name := if ($comp/tei:forename/data() != '' and $comp/tei:surname/data() != '') then ((if ($comp/tei:forename/data() != '') then ($comp/tei:forename/data() || ' ') else ()) || $comp/tei:surname/data()) else ('unbekannt')
                                                                    return $name
                                                let $authorId := if ($author/tei:persName/@key) then $author/tei:persName/@key else (replace($completeName, ' ', '')) (: 'ohneId_' || index-of($allWorks, $work) :)
                                                let $arrId := if ($work/tei:author[@role = 'arrangement']/tei:persName/@key) then $work/tei:author[@role = 'arrangement']/tei:persName/@key else (replace($arrName, ' ', ''))
                                                let $workRef := substring-after($work/tei:ref[@type eq 'partOf']/@target, '#')
                                                return  <entry key="{$authorId}">
                                                            { if (not($author/tei:persName/@key)) then (<persName>{$completeName}</persName>) else () }
                                                            { if ($type eq 'Komposition') then (
                                                                <work key="{$id}">{$title}</work>) else () }
                                                            { if ($type eq 'Bearbeitung') then (
                                                                if ($author/@role eq 'arrangement')
                                                                (: Eintrag der Bearbeitung unter dem Bearbeiter => wird immer unter "Bearbeitungen" eingruppiert :)
                                                                then <arrangement key="{$id}">{$title || " von " || string-join($compName, ' und ') || (if ($subtitle != '') then (" (" || $subtitle || ")") else ())}</arrangement>
                                                                (: Eintrag der Bearbeitung unter dem Komponisten :)
                                                                else (if ($authorId eq $arrId)
                                                                        (: Wird bei Eigenbearbeitungen unter der Kategorie "Bearbeitungen" geführt :)
                                                                        then <arrangement key="{$id}">{$title || " (" || (if ($subtitle ne "") then $subtitle else "Bearbeitung") || ")"}</arrangement>
                                                                        (: ansonsten unter der Kategorie "Musikalische Werke" :)
                                                                        else <work key="{$id}" ref="{$workRef}">{$title || " (" || (if ($subtitle ne "") then $subtitle else "Bearbeitung") || " von " || string-join($arrName, ' und ') || ")"}</work>
                                                                      )
                                                              ) else () }
                                                            { if ($type eq 'Schrift') then (<writing key="{$id}">{$title}</writing>) else () }
                                                        </entry>
                            return $result
let $personsWithWorksGrouped := for $entry in $personsWithWorks
                                    let $authorId := $entry/@key
                                    group by $authorId
                                    return <entry key="{$authorId}">
                                                { if ($entry/persName) then $entry/persName[1] else () }
                                                { if ($entry/work) then <works>{for $work in $entry/work[not(starts-with(@ref/data(), 'werke'))]
                                                                                    let $workId := $work/@key/data()
                                                                                    let $title := $work/text()
                                                                                    return if ($entry/work[@ref eq $workId])
                                                                                    then (<work key="{$workId}"><title>{$title}</title>{for $subentry in $entry/work[@ref eq $workId] return $subentry}</work>)
                                                                                    else($work)}</works> else () }
                                                { if ($entry/arrangement) then <arrangements>{$entry/arrangement}</arrangements> else () }
                                                { if ($entry/writing) then <writings>{$entry/writing}</writings> else () }
                                            </entry>
let $mergeAllEntries := for $entry in ($persons, $personsWithWorksGrouped)
                            let $authorId := $entry/@key
                            group by $authorId
                            return  <entry key="{$authorId}">
                                        {$entry/persName[1]}
                                        {$entry/altNames}
                                        {$entry/works}
                                        {$entry/arrangements}
                                        {$entry/writings}
                                    </entry>


(:return <result  count="{count($personsWithWorksGrouped)}"
                withkey="{count($personsWithWorksGrouped[starts-with(@key, 'pers')])}">{$personsWithWorksGrouped}</result>:)
                
(:return <result count="{count($mergeAllEntries)}">{$mergeAllEntries}</result>:)

let $resultAsJsonMap := for $entry in $mergeAllEntries
        return map {
            $entry/@key: map {
                "persName": $entry/persName/text(),
                "altNames": map:merge(if ($entry/altNames) then (for $altname in $entry//altName return map:entry($altname/@type, $altname/text())) else ()),
                "works": map:merge(if ($entry/works) then (for $work in $entry/works/work return if ($work/title)
                                                                                            then (map:entry($work/@key, map:merge(map {"title": $work/title/text(), "related": map:merge(for $subentry in $work/work return map:entry($subentry/@key, $subentry/text()))})))
                                                                                            else (map:entry($work/@key, $work/text())))
                                                     else ()),
                "arrangements": map:merge(if ($entry/arrangements) then (for $arr in $entry//arrangement return map:entry($arr/@key, $arr/text())) else ()),
                "writings": map:merge(if ($entry/writings) then (for $writing in $entry//writing return map:entry($writing/@key, $writing/text())) else ())
            }
        }
        
return map:merge($resultAsJsonMap)
        
(:return map {
            "count": count($personsWithWorks),
            "list": map:merge($personsWithWorks, map{"duplicates":"combine"}) }:)
(:return serialize(map {"result": $personsWithWorks }, map { 'method':'json'})
:)(:let $works := for $work in $musicalWorks[not(@type = 'arrangement')][tei:author[@role = 'composition']/tei:persName/@key/data() = $id]
                                    let $id := $work/@xml:id/data()
                                    let $title := $work/tei:title/normalize-space()
                                    return map:entry($id, $title)
                    let $arrangements := for $arr in $musicalWorks[@type = 'arrangement'][tei:author[@role = 'arrangement']/tei:persName/@key/data() = $id]
                                            let $id := $arr/@xml:id/data()
                                            let $title := $arr/tei:title/normalize-space() || ". " || $arr/tei:note/tei:bibl[not(@*)][1]/tei:title/normalize-space()
                                            return map:entry($id, $title)
                    let $writings := for $writing in $writings[tei:author[@role = 'text']/tei:persName/@key/data() = $id]
                                            let $id := $writing/@xml:id/data()
                                            let $title := $writing/tei:title/normalize-space()
                                            return map:entry($id, $title)
let $personsWithWorks := for $work in 
                                     
                                     
                    
                    
                    return map{$id: map {
                                    "persName": $completeName,
                                    "altNames": map:merge(($altnames)),
                                    "works": map:merge(($works)),
                                    "arrangements": map:merge(($arrangements)),
                                    "writings": map:merge(($writings))
                                    }
                              }
                    (\:map:entry($id, $completeName):\)
return map:merge(($persons)):)

(:let $persons := for $person in $registry-persons//tei:listBibl[@type = "artwork"]/tei:bibl
                    let $id := $person/@xml:id/data()
                    let $regName := if ($person/tei:persName[@type = 'reg']) then $person/tei:persName[@type = 'reg'] else $person/tei:persName[@type = 'alt']
                    let $forename := $regName//tei:forename
                    let $surname := $regName//tei:surname
                    let $nameLink := $regName//tei:nameLink
                    let $completeName := string-join($surname, " ") || (if ($surname != "" and $forename != "") then ", " || string-join($forename, " ") else ()) || (if ($nameLink != "") then " " || $nameLink else ())
                    return map:entry($id, $completeName)
return map:merge(($persons)):)

(:let $works := for $work in $registry-works//tei:listBibl[@type = "artwork"]/tei:bibl
                    let $id := $work/@xml:id/data()
                    let $type := if ($work/starts-with(@xml:id, "schriften")) then "Schriften" else if ($work/@type = "arrangement") then "Bearbeitungen" else "Werke"
                    let $title := if ($type = "Bearbeitungen") then $work/tei:title/normalize-space() || ". " || $work/tei:note/tei:bibl[not(@*)][1]/tei:title/normalize-space() else $work/tei:title/normalize-space()
                    let $authorIds := if ($type = "Bearbeitungen") then $work/tei:author[@role = 'arrangement']/tei:persName/@key/data()
                                        else if ($type = "Werke") then $work/tei:author[@role = 'composition']/tei:persName/@key/data()
                                        else if ($type = "Schriften") then $work/tei:author[@role = 'text']/tei:persName/@key/data()
                                        else ("Error: Cannot find author Id")
                    let $authors := for $authorId in $authorIds 
                                        let $authorName := $registry-persons//id($authorId)
                                        let $regName := if ($authorName/tei:persName[@type = 'reg']) then $authorName/tei:persName[@type = 'reg'] else $authorName/tei:persName[@type = 'alt']
                                        let $forename := $regName//tei:forename
                                        let $surname := $regName//tei:surname
                                        let $nameLink := $regName//tei:nameLink
                                        let $completeName := string-join($surname, " ") || (if ($surname != "" and $forename != "") then ", " || string-join($forename, " ") else ()) || (if ($nameLink != "") then " " || $nameLink else ())
                                        return map:entry($authorId, $completeName)
                    return map{$id: map {
                                    "title": $title,
                                    "type": $type,
                                    "authors": map:merge(($authors))
                                    }
                              }
return map:merge(($works)):)