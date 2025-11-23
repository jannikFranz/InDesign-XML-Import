<?xml version="1.0" encoding="UTF-8"?>
<p:declare-step xmlns:p="http://www.w3.org/ns/xproc"
    xmlns:c="http://www.w3.org/ns/xproc-step"
    xmlns:tei="http://www.tei-c.org/ns/1.0"
    version="3.0"
    name="transformationForPrint">
    
    <!-- Input documents -->
    <p:input port="source" sequence="true">
        <p:document href="../../Documents/Schoenberg-UE/data/letters/1902/17616/17616.xml"/>
    </p:input>
    
    <!-- Output document -->
    <p:output port="result"/>
    
    <!-- Filter input (remove lost letters) -->
    <!--<p:filter select="not(//tei:TEI/@type eq 'lost')"/>-->
    
    <!--<p:directory-list path="./TestLettersForPrint" include-filter=".*xml"/>-->
    
    <!--<p:filter select="//*:title"/>-->
    
    <!-- Directory-List auswählen -->
    <!-- For each File, ... -->
    <!--<p:choose>
        <p:when test="//tei:TEI[not(@type eq 'lost')]">
            <!-\- Reihe von XSL-Transformationen -\->
        </p:when>
        <p:otherwise/>
    </p:choose>-->
    <!-- Zum Schluss alle Dateien aneinanderfügen -->
    <!--<p:for-each>
        
        <p:choose>
            <p:when test="//tei:TEI[not(@type eq 'lost')]">
            
            </p:when>
        </p:choose>
    </p:for-each>-->
    
    <!--<p:wrap-sequence wrapper="book"/>-->
    <!-- Pipeline steps -->
    <p:xslt name="Kopfzeile">
        <p:input port="source" select="collection('../../Documents/Schoenberg-UE/data/letters/?select=*.xml;recurse=yes')[not(substring-after(/tei:TEI/@xml:id, 'letter.') = ('9', '63', '64', '99', '357', '367', '387', '532', '574', '578', '594', '626', '641', '658', '702', '718', '726', '730', '799', '944', '947', '948', '985', '1112', '1174', '1184', '1211', '1214', '1220', '1249', '1249', '1261', '1309', '1332', '1338', '1412', '1708', '1711', '2265', '2308', '2760', '2788', '2806', '2827', '2836', '2919', '3575', '6389', '6848', '6858', '6860', '6892', '6898', '6918', '6930', '6931', '6944', '6951', '6975', '6976', '6983', '6991', '6998', '7002', '7003', '7014', '7017', '7023', '7033', '7041', '7056', '7066', '7066', '7069', '7070', '7071', '7075', '7076', '7080', '7083', '7105', '7106', '7121', '7122', '7123', '7126', '7133', '7134', '7140', '7143', '7144', '7148', '7156', '7170', '7172', '7173', '7175', '7178', '7181', '7184', '7192', '7198', '7219', '7231', '7253', '7279', '7279', '7718', '7927', '11569', '12367', '12368', '12369', '12370', '12371', '12372', '12382', '12424', '12426', '12428', '13001', '16818', '17355', '17490', '17493', '17508', '17514', '17519', '17522', '17561', '17568', '17570', '17575', '17576', '17587', '17593', '17594', '17596', '17603', '17619', '17629', '17637', '17638', '17640', '17641', '17644', '17645', '17650', '17651', '17653', '17661', '17664', '17667', '17684', '17684', '17688', '17693', '17696', '17713', '17718', '17721', '17737', '17755', '17757', '17764', '17766', '17768', '17779', '17780', '17784', '17789', '19875', '19878', '19879', '19883', '19890', '19897', '19914', '19915', '19929', '19934', '19938', '19954', '19956', '19970', '19971', '19978', '19980', '19989', '19994', '20009', '20019', '20021', '20022', '20028', '20031', '20038', '20040', '20042', '20059', '20063', '20099', '20121', '20137', '20141', '20152', '20156', '20185', '20186', '20224', '20225', '20249', '20322', '20323', '20324', '20326', '20691', '20714', '20715', '20719', '20723', '20726', '20731', '20914', '20916', '21436', '21773', '21775', '21780', '22618_hld', '22618_hlsd', '22653', '22680', '23623', '23852', '23853', '23854', '23855', '23946', '24365', '24376', '24540', '29323'))]"/> <!-- collection('TestLetters_Serie1?select=*.xml;recurse=yes') -->
      
        <p:input port="stylesheet">
            <p:document href="Kopfzeilen/Kopfzeilen.xsl"/>
        </p:input>
        <p:input port="parameters">
            <p:empty/>
        </p:input>
    </p:xslt>
    
    <!-- Zweite XSL-Transformation -->
    <p:xslt name="Brieftext">
        <p:input port="source">
            <p:pipe step="Kopfzeile" port="result"/>
        </p:input>
        <p:input port="stylesheet"> 
            <p:document href="Brieftext/Brieftext2.xsl"/>
        </p:input>
        <p:input port="parameters">
            <p:empty/>
        </p:input>
    </p:xslt>
    
    <!-- Post-Processing -->
    <!--Replace multiple spaces, line breaks and tabs with one space in all textnodes inside the letter text
         => the whole letter text is now one single line -->
    <p:xslt name="Postprocessing">
        <p:input port="source">
            <p:pipe step="Brieftext" port="result"/>
        </p:input>
        <p:input port="stylesheet">
            <p:document href="post.xsl"/>
        </p:input>
        <p:input port="parameters">
            <p:empty/>
        </p:input>
    </p:xslt>
    
    <!-- Remove single spaces at the start or end of text nodes where no space is intended -->
    <p:xslt name="Postprocessing-2">
        <p:input port="source">
            <p:pipe step="Postprocessing" port="result"/> 
        </p:input> 
        <p:input port="stylesheet"> 
            <p:document href="post2.xsl"/> 
        </p:input>
        <p:input port="parameters">
            <p:empty/>
        </p:input>
    </p:xslt>
    
    <!-- Add linebreaks where necessary! -->
    <p:xslt name="Postprocessing-3">
        <p:input port="source"> 
            <p:pipe step="Postprocessing-2" port="result"/> 
        </p:input> 
        <p:input port="stylesheet"> 
            <p:document href="post3.xsl"/> 
        </p:input>
        <p:input port="parameters">
            <p:empty/>
        </p:input>
    </p:xslt>
    
</p:declare-step>