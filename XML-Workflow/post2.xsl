<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    xmlns:tei="http://www.tei-c.org/ns/1.0"
    exclude-result-prefixes="xs"
    version="2.0">
    
    <xsl:output method="xml" encoding="UTF-8" media-type="text/xml" indent="no" omit-xml-declaration="no"/>
    
    <xsl:template match="*|text()|@*">
        <xsl:copy>
            <xsl:apply-templates select="*|text()|@*"/>
        </xsl:copy>
    </xsl:template>
    
    <!-- remove empty text nodes that are children of <text> -->
    <xsl:template match="text()[parent::text][normalize-space() eq '']" priority="5"/>
    
    <!-- Entfernt z. B. Leerzeichen direkt bei dem Beginn eines Absatzes -->
    <xsl:template match="*/descendant::text()[1][starts-with(., ' ')]">
        <xsl:value-of select="substring(., 2)"/>
    </xsl:template>
    
    <xsl:template match="text()[preceding-sibling::node()[1][self::lb]][starts-with(., ' ')]" priority="10">
        <xsl:value-of select="substring(., 2)"/>
    </xsl:template>
    
    <xsl:template match="text()[ancestor::dateline]" priority="15">
        <xsl:value-of select="normalize-space(.)"/>
    </xsl:template>
    
    <!-- entfernt Leerstellen direkt vor Fußnotenzeichen -->
    <xsl:template match="text()[following-sibling::node()[1][self::comment]][ends-with(., ' ')]" priority="10">
        <xsl:value-of select="substring(., 1, string-length(.) - 1)"/>
    </xsl:template>
    
    <!-- entfernt leere Textknoten innerhalb von Tabellen -->
    <xsl:template match="table//text()[normalize-space() eq '']" priority="20"/>
    
    
</xsl:stylesheet>