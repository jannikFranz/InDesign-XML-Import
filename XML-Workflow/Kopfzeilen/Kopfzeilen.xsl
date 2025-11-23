<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    xmlns:tei="http://www.tei-c.org/ns/1.0"
    xmlns:aid="http://ns.adobe.com/AdobeInDesign/4.0/"
    xmlns:local="lokal"
    xmlns:map="http://www.w3.org/2005/xpath-functions/map"
    exclude-result-prefixes="xs tei local"
    version="2.0">
    
    <xsl:output method="xml" encoding="UTF-8" media-type="text/xml" indent="no" omit-xml-declaration="no"/>
    
    <xsl:variable name="letterNumbers" as="item()">
        <xsl:variable name="mapping" as="item()+">
            <xsl:for-each select="collection()//tei:TEI[not(@type eq 'lost')]">
                <xsl:sort select="local:getSortingCriteria(.)"/>
                <xsl:variable name="id" select="@xml:id/string()" as="xs:string"/>
                <xsl:sequence select="map { $id: position() }"/>
                </xsl:for-each>
        </xsl:variable>
        <!--<xsl:value-of select="map:merge($mapping)"/>-->
        <xsl:sequence select="map:merge($mapping)"/>
    </xsl:variable>
    
    <!-- ########################################################################################################################################################################################################################## -->
                                                                                                            <!-- Functions -->
    <!-- ########################################################################################################################################################################################################################## -->
    <xsl:function name="local:getSortingCriteria">
        <xsl:param name="contextItem"/>
        <xsl:choose>
            <xsl:when test="$contextItem//tei:correspDesc/tei:correspAction[@type = 'sent']/tei:date/@when">
                <xsl:value-of select="$contextItem//tei:correspDesc/tei:correspAction[@type = 'sent']/tei:date/@when"/>
            </xsl:when>
            <xsl:when test="$contextItem//tei:correspDesc/tei:correspAction[@type = 'sent']/tei:date/@notBefore">
                <xsl:value-of select="$contextItem//tei:correspDesc/tei:correspAction[@type = 'sent']/tei:date/@notBefore"/>
            </xsl:when>
            <xsl:when test="$contextItem//tei:correspDesc/tei:correspAction[@type = 'sent']/tei:date/@notAfter">
                <xsl:value-of select="$contextItem//tei:correspDesc/tei:correspAction[@type = 'sent']/tei:date/@notAfter"/>
            </xsl:when>
            <xsl:when test="$contextItem//tei:correspDesc/tei:correspAction[@type = 'sent']/tei:date/@from">
                <xsl:value-of select="$contextItem//tei:correspDesc/tei:correspAction[@type = 'sent']/tei:date/@from"/>
            </xsl:when>
            <xsl:when test="$contextItem//tei:correspDesc/tei:correspAction[@type = 'received']/tei:date/@when">
                <xsl:value-of select="$contextItem//tei:correspDesc/tei:correspAction[@type = 'received']/tei:date/@when"/>
            </xsl:when>
            <xsl:when test="$contextItem//tei:correspDesc/tei:correspAction[@type = 'received']/tei:date/@notBefore">
                <xsl:value-of select="$contextItem//tei:correspDesc/tei:correspAction[@type = 'received']/tei:date/@notBefore"/>
            </xsl:when>
            <xsl:when test="$contextItem//tei:correspDesc/tei:correspAction[@type = 'received']/tei:date/@notAfter">
                <xsl:value-of select="$contextItem//tei:correspDesc/tei:correspAction[@type = 'received']/tei:date/@notAfter"/>
            </xsl:when>
            <xsl:when test="$contextItem//tei:correspDesc/tei:correspAction[@type = 'received']/tei:date/@from">
                <xsl:value-of select="$contextItem//tei:correspDesc/tei:correspAction[@type = 'received']/tei:date/@from"/>
            </xsl:when>
        </xsl:choose>
    </xsl:function>
    
    <xsl:function name="local:getMonth" as="xs:string">
        <xsl:param name="number" as="xs:integer"/>
        <xsl:choose>
            <xsl:when test="$number eq 1">Januar</xsl:when>
            <xsl:when test="$number eq 2">Februar</xsl:when>
            <xsl:when test="$number eq 3">März</xsl:when>
            <xsl:when test="$number eq 4">April</xsl:when>
            <xsl:when test="$number eq 5">Mai</xsl:when>
            <xsl:when test="$number eq 6">Juni</xsl:when>
            <xsl:when test="$number eq 7">Juli</xsl:when>
            <xsl:when test="$number eq 8">August</xsl:when>
            <xsl:when test="$number eq 9">September</xsl:when>
            <xsl:when test="$number eq 10">Oktober</xsl:when>
            <xsl:when test="$number eq 11">November</xsl:when>
            <xsl:when test="$number eq 12">Dezember</xsl:when>
        </xsl:choose>
    </xsl:function>
    
    <xsl:function name="local:processDate" as="xs:string">
        <xsl:param name="isodate" as="xs:string"/>
        
        <xsl:choose>
            <xsl:when test="tokenize($isodate, '-')[3]">
                <xsl:value-of select="format-date(xs:date($isodate), '[D].[M].[Y0001]', 'de', (), ())"/>
            </xsl:when>
            <xsl:when test="tokenize($isodate, '-')[2]">
                <xsl:value-of select="local:getMonth(xs:integer(tokenize($isodate, '-')[2])) || ' ' || tokenize($isodate, '-')[1]"/>
            </xsl:when>
            <xsl:otherwise>
                <xsl:value-of select="$isodate"/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:function>
    
    <xsl:function name="local:makePersonList" as="xs:string">
        <xsl:param name="persons" as="item()*"/>
        <xsl:choose>
            <xsl:when test="count($persons) &gt; 2">
                <xsl:variable name="persSequence">
                    <xsl:for-each select="$persons">
                        <xsl:value-of select="."/>
                        <xsl:choose>
                            <xsl:when test="position() &lt; last() - 1">
                                <xsl:text>, </xsl:text>
                            </xsl:when>
                            <xsl:when test="position() = last() - 1">
                                <xsl:text> und </xsl:text>
                            </xsl:when>
                            <xsl:otherwise/>
                        </xsl:choose>
                    </xsl:for-each>
                </xsl:variable>
                <xsl:value-of select="string-join($persSequence, '')"/>
            </xsl:when>
            <xsl:otherwise>
                <xsl:value-of select="string-join($persons, ' und ')"/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:function>
    
    <!-- Zunächst einmal nur die Nachnamen der Absender/Empfänger anzeigen; wenn uneindeutig, dann Vornamen hinzufügen -->
    <xsl:function name="local:getPersonById" as="xs:string">
        <xsl:param name="persId" as="xs:ID"/>
        <xsl:variable name="persName" select="$registry-persons//id($persId)/tei:persName[@type = 'reg']"/>
        <xsl:value-of>
            <!--<xsl:if test="$persName/tei:forename">
                <xsl:value-of select="$persName/tei:forename"/>
                <xsl:text> </xsl:text>
            </xsl:if>
            <xsl:if test="$persName/tei:nameLink">
                <xsl:value-of select="$persName/tei:nameLink"/>
                <xsl:text> </xsl:text>
            </xsl:if>-->
            <xsl:value-of select="$persName/tei:surname"/>
        </xsl:value-of>
    </xsl:function>
    
    <xsl:function name="local:getPlaceById" as="xs:string">
        <xsl:param name="placeId" as="xs:ID"/>
        <xsl:variable name="place" select="$registry-places//id($placeId)"/>
        <xsl:choose>
            <xsl:when test="$place/@type = 'settlement'">
                <xsl:value-of select="$place/tei:placeName[@type = 'reg']"/>
            </xsl:when>
            <xsl:otherwise>
                <xsl:choose>
                    <!-- Sonderfall Los Angeles: Hier werden Distriktnamen anstatt des Städtenamens verwendet -->
                    <xsl:when test="contains($placeId, '15.7')">
                        <xsl:value-of select="$place/ancestor-or-self::tei:place[@type = 'district']/tei:placeName[@type = 'reg']"/>
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:value-of select="$place/ancestor::tei:place[@type = 'settlement']/tei:placeName[@type = 'reg']"/>
                    </xsl:otherwise>
                </xsl:choose>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:function>
    
    <xsl:function name="local:getPersonsForOrg">
        <xsl:param name="org" as="xs:string"/>
        <xsl:param name="correspAction" as="item()"/>
        <xsl:choose>
            <xsl:when test="$correspAction/tei:persName/@key">
                <xsl:variable name="senders" as="item()*">
                    <xsl:for-each select="$correspAction/tei:persName/@key/data()">
                        <xsl:value-of select="local:getPersonById(.)"/>
                    </xsl:for-each>
                </xsl:variable>
                <xsl:value-of select="$org || ' (' || local:makePersonList($senders) || ')'"/>
            </xsl:when>
            <xsl:otherwise>
                <xsl:value-of select="$org"/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:function>
    
    <xsl:function name="local:getRelatedPersons" as="xs:string">
        <xsl:param name="correspAction" as="item()"/>
        <xsl:choose>
            <xsl:when test="$correspAction/tei:persName/@key = 'p_3263'">
                <xsl:text>Schönberg</xsl:text>
            </xsl:when>
            <xsl:when test="$correspAction/tei:orgName/@key = 'org.1'">
                <xsl:value-of select="local:getPersonsForOrg('UE', $correspAction)"/>
            </xsl:when>
            <xsl:when test="$correspAction/tei:orgName/@key = 'org.180'">
                <xsl:value-of select="local:getPersonsForOrg('Dreililien', $correspAction)"/>
            </xsl:when>
            <xsl:when test="$correspAction/tei:orgName/@key = 'org.194'">
                <xsl:value-of select="local:getPersonsForOrg('Helianthus', $correspAction)"/>
            </xsl:when>
            <xsl:otherwise>
                <xsl:choose>
                    <xsl:when test="$correspAction/tei:orgName/@key">
                        <xsl:variable name="organisations" as="item()*">
                            <xsl:for-each select="$correspAction/tei:orgName/@key">
                                <xsl:variable name="orgId" select="$correspAction/tei:orgName/@key"/>
                                <xsl:variable name="orgName" select="$registry-orgs//id($orgId)/tei:orgName[@type = 'reg']"/>
                                <xsl:value-of select="$orgName"/>
                            </xsl:for-each>
                        </xsl:variable>
                        <xsl:value-of select="local:makePersonList($organisations)"/>
                    </xsl:when>
                    <xsl:when test="$correspAction/tei:persName/@key">
                        <xsl:variable name="persons" as="item()*">
                            <xsl:for-each select="$correspAction/tei:persName/@key/data()">
                                <xsl:value-of select="local:getPersonById(.)"/>
                            </xsl:for-each>
                        </xsl:variable>
                        <xsl:value-of select="local:makePersonList($persons)"/>
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:text>unbekannt</xsl:text>
                    </xsl:otherwise>
                </xsl:choose>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:function>
    
    <xsl:function name="local:buildDateString" as="xs:string">
        <xsl:param name="correspAction" as="item()"/>
        <xsl:variable name="dateAsSequence">
            <xsl:choose>
                <!-- Fall: genaues Schreibdatum -->
                <xsl:when test="$correspAction/tei:date[@when]">
                    <xsl:value-of select="if ($correspAction/tei:date[@cert = ('medium', 'low')]) then ('&lt;ca. ' || local:processDate($correspAction/tei:date[1]/@when) || '&gt;') else local:processDate($correspAction/tei:date[1]/@when)"/>
                </xsl:when>
                <!-- Fall: @notBefore und @notAfter als Zeitraum -->
                <xsl:when test="$correspAction/tei:date[@notBefore and @notAfter]">
                    <xsl:text>&lt;zwischen </xsl:text>
                    <xsl:value-of select="local:processDate($correspAction/tei:date[1]/@notBefore)"/>
                    <xsl:text> und </xsl:text>
                    <xsl:value-of select="local:processDate($correspAction/tei:date[1]/@notAfter)"/>
                    <xsl:text>&gt;</xsl:text>
                </xsl:when>
                <!-- Fall: nur @notBefore -->
                <xsl:when test="$correspAction/tei:date[@notBefore]">
                    <xsl:text>&lt;nach </xsl:text>
                    <xsl:value-of select="local:processDate($correspAction/tei:date[1]/@notBefore)"/>
                    <xsl:text>&gt;</xsl:text>
                </xsl:when>
                <!-- Fall: nur @notAfter -->
                <xsl:when test="$correspAction/tei:date[@notAfter]">
                    <xsl:text>&lt;vor </xsl:text>
                    <xsl:value-of select="local:processDate($correspAction/tei:date[1]/@notAfter)"/>
                    <xsl:text>&gt;</xsl:text>
                </xsl:when>
                <!-- Fall: Brief über mehrere Tage verfasst -->
                <xsl:when test="$correspAction/tei:date[@from and @to]">
                    <xsl:text>von </xsl:text>
                    <xsl:value-of select="local:processDate($correspAction/tei:date[1]/@from)"/>
                    <xsl:text> bis </xsl:text>
                    <xsl:value-of select="local:processDate($correspAction/tei:date[1]/@to)"/>
                </xsl:when>
                <xsl:otherwise>&lt;ohne Datum&gt;</xsl:otherwise>
            </xsl:choose>
        </xsl:variable>
        <xsl:value-of select="string-join($dateAsSequence, '')"/>
    </xsl:function>
    
    <!-- ########################################################################################################################################################################################################################## -->
                                                                                                            <!-- Source Files -->
    <!-- ########################################################################################################################################################################################################################## -->
    
    <!--<xsl:variable name="collection" select="collection('../../../documents/Schoenberg-UE/data/letters/?select=*.xml;recurse=yes')"/>-->
    <xsl:variable name="registry-places" select="doc('../../../documents/Schoenberg-UE/data/indices/Orte.xml')//tei:TEI"/>
    <xsl:variable name="registry-persons" select="doc('../../../documents/Schoenberg-UE/data/indices/Personen.xml')//tei:TEI"/>
    <xsl:variable name="registry-orgs" select="doc('../../../documents/Schoenberg-UE/data/indices/Organisationen.xml')//tei:TEI"/>
    <xsl:variable name="registry-stamps" select="doc('../../../documents/Schoenberg-UE/data/indices/Stempel.xml')//tei:TEI"/>
    
    <!-- ########################################################################################################################################################################################################################## -->
                                                                                                            <!-- Template -->
    <!-- ########################################################################################################################################################################################################################## -->
    
    <!--<xsl:variable name="sorting-map">
        <xsl:for-each select="collection()//tei:TEI[not(@type eq 'lost')]">
            <xsl:
        </xsl:for-each>
    </xsl:variable>-->
    
    <xsl:template match="/">
        <content>
            <!-- Loop über alle Briefe, die überliefert sind -->
            <xsl:for-each select="collection()//tei:TEI[not(@type eq 'lost')]"> <!-- wenn collection von außen übergeben wird: collection()//tei:TEI -->
                <!-- && Die Sortierung muss genau so wie in der Webapp eingerichtet werden: 1. Nach Datum, 2. Nach Datierungsattribut, 3. Nach Antw./Beantw., 4. nach Länge des Strings -->
                <xsl:sort>
                    <xsl:value-of select="local:getSortingCriteria(.)"/>
                </xsl:sort>
                <letter>
                <xsl:variable name="id" select="@xml:id/data()"/>
                <xsl:variable name="number" select="position()"/>
                <xsl:variable name="title" select="local:getRelatedPersons(//tei:correspDesc/tei:correspAction[@type = 'sent']) || ' an ' || local:getRelatedPersons(//tei:correspDesc/tei:correspAction[@type = 'received'])"/>
                <xsl:variable name="ascc-id" select="//tei:sourceDesc//tei:altIdentifier/tei:idno[@type = 'signature']"/>
                <xsl:variable name="stamps" select="//tei:body//tei:stamp[@sameAs]"/>
                <xsl:variable name="place-id">
                    <xsl:choose>
                        <xsl:when test="//tei:correspDesc/tei:correspAction[@type = 'sent']/tei:placeName/@key">
                            <xsl:value-of select="//tei:correspDesc/tei:correspAction[@type = 'sent']/tei:placeName[1]/@key"/>
                        </xsl:when>
                        <xsl:when test="//tei:correspDesc/tei:correspAction[@type = 'received']/tei:placeName/@key">
                            <xsl:value-of select="//tei:correspDesc/tei:correspAction[@type = 'received']/tei:placeName/@key"/>
                        </xsl:when>
                        <xsl:otherwise/>
                    </xsl:choose>
                </xsl:variable>
                <xsl:variable name="place-name">
                    <xsl:choose>
                        <xsl:when test="$place-id != ''">
                            <xsl:value-of select="local:getPlaceById($place-id)"/>
                        </xsl:when>
                        <xsl:otherwise>
                            <xsl:text>&lt;Ohne Ort&gt;</xsl:text>
                        </xsl:otherwise>
                    </xsl:choose>
                </xsl:variable>
                <xsl:variable name="date" select="local:buildDateString(//tei:correspDesc/tei:correspAction[@type = 'sent'])"/>


                <headline letter="{$id}" aid:pstyle="kopfzeile">
                    <!-- 1. Laufnummer des Briefs (bekommt eigenes Zeichenformat) -->
                    <number aid:cstyle="laufnummer">
                        <xsl:value-of select="$letterNumbers?($id)"/>
                    </number>
                    <xsl:text>&#x9;</xsl:text>
                    <!-- 2. Haupttitel: Absender an Adressat (bekommt eigenes Zeichenformat) -->
                    <title aid:cstyle="titel">
                        <xsl:value-of select="$title"/>
                    </title>
                    <!-- ein rechtsbündiger Tab zwischen Titel und idnos wird per InDesign-Skript an dieser Stelle eingefügt -->                    
                    <!-- 3. ASCC-ID (bekommt eigenes Zeichenformat) -->
                    <idno type="ascc" aid:cstyle="asccId">
                        <xsl:value-of select="$ascc-id"/>
                    </idno>
                    <xsl:text>&#10;</xsl:text> <!-- &#x2028; damit funktioniert der Einzug der zweiten Zeile, da beide Zeilen in Indesign als ein Paragraph behandelt werden -->
                    <!-- 4. Untertitel: Ort und Datum -->
                    <xsl:value-of select="$place-name"/>
                    <xsl:text>, </xsl:text>
                    <xsl:value-of select="$date"/>
                    <!-- ein rechtsbündiger Tab zwischen Titel und idnos wird per InDesign-Skript an dieser Stelle eingefügt -->
                    <!-- 5. SV-ID (Stempel-Vordrucke) (selbes Zeichenformat wie ASCC-IDs) -->
                    <idno type="bs" aid:cstyle="bsNummer">
                        <xsl:for-each select="$stamps">
                            <xsl:variable name="id" select="@sameAs/data()"/>
                            <xsl:variable name="stamp" select="$registry-stamps//tei:stamp[@xml:id = $id]"/>
                            <xsl:variable name="bs-number" select="$stamp/parent::tei:item/tei:idno[@type = 'bs']"/>
                            <xsl:text>BS </xsl:text>
                            <xsl:value-of select="$bs-number"/>
                            <xsl:if test="position() != last()">
                                <xsl:text>, </xsl:text>
                            </xsl:if>
                        </xsl:for-each>
                    </idno>
                </headline>
                <xsl:text>&#10;&#10;</xsl:text>
                <xsl:apply-templates select="//tei:text"/>
                </letter>
                <xsl:if test="//tei:note[@place][not(@hand) or @hand eq '#author']">
                    <xsl:text>&#10;&#10;</xsl:text>
                    <notes>
                        <xsl:for-each select="//tei:note[@place][not(@hand) or @hand eq '#author']">
                            <xsl:copy-of select="."/>
                        </xsl:for-each>
                    </notes>
                </xsl:if>
                <xsl:text>&#10;&#10;</xsl:text>
            </xsl:for-each>
        </content>
    </xsl:template>
    
    <xsl:template match="tei:text">
        <xsl:copy-of select="." copy-namespaces="no"/>
    </xsl:template>
    
</xsl:stylesheet>