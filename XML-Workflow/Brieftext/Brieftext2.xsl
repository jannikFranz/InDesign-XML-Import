<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    xmlns:tei="http://www.tei-c.org/ns/1.0"
    xmlns:aid="http://ns.adobe.com/AdobeInDesign/4.0/"
    xmlns:local="lokal"
    exclude-result-prefixes="xs tei local"
    version="2.0">
    
    <xsl:strip-space elements="tei:choice"/>
    
    <xsl:output method="xml" encoding="UTF-8" media-type="text/xml" indent="no" omit-xml-declaration="no"/>
    
    
    <!-- ########################################################################################################################################################################################################################## -->
    <!-- Functions -->
    <!-- ########################################################################################################################################################################################################################## -->
    <xsl:template name="getHand">
        <xsl:param name="hand" required="yes"/>
        <xsl:choose>
            <!--<xsl:when test="@hand = '#author'">
                <xsl:text>Sender:in</xsl:text>
            </xsl:when>-->
            <xsl:when test="$hand = '#addressee'">
                <xsl:text>Empfänger:in</xsl:text>
            </xsl:when>
            <xsl:when test="$hand = '#unknown'">
                <xsl:text>von unbekannter Hand</xsl:text>
            </xsl:when>
            <xsl:when test="starts-with($hand, '#pers.')">
                <xsl:variable name="id" select="substring-after($hand, '#')"/>
                <xsl:variable name="person" select="$registry-persons//tei:person[@xml:id = $id]/tei:persName[@type = 'reg']"/>
                <xsl:if test="$person/tei:forename">
                    <xsl:value-of select="$person/tei:forename"/>
                    <xsl:text> </xsl:text>
                </xsl:if>
                <xsl:if test="$person/tei:nameLink">
                    <xsl:value-of select="$person/tei:nameLink"/>
                    <xsl:text> </xsl:text>
                </xsl:if>
                <xsl:value-of select="$person/tei:surname"/>
            </xsl:when>
        </xsl:choose>
    </xsl:template>
    
    <!-- ########################################################################################################################################################################################################################## -->
    <!-- Source Files -->
    <!-- ########################################################################################################################################################################################################################## -->
    
    <!--<xsl:variable name="collection" select="collection('../../../documents/Schoenberg-UE/data/letters/?select=*.xml;recurse=yes')"/>-->
    <xsl:variable name="registry-places" select="doc('../../../documents/Schoenberg-UE/data/indices/Orte.xml')//tei:TEI"/>
    <xsl:variable name="registry-persons" select="doc('../../../documents/Schoenberg-UE/data/indices/Personen.xml')//tei:TEI"/>
    <xsl:variable name="registry-orgs" select="doc('../../../documents/Schoenberg-UE/data/indices/Organisationen.xml')//tei:TEI"/>
    <xsl:variable name="registry-events" select="doc('../../../documents/Schoenberg-UE/data/indices/Ereignisse.xml')//tei:TEI"/>
    <xsl:variable name="registry-works" select="doc('../../../documents/Schoenberg-UE/data/indices/Werke.xml')//tei:TEI"/>
    
    <!-- ########################################################################################################################################################################################################################## -->
    <!-- Template -->
    <!-- ########################################################################################################################################################################################################################## -->
    
    <!--<xsl:template match="/">
        <content>
            <!-\- Loop über alle Briefe, die überliefert sind -\->
            <xsl:for-each select="collection()/tei:TEI[not(@type eq 'lost')]"> <!-\- wenn collection von außen übergeben wird: collection()//tei:TEI -\->
                <xsl:variable name="id" select="@xml:id/data()"/>
                
                <letter id="{$id}">
                    <xsl:apply-templates select="tei:text"/>
                </letter>
                <!-\- Leerzeilen zwischen den Briefen => &&Herr Stark fragen, wie viel Abstand hier hin soll und in welcher Weise dieser in Indesign definiert wird -\->
                <xsl:text>&#10;</xsl:text>
                <xsl:text>&#10;</xsl:text>
                <xsl:text>&#10;</xsl:text>
                
            </xsl:for-each>
        </content>
    </xsl:template>-->
    
    <xsl:template match="*|text()|@*">
        <xsl:copy>
            <xsl:apply-templates select="*|text()|@*"/>
        </xsl:copy>
    </xsl:template>
    
    <!--<xsl:template match="headline">
        <xsl:copy-of select="."/>
    </xsl:template>-->
    
    <xsl:template match="tei:text">
        <xsl:copy>
            <xsl:apply-templates/>
        </xsl:copy>
    </xsl:template>
    
    <xsl:template match="tei:body">
        <xsl:apply-templates/>
    </xsl:template>
    
    <xsl:template match="tei:div[@type]">
        <xsl:apply-templates/>
        <!-- &&Evtl. hier etwas Abstand einfügen -->
    </xsl:template>
    
    
    <!-- ################################################################################################################# -->
    <!-- Elemente, die nicht weiterverarbeitet werden -->
    <!-- ################################################################################################################# -->
    
    <xsl:template match="tei:pb"/>
    
    <xsl:template match="tei:lb"/>
    
    <xsl:template match="tei:g[@ref eq '#typoHyphen']"/>
    
    <xsl:template match="comment()"/>
    
    <xsl:template match="text()[preceding-sibling::*[1][self::tei:g[@ref = '#typoHyphen']]]" priority="20"/>
    
    <xsl:template match="tei:closer[@rendition = '#inline']"/>
    
    <xsl:template match="tei:anchor"/>
    
    
    <!-- ################################################################################################################# -->
    <!-- ################################################################################################################# -->
    
    
    <!-- Zeilenumbrüche -->
    
    <!-- => werden innerhalb des <closer> berücksichtigt -->
    <xsl:template match="tei:lb[ancestor::tei:closer]" mode="#all">
        <!-- Zeilenumbrüche im <salute> sollen im Fließtext nicht berücksichtigt werden, zwischen Grußformeln allerdings schon -->
        <xsl:if test="not(ancestor::tei:salute) or following-sibling::tei:*[1][self::tei:seg[@rendition]]">
            <!--<xsl:text>&#10;</xsl:text>-->
            <lb/>
        </xsl:if>
    </xsl:template>
    
    <!-- => werden als Kindelemente des <opener> berücksichtigt (Bezugszeichen etc.) -->
    <!--<xsl:template match="tei:lb[parent::tei:opener]">
        <lb/>
    </xsl:template>-->
    
    <!-- => werden innerhalb von Datumszeile und Adresszeilen berücksichtigt???? => && ja oder nein? -->
    <!--<xsl:template match="tei:lb[ancestor::tei:addrLine or ancestor::tei:dateline]">
        <!-\-<xsl:text>&#10;</xsl:text>-\->
        <lb/>
    </xsl:template>-->
    
    <xsl:template match="tei:opener">
        <xsl:apply-templates/>
    </xsl:template>
    
    <!-- Stempel => werden nicht dargestellt, allerdings muss autographer Text innerhalb des Stempels (etwa Eintragungen des Datums) wiedergegeben werden -->
    <xsl:template match="tei:stamp" mode="#all">
        <xsl:choose>
            <xsl:when test="descendant::tei:seg[@hand eq '#author'][parent::tei:date]">
                <!-- &&TEST: Es wird im Falle von Datumseintragungen in Vordrucke die gesamte Datumszeile ausgegeben, nicht nur die autograph eingetragenen Bestandteile -->
                <xsl:variable name="date" select="descendant::tei:seg[@hand eq '#author']/parent::tei:date"/>
                <dateline>
                    <xsl:attribute name="aid:pstyle">
                        <xsl:choose>
                            <xsl:when test="ancestor::tei:opener">
                                <xsl:text>rechtsbündig</xsl:text>
                            </xsl:when>
                            <xsl:otherwise>
                                <xsl:text>absatz_einzug_abstandOben</xsl:text>
                            </xsl:otherwise>
                        </xsl:choose>
                    </xsl:attribute>
                    <xsl:apply-templates select="$date"/>
                </dateline>
            </xsl:when>
            <xsl:when test="descendant::tei:seg[@hand eq '#author'][child::tei:date]">
                <dateline>
                    <xsl:attribute name="aid:pstyle">
                        <xsl:choose>
                            <xsl:when test="ancestor::tei:opener">
                                <xsl:text>rechtsbündig</xsl:text>
                            </xsl:when>
                            <xsl:otherwise>
                                <xsl:text>absatz_einzug_abstandOben</xsl:text>
                            </xsl:otherwise>
                        </xsl:choose>
                    </xsl:attribute>
                    <xsl:apply-templates select="descendant::tei:seg[@hand eq '#author']"/>
                </dateline>
            </xsl:when>
        </xsl:choose>
    </xsl:template>
    
    <!-- Datumszeile (rechtsbündig wenn über Brieftext, linksbündig mit Einzug wenn unter Brieftext) -->
    <xsl:template match="tei:dateline">
        <xsl:choose>
            <xsl:when test="ancestor::tei:closer">
                <dateline aid:pstyle="absatz_einzug_abstandOben">
                    <xsl:apply-templates/>
                </dateline>
            </xsl:when>
            <xsl:otherwise>
                <dateline aid:pstyle="rechtsbündig">
                    <xsl:apply-templates/>
                </dateline>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>
    
    <xsl:template match="tei:address">
        <address>
            <xsl:apply-templates/>            
        </address>
    </xsl:template>
    
    <!-- Adresszeilen => bekommen eigenes Absatzformat -->
    <xsl:template match="tei:addrLine">
        <addrline aid:pstyle="addresszeile">
            <xsl:apply-templates/>
        </addrline>
    </xsl:template>
    
    <!-- Anrede als eigener Absatz -->
    <xsl:template match="tei:salute[not(parent::tei:closer)]">
        <xsl:choose>
            <!-- Inline-Anreden werden im ersten Paragraphen verarbeitet -->
            <xsl:when test="following-sibling::tei:p[@rendition = '#inline']"/>
            <!-- Ansonsten Verarbeitung als erster Absatz => bekommt eigenes Absatzformat -->
            <xsl:otherwise>
                <paragraph aid:pstyle="absatz">
                    <xsl:apply-templates/>
                </paragraph>
            </xsl:otherwise>            
        </xsl:choose>
    </xsl:template>
    
    <!-- Absätze => bekommen eigenes Absatzformat -->
    <xsl:template match="tei:p">
        <paragraph>
            <xsl:attribute name="aid:pstyle">
                <xsl:choose>
                    <!-- Postskripta werden gleich behandelt wie Absätze -->
                    <xsl:when test="parent::tei:postscript and index-of(parent::tei:postscript/child::tei:p, .) = 1">
                        <xsl:text>absatz_einzug_abstandOben</xsl:text>
                    </xsl:when>
                    <xsl:when test="parent::tei:postscript">
                        <xsl:text>absatz_einzug</xsl:text>
                    </xsl:when>
                    <!-- Erster Absatz ohne Einzug -->
                    <xsl:when test="@rendition = '#inline' or (not(preceding-sibling::tei:p) and not(preceding-sibling::tei:salute))">
                        <xsl:text>absatz</xsl:text>
                    </xsl:when>
                    <!-- Alle weiteren Absätze mit Einzug -->
                    <xsl:otherwise>
                        <xsl:text>absatz_einzug</xsl:text>
                    </xsl:otherwise>
                </xsl:choose>
            </xsl:attribute>
            <!-- Inline-Anrede wird hier verarbeitet, falls vorhanden -->
            <xsl:if test="@rendition = '#inline' and preceding-sibling::*[1][self::tei:salute]">
                <xsl:apply-templates select="preceding-sibling::*[1][self::tei:salute]" mode="salute-inline"/>
                <xsl:text> </xsl:text>
            </xsl:if>
            <xsl:apply-templates/>
            <!-- Inline-Grußformel wird hier verarbeitet, falls vorhanden -->
            <xsl:if test="following-sibling::*[1][self::tei:closer[@rendition = '#inline']]">
                <xsl:apply-templates select="following-sibling::*[1][self::tei:closer[@rendition = '#inline']]" mode="closer-inline"/>
            </xsl:if>
        </paragraph>
    </xsl:template>
    
    <!-- Schlussformel als eigener Absatz => wird als Absatz verarbeitet -->
    <xsl:template match="tei:closer[not(@rendition = '#inline')]">
        <!--<xsl:choose>
            <!-\- 1. Rechtsbündiges Salute und linksbündiger Text davor -\->
            <xsl:when test="tei:salute[@rendition] and child::node()[1][self::text() and normalize-space() ne '']">
                <xsl:for-each-group select="descendant::node()" group-starting-with="self::element()[@rendition = ('#r', '#c')]">
                    <xsl:choose>
                        <xsl:when test="position() eq 1">
                            <!-\- Alles vor dem salute soll verarbeitet werden -\->
                            <paragraph>
                                <xsl:attribute name="aid:pstyle">
                                    <xsl:choose>
                                        <xsl:when test="@rendition = '#c'">
                                            <xsl:text>paragraph-center</xsl:text>
                                        </xsl:when>
                                        <xsl:when test="@rendition = '#r'">
                                            <xsl:text>paragraph-right</xsl:text>
                                        </xsl:when>
                                        <xsl:otherwise>
                                            <xsl:text>paragraph</xsl:text>
                                        </xsl:otherwise>
                                    </xsl:choose>
                                </xsl:attribute>
                                <xsl:apply-templates select="current-group()[parent::tei:closer]"/>
                            </paragraph>
                        </xsl:when>
                        <!-\- && Das funktioniert nicht so richtig, es werden Zeilenumbrüche verschluckt!!! && -\->
                        <xsl:otherwise>
                            <xsl:apply-templates select="current-group()[parent::tei:closer]"/>
                        </xsl:otherwise>
                    </xsl:choose>
                </xsl:for-each-group>
            </xsl:when>
            <xsl:otherwise>
                <xsl:apply-templates/>
            </xsl:otherwise>
        </xsl:choose>-->
        <closer>
            <xsl:attribute name="aid:pstyle">
                <xsl:text>absatz_einzug</xsl:text>
            </xsl:attribute>
            <xsl:apply-templates/>
        </closer>
    </xsl:template>
    
    <xsl:template match="tei:salute[parent::tei:closer]">
        <!--<xsl:choose>
            <xsl:when test="@rendition = '#c' or parent::tei:closer[@rendition = '#c']">
                <paragraph aid:pstyle="paragraph-center">
                    <xsl:apply-templates/>
                </paragraph>
            </xsl:when>
            <xsl:when test="@rendition = '#r' or parent::tei:closer[@rendition = '#r']">
                <paragraph aid:pstyle="paragraph-right">
                    <xsl:apply-templates/>
                </paragraph>
            </xsl:when>
            <xsl:otherwise>
                <xsl:choose>
                    <!-\- 1. Rechtsbündiges Salute und linksbündiger Text davor -\->
                    <xsl:when test="tei:seg[@rendition] and child::node()[1][self::text() and normalize-space() ne '']">
                        <xsl:for-each-group select="descendant::node()" group-starting-with="self::element()[@rendition = ('#r', '#c')]">
                            <xsl:choose>
                                <xsl:when test="position() eq 1">
                                    <!-\- Alles vor dem seg soll verarbeitet werden -\->
                                    <paragraph>
                                        <xsl:attribute name="aid:pstyle">
                                            <xsl:choose>
                                                <xsl:when test="@rendition = '#c'">
                                                    <xsl:text>paragraph-center</xsl:text>
                                                </xsl:when>
                                                <xsl:when test="@rendition = '#r'">
                                                    <xsl:text>paragraph-right</xsl:text>
                                                </xsl:when>
                                                <xsl:otherwise>
                                                    <xsl:text>paragraph</xsl:text>
                                                </xsl:otherwise>
                                            </xsl:choose>
                                        </xsl:attribute>
                                        <xsl:apply-templates select="current-group()[parent::tei:salute]"/>
                                    </paragraph>
                                </xsl:when>
                                <!-\- && Das funktioniert nicht so richtig, es werden Zeilenumbrüche verschluckt!!! && -\->
                                <xsl:otherwise>
                                    <xsl:apply-templates select="current-group()[parent::tei:salute]"/>
                                </xsl:otherwise>
                            </xsl:choose>
                        </xsl:for-each-group>
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:apply-templates/>
                    </xsl:otherwise>
                </xsl:choose>
            </xsl:otherwise>
        </xsl:choose>-->
        <xsl:apply-templates/>
    </xsl:template>
    
    <xsl:template match="tei:signed" mode="#all">
        <xsl:choose>
            <!-- If there are multiple <signed>-elements directly following each other, only the first one is processed in this template -->
            <xsl:when test="preceding-sibling::*[1][self::*:signed[@rendition]]"/>
            <!-- Mittig oder rechtsbündig platzierte Unterschriften werden wie Paragraphen behandelt -->
            <xsl:when test="@rendition or parent::tei:closer[@rendition = ('#r', '#c')]">
                <xsl:variable name="rendition" select="@rendition"/>
                <signed>
                    <xsl:attribute name="aid:pstyle">
                        <!--<xsl:choose>
                            <xsl:when test="$rendition = '#r' or parent::tei:closer[@rendition = '#r']">
                                <xsl:text>text-right</xsl:text>
                            </xsl:when>
                            <xsl:when test="$rendition = '#c' or parent::tei:closer[@rendition = '#c']">
                                <xsl:text>text-center</xsl:text>
                            </xsl:when>
                            <xsl:when test="$rendition = '#l' or parent::tei:closer[@rendition = '#l']">
                                <xsl:text>text-left</xsl:text>
                            </xsl:when>
                        </xsl:choose>-->
                        <xsl:text>absatz_einzug</xsl:text>
                    </xsl:attribute>
                    <xsl:apply-templates/>
                    <xsl:choose>
                        <!-- Rechtsbündig direkt aufeinanderfolgende Unterschriften werden in einem Schwung verarbeitet mittelt eines rekursiven Templates -->
                        <xsl:when test="not(preceding-sibling::tei:signed) and following-sibling::*[1][self::tei:signed[@rendition eq $rendition]]">
                            <xsl:call-template name="process-signed">
                                <xsl:with-param name="following" select="following-sibling::*"/>
                                <xsl:with-param name="rendition" select="$rendition"/>
                            </xsl:call-template>
                        </xsl:when>
                        <xsl:otherwise/>
                    </xsl:choose>
                </signed>
            </xsl:when>
            <xsl:otherwise>
                <!-- for inline-closer -->
                <xsl:apply-templates/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>
    
    <xsl:template name="process-signed">
        <xsl:param name="following"/>
        <xsl:param name="rendition"/>
        <xsl:text> </xsl:text>
        <xsl:apply-templates select="$following[1]/node()"/>
        <xsl:if test="$following[2][self::*:signed[@rendition eq $rendition]]">
            <xsl:call-template name="process-signed">
                <xsl:with-param name="following" select="$following[1]/following-sibling::*"/>
                <xsl:with-param name="rendition" select="$rendition"/>
            </xsl:call-template>
        </xsl:if>
    </xsl:template>
    
    <xsl:template match="tei:date">
        <xsl:apply-templates/>
    </xsl:template>
    
    <xsl:template match="tei:seg[@hand eq '#author']">
        <xsl:apply-templates/>
    </xsl:template>
    
    <xsl:template match="tei:head"> <!-- => fertig, alle Fälle berücksichtigt -->
        <xsl:copy>
            <!--<xsl:choose>
                <!-\- Überschrift mittig -\->
                <xsl:when test="tokenize(@rendition) = '#c'">
                    <xsl:attribute name="aid:pstyle">
                        <xsl:text>paragraph-right</xsl:text>
                    </xsl:attribute>
                </xsl:when>
                <!-\- Überschrift linksbündig -\->
                <xsl:otherwise>
                    <xsl:attribute name="aid:pstyle" select="'Überschrift'"/>
                </xsl:otherwise>
            </xsl:choose>-->
            <xsl:attribute name="aid:pstyle" select="'überschrift'"/>
            <xsl:choose>
                <!-- Unterstrichen -->
                <xsl:when test="tokenize(@rendition) = '#u'">
                    <hi aid:cstyle="kursiv">
                        <xsl:apply-templates/>
                    </hi>
                </xsl:when>
                <!-- Unterstrichen + Umrahmt -->
                <xsl:when test="tokenize(@rendition) = ('#rectangle') and tokenize(@rendition) = '#u'">
                    <hi aid:cstyle="kursiv">
                        <xsl:apply-templates/>
                    </hi>
                </xsl:when>
                <!-- default -->
                <xsl:otherwise>
                    <xsl:apply-templates/>                    
                </xsl:otherwise>
            </xsl:choose>
        </xsl:copy>
    </xsl:template>

    <!-- ######################################################################## -->
    <!-- Editorische Kommentare -->
    <!-- ######################################################################## -->
    
    <xsl:template match="tei:seg[@type eq 'comment']">
        <xsl:apply-templates/>
    </xsl:template>

    <!-- Das Lemma wird ganz normal als Text ausgegeben -->
    <xsl:template match="tei:orig[parent::tei:seg]">
        <xsl:apply-templates/>
    </xsl:template>
    
    <!-- Der Kommentarinhalt wird zunächst als Text ausgegeben und dann per Skript in eine Fußnote umgewandelt => eigenes Absatzformat? -->
    <xsl:template match="tei:note[@xml:id]">
        <!-- Kommentare, die lediglich einen Verweis auf einen erschlossenen Brief erhalten, kommen nicht in die Buchausgabe -->
        <xsl:if test="not(child::*[1][self::tei:ref[ends-with(normalize-space(.), '[erschlossen]')]])">
            <comment> <!-- aid:pstyle="comment" -->
                <xsl:apply-templates mode="comment"/>
            </comment>            
        </xsl:if>
    </xsl:template>
    
    <!-- ######################################################################## -->
    <!-- Randanmerkungen -->
    <!-- ######################################################################## -->
    
    <xsl:template match="tei:note[@place][ancestor::letter]" mode="#all">
        <xsl:if test="not(@hand) or @hand eq '#author'">
            <xsl:variable name="letter" select="ancestor::letter"/>
            <!--<xsl:variable name="notesInLetter" select="ancestor::letter//tei:note[@hand = '#author']"/>-->
            <xsl:variable name="noteNumber" select="count(preceding::tei:note[@hand = '#author'][ancestor::letter = $letter]) + 1"/>
            <xsl:for-each select="1 to $noteNumber">
                <xsl:text>*</xsl:text>
            </xsl:for-each>
            <xsl:text> </xsl:text>
        </xsl:if>
    </xsl:template>
    
    <xsl:template match="tei:note[@place][parent::notes]" mode="#all">
        <xsl:variable name="position" select="count(preceding-sibling::tei:note) + 1"/>
        <note aid:pstyle="absatz">
            <xsl:for-each select="1 to $position">
                <xsl:text>*</xsl:text>
            </xsl:for-each>
            <xsl:text> </xsl:text>
            <xsl:apply-templates/>
        </note>
    </xsl:template>
    
    <!-- ######################################################################## -->
    <!-- Kommentarinhalte -->
    <!-- ######################################################################## -->
    
    <xsl:template match="tei:p" mode="comment">
        <xsl:apply-templates mode="#current"/>
    </xsl:template>
    
    <xsl:template match="tei:ref[@target]" mode="comment">
        <xsl:variable name="id" select="@target/data()"/>
        <xsl:choose>
            <!-- Referenzen auf Konzerte -->
            <xsl:when test="starts-with(@target, 'event')">
                <xsl:variable name="event" select="$registry-events/id($id)"/>
                <xsl:value-of select="$event/tei:label/normalize-space()"/>
            </xsl:when>
            <!-- Referenzen auf andere Briefe und Dokumente -->
            <xsl:when test="starts-with(@target, 'letter') or starts-with(@target, 'document')">
                <xsl:apply-templates/>
            </xsl:when>
            <!-- externe Links -->
            <xsl:otherwise>
                <xsl:apply-templates/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>
    
    
    <!-- Bei mehreren aufeinanderfolgenden Werknennungen die Werktitel mit Komma oder Semikolon trennen; -->
    
    <!-- ######################################################################## -->
    <!-- ######################################################################## -->
    
    <xsl:template match="tei:note[@sameAs]">
        <comment>Vgl. Anmerkung ## auf Seite ##. [<xsl:value-of select="@sameAs"/>]</comment> <!-- aid:pstyle="comment" -->
    </xsl:template>
    
    <xsl:template match="tei:seg[@type eq 'row']">
        <xsl:text>&#10;</xsl:text>
        <xsl:apply-templates/>
        <xsl:text>&#10;</xsl:text>
    </xsl:template>
    
    <xsl:template match="tei:seg[@rendition][not(@type)]" mode="#all">
        <!--<span>
            <xsl:attribute name="aid:pstyle">
                <xsl:choose>
                    <xsl:when test="@rendition = '#r'">
                        <xsl:text>text-right</xsl:text>
                    </xsl:when>
                    <xsl:when test="@rendition = '#c'">
                        <xsl:text>text-center</xsl:text>
                    </xsl:when>
                    <xsl:when test="@rendition = '#l'">
                        <xsl:text>text-left</xsl:text>
                    </xsl:when>
                </xsl:choose>
            </xsl:attribute>
            <xsl:apply-templates/>
        </span>-->
        <span aid:pstyle="absatz_einzug">
            <xsl:apply-templates/>
        </span>
    </xsl:template>
    
    <xsl:template match="tei:quote[@rendition eq '#blockquote']">
        <paragraph>
            <xsl:attribute name="aid:pstyle">
                <!--<xsl:choose>
                    <xsl:when test="@rendition = '#c'">
                        <xsl:text>paragraph-center</xsl:text>
                    </xsl:when>
                    <xsl:when test="@rendition = '#r'">
                        <xsl:text>paragraph-right</xsl:text>
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:text>paragraph</xsl:text>
                    </xsl:otherwise>
                </xsl:choose>-->
                <xsl:text>absatz_einzug</xsl:text>
            </xsl:attribute>
            <xsl:apply-templates/>
        </paragraph>
        <xsl:text>&#10;</xsl:text>
    </xsl:template>
    
    <xsl:template match="tei:postscript">
        <xsl:choose>
            <!-- Inline-Postscript siehe letter.7002 -->
            <xsl:when test="@rendition eq '#inline'">
                <xsl:apply-templates select="tei:p/node()"/>
            </xsl:when>
            <xsl:otherwise>
                <xsl:apply-templates/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>
    
    <xsl:template match="tei:list">
        <list aid:pstyle="liste"> <!-- aid:pstyle="list" -->
            <xsl:choose>
                <xsl:when test="tei:head">
                    <xsl:apply-templates select="tei:head"/>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:apply-templates select="tei:item"/>
                </xsl:otherwise>
            </xsl:choose>
        </list>
        <!-- Inline-Grußformel wird hier verarbeitet, falls vorhanden -->
        <xsl:if test="following-sibling::*[1][self::tei:closer[@rendition = '#inline']]">
            <xsl:apply-templates select="following-sibling::*[1][self::tei:closer[@rendition = '#inline']]" mode="closer-inline"/>
        </xsl:if>
    </xsl:template>
    
    <xsl:template match="*:list[ancestor::*:list]">
        <list aid:pstyle="list-indent">
            <xsl:apply-templates/>
        </list>
        <xsl:text>&#10;</xsl:text>
    </xsl:template>
    
    <xsl:template match="*:head[parent::*:list]">
        <xsl:choose>
            <!-- &&Sonderfall -->
            <xsl:when test="@place = 'left'">
                <!--<div class="row">
                    <div class="col-md-1">
                        <xsl:apply-templates mode="#current"/>
                    </div>
                    <div class="col-md-11">
                        <xsl:apply-templates select="../*:item" mode="#current"/>
                    </div>
                </div>-->
            </xsl:when>
            <xsl:otherwise>
                <xsl:apply-templates/>
                <xsl:text>&#10;</xsl:text>
                <xsl:apply-templates select="../*:item"/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>
    
    <xsl:template match="*:item">
        <li aid:pstyle="listenpunkt">
            <xsl:apply-templates/>
        </li>
    </xsl:template>
    
    <!-- ################################################################################## -->
    <!-- ##############################   Hervorhebungen   ################################ -->
    <!-- ################################################################################## -->
    
    <xsl:template match="tei:hi" mode="#all">
        <xsl:copy>
            <xsl:choose>
                <xsl:when test="tokenize(@rendition) = '#sup' and tokenize(@rendition) = '#uu'">
                    <!--<xsl:attribute name="aid:cstyle" select="'hochgestellt+doppelt_unterstrichen'"/>-->
                    <xsl:attribute name="aid:cstyle" select="'hochgestellt+kursiv'"/>
                    <xsl:apply-templates/>
                </xsl:when>
                <xsl:when test="tokenize(@rendition) = '#sup' and tokenize(@rendition) = '#u'">
                    <!--<xsl:attribute name="aid:cstyle" select="'hochgestellt+unterstrichen'"/>-->
                    <xsl:attribute name="aid:cstyle" select="'hochgestellt+kursiv'"/>
                    <xsl:apply-templates/>
                </xsl:when>
                <!--<xsl:when test="tokenize(@rendition) = '#uu'">
                    <xsl:attribute name="aid:cstyle" select="'doppelt_unterstrichen'"/>
                    <xsl:apply-templates/>
                </xsl:when>
                <xsl:when test="tokenize(@rendition) = '#uda'">
                    <xsl:attribute name="aid:cstyle" select="'gestrichelt_unterstrichen'"/>
                    <xsl:apply-templates/>
                </xsl:when>
                <xsl:when test="tokenize(@rendition) = '#u'">
                    <xsl:attribute name="aid:cstyle" select="'unterstrichen'"/>
                    <xsl:apply-templates/>
                </xsl:when>-->
                <xsl:when test="tokenize(@rendition) = '#sup'">
                    <xsl:attribute name="aid:cstyle" select="'hochgestellt'"/>
                    <xsl:apply-templates/>
                </xsl:when>
                <xsl:when test="tokenize(@rendition) = '#sub'">
                    <xsl:attribute name="aid:cstyle" select="'tiefgestellt'"/>
                    <xsl:apply-templates/>
                </xsl:when>
                <!--<xsl:when test="tokenize(@rendition) = '#g'">
                    <xsl:attribute name="aid:cstyle" select="'gesperrt'"/>
                    <xsl:apply-templates/>
                </xsl:when>
                <xsl:when test="tokenize(@rendition) = '#rectangle'">
                    <xsl:attribute name="aid:cstyle" select="'umrahmt'"/>
                    <xsl:apply-templates/>
                </xsl:when>
                <xsl:when test="tokenize(@rendition) = '#circle'">
                    <xsl:attribute name="aid:cstyle" select="'umkreist'"/>
                    <xsl:apply-templates/>
                </xsl:when>-->
                <xsl:when test="tokenize(@rendition) = '#st'">
                    <xsl:attribute name="aid:cstyle" select="'kursiv'"/>
                    <xsl:text>[Stenographie:] </xsl:text>
                    <xsl:apply-templates/>
                </xsl:when>
                <!-- Für den Druck ist der Standardfall für Textauszeichnungen und Randanstrichungen die Kursivsetzung -->
                <xsl:otherwise>
                    <xsl:attribute name="aid:cstyle" select="'kursiv'"/>
                    <xsl:apply-templates/>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:copy>
    </xsl:template>
    
    <!-- ################################################################################## -->
    <!-- ##############################   Named Entities   ################################ -->
    <!-- ################################################################################## -->
    
    <xsl:template match="tei:persName[@key] | tei:rs[@type eq 'person']" mode="#all">
        <xsl:variable name="id" select="@key"/>
        <person key="{$id}">
            <xsl:apply-templates/>
            <xsl:if test="not(ancestor::tei:note[@xml:id]) and not(preceding::tei:persName[@key eq $id][not(ancestor::tei:note[@xml:id])])">
                <comment>
                    <xsl:variable name="person" select="$registry-persons//id($id)"/>
                    <xsl:variable name="persName" select="if ($person/tei:persName[@type = 'reg']/tei:surname/text() or $person/tei:persName[@type = 'reg']/tei:forename/text()) then $person/tei:persName[@type = 'reg'] else $person/tei:persName[@type = 'alt'][1]"/>
                    <!--<xsl:variable name="birthdate" select="substring($person/tei:birth/tei:date/@when, 1, 4)"/>
                    <xsl:variable name="deathdate" select="substring($person/tei:death/tei:date/@when, 1, 4)"/>-->
                    <person key="{$person/@xml:id}">
                        <xsl:value-of select="$persName/tei:forename"/>
                        <xsl:if test="$persName/tei:forename and $persName/tei:surname">
                            <xsl:text> </xsl:text>
                        </xsl:if>
                        <xsl:if test="$persName/tei:nameLink">
                            <xsl:value-of select="$persName/tei:nameLink"/>
                        </xsl:if>
                        <xsl:if test="$persName/tei:nameLink != 'd’'">
                            <xsl:text> </xsl:text>    
                        </xsl:if>
                        <xsl:choose>
                            <xsl:when test="$persName/tei:surname">
                                <xsl:value-of select="$persName/tei:surname"/>
                            </xsl:when>
                            <xsl:otherwise>
                                <xsl:value-of select="$persName"/>
                            </xsl:otherwise>
                        </xsl:choose>
                    </person>
                    <!--<xsl:if test="$birthdate != '' or $deathdate != ''">
                        <xsl:text> (</xsl:text>
                        <xsl:value-of select="if ($birthdate != '') then $birthdate else '?'"/>
                        <xsl:text>–</xsl:text>
                        <xsl:value-of select="if ($deathdate != '') then $deathdate else '?'"/>
                        <xsl:text>)</xsl:text>
                    </xsl:if>-->
                </comment>
            </xsl:if>
        </person>
    </xsl:template>
    
    <xsl:template match="tei:orgName[@key] | tei:rs[@type eq 'org']" mode="#all">
        <xsl:variable name="id" select="@key"/>
        <xsl:apply-templates mode="#current"/>
        <!-- Bei Erstnennung von Organisationen im Brieftext (nicht in Anmerkungen) -->
        <xsl:if test="not(ancestor::tei:note[@xml:id]) and not(preceding::tei:orgName[@key eq $id][not(ancestor::tei:note[@xml:id])])">
            <comment>
                <xsl:variable name="org" select="$registry-orgs//id($id)"/>
                <xsl:value-of select="$org/tei:orgName[@type = 'reg']"/>
            </comment>
        </xsl:if>
    </xsl:template>
    
    <xsl:template match="tei:bibl[@sameAs]" mode="#all">
        <xsl:variable name="id" select="@sameAs"/>
        <work key="{$id}">
            <xsl:apply-templates mode="#current"/>
        </work>
        <!-- Bei Nennung von Werken im Brieftext (nicht in Anmerkungen) -->
        <!-- && Wie sollen die Titel von Bearbeitungen lauten? -->
        <xsl:if test="not(ancestor::tei:note[@xml:id])"> <!-- wenn nur bei Erstnennung, dann folgendes Prädikat ergänzen: and not(preceding::tei:bibl[@sameAs eq $id][not(ancestor::tei:note[@xml:id])]) -->
            <comment>
                <xsl:variable name="work" select="$registry-works//id($id)"/>
                <xsl:variable name="composer" select="if ($work/tei:author/tei:persName) then ( if (starts-with($id, 'werke')) then $work/tei:author[@role eq 'composition']/tei:persName else (if (starts-with($id, 'schriften')) then $work/tei:author[@role eq 'text']/tei:persName else ())) else $work/tei:author"/>
                <xsl:variable name="persName">
                    <xsl:if test="$composer/tei:forename">
                        <xsl:value-of select="$composer/tei:forename"/>
                        <xsl:text> </xsl:text>
                    </xsl:if>
                    <!-- Als Namelink kommt im Werkregister nur "van" oder "von" vor -->
                    <xsl:if test="$composer/tei:nameLink">
                        <xsl:value-of select="$composer/tei:nameLink"/>
                        <xsl:text> </xsl:text>
                    </xsl:if>
                    <xsl:choose>
                        <xsl:when test="$composer/tei:surname">
                            <xsl:value-of select="$composer/tei:surname"/>
                        </xsl:when>
                        <xsl:otherwise>
                            <xsl:value-of select="$composer/text()"/>
                        </xsl:otherwise>
                    </xsl:choose>
                </xsl:variable>
                <xsl:choose>
                    <xsl:when test="$composer/@key">
                        <person key="{$composer/@key}">
                            <xsl:value-of select="$persName"/>
                        </person>
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:value-of select="$persName"/>
                    </xsl:otherwise>
                </xsl:choose>
                <xsl:text>, </xsl:text>
                <work key="{$work/@xml:id}">
                    <xsl:value-of select="$work/tei:title"/>
                    <xsl:if test="$work/@type eq 'arrangement'">
                        <xsl:text> (</xsl:text>
                        <xsl:value-of select="$work/tei:note/tei:bibl/tei:title"/>
                        <xsl:text>)</xsl:text>
                    </xsl:if>
                    <xsl:if test="starts-with($id, 'schriften') and $work/tei:idno/text()">
                        <xsl:text> (</xsl:text>
                        <xsl:value-of select="$work/tei:idno"/>
                        <xsl:text>)</xsl:text>
                    </xsl:if>
                </work>
            </comment>
        </xsl:if>
    </xsl:template>
    
    <xsl:template match="tei:placeName | tei:rs[@type = 'place']" mode="#all">
        <xsl:apply-templates/>
    </xsl:template>
    
    <!-- ################################################################################## -->
    <!-- #############################   Zotero-Referenzen   ############################## -->
    <!-- ################################################################################## -->
    
    <xsl:template match="tei:rs[@type eq 'bibl']">
        <xsl:apply-templates/>
    </xsl:template>
    
    <!-- ################################################################################## -->
    <!-- ###########################   Textkritik   ####################################### -->
    <!-- ################################################################################## -->
    
    <!-- Korrekturen durch den Autor -->
    <xsl:template match="tei:subst">
        <xsl:apply-templates/>
    </xsl:template>
    
    <!-- Durchgestrichene Passagen werden nur dann (ohne Streichung) wiedergegeben, wenn sie nicht von Autorhand stammen (auch innerhalb von Tabellen!!) -->
    <xsl:template match="tei:del[contains(@rendition, '#s')]">
        <xsl:if test="@hand ne '#author'">
            <xsl:apply-templates mode="#current"/>
        </xsl:if>
    </xsl:template>
    
    <xsl:template match="tei:del[contains(@rendition, '#ow')]"/>
    
    <!-- Der einer Streichung vorangehende String wird in der Lesefassung am Ende getrimmt, damit keine ungewollten Leerzeichen am Ende des Strings entstehen, wenn direkt nach der Streichung ein Satzzeichen folgt
         Beispiele: letter.774 "ob ich weiter gehen soll,"
                    letter.859 "den Weg des Feilschens betreten haben."
        Dagegen noch ungelöst: Streichungen nach Zeilenumbrüchen, siehe z. B. letter.394 und letter.12381
    -->
    <!-- Siehe dagegen: letter.416 "des Materials eine", hier muss das Leerzeichen bestehen bleiben! -->
    <!--<xsl:template match="text()[following::*[1][self::*:del[not(@hand)]]]">
        <xsl:choose>
            <xsl:when test="ends-with(., ' ')">
                <xsl:value-of select="substring(., 1, string-length(.) - 1)"/>
            </xsl:when>
            <xsl:otherwise>
                <xsl:value-of select="."/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>-->
    
    <!-- Unsichere Lesung => in der Regel immer mit @reason = (illegible|covered) -->
    <xsl:template match="tei:unclear">
        <xsl:choose>
            <xsl:when test="@reason = 'illegible'">
                <xsl:apply-templates mode="#current"/>
                <xsl:text>[?]</xsl:text>
            </xsl:when>
            <xsl:otherwise>
                <xsl:apply-templates mode="#current"/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>
    
    
    <!-- ######################################################################################### -->
    <!-- Einfügungen in den Text und Korrekturen -->
    <!-- ######################################################################################### -->
    
    <!-- Hinzufügungen und Korrekturen aus Empfängerhand werden in der Lesefassung nicht angezeigt (siehe letter.19674) -->
    <xsl:template match="tei:add[not(parent::*:subst)]">
        <xsl:if test="not(@hand eq '#addressee')">
            <xsl:apply-templates mode="#current"/>
        </xsl:if>
    </xsl:template>
    
    <xsl:template match="tei:add[parent::*:subst]">
        <xsl:if test="not(@hand eq '#addressee')">
            <xsl:apply-templates mode="#current"/>
        </xsl:if>
    </xsl:template>
    
    <!-- ######################################################################################### -->
    <!-- Abkürzungen und Normalisierungen -->
    <!-- ######################################################################################### -->
    
    <xsl:template match="tei:choice">
        <xsl:apply-templates/>
    </xsl:template>
    
    <xsl:template match="tei:abbr">
        <xsl:apply-templates/>
    </xsl:template>
    
    <xsl:template match="tei:expan"/>
    
    <xsl:template match="tei:choice/tei:orig">
        <xsl:apply-templates mode="#current"/>
    </xsl:template>
    
    <xsl:template match="tei:choice/tei:reg"/>
    
    <!-- ######################################################################################### -->
    <!-- Editorische Ergänzungen in den Brieftext -->
    <!-- ######################################################################################### -->
    
    <xsl:template match="tei:supplied">
        <xsl:apply-templates/>
    </xsl:template>
    
    <!-- ######################################################################################### -->
    <!-- Korrekturen des Herausgebers -->
    <!-- ######################################################################################### -->
    
    <xsl:template match="tei:sic"/>
    
    <xsl:template match="tei:corr">
        <xsl:apply-templates/>
    </xsl:template>
    
    
    <!-- ######################################################################################### -->
    <!-- Lücken im Brieftext / unleserliche Stellen / Auslassungen -->
    <!-- ######################################################################################### -->
    
    <xsl:template match="tei:gap">
        <xsl:text>[...]</xsl:text>
    </xsl:template>
    
    <xsl:template match="tei:ellipsis">
        <xsl:apply-templates select="tei:metamark[@function eq 'ellipsis']"/>
    </xsl:template>
    
    <xsl:template match="tei:metamark[@function eq 'ellipsis']">
        <xsl:apply-templates/>
    </xsl:template>
    
    <xsl:template match="tei:metamark[@function eq 'done']">
        <xsl:if test="@hand eq 'author'">
            <xsl:apply-templates/>
        </xsl:if>
    </xsl:template>
    
    <!-- ############################################################ -->
    <!-- &&Tabellen noch nicht berücksichtigt !!!! -->
    <!-- ############################################################ -->
    
    <xsl:template match="tei:table">
        <table>
            <xsl:apply-templates/>
        </table>
        <!-- Inline-Grußformel wird hier verarbeitet, falls vorhanden -->
        <xsl:if test="following-sibling::*[1][self::tei:closer[@rendition = '#inline']]">
            <xsl:apply-templates select="following-sibling::*[1][self::tei:closer[@rendition = '#inline']]" mode="closer-inline"/>
        </xsl:if>
    </xsl:template>
    
    <xsl:template match="tei:row">
        <row>
            <xsl:apply-templates/>
        </row>
    </xsl:template>
    
    <xsl:template match="tei:cell">
        <cell>
            <xsl:apply-templates/>
        </cell>
    </xsl:template>
    
    <!-- ############################################################ -->
    <!-- &&Milestones noch nicht berücksichtigt !!!! -->
    <!-- ############################################################ -->
    
    <!-- ######################################################################################### -->
    <!-- Grafiken und Notenbeispiele -->
    <!-- ######################################################################################### -->
    
    <xsl:template match="tei:notatedMusic">
        <xsl:choose>
            <xsl:when test="@place eq 'inline'">
                <music aid:cstyle="music">[Notenbeispiel einfügen]</music>
            </xsl:when>
            <xsl:otherwise>
                <music aid:pstyle="music">[Notenbeispiel einfügen]</music>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>
    
    <xsl:template match="tei:ab">
        <paragraph aid:pstyle="absatz_einzug">
            <xsl:apply-templates/>
        </paragraph>
    </xsl:template>
    
    <xsl:template match="tei:figure">
        <image aid:pstyle="image">
            <xsl:text>[</xsl:text>
            <xsl:text>Abbildung</xsl:text>
            <xsl:if test="tei:figDesc">
                <xsl:text>: </xsl:text>
                <xsl:apply-templates select="tei:figDesc"/>
            </xsl:if>
            <xsl:if test="@hand">
                <xsl:text> </xsl:text>
                <xsl:value-of>
                    <xsl:call-template name="getHand">
                        <xsl:with-param name="hand" select="@hand"/>
                    </xsl:call-template>
                </xsl:value-of>
            </xsl:if>
            <xsl:text>]</xsl:text>
            <xsl:apply-templates select="tei:*[not(self::tei:figDesc)]"/>
        </image>
    </xsl:template>
    
    <!-- using SMUFL-Browser (https://smufl-browser.edirom.de/index) to display musical symbols on the web -->    
    <xsl:template match="*:g[not(@ref = '#typoHyphen')]">
        <xsl:variable name="url" select="data(@ref)"/>
        <xsl:variable name="doc" select="doc($url)"/>
        <xsl:variable name="image" select="$doc//tei:graphic/data(@url)"/>
        <xsl:variable name="desc" select="$doc//tei:desc/text()"/>
        <!--<img src="{$image}" alt="{$desc}" width="{if ($doc//tei:note//tei:item/text() = 'tf_hairpins') then '28' else if (@type eq 'note') then '24' else '12'}"/>--> <!-- class="musicalSymbol" -->
        <span aid:cstyle="symbol">
            <xsl:apply-templates/>
        </span>
    </xsl:template>
    
</xsl:stylesheet>