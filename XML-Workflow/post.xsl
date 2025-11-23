<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    xmlns:tei="http://www.tei-c.org/ns/1.0"
    exclude-result-prefixes="xs"
    version="2.0">
    
    <xsl:output method="xml" encoding="UTF-8" media-type="text/xml" indent="no" omit-xml-declaration="no"/>
    
    <!-- copy elements without namespaces -->
    
    <!-- template to copy elements -->
    <xsl:template match="*">
        <xsl:element name="{local-name()}">
            <xsl:apply-templates select="@* | node()"/>
        </xsl:element>
    </xsl:template>
    
    <!-- template to copy attributes -->
    <xsl:template match="@*">
        <xsl:copy-of select="."/>
    </xsl:template>
    
    <!-- template to copy the rest of the nodes -->
    <xsl:template match="text()">
        <xsl:copy/>
    </xsl:template>
    
    <!-- ########## IMPORTANT ########## -->
    <!-- Replace multiple spaces as well as tabs, newlines with one space (only inside the letter text!) -->
    <xsl:template match="text()[ancestor::tei:text or ancestor::notes]">
        <xsl:value-of select="replace(., '\s\s+', ' ')"/>
    </xsl:template>
    
</xsl:stylesheet>