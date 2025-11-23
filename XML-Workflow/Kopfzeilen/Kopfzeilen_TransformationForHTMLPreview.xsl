<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    xmlns:aid="http://ns.adobe.com/AdobeInDesign/4.0/"
    exclude-result-prefixes="xs"
    version="2.0">
    
    <xsl:output method="html" encoding="UTF-8" media-type="text/html" indent="yes"/>
    
    <xsl:template match="/">
        <html lang="de">
            <head>
                <title>Breigzeilen für ASUE Print</title>
                <meta charset="uft-8"/>
                <style>
                    body {
                        width: 40%;
                        margin: auto;
                        font-size: 16pt;
                    }
                    .header {
                        margin-top: 32px;
                    }
                    .row {
                        display: flex;
                    }
                    .space-between {
                        justify-content: space-between;
                    }
                    .kopfzeile {
                        margin: 24px 0px;
                    }
                    .letter_number {
                        margin-right: 24px; 
                    }
                    .title {
                        font-variant-caps: small-caps;
                    }
                    .grow {
                        flex-grow: 1;
                    }
                    .admin {
                        font-size: 12pt;
                    }
                </style>
            </head>
            <body>
                <h3 class="header">Breigzeilen für die ASUE Printausgabe</h3>
                <ul class="admin">
                    <head>Fragen:</head>
                    <li>Nur eine Spitzklammer, wenn Datum und Ort unbekannt bzw. unsicher sind? (vgl. ASCC 13036)</li>
                    <li>Sollen in den Datumsangaben hinter Punkten schmale Leerzeichen gesetzt werden? (vgl. ASAB) => wird ganz am Ende für das gesamte Buch automatisiert eingefügt</li>
                    <li>Wie soll die Formatierung der Breigzeile aussehen, wenn die Autorenangabe mehrere Zeilen ausfüllt? Siehe z. B. ASCC 17748 => händisch in InDesign bearbeiten</li>
                </ul>
                <hr/>
                <xsl:for-each select="//headline">
                    <div id="{@letter}" class="{@aid:pstyle}">
                        <div class="row">
                            <div class="col">
                                <xsl:apply-templates select="number"/>
                            </div>
                            <div class="col grow">
                                <div class="row space-between">
                                    <div class="col">
                                        <xsl:apply-templates select="title"/>
                                    </div>
                                    <div class="col">
                                        <xsl:apply-templates select="idno[@type = 'ascc']"/>
                                    </div>
                                </div>
                                <div class="row space-between">
                                    <div class="col">
                                        <xsl:apply-templates select="./text()"/>
                                    </div>
                                    <div class="col">
                                        <xsl:apply-templates select="idno[@type = 'sv']"/>
                                    </div>
                                </div>
                            </div>
                        </div>
                    </div>
                </xsl:for-each>
            </body>
        </html>
    </xsl:template>
    
    <xsl:template match="number">
        <span class="{@aid:cstyle}">
            <xsl:apply-templates/>
        </span>
    </xsl:template>
    
    <xsl:template match="title">
        <span class="{@aid:cstyle}">
            <xsl:apply-templates/>
        </span>
    </xsl:template>
    
    <xsl:template match="idno">
        <span class="{@aid:cstyle}">
            <xsl:apply-templates/>
        </span>
    </xsl:template>
    
</xsl:stylesheet>