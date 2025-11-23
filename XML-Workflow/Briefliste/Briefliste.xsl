<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    xmlns:tei="http://www.tei-c.org/ns/1.0"
    xmlns:local="lokal"
    exclude-result-prefixes="xs tei"
    version="3.0">
    
    <xsl:output method="html" encoding="UTF-8" indent="yes" omit-xml-declaration="no"/>
    <xsl:strip-space elements="*"/>
    
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
    
    <xsl:template match="/">
        <html>
            <head>
                <meta charset="UTF-8"/>
                <title>Briefliste für Print</title>
                <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet" integrity="sha384-9ndCyUaIbzAi2FUVXJi0CjmCapSmO7SnpJef0486qhLnuZ2cdeRhO02iuK6FUUVM" crossorigin="anonymous"/>
                <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/js/bootstrap.bundle.min.js" integrity="sha384-geWF76RCwLtnZ8qwWowPQNguL3RmwHVBC9FhGdlKrxdiJJigb/j/68SIy3Te4Bkz" crossorigin="anonymous"></script>
            </head>
            <body>
                <div class="container">
                    <table class="table table-borderless">
                        <thead>
                            <tr>
                                <th>Nr.</th>
                                <th>Datum</th>
                                <th>ASCC-Id</th>
                                <th>Brieftitel</th>
                                <th>Standort</th>
                            </tr>
                        </thead>
                        <tbody>
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
                                <tr>
                                    <td>
                                        <xsl:value-of select="$number"/>
                                    </td>
                                    <td>
                                        <xsl:value-of select="$date"/>
                                    </td>
                                    <td>
                                        <xsl:value-of select="$id"/>
                                    </td>
                                    <td>
                                        <xsl:value-of select="$title"/>
                                    </td>
                                    <td>
                                        <xsl:value-of select="$repository"/>
                                    </td>
                                </tr>
                            </xsl:for-each>
                        </tbody>
                    </table>
                </div>
            </body>
        </html>
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