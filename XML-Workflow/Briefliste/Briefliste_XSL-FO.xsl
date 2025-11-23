<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    xmlns:fo="http://www.w3.org/1999/XSL/Format"
    xmlns:tei="http://www.tei-c.org/ns/1.0"
    xmlns:local="lokal"
    exclude-result-prefixes="xs tei"
    version="3.0">
    
    <xsl:output encoding="UTF-8" indent="yes" omit-xml-declaration="no" method="xml" media-type="text/xml"/>
    
    <xsl:variable name="collection" select="collection('../../documents/Schoenberg-UE/data/letters/?select=*.xml;recurse=yes')"/>
    
    <xsl:function name="local:process-date" as="xs:string">
        <xsl:param name="isodate" as="xs:string"/>
        <xsl:choose>
            <xsl:when test="tokenize($isodate, '-')[3]">
                <xsl:value-of select="format-date(xs:date($isodate), '[D01].[M01].[Y0001]')"/>
            </xsl:when>
            <xsl:when test="tokenize($isodate, '-')[2]">
                <xsl:value-of select="concat(tokenize($isodate, '-')[2], '.', tokenize($isodate, '-')[1])"/>
            </xsl:when>
            <xsl:otherwise>
                <xsl:value-of select="$isodate"/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:function>
    
    <!-- Seitenaufteilung -->
    <xsl:template match="/">
        <fo:root xmlns:fo="http://www.w3.org/1999/XSL/Format" font-size="10pt">
            <fo:layout-master-set>
                <!-- contains one or more page templates that define the page layout -->
                <fo:simple-page-master
                    master-name="DIN-A4"
                    page-width="210mm"
                    page-height="297mm"
                    margin-top="1cm"
                    margin-bottom="1cm"
                    margin-left="1cm"
                    margin-right="1cm"
                    font-family="Garamond, serif"
                    size="auto"
                    language="de"
                    country="DE"
                    hyphenate="true">
                    <fo:region-body  margin="3cm"/>
                    <fo:region-before extent="2cm"/>
                    <fo:region-after extent="2cm"/>
                    <fo:region-start extent="2cm"/>
                    <fo:region-end extent="2cm"/>
                </fo:simple-page-master>
            </fo:layout-master-set>
            <!-- Page -->
            <fo:page-sequence master-reference="DIN-A4">
                <!-- Region (region-body (=body of the page), region-before (=header of the page), region-after (=footer of the page), region-start (=left sidebar), region-end (=right sidebar)) -->
                
                <!-- Header -->
                <fo:static-content flow-name="xsl-region-before">
                    <fo:block font-size="10pt" text-align="center">
                        Briefe Arnold Schönberg - Universal-Edition
                    </fo:block>
                </fo:static-content>
                
                <!-- Footer -->
                <fo:static-content flow-name="xsl-region-after">
                    <fo:block text-align="center" font-size="10pt">
                        Seite <fo:page-number/>
                    </fo:block>
                </fo:static-content>
                
                <!-- Body -->
                <fo:flow flow-name="xsl-region-body">
                    <!-- Include page content here -->
                    <!-- Block Area -->
                    
                    <fo:table>
                        <fo:table-header>
                            <fo:table-row>
                                <fo:table-cell><fo:block>Nr.</fo:block></fo:table-cell>
                                <fo:table-cell><fo:block>Datum</fo:block></fo:table-cell>
                                <fo:table-cell><fo:block>ASCC-Id</fo:block></fo:table-cell>
                                <fo:table-cell><fo:block>Brieftitel</fo:block></fo:table-cell>
                                <fo:table-cell><fo:block>Standort</fo:block></fo:table-cell>
                            </fo:table-row>
                        </fo:table-header>
                        <fo:table-body>
                            <xsl:for-each select="$collection//tei:TEI">
                                <xsl:sort select="if (tei:teiHeader//tei:correspAction[@type = 'sent']/tei:date/@*[1]) then tei:teiHeader//tei:correspAction[@type = 'sent']/tei:date/@*[1] else '1999-01-01'"/>
                                <xsl:variable name="number" select="position()"/>
                                <xsl:variable name="id" select="substring-after(@xml:id/data(), 'letter.')"/>
                                <xsl:variable name="title" select="substring-before(tei:teiHeader//tei:titleStmt/tei:title[1], ',') || (if (ends-with(tei:teiHeader//tei:titleStmt/tei:title[1], '[erschlossen]')) then ' [erschlossen]' else ())"/>
                                <xsl:variable name="date">
                                    <xsl:choose>
                                        <xsl:when test="tei:teiHeader//tei:correspAction[@type = 'sent']/tei:date">
                                            <xsl:apply-templates select="tei:teiHeader//tei:correspAction[@type = 'sent']/tei:date[1]"/>        
                                        </xsl:when>
                                        <xsl:when test="tei:teiHeader//tei:correspAction[@type = 'received']/tei:date">
                                            <xsl:apply-templates select="tei:teiHeader//tei:correspAction[@type = 'received']/tei:date[1]"/>
                                            <xsl:text> (erh.)</xsl:text>
                                        </xsl:when>
                                        <xsl:otherwise>
                                            <xsl:text>nicht ermittelt</xsl:text>
                                        </xsl:otherwise>
                                    </xsl:choose>
                                    
                                </xsl:variable>
                                <xsl:variable name="repository">
                                    <xsl:choose>
                                        <xsl:when test="lower-case(tei:teiHeader//tei:msDesc//tei:collection/normalize-space()) = 'arnold schoenberg collection'">
                                            <xsl:text>ASC</xsl:text>
                                        </xsl:when>
                                        <xsl:when test="lower-case(tei:teiHeader//tei:msDesc//tei:collection/normalize-space()) = 'universal edition collection'">
                                            <xsl:text>LC</xsl:text>
                                        </xsl:when>
                                        <xsl:otherwise>
                                            <xsl:value-of select="tei:teiHeader//tei:msDesc//tei:collection/normalize-space()"/>
                                        </xsl:otherwise>
                                    </xsl:choose>
                                </xsl:variable>
                                <fo:table-row>
                                    <fo:table-cell><fo:block>
                                        <xsl:value-of select="$number"/>
                                    </fo:block></fo:table-cell>
                                    <fo:table-cell><fo:block>
                                        <xsl:value-of select="$date"/>
                                    </fo:block></fo:table-cell>
                                    <fo:table-cell><fo:block>
                                        <xsl:value-of select="$id"/>
                                    </fo:block></fo:table-cell>
                                    <fo:table-cell><fo:block>
                                        <xsl:value-of select="$title"/>
                                    </fo:block></fo:table-cell>
                                    <fo:table-cell><fo:block>
                                        <xsl:value-of select="$repository"/>
                                    </fo:block></fo:table-cell>
                                </fo:table-row>
                            </xsl:for-each>
                        </fo:table-body>
                    </fo:table>
                    
                </fo:flow>
            </fo:page-sequence>
        </fo:root>
    </xsl:template>
    
    <xsl:template match="tei:date">
        <xsl:choose>
            <xsl:when test="@when">
                <xsl:value-of select="local:process-date(@when)"/>
            </xsl:when>
            <xsl:when test="@notBefore and @notAfter">
                <xsl:text>zwischen </xsl:text>
                <xsl:value-of select="local:process-date(@notBefore)"/>
                <xsl:text> und </xsl:text>
                <xsl:value-of select="local:process-date(@notAfter)"/>
            </xsl:when>
            <xsl:when test="@notBefore">
                <xsl:text>nach </xsl:text>
                <xsl:value-of select="local:process-date(@notBefore)"/>
            </xsl:when>
            <xsl:when test="@notAfter">
                <xsl:text>vor </xsl:text>
                <xsl:value-of select="local:process-date(@notAfter)"/>
            </xsl:when>
            <xsl:otherwise>
                <xsl:text>unbekannt</xsl:text>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>
    
</xsl:stylesheet>