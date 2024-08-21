<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="2.0">
    <!-- Template matching the form element -->
    <xsl:template match="form">
        <xsl:variable name="corresp" select="../@corresp"/>
        <xsl:variable name="existingEntry" select="document('')//entry[@corresp=$corresp]"/>
        <xsl:result-document href="output1.xml" method="xml">
            <root>
                <xsl:text>TEST</xsl:text>
            </root>
        </xsl:result-document>
        
        <xsl:choose>
            <xsl:when test="not($existingEntry)">
                <!-- Create a new entry element if it doesn't exist -->
                <xsl:element name="entry">
                    <xsl:attribute name="corresp">
                        <xsl:value-of select="$corresp"/>
                    </xsl:attribute>
                    <xsl:value-of select=".."/>
                </xsl:element>
            </xsl:when>
            <xsl:otherwise>
                <!-- Copy the form element into the existing entry -->
                <xsl:value-of select="."/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>
</xsl:stylesheet>