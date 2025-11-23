<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    xmlns:tei="http://www.tei-c.org/ns/1.0"
    xmlns:aid="http://ns.adobe.com/AdobeInDesign/4.0/"
    exclude-result-prefixes="xs"
    version="2.0">
    
    <xsl:output method="xml" encoding="UTF-8" media-type="text/xml" indent="no" omit-xml-declaration="no"/>
    
    <!-- Hier erfolgt noch etwas Formatierung: es werden Zeilenumbrüche eingefügt, wo nötig -->
    
    <xsl:template match="*|text()|@*">
        <xsl:copy>
            <xsl:apply-templates select="*|text()|@*"/>
        </xsl:copy>
    </xsl:template>
    
    <!-- Entfernt Leerzeichen am Ende des letzten Textknoten eines hi-Elements -->
    <xsl:template match="hi/text()[last()][ends-with(., ' ')]" priority="5">
        <xsl:value-of select="substring(., 1, string-length(.) - 1)"/>
    </xsl:template>
    
    <!-- Wenn der letzte Knoten innerhalb eines Kommentars ein Textknoten ist und dieser mit einem Leerzeichen endet, dann wird das Leerzeichen entfernt (da ein Punkt dahinter gesetzt wird) -->
    <xsl:template match="comment/node()[last()][self::text()][ends-with(., ' ')]">
        <xsl:value-of select="substring(., 1, string-length(.) - 1)"/>
    </xsl:template>
    
    <!-- entfernt Leerstellen direkt nach Fußnotenzeichen, wenn auf die Leerstelle ein Interpunktionszeichen folgt -->
    <xsl:template match="text()[preceding-sibling::node()[1][self::comment]][starts-with(., ' ')][substring(., 2, 1) = ('.', ',' , ';', ':', '?', '!')]" priority="10">
        <xsl:value-of select="substring(., 2)"/>
    </xsl:template>
    
    <xsl:template match="address">
        <xsl:if test="preceding-sibling::person">
            <xsl:text>&#10;</xsl:text>
        </xsl:if>
        <xsl:copy>
            <xsl:apply-templates select="@*"/>
            <xsl:apply-templates/>   
        </xsl:copy>
        <!--<xsl:text>&#10;</xsl:text>-->
    </xsl:template>
    
    <xsl:template match="closer">
        <xsl:if test="preceding-sibling::*">
            <xsl:text>&#10;</xsl:text>            
        </xsl:if>
        <xsl:copy>
            <xsl:apply-templates select="@*"/>
            <xsl:apply-templates/>   
        </xsl:copy>
        <xsl:if test="following-sibling::node()[1][self::text() and normalize-space() ne '']">
            <xsl:text>&#10;</xsl:text>
        </xsl:if>
        <!--<xsl:if test="following-sibling::*">
            <xsl:text>&#10;</xsl:text>
        </xsl:if>-->
    </xsl:template>
    
    <xsl:template match="paragraph | addrline | head | list | li | milestone | note">
        <!--<xsl:if test="self::addrline and not(preceding-sibling::addrline)">
            <xsl:text>&#10;</xsl:text>
        </xsl:if>-->
        <xsl:if test="preceding-sibling::*">
            <xsl:text>&#10;</xsl:text>            
        </xsl:if>
        <xsl:copy>
            <xsl:apply-templates select="@*"/>
            <xsl:apply-templates/>   
        </xsl:copy>
        <xsl:if test="following-sibling::node()[1][self::text() and normalize-space() ne '']">
            <xsl:text>&#10;</xsl:text>
        </xsl:if>
        <!--<xsl:text>&#10;</xsl:text>-->
    </xsl:template>
    
    <xsl:template match="table">
        <xsl:if test="not(parent::paragraph)">
            <xsl:text>&#10;</xsl:text>
        </xsl:if>
        <xsl:copy>
            <xsl:apply-templates select="@*"/>
            <xsl:apply-templates/>   
        </xsl:copy>
    </xsl:template>
    
    <xsl:template match="dateline">
        <xsl:if test="preceding-sibling::* and not(preceding-sibling::*[1][self::lb])">
            <xsl:text>&#10;</xsl:text>
        </xsl:if>
        <xsl:copy>
            <xsl:apply-templates select="@*"/>
            <xsl:apply-templates/>   
        </xsl:copy>
        <xsl:if test="following-sibling::* and not(following-sibling::*[1][self::paragraph] or following-sibling::*[1][self::addrline] or following-sibling::*[1][self::head])">
            <xsl:text>&#10;</xsl:text>
        </xsl:if>
    </xsl:template>
    
    <!-- Bei zwei aufeinanderfolgenden Umbrüchen wird nur einer ausgegeben -->
    <xsl:template match="lb">
        <xsl:if test="not(preceding-sibling::node()[1][self::lb])">
            <xsl:text>&#10;</xsl:text>            
        </xsl:if>
    </xsl:template>
    
    <!-- Fügt Punkt am Ende von Fußnoten hinzu -->
    <xsl:template match="comment">
        <xsl:copy>
            <xsl:apply-templates/>
            <xsl:if test="not(substring(./text()[last()], string-length(.), 1) = ('.', '?', '!'))">
                <xsl:text>.</xsl:text>
            </xsl:if>
        </xsl:copy>
    </xsl:template>
    
    <!-- ###### TABLES ###### -->
    
    <xsl:template match="row">
        <xsl:apply-templates/>
        <xsl:if test="following-sibling::row">
            <xsl:text>&#10;</xsl:text>
        </xsl:if>
    </xsl:template>
    
    <xsl:template match="cell">
        <xsl:apply-templates/>
        <xsl:if test="following-sibling::cell">
            <xsl:text>&#x9;</xsl:text>            
        </xsl:if>
    </xsl:template>
    
</xsl:stylesheet>