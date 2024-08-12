<?xml version="1.0" encoding="UTF-8" standalone="yes"?>
<xsl:stylesheet xmlns:iso="http://purl.oclc.org/dsdl/schematron"
                xmlns:rna="http://relaxng.org/ns/compatibility/annotations/1.0"
                xmlns:rng="http://relaxng.org/ns/structure/1.0"
                xmlns:saxon="http://saxon.sf.net/"
                xmlns:sch="http://purl.oclc.org/dsdl/schematron"
                xmlns:sch1x="http://www.ascc.net/xml/schematron"
                xmlns:schold="http://www.ascc.net/xml/schematron"
                xmlns:tei="http://www.tei-c.org/ns/1.0"
                xmlns:teix="http://www.tei-c.org/ns/Examples"
                xmlns:xhtml="http://www.w3.org/1999/xhtml"
                xmlns:xs="http://www.w3.org/2001/XMLSchema"
                xmlns:xsd="http://www.w3.org/2001/XMLSchema"
                xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                version="2.0"><!--Implementers: please note that overriding process-prolog or process-root is 
    the preferred method for meta-stylesheets to use where possible. -->
   <xsl:param name="archiveDirParameter"/>
   <xsl:param name="archiveNameParameter"/>
   <xsl:param name="fileNameParameter"/>
   <xsl:param name="fileDirParameter"/>
   <xsl:variable name="document-uri">
      <xsl:value-of select="document-uri(/)"/>
   </xsl:variable>
   <!--PHASES-->
   <!--PROLOG-->
   <xsl:output method="text"/>
   <!--XSD TYPES FOR XSLT2-->
   <!--KEYS AND FUNCTIONS-->
   <!--DEFAULT RULES-->
   <!--MODE: SCHEMATRON-SELECT-FULL-PATH-->
   <!--This mode can be used to generate an ugly though full XPath for locators-->
   <xsl:template match="*" mode="schematron-select-full-path">
      <xsl:apply-templates select="." mode="schematron-get-full-path"/>
   </xsl:template>
   <!--MODE: SCHEMATRON-FULL-PATH-->
   <!--This mode can be used to generate an ugly though full XPath for locators-->
   <xsl:template match="*" mode="schematron-get-full-path">
      <xsl:apply-templates select="parent::*" mode="schematron-get-full-path"/>
      <xsl:text>/</xsl:text>
      <xsl:choose>
         <xsl:when test="namespace-uri()=''">
            <xsl:value-of select="name()"/>
         </xsl:when>
         <xsl:otherwise>
            <xsl:text>*:</xsl:text>
            <xsl:value-of select="local-name()"/>
            <xsl:text>[namespace-uri()='</xsl:text>
            <xsl:value-of select="namespace-uri()"/>
            <xsl:text>']</xsl:text>
         </xsl:otherwise>
      </xsl:choose>
      <xsl:variable name="preceding"
                    select="count(preceding-sibling::*[local-name()=local-name(current())                                   and namespace-uri() = namespace-uri(current())])"/>
      <xsl:text>[</xsl:text>
      <xsl:value-of select="1+ $preceding"/>
      <xsl:text>]</xsl:text>
   </xsl:template>
   <xsl:template match="@*" mode="schematron-get-full-path">
      <xsl:apply-templates select="parent::*" mode="schematron-get-full-path"/>
      <xsl:text>/</xsl:text>
      <xsl:choose>
         <xsl:when test="namespace-uri()=''">@<xsl:value-of select="name()"/>
         </xsl:when>
         <xsl:otherwise>
            <xsl:text>@*[local-name()='</xsl:text>
            <xsl:value-of select="local-name()"/>
            <xsl:text>' and namespace-uri()='</xsl:text>
            <xsl:value-of select="namespace-uri()"/>
            <xsl:text>']</xsl:text>
         </xsl:otherwise>
      </xsl:choose>
   </xsl:template>
   <!--MODE: SCHEMATRON-FULL-PATH-2-->
   <!--This mode can be used to generate prefixed XPath for humans-->
   <xsl:template match="node() | @*" mode="schematron-get-full-path-2">
      <xsl:for-each select="ancestor-or-self::*">
         <xsl:text>/</xsl:text>
         <xsl:value-of select="name(.)"/>
         <xsl:if test="preceding-sibling::*[name(.)=name(current())]">
            <xsl:text>[</xsl:text>
            <xsl:value-of select="count(preceding-sibling::*[name(.)=name(current())])+1"/>
            <xsl:text>]</xsl:text>
         </xsl:if>
      </xsl:for-each>
      <xsl:if test="not(self::*)">
         <xsl:text/>/@<xsl:value-of select="name(.)"/>
      </xsl:if>
   </xsl:template>
   <!--MODE: SCHEMATRON-FULL-PATH-3-->
   <!--This mode can be used to generate prefixed XPath for humans 
	(Top-level element has index)-->
   <xsl:template match="node() | @*" mode="schematron-get-full-path-3">
      <xsl:for-each select="ancestor-or-self::*">
         <xsl:text>/</xsl:text>
         <xsl:value-of select="name(.)"/>
         <xsl:if test="parent::*">
            <xsl:text>[</xsl:text>
            <xsl:value-of select="count(preceding-sibling::*[name(.)=name(current())])+1"/>
            <xsl:text>]</xsl:text>
         </xsl:if>
      </xsl:for-each>
      <xsl:if test="not(self::*)">
         <xsl:text/>/@<xsl:value-of select="name(.)"/>
      </xsl:if>
   </xsl:template>
   <!--MODE: GENERATE-ID-FROM-PATH -->
   <xsl:template match="/" mode="generate-id-from-path"/>
   <xsl:template match="text()" mode="generate-id-from-path">
      <xsl:apply-templates select="parent::*" mode="generate-id-from-path"/>
      <xsl:value-of select="concat('.text-', 1+count(preceding-sibling::text()), '-')"/>
   </xsl:template>
   <xsl:template match="comment()" mode="generate-id-from-path">
      <xsl:apply-templates select="parent::*" mode="generate-id-from-path"/>
      <xsl:value-of select="concat('.comment-', 1+count(preceding-sibling::comment()), '-')"/>
   </xsl:template>
   <xsl:template match="processing-instruction()" mode="generate-id-from-path">
      <xsl:apply-templates select="parent::*" mode="generate-id-from-path"/>
      <xsl:value-of select="concat('.processing-instruction-', 1+count(preceding-sibling::processing-instruction()), '-')"/>
   </xsl:template>
   <xsl:template match="@*" mode="generate-id-from-path">
      <xsl:apply-templates select="parent::*" mode="generate-id-from-path"/>
      <xsl:value-of select="concat('.@', name())"/>
   </xsl:template>
   <xsl:template match="*" mode="generate-id-from-path" priority="-0.5">
      <xsl:apply-templates select="parent::*" mode="generate-id-from-path"/>
      <xsl:text>.</xsl:text>
      <xsl:value-of select="concat('.',name(),'-',1+count(preceding-sibling::*[name()=name(current())]),'-')"/>
   </xsl:template>
   <!--MODE: GENERATE-ID-2 -->
   <xsl:template match="/" mode="generate-id-2">U</xsl:template>
   <xsl:template match="*" mode="generate-id-2" priority="2">
      <xsl:text>U</xsl:text>
      <xsl:number level="multiple" count="*"/>
   </xsl:template>
   <xsl:template match="node()" mode="generate-id-2">
      <xsl:text>U.</xsl:text>
      <xsl:number level="multiple" count="*"/>
      <xsl:text>n</xsl:text>
      <xsl:number count="node()"/>
   </xsl:template>
   <xsl:template match="@*" mode="generate-id-2">
      <xsl:text>U.</xsl:text>
      <xsl:number level="multiple" count="*"/>
      <xsl:text>_</xsl:text>
      <xsl:value-of select="string-length(local-name(.))"/>
      <xsl:text>_</xsl:text>
      <xsl:value-of select="translate(name(),':','.')"/>
   </xsl:template>
   <!--Strip characters-->
   <xsl:template match="text()" priority="-1"/>
   <!--SCHEMA SETUP-->
   <xsl:template match="/">
      <xsl:apply-templates select="/" mode="M8"/>
      <xsl:apply-templates select="/" mode="M9"/>
      <xsl:apply-templates select="/" mode="M10"/>
      <xsl:apply-templates select="/" mode="M11"/>
      <xsl:apply-templates select="/" mode="M12"/>
      <xsl:apply-templates select="/" mode="M13"/>
      <xsl:apply-templates select="/" mode="M14"/>
      <xsl:apply-templates select="/" mode="M15"/>
      <xsl:apply-templates select="/" mode="M16"/>
      <xsl:apply-templates select="/" mode="M17"/>
      <xsl:apply-templates select="/" mode="M18"/>
      <xsl:apply-templates select="/" mode="M19"/>
      <xsl:apply-templates select="/" mode="M20"/>
      <xsl:apply-templates select="/" mode="M21"/>
      <xsl:apply-templates select="/" mode="M22"/>
      <xsl:apply-templates select="/" mode="M23"/>
      <xsl:apply-templates select="/" mode="M24"/>
      <xsl:apply-templates select="/" mode="M25"/>
      <xsl:apply-templates select="/" mode="M26"/>
      <xsl:apply-templates select="/" mode="M27"/>
      <xsl:apply-templates select="/" mode="M28"/>
      <xsl:apply-templates select="/" mode="M29"/>
      <xsl:apply-templates select="/" mode="M30"/>
      <xsl:apply-templates select="/" mode="M31"/>
      <xsl:apply-templates select="/" mode="M32"/>
      <xsl:apply-templates select="/" mode="M33"/>
      <xsl:apply-templates select="/" mode="M34"/>
      <xsl:apply-templates select="/" mode="M35"/>
      <xsl:apply-templates select="/" mode="M36"/>
      <xsl:apply-templates select="/" mode="M37"/>
      <xsl:apply-templates select="/" mode="M38"/>
      <xsl:apply-templates select="/" mode="M39"/>
      <xsl:apply-templates select="/" mode="M40"/>
      <xsl:apply-templates select="/" mode="M41"/>
      <xsl:apply-templates select="/" mode="M42"/>
      <xsl:apply-templates select="/" mode="M43"/>
      <xsl:apply-templates select="/" mode="M44"/>
      <xsl:apply-templates select="/" mode="M45"/>
      <xsl:apply-templates select="/" mode="M46"/>
      <xsl:apply-templates select="/" mode="M47"/>
      <xsl:apply-templates select="/" mode="M48"/>
      <xsl:apply-templates select="/" mode="M49"/>
      <xsl:apply-templates select="/" mode="M50"/>
      <xsl:apply-templates select="/" mode="M51"/>
      <xsl:apply-templates select="/" mode="M52"/>
      <xsl:apply-templates select="/" mode="M53"/>
      <xsl:apply-templates select="/" mode="M54"/>
      <xsl:apply-templates select="/" mode="M55"/>
      <xsl:apply-templates select="/" mode="M56"/>
      <xsl:apply-templates select="/" mode="M57"/>
      <xsl:apply-templates select="/" mode="M58"/>
      <xsl:apply-templates select="/" mode="M59"/>
      <xsl:apply-templates select="/" mode="M60"/>
      <xsl:apply-templates select="/" mode="M61"/>
      <xsl:apply-templates select="/" mode="M62"/>
      <xsl:apply-templates select="/" mode="M63"/>
      <xsl:apply-templates select="/" mode="M64"/>
      <xsl:apply-templates select="/" mode="M65"/>
      <xsl:apply-templates select="/" mode="M66"/>
      <xsl:apply-templates select="/" mode="M67"/>
      <xsl:apply-templates select="/" mode="M68"/>
      <xsl:apply-templates select="/" mode="M69"/>
      <xsl:apply-templates select="/" mode="M70"/>
      <xsl:apply-templates select="/" mode="M71"/>
      <xsl:apply-templates select="/" mode="M72"/>
      <xsl:apply-templates select="/" mode="M73"/>
      <xsl:apply-templates select="/" mode="M74"/>
      <xsl:apply-templates select="/" mode="M75"/>
      <xsl:apply-templates select="/" mode="M76"/>
      <xsl:apply-templates select="/" mode="M77"/>
      <xsl:apply-templates select="/" mode="M78"/>
      <xsl:apply-templates select="/" mode="M79"/>
      <xsl:apply-templates select="/" mode="M80"/>
      <xsl:apply-templates select="/" mode="M81"/>
      <xsl:apply-templates select="/" mode="M82"/>
      <xsl:apply-templates select="/" mode="M83"/>
      <xsl:apply-templates select="/" mode="M84"/>
      <xsl:apply-templates select="/" mode="M85"/>
      <xsl:apply-templates select="/" mode="M86"/>
      <xsl:apply-templates select="/" mode="M87"/>
      <xsl:apply-templates select="/" mode="M88"/>
      <xsl:apply-templates select="/" mode="M89"/>
      <xsl:apply-templates select="/" mode="M90"/>
      <xsl:apply-templates select="/" mode="M91"/>
      <xsl:apply-templates select="/" mode="M92"/>
      <xsl:apply-templates select="/" mode="M93"/>
      <xsl:apply-templates select="/" mode="M94"/>
      <xsl:apply-templates select="/" mode="M95"/>
      <xsl:apply-templates select="/" mode="M96"/>
      <xsl:apply-templates select="/" mode="M97"/>
      <xsl:apply-templates select="/" mode="M98"/>
      <xsl:apply-templates select="/" mode="M99"/>
      <xsl:apply-templates select="/" mode="M100"/>
      <xsl:apply-templates select="/" mode="M101"/>
      <xsl:apply-templates select="/" mode="M102"/>
      <xsl:apply-templates select="/" mode="M103"/>
      <xsl:apply-templates select="/" mode="M104"/>
      <xsl:apply-templates select="/" mode="M105"/>
      <xsl:apply-templates select="/" mode="M106"/>
      <xsl:apply-templates select="/" mode="M107"/>
      <xsl:apply-templates select="/" mode="M108"/>
      <xsl:apply-templates select="/" mode="M109"/>
      <xsl:apply-templates select="/" mode="M110"/>
      <xsl:apply-templates select="/" mode="M111"/>
      <xsl:apply-templates select="/" mode="M112"/>
      <xsl:apply-templates select="/" mode="M113"/>
      <xsl:apply-templates select="/" mode="M114"/>
      <xsl:apply-templates select="/" mode="M115"/>
      <xsl:apply-templates select="/" mode="M116"/>
      <xsl:apply-templates select="/" mode="M117"/>
      <xsl:apply-templates select="/" mode="M118"/>
      <xsl:apply-templates select="/" mode="M119"/>
      <xsl:apply-templates select="/" mode="M120"/>
      <xsl:apply-templates select="/" mode="M121"/>
      <xsl:apply-templates select="/" mode="M122"/>
      <xsl:apply-templates select="/" mode="M123"/>
      <xsl:apply-templates select="/" mode="M124"/>
      <xsl:apply-templates select="/" mode="M125"/>
      <xsl:apply-templates select="/" mode="M126"/>
      <xsl:apply-templates select="/" mode="M127"/>
      <xsl:apply-templates select="/" mode="M128"/>
      <xsl:apply-templates select="/" mode="M129"/>
      <xsl:apply-templates select="/" mode="M130"/>
      <xsl:apply-templates select="/" mode="M131"/>
      <xsl:apply-templates select="/" mode="M132"/>
      <xsl:apply-templates select="/" mode="M133"/>
      <xsl:apply-templates select="/" mode="M134"/>
      <xsl:apply-templates select="/" mode="M135"/>
      <xsl:apply-templates select="/" mode="M136"/>
      <xsl:apply-templates select="/" mode="M137"/>
      <xsl:apply-templates select="/" mode="M138"/>
      <xsl:apply-templates select="/" mode="M139"/>
      <xsl:apply-templates select="/" mode="M140"/>
      <xsl:apply-templates select="/" mode="M141"/>
      <xsl:apply-templates select="/" mode="M142"/>
      <xsl:apply-templates select="/" mode="M143"/>
      <xsl:apply-templates select="/" mode="M144"/>
      <xsl:apply-templates select="/" mode="M145"/>
      <xsl:apply-templates select="/" mode="M146"/>
      <xsl:apply-templates select="/" mode="M147"/>
      <xsl:apply-templates select="/" mode="M148"/>
      <xsl:apply-templates select="/" mode="M149"/>
      <xsl:apply-templates select="/" mode="M150"/>
      <xsl:apply-templates select="/" mode="M151"/>
      <xsl:apply-templates select="/" mode="M152"/>
      <xsl:apply-templates select="/" mode="M153"/>
      <xsl:apply-templates select="/" mode="M154"/>
      <xsl:apply-templates select="/" mode="M155"/>
      <xsl:apply-templates select="/" mode="M156"/>
      <xsl:apply-templates select="/" mode="M157"/>
      <xsl:apply-templates select="/" mode="M158"/>
      <xsl:apply-templates select="/" mode="M159"/>
      <xsl:apply-templates select="/" mode="M160"/>
      <xsl:apply-templates select="/" mode="M161"/>
      <xsl:apply-templates select="/" mode="M162"/>
      <xsl:apply-templates select="/" mode="M163"/>
      <xsl:apply-templates select="/" mode="M164"/>
      <xsl:apply-templates select="/" mode="M165"/>
      <xsl:apply-templates select="/" mode="M166"/>
      <xsl:apply-templates select="/" mode="M167"/>
      <xsl:apply-templates select="/" mode="M168"/>
      <xsl:apply-templates select="/" mode="M169"/>
      <xsl:apply-templates select="/" mode="M170"/>
      <xsl:apply-templates select="/" mode="M171"/>
      <xsl:apply-templates select="/" mode="M172"/>
      <xsl:apply-templates select="/" mode="M173"/>
      <xsl:apply-templates select="/" mode="M174"/>
      <xsl:apply-templates select="/" mode="M175"/>
      <xsl:apply-templates select="/" mode="M176"/>
      <xsl:apply-templates select="/" mode="M177"/>
      <xsl:apply-templates select="/" mode="M178"/>
      <xsl:apply-templates select="/" mode="M179"/>
      <xsl:apply-templates select="/" mode="M180"/>
      <xsl:apply-templates select="/" mode="M181"/>
      <xsl:apply-templates select="/" mode="M182"/>
      <xsl:apply-templates select="/" mode="M183"/>
      <xsl:apply-templates select="/" mode="M184"/>
      <xsl:apply-templates select="/" mode="M185"/>
      <xsl:apply-templates select="/" mode="M186"/>
      <xsl:apply-templates select="/" mode="M187"/>
      <xsl:apply-templates select="/" mode="M188"/>
      <xsl:apply-templates select="/" mode="M189"/>
      <xsl:apply-templates select="/" mode="M190"/>
      <xsl:apply-templates select="/" mode="M191"/>
      <xsl:apply-templates select="/" mode="M192"/>
      <xsl:apply-templates select="/" mode="M193"/>
      <xsl:apply-templates select="/" mode="M194"/>
      <xsl:apply-templates select="/" mode="M195"/>
      <xsl:apply-templates select="/" mode="M196"/>
      <xsl:apply-templates select="/" mode="M197"/>
      <xsl:apply-templates select="/" mode="M198"/>
      <xsl:apply-templates select="/" mode="M199"/>
      <xsl:apply-templates select="/" mode="M200"/>
      <xsl:apply-templates select="/" mode="M201"/>
      <xsl:apply-templates select="/" mode="M202"/>
      <xsl:apply-templates select="/" mode="M203"/>
      <xsl:apply-templates select="/" mode="M204"/>
      <xsl:apply-templates select="/" mode="M205"/>
      <xsl:apply-templates select="/" mode="M206"/>
      <xsl:apply-templates select="/" mode="M207"/>
      <xsl:apply-templates select="/" mode="M208"/>
      <xsl:apply-templates select="/" mode="M209"/>
      <xsl:apply-templates select="/" mode="M210"/>
      <xsl:apply-templates select="/" mode="M211"/>
      <xsl:apply-templates select="/" mode="M212"/>
      <xsl:apply-templates select="/" mode="M213"/>
      <xsl:apply-templates select="/" mode="M214"/>
      <xsl:apply-templates select="/" mode="M215"/>
      <xsl:apply-templates select="/" mode="M216"/>
      <xsl:apply-templates select="/" mode="M217"/>
      <xsl:apply-templates select="/" mode="M218"/>
      <xsl:apply-templates select="/" mode="M219"/>
      <xsl:apply-templates select="/" mode="M220"/>
      <xsl:apply-templates select="/" mode="M221"/>
      <xsl:apply-templates select="/" mode="M222"/>
      <xsl:apply-templates select="/" mode="M223"/>
      <xsl:apply-templates select="/" mode="M224"/>
      <xsl:apply-templates select="/" mode="M225"/>
      <xsl:apply-templates select="/" mode="M226"/>
      <xsl:apply-templates select="/" mode="M227"/>
      <xsl:apply-templates select="/" mode="M228"/>
      <xsl:apply-templates select="/" mode="M229"/>
      <xsl:apply-templates select="/" mode="M230"/>
      <xsl:apply-templates select="/" mode="M231"/>
      <xsl:apply-templates select="/" mode="M232"/>
      <xsl:apply-templates select="/" mode="M233"/>
      <xsl:apply-templates select="/" mode="M234"/>
      <xsl:apply-templates select="/" mode="M235"/>
      <xsl:apply-templates select="/" mode="M236"/>
      <xsl:apply-templates select="/" mode="M237"/>
      <xsl:apply-templates select="/" mode="M238"/>
      <xsl:apply-templates select="/" mode="M239"/>
      <xsl:apply-templates select="/" mode="M240"/>
      <xsl:apply-templates select="/" mode="M241"/>
      <xsl:apply-templates select="/" mode="M242"/>
   </xsl:template>
   <!--SCHEMATRON PATTERNS-->
   <!--PATTERN schematron-constraint-tei_all-att.datable.w3c-att-datable-w3c-when-1-->
   <!--RULE -->
   <xsl:template match="tei:*[@when]" priority="1000" mode="M8">

		<!--REPORT nonfatal-->
      <xsl:if test="@notBefore|@notAfter|@from|@to">
         <xsl:message>The @when attribute cannot be used with any other att.datable.w3c attributes. (@notBefore|@notAfter|@from|@to / nonfatal)</xsl:message>
      </xsl:if>
      <xsl:apply-templates select="*" mode="M8"/>
   </xsl:template>
   <xsl:template match="text()" priority="-1" mode="M8"/>
   <xsl:template match="@*|node()" priority="-2" mode="M8">
      <xsl:apply-templates select="*" mode="M8"/>
   </xsl:template>
   <!--PATTERN schematron-constraint-tei_all-att.datable.w3c-att-datable-w3c-from-2-->
   <!--RULE -->
   <xsl:template match="tei:*[@from]" priority="1000" mode="M9">

		<!--REPORT nonfatal-->
      <xsl:if test="@notBefore">
         <xsl:message>The @from and @notBefore attributes cannot be used together. (@notBefore / nonfatal)</xsl:message>
      </xsl:if>
      <xsl:apply-templates select="*" mode="M9"/>
   </xsl:template>
   <xsl:template match="text()" priority="-1" mode="M9"/>
   <xsl:template match="@*|node()" priority="-2" mode="M9">
      <xsl:apply-templates select="*" mode="M9"/>
   </xsl:template>
   <!--PATTERN schematron-constraint-tei_all-att.datable.w3c-att-datable-w3c-to-3-->
   <!--RULE -->
   <xsl:template match="tei:*[@to]" priority="1000" mode="M10">

		<!--REPORT nonfatal-->
      <xsl:if test="@notAfter">
         <xsl:message>The @to and @notAfter attributes cannot be used together. (@notAfter / nonfatal)</xsl:message>
      </xsl:if>
      <xsl:apply-templates select="*" mode="M10"/>
   </xsl:template>
   <xsl:template match="text()" priority="-1" mode="M10"/>
   <xsl:template match="@*|node()" priority="-2" mode="M10">
      <xsl:apply-templates select="*" mode="M10"/>
   </xsl:template>
   <!--PATTERN schematron-constraint-tei_all-att.global.source-source-only_1_ODD_source-4-->
   <!--RULE -->
   <xsl:template match="tei:*[@source]" priority="1000" mode="M11">
      <xsl:variable name="srcs" select="tokenize( normalize-space(@source),' ')"/>
      <!--REPORT -->
      <xsl:if test="( self::tei:classRef               | self::tei:dataRef               | self::tei:elementRef               | self::tei:macroRef               | self::tei:moduleRef               | self::tei:schemaSpec )               and               $srcs[2]">
         <xsl:message>
              When used on a schema description element (like
              <xsl:text/>
            <xsl:value-of select="name(.)"/>
            <xsl:text/>), the @source attribute
              should have only 1 value. (This one has <xsl:text/>
            <xsl:value-of select="count($srcs)"/>
            <xsl:text/>.)
             (( self::tei:classRef | self::tei:dataRef | self::tei:elementRef | self::tei:macroRef | self::tei:moduleRef | self::tei:schemaSpec ) and $srcs[2])</xsl:message>
      </xsl:if>
      <xsl:apply-templates select="*" mode="M11"/>
   </xsl:template>
   <xsl:template match="text()" priority="-1" mode="M11"/>
   <xsl:template match="@*|node()" priority="-2" mode="M11">
      <xsl:apply-templates select="*" mode="M11"/>
   </xsl:template>
   <!--PATTERN schematron-constraint-tei_all-att.measurement-att-measurement-unitRef-5-->
   <!--RULE -->
   <xsl:template match="tei:*[@unitRef]" priority="1000" mode="M12">

		<!--REPORT info-->
      <xsl:if test="@unit">
         <xsl:message>The @unit attribute may be unnecessary when @unitRef is present. (@unit / info)</xsl:message>
      </xsl:if>
      <xsl:apply-templates select="*" mode="M12"/>
   </xsl:template>
   <xsl:template match="text()" priority="-1" mode="M12"/>
   <xsl:template match="@*|node()" priority="-2" mode="M12">
      <xsl:apply-templates select="*" mode="M12"/>
   </xsl:template>
   <!--PATTERN schematron-constraint-tei_all-att.typed-subtypeTyped-6-->
   <!--RULE -->
   <xsl:template match="tei:*[@subtype]" priority="1000" mode="M13">

		<!--ASSERT -->
      <xsl:choose>
         <xsl:when test="@type"/>
         <xsl:otherwise>
            <xsl:message>The <xsl:text/>
               <xsl:value-of select="name(.)"/>
               <xsl:text/> element should not be categorized in detail with @subtype unless also categorized in general with @type (@type)</xsl:message>
         </xsl:otherwise>
      </xsl:choose>
      <xsl:apply-templates select="*" mode="M13"/>
   </xsl:template>
   <xsl:template match="text()" priority="-1" mode="M13"/>
   <xsl:template match="@*|node()" priority="-2" mode="M13">
      <xsl:apply-templates select="*" mode="M13"/>
   </xsl:template>
   <!--PATTERN schematron-constraint-tei_all-att.pointing-targetLang-targetLang-7-->
   <!--RULE -->
   <xsl:template match="tei:*[not(self::tei:schemaSpec)][@targetLang]"
                 priority="1000"
                 mode="M14">

		<!--ASSERT -->
      <xsl:choose>
         <xsl:when test="@target"/>
         <xsl:otherwise>
            <xsl:message>@targetLang should only be used on <xsl:text/>
               <xsl:value-of select="name(.)"/>
               <xsl:text/> if @target is specified. (@target)</xsl:message>
         </xsl:otherwise>
      </xsl:choose>
      <xsl:apply-templates select="*" mode="M14"/>
   </xsl:template>
   <xsl:template match="text()" priority="-1" mode="M14"/>
   <xsl:template match="@*|node()" priority="-2" mode="M14">
      <xsl:apply-templates select="*" mode="M14"/>
   </xsl:template>
   <!--PATTERN schematron-constraint-tei_all-att.spanning-spanTo-spanTo-points-to-following-8-->
   <!--RULE -->
   <xsl:template match="tei:*[@spanTo]" priority="1000" mode="M15">

		<!--ASSERT -->
      <xsl:choose>
         <xsl:when test="id(substring(@spanTo,2)) and following::*[@xml:id=substring(current()/@spanTo,2)]"/>
         <xsl:otherwise>
            <xsl:message>
The element indicated by @spanTo (<xsl:text/>
               <xsl:value-of select="@spanTo"/>
               <xsl:text/>) must follow the current element <xsl:text/>
               <xsl:value-of select="name(.)"/>
               <xsl:text/>
          (id(substring(@spanTo,2)) and following::*[@xml:id=substring(current()/@spanTo,2)])</xsl:message>
         </xsl:otherwise>
      </xsl:choose>
      <xsl:apply-templates select="*" mode="M15"/>
   </xsl:template>
   <xsl:template match="text()" priority="-1" mode="M15"/>
   <xsl:template match="@*|node()" priority="-2" mode="M15">
      <xsl:apply-templates select="*" mode="M15"/>
   </xsl:template>
   <!--PATTERN schematron-constraint-tei_all-att.styleDef-schemeVersion-schemeVersionRequiresScheme-9-->
   <!--RULE -->
   <xsl:template match="tei:*[@schemeVersion]" priority="1000" mode="M16">

		<!--ASSERT -->
      <xsl:choose>
         <xsl:when test="@scheme and not(@scheme = 'free')"/>
         <xsl:otherwise>
            <xsl:message>
              @schemeVersion can only be used if @scheme is specified.
             (@scheme and not(@scheme = 'free'))</xsl:message>
         </xsl:otherwise>
      </xsl:choose>
      <xsl:apply-templates select="*" mode="M16"/>
   </xsl:template>
   <xsl:template match="text()" priority="-1" mode="M16"/>
   <xsl:template match="@*|node()" priority="-2" mode="M16">
      <xsl:apply-templates select="*" mode="M16"/>
   </xsl:template>
   <!--PATTERN schematron-constraint-tei_all-att.calendarSystem-calendar-calendar-10-->
   <!--RULE -->
   <xsl:template match="tei:*[@calendar]" priority="1000" mode="M17">

		<!--ASSERT -->
      <xsl:choose>
         <xsl:when test="string-length( normalize-space(.) ) gt 0"/>
         <xsl:otherwise>
            <xsl:message> @calendar indicates one or more
              systems or calendars to which the date represented by the content of this element belongs,
              but this <xsl:text/>
               <xsl:value-of select="name(.)"/>
               <xsl:text/> element has no textual content. (string-length( normalize-space(.) ) gt 0)</xsl:message>
         </xsl:otherwise>
      </xsl:choose>
      <xsl:apply-templates select="*" mode="M17"/>
   </xsl:template>
   <xsl:template match="text()" priority="-1" mode="M17"/>
   <xsl:template match="@*|node()" priority="-2" mode="M17">
      <xsl:apply-templates select="*" mode="M17"/>
   </xsl:template>
   <!--PATTERN schematron-constraint-tei_all-p-abstractModel-structure-p-in-ab-or-p-11-->
   <!--RULE -->
   <xsl:template match="tei:p" priority="1000" mode="M18">

		<!--REPORT -->
      <xsl:if test="(ancestor::tei:ab or ancestor::tei:p) and not( ancestor::tei:floatingText |parent::tei:exemplum |parent::tei:item |parent::tei:note |parent::tei:q |parent::tei:quote |parent::tei:remarks |parent::tei:said |parent::tei:sp |parent::tei:stage |parent::tei:cell |parent::tei:figure )">
         <xsl:message>
        Abstract model violation: Paragraphs may not occur inside other paragraphs or ab elements.
       ((ancestor::tei:ab or ancestor::tei:p) and not( ancestor::tei:floatingText |parent::tei:exemplum |parent::tei:item |parent::tei:note |parent::tei:q |parent::tei:quote |parent::tei:remarks |parent::tei:said |parent::tei:sp |parent::tei:stage |parent::tei:cell |parent::tei:figure ))</xsl:message>
      </xsl:if>
      <xsl:apply-templates select="*" mode="M18"/>
   </xsl:template>
   <xsl:template match="text()" priority="-1" mode="M18"/>
   <xsl:template match="@*|node()" priority="-2" mode="M18">
      <xsl:apply-templates select="*" mode="M18"/>
   </xsl:template>
   <!--PATTERN schematron-constraint-tei_all-p-abstractModel-structure-p-in-l-or-lg-12-->
   <!--RULE -->
   <xsl:template match="tei:p" priority="1000" mode="M19">

		<!--REPORT -->
      <xsl:if test="(ancestor::tei:l or ancestor::tei:lg) and not( ancestor::tei:floatingText |parent::tei:figure |parent::tei:note )">
         <xsl:message>
        Abstract model violation: Lines may not contain higher-level structural elements such as div, p, or ab, unless p is a child of figure or note, or is a descendant of floatingText.
       ((ancestor::tei:l or ancestor::tei:lg) and not( ancestor::tei:floatingText |parent::tei:figure |parent::tei:note ))</xsl:message>
      </xsl:if>
      <xsl:apply-templates select="*" mode="M19"/>
   </xsl:template>
   <xsl:template match="text()" priority="-1" mode="M19"/>
   <xsl:template match="@*|node()" priority="-2" mode="M19">
      <xsl:apply-templates select="*" mode="M19"/>
   </xsl:template>
   <!--PATTERN schematron-constraint-tei_all-desc-deprecationInfo-only-in-deprecated-13-->
   <!--RULE -->
   <xsl:template match="tei:desc[ @type eq 'deprecationInfo']"
                 priority="1000"
                 mode="M20">

		<!--ASSERT -->
      <xsl:choose>
         <xsl:when test="../@validUntil"/>
         <xsl:otherwise>
            <xsl:message>Information about a
        deprecation should only be present in a specification element
        that is being deprecated: that is, only an element that has a
        @validUntil attribute should have a child &lt;desc
        type="deprecationInfo"&gt;. (../@validUntil)</xsl:message>
         </xsl:otherwise>
      </xsl:choose>
      <xsl:apply-templates select="*" mode="M20"/>
   </xsl:template>
   <xsl:template match="text()" priority="-1" mode="M20"/>
   <xsl:template match="@*|node()" priority="-2" mode="M20">
      <xsl:apply-templates select="*" mode="M20"/>
   </xsl:template>
   <!--PATTERN schematron-constraint-tei_all-rt-target-rt-target-not-span-14-->
   <!--RULE -->
   <xsl:template match="tei:rt/@target" priority="1000" mode="M21">

		<!--REPORT -->
      <xsl:if test="../@from | ../@to">
         <xsl:message>When target= is
            present, neither from= nor to= should be. (../@from | ../@to)</xsl:message>
      </xsl:if>
   </xsl:template>
   <xsl:template match="text()" priority="-1" mode="M21"/>
   <xsl:template match="@*|node()" priority="-2" mode="M21">
      <xsl:apply-templates select="*" mode="M21"/>
   </xsl:template>
   <!--PATTERN schematron-constraint-tei_all-rt-from-rt-from-15-->
   <!--RULE -->
   <xsl:template match="tei:rt/@from" priority="1000" mode="M22">

		<!--ASSERT -->
      <xsl:choose>
         <xsl:when test="../@to"/>
         <xsl:otherwise>
            <xsl:message>When from= is present, the to=
            attribute of <xsl:text/>
               <xsl:value-of select="name(.)"/>
               <xsl:text/> is required. (../@to)</xsl:message>
         </xsl:otherwise>
      </xsl:choose>
   </xsl:template>
   <xsl:template match="text()" priority="-1" mode="M22"/>
   <xsl:template match="@*|node()" priority="-2" mode="M22">
      <xsl:apply-templates select="*" mode="M22"/>
   </xsl:template>
   <!--PATTERN schematron-constraint-tei_all-rt-to-rt-to-16-->
   <!--RULE -->
   <xsl:template match="tei:rt/@to" priority="1000" mode="M23">

		<!--ASSERT -->
      <xsl:choose>
         <xsl:when test="../@from"/>
         <xsl:otherwise>
            <xsl:message>When to= is present, the from=
            attribute of <xsl:text/>
               <xsl:value-of select="name(.)"/>
               <xsl:text/> is required. (../@from)</xsl:message>
         </xsl:otherwise>
      </xsl:choose>
   </xsl:template>
   <xsl:template match="text()" priority="-1" mode="M23"/>
   <xsl:template match="@*|node()" priority="-2" mode="M23">
      <xsl:apply-templates select="*" mode="M23"/>
   </xsl:template>
   <!--PATTERN schematron-constraint-tei_all-name-calendar-calendar-check-name-17-->
   <!--RULE -->
   <xsl:template match="tei:*[@calendar]" priority="1000" mode="M24">

		<!--ASSERT -->
      <xsl:choose>
         <xsl:when test="string-length( normalize-space(.) ) gt 0"/>
         <xsl:otherwise>
            <xsl:message> @calendar indicates one or more
                        systems or calendars to which the date represented by the content of this element belongs,
                        but this <xsl:text/>
               <xsl:value-of select="name(.)"/>
               <xsl:text/> element has no textual content. (string-length( normalize-space(.) ) gt 0)</xsl:message>
         </xsl:otherwise>
      </xsl:choose>
      <xsl:apply-templates select="*" mode="M24"/>
   </xsl:template>
   <xsl:template match="text()" priority="-1" mode="M24"/>
   <xsl:template match="@*|node()" priority="-2" mode="M24">
      <xsl:apply-templates select="*" mode="M24"/>
   </xsl:template>
   <!--PATTERN schematron-constraint-tei_all-ptr-ptrAtts-18-->
   <!--RULE -->
   <xsl:template match="tei:ptr" priority="1000" mode="M25">

		<!--REPORT -->
      <xsl:if test="@target and @cRef">
         <xsl:message>Only one of the
attributes @target and @cRef may be supplied on <xsl:text/>
            <xsl:value-of select="name(.)"/>
            <xsl:text/>. (@target and @cRef)</xsl:message>
      </xsl:if>
      <xsl:apply-templates select="*" mode="M25"/>
   </xsl:template>
   <xsl:template match="text()" priority="-1" mode="M25"/>
   <xsl:template match="@*|node()" priority="-2" mode="M25">
      <xsl:apply-templates select="*" mode="M25"/>
   </xsl:template>
   <!--PATTERN schematron-constraint-tei_all-ref-refAtts-19-->
   <!--RULE -->
   <xsl:template match="tei:ref" priority="1000" mode="M26">

		<!--REPORT -->
      <xsl:if test="@target and @cRef">
         <xsl:message>Only one of the
	attributes @target' and @cRef' may be supplied on <xsl:text/>
            <xsl:value-of select="name(.)"/>
            <xsl:text/>
          (@target and @cRef)</xsl:message>
      </xsl:if>
      <xsl:apply-templates select="*" mode="M26"/>
   </xsl:template>
   <xsl:template match="text()" priority="-1" mode="M26"/>
   <xsl:template match="@*|node()" priority="-2" mode="M26">
      <xsl:apply-templates select="*" mode="M26"/>
   </xsl:template>
   <!--PATTERN schematron-constraint-tei_all-list-gloss-list-must-have-labels-20-->
   <!--RULE -->
   <xsl:template match="tei:list[@type='gloss']" priority="1000" mode="M27">

		<!--ASSERT -->
      <xsl:choose>
         <xsl:when test="tei:label"/>
         <xsl:otherwise>
            <xsl:message>The content of a "gloss" list should include a sequence of one or more pairs of a label element followed by an item element (tei:label)</xsl:message>
         </xsl:otherwise>
      </xsl:choose>
      <xsl:apply-templates select="*" mode="M27"/>
   </xsl:template>
   <xsl:template match="text()" priority="-1" mode="M27"/>
   <xsl:template match="@*|node()" priority="-2" mode="M27">
      <xsl:apply-templates select="*" mode="M27"/>
   </xsl:template>
   <!--PATTERN schematron-constraint-tei_all-author-calendar-calendar-check-author-21-->
   <!--RULE -->
   <xsl:template match="tei:*[@calendar]" priority="1000" mode="M28">

		<!--ASSERT -->
      <xsl:choose>
         <xsl:when test="string-length( normalize-space(.) ) gt 0"/>
         <xsl:otherwise>
            <xsl:message> @calendar indicates one or more
                        systems or calendars to which the date represented by the content of this element belongs,
                        but this <xsl:text/>
               <xsl:value-of select="name(.)"/>
               <xsl:text/> element has no textual content. (string-length( normalize-space(.) ) gt 0)</xsl:message>
         </xsl:otherwise>
      </xsl:choose>
      <xsl:apply-templates select="*" mode="M28"/>
   </xsl:template>
   <xsl:template match="text()" priority="-1" mode="M28"/>
   <xsl:template match="@*|node()" priority="-2" mode="M28">
      <xsl:apply-templates select="*" mode="M28"/>
   </xsl:template>
   <!--PATTERN schematron-constraint-tei_all-editor-calendar-calendar-check-editor-22-->
   <!--RULE -->
   <xsl:template match="tei:*[@calendar]" priority="1000" mode="M29">

		<!--ASSERT -->
      <xsl:choose>
         <xsl:when test="string-length( normalize-space(.) ) gt 0"/>
         <xsl:otherwise>
            <xsl:message> @calendar indicates one or more
                        systems or calendars to which the date represented by the content of this element belongs,
                        but this <xsl:text/>
               <xsl:value-of select="name(.)"/>
               <xsl:text/> element has no textual content. (string-length( normalize-space(.) ) gt 0)</xsl:message>
         </xsl:otherwise>
      </xsl:choose>
      <xsl:apply-templates select="*" mode="M29"/>
   </xsl:template>
   <xsl:template match="text()" priority="-1" mode="M29"/>
   <xsl:template match="@*|node()" priority="-2" mode="M29">
      <xsl:apply-templates select="*" mode="M29"/>
   </xsl:template>
   <!--PATTERN schematron-constraint-tei_all-resp-calendar-calendar-check-resp-23-->
   <!--RULE -->
   <xsl:template match="tei:*[@calendar]" priority="1000" mode="M30">

		<!--ASSERT -->
      <xsl:choose>
         <xsl:when test="string-length( normalize-space(.) ) gt 0"/>
         <xsl:otherwise>
            <xsl:message> @calendar indicates one or more
                        systems or calendars to which the date represented by the content of this element belongs,
                        but this <xsl:text/>
               <xsl:value-of select="name(.)"/>
               <xsl:text/> element has no textual content. (string-length( normalize-space(.) ) gt 0)</xsl:message>
         </xsl:otherwise>
      </xsl:choose>
      <xsl:apply-templates select="*" mode="M30"/>
   </xsl:template>
   <xsl:template match="text()" priority="-1" mode="M30"/>
   <xsl:template match="@*|node()" priority="-2" mode="M30">
      <xsl:apply-templates select="*" mode="M30"/>
   </xsl:template>
   <!--PATTERN schematron-constraint-tei_all-title-calendar-calendar-check-title-24-->
   <!--RULE -->
   <xsl:template match="tei:*[@calendar]" priority="1000" mode="M31">

		<!--ASSERT -->
      <xsl:choose>
         <xsl:when test="string-length( normalize-space(.) ) gt 0"/>
         <xsl:otherwise>
            <xsl:message> @calendar indicates one or more
                        systems or calendars to which the date represented by the content of this element belongs,
                        but this <xsl:text/>
               <xsl:value-of select="name(.)"/>
               <xsl:text/> element has no textual content. (string-length( normalize-space(.) ) gt 0)</xsl:message>
         </xsl:otherwise>
      </xsl:choose>
      <xsl:apply-templates select="*" mode="M31"/>
   </xsl:template>
   <xsl:template match="text()" priority="-1" mode="M31"/>
   <xsl:template match="@*|node()" priority="-2" mode="M31">
      <xsl:apply-templates select="*" mode="M31"/>
   </xsl:template>
   <!--PATTERN schematron-constraint-tei_all-meeting-calendar-calendar-check-meeting-25-->
   <!--RULE -->
   <xsl:template match="tei:*[@calendar]" priority="1000" mode="M32">

		<!--ASSERT -->
      <xsl:choose>
         <xsl:when test="string-length( normalize-space(.) ) gt 0"/>
         <xsl:otherwise>
            <xsl:message> @calendar indicates one or more
                        systems or calendars to which the date represented by the content of this element belongs,
                        but this <xsl:text/>
               <xsl:value-of select="name(.)"/>
               <xsl:text/> element has no textual content. (string-length( normalize-space(.) ) gt 0)</xsl:message>
         </xsl:otherwise>
      </xsl:choose>
      <xsl:apply-templates select="*" mode="M32"/>
   </xsl:template>
   <xsl:template match="text()" priority="-1" mode="M32"/>
   <xsl:template match="@*|node()" priority="-2" mode="M32">
      <xsl:apply-templates select="*" mode="M32"/>
   </xsl:template>
   <!--PATTERN schematron-constraint-tei_all-relatedItem-targetorcontent1-26-->
   <!--RULE -->
   <xsl:template match="tei:relatedItem" priority="1000" mode="M33">

		<!--REPORT -->
      <xsl:if test="@target and count( child::* ) &gt; 0">
         <xsl:message>
If the @target attribute on <xsl:text/>
            <xsl:value-of select="name(.)"/>
            <xsl:text/> is used, the
relatedItem element must be empty (@target and count( child::* ) &gt; 0)</xsl:message>
      </xsl:if>
      <!--ASSERT -->
      <xsl:choose>
         <xsl:when test="@target or child::*"/>
         <xsl:otherwise>
            <xsl:message>A relatedItem element should have either a 'target' attribute
        or a child element to indicate the related bibliographic item (@target or child::*)</xsl:message>
         </xsl:otherwise>
      </xsl:choose>
      <xsl:apply-templates select="*" mode="M33"/>
   </xsl:template>
   <xsl:template match="text()" priority="-1" mode="M33"/>
   <xsl:template match="@*|node()" priority="-2" mode="M33">
      <xsl:apply-templates select="*" mode="M33"/>
   </xsl:template>
   <!--PATTERN schematron-constraint-tei_all-l-abstractModel-structure-l-in-l-27-->
   <!--RULE -->
   <xsl:template match="tei:l" priority="1000" mode="M34">

		<!--REPORT -->
      <xsl:if test="ancestor::tei:l[not(.//tei:note//tei:l[. = current()])]">
         <xsl:message>
        Abstract model violation: Lines may not contain lines or lg elements.
       (ancestor::tei:l[not(.//tei:note//tei:l[. = current()])])</xsl:message>
      </xsl:if>
      <xsl:apply-templates select="*" mode="M34"/>
   </xsl:template>
   <xsl:template match="text()" priority="-1" mode="M34"/>
   <xsl:template match="@*|node()" priority="-2" mode="M34">
      <xsl:apply-templates select="*" mode="M34"/>
   </xsl:template>
   <!--PATTERN schematron-constraint-tei_all-lg-atleast1oflggapl-28-->
   <!--RULE -->
   <xsl:template match="tei:lg" priority="1000" mode="M35">

		<!--ASSERT -->
      <xsl:choose>
         <xsl:when test="count(descendant::tei:lg|descendant::tei:l|descendant::tei:gap) &gt; 0"/>
         <xsl:otherwise>
            <xsl:message>An lg element
        must contain at least one child l, lg, or gap element. (count(descendant::tei:lg|descendant::tei:l|descendant::tei:gap) &gt; 0)</xsl:message>
         </xsl:otherwise>
      </xsl:choose>
      <xsl:apply-templates select="*" mode="M35"/>
   </xsl:template>
   <xsl:template match="text()" priority="-1" mode="M35"/>
   <xsl:template match="@*|node()" priority="-2" mode="M35">
      <xsl:apply-templates select="*" mode="M35"/>
   </xsl:template>
   <!--PATTERN schematron-constraint-tei_all-lg-abstractModel-structure-lg-in-l-29-->
   <!--RULE -->
   <xsl:template match="tei:lg" priority="1000" mode="M36">

		<!--REPORT -->
      <xsl:if test="ancestor::tei:l[not(.//tei:note//tei:lg[. = current()])]">
         <xsl:message>
        Abstract model violation: Lines may not contain line groups.
       (ancestor::tei:l[not(.//tei:note//tei:lg[. = current()])])</xsl:message>
      </xsl:if>
      <xsl:apply-templates select="*" mode="M36"/>
   </xsl:template>
   <xsl:template match="text()" priority="-1" mode="M36"/>
   <xsl:template match="@*|node()" priority="-2" mode="M36">
      <xsl:apply-templates select="*" mode="M36"/>
   </xsl:template>
   <!--PATTERN schematron-constraint-tei_all-sponsor-calendar-calendar-check-sponsor-30-->
   <!--RULE -->
   <xsl:template match="tei:*[@calendar]" priority="1000" mode="M37">

		<!--ASSERT -->
      <xsl:choose>
         <xsl:when test="string-length( normalize-space(.) ) gt 0"/>
         <xsl:otherwise>
            <xsl:message> @calendar indicates one or more
                        systems or calendars to which the date represented by the content of this element belongs,
                        but this <xsl:text/>
               <xsl:value-of select="name(.)"/>
               <xsl:text/> element has no textual content. (string-length( normalize-space(.) ) gt 0)</xsl:message>
         </xsl:otherwise>
      </xsl:choose>
      <xsl:apply-templates select="*" mode="M37"/>
   </xsl:template>
   <xsl:template match="text()" priority="-1" mode="M37"/>
   <xsl:template match="@*|node()" priority="-2" mode="M37">
      <xsl:apply-templates select="*" mode="M37"/>
   </xsl:template>
   <!--PATTERN schematron-constraint-tei_all-funder-calendar-calendar-check-funder-31-->
   <!--RULE -->
   <xsl:template match="tei:*[@calendar]" priority="1000" mode="M38">

		<!--ASSERT -->
      <xsl:choose>
         <xsl:when test="string-length( normalize-space(.) ) gt 0"/>
         <xsl:otherwise>
            <xsl:message> @calendar indicates one or more
                        systems or calendars to which the date represented by the content of this element belongs,
                        but this <xsl:text/>
               <xsl:value-of select="name(.)"/>
               <xsl:text/> element has no textual content. (string-length( normalize-space(.) ) gt 0)</xsl:message>
         </xsl:otherwise>
      </xsl:choose>
      <xsl:apply-templates select="*" mode="M38"/>
   </xsl:template>
   <xsl:template match="text()" priority="-1" mode="M38"/>
   <xsl:template match="@*|node()" priority="-2" mode="M38">
      <xsl:apply-templates select="*" mode="M38"/>
   </xsl:template>
   <!--PATTERN schematron-constraint-tei_all-principal-calendar-calendar-check-principal-32-->
   <!--RULE -->
   <xsl:template match="tei:*[@calendar]" priority="1000" mode="M39">

		<!--ASSERT -->
      <xsl:choose>
         <xsl:when test="string-length( normalize-space(.) ) gt 0"/>
         <xsl:otherwise>
            <xsl:message> @calendar indicates one or more
                        systems or calendars to which the date represented by the content of this element belongs,
                        but this <xsl:text/>
               <xsl:value-of select="name(.)"/>
               <xsl:text/> element has no textual content. (string-length( normalize-space(.) ) gt 0)</xsl:message>
         </xsl:otherwise>
      </xsl:choose>
      <xsl:apply-templates select="*" mode="M39"/>
   </xsl:template>
   <xsl:template match="text()" priority="-1" mode="M39"/>
   <xsl:template match="@*|node()" priority="-2" mode="M39">
      <xsl:apply-templates select="*" mode="M39"/>
   </xsl:template>
   <!--PATTERN schematron-constraint-tei_all-idno-calendar-calendar-check-idno-33-->
   <!--RULE -->
   <xsl:template match="tei:*[@calendar]" priority="1000" mode="M40">

		<!--ASSERT -->
      <xsl:choose>
         <xsl:when test="string-length( normalize-space(.) ) gt 0"/>
         <xsl:otherwise>
            <xsl:message> @calendar indicates one or more
                        systems or calendars to which the date represented by the content of this element belongs,
                        but this <xsl:text/>
               <xsl:value-of select="name(.)"/>
               <xsl:text/> element has no textual content. (string-length( normalize-space(.) ) gt 0)</xsl:message>
         </xsl:otherwise>
      </xsl:choose>
      <xsl:apply-templates select="*" mode="M40"/>
   </xsl:template>
   <xsl:template match="text()" priority="-1" mode="M40"/>
   <xsl:template match="@*|node()" priority="-2" mode="M40">
      <xsl:apply-templates select="*" mode="M40"/>
   </xsl:template>
   <!--PATTERN schematron-constraint-tei_all-licence-calendar-calendar-check-licence-34-->
   <!--RULE -->
   <xsl:template match="tei:*[@calendar]" priority="1000" mode="M41">

		<!--ASSERT -->
      <xsl:choose>
         <xsl:when test="string-length( normalize-space(.) ) gt 0"/>
         <xsl:otherwise>
            <xsl:message> @calendar indicates one or more
                        systems or calendars to which the date represented by the content of this element belongs,
                        but this <xsl:text/>
               <xsl:value-of select="name(.)"/>
               <xsl:text/> element has no textual content. (string-length( normalize-space(.) ) gt 0)</xsl:message>
         </xsl:otherwise>
      </xsl:choose>
      <xsl:apply-templates select="*" mode="M41"/>
   </xsl:template>
   <xsl:template match="text()" priority="-1" mode="M41"/>
   <xsl:template match="@*|node()" priority="-2" mode="M41">
      <xsl:apply-templates select="*" mode="M41"/>
   </xsl:template>
   <!--PATTERN schematron-constraint-tei_all-quotation-quotationContents-35-->
   <!--RULE -->
   <xsl:template match="tei:quotation" priority="1000" mode="M42">

		<!--REPORT -->
      <xsl:if test="not(@marks) and not (tei:p)">
         <xsl:message>
On <xsl:text/>
            <xsl:value-of select="name(.)"/>
            <xsl:text/>, either the @marks attribute should be used, or a paragraph of description provided (not(@marks) and not (tei:p))</xsl:message>
      </xsl:if>
      <xsl:apply-templates select="*" mode="M42"/>
   </xsl:template>
   <xsl:template match="text()" priority="-1" mode="M42"/>
   <xsl:template match="@*|node()" priority="-2" mode="M42">
      <xsl:apply-templates select="*" mode="M42"/>
   </xsl:template>
   <!--PATTERN schematron-constraint-tei_all-citeStructure-match-citestructure-outer-match-36-->
   <!--RULE -->
   <xsl:template match="tei:citeStructure[not(parent::tei:citeStructure)]"
                 priority="1000"
                 mode="M43">

		<!--ASSERT -->
      <xsl:choose>
         <xsl:when test="starts-with(@match,'/')"/>
         <xsl:otherwise>
            <xsl:message>An XPath in @match on the outer <xsl:text/>
               <xsl:value-of select="name(.)"/>
               <xsl:text/> must start with '/'. (starts-with(@match,'/'))</xsl:message>
         </xsl:otherwise>
      </xsl:choose>
      <xsl:apply-templates select="*" mode="M43"/>
   </xsl:template>
   <xsl:template match="text()" priority="-1" mode="M43"/>
   <xsl:template match="@*|node()" priority="-2" mode="M43">
      <xsl:apply-templates select="*" mode="M43"/>
   </xsl:template>
   <!--PATTERN schematron-constraint-tei_all-citeStructure-match-citestructure-inner-match-37-->
   <!--RULE -->
   <xsl:template match="tei:citeStructure[parent::tei:citeStructure]"
                 priority="1000"
                 mode="M44">

		<!--ASSERT -->
      <xsl:choose>
         <xsl:when test="not(starts-with(@match,'/'))"/>
         <xsl:otherwise>
            <xsl:message>An XPath in @match must not start with '/' except on the outer <xsl:text/>
               <xsl:value-of select="name(.)"/>
               <xsl:text/>. (not(starts-with(@match,'/')))</xsl:message>
         </xsl:otherwise>
      </xsl:choose>
      <xsl:apply-templates select="*" mode="M44"/>
   </xsl:template>
   <xsl:template match="text()" priority="-1" mode="M44"/>
   <xsl:template match="@*|node()" priority="-2" mode="M44">
      <xsl:apply-templates select="*" mode="M44"/>
   </xsl:template>
   <!--PATTERN schematron-constraint-tei_all-unitDecl-calendar-calendar-check-unitDecl-38-->
   <!--RULE -->
   <xsl:template match="tei:*[@calendar]" priority="1000" mode="M45">

		<!--ASSERT -->
      <xsl:choose>
         <xsl:when test="string-length( normalize-space(.) ) gt 0"/>
         <xsl:otherwise>
            <xsl:message> @calendar indicates one or more
                        systems or calendars to which the date represented by the content of this element belongs,
                        but this <xsl:text/>
               <xsl:value-of select="name(.)"/>
               <xsl:text/> element has no textual content. (string-length( normalize-space(.) ) gt 0)</xsl:message>
         </xsl:otherwise>
      </xsl:choose>
      <xsl:apply-templates select="*" mode="M45"/>
   </xsl:template>
   <xsl:template match="text()" priority="-1" mode="M45"/>
   <xsl:template match="@*|node()" priority="-2" mode="M45">
      <xsl:apply-templates select="*" mode="M45"/>
   </xsl:template>
   <!--PATTERN schematron-constraint-tei_all-unitDef-calendar-calendar-check-unitDef-39-->
   <!--RULE -->
   <xsl:template match="tei:*[@calendar]" priority="1000" mode="M46">

		<!--ASSERT -->
      <xsl:choose>
         <xsl:when test="string-length( normalize-space(.) ) gt 0"/>
         <xsl:otherwise>
            <xsl:message> @calendar indicates one or more
                        systems or calendars to which the date represented by the content of this element belongs,
                        but this <xsl:text/>
               <xsl:value-of select="name(.)"/>
               <xsl:text/> element has no textual content. (string-length( normalize-space(.) ) gt 0)</xsl:message>
         </xsl:otherwise>
      </xsl:choose>
      <xsl:apply-templates select="*" mode="M46"/>
   </xsl:template>
   <xsl:template match="text()" priority="-1" mode="M46"/>
   <xsl:template match="@*|node()" priority="-2" mode="M46">
      <xsl:apply-templates select="*" mode="M46"/>
   </xsl:template>
   <!--PATTERN schematron-constraint-tei_all-conversion-calendar-calendar-check-conversion-40-->
   <!--RULE -->
   <xsl:template match="tei:*[@calendar]" priority="1000" mode="M47">

		<!--ASSERT -->
      <xsl:choose>
         <xsl:when test="string-length( normalize-space(.) ) gt 0"/>
         <xsl:otherwise>
            <xsl:message> @calendar indicates one or more
                        systems or calendars to which the date represented by the content of this element belongs,
                        but this <xsl:text/>
               <xsl:value-of select="name(.)"/>
               <xsl:text/> element has no textual content. (string-length( normalize-space(.) ) gt 0)</xsl:message>
         </xsl:otherwise>
      </xsl:choose>
      <xsl:apply-templates select="*" mode="M47"/>
   </xsl:template>
   <xsl:template match="text()" priority="-1" mode="M47"/>
   <xsl:template match="@*|node()" priority="-2" mode="M47">
      <xsl:apply-templates select="*" mode="M47"/>
   </xsl:template>
   <!--PATTERN schematron-constraint-tei_all-application-calendar-calendar-check-application-41-->
   <!--RULE -->
   <xsl:template match="tei:*[@calendar]" priority="1000" mode="M48">

		<!--ASSERT -->
      <xsl:choose>
         <xsl:when test="string-length( normalize-space(.) ) gt 0"/>
         <xsl:otherwise>
            <xsl:message> @calendar indicates one or more
                        systems or calendars to which the date represented by the content of this element belongs,
                        but this <xsl:text/>
               <xsl:value-of select="name(.)"/>
               <xsl:text/> element has no textual content. (string-length( normalize-space(.) ) gt 0)</xsl:message>
         </xsl:otherwise>
      </xsl:choose>
      <xsl:apply-templates select="*" mode="M48"/>
   </xsl:template>
   <xsl:template match="text()" priority="-1" mode="M48"/>
   <xsl:template match="@*|node()" priority="-2" mode="M48">
      <xsl:apply-templates select="*" mode="M48"/>
   </xsl:template>
   <!--PATTERN schematron-constraint-tei_all-creation-calendar-calendar-check-creation-42-->
   <!--RULE -->
   <xsl:template match="tei:*[@calendar]" priority="1000" mode="M49">

		<!--ASSERT -->
      <xsl:choose>
         <xsl:when test="string-length( normalize-space(.) ) gt 0"/>
         <xsl:otherwise>
            <xsl:message> @calendar indicates one or more
                        systems or calendars to which the date represented by the content of this element belongs,
                        but this <xsl:text/>
               <xsl:value-of select="name(.)"/>
               <xsl:text/> element has no textual content. (string-length( normalize-space(.) ) gt 0)</xsl:message>
         </xsl:otherwise>
      </xsl:choose>
      <xsl:apply-templates select="*" mode="M49"/>
   </xsl:template>
   <xsl:template match="text()" priority="-1" mode="M49"/>
   <xsl:template match="@*|node()" priority="-2" mode="M49">
      <xsl:apply-templates select="*" mode="M49"/>
   </xsl:template>
   <!--PATTERN schematron-constraint-tei_all-change-calendar-calendar-check-change-43-->
   <!--RULE -->
   <xsl:template match="tei:*[@calendar]" priority="1000" mode="M50">

		<!--ASSERT -->
      <xsl:choose>
         <xsl:when test="string-length( normalize-space(.) ) gt 0"/>
         <xsl:otherwise>
            <xsl:message> @calendar indicates one or more
                        systems or calendars to which the date represented by the content of this element belongs,
                        but this <xsl:text/>
               <xsl:value-of select="name(.)"/>
               <xsl:text/> element has no textual content. (string-length( normalize-space(.) ) gt 0)</xsl:message>
         </xsl:otherwise>
      </xsl:choose>
      <xsl:apply-templates select="*" mode="M50"/>
   </xsl:template>
   <xsl:template match="text()" priority="-1" mode="M50"/>
   <xsl:template match="@*|node()" priority="-2" mode="M50">
      <xsl:apply-templates select="*" mode="M50"/>
   </xsl:template>
   <!--PATTERN schematron-constraint-tei_all-div-abstractModel-structure-div-in-l-or-lg-47-->
   <!--RULE -->
   <xsl:template match="tei:div" priority="1000" mode="M51">

		<!--REPORT -->
      <xsl:if test="(ancestor::tei:l or ancestor::tei:lg) and not(ancestor::tei:floatingText)">
         <xsl:message>
        Abstract model violation: Lines may not contain higher-level structural elements such as div, unless div is a descendant of floatingText.
       ((ancestor::tei:l or ancestor::tei:lg) and not(ancestor::tei:floatingText))</xsl:message>
      </xsl:if>
      <xsl:apply-templates select="*" mode="M51"/>
   </xsl:template>
   <xsl:template match="text()" priority="-1" mode="M51"/>
   <xsl:template match="@*|node()" priority="-2" mode="M51">
      <xsl:apply-templates select="*" mode="M51"/>
   </xsl:template>
   <!--PATTERN schematron-constraint-tei_all-div-abstractModel-structure-div-in-ab-or-p-48-->
   <!--RULE -->
   <xsl:template match="tei:div" priority="1000" mode="M52">

		<!--REPORT -->
      <xsl:if test="(ancestor::tei:p or ancestor::tei:ab) and not(ancestor::tei:floatingText)">
         <xsl:message>
        Abstract model violation: p and ab may not contain higher-level structural elements such as div, unless div is a descendant of floatingText.
       ((ancestor::tei:p or ancestor::tei:ab) and not(ancestor::tei:floatingText))</xsl:message>
      </xsl:if>
      <xsl:apply-templates select="*" mode="M52"/>
   </xsl:template>
   <xsl:template match="text()" priority="-1" mode="M52"/>
   <xsl:template match="@*|node()" priority="-2" mode="M52">
      <xsl:apply-templates select="*" mode="M52"/>
   </xsl:template>
   <!--PATTERN schematron-constraint-tei_all-shift-shiftNew-49-->
   <!--RULE -->
   <xsl:template match="tei:shift" priority="1000" mode="M53">

		<!--ASSERT warning-->
      <xsl:choose>
         <xsl:when test="@new"/>
         <xsl:otherwise>
            <xsl:message>              
The @new attribute should always be supplied; use the special value
"normal" to indicate that the feature concerned ceases to be
remarkable at this point. (@new / warning)</xsl:message>
         </xsl:otherwise>
      </xsl:choose>
      <xsl:apply-templates select="*" mode="M53"/>
   </xsl:template>
   <xsl:template match="text()" priority="-1" mode="M53"/>
   <xsl:template match="@*|node()" priority="-2" mode="M53">
      <xsl:apply-templates select="*" mode="M53"/>
   </xsl:template>
   <!--PATTERN schematron-constraint-tei_all-s-noNestedS-50-->
   <!--RULE -->
   <xsl:template match="tei:s" priority="1000" mode="M54">

		<!--REPORT -->
      <xsl:if test="tei:s">
         <xsl:message>You may not nest one s element within
      another: use seg instead (tei:s)</xsl:message>
      </xsl:if>
      <xsl:apply-templates select="*" mode="M54"/>
   </xsl:template>
   <xsl:template match="text()" priority="-1" mode="M54"/>
   <xsl:template match="@*|node()" priority="-2" mode="M54">
      <xsl:apply-templates select="*" mode="M54"/>
   </xsl:template>
   <!--PATTERN schematron-constraint-tei_all-span-targetfrom-51-->
   <!--RULE -->
   <xsl:template match="tei:span" priority="1000" mode="M55">

		<!--REPORT -->
      <xsl:if test="@from and @target">
         <xsl:message>
Only one of the attributes @target and @from may be supplied on <xsl:text/>
            <xsl:value-of select="name(.)"/>
            <xsl:text/>
          (@from and @target)</xsl:message>
      </xsl:if>
      <xsl:apply-templates select="*" mode="M55"/>
   </xsl:template>
   <xsl:template match="text()" priority="-1" mode="M55"/>
   <xsl:template match="@*|node()" priority="-2" mode="M55">
      <xsl:apply-templates select="*" mode="M55"/>
   </xsl:template>
   <!--PATTERN schematron-constraint-tei_all-span-targetto-52-->
   <!--RULE -->
   <xsl:template match="tei:span" priority="1000" mode="M56">

		<!--REPORT -->
      <xsl:if test="@to and @target">
         <xsl:message>
Only one of the attributes @target and @to may be supplied on <xsl:text/>
            <xsl:value-of select="name(.)"/>
            <xsl:text/>
          (@to and @target)</xsl:message>
      </xsl:if>
      <xsl:apply-templates select="*" mode="M56"/>
   </xsl:template>
   <xsl:template match="text()" priority="-1" mode="M56"/>
   <xsl:template match="@*|node()" priority="-2" mode="M56">
      <xsl:apply-templates select="*" mode="M56"/>
   </xsl:template>
   <!--PATTERN schematron-constraint-tei_all-span-tonotfrom-53-->
   <!--RULE -->
   <xsl:template match="tei:span" priority="1000" mode="M57">

		<!--REPORT -->
      <xsl:if test="@to and not(@from)">
         <xsl:message>
If @to is supplied on <xsl:text/>
            <xsl:value-of select="name(.)"/>
            <xsl:text/>, @from must be supplied as well (@to and not(@from))</xsl:message>
      </xsl:if>
      <xsl:apply-templates select="*" mode="M57"/>
   </xsl:template>
   <xsl:template match="text()" priority="-1" mode="M57"/>
   <xsl:template match="@*|node()" priority="-2" mode="M57">
      <xsl:apply-templates select="*" mode="M57"/>
   </xsl:template>
   <!--PATTERN schematron-constraint-tei_all-span-tofrom-54-->
   <!--RULE -->
   <xsl:template match="tei:span" priority="1000" mode="M58">

		<!--REPORT -->
      <xsl:if test="contains(normalize-space(@to),' ') or contains(normalize-space(@from),' ')">
         <xsl:message>
The attributes @to and @from on <xsl:text/>
            <xsl:value-of select="name(.)"/>
            <xsl:text/> may each contain only a single value (contains(normalize-space(@to),' ') or contains(normalize-space(@from),' '))</xsl:message>
      </xsl:if>
      <xsl:apply-templates select="*" mode="M58"/>
   </xsl:template>
   <xsl:template match="text()" priority="-1" mode="M58"/>
   <xsl:template match="@*|node()" priority="-2" mode="M58">
      <xsl:apply-templates select="*" mode="M58"/>
   </xsl:template>
   <!--PATTERN schematron-constraint-tei_all-msDesc-one_ms_singleton_max-55-->
   <!--RULE -->
   <xsl:template match="tei:msContents|tei:physDesc|tei:history|tei:additional"
                 priority="1000"
                 mode="M59">
      <xsl:variable name="gi" select="name(.)"/>
      <!--REPORT -->
      <xsl:if test="preceding-sibling::*[ name(.) eq $gi ]                           and                           not( following-sibling::*[ name(.) eq $gi ] )">
         <xsl:message>
          Only one <xsl:text/>
            <xsl:value-of select="name(.)"/>
            <xsl:text/> is allowed as a child of <xsl:text/>
            <xsl:value-of select="name(..)"/>
            <xsl:text/>.
         (preceding-sibling::*[ name(.) eq $gi ] and not( following-sibling::*[ name(.) eq $gi ] ))</xsl:message>
      </xsl:if>
      <xsl:apply-templates select="*" mode="M59"/>
   </xsl:template>
   <xsl:template match="text()" priority="-1" mode="M59"/>
   <xsl:template match="@*|node()" priority="-2" mode="M59">
      <xsl:apply-templates select="*" mode="M59"/>
   </xsl:template>
   <!--PATTERN schematron-constraint-tei_all-catchwords-catchword_in_msDesc-56-->
   <!--RULE -->
   <xsl:template match="tei:catchwords" priority="1000" mode="M60">

		<!--ASSERT -->
      <xsl:choose>
         <xsl:when test="ancestor::tei:msDesc or ancestor::tei:egXML"/>
         <xsl:otherwise>
            <xsl:message>The <xsl:text/>
               <xsl:value-of select="name(.)"/>
               <xsl:text/> element should not be used outside of msDesc. (ancestor::tei:msDesc or ancestor::tei:egXML)</xsl:message>
         </xsl:otherwise>
      </xsl:choose>
      <xsl:apply-templates select="*" mode="M60"/>
   </xsl:template>
   <xsl:template match="text()" priority="-1" mode="M60"/>
   <xsl:template match="@*|node()" priority="-2" mode="M60">
      <xsl:apply-templates select="*" mode="M60"/>
   </xsl:template>
   <!--PATTERN schematron-constraint-tei_all-dimensions-duplicateDim-57-->
   <!--RULE -->
   <xsl:template match="tei:dimensions" priority="1000" mode="M61">

		<!--REPORT -->
      <xsl:if test="count(tei:width)&gt; 1">
         <xsl:message>
        The element <xsl:text/>
            <xsl:value-of select="name(.)"/>
            <xsl:text/> may appear once only
       (count(tei:width)&gt; 1)</xsl:message>
      </xsl:if>
      <!--REPORT -->
      <xsl:if test="count(tei:height)&gt; 1">
         <xsl:message>
        The element <xsl:text/>
            <xsl:value-of select="name(.)"/>
            <xsl:text/> may appear once only
       (count(tei:height)&gt; 1)</xsl:message>
      </xsl:if>
      <!--REPORT -->
      <xsl:if test="count(tei:depth)&gt; 1">
         <xsl:message>
        The element <xsl:text/>
            <xsl:value-of select="name(.)"/>
            <xsl:text/> may appear once only
       (count(tei:depth)&gt; 1)</xsl:message>
      </xsl:if>
      <xsl:apply-templates select="*" mode="M61"/>
   </xsl:template>
   <xsl:template match="text()" priority="-1" mode="M61"/>
   <xsl:template match="@*|node()" priority="-2" mode="M61">
      <xsl:apply-templates select="*" mode="M61"/>
   </xsl:template>
   <!--PATTERN schematron-constraint-tei_all-origPlace-calendar-calendar-check-origPlace-58-->
   <!--RULE -->
   <xsl:template match="tei:*[@calendar]" priority="1000" mode="M62">

		<!--ASSERT -->
      <xsl:choose>
         <xsl:when test="string-length( normalize-space(.) ) gt 0"/>
         <xsl:otherwise>
            <xsl:message> @calendar indicates one or more
                        systems or calendars to which the date represented by the content of this element belongs,
                        but this <xsl:text/>
               <xsl:value-of select="name(.)"/>
               <xsl:text/> element has no textual content. (string-length( normalize-space(.) ) gt 0)</xsl:message>
         </xsl:otherwise>
      </xsl:choose>
      <xsl:apply-templates select="*" mode="M62"/>
   </xsl:template>
   <xsl:template match="text()" priority="-1" mode="M62"/>
   <xsl:template match="@*|node()" priority="-2" mode="M62">
      <xsl:apply-templates select="*" mode="M62"/>
   </xsl:template>
   <!--PATTERN schematron-constraint-tei_all-secFol-secFol_in_msDesc-59-->
   <!--RULE -->
   <xsl:template match="tei:secFol" priority="1000" mode="M63">

		<!--ASSERT -->
      <xsl:choose>
         <xsl:when test="ancestor::tei:msDesc or ancestor::tei:egXML"/>
         <xsl:otherwise>
            <xsl:message>The <xsl:text/>
               <xsl:value-of select="name(.)"/>
               <xsl:text/> element should not be used outside of msDesc. (ancestor::tei:msDesc or ancestor::tei:egXML)</xsl:message>
         </xsl:otherwise>
      </xsl:choose>
      <xsl:apply-templates select="*" mode="M63"/>
   </xsl:template>
   <xsl:template match="text()" priority="-1" mode="M63"/>
   <xsl:template match="@*|node()" priority="-2" mode="M63">
      <xsl:apply-templates select="*" mode="M63"/>
   </xsl:template>
   <!--PATTERN schematron-constraint-tei_all-signatures-signatures_in_msDesc-60-->
   <!--RULE -->
   <xsl:template match="tei:signatures" priority="1000" mode="M64">

		<!--ASSERT -->
      <xsl:choose>
         <xsl:when test="ancestor::tei:msDesc or ancestor::tei:egXML"/>
         <xsl:otherwise>
            <xsl:message>The <xsl:text/>
               <xsl:value-of select="name(.)"/>
               <xsl:text/> element should not be used outside of msDesc. (ancestor::tei:msDesc or ancestor::tei:egXML)</xsl:message>
         </xsl:otherwise>
      </xsl:choose>
      <xsl:apply-templates select="*" mode="M64"/>
   </xsl:template>
   <xsl:template match="text()" priority="-1" mode="M64"/>
   <xsl:template match="@*|node()" priority="-2" mode="M64">
      <xsl:apply-templates select="*" mode="M64"/>
   </xsl:template>
   <!--PATTERN schematron-constraint-tei_all-stamp-calendar-calendar-check-stamp-61-->
   <!--RULE -->
   <xsl:template match="tei:*[@calendar]" priority="1000" mode="M65">

		<!--ASSERT -->
      <xsl:choose>
         <xsl:when test="string-length( normalize-space(.) ) gt 0"/>
         <xsl:otherwise>
            <xsl:message> @calendar indicates one or more
                        systems or calendars to which the date represented by the content of this element belongs,
                        but this <xsl:text/>
               <xsl:value-of select="name(.)"/>
               <xsl:text/> element has no textual content. (string-length( normalize-space(.) ) gt 0)</xsl:message>
         </xsl:otherwise>
      </xsl:choose>
      <xsl:apply-templates select="*" mode="M65"/>
   </xsl:template>
   <xsl:template match="text()" priority="-1" mode="M65"/>
   <xsl:template match="@*|node()" priority="-2" mode="M65">
      <xsl:apply-templates select="*" mode="M65"/>
   </xsl:template>
   <!--PATTERN schematron-constraint-tei_all-msIdentifier-msId_minimal-62-->
   <!--RULE -->
   <xsl:template match="tei:msIdentifier" priority="1000" mode="M66">

		<!--REPORT -->
      <xsl:if test="not(parent::tei:msPart) and (local-name(*[1])='idno' or local-name(*[1])='altIdentifier' or normalize-space(.)='')">
         <xsl:message>An msIdentifier must contain either a repository or location. (not(parent::tei:msPart) and (local-name(*[1])='idno' or local-name(*[1])='altIdentifier' or normalize-space(.)=''))</xsl:message>
      </xsl:if>
      <xsl:apply-templates select="*" mode="M66"/>
   </xsl:template>
   <xsl:template match="text()" priority="-1" mode="M66"/>
   <xsl:template match="@*|node()" priority="-2" mode="M66">
      <xsl:apply-templates select="*" mode="M66"/>
   </xsl:template>
   <!--PATTERN schematron-constraint-tei_all-altIdentifier-calendar-calendar-check-altIdentifier-63-->
   <!--RULE -->
   <xsl:template match="tei:*[@calendar]" priority="1000" mode="M67">

		<!--ASSERT -->
      <xsl:choose>
         <xsl:when test="string-length( normalize-space(.) ) gt 0"/>
         <xsl:otherwise>
            <xsl:message> @calendar indicates one or more
                        systems or calendars to which the date represented by the content of this element belongs,
                        but this <xsl:text/>
               <xsl:value-of select="name(.)"/>
               <xsl:text/> element has no textual content. (string-length( normalize-space(.) ) gt 0)</xsl:message>
         </xsl:otherwise>
      </xsl:choose>
      <xsl:apply-templates select="*" mode="M67"/>
   </xsl:template>
   <xsl:template match="text()" priority="-1" mode="M67"/>
   <xsl:template match="@*|node()" priority="-2" mode="M67">
      <xsl:apply-templates select="*" mode="M67"/>
   </xsl:template>
   <!--PATTERN schematron-constraint-tei_all-binding-calendar-calendar-check-binding-64-->
   <!--RULE -->
   <xsl:template match="tei:*[@calendar]" priority="1000" mode="M68">

		<!--ASSERT -->
      <xsl:choose>
         <xsl:when test="string-length( normalize-space(.) ) gt 0"/>
         <xsl:otherwise>
            <xsl:message> @calendar indicates one or more
                        systems or calendars to which the date represented by the content of this element belongs,
                        but this <xsl:text/>
               <xsl:value-of select="name(.)"/>
               <xsl:text/> element has no textual content. (string-length( normalize-space(.) ) gt 0)</xsl:message>
         </xsl:otherwise>
      </xsl:choose>
      <xsl:apply-templates select="*" mode="M68"/>
   </xsl:template>
   <xsl:template match="text()" priority="-1" mode="M68"/>
   <xsl:template match="@*|node()" priority="-2" mode="M68">
      <xsl:apply-templates select="*" mode="M68"/>
   </xsl:template>
   <!--PATTERN schematron-constraint-tei_all-seal-calendar-calendar-check-seal-65-->
   <!--RULE -->
   <xsl:template match="tei:*[@calendar]" priority="1000" mode="M69">

		<!--ASSERT -->
      <xsl:choose>
         <xsl:when test="string-length( normalize-space(.) ) gt 0"/>
         <xsl:otherwise>
            <xsl:message> @calendar indicates one or more
                        systems or calendars to which the date represented by the content of this element belongs,
                        but this <xsl:text/>
               <xsl:value-of select="name(.)"/>
               <xsl:text/> element has no textual content. (string-length( normalize-space(.) ) gt 0)</xsl:message>
         </xsl:otherwise>
      </xsl:choose>
      <xsl:apply-templates select="*" mode="M69"/>
   </xsl:template>
   <xsl:template match="text()" priority="-1" mode="M69"/>
   <xsl:template match="@*|node()" priority="-2" mode="M69">
      <xsl:apply-templates select="*" mode="M69"/>
   </xsl:template>
   <!--PATTERN schematron-constraint-tei_all-origin-calendar-calendar-check-origin-66-->
   <!--RULE -->
   <xsl:template match="tei:*[@calendar]" priority="1000" mode="M70">

		<!--ASSERT -->
      <xsl:choose>
         <xsl:when test="string-length( normalize-space(.) ) gt 0"/>
         <xsl:otherwise>
            <xsl:message> @calendar indicates one or more
                        systems or calendars to which the date represented by the content of this element belongs,
                        but this <xsl:text/>
               <xsl:value-of select="name(.)"/>
               <xsl:text/> element has no textual content. (string-length( normalize-space(.) ) gt 0)</xsl:message>
         </xsl:otherwise>
      </xsl:choose>
      <xsl:apply-templates select="*" mode="M70"/>
   </xsl:template>
   <xsl:template match="text()" priority="-1" mode="M70"/>
   <xsl:template match="@*|node()" priority="-2" mode="M70">
      <xsl:apply-templates select="*" mode="M70"/>
   </xsl:template>
   <!--PATTERN schematron-constraint-tei_all-provenance-calendar-calendar-check-provenance-67-->
   <!--RULE -->
   <xsl:template match="tei:*[@calendar]" priority="1000" mode="M71">

		<!--ASSERT -->
      <xsl:choose>
         <xsl:when test="string-length( normalize-space(.) ) gt 0"/>
         <xsl:otherwise>
            <xsl:message> @calendar indicates one or more
                        systems or calendars to which the date represented by the content of this element belongs,
                        but this <xsl:text/>
               <xsl:value-of select="name(.)"/>
               <xsl:text/> element has no textual content. (string-length( normalize-space(.) ) gt 0)</xsl:message>
         </xsl:otherwise>
      </xsl:choose>
      <xsl:apply-templates select="*" mode="M71"/>
   </xsl:template>
   <xsl:template match="text()" priority="-1" mode="M71"/>
   <xsl:template match="@*|node()" priority="-2" mode="M71">
      <xsl:apply-templates select="*" mode="M71"/>
   </xsl:template>
   <!--PATTERN schematron-constraint-tei_all-acquisition-calendar-calendar-check-acquisition-68-->
   <!--RULE -->
   <xsl:template match="tei:*[@calendar]" priority="1000" mode="M72">

		<!--ASSERT -->
      <xsl:choose>
         <xsl:when test="string-length( normalize-space(.) ) gt 0"/>
         <xsl:otherwise>
            <xsl:message> @calendar indicates one or more
                        systems or calendars to which the date represented by the content of this element belongs,
                        but this <xsl:text/>
               <xsl:value-of select="name(.)"/>
               <xsl:text/> element has no textual content. (string-length( normalize-space(.) ) gt 0)</xsl:message>
         </xsl:otherwise>
      </xsl:choose>
      <xsl:apply-templates select="*" mode="M72"/>
   </xsl:template>
   <xsl:template match="text()" priority="-1" mode="M72"/>
   <xsl:template match="@*|node()" priority="-2" mode="M72">
      <xsl:apply-templates select="*" mode="M72"/>
   </xsl:template>
   <!--PATTERN schematron-constraint-tei_all-custEvent-calendar-calendar-check-custEvent-69-->
   <!--RULE -->
   <xsl:template match="tei:*[@calendar]" priority="1000" mode="M73">

		<!--ASSERT -->
      <xsl:choose>
         <xsl:when test="string-length( normalize-space(.) ) gt 0"/>
         <xsl:otherwise>
            <xsl:message> @calendar indicates one or more
                        systems or calendars to which the date represented by the content of this element belongs,
                        but this <xsl:text/>
               <xsl:value-of select="name(.)"/>
               <xsl:text/> element has no textual content. (string-length( normalize-space(.) ) gt 0)</xsl:message>
         </xsl:otherwise>
      </xsl:choose>
      <xsl:apply-templates select="*" mode="M73"/>
   </xsl:template>
   <xsl:template match="text()" priority="-1" mode="M73"/>
   <xsl:template match="@*|node()" priority="-2" mode="M73">
      <xsl:apply-templates select="*" mode="M73"/>
   </xsl:template>
   <!--PATTERN schematron-constraint-tei_all-facsimile-no_facsimile_text_nodes-70-->
   <!--RULE -->
   <xsl:template match="tei:facsimile//tei:line | tei:facsimile//tei:zone"
                 priority="1000"
                 mode="M74">

		<!--REPORT -->
      <xsl:if test="child::text()[ normalize-space(.) ne '']">
         <xsl:message>
          A facsimile element represents a text with images, thus
          transcribed text should not be present within it.
         (child::text()[ normalize-space(.) ne ''])</xsl:message>
      </xsl:if>
      <xsl:apply-templates select="*" mode="M74"/>
   </xsl:template>
   <xsl:template match="text()" priority="-1" mode="M74"/>
   <xsl:template match="@*|node()" priority="-2" mode="M74">
      <xsl:apply-templates select="*" mode="M74"/>
   </xsl:template>
   <!--PATTERN schematron-constraint-tei_all-path-pathmustnotbeclosed-71-->
   <!--RULE -->
   <xsl:template match="tei:path[@points]" priority="1000" mode="M75">
      <xsl:variable name="firstPair" select="tokenize( normalize-space( @points ), ' ')[1]"/>
      <xsl:variable name="lastPair"
                    select="tokenize( normalize-space( @points ), ' ')[last()]"/>
      <xsl:variable name="firstX" select="xs:float( substring-before( $firstPair, ',') )"/>
      <xsl:variable name="firstY" select="xs:float( substring-after( $firstPair, ',') )"/>
      <xsl:variable name="lastX" select="xs:float( substring-before( $lastPair, ',') )"/>
      <xsl:variable name="lastY" select="xs:float( substring-after( $lastPair, ',') )"/>
      <!--REPORT -->
      <xsl:if test="$firstX eq $lastX and $firstY eq $lastY">
         <xsl:message>The first and
          last elements of this path are the same. To specify a closed polygon, use
          the zone element rather than the path element.  ($firstX eq $lastX and $firstY eq $lastY)</xsl:message>
      </xsl:if>
      <xsl:apply-templates select="*" mode="M75"/>
   </xsl:template>
   <xsl:template match="text()" priority="-1" mode="M75"/>
   <xsl:template match="@*|node()" priority="-2" mode="M75">
      <xsl:apply-templates select="*" mode="M75"/>
   </xsl:template>
   <!--PATTERN schematron-constraint-tei_all-addSpan-addSpan-requires-spanTo-72-->
   <!--RULE -->
   <xsl:template match="tei:addSpan" priority="1000" mode="M76">

		<!--ASSERT -->
      <xsl:choose>
         <xsl:when test="@spanTo"/>
         <xsl:otherwise>
            <xsl:message>The @spanTo attribute of <xsl:text/>
               <xsl:value-of select="name(.)"/>
               <xsl:text/> is required. (@spanTo)</xsl:message>
         </xsl:otherwise>
      </xsl:choose>
      <xsl:apply-templates select="*" mode="M76"/>
   </xsl:template>
   <xsl:template match="text()" priority="-1" mode="M76"/>
   <xsl:template match="@*|node()" priority="-2" mode="M76">
      <xsl:apply-templates select="*" mode="M76"/>
   </xsl:template>
   <!--PATTERN schematron-constraint-tei_all-damageSpan-damageSpan-requires-spanTo-74-->
   <!--RULE -->
   <xsl:template match="tei:damageSpan" priority="1000" mode="M77">

		<!--ASSERT -->
      <xsl:choose>
         <xsl:when test="@spanTo"/>
         <xsl:otherwise>
            <xsl:message>The @spanTo attribute of <xsl:text/>
               <xsl:value-of select="name(.)"/>
               <xsl:text/> is required. (@spanTo)</xsl:message>
         </xsl:otherwise>
      </xsl:choose>
      <xsl:apply-templates select="*" mode="M77"/>
   </xsl:template>
   <xsl:template match="text()" priority="-1" mode="M77"/>
   <xsl:template match="@*|node()" priority="-2" mode="M77">
      <xsl:apply-templates select="*" mode="M77"/>
   </xsl:template>
   <!--PATTERN schematron-constraint-tei_all-delSpan-delSpan-requires-spanTo-76-->
   <!--RULE -->
   <xsl:template match="tei:delSpan" priority="1000" mode="M78">

		<!--ASSERT -->
      <xsl:choose>
         <xsl:when test="@spanTo"/>
         <xsl:otherwise>
            <xsl:message>The @spanTo attribute of <xsl:text/>
               <xsl:value-of select="name(.)"/>
               <xsl:text/> is required. (@spanTo)</xsl:message>
         </xsl:otherwise>
      </xsl:choose>
      <xsl:apply-templates select="*" mode="M78"/>
   </xsl:template>
   <xsl:template match="text()" priority="-1" mode="M78"/>
   <xsl:template match="@*|node()" priority="-2" mode="M78">
      <xsl:apply-templates select="*" mode="M78"/>
   </xsl:template>
   <!--PATTERN schematron-constraint-tei_all-subst-substContents1-78-->
   <!--RULE -->
   <xsl:template match="tei:subst" priority="1000" mode="M79">

		<!--ASSERT -->
      <xsl:choose>
         <xsl:when test="child::tei:add and (child::tei:del or child::tei:surplus)"/>
         <xsl:otherwise>
            <xsl:message>
               <xsl:text/>
               <xsl:value-of select="name(.)"/>
               <xsl:text/> must have at least one child add and at least one child del or surplus (child::tei:add and (child::tei:del or child::tei:surplus))</xsl:message>
         </xsl:otherwise>
      </xsl:choose>
      <xsl:apply-templates select="*" mode="M79"/>
   </xsl:template>
   <xsl:template match="text()" priority="-1" mode="M79"/>
   <xsl:template match="@*|node()" priority="-2" mode="M79">
      <xsl:apply-templates select="*" mode="M79"/>
   </xsl:template>
   <!--PATTERN schematron-constraint-tei_all-rdgGrp-only1lem-79-->
   <!--RULE -->
   <xsl:template match="tei:rdgGrp" priority="1000" mode="M80">

		<!--ASSERT -->
      <xsl:choose>
         <xsl:when test="count(tei:lem) &lt; 2"/>
         <xsl:otherwise>
            <xsl:message>Only one &lt;lem&gt; element may appear within a &lt;rdgGrp&gt; (count(tei:lem) &lt; 2)</xsl:message>
         </xsl:otherwise>
      </xsl:choose>
      <xsl:apply-templates select="*" mode="M80"/>
   </xsl:template>
   <xsl:template match="text()" priority="-1" mode="M80"/>
   <xsl:template match="@*|node()" priority="-2" mode="M80">
      <xsl:apply-templates select="*" mode="M80"/>
   </xsl:template>
   <!--PATTERN schematron-constraint-tei_all-variantEncoding-location-variantEncodingLocation-80-->
   <!--RULE -->
   <xsl:template match="tei:variantEncoding" priority="1000" mode="M81">

		<!--REPORT -->
      <xsl:if test="@location eq 'external' and @method eq 'parallel-segmentation'">
         <xsl:message>
              The @location value "external" is inconsistent with the
              parallel-segmentation method of apparatus markup. (@location eq 'external' and @method eq 'parallel-segmentation')</xsl:message>
      </xsl:if>
      <xsl:apply-templates select="*" mode="M81"/>
   </xsl:template>
   <xsl:template match="text()" priority="-1" mode="M81"/>
   <xsl:template match="@*|node()" priority="-2" mode="M81">
      <xsl:apply-templates select="*" mode="M81"/>
   </xsl:template>
   <!--PATTERN schematron-constraint-tei_all-orgName-calendar-calendar-check-orgName-81-->
   <!--RULE -->
   <xsl:template match="tei:*[@calendar]" priority="1000" mode="M82">

		<!--ASSERT -->
      <xsl:choose>
         <xsl:when test="string-length( normalize-space(.) ) gt 0"/>
         <xsl:otherwise>
            <xsl:message> @calendar indicates one or more
                        systems or calendars to which the date represented by the content of this element belongs,
                        but this <xsl:text/>
               <xsl:value-of select="name(.)"/>
               <xsl:text/> element has no textual content. (string-length( normalize-space(.) ) gt 0)</xsl:message>
         </xsl:otherwise>
      </xsl:choose>
      <xsl:apply-templates select="*" mode="M82"/>
   </xsl:template>
   <xsl:template match="text()" priority="-1" mode="M82"/>
   <xsl:template match="@*|node()" priority="-2" mode="M82">
      <xsl:apply-templates select="*" mode="M82"/>
   </xsl:template>
   <!--PATTERN schematron-constraint-tei_all-persName-calendar-calendar-check-persName-82-->
   <!--RULE -->
   <xsl:template match="tei:*[@calendar]" priority="1000" mode="M83">

		<!--ASSERT -->
      <xsl:choose>
         <xsl:when test="string-length( normalize-space(.) ) gt 0"/>
         <xsl:otherwise>
            <xsl:message> @calendar indicates one or more
                        systems or calendars to which the date represented by the content of this element belongs,
                        but this <xsl:text/>
               <xsl:value-of select="name(.)"/>
               <xsl:text/> element has no textual content. (string-length( normalize-space(.) ) gt 0)</xsl:message>
         </xsl:otherwise>
      </xsl:choose>
      <xsl:apply-templates select="*" mode="M83"/>
   </xsl:template>
   <xsl:template match="text()" priority="-1" mode="M83"/>
   <xsl:template match="@*|node()" priority="-2" mode="M83">
      <xsl:apply-templates select="*" mode="M83"/>
   </xsl:template>
   <!--PATTERN schematron-constraint-tei_all-placeName-calendar-calendar-check-placeName-83-->
   <!--RULE -->
   <xsl:template match="tei:*[@calendar]" priority="1000" mode="M84">

		<!--ASSERT -->
      <xsl:choose>
         <xsl:when test="string-length( normalize-space(.) ) gt 0"/>
         <xsl:otherwise>
            <xsl:message> @calendar indicates one or more
                        systems or calendars to which the date represented by the content of this element belongs,
                        but this <xsl:text/>
               <xsl:value-of select="name(.)"/>
               <xsl:text/> element has no textual content. (string-length( normalize-space(.) ) gt 0)</xsl:message>
         </xsl:otherwise>
      </xsl:choose>
      <xsl:apply-templates select="*" mode="M84"/>
   </xsl:template>
   <xsl:template match="text()" priority="-1" mode="M84"/>
   <xsl:template match="@*|node()" priority="-2" mode="M84">
      <xsl:apply-templates select="*" mode="M84"/>
   </xsl:template>
   <!--PATTERN schematron-constraint-tei_all-bloc-calendar-calendar-check-bloc-84-->
   <!--RULE -->
   <xsl:template match="tei:*[@calendar]" priority="1000" mode="M85">

		<!--ASSERT -->
      <xsl:choose>
         <xsl:when test="string-length( normalize-space(.) ) gt 0"/>
         <xsl:otherwise>
            <xsl:message> @calendar indicates one or more
                        systems or calendars to which the date represented by the content of this element belongs,
                        but this <xsl:text/>
               <xsl:value-of select="name(.)"/>
               <xsl:text/> element has no textual content. (string-length( normalize-space(.) ) gt 0)</xsl:message>
         </xsl:otherwise>
      </xsl:choose>
      <xsl:apply-templates select="*" mode="M85"/>
   </xsl:template>
   <xsl:template match="text()" priority="-1" mode="M85"/>
   <xsl:template match="@*|node()" priority="-2" mode="M85">
      <xsl:apply-templates select="*" mode="M85"/>
   </xsl:template>
   <!--PATTERN schematron-constraint-tei_all-country-calendar-calendar-check-country-85-->
   <!--RULE -->
   <xsl:template match="tei:*[@calendar]" priority="1000" mode="M86">

		<!--ASSERT -->
      <xsl:choose>
         <xsl:when test="string-length( normalize-space(.) ) gt 0"/>
         <xsl:otherwise>
            <xsl:message> @calendar indicates one or more
                        systems or calendars to which the date represented by the content of this element belongs,
                        but this <xsl:text/>
               <xsl:value-of select="name(.)"/>
               <xsl:text/> element has no textual content. (string-length( normalize-space(.) ) gt 0)</xsl:message>
         </xsl:otherwise>
      </xsl:choose>
      <xsl:apply-templates select="*" mode="M86"/>
   </xsl:template>
   <xsl:template match="text()" priority="-1" mode="M86"/>
   <xsl:template match="@*|node()" priority="-2" mode="M86">
      <xsl:apply-templates select="*" mode="M86"/>
   </xsl:template>
   <!--PATTERN schematron-constraint-tei_all-region-calendar-calendar-check-region-86-->
   <!--RULE -->
   <xsl:template match="tei:*[@calendar]" priority="1000" mode="M87">

		<!--ASSERT -->
      <xsl:choose>
         <xsl:when test="string-length( normalize-space(.) ) gt 0"/>
         <xsl:otherwise>
            <xsl:message> @calendar indicates one or more
                        systems or calendars to which the date represented by the content of this element belongs,
                        but this <xsl:text/>
               <xsl:value-of select="name(.)"/>
               <xsl:text/> element has no textual content. (string-length( normalize-space(.) ) gt 0)</xsl:message>
         </xsl:otherwise>
      </xsl:choose>
      <xsl:apply-templates select="*" mode="M87"/>
   </xsl:template>
   <xsl:template match="text()" priority="-1" mode="M87"/>
   <xsl:template match="@*|node()" priority="-2" mode="M87">
      <xsl:apply-templates select="*" mode="M87"/>
   </xsl:template>
   <!--PATTERN schematron-constraint-tei_all-settlement-calendar-calendar-check-settlement-87-->
   <!--RULE -->
   <xsl:template match="tei:*[@calendar]" priority="1000" mode="M88">

		<!--ASSERT -->
      <xsl:choose>
         <xsl:when test="string-length( normalize-space(.) ) gt 0"/>
         <xsl:otherwise>
            <xsl:message> @calendar indicates one or more
                        systems or calendars to which the date represented by the content of this element belongs,
                        but this <xsl:text/>
               <xsl:value-of select="name(.)"/>
               <xsl:text/> element has no textual content. (string-length( normalize-space(.) ) gt 0)</xsl:message>
         </xsl:otherwise>
      </xsl:choose>
      <xsl:apply-templates select="*" mode="M88"/>
   </xsl:template>
   <xsl:template match="text()" priority="-1" mode="M88"/>
   <xsl:template match="@*|node()" priority="-2" mode="M88">
      <xsl:apply-templates select="*" mode="M88"/>
   </xsl:template>
   <!--PATTERN schematron-constraint-tei_all-district-calendar-calendar-check-district-88-->
   <!--RULE -->
   <xsl:template match="tei:*[@calendar]" priority="1000" mode="M89">

		<!--ASSERT -->
      <xsl:choose>
         <xsl:when test="string-length( normalize-space(.) ) gt 0"/>
         <xsl:otherwise>
            <xsl:message> @calendar indicates one or more
                        systems or calendars to which the date represented by the content of this element belongs,
                        but this <xsl:text/>
               <xsl:value-of select="name(.)"/>
               <xsl:text/> element has no textual content. (string-length( normalize-space(.) ) gt 0)</xsl:message>
         </xsl:otherwise>
      </xsl:choose>
      <xsl:apply-templates select="*" mode="M89"/>
   </xsl:template>
   <xsl:template match="text()" priority="-1" mode="M89"/>
   <xsl:template match="@*|node()" priority="-2" mode="M89">
      <xsl:apply-templates select="*" mode="M89"/>
   </xsl:template>
   <!--PATTERN schematron-constraint-tei_all-offset-calendar-calendar-check-offset-89-->
   <!--RULE -->
   <xsl:template match="tei:*[@calendar]" priority="1000" mode="M90">

		<!--ASSERT -->
      <xsl:choose>
         <xsl:when test="string-length( normalize-space(.) ) gt 0"/>
         <xsl:otherwise>
            <xsl:message> @calendar indicates one or more
                        systems or calendars to which the date represented by the content of this element belongs,
                        but this <xsl:text/>
               <xsl:value-of select="name(.)"/>
               <xsl:text/> element has no textual content. (string-length( normalize-space(.) ) gt 0)</xsl:message>
         </xsl:otherwise>
      </xsl:choose>
      <xsl:apply-templates select="*" mode="M90"/>
   </xsl:template>
   <xsl:template match="text()" priority="-1" mode="M90"/>
   <xsl:template match="@*|node()" priority="-2" mode="M90">
      <xsl:apply-templates select="*" mode="M90"/>
   </xsl:template>
   <!--PATTERN schematron-constraint-tei_all-geogName-calendar-calendar-check-geogName-90-->
   <!--RULE -->
   <xsl:template match="tei:*[@calendar]" priority="1000" mode="M91">

		<!--ASSERT -->
      <xsl:choose>
         <xsl:when test="string-length( normalize-space(.) ) gt 0"/>
         <xsl:otherwise>
            <xsl:message> @calendar indicates one or more
                        systems or calendars to which the date represented by the content of this element belongs,
                        but this <xsl:text/>
               <xsl:value-of select="name(.)"/>
               <xsl:text/> element has no textual content. (string-length( normalize-space(.) ) gt 0)</xsl:message>
         </xsl:otherwise>
      </xsl:choose>
      <xsl:apply-templates select="*" mode="M91"/>
   </xsl:template>
   <xsl:template match="text()" priority="-1" mode="M91"/>
   <xsl:template match="@*|node()" priority="-2" mode="M91">
      <xsl:apply-templates select="*" mode="M91"/>
   </xsl:template>
   <!--PATTERN schematron-constraint-tei_all-geogFeat-calendar-calendar-check-geogFeat-91-->
   <!--RULE -->
   <xsl:template match="tei:*[@calendar]" priority="1000" mode="M92">

		<!--ASSERT -->
      <xsl:choose>
         <xsl:when test="string-length( normalize-space(.) ) gt 0"/>
         <xsl:otherwise>
            <xsl:message> @calendar indicates one or more
                        systems or calendars to which the date represented by the content of this element belongs,
                        but this <xsl:text/>
               <xsl:value-of select="name(.)"/>
               <xsl:text/> element has no textual content. (string-length( normalize-space(.) ) gt 0)</xsl:message>
         </xsl:otherwise>
      </xsl:choose>
      <xsl:apply-templates select="*" mode="M92"/>
   </xsl:template>
   <xsl:template match="text()" priority="-1" mode="M92"/>
   <xsl:template match="@*|node()" priority="-2" mode="M92">
      <xsl:apply-templates select="*" mode="M92"/>
   </xsl:template>
   <!--PATTERN schematron-constraint-tei_all-affiliation-calendar-calendar-check-affiliation-92-->
   <!--RULE -->
   <xsl:template match="tei:*[@calendar]" priority="1000" mode="M93">

		<!--ASSERT -->
      <xsl:choose>
         <xsl:when test="string-length( normalize-space(.) ) gt 0"/>
         <xsl:otherwise>
            <xsl:message> @calendar indicates one or more
                        systems or calendars to which the date represented by the content of this element belongs,
                        but this <xsl:text/>
               <xsl:value-of select="name(.)"/>
               <xsl:text/> element has no textual content. (string-length( normalize-space(.) ) gt 0)</xsl:message>
         </xsl:otherwise>
      </xsl:choose>
      <xsl:apply-templates select="*" mode="M93"/>
   </xsl:template>
   <xsl:template match="text()" priority="-1" mode="M93"/>
   <xsl:template match="@*|node()" priority="-2" mode="M93">
      <xsl:apply-templates select="*" mode="M93"/>
   </xsl:template>
   <!--PATTERN schematron-constraint-tei_all-age-calendar-calendar-check-age-93-->
   <!--RULE -->
   <xsl:template match="tei:*[@calendar]" priority="1000" mode="M94">

		<!--ASSERT -->
      <xsl:choose>
         <xsl:when test="string-length( normalize-space(.) ) gt 0"/>
         <xsl:otherwise>
            <xsl:message> @calendar indicates one or more
                        systems or calendars to which the date represented by the content of this element belongs,
                        but this <xsl:text/>
               <xsl:value-of select="name(.)"/>
               <xsl:text/> element has no textual content. (string-length( normalize-space(.) ) gt 0)</xsl:message>
         </xsl:otherwise>
      </xsl:choose>
      <xsl:apply-templates select="*" mode="M94"/>
   </xsl:template>
   <xsl:template match="text()" priority="-1" mode="M94"/>
   <xsl:template match="@*|node()" priority="-2" mode="M94">
      <xsl:apply-templates select="*" mode="M94"/>
   </xsl:template>
   <!--PATTERN schematron-constraint-tei_all-birth-calendar-calendar-check-birth-94-->
   <!--RULE -->
   <xsl:template match="tei:*[@calendar]" priority="1000" mode="M95">

		<!--ASSERT -->
      <xsl:choose>
         <xsl:when test="string-length( normalize-space(.) ) gt 0"/>
         <xsl:otherwise>
            <xsl:message> @calendar indicates one or more
                        systems or calendars to which the date represented by the content of this element belongs,
                        but this <xsl:text/>
               <xsl:value-of select="name(.)"/>
               <xsl:text/> element has no textual content. (string-length( normalize-space(.) ) gt 0)</xsl:message>
         </xsl:otherwise>
      </xsl:choose>
      <xsl:apply-templates select="*" mode="M95"/>
   </xsl:template>
   <xsl:template match="text()" priority="-1" mode="M95"/>
   <xsl:template match="@*|node()" priority="-2" mode="M95">
      <xsl:apply-templates select="*" mode="M95"/>
   </xsl:template>
   <!--PATTERN schematron-constraint-tei_all-climate-calendar-calendar-check-climate-95-->
   <!--RULE -->
   <xsl:template match="tei:*[@calendar]" priority="1000" mode="M96">

		<!--ASSERT -->
      <xsl:choose>
         <xsl:when test="string-length( normalize-space(.) ) gt 0"/>
         <xsl:otherwise>
            <xsl:message> @calendar indicates one or more
                        systems or calendars to which the date represented by the content of this element belongs,
                        but this <xsl:text/>
               <xsl:value-of select="name(.)"/>
               <xsl:text/> element has no textual content. (string-length( normalize-space(.) ) gt 0)</xsl:message>
         </xsl:otherwise>
      </xsl:choose>
      <xsl:apply-templates select="*" mode="M96"/>
   </xsl:template>
   <xsl:template match="text()" priority="-1" mode="M96"/>
   <xsl:template match="@*|node()" priority="-2" mode="M96">
      <xsl:apply-templates select="*" mode="M96"/>
   </xsl:template>
   <!--PATTERN schematron-constraint-tei_all-death-calendar-calendar-check-death-96-->
   <!--RULE -->
   <xsl:template match="tei:*[@calendar]" priority="1000" mode="M97">

		<!--ASSERT -->
      <xsl:choose>
         <xsl:when test="string-length( normalize-space(.) ) gt 0"/>
         <xsl:otherwise>
            <xsl:message> @calendar indicates one or more
                        systems or calendars to which the date represented by the content of this element belongs,
                        but this <xsl:text/>
               <xsl:value-of select="name(.)"/>
               <xsl:text/> element has no textual content. (string-length( normalize-space(.) ) gt 0)</xsl:message>
         </xsl:otherwise>
      </xsl:choose>
      <xsl:apply-templates select="*" mode="M97"/>
   </xsl:template>
   <xsl:template match="text()" priority="-1" mode="M97"/>
   <xsl:template match="@*|node()" priority="-2" mode="M97">
      <xsl:apply-templates select="*" mode="M97"/>
   </xsl:template>
   <!--PATTERN schematron-constraint-tei_all-education-calendar-calendar-check-education-97-->
   <!--RULE -->
   <xsl:template match="tei:*[@calendar]" priority="1000" mode="M98">

		<!--ASSERT -->
      <xsl:choose>
         <xsl:when test="string-length( normalize-space(.) ) gt 0"/>
         <xsl:otherwise>
            <xsl:message> @calendar indicates one or more
                        systems or calendars to which the date represented by the content of this element belongs,
                        but this <xsl:text/>
               <xsl:value-of select="name(.)"/>
               <xsl:text/> element has no textual content. (string-length( normalize-space(.) ) gt 0)</xsl:message>
         </xsl:otherwise>
      </xsl:choose>
      <xsl:apply-templates select="*" mode="M98"/>
   </xsl:template>
   <xsl:template match="text()" priority="-1" mode="M98"/>
   <xsl:template match="@*|node()" priority="-2" mode="M98">
      <xsl:apply-templates select="*" mode="M98"/>
   </xsl:template>
   <!--PATTERN schematron-constraint-tei_all-event-calendar-calendar-check-event-98-->
   <!--RULE -->
   <xsl:template match="tei:*[@calendar]" priority="1000" mode="M99">

		<!--ASSERT -->
      <xsl:choose>
         <xsl:when test="string-length( normalize-space(.) ) gt 0"/>
         <xsl:otherwise>
            <xsl:message> @calendar indicates one or more
            systems or calendars to which the date represented by the content of this element belongs,
            but this <xsl:text/>
               <xsl:value-of select="name(.)"/>
               <xsl:text/> element has no textual content. (string-length( normalize-space(.) ) gt 0)</xsl:message>
         </xsl:otherwise>
      </xsl:choose>
      <xsl:apply-templates select="*" mode="M99"/>
   </xsl:template>
   <xsl:template match="text()" priority="-1" mode="M99"/>
   <xsl:template match="@*|node()" priority="-2" mode="M99">
      <xsl:apply-templates select="*" mode="M99"/>
   </xsl:template>
   <!--PATTERN schematron-constraint-tei_all-faith-calendar-calendar-check-faith-99-->
   <!--RULE -->
   <xsl:template match="tei:*[@calendar]" priority="1000" mode="M100">

		<!--ASSERT -->
      <xsl:choose>
         <xsl:when test="string-length( normalize-space(.) ) gt 0"/>
         <xsl:otherwise>
            <xsl:message> @calendar indicates one or more
                        systems or calendars to which the date represented by the content of this element belongs,
                        but this <xsl:text/>
               <xsl:value-of select="name(.)"/>
               <xsl:text/> element has no textual content. (string-length( normalize-space(.) ) gt 0)</xsl:message>
         </xsl:otherwise>
      </xsl:choose>
      <xsl:apply-templates select="*" mode="M100"/>
   </xsl:template>
   <xsl:template match="text()" priority="-1" mode="M100"/>
   <xsl:template match="@*|node()" priority="-2" mode="M100">
      <xsl:apply-templates select="*" mode="M100"/>
   </xsl:template>
   <!--PATTERN schematron-constraint-tei_all-floruit-calendar-calendar-check-floruit-100-->
   <!--RULE -->
   <xsl:template match="tei:*[@calendar]" priority="1000" mode="M101">

		<!--ASSERT -->
      <xsl:choose>
         <xsl:when test="string-length( normalize-space(.) ) gt 0"/>
         <xsl:otherwise>
            <xsl:message> @calendar indicates one or more
                        systems or calendars to which the date represented by the content of this element belongs,
                        but this <xsl:text/>
               <xsl:value-of select="name(.)"/>
               <xsl:text/> element has no textual content. (string-length( normalize-space(.) ) gt 0)</xsl:message>
         </xsl:otherwise>
      </xsl:choose>
      <xsl:apply-templates select="*" mode="M101"/>
   </xsl:template>
   <xsl:template match="text()" priority="-1" mode="M101"/>
   <xsl:template match="@*|node()" priority="-2" mode="M101">
      <xsl:apply-templates select="*" mode="M101"/>
   </xsl:template>
   <!--PATTERN schematron-constraint-tei_all-gender-calendar-calendar-check-gender-101-->
   <!--RULE -->
   <xsl:template match="tei:*[@calendar]" priority="1000" mode="M102">

		<!--ASSERT -->
      <xsl:choose>
         <xsl:when test="string-length( normalize-space(.) ) gt 0"/>
         <xsl:otherwise>
            <xsl:message> @calendar indicates one or more
                        systems or calendars to which the date represented by the content of this element belongs,
                        but this <xsl:text/>
               <xsl:value-of select="name(.)"/>
               <xsl:text/> element has no textual content. (string-length( normalize-space(.) ) gt 0)</xsl:message>
         </xsl:otherwise>
      </xsl:choose>
      <xsl:apply-templates select="*" mode="M102"/>
   </xsl:template>
   <xsl:template match="text()" priority="-1" mode="M102"/>
   <xsl:template match="@*|node()" priority="-2" mode="M102">
      <xsl:apply-templates select="*" mode="M102"/>
   </xsl:template>
   <!--PATTERN schematron-constraint-tei_all-langKnowledge-calendar-calendar-check-langKnowledge-102-->
   <!--RULE -->
   <xsl:template match="tei:*[@calendar]" priority="1000" mode="M103">

		<!--ASSERT -->
      <xsl:choose>
         <xsl:when test="string-length( normalize-space(.) ) gt 0"/>
         <xsl:otherwise>
            <xsl:message> @calendar indicates one or more
                        systems or calendars to which the date represented by the content of this element belongs,
                        but this <xsl:text/>
               <xsl:value-of select="name(.)"/>
               <xsl:text/> element has no textual content. (string-length( normalize-space(.) ) gt 0)</xsl:message>
         </xsl:otherwise>
      </xsl:choose>
      <xsl:apply-templates select="*" mode="M103"/>
   </xsl:template>
   <xsl:template match="text()" priority="-1" mode="M103"/>
   <xsl:template match="@*|node()" priority="-2" mode="M103">
      <xsl:apply-templates select="*" mode="M103"/>
   </xsl:template>
   <!--PATTERN schematron-constraint-tei_all-langKnown-calendar-calendar-check-langKnown-103-->
   <!--RULE -->
   <xsl:template match="tei:*[@calendar]" priority="1000" mode="M104">

		<!--ASSERT -->
      <xsl:choose>
         <xsl:when test="string-length( normalize-space(.) ) gt 0"/>
         <xsl:otherwise>
            <xsl:message> @calendar indicates one or more
                        systems or calendars to which the date represented by the content of this element belongs,
                        but this <xsl:text/>
               <xsl:value-of select="name(.)"/>
               <xsl:text/> element has no textual content. (string-length( normalize-space(.) ) gt 0)</xsl:message>
         </xsl:otherwise>
      </xsl:choose>
      <xsl:apply-templates select="*" mode="M104"/>
   </xsl:template>
   <xsl:template match="text()" priority="-1" mode="M104"/>
   <xsl:template match="@*|node()" priority="-2" mode="M104">
      <xsl:apply-templates select="*" mode="M104"/>
   </xsl:template>
   <!--PATTERN schematron-constraint-tei_all-location-calendar-calendar-check-location-104-->
   <!--RULE -->
   <xsl:template match="tei:*[@calendar]" priority="1000" mode="M105">

		<!--ASSERT -->
      <xsl:choose>
         <xsl:when test="string-length( normalize-space(.) ) gt 0"/>
         <xsl:otherwise>
            <xsl:message> @calendar indicates one or more
                        systems or calendars to which the date represented by the content of this element belongs,
                        but this <xsl:text/>
               <xsl:value-of select="name(.)"/>
               <xsl:text/> element has no textual content. (string-length( normalize-space(.) ) gt 0)</xsl:message>
         </xsl:otherwise>
      </xsl:choose>
      <xsl:apply-templates select="*" mode="M105"/>
   </xsl:template>
   <xsl:template match="text()" priority="-1" mode="M105"/>
   <xsl:template match="@*|node()" priority="-2" mode="M105">
      <xsl:apply-templates select="*" mode="M105"/>
   </xsl:template>
   <!--PATTERN schematron-constraint-tei_all-nationality-calendar-calendar-check-nationality-105-->
   <!--RULE -->
   <xsl:template match="tei:*[@calendar]" priority="1000" mode="M106">

		<!--ASSERT -->
      <xsl:choose>
         <xsl:when test="string-length( normalize-space(.) ) gt 0"/>
         <xsl:otherwise>
            <xsl:message> @calendar indicates one or more
                        systems or calendars to which the date represented by the content of this element belongs,
                        but this <xsl:text/>
               <xsl:value-of select="name(.)"/>
               <xsl:text/> element has no textual content. (string-length( normalize-space(.) ) gt 0)</xsl:message>
         </xsl:otherwise>
      </xsl:choose>
      <xsl:apply-templates select="*" mode="M106"/>
   </xsl:template>
   <xsl:template match="text()" priority="-1" mode="M106"/>
   <xsl:template match="@*|node()" priority="-2" mode="M106">
      <xsl:apply-templates select="*" mode="M106"/>
   </xsl:template>
   <!--PATTERN schematron-constraint-tei_all-occupation-calendar-calendar-check-occupation-106-->
   <!--RULE -->
   <xsl:template match="tei:*[@calendar]" priority="1000" mode="M107">

		<!--ASSERT -->
      <xsl:choose>
         <xsl:when test="string-length( normalize-space(.) ) gt 0"/>
         <xsl:otherwise>
            <xsl:message> @calendar indicates one or more
                        systems or calendars to which the date represented by the content of this element belongs,
                        but this <xsl:text/>
               <xsl:value-of select="name(.)"/>
               <xsl:text/> element has no textual content. (string-length( normalize-space(.) ) gt 0)</xsl:message>
         </xsl:otherwise>
      </xsl:choose>
      <xsl:apply-templates select="*" mode="M107"/>
   </xsl:template>
   <xsl:template match="text()" priority="-1" mode="M107"/>
   <xsl:template match="@*|node()" priority="-2" mode="M107">
      <xsl:apply-templates select="*" mode="M107"/>
   </xsl:template>
   <!--PATTERN schematron-constraint-tei_all-persPronouns-calendar-calendar-check-persPronouns-107-->
   <!--RULE -->
   <xsl:template match="tei:*[@calendar]" priority="1000" mode="M108">

		<!--ASSERT -->
      <xsl:choose>
         <xsl:when test="string-length( normalize-space(.) ) gt 0"/>
         <xsl:otherwise>
            <xsl:message> @calendar indicates one or more
                        systems or calendars to which the date represented by the content of this element belongs,
                        but this <xsl:text/>
               <xsl:value-of select="name(.)"/>
               <xsl:text/> element has no textual content. (string-length( normalize-space(.) ) gt 0)</xsl:message>
         </xsl:otherwise>
      </xsl:choose>
      <xsl:apply-templates select="*" mode="M108"/>
   </xsl:template>
   <xsl:template match="text()" priority="-1" mode="M108"/>
   <xsl:template match="@*|node()" priority="-2" mode="M108">
      <xsl:apply-templates select="*" mode="M108"/>
   </xsl:template>
   <!--PATTERN schematron-constraint-tei_all-population-calendar-calendar-check-population-108-->
   <!--RULE -->
   <xsl:template match="tei:*[@calendar]" priority="1000" mode="M109">

		<!--ASSERT -->
      <xsl:choose>
         <xsl:when test="string-length( normalize-space(.) ) gt 0"/>
         <xsl:otherwise>
            <xsl:message> @calendar indicates one or more
                        systems or calendars to which the date represented by the content of this element belongs,
                        but this <xsl:text/>
               <xsl:value-of select="name(.)"/>
               <xsl:text/> element has no textual content. (string-length( normalize-space(.) ) gt 0)</xsl:message>
         </xsl:otherwise>
      </xsl:choose>
      <xsl:apply-templates select="*" mode="M109"/>
   </xsl:template>
   <xsl:template match="text()" priority="-1" mode="M109"/>
   <xsl:template match="@*|node()" priority="-2" mode="M109">
      <xsl:apply-templates select="*" mode="M109"/>
   </xsl:template>
   <!--PATTERN schematron-constraint-tei_all-relation-reforkeyorname-109-->
   <!--RULE -->
   <xsl:template match="tei:relation" priority="1000" mode="M110">

		<!--ASSERT -->
      <xsl:choose>
         <xsl:when test="@ref or @key or @name"/>
         <xsl:otherwise>
            <xsl:message>One of the attributes  'name', 'ref' or 'key' must be supplied (@ref or @key or @name)</xsl:message>
         </xsl:otherwise>
      </xsl:choose>
      <xsl:apply-templates select="*" mode="M110"/>
   </xsl:template>
   <xsl:template match="text()" priority="-1" mode="M110"/>
   <xsl:template match="@*|node()" priority="-2" mode="M110">
      <xsl:apply-templates select="*" mode="M110"/>
   </xsl:template>
   <!--PATTERN schematron-constraint-tei_all-relation-activemutual-110-->
   <!--RULE -->
   <xsl:template match="tei:relation" priority="1000" mode="M111">

		<!--REPORT -->
      <xsl:if test="@active and @mutual">
         <xsl:message>Only one of the attributes @active and @mutual may be supplied (@active and @mutual)</xsl:message>
      </xsl:if>
      <xsl:apply-templates select="*" mode="M111"/>
   </xsl:template>
   <xsl:template match="text()" priority="-1" mode="M111"/>
   <xsl:template match="@*|node()" priority="-2" mode="M111">
      <xsl:apply-templates select="*" mode="M111"/>
   </xsl:template>
   <!--PATTERN schematron-constraint-tei_all-relation-activepassive-111-->
   <!--RULE -->
   <xsl:template match="tei:relation" priority="1000" mode="M112">

		<!--REPORT -->
      <xsl:if test="@passive and not(@active)">
         <xsl:message>the attribute 'passive' may be supplied only if the attribute 'active' is supplied (@passive and not(@active))</xsl:message>
      </xsl:if>
      <xsl:apply-templates select="*" mode="M112"/>
   </xsl:template>
   <xsl:template match="text()" priority="-1" mode="M112"/>
   <xsl:template match="@*|node()" priority="-2" mode="M112">
      <xsl:apply-templates select="*" mode="M112"/>
   </xsl:template>
   <!--PATTERN schematron-constraint-tei_all-relation-calendar-calendar-check-relation-112-->
   <!--RULE -->
   <xsl:template match="tei:*[@calendar]" priority="1000" mode="M113">

		<!--ASSERT -->
      <xsl:choose>
         <xsl:when test="string-length( normalize-space(.) ) gt 0"/>
         <xsl:otherwise>
            <xsl:message> @calendar indicates one or more
                        systems or calendars to which the date represented by the content of this element belongs,
                        but this <xsl:text/>
               <xsl:value-of select="name(.)"/>
               <xsl:text/> element has no textual content. (string-length( normalize-space(.) ) gt 0)</xsl:message>
         </xsl:otherwise>
      </xsl:choose>
      <xsl:apply-templates select="*" mode="M113"/>
   </xsl:template>
   <xsl:template match="text()" priority="-1" mode="M113"/>
   <xsl:template match="@*|node()" priority="-2" mode="M113">
      <xsl:apply-templates select="*" mode="M113"/>
   </xsl:template>
   <!--PATTERN schematron-constraint-tei_all-residence-calendar-calendar-check-residence-113-->
   <!--RULE -->
   <xsl:template match="tei:*[@calendar]" priority="1000" mode="M114">

		<!--ASSERT -->
      <xsl:choose>
         <xsl:when test="string-length( normalize-space(.) ) gt 0"/>
         <xsl:otherwise>
            <xsl:message> @calendar indicates one or more
                        systems or calendars to which the date represented by the content of this element belongs,
                        but this <xsl:text/>
               <xsl:value-of select="name(.)"/>
               <xsl:text/> element has no textual content. (string-length( normalize-space(.) ) gt 0)</xsl:message>
         </xsl:otherwise>
      </xsl:choose>
      <xsl:apply-templates select="*" mode="M114"/>
   </xsl:template>
   <xsl:template match="text()" priority="-1" mode="M114"/>
   <xsl:template match="@*|node()" priority="-2" mode="M114">
      <xsl:apply-templates select="*" mode="M114"/>
   </xsl:template>
   <!--PATTERN schematron-constraint-tei_all-sex-calendar-calendar-check-sex-114-->
   <!--RULE -->
   <xsl:template match="tei:*[@calendar]" priority="1000" mode="M115">

		<!--ASSERT -->
      <xsl:choose>
         <xsl:when test="string-length( normalize-space(.) ) gt 0"/>
         <xsl:otherwise>
            <xsl:message> @calendar indicates one or more
                        systems or calendars to which the date represented by the content of this element belongs,
                        but this <xsl:text/>
               <xsl:value-of select="name(.)"/>
               <xsl:text/> element has no textual content. (string-length( normalize-space(.) ) gt 0)</xsl:message>
         </xsl:otherwise>
      </xsl:choose>
      <xsl:apply-templates select="*" mode="M115"/>
   </xsl:template>
   <xsl:template match="text()" priority="-1" mode="M115"/>
   <xsl:template match="@*|node()" priority="-2" mode="M115">
      <xsl:apply-templates select="*" mode="M115"/>
   </xsl:template>
   <!--PATTERN schematron-constraint-tei_all-socecStatus-calendar-calendar-check-socecStatus-115-->
   <!--RULE -->
   <xsl:template match="tei:*[@calendar]" priority="1000" mode="M116">

		<!--ASSERT -->
      <xsl:choose>
         <xsl:when test="string-length( normalize-space(.) ) gt 0"/>
         <xsl:otherwise>
            <xsl:message> @calendar indicates one or more
                        systems or calendars to which the date represented by the content of this element belongs,
                        but this <xsl:text/>
               <xsl:value-of select="name(.)"/>
               <xsl:text/> element has no textual content. (string-length( normalize-space(.) ) gt 0)</xsl:message>
         </xsl:otherwise>
      </xsl:choose>
      <xsl:apply-templates select="*" mode="M116"/>
   </xsl:template>
   <xsl:template match="text()" priority="-1" mode="M116"/>
   <xsl:template match="@*|node()" priority="-2" mode="M116">
      <xsl:apply-templates select="*" mode="M116"/>
   </xsl:template>
   <!--PATTERN schematron-constraint-tei_all-state-calendar-calendar-check-state-116-->
   <!--RULE -->
   <xsl:template match="tei:*[@calendar]" priority="1000" mode="M117">

		<!--ASSERT -->
      <xsl:choose>
         <xsl:when test="string-length( normalize-space(.) ) gt 0"/>
         <xsl:otherwise>
            <xsl:message> @calendar indicates one or more
                        systems or calendars to which the date represented by the content of this element belongs,
                        but this <xsl:text/>
               <xsl:value-of select="name(.)"/>
               <xsl:text/> element has no textual content. (string-length( normalize-space(.) ) gt 0)</xsl:message>
         </xsl:otherwise>
      </xsl:choose>
      <xsl:apply-templates select="*" mode="M117"/>
   </xsl:template>
   <xsl:template match="text()" priority="-1" mode="M117"/>
   <xsl:template match="@*|node()" priority="-2" mode="M117">
      <xsl:apply-templates select="*" mode="M117"/>
   </xsl:template>
   <!--PATTERN schematron-constraint-tei_all-terrain-calendar-calendar-check-terrain-117-->
   <!--RULE -->
   <xsl:template match="tei:*[@calendar]" priority="1000" mode="M118">

		<!--ASSERT -->
      <xsl:choose>
         <xsl:when test="string-length( normalize-space(.) ) gt 0"/>
         <xsl:otherwise>
            <xsl:message> @calendar indicates one or more
                        systems or calendars to which the date represented by the content of this element belongs,
                        but this <xsl:text/>
               <xsl:value-of select="name(.)"/>
               <xsl:text/> element has no textual content. (string-length( normalize-space(.) ) gt 0)</xsl:message>
         </xsl:otherwise>
      </xsl:choose>
      <xsl:apply-templates select="*" mode="M118"/>
   </xsl:template>
   <xsl:template match="text()" priority="-1" mode="M118"/>
   <xsl:template match="@*|node()" priority="-2" mode="M118">
      <xsl:apply-templates select="*" mode="M118"/>
   </xsl:template>
   <!--PATTERN schematron-constraint-tei_all-trait-calendar-calendar-check-trait-118-->
   <!--RULE -->
   <xsl:template match="tei:*[@calendar]" priority="1000" mode="M119">

		<!--ASSERT -->
      <xsl:choose>
         <xsl:when test="string-length( normalize-space(.) ) gt 0"/>
         <xsl:otherwise>
            <xsl:message> @calendar indicates one or more
                        systems or calendars to which the date represented by the content of this element belongs,
                        but this <xsl:text/>
               <xsl:value-of select="name(.)"/>
               <xsl:text/> element has no textual content. (string-length( normalize-space(.) ) gt 0)</xsl:message>
         </xsl:otherwise>
      </xsl:choose>
      <xsl:apply-templates select="*" mode="M119"/>
   </xsl:template>
   <xsl:template match="text()" priority="-1" mode="M119"/>
   <xsl:template match="@*|node()" priority="-2" mode="M119">
      <xsl:apply-templates select="*" mode="M119"/>
   </xsl:template>
   <!--PATTERN schematron-constraint-tei_all-objectName-calendar-calendar-check-objectName-119-->
   <!--RULE -->
   <xsl:template match="tei:*[@calendar]" priority="1000" mode="M120">

		<!--ASSERT -->
      <xsl:choose>
         <xsl:when test="string-length( normalize-space(.) ) gt 0"/>
         <xsl:otherwise>
            <xsl:message> @calendar indicates one or more
                        systems or calendars to which the date represented by the content of this element belongs,
                        but this <xsl:text/>
               <xsl:value-of select="name(.)"/>
               <xsl:text/> element has no textual content. (string-length( normalize-space(.) ) gt 0)</xsl:message>
         </xsl:otherwise>
      </xsl:choose>
      <xsl:apply-templates select="*" mode="M120"/>
   </xsl:template>
   <xsl:template match="text()" priority="-1" mode="M120"/>
   <xsl:template match="@*|node()" priority="-2" mode="M120">
      <xsl:apply-templates select="*" mode="M120"/>
   </xsl:template>
   <!--PATTERN schematron-constraint-tei_all-link-linkTargets3-120-->
   <!--RULE -->
   <xsl:template match="tei:link" priority="1000" mode="M121">

		<!--ASSERT -->
      <xsl:choose>
         <xsl:when test="contains(normalize-space(@target),' ')"/>
         <xsl:otherwise>
            <xsl:message>You must supply at least two values for @target or  on <xsl:text/>
               <xsl:value-of select="name(.)"/>
               <xsl:text/>
          (contains(normalize-space(@target),' '))</xsl:message>
         </xsl:otherwise>
      </xsl:choose>
      <xsl:apply-templates select="*" mode="M121"/>
   </xsl:template>
   <xsl:template match="text()" priority="-1" mode="M121"/>
   <xsl:template match="@*|node()" priority="-2" mode="M121">
      <xsl:apply-templates select="*" mode="M121"/>
   </xsl:template>
   <!--PATTERN schematron-constraint-tei_all-ab-abstractModel-structure-ab-in-l-or-lg-121-->
   <!--RULE -->
   <xsl:template match="tei:ab" priority="1000" mode="M122">

		<!--REPORT -->
      <xsl:if test="(ancestor::tei:l or ancestor::tei:lg) and not( ancestor::tei:floatingText |parent::tei:figure |parent::tei:note )">
         <xsl:message>
        Abstract model violation: Lines may not contain higher-level divisions such as p or ab, unless ab is a child of figure or note, or is a descendant of floatingText.
       ((ancestor::tei:l or ancestor::tei:lg) and not( ancestor::tei:floatingText |parent::tei:figure |parent::tei:note ))</xsl:message>
      </xsl:if>
      <xsl:apply-templates select="*" mode="M122"/>
   </xsl:template>
   <xsl:template match="text()" priority="-1" mode="M122"/>
   <xsl:template match="@*|node()" priority="-2" mode="M122">
      <xsl:apply-templates select="*" mode="M122"/>
   </xsl:template>
   <!--PATTERN schematron-constraint-tei_all-join-joinTargets3-122-->
   <!--RULE -->
   <xsl:template match="tei:join" priority="1000" mode="M123">

		<!--ASSERT -->
      <xsl:choose>
         <xsl:when test="contains(@target,' ')"/>
         <xsl:otherwise>
            <xsl:message>
You must supply at least two values for @target on <xsl:text/>
               <xsl:value-of select="name(.)"/>
               <xsl:text/>
          (contains(@target,' '))</xsl:message>
         </xsl:otherwise>
      </xsl:choose>
      <xsl:apply-templates select="*" mode="M123"/>
   </xsl:template>
   <xsl:template match="text()" priority="-1" mode="M123"/>
   <xsl:template match="@*|node()" priority="-2" mode="M123">
      <xsl:apply-templates select="*" mode="M123"/>
   </xsl:template>
   <!--PATTERN schematron-constraint-tei_all-standOff-nested_standOff_should_be_typed-123-->
   <!--RULE -->
   <xsl:template match="tei:standOff" priority="1000" mode="M124">

		<!--ASSERT -->
      <xsl:choose>
         <xsl:when test="@type or not(ancestor::tei:standOff)"/>
         <xsl:otherwise>
            <xsl:message>This
      <xsl:text/>
               <xsl:value-of select="name(.)"/>
               <xsl:text/> element must have a @type attribute, since it is
      nested inside a <xsl:text/>
               <xsl:value-of select="name(.)"/>
               <xsl:text/>
          (@type or not(ancestor::tei:standOff))</xsl:message>
         </xsl:otherwise>
      </xsl:choose>
      <xsl:apply-templates select="*" mode="M124"/>
   </xsl:template>
   <xsl:template match="text()" priority="-1" mode="M124"/>
   <xsl:template match="@*|node()" priority="-2" mode="M124">
      <xsl:apply-templates select="*" mode="M124"/>
   </xsl:template>
   <!--PATTERN schematron-constraint-tei_all-precision-calendar-calendar-check-precision-124-->
   <!--RULE -->
   <xsl:template match="tei:*[@calendar]" priority="1000" mode="M125">

		<!--ASSERT -->
      <xsl:choose>
         <xsl:when test="string-length( normalize-space(.) ) gt 0"/>
         <xsl:otherwise>
            <xsl:message> @calendar indicates one or more
                        systems or calendars to which the date represented by the content of this element belongs,
                        but this <xsl:text/>
               <xsl:value-of select="name(.)"/>
               <xsl:text/> element has no textual content. (string-length( normalize-space(.) ) gt 0)</xsl:message>
         </xsl:otherwise>
      </xsl:choose>
      <xsl:apply-templates select="*" mode="M125"/>
   </xsl:template>
   <xsl:template match="text()" priority="-1" mode="M125"/>
   <xsl:template match="@*|node()" priority="-2" mode="M125">
      <xsl:apply-templates select="*" mode="M125"/>
   </xsl:template>
   <!--PATTERN schematron-constraint-tei_all-att.repeatable-MINandMAXoccurs-125-->
   <!--RULE -->
   <xsl:template match="*[ @minOccurs and @maxOccurs ]" priority="1001" mode="M126">
      <xsl:variable name="min" select="@minOccurs cast as xs:integer"/>
      <xsl:variable name="max"
                    select="if ( normalize-space( @maxOccurs ) eq 'unbounded') then -1 else @maxOccurs cast as xs:integer"/>
      <!--ASSERT -->
      <xsl:choose>
         <xsl:when test="$max eq -1 or $max ge $min"/>
         <xsl:otherwise>
            <xsl:message>@maxOccurs should be greater than or equal to @minOccurs ($max eq -1 or $max ge $min)</xsl:message>
         </xsl:otherwise>
      </xsl:choose>
      <xsl:apply-templates select="*" mode="M126"/>
   </xsl:template>
   <!--RULE -->
   <xsl:template match="*[ @minOccurs and not( @maxOccurs ) ]"
                 priority="1000"
                 mode="M126">

		<!--ASSERT -->
      <xsl:choose>
         <xsl:when test="@minOccurs cast as xs:integer lt 2"/>
         <xsl:otherwise>
            <xsl:message>When @maxOccurs is not specified, @minOccurs must be 0 or 1 (@minOccurs cast as xs:integer lt 2)</xsl:message>
         </xsl:otherwise>
      </xsl:choose>
      <xsl:apply-templates select="*" mode="M126"/>
   </xsl:template>
   <xsl:template match="text()" priority="-1" mode="M126"/>
   <xsl:template match="@*|node()" priority="-2" mode="M126">
      <xsl:apply-templates select="*" mode="M126"/>
   </xsl:template>
   <!--PATTERN schematron-constraint-tei_all-att.identified-spec-in-module-126-->
   <!--RULE -->
   <xsl:template match="tei:elementSpec[@module]|tei:classSpec[@module]|tei:macroSpec[@module]"
                 priority="1000"
                 mode="M127">

		<!--ASSERT -->
      <xsl:choose>
         <xsl:when test="(not(ancestor::tei:schemaSpec | ancestor::tei:TEI | ancestor::tei:teiCorpus)) or (not(@module) or (not(//tei:moduleSpec) and not(//tei:moduleRef)) or (//tei:moduleSpec[@ident = current()/@module]) or (//tei:moduleRef[@key = current()/@module]))"/>
         <xsl:otherwise>
            <xsl:message>
        Specification <xsl:text/>
               <xsl:value-of select="@ident"/>
               <xsl:text/>: the value of the module attribute ("<xsl:text/>
               <xsl:value-of select="@module"/>
               <xsl:text/>") 
should correspond to an existing module, via a moduleSpec or
      moduleRef ((not(ancestor::tei:schemaSpec | ancestor::tei:TEI | ancestor::tei:teiCorpus)) or (not(@module) or (not(//tei:moduleSpec) and not(//tei:moduleRef)) or (//tei:moduleSpec[@ident = current()/@module]) or (//tei:moduleRef[@key = current()/@module])))</xsl:message>
         </xsl:otherwise>
      </xsl:choose>
      <xsl:apply-templates select="*" mode="M127"/>
   </xsl:template>
   <xsl:template match="text()" priority="-1" mode="M127"/>
   <xsl:template match="@*|node()" priority="-2" mode="M127">
      <xsl:apply-templates select="*" mode="M127"/>
   </xsl:template>
   <!--PATTERN schematron-constraint-tei_all-att.deprecated-validUntil-deprecation-two-month-warning-127-->
   <!--RULE -->
   <xsl:template match="tei:*[@validUntil]" priority="1000" mode="M128">
      <xsl:variable name="advance_warning_period"
                    select="current-date() + xs:dayTimeDuration('P60D')"/>
      <xsl:variable name="me_phrase"
                    select="if (@ident) then concat('The ', @ident ) else concat('This ', local-name(.), ' of ', ancestor::tei:*[@ident][1]/@ident )"/>
      <!--ASSERT -->
      <xsl:choose>
         <xsl:when test="@validUntil cast as xs:date ge current-date()"/>
         <xsl:otherwise>
            <xsl:message>
               <xsl:text/>
               <xsl:value-of select="concat( $me_phrase, ' construct is outdated (as of ', @validUntil, '); ODD processors may ignore it, and its use is no longer supported' )"/>
               <xsl:text/>
          (@validUntil cast as xs:date ge current-date())</xsl:message>
         </xsl:otherwise>
      </xsl:choose>
      <!--ASSERT warning-->
      <xsl:choose>
         <xsl:when test="@validUntil cast as xs:date ge $advance_warning_period"/>
         <xsl:otherwise>
            <xsl:message>
               <xsl:text/>
               <xsl:value-of select="concat( $me_phrase, ' construct becomes outdated on ', @validUntil )"/>
               <xsl:text/>
          (@validUntil cast as xs:date ge $advance_warning_period / warning)</xsl:message>
         </xsl:otherwise>
      </xsl:choose>
      <xsl:apply-templates select="*" mode="M128"/>
   </xsl:template>
   <xsl:template match="text()" priority="-1" mode="M128"/>
   <xsl:template match="@*|node()" priority="-2" mode="M128">
      <xsl:apply-templates select="*" mode="M128"/>
   </xsl:template>
   <!--PATTERN schematron-constraint-tei_all-att.deprecated-validUntil-deprecation-should-be-explained-128-->
   <!--RULE -->
   <xsl:template match="tei:*[@validUntil][ not( self::tei:valDesc | self::tei:valList | self::tei:defaultVal | self::tei:remarks )]"
                 priority="1000"
                 mode="M129">

		<!--ASSERT -->
      <xsl:choose>
         <xsl:when test="child::tei:desc[ @type eq 'deprecationInfo']"/>
         <xsl:otherwise>
            <xsl:message>
              A deprecated construct should include, whenever possible, an explanation, but this <xsl:text/>
               <xsl:value-of select="name(.)"/>
               <xsl:text/> does not have a child &lt;desc type="deprecationInfo"&gt; (child::tei:desc[ @type eq 'deprecationInfo'])</xsl:message>
         </xsl:otherwise>
      </xsl:choose>
      <xsl:apply-templates select="*" mode="M129"/>
   </xsl:template>
   <xsl:template match="text()" priority="-1" mode="M129"/>
   <xsl:template match="@*|node()" priority="-2" mode="M129">
      <xsl:apply-templates select="*" mode="M129"/>
   </xsl:template>
   <!--PATTERN schematron-constraint-tei_all-moduleRef-modref-129-->
   <!--RULE -->
   <xsl:template match="tei:moduleRef" priority="1000" mode="M130">

		<!--REPORT -->
      <xsl:if test="* and @key">
         <xsl:message>
Child elements of <xsl:text/>
            <xsl:value-of select="name(.)"/>
            <xsl:text/> are only allowed when an external module is being loaded
         (* and @key)</xsl:message>
      </xsl:if>
      <xsl:apply-templates select="*" mode="M130"/>
   </xsl:template>
   <xsl:template match="text()" priority="-1" mode="M130"/>
   <xsl:template match="@*|node()" priority="-2" mode="M130">
      <xsl:apply-templates select="*" mode="M130"/>
   </xsl:template>
   <!--PATTERN schematron-constraint-tei_all-moduleRef-prefix-not-same-prefix-130-->
   <!--RULE -->
   <xsl:template match="tei:moduleRef" priority="1000" mode="M131">

		<!--REPORT -->
      <xsl:if test="//*[ not( generate-id(.) eq generate-id( current() ) ) ]/@prefix = @prefix">
         <xsl:message>The prefix attribute
	    of <xsl:text/>
            <xsl:value-of select="name(.)"/>
            <xsl:text/> should not match that of any other
	    element (it would defeat the purpose) (//*[ not( generate-id(.) eq generate-id( current() ) ) ]/@prefix = @prefix)</xsl:message>
      </xsl:if>
      <xsl:apply-templates select="*" mode="M131"/>
   </xsl:template>
   <xsl:template match="text()" priority="-1" mode="M131"/>
   <xsl:template match="@*|node()" priority="-2" mode="M131">
      <xsl:apply-templates select="*" mode="M131"/>
   </xsl:template>
   <!--PATTERN schematron-constraint-tei_all-moduleRef-prefix-not-except-and-include-131-->
   <!--RULE -->
   <xsl:template match="tei:moduleRef" priority="1000" mode="M132">

		<!--REPORT -->
      <xsl:if test="@except and @include">
         <xsl:message>It is an error to supply both the @include and @except attributes (@except and @include)</xsl:message>
      </xsl:if>
      <xsl:apply-templates select="*" mode="M132"/>
   </xsl:template>
   <xsl:template match="text()" priority="-1" mode="M132"/>
   <xsl:template match="@*|node()" priority="-2" mode="M132">
      <xsl:apply-templates select="*" mode="M132"/>
   </xsl:template>
   <!--PATTERN schematron-constraint-tei_all-elementSpec-child-constraint-based-on-mode-132-->
   <!--RULE -->
   <xsl:template match="tei:elementSpec[ @mode eq 'delete' ]"
                 priority="1001"
                 mode="M133">

		<!--REPORT -->
      <xsl:if test="child::*">
         <xsl:message>This elementSpec element has a mode= of "delete" even though it has child elements. Change the mode= to "add", "change", or "replace", or remove the child elements. (child::*)</xsl:message>
      </xsl:if>
      <xsl:apply-templates select="*" mode="M133"/>
   </xsl:template>
   <!--RULE -->
   <xsl:template match="tei:elementSpec[ @mode = ('add','change','replace') ]"
                 priority="1000"
                 mode="M133">

		<!--ASSERT -->
      <xsl:choose>
         <xsl:when test="child::* | (@* except (@mode, @ident))"/>
         <xsl:otherwise>
            <xsl:message>This elementSpec element has a mode= of "<xsl:text/>
               <xsl:value-of select="@mode"/>
               <xsl:text/>", but does not have any child elements or schema-changing attributes. Specify child elements, use validUntil=, predeclare=, ns=, or prefix=, or change the mode= to "delete". (child::* | (@* except (@mode, @ident)))</xsl:message>
         </xsl:otherwise>
      </xsl:choose>
      <xsl:apply-templates select="*" mode="M133"/>
   </xsl:template>
   <xsl:template match="text()" priority="-1" mode="M133"/>
   <xsl:template match="@*|node()" priority="-2" mode="M133">
      <xsl:apply-templates select="*" mode="M133"/>
   </xsl:template>
   <!--PATTERN schematron-constraint-tei_all-dataSpec-no_elements_in_data_content-133-->
   <!--RULE -->
   <xsl:template match="tei:dataSpec/tei:content" priority="1000" mode="M134">

		<!--REPORT -->
      <xsl:if test=".//tei:anyElement | .//tei:classRef | .//tei:elementRef">
         <xsl:message>
          A datatype specification should not refer to an element or a class.
         (.//tei:anyElement | .//tei:classRef | .//tei:elementRef)</xsl:message>
      </xsl:if>
      <xsl:apply-templates select="*" mode="M134"/>
   </xsl:template>
   <xsl:template match="text()" priority="-1" mode="M134"/>
   <xsl:template match="@*|node()" priority="-2" mode="M134">
      <xsl:apply-templates select="*" mode="M134"/>
   </xsl:template>
   <!--PATTERN schematron-constraint-tei_all-listRef-TagDocsNestinglistRef-134-->
   <!--RULE -->
   <xsl:template match="( tei:classSpec | tei:dataSpec | tei:elementSpec | tei:macroSpec | tei:moduleSpec | tei:schemaSpec | tei:specGrp )/tei:listRef"
                 priority="1000"
                 mode="M135">

		<!--REPORT -->
      <xsl:if test="tei:listRef">
         <xsl:message>In the context of tagset documentation, the listRef element must not self-nest. (tei:listRef)</xsl:message>
      </xsl:if>
      <xsl:apply-templates select="*" mode="M135"/>
   </xsl:template>
   <xsl:template match="text()" priority="-1" mode="M135"/>
   <xsl:template match="@*|node()" priority="-2" mode="M135">
      <xsl:apply-templates select="*" mode="M135"/>
   </xsl:template>
   <!--PATTERN schematron-constraint-tei_all-listRef-TagDocslistRefChildren-135-->
   <!--RULE -->
   <xsl:template match="( tei:classSpec | tei:dataSpec | tei:elementSpec | tei:macroSpec | tei:moduleSpec | tei:schemaSpec | tei:specGrp )/tei:listRef/tei:ptr | ( tei:classSpec | tei:dataSpec | tei:elementSpec | tei:macroSpec | tei:moduleSpec | tei:schemaSpec | tei:specGrp )/tei:listRef/tei:ref"
                 priority="1000"
                 mode="M136">

		<!--ASSERT -->
      <xsl:choose>
         <xsl:when test="@target and not( matches( @target,'\s') )"/>
         <xsl:otherwise>
            <xsl:message>In the context of tagset documentation, each ptr or ref element inside a listRef must have a target attribute with only 1 pointer as its value. (@target and not( matches( @target,'\s') ))</xsl:message>
         </xsl:otherwise>
      </xsl:choose>
      <xsl:apply-templates select="*" mode="M136"/>
   </xsl:template>
   <xsl:template match="text()" priority="-1" mode="M136"/>
   <xsl:template match="@*|node()" priority="-2" mode="M136">
      <xsl:apply-templates select="*" mode="M136"/>
   </xsl:template>
   <!--PATTERN schematron-constraint-tei_all-model-no_dup_default_models-136-->
   <!--RULE -->
   <xsl:template match="tei:model[ not( parent::tei:modelSequence ) ][ not( @predicate ) ]"
                 priority="1000"
                 mode="M137">
      <xsl:variable name="output" select="normalize-space( @output )"/>
      <!--REPORT -->
      <xsl:if test="following-sibling::tei:model [ not( @predicate )] [ normalize-space( @output ) eq $output ]">
         <xsl:message>
          There are 2 (or more) 'model' elements in this '<xsl:text/>
            <xsl:value-of select="local-name(..)"/>
            <xsl:text/>'
          that have no predicate, but are targeted to the same output
          ("<xsl:text/>
            <xsl:value-of select="( $output, parent::modelGrp/@output, 'all')[1]"/>
            <xsl:text/>") (following-sibling::tei:model [ not( @predicate )] [ normalize-space( @output ) eq $output ])</xsl:message>
      </xsl:if>
      <xsl:apply-templates select="*" mode="M137"/>
   </xsl:template>
   <xsl:template match="text()" priority="-1" mode="M137"/>
   <xsl:template match="@*|node()" priority="-2" mode="M137">
      <xsl:apply-templates select="*" mode="M137"/>
   </xsl:template>
   <!--PATTERN schematron-constraint-tei_all-model-no_dup_models-137-->
   <!--RULE -->
   <xsl:template match="tei:model[ not( parent::tei:modelSequence ) ][ @predicate ]"
                 priority="1000"
                 mode="M138">
      <xsl:variable name="predicate" select="normalize-space( @predicate )"/>
      <xsl:variable name="output" select="normalize-space( @output )"/>
      <!--REPORT -->
      <xsl:if test="following-sibling::tei:model [ normalize-space( @predicate ) eq $predicate ] [ normalize-space( @output ) eq $output ]">
         <xsl:message>
          There are 2 (or more) 'model' elements in this
          '<xsl:text/>
            <xsl:value-of select="local-name(..)"/>
            <xsl:text/>' that have
          the same predicate, and are targeted to the same output
          ("<xsl:text/>
            <xsl:value-of select="( $output, parent::modelGrp/@output, 'all')[1]"/>
            <xsl:text/>") (following-sibling::tei:model [ normalize-space( @predicate ) eq $predicate ] [ normalize-space( @output ) eq $output ])</xsl:message>
      </xsl:if>
      <xsl:apply-templates select="*" mode="M138"/>
   </xsl:template>
   <xsl:template match="text()" priority="-1" mode="M138"/>
   <xsl:template match="@*|node()" priority="-2" mode="M138">
      <xsl:apply-templates select="*" mode="M138"/>
   </xsl:template>
   <!--PATTERN schematron-constraint-tei_all-modelSequence-no_outputs_nor_predicates_4_my_kids-138-->
   <!--RULE -->
   <xsl:template match="tei:modelSequence" priority="1000" mode="M139">

		<!--REPORT warning-->
      <xsl:if test="tei:model[@output]">
         <xsl:message>The 'model' children
      of a 'modelSequence' element inherit the @output attribute of the
      parent 'modelSequence', and thus should not have their own (tei:model[@output] / warning)</xsl:message>
      </xsl:if>
      <xsl:apply-templates select="*" mode="M139"/>
   </xsl:template>
   <xsl:template match="text()" priority="-1" mode="M139"/>
   <xsl:template match="@*|node()" priority="-2" mode="M139">
      <xsl:apply-templates select="*" mode="M139"/>
   </xsl:template>
   <!--PATTERN schematron-constraint-tei_all-content-only_1_child_of_content-139-->
   <!--RULE -->
   <xsl:template match="tei:content[ *[2] ]" priority="1000" mode="M140">
      <xsl:variable name="tot_kids" select="count( * )"/>
      <xsl:variable name="tei_kids" select="count( tei:* )"/>
      <xsl:variable name="rng_kids" select="count( rng:* | rna:* )"/>
      <xsl:variable name="msg_part01"
                    select="'In the near future the &lt;content&gt; element will be limited to 1 and only 1 child element. '"/>
      <xsl:variable name="msg_part02" select="'This &lt;content&gt; element is in '"/>
      <xsl:variable name="msg_part03"
                    select="if ( local-name(..) eq 'elementSpec' ) then 'an ' else 'a '"/>
      <xsl:variable name="msg_part04" select="concat( local-name(..), ' with ' )"/>
      <xsl:variable name="msg_part05"
                    select="if ( parent::tei:moduleRef/@key ) then 'a @key'    else ''"/>
      <xsl:variable name="msg_part06"
                    select="if ( parent::tei:moduleRef/@url ) then 'a @url'    else ''"/>
      <xsl:variable name="msg_part07"
                    select="if ( parent::tei:*/@ident )       then 'an @ident' else ''"/>
      <xsl:variable name="msg_part08" select="' of &#34;'"/>
      <xsl:variable name="msg_part09" select="../@ident | ../@key | ../@url"/>
      <xsl:variable name="msg_part10"
                    select="concat('&#34; and has ', $tot_kids, ' children,')"/>
      <xsl:variable name="msgs_1to10"
                    select="concat( $msg_part01, $msg_part02, $msg_part03, $msg_part04, $msg_part05, $msg_part06, $msg_part07, $msg_part08, $msg_part09, $msg_part10 )"/>
      <!--REPORT warning-->
      <xsl:if test="$tei_kids eq $tot_kids">
         <xsl:message>
            <xsl:text/>
            <xsl:value-of select="$msgs_1to10"/>
            <xsl:text/> which could be wrapped in a &lt;sequence&gt; element.
       ($tei_kids eq $tot_kids / warning)</xsl:message>
      </xsl:if>
      <!--REPORT warning-->
      <xsl:if test="$rng_kids eq $tot_kids">
         <xsl:message>
            <xsl:text/>
            <xsl:value-of select="$msgs_1to10"/>
            <xsl:text/> which could be wrapped in an &lt;rng:div&gt; element.
       ($rng_kids eq $tot_kids / warning)</xsl:message>
      </xsl:if>
      <!--ASSERT warning-->
      <xsl:choose>
         <xsl:when test="$tei_kids eq $tot_kids  or  $rng_kids eq $tot_kids"/>
         <xsl:otherwise>
            <xsl:message>
               <xsl:text/>
               <xsl:value-of select="$msgs_1to10"/>
               <xsl:text/> but those children are neither all TEI elements nor
        all RELAX NG elements, and thus this &lt;content&gt; is invalid and can not be easily rectified.
       ($tei_kids eq $tot_kids or $rng_kids eq $tot_kids / warning)</xsl:message>
         </xsl:otherwise>
      </xsl:choose>
      <xsl:apply-templates select="*" mode="M140"/>
   </xsl:template>
   <xsl:template match="text()" priority="-1" mode="M140"/>
   <xsl:template match="@*|node()" priority="-2" mode="M140">
      <xsl:apply-templates select="*" mode="M140"/>
   </xsl:template>
   <!--PATTERN schematron-constraint-tei_all-sequence-sequencechilden-140-->
   <!--RULE -->
   <xsl:template match="tei:sequence" priority="1000" mode="M141">

		<!--ASSERT -->
      <xsl:choose>
         <xsl:when test="count(*)&gt;1"/>
         <xsl:otherwise>
            <xsl:message>The sequence element must have at least two child elements (count(*)&gt;1)</xsl:message>
         </xsl:otherwise>
      </xsl:choose>
      <xsl:apply-templates select="*" mode="M141"/>
   </xsl:template>
   <xsl:template match="text()" priority="-1" mode="M141"/>
   <xsl:template match="@*|node()" priority="-2" mode="M141">
      <xsl:apply-templates select="*" mode="M141"/>
   </xsl:template>
   <!--PATTERN schematron-constraint-tei_all-alternate-alternatechilden-141-->
   <!--RULE -->
   <xsl:template match="tei:alternate" priority="1000" mode="M142">

		<!--ASSERT -->
      <xsl:choose>
         <xsl:when test="count(*)&gt;1"/>
         <xsl:otherwise>
            <xsl:message>The alternate element must have at least two child elements (count(*)&gt;1)</xsl:message>
         </xsl:otherwise>
      </xsl:choose>
      <xsl:apply-templates select="*" mode="M142"/>
   </xsl:template>
   <xsl:template match="text()" priority="-1" mode="M142"/>
   <xsl:template match="@*|node()" priority="-2" mode="M142">
      <xsl:apply-templates select="*" mode="M142"/>
   </xsl:template>
   <!--PATTERN schematron-constraint-tei_all-constraintSpec-empty-based-on-mode-142-->
   <!--RULE -->
   <xsl:template match="tei:constraintSpec[ @mode eq 'delete']"
                 priority="1002"
                 mode="M143">

		<!--REPORT -->
      <xsl:if test="child::*">
         <xsl:message>This constraintSpec element has a mode= of "delete" even though it has child elements. Change the mode= to "add", "change", or "replace", or remove the child elements. (child::*)</xsl:message>
      </xsl:if>
      <xsl:apply-templates select="*" mode="M143"/>
   </xsl:template>
   <!--RULE -->
   <xsl:template match="tei:constraintSpec[ @mode eq 'change']"
                 priority="1001"
                 mode="M143">

		<!--ASSERT -->
      <xsl:choose>
         <xsl:when test="child::*"/>
         <xsl:otherwise>
            <xsl:message>This constraintSpec element has a mode= of "change", but does not have any child elements. Specify child elements, or change the mode= to "delete". (child::*)</xsl:message>
         </xsl:otherwise>
      </xsl:choose>
      <xsl:apply-templates select="*" mode="M143"/>
   </xsl:template>
   <!--RULE -->
   <xsl:template match="tei:constraintSpec[ @mode = ('add','replace') ]"
                 priority="1000"
                 mode="M143">

		<!--ASSERT -->
      <xsl:choose>
         <xsl:when test="child::tei:constraint"/>
         <xsl:otherwise>
            <xsl:message>This constraintSpec element has a mode= of "<xsl:text/>
               <xsl:value-of select="@mode"/>
               <xsl:text/>", but does not have a child 'constraint' element. Use a child 'constraint' element or change the mode= to "delete" or "change". (child::tei:constraint)</xsl:message>
         </xsl:otherwise>
      </xsl:choose>
      <xsl:apply-templates select="*" mode="M143"/>
   </xsl:template>
   <xsl:template match="text()" priority="-1" mode="M143"/>
   <xsl:template match="@*|node()" priority="-2" mode="M143">
      <xsl:apply-templates select="*" mode="M143"/>
   </xsl:template>
   <!--PATTERN schematron-constraint-tei_all-constraintSpec-sch_no_more-143-->
   <!--RULE -->
   <xsl:template match="tei:constraintSpec" priority="1000" mode="M144">

		<!--REPORT -->
      <xsl:if test="tei:constraint/sch1x:* and @scheme = ('isoschematron','schematron')">
         <xsl:message>Rules
        in the Schematron 1.* language must be inside a constraintSpec
        with a value other than 'schematron' or 'isoschematron' on the
        scheme attribute (tei:constraint/sch1x:* and @scheme = ('isoschematron','schematron'))</xsl:message>
      </xsl:if>
      <xsl:apply-templates select="*" mode="M144"/>
   </xsl:template>
   <xsl:template match="text()" priority="-1" mode="M144"/>
   <xsl:template match="@*|node()" priority="-2" mode="M144">
      <xsl:apply-templates select="*" mode="M144"/>
   </xsl:template>
   <!--PATTERN schematron-constraint-tei_all-constraintSpec-isosch-144-->
   <!--RULE -->
   <xsl:template match="tei:constraintSpec[ @mode = ('add','replace') or not( @mode ) ]"
                 priority="1000"
                 mode="M145">

		<!--REPORT -->
      <xsl:if test="tei:constraint/sch:* and not( @scheme eq 'schematron')">
         <xsl:message>Rules
          in the ISO Schematron language must be inside a constraintSpec
          with the value 'schematron' on the scheme attribute (tei:constraint/sch:* and not( @scheme eq 'schematron'))</xsl:message>
      </xsl:if>
      <xsl:apply-templates select="*" mode="M145"/>
   </xsl:template>
   <xsl:template match="text()" priority="-1" mode="M145"/>
   <xsl:template match="@*|node()" priority="-2" mode="M145">
      <xsl:apply-templates select="*" mode="M145"/>
   </xsl:template>
   <!--PATTERN schematron-constraint-tei_all-constraintSpec-needrules-145-->
   <!--RULE -->
   <xsl:template match="tei:macroSpec/tei:constraintSpec[@scheme eq 'schematron']/tei:constraint"
                 priority="1000"
                 mode="M146">

		<!--REPORT -->
      <xsl:if test="sch:assert|sch:report">
         <xsl:message>An ISO Schematron constraint specification for a macro should not
        have an 'assert' or 'report' element without a parent 'rule' element (sch:assert|sch:report)</xsl:message>
      </xsl:if>
      <xsl:apply-templates select="*" mode="M146"/>
   </xsl:template>
   <xsl:template match="text()" priority="-1" mode="M146"/>
   <xsl:template match="@*|node()" priority="-2" mode="M146">
      <xsl:apply-templates select="*" mode="M146"/>
   </xsl:template>
   <!--PATTERN schematron-constraint-tei_all-constraintSpec-unique-constraintSpec-ident-146-->
   <!--RULE -->
   <xsl:template match="tei:constraintSpec[ @mode eq 'add' or not( @mode ) ]"
                 priority="1000"
                 mode="M147">
      <xsl:variable name="myIdent" select="normalize-space(@ident)"/>
      <!--REPORT -->
      <xsl:if test="preceding::tei:constraintSpec[ normalize-space(@ident) eq $myIdent ]">
         <xsl:message>
        The @ident of 'constraintSpec' should be unique; this one (<xsl:text/>
            <xsl:value-of select="$myIdent"/>
            <xsl:text/>) is the same as that of a previous 'constraintSpec'.
         (preceding::tei:constraintSpec[ normalize-space(@ident) eq $myIdent ])</xsl:message>
      </xsl:if>
      <xsl:apply-templates select="*" mode="M147"/>
   </xsl:template>
   <xsl:template match="text()" priority="-1" mode="M147"/>
   <xsl:template match="@*|node()" priority="-2" mode="M147">
      <xsl:apply-templates select="*" mode="M147"/>
   </xsl:template>
   <!--PATTERN schematron-constraint-tei_all-constraintSpec-scheme-usage_based_on_mode-147-->
   <!--RULE -->
   <xsl:template match="tei:constraintSpec[ @mode = ('add','replace')  or  not( @mode ) ]"
                 priority="1000"
                 mode="M148">

		<!--ASSERT -->
      <xsl:choose>
         <xsl:when test="@scheme"/>
         <xsl:otherwise>
            <xsl:message>The @scheme attribute of &lt;constraintSpec&gt; is required when the @mode is <xsl:text/>
               <xsl:value-of select="if (@mode) then concat('&#34;',@mode,'&#34;') else 'not specified'"/>
               <xsl:text/>. (@scheme)</xsl:message>
         </xsl:otherwise>
      </xsl:choose>
      <xsl:apply-templates select="*" mode="M148"/>
   </xsl:template>
   <xsl:template match="text()" priority="-1" mode="M148"/>
   <xsl:template match="@*|node()" priority="-2" mode="M148">
      <xsl:apply-templates select="*" mode="M148"/>
   </xsl:template>
   <!--PATTERN schematron-constraint-tei_all-attDef-attDefContents-148-->
   <!--RULE -->
   <xsl:template match="tei:attDef" priority="1000" mode="M149">

		<!--ASSERT -->
      <xsl:choose>
         <xsl:when test="ancestor::teix:egXML[@valid='feasible'] or @mode eq 'change' or @mode eq 'delete' or tei:datatype or tei:valList[@type='closed']"/>
         <xsl:otherwise>
            <xsl:message>Attribute: the definition of the @<xsl:text/>
               <xsl:value-of select="@ident"/>
               <xsl:text/> attribute in the <xsl:text/>
               <xsl:value-of select="ancestor::*[@ident][1]/@ident"/>
               <xsl:text/>
               <xsl:text/>
               <xsl:value-of select="' '"/>
               <xsl:text/>
               <xsl:text/>
               <xsl:value-of select="local-name(ancestor::*[@ident][1])"/>
               <xsl:text/> should have a closed valList or a datatype (ancestor::teix:egXML[@valid='feasible'] or @mode eq 'change' or @mode eq 'delete' or tei:datatype or tei:valList[@type='closed'])</xsl:message>
         </xsl:otherwise>
      </xsl:choose>
      <xsl:apply-templates select="*" mode="M149"/>
   </xsl:template>
   <xsl:template match="text()" priority="-1" mode="M149"/>
   <xsl:template match="@*|node()" priority="-2" mode="M149">
      <xsl:apply-templates select="*" mode="M149"/>
   </xsl:template>
   <!--PATTERN schematron-constraint-tei_all-attDef-noDefault4Required-149-->
   <!--RULE -->
   <xsl:template match="tei:attDef[@usage eq 'req']" priority="1000" mode="M150">

		<!--REPORT -->
      <xsl:if test="tei:defaultVal">
         <xsl:message>Since the @<xsl:text/>
            <xsl:value-of select="@ident"/>
            <xsl:text/> attribute is required, it will always be specified. Thus the default value (of "<xsl:text/>
            <xsl:value-of select="normalize-space(tei:defaultVal)"/>
            <xsl:text/>") will never be used. Either change the definition of the attribute so it is not required ("rec" or "opt"), or remove the defaultVal element. (tei:defaultVal)</xsl:message>
      </xsl:if>
      <xsl:apply-templates select="*" mode="M150"/>
   </xsl:template>
   <xsl:template match="text()" priority="-1" mode="M150"/>
   <xsl:template match="@*|node()" priority="-2" mode="M150">
      <xsl:apply-templates select="*" mode="M150"/>
   </xsl:template>
   <!--PATTERN schematron-constraint-tei_all-attDef-defaultIsInClosedList-twoOrMore-150-->
   <!--RULE -->
   <xsl:template match="tei:attDef[ tei:defaultVal and tei:valList[@type eq 'closed'] and tei:datatype[ @maxOccurs &gt; 1 or @minOccurs &gt; 1 or @maxOccurs = 'unbounded' ] ]"
                 priority="1000"
                 mode="M151">

		<!--ASSERT -->
      <xsl:choose>
         <xsl:when test="tokenize(normalize-space(tei:defaultVal),' ') = tei:valList/tei:valItem/@ident"/>
         <xsl:otherwise>
            <xsl:message>In the <xsl:text/>
               <xsl:value-of select="local-name(ancestor::*[@ident][1])"/>
               <xsl:text/> defining
        <xsl:text/>
               <xsl:value-of select="ancestor::*[@ident][1]/@ident"/>
               <xsl:text/> the default value of the
        @<xsl:text/>
               <xsl:value-of select="@ident"/>
               <xsl:text/> attribute is not among the closed list of possible
        values (tokenize(normalize-space(tei:defaultVal),' ') = tei:valList/tei:valItem/@ident)</xsl:message>
         </xsl:otherwise>
      </xsl:choose>
      <xsl:apply-templates select="*" mode="M151"/>
   </xsl:template>
   <xsl:template match="text()" priority="-1" mode="M151"/>
   <xsl:template match="@*|node()" priority="-2" mode="M151">
      <xsl:apply-templates select="*" mode="M151"/>
   </xsl:template>
   <!--PATTERN schematron-constraint-tei_all-attDef-defaultIsInClosedList-one-151-->
   <!--RULE -->
   <xsl:template match="tei:attDef[ tei:defaultVal and tei:valList[@type eq 'closed'] and tei:datatype[ not(@maxOccurs) or ( if ( @maxOccurs castable as xs:integer ) then ( @maxOccurs cast as xs:integer eq 1 ) else false() )] ]"
                 priority="1000"
                 mode="M152">

		<!--ASSERT -->
      <xsl:choose>
         <xsl:when test="string(tei:defaultVal) = tei:valList/tei:valItem/@ident"/>
         <xsl:otherwise>
            <xsl:message>In the <xsl:text/>
               <xsl:value-of select="local-name(ancestor::*[@ident][1])"/>
               <xsl:text/> defining
        <xsl:text/>
               <xsl:value-of select="ancestor::*[@ident][1]/@ident"/>
               <xsl:text/> the default value of the
        @<xsl:text/>
               <xsl:value-of select="@ident"/>
               <xsl:text/> attribute is not among the closed list of possible
        values (string(tei:defaultVal) = tei:valList/tei:valItem/@ident)</xsl:message>
         </xsl:otherwise>
      </xsl:choose>
      <xsl:apply-templates select="*" mode="M152"/>
   </xsl:template>
   <xsl:template match="text()" priority="-1" mode="M152"/>
   <xsl:template match="@*|node()" priority="-2" mode="M152">
      <xsl:apply-templates select="*" mode="M152"/>
   </xsl:template>
   <!--PATTERN schematron-constraint-tei_all-dataRef-restrictDataFacet-152-->
   <!--RULE -->
   <xsl:template match="tei:dataRef[tei:dataFacet]" priority="1000" mode="M153">

		<!--ASSERT nonfatal-->
      <xsl:choose>
         <xsl:when test="@name"/>
         <xsl:otherwise>
            <xsl:message>Data facets can only be specified for references to datatypes specified by
          XML Schema Part 2: Datatypes Second Edition — that is, for there to be a 'dataFacet' child there must be a @name attribute. (@name / nonfatal)</xsl:message>
         </xsl:otherwise>
      </xsl:choose>
      <!--REPORT nonfatal-->
      <xsl:if test="@restriction">
         <xsl:message>Data facets and restrictions cannot both be expressed on the same data reference — that is, the @restriction attribute cannot be used when a 'dataFacet' element is present. (@restriction / nonfatal)</xsl:message>
      </xsl:if>
      <xsl:apply-templates select="*" mode="M153"/>
   </xsl:template>
   <xsl:template match="text()" priority="-1" mode="M153"/>
   <xsl:template match="@*|node()" priority="-2" mode="M153">
      <xsl:apply-templates select="*" mode="M153"/>
   </xsl:template>
   <!--PATTERN schematron-constraint-tei_all-dataRef-restrictAttResctrictionName-153-->
   <!--RULE -->
   <xsl:template match="tei:dataRef[@restriction]" priority="1000" mode="M154">

		<!--ASSERT nonfatal-->
      <xsl:choose>
         <xsl:when test="@name"/>
         <xsl:otherwise>
            <xsl:message>Restrictions can only be specified for references to datatypes specified by
          XML Schema Part 2: Datatypes Second Edition — that is, for there to be a @restriction attribute there must be a @name attribute, too. (@name / nonfatal)</xsl:message>
         </xsl:otherwise>
      </xsl:choose>
      <xsl:apply-templates select="*" mode="M154"/>
   </xsl:template>
   <xsl:template match="text()" priority="-1" mode="M154"/>
   <xsl:template match="@*|node()" priority="-2" mode="M154">
      <xsl:apply-templates select="*" mode="M154"/>
   </xsl:template>
   <!--PATTERN -->
   <!--RULE -->
   <xsl:template match="tei:name" priority="1000" mode="M155">

		<!--REPORT nonfatal-->
      <xsl:if test="@calendar">
         <xsl:message>WARNING: use of deprecated attribute — @calendar of the name element will be removed from the TEI on 2024-11-11.
                 (@calendar / nonfatal)</xsl:message>
      </xsl:if>
      <xsl:apply-templates select="*" mode="M155"/>
   </xsl:template>
   <xsl:template match="text()" priority="-1" mode="M155"/>
   <xsl:template match="@*|node()" priority="-2" mode="M155">
      <xsl:apply-templates select="*" mode="M155"/>
   </xsl:template>
   <!--PATTERN -->
   <!--RULE -->
   <xsl:template match="tei:author" priority="1000" mode="M156">

		<!--REPORT nonfatal-->
      <xsl:if test="@calendar">
         <xsl:message>WARNING: use of deprecated attribute — @calendar of the author element will be removed from the TEI on 2024-11-11.
                 (@calendar / nonfatal)</xsl:message>
      </xsl:if>
      <xsl:apply-templates select="*" mode="M156"/>
   </xsl:template>
   <xsl:template match="text()" priority="-1" mode="M156"/>
   <xsl:template match="@*|node()" priority="-2" mode="M156">
      <xsl:apply-templates select="*" mode="M156"/>
   </xsl:template>
   <!--PATTERN -->
   <!--RULE -->
   <xsl:template match="tei:editor" priority="1000" mode="M157">

		<!--REPORT nonfatal-->
      <xsl:if test="@calendar">
         <xsl:message>WARNING: use of deprecated attribute — @calendar of the editor element will be removed from the TEI on 2024-11-11.
                 (@calendar / nonfatal)</xsl:message>
      </xsl:if>
      <xsl:apply-templates select="*" mode="M157"/>
   </xsl:template>
   <xsl:template match="text()" priority="-1" mode="M157"/>
   <xsl:template match="@*|node()" priority="-2" mode="M157">
      <xsl:apply-templates select="*" mode="M157"/>
   </xsl:template>
   <!--PATTERN -->
   <!--RULE -->
   <xsl:template match="tei:resp" priority="1000" mode="M158">

		<!--REPORT nonfatal-->
      <xsl:if test="@calendar">
         <xsl:message>WARNING: use of deprecated attribute — @calendar of the resp element will be removed from the TEI on 2024-11-11.
                 (@calendar / nonfatal)</xsl:message>
      </xsl:if>
      <xsl:apply-templates select="*" mode="M158"/>
   </xsl:template>
   <xsl:template match="text()" priority="-1" mode="M158"/>
   <xsl:template match="@*|node()" priority="-2" mode="M158">
      <xsl:apply-templates select="*" mode="M158"/>
   </xsl:template>
   <!--PATTERN -->
   <!--RULE -->
   <xsl:template match="tei:title" priority="1000" mode="M159">

		<!--REPORT nonfatal-->
      <xsl:if test="@calendar">
         <xsl:message>WARNING: use of deprecated attribute — @calendar of the title element will be removed from the TEI on 2024-11-11.
                 (@calendar / nonfatal)</xsl:message>
      </xsl:if>
      <xsl:apply-templates select="*" mode="M159"/>
   </xsl:template>
   <xsl:template match="text()" priority="-1" mode="M159"/>
   <xsl:template match="@*|node()" priority="-2" mode="M159">
      <xsl:apply-templates select="*" mode="M159"/>
   </xsl:template>
   <!--PATTERN -->
   <!--RULE -->
   <xsl:template match="tei:meeting" priority="1000" mode="M160">

		<!--REPORT nonfatal-->
      <xsl:if test="@calendar">
         <xsl:message>WARNING: use of deprecated attribute — @calendar of the meeting element will be removed from the TEI on 2024-11-11.
                 (@calendar / nonfatal)</xsl:message>
      </xsl:if>
      <xsl:apply-templates select="*" mode="M160"/>
   </xsl:template>
   <xsl:template match="text()" priority="-1" mode="M160"/>
   <xsl:template match="@*|node()" priority="-2" mode="M160">
      <xsl:apply-templates select="*" mode="M160"/>
   </xsl:template>
   <!--PATTERN -->
   <!--RULE -->
   <xsl:template match="tei:sponsor" priority="1000" mode="M161">

		<!--REPORT nonfatal-->
      <xsl:if test="@calendar">
         <xsl:message>WARNING: use of deprecated attribute — @calendar of the sponsor element will be removed from the TEI on 2024-11-11.
                 (@calendar / nonfatal)</xsl:message>
      </xsl:if>
      <xsl:apply-templates select="*" mode="M161"/>
   </xsl:template>
   <xsl:template match="text()" priority="-1" mode="M161"/>
   <xsl:template match="@*|node()" priority="-2" mode="M161">
      <xsl:apply-templates select="*" mode="M161"/>
   </xsl:template>
   <!--PATTERN -->
   <!--RULE -->
   <xsl:template match="tei:funder" priority="1000" mode="M162">

		<!--REPORT nonfatal-->
      <xsl:if test="@calendar">
         <xsl:message>WARNING: use of deprecated attribute — @calendar of the funder element will be removed from the TEI on 2024-11-11.
                 (@calendar / nonfatal)</xsl:message>
      </xsl:if>
      <xsl:apply-templates select="*" mode="M162"/>
   </xsl:template>
   <xsl:template match="text()" priority="-1" mode="M162"/>
   <xsl:template match="@*|node()" priority="-2" mode="M162">
      <xsl:apply-templates select="*" mode="M162"/>
   </xsl:template>
   <!--PATTERN -->
   <!--RULE -->
   <xsl:template match="tei:principal" priority="1000" mode="M163">

		<!--REPORT nonfatal-->
      <xsl:if test="@calendar">
         <xsl:message>WARNING: use of deprecated attribute — @calendar of the principal element will be removed from the TEI on 2024-11-11.
                 (@calendar / nonfatal)</xsl:message>
      </xsl:if>
      <xsl:apply-templates select="*" mode="M163"/>
   </xsl:template>
   <xsl:template match="text()" priority="-1" mode="M163"/>
   <xsl:template match="@*|node()" priority="-2" mode="M163">
      <xsl:apply-templates select="*" mode="M163"/>
   </xsl:template>
   <!--PATTERN -->
   <!--RULE -->
   <xsl:template match="tei:idno" priority="1000" mode="M164">

		<!--REPORT nonfatal-->
      <xsl:if test="@calendar">
         <xsl:message>WARNING: use of deprecated attribute — @calendar of the idno element will be removed from the TEI on 2024-11-11.
                 (@calendar / nonfatal)</xsl:message>
      </xsl:if>
      <xsl:apply-templates select="*" mode="M164"/>
   </xsl:template>
   <xsl:template match="text()" priority="-1" mode="M164"/>
   <xsl:template match="@*|node()" priority="-2" mode="M164">
      <xsl:apply-templates select="*" mode="M164"/>
   </xsl:template>
   <!--PATTERN -->
   <!--RULE -->
   <xsl:template match="tei:licence" priority="1000" mode="M165">

		<!--REPORT nonfatal-->
      <xsl:if test="@calendar">
         <xsl:message>WARNING: use of deprecated attribute — @calendar of the licence element will be removed from the TEI on 2024-11-11.
                 (@calendar / nonfatal)</xsl:message>
      </xsl:if>
      <xsl:apply-templates select="*" mode="M165"/>
   </xsl:template>
   <xsl:template match="text()" priority="-1" mode="M165"/>
   <xsl:template match="@*|node()" priority="-2" mode="M165">
      <xsl:apply-templates select="*" mode="M165"/>
   </xsl:template>
   <!--PATTERN -->
   <!--RULE -->
   <xsl:template match="tei:unitDecl" priority="1000" mode="M166">

		<!--REPORT nonfatal-->
      <xsl:if test="@calendar">
         <xsl:message>WARNING: use of deprecated attribute — @calendar of the unitDecl element will be removed from the TEI on 2024-11-11.
                 (@calendar / nonfatal)</xsl:message>
      </xsl:if>
      <xsl:apply-templates select="*" mode="M166"/>
   </xsl:template>
   <xsl:template match="text()" priority="-1" mode="M166"/>
   <xsl:template match="@*|node()" priority="-2" mode="M166">
      <xsl:apply-templates select="*" mode="M166"/>
   </xsl:template>
   <!--PATTERN -->
   <!--RULE -->
   <xsl:template match="tei:unitDef" priority="1000" mode="M167">

		<!--REPORT nonfatal-->
      <xsl:if test="@calendar">
         <xsl:message>WARNING: use of deprecated attribute — @calendar of the unitDef element will be removed from the TEI on 2024-11-11.
                 (@calendar / nonfatal)</xsl:message>
      </xsl:if>
      <xsl:apply-templates select="*" mode="M167"/>
   </xsl:template>
   <xsl:template match="text()" priority="-1" mode="M167"/>
   <xsl:template match="@*|node()" priority="-2" mode="M167">
      <xsl:apply-templates select="*" mode="M167"/>
   </xsl:template>
   <!--PATTERN -->
   <!--RULE -->
   <xsl:template match="tei:conversion" priority="1000" mode="M168">

		<!--REPORT nonfatal-->
      <xsl:if test="@calendar">
         <xsl:message>WARNING: use of deprecated attribute — @calendar of the conversion element will be removed from the TEI on 2024-11-11.
                 (@calendar / nonfatal)</xsl:message>
      </xsl:if>
      <xsl:apply-templates select="*" mode="M168"/>
   </xsl:template>
   <xsl:template match="text()" priority="-1" mode="M168"/>
   <xsl:template match="@*|node()" priority="-2" mode="M168">
      <xsl:apply-templates select="*" mode="M168"/>
   </xsl:template>
   <!--PATTERN -->
   <!--RULE -->
   <xsl:template match="tei:application" priority="1000" mode="M169">

		<!--REPORT nonfatal-->
      <xsl:if test="@calendar">
         <xsl:message>WARNING: use of deprecated attribute — @calendar of the application element will be removed from the TEI on 2024-11-11.
                 (@calendar / nonfatal)</xsl:message>
      </xsl:if>
      <xsl:apply-templates select="*" mode="M169"/>
   </xsl:template>
   <xsl:template match="text()" priority="-1" mode="M169"/>
   <xsl:template match="@*|node()" priority="-2" mode="M169">
      <xsl:apply-templates select="*" mode="M169"/>
   </xsl:template>
   <!--PATTERN -->
   <!--RULE -->
   <xsl:template match="tei:creation" priority="1000" mode="M170">

		<!--REPORT nonfatal-->
      <xsl:if test="@calendar">
         <xsl:message>WARNING: use of deprecated attribute — @calendar of the creation element will be removed from the TEI on 2024-11-11.
                 (@calendar / nonfatal)</xsl:message>
      </xsl:if>
      <xsl:apply-templates select="*" mode="M170"/>
   </xsl:template>
   <xsl:template match="text()" priority="-1" mode="M170"/>
   <xsl:template match="@*|node()" priority="-2" mode="M170">
      <xsl:apply-templates select="*" mode="M170"/>
   </xsl:template>
   <!--PATTERN -->
   <!--RULE -->
   <xsl:template match="tei:change" priority="1000" mode="M171">

		<!--REPORT nonfatal-->
      <xsl:if test="@calendar">
         <xsl:message>WARNING: use of deprecated attribute — @calendar of the change element will be removed from the TEI on 2024-11-11.
                 (@calendar / nonfatal)</xsl:message>
      </xsl:if>
      <xsl:apply-templates select="*" mode="M171"/>
   </xsl:template>
   <xsl:template match="text()" priority="-1" mode="M171"/>
   <xsl:template match="@*|node()" priority="-2" mode="M171">
      <xsl:apply-templates select="*" mode="M171"/>
   </xsl:template>
   <!--PATTERN -->
   <!--RULE -->
   <xsl:template match="tei:origPlace" priority="1000" mode="M172">

		<!--REPORT nonfatal-->
      <xsl:if test="@calendar">
         <xsl:message>WARNING: use of deprecated attribute — @calendar of the origPlace element will be removed from the TEI on 2024-11-11.
                 (@calendar / nonfatal)</xsl:message>
      </xsl:if>
      <xsl:apply-templates select="*" mode="M172"/>
   </xsl:template>
   <xsl:template match="text()" priority="-1" mode="M172"/>
   <xsl:template match="@*|node()" priority="-2" mode="M172">
      <xsl:apply-templates select="*" mode="M172"/>
   </xsl:template>
   <!--PATTERN -->
   <!--RULE -->
   <xsl:template match="tei:stamp" priority="1000" mode="M173">

		<!--REPORT nonfatal-->
      <xsl:if test="@calendar">
         <xsl:message>WARNING: use of deprecated attribute — @calendar of the stamp element will be removed from the TEI on 2024-11-11.
                 (@calendar / nonfatal)</xsl:message>
      </xsl:if>
      <xsl:apply-templates select="*" mode="M173"/>
   </xsl:template>
   <xsl:template match="text()" priority="-1" mode="M173"/>
   <xsl:template match="@*|node()" priority="-2" mode="M173">
      <xsl:apply-templates select="*" mode="M173"/>
   </xsl:template>
   <!--PATTERN -->
   <!--RULE -->
   <xsl:template match="tei:altIdentifier" priority="1000" mode="M174">

		<!--REPORT nonfatal-->
      <xsl:if test="@calendar">
         <xsl:message>WARNING: use of deprecated attribute — @calendar of the altIdentifier element will be removed from the TEI on 2024-11-11.
                 (@calendar / nonfatal)</xsl:message>
      </xsl:if>
      <xsl:apply-templates select="*" mode="M174"/>
   </xsl:template>
   <xsl:template match="text()" priority="-1" mode="M174"/>
   <xsl:template match="@*|node()" priority="-2" mode="M174">
      <xsl:apply-templates select="*" mode="M174"/>
   </xsl:template>
   <!--PATTERN -->
   <!--RULE -->
   <xsl:template match="tei:binding" priority="1000" mode="M175">

		<!--REPORT nonfatal-->
      <xsl:if test="@calendar">
         <xsl:message>WARNING: use of deprecated attribute — @calendar of the binding element will be removed from the TEI on 2024-11-11.
                 (@calendar / nonfatal)</xsl:message>
      </xsl:if>
      <xsl:apply-templates select="*" mode="M175"/>
   </xsl:template>
   <xsl:template match="text()" priority="-1" mode="M175"/>
   <xsl:template match="@*|node()" priority="-2" mode="M175">
      <xsl:apply-templates select="*" mode="M175"/>
   </xsl:template>
   <!--PATTERN -->
   <!--RULE -->
   <xsl:template match="tei:seal" priority="1000" mode="M176">

		<!--REPORT nonfatal-->
      <xsl:if test="@calendar">
         <xsl:message>WARNING: use of deprecated attribute — @calendar of the seal element will be removed from the TEI on 2024-11-11.
                 (@calendar / nonfatal)</xsl:message>
      </xsl:if>
      <xsl:apply-templates select="*" mode="M176"/>
   </xsl:template>
   <xsl:template match="text()" priority="-1" mode="M176"/>
   <xsl:template match="@*|node()" priority="-2" mode="M176">
      <xsl:apply-templates select="*" mode="M176"/>
   </xsl:template>
   <!--PATTERN -->
   <!--RULE -->
   <xsl:template match="tei:origin" priority="1000" mode="M177">

		<!--REPORT nonfatal-->
      <xsl:if test="@calendar">
         <xsl:message>WARNING: use of deprecated attribute — @calendar of the origin element will be removed from the TEI on 2024-11-11.
                 (@calendar / nonfatal)</xsl:message>
      </xsl:if>
      <xsl:apply-templates select="*" mode="M177"/>
   </xsl:template>
   <xsl:template match="text()" priority="-1" mode="M177"/>
   <xsl:template match="@*|node()" priority="-2" mode="M177">
      <xsl:apply-templates select="*" mode="M177"/>
   </xsl:template>
   <!--PATTERN -->
   <!--RULE -->
   <xsl:template match="tei:provenance" priority="1000" mode="M178">

		<!--REPORT nonfatal-->
      <xsl:if test="@calendar">
         <xsl:message>WARNING: use of deprecated attribute — @calendar of the provenance element will be removed from the TEI on 2024-11-11.
                 (@calendar / nonfatal)</xsl:message>
      </xsl:if>
      <xsl:apply-templates select="*" mode="M178"/>
   </xsl:template>
   <xsl:template match="text()" priority="-1" mode="M178"/>
   <xsl:template match="@*|node()" priority="-2" mode="M178">
      <xsl:apply-templates select="*" mode="M178"/>
   </xsl:template>
   <!--PATTERN -->
   <!--RULE -->
   <xsl:template match="tei:acquisition" priority="1000" mode="M179">

		<!--REPORT nonfatal-->
      <xsl:if test="@calendar">
         <xsl:message>WARNING: use of deprecated attribute — @calendar of the acquisition element will be removed from the TEI on 2024-11-11.
                 (@calendar / nonfatal)</xsl:message>
      </xsl:if>
      <xsl:apply-templates select="*" mode="M179"/>
   </xsl:template>
   <xsl:template match="text()" priority="-1" mode="M179"/>
   <xsl:template match="@*|node()" priority="-2" mode="M179">
      <xsl:apply-templates select="*" mode="M179"/>
   </xsl:template>
   <!--PATTERN -->
   <!--RULE -->
   <xsl:template match="tei:custEvent" priority="1000" mode="M180">

		<!--REPORT nonfatal-->
      <xsl:if test="@calendar">
         <xsl:message>WARNING: use of deprecated attribute — @calendar of the custEvent element will be removed from the TEI on 2024-11-11.
                 (@calendar / nonfatal)</xsl:message>
      </xsl:if>
      <xsl:apply-templates select="*" mode="M180"/>
   </xsl:template>
   <xsl:template match="text()" priority="-1" mode="M180"/>
   <xsl:template match="@*|node()" priority="-2" mode="M180">
      <xsl:apply-templates select="*" mode="M180"/>
   </xsl:template>
   <!--PATTERN -->
   <!--RULE -->
   <xsl:template match="tei:orgName" priority="1000" mode="M181">

		<!--REPORT nonfatal-->
      <xsl:if test="@calendar">
         <xsl:message>WARNING: use of deprecated attribute — @calendar of the orgName element will be removed from the TEI on 2024-11-11.
                 (@calendar / nonfatal)</xsl:message>
      </xsl:if>
      <xsl:apply-templates select="*" mode="M181"/>
   </xsl:template>
   <xsl:template match="text()" priority="-1" mode="M181"/>
   <xsl:template match="@*|node()" priority="-2" mode="M181">
      <xsl:apply-templates select="*" mode="M181"/>
   </xsl:template>
   <!--PATTERN -->
   <!--RULE -->
   <xsl:template match="tei:persName" priority="1000" mode="M182">

		<!--REPORT nonfatal-->
      <xsl:if test="@calendar">
         <xsl:message>WARNING: use of deprecated attribute — @calendar of the persName element will be removed from the TEI on 2024-11-11.
                 (@calendar / nonfatal)</xsl:message>
      </xsl:if>
      <xsl:apply-templates select="*" mode="M182"/>
   </xsl:template>
   <xsl:template match="text()" priority="-1" mode="M182"/>
   <xsl:template match="@*|node()" priority="-2" mode="M182">
      <xsl:apply-templates select="*" mode="M182"/>
   </xsl:template>
   <!--PATTERN -->
   <!--RULE -->
   <xsl:template match="tei:placeName" priority="1000" mode="M183">

		<!--REPORT nonfatal-->
      <xsl:if test="@calendar">
         <xsl:message>WARNING: use of deprecated attribute — @calendar of the placeName element will be removed from the TEI on 2024-11-11.
                 (@calendar / nonfatal)</xsl:message>
      </xsl:if>
      <xsl:apply-templates select="*" mode="M183"/>
   </xsl:template>
   <xsl:template match="text()" priority="-1" mode="M183"/>
   <xsl:template match="@*|node()" priority="-2" mode="M183">
      <xsl:apply-templates select="*" mode="M183"/>
   </xsl:template>
   <!--PATTERN -->
   <!--RULE -->
   <xsl:template match="tei:bloc" priority="1000" mode="M184">

		<!--REPORT nonfatal-->
      <xsl:if test="@calendar">
         <xsl:message>WARNING: use of deprecated attribute — @calendar of the bloc element will be removed from the TEI on 2024-11-11.
                 (@calendar / nonfatal)</xsl:message>
      </xsl:if>
      <xsl:apply-templates select="*" mode="M184"/>
   </xsl:template>
   <xsl:template match="text()" priority="-1" mode="M184"/>
   <xsl:template match="@*|node()" priority="-2" mode="M184">
      <xsl:apply-templates select="*" mode="M184"/>
   </xsl:template>
   <!--PATTERN -->
   <!--RULE -->
   <xsl:template match="tei:country" priority="1000" mode="M185">

		<!--REPORT nonfatal-->
      <xsl:if test="@calendar">
         <xsl:message>WARNING: use of deprecated attribute — @calendar of the country element will be removed from the TEI on 2024-11-11.
                 (@calendar / nonfatal)</xsl:message>
      </xsl:if>
      <xsl:apply-templates select="*" mode="M185"/>
   </xsl:template>
   <xsl:template match="text()" priority="-1" mode="M185"/>
   <xsl:template match="@*|node()" priority="-2" mode="M185">
      <xsl:apply-templates select="*" mode="M185"/>
   </xsl:template>
   <!--PATTERN -->
   <!--RULE -->
   <xsl:template match="tei:region" priority="1000" mode="M186">

		<!--REPORT nonfatal-->
      <xsl:if test="@calendar">
         <xsl:message>WARNING: use of deprecated attribute — @calendar of the region element will be removed from the TEI on 2024-11-11.
                 (@calendar / nonfatal)</xsl:message>
      </xsl:if>
      <xsl:apply-templates select="*" mode="M186"/>
   </xsl:template>
   <xsl:template match="text()" priority="-1" mode="M186"/>
   <xsl:template match="@*|node()" priority="-2" mode="M186">
      <xsl:apply-templates select="*" mode="M186"/>
   </xsl:template>
   <!--PATTERN -->
   <!--RULE -->
   <xsl:template match="tei:settlement" priority="1000" mode="M187">

		<!--REPORT nonfatal-->
      <xsl:if test="@calendar">
         <xsl:message>WARNING: use of deprecated attribute — @calendar of the settlement element will be removed from the TEI on 2024-11-11.
                 (@calendar / nonfatal)</xsl:message>
      </xsl:if>
      <xsl:apply-templates select="*" mode="M187"/>
   </xsl:template>
   <xsl:template match="text()" priority="-1" mode="M187"/>
   <xsl:template match="@*|node()" priority="-2" mode="M187">
      <xsl:apply-templates select="*" mode="M187"/>
   </xsl:template>
   <!--PATTERN -->
   <!--RULE -->
   <xsl:template match="tei:district" priority="1000" mode="M188">

		<!--REPORT nonfatal-->
      <xsl:if test="@calendar">
         <xsl:message>WARNING: use of deprecated attribute — @calendar of the district element will be removed from the TEI on 2024-11-11.
                 (@calendar / nonfatal)</xsl:message>
      </xsl:if>
      <xsl:apply-templates select="*" mode="M188"/>
   </xsl:template>
   <xsl:template match="text()" priority="-1" mode="M188"/>
   <xsl:template match="@*|node()" priority="-2" mode="M188">
      <xsl:apply-templates select="*" mode="M188"/>
   </xsl:template>
   <!--PATTERN -->
   <!--RULE -->
   <xsl:template match="tei:offset" priority="1000" mode="M189">

		<!--REPORT nonfatal-->
      <xsl:if test="@calendar">
         <xsl:message>WARNING: use of deprecated attribute — @calendar of the offset element will be removed from the TEI on 2024-11-11.
                 (@calendar / nonfatal)</xsl:message>
      </xsl:if>
      <xsl:apply-templates select="*" mode="M189"/>
   </xsl:template>
   <xsl:template match="text()" priority="-1" mode="M189"/>
   <xsl:template match="@*|node()" priority="-2" mode="M189">
      <xsl:apply-templates select="*" mode="M189"/>
   </xsl:template>
   <!--PATTERN -->
   <!--RULE -->
   <xsl:template match="tei:geogName" priority="1000" mode="M190">

		<!--REPORT nonfatal-->
      <xsl:if test="@calendar">
         <xsl:message>WARNING: use of deprecated attribute — @calendar of the geogName element will be removed from the TEI on 2024-11-11.
                 (@calendar / nonfatal)</xsl:message>
      </xsl:if>
      <xsl:apply-templates select="*" mode="M190"/>
   </xsl:template>
   <xsl:template match="text()" priority="-1" mode="M190"/>
   <xsl:template match="@*|node()" priority="-2" mode="M190">
      <xsl:apply-templates select="*" mode="M190"/>
   </xsl:template>
   <!--PATTERN -->
   <!--RULE -->
   <xsl:template match="tei:geogFeat" priority="1000" mode="M191">

		<!--REPORT nonfatal-->
      <xsl:if test="@calendar">
         <xsl:message>WARNING: use of deprecated attribute — @calendar of the geogFeat element will be removed from the TEI on 2024-11-11.
                 (@calendar / nonfatal)</xsl:message>
      </xsl:if>
      <xsl:apply-templates select="*" mode="M191"/>
   </xsl:template>
   <xsl:template match="text()" priority="-1" mode="M191"/>
   <xsl:template match="@*|node()" priority="-2" mode="M191">
      <xsl:apply-templates select="*" mode="M191"/>
   </xsl:template>
   <!--PATTERN -->
   <!--RULE -->
   <xsl:template match="tei:affiliation" priority="1000" mode="M192">

		<!--REPORT nonfatal-->
      <xsl:if test="@calendar">
         <xsl:message>WARNING: use of deprecated attribute — @calendar of the affiliation element will be removed from the TEI on 2024-11-11.
                 (@calendar / nonfatal)</xsl:message>
      </xsl:if>
      <xsl:apply-templates select="*" mode="M192"/>
   </xsl:template>
   <xsl:template match="text()" priority="-1" mode="M192"/>
   <xsl:template match="@*|node()" priority="-2" mode="M192">
      <xsl:apply-templates select="*" mode="M192"/>
   </xsl:template>
   <!--PATTERN -->
   <!--RULE -->
   <xsl:template match="tei:age" priority="1000" mode="M193">

		<!--REPORT nonfatal-->
      <xsl:if test="@calendar">
         <xsl:message>WARNING: use of deprecated attribute — @calendar of the age element will be removed from the TEI on 2024-11-11.
                 (@calendar / nonfatal)</xsl:message>
      </xsl:if>
      <xsl:apply-templates select="*" mode="M193"/>
   </xsl:template>
   <xsl:template match="text()" priority="-1" mode="M193"/>
   <xsl:template match="@*|node()" priority="-2" mode="M193">
      <xsl:apply-templates select="*" mode="M193"/>
   </xsl:template>
   <!--PATTERN -->
   <!--RULE -->
   <xsl:template match="tei:birth" priority="1000" mode="M194">

		<!--REPORT nonfatal-->
      <xsl:if test="@calendar">
         <xsl:message>WARNING: use of deprecated attribute — @calendar of the birth element will be removed from the TEI on 2024-11-11.
                 (@calendar / nonfatal)</xsl:message>
      </xsl:if>
      <xsl:apply-templates select="*" mode="M194"/>
   </xsl:template>
   <xsl:template match="text()" priority="-1" mode="M194"/>
   <xsl:template match="@*|node()" priority="-2" mode="M194">
      <xsl:apply-templates select="*" mode="M194"/>
   </xsl:template>
   <!--PATTERN -->
   <!--RULE -->
   <xsl:template match="tei:climate" priority="1000" mode="M195">

		<!--REPORT nonfatal-->
      <xsl:if test="@calendar">
         <xsl:message>WARNING: use of deprecated attribute — @calendar of the climate element will be removed from the TEI on 2024-11-11.
                 (@calendar / nonfatal)</xsl:message>
      </xsl:if>
      <xsl:apply-templates select="*" mode="M195"/>
   </xsl:template>
   <xsl:template match="text()" priority="-1" mode="M195"/>
   <xsl:template match="@*|node()" priority="-2" mode="M195">
      <xsl:apply-templates select="*" mode="M195"/>
   </xsl:template>
   <!--PATTERN -->
   <!--RULE -->
   <xsl:template match="tei:death" priority="1000" mode="M196">

		<!--REPORT nonfatal-->
      <xsl:if test="@calendar">
         <xsl:message>WARNING: use of deprecated attribute — @calendar of the death element will be removed from the TEI on 2024-11-11.
                 (@calendar / nonfatal)</xsl:message>
      </xsl:if>
      <xsl:apply-templates select="*" mode="M196"/>
   </xsl:template>
   <xsl:template match="text()" priority="-1" mode="M196"/>
   <xsl:template match="@*|node()" priority="-2" mode="M196">
      <xsl:apply-templates select="*" mode="M196"/>
   </xsl:template>
   <!--PATTERN -->
   <!--RULE -->
   <xsl:template match="tei:education" priority="1000" mode="M197">

		<!--REPORT nonfatal-->
      <xsl:if test="@calendar">
         <xsl:message>WARNING: use of deprecated attribute — @calendar of the education element will be removed from the TEI on 2024-11-11.
                 (@calendar / nonfatal)</xsl:message>
      </xsl:if>
      <xsl:apply-templates select="*" mode="M197"/>
   </xsl:template>
   <xsl:template match="text()" priority="-1" mode="M197"/>
   <xsl:template match="@*|node()" priority="-2" mode="M197">
      <xsl:apply-templates select="*" mode="M197"/>
   </xsl:template>
   <!--PATTERN -->
   <!--RULE -->
   <xsl:template match="tei:event" priority="1000" mode="M198">

		<!--REPORT nonfatal-->
      <xsl:if test="@calendar">
         <xsl:message>WARNING: use of deprecated attribute — @calendar of the event element will be removed from the TEI on 2024-11-11.
                 (@calendar / nonfatal)</xsl:message>
      </xsl:if>
      <xsl:apply-templates select="*" mode="M198"/>
   </xsl:template>
   <xsl:template match="text()" priority="-1" mode="M198"/>
   <xsl:template match="@*|node()" priority="-2" mode="M198">
      <xsl:apply-templates select="*" mode="M198"/>
   </xsl:template>
   <!--PATTERN -->
   <!--RULE -->
   <xsl:template match="tei:faith" priority="1000" mode="M199">

		<!--REPORT nonfatal-->
      <xsl:if test="@calendar">
         <xsl:message>WARNING: use of deprecated attribute — @calendar of the faith element will be removed from the TEI on 2024-11-11.
                 (@calendar / nonfatal)</xsl:message>
      </xsl:if>
      <xsl:apply-templates select="*" mode="M199"/>
   </xsl:template>
   <xsl:template match="text()" priority="-1" mode="M199"/>
   <xsl:template match="@*|node()" priority="-2" mode="M199">
      <xsl:apply-templates select="*" mode="M199"/>
   </xsl:template>
   <!--PATTERN -->
   <!--RULE -->
   <xsl:template match="tei:floruit" priority="1000" mode="M200">

		<!--REPORT nonfatal-->
      <xsl:if test="@calendar">
         <xsl:message>WARNING: use of deprecated attribute — @calendar of the floruit element will be removed from the TEI on 2024-11-11.
                 (@calendar / nonfatal)</xsl:message>
      </xsl:if>
      <xsl:apply-templates select="*" mode="M200"/>
   </xsl:template>
   <xsl:template match="text()" priority="-1" mode="M200"/>
   <xsl:template match="@*|node()" priority="-2" mode="M200">
      <xsl:apply-templates select="*" mode="M200"/>
   </xsl:template>
   <!--PATTERN -->
   <!--RULE -->
   <xsl:template match="tei:gender" priority="1000" mode="M201">

		<!--REPORT nonfatal-->
      <xsl:if test="@calendar">
         <xsl:message>WARNING: use of deprecated attribute — @calendar of the gender element will be removed from the TEI on 2024-11-11.
                 (@calendar / nonfatal)</xsl:message>
      </xsl:if>
      <xsl:apply-templates select="*" mode="M201"/>
   </xsl:template>
   <xsl:template match="text()" priority="-1" mode="M201"/>
   <xsl:template match="@*|node()" priority="-2" mode="M201">
      <xsl:apply-templates select="*" mode="M201"/>
   </xsl:template>
   <!--PATTERN -->
   <!--RULE -->
   <xsl:template match="tei:langKnowledge" priority="1000" mode="M202">

		<!--REPORT nonfatal-->
      <xsl:if test="@calendar">
         <xsl:message>WARNING: use of deprecated attribute — @calendar of the langKnowledge element will be removed from the TEI on 2024-11-11.
                 (@calendar / nonfatal)</xsl:message>
      </xsl:if>
      <xsl:apply-templates select="*" mode="M202"/>
   </xsl:template>
   <xsl:template match="text()" priority="-1" mode="M202"/>
   <xsl:template match="@*|node()" priority="-2" mode="M202">
      <xsl:apply-templates select="*" mode="M202"/>
   </xsl:template>
   <!--PATTERN -->
   <!--RULE -->
   <xsl:template match="tei:langKnown" priority="1000" mode="M203">

		<!--REPORT nonfatal-->
      <xsl:if test="@calendar">
         <xsl:message>WARNING: use of deprecated attribute — @calendar of the langKnown element will be removed from the TEI on 2024-11-11.
                 (@calendar / nonfatal)</xsl:message>
      </xsl:if>
      <xsl:apply-templates select="*" mode="M203"/>
   </xsl:template>
   <xsl:template match="text()" priority="-1" mode="M203"/>
   <xsl:template match="@*|node()" priority="-2" mode="M203">
      <xsl:apply-templates select="*" mode="M203"/>
   </xsl:template>
   <!--PATTERN -->
   <!--RULE -->
   <xsl:template match="tei:location" priority="1000" mode="M204">

		<!--REPORT nonfatal-->
      <xsl:if test="@calendar">
         <xsl:message>WARNING: use of deprecated attribute — @calendar of the location element will be removed from the TEI on 2024-11-11.
                 (@calendar / nonfatal)</xsl:message>
      </xsl:if>
      <xsl:apply-templates select="*" mode="M204"/>
   </xsl:template>
   <xsl:template match="text()" priority="-1" mode="M204"/>
   <xsl:template match="@*|node()" priority="-2" mode="M204">
      <xsl:apply-templates select="*" mode="M204"/>
   </xsl:template>
   <!--PATTERN -->
   <!--RULE -->
   <xsl:template match="tei:nationality" priority="1000" mode="M205">

		<!--REPORT nonfatal-->
      <xsl:if test="@calendar">
         <xsl:message>WARNING: use of deprecated attribute — @calendar of the nationality element will be removed from the TEI on 2024-11-11.
                 (@calendar / nonfatal)</xsl:message>
      </xsl:if>
      <xsl:apply-templates select="*" mode="M205"/>
   </xsl:template>
   <xsl:template match="text()" priority="-1" mode="M205"/>
   <xsl:template match="@*|node()" priority="-2" mode="M205">
      <xsl:apply-templates select="*" mode="M205"/>
   </xsl:template>
   <!--PATTERN -->
   <!--RULE -->
   <xsl:template match="tei:occupation" priority="1000" mode="M206">

		<!--REPORT nonfatal-->
      <xsl:if test="@calendar">
         <xsl:message>WARNING: use of deprecated attribute — @calendar of the occupation element will be removed from the TEI on 2024-11-11.
                 (@calendar / nonfatal)</xsl:message>
      </xsl:if>
      <xsl:apply-templates select="*" mode="M206"/>
   </xsl:template>
   <xsl:template match="text()" priority="-1" mode="M206"/>
   <xsl:template match="@*|node()" priority="-2" mode="M206">
      <xsl:apply-templates select="*" mode="M206"/>
   </xsl:template>
   <!--PATTERN -->
   <!--RULE -->
   <xsl:template match="tei:persPronouns" priority="1000" mode="M207">

		<!--REPORT nonfatal-->
      <xsl:if test="@calendar">
         <xsl:message>WARNING: use of deprecated attribute — @calendar of the persPronouns element will be removed from the TEI on 2024-11-11.
                 (@calendar / nonfatal)</xsl:message>
      </xsl:if>
      <xsl:apply-templates select="*" mode="M207"/>
   </xsl:template>
   <xsl:template match="text()" priority="-1" mode="M207"/>
   <xsl:template match="@*|node()" priority="-2" mode="M207">
      <xsl:apply-templates select="*" mode="M207"/>
   </xsl:template>
   <!--PATTERN -->
   <!--RULE -->
   <xsl:template match="tei:population" priority="1000" mode="M208">

		<!--REPORT nonfatal-->
      <xsl:if test="@calendar">
         <xsl:message>WARNING: use of deprecated attribute — @calendar of the population element will be removed from the TEI on 2024-11-11.
                 (@calendar / nonfatal)</xsl:message>
      </xsl:if>
      <xsl:apply-templates select="*" mode="M208"/>
   </xsl:template>
   <xsl:template match="text()" priority="-1" mode="M208"/>
   <xsl:template match="@*|node()" priority="-2" mode="M208">
      <xsl:apply-templates select="*" mode="M208"/>
   </xsl:template>
   <!--PATTERN -->
   <!--RULE -->
   <xsl:template match="tei:relation" priority="1000" mode="M209">

		<!--REPORT nonfatal-->
      <xsl:if test="@calendar">
         <xsl:message>WARNING: use of deprecated attribute — @calendar of the relation element will be removed from the TEI on 2024-11-11.
                 (@calendar / nonfatal)</xsl:message>
      </xsl:if>
      <xsl:apply-templates select="*" mode="M209"/>
   </xsl:template>
   <xsl:template match="text()" priority="-1" mode="M209"/>
   <xsl:template match="@*|node()" priority="-2" mode="M209">
      <xsl:apply-templates select="*" mode="M209"/>
   </xsl:template>
   <!--PATTERN -->
   <!--RULE -->
   <xsl:template match="tei:residence" priority="1000" mode="M210">

		<!--REPORT nonfatal-->
      <xsl:if test="@calendar">
         <xsl:message>WARNING: use of deprecated attribute — @calendar of the residence element will be removed from the TEI on 2024-11-11.
                 (@calendar / nonfatal)</xsl:message>
      </xsl:if>
      <xsl:apply-templates select="*" mode="M210"/>
   </xsl:template>
   <xsl:template match="text()" priority="-1" mode="M210"/>
   <xsl:template match="@*|node()" priority="-2" mode="M210">
      <xsl:apply-templates select="*" mode="M210"/>
   </xsl:template>
   <!--PATTERN -->
   <!--RULE -->
   <xsl:template match="tei:sex" priority="1000" mode="M211">

		<!--REPORT nonfatal-->
      <xsl:if test="@calendar">
         <xsl:message>WARNING: use of deprecated attribute — @calendar of the sex element will be removed from the TEI on 2024-11-11.
                 (@calendar / nonfatal)</xsl:message>
      </xsl:if>
      <xsl:apply-templates select="*" mode="M211"/>
   </xsl:template>
   <xsl:template match="text()" priority="-1" mode="M211"/>
   <xsl:template match="@*|node()" priority="-2" mode="M211">
      <xsl:apply-templates select="*" mode="M211"/>
   </xsl:template>
   <!--PATTERN -->
   <!--RULE -->
   <xsl:template match="tei:socecStatus" priority="1000" mode="M212">

		<!--REPORT nonfatal-->
      <xsl:if test="@calendar">
         <xsl:message>WARNING: use of deprecated attribute — @calendar of the socecStatus element will be removed from the TEI on 2024-11-11.
                 (@calendar / nonfatal)</xsl:message>
      </xsl:if>
      <xsl:apply-templates select="*" mode="M212"/>
   </xsl:template>
   <xsl:template match="text()" priority="-1" mode="M212"/>
   <xsl:template match="@*|node()" priority="-2" mode="M212">
      <xsl:apply-templates select="*" mode="M212"/>
   </xsl:template>
   <!--PATTERN -->
   <!--RULE -->
   <xsl:template match="tei:state" priority="1000" mode="M213">

		<!--REPORT nonfatal-->
      <xsl:if test="@calendar">
         <xsl:message>WARNING: use of deprecated attribute — @calendar of the state element will be removed from the TEI on 2024-11-11.
                 (@calendar / nonfatal)</xsl:message>
      </xsl:if>
      <xsl:apply-templates select="*" mode="M213"/>
   </xsl:template>
   <xsl:template match="text()" priority="-1" mode="M213"/>
   <xsl:template match="@*|node()" priority="-2" mode="M213">
      <xsl:apply-templates select="*" mode="M213"/>
   </xsl:template>
   <!--PATTERN -->
   <!--RULE -->
   <xsl:template match="tei:terrain" priority="1000" mode="M214">

		<!--REPORT nonfatal-->
      <xsl:if test="@calendar">
         <xsl:message>WARNING: use of deprecated attribute — @calendar of the terrain element will be removed from the TEI on 2024-11-11.
                 (@calendar / nonfatal)</xsl:message>
      </xsl:if>
      <xsl:apply-templates select="*" mode="M214"/>
   </xsl:template>
   <xsl:template match="text()" priority="-1" mode="M214"/>
   <xsl:template match="@*|node()" priority="-2" mode="M214">
      <xsl:apply-templates select="*" mode="M214"/>
   </xsl:template>
   <!--PATTERN -->
   <!--RULE -->
   <xsl:template match="tei:trait" priority="1000" mode="M215">

		<!--REPORT nonfatal-->
      <xsl:if test="@calendar">
         <xsl:message>WARNING: use of deprecated attribute — @calendar of the trait element will be removed from the TEI on 2024-11-11.
                 (@calendar / nonfatal)</xsl:message>
      </xsl:if>
      <xsl:apply-templates select="*" mode="M215"/>
   </xsl:template>
   <xsl:template match="text()" priority="-1" mode="M215"/>
   <xsl:template match="@*|node()" priority="-2" mode="M215">
      <xsl:apply-templates select="*" mode="M215"/>
   </xsl:template>
   <!--PATTERN -->
   <!--RULE -->
   <xsl:template match="tei:objectName" priority="1000" mode="M216">

		<!--REPORT nonfatal-->
      <xsl:if test="@calendar">
         <xsl:message>WARNING: use of deprecated attribute — @calendar of the objectName element will be removed from the TEI on 2024-11-11.
                 (@calendar / nonfatal)</xsl:message>
      </xsl:if>
      <xsl:apply-templates select="*" mode="M216"/>
   </xsl:template>
   <xsl:template match="text()" priority="-1" mode="M216"/>
   <xsl:template match="@*|node()" priority="-2" mode="M216">
      <xsl:apply-templates select="*" mode="M216"/>
   </xsl:template>
   <!--PATTERN -->
   <!--RULE -->
   <xsl:template match="tei:precision" priority="1000" mode="M217">

		<!--REPORT nonfatal-->
      <xsl:if test="@calendar">
         <xsl:message>WARNING: use of deprecated attribute — @calendar of the precision element will be removed from the TEI on 2024-11-11.
                 (@calendar / nonfatal)</xsl:message>
      </xsl:if>
      <xsl:apply-templates select="*" mode="M217"/>
   </xsl:template>
   <xsl:template match="text()" priority="-1" mode="M217"/>
   <xsl:template match="@*|node()" priority="-2" mode="M217">
      <xsl:apply-templates select="*" mode="M217"/>
   </xsl:template>
   <!--PATTERN teipm-model-paramList-1-->
   <!--RULE -->
   <xsl:template match="tei:param[parent::tei:model/@behaviour='alternate']"
                 priority="1000"
                 mode="M218">

		<!--ASSERT error-->
      <xsl:choose>
         <xsl:when test="@name='default'   or  @name='alternate'"/>
         <xsl:otherwise>
            <xsl:message>
          Parameter name '<xsl:text/>
               <xsl:value-of select="@name"/>
               <xsl:text/>'  (on <xsl:text/>
               <xsl:value-of select="ancestor::tei:elementSpec/@ident"/>
               <xsl:text/>) not allowed.
          Must  be  drawn from the list: default, alternate (@name='default' or @name='alternate' / error)</xsl:message>
         </xsl:otherwise>
      </xsl:choose>
      <xsl:apply-templates select="*" mode="M218"/>
   </xsl:template>
   <xsl:template match="text()" priority="-1" mode="M218"/>
   <xsl:template match="@*|node()" priority="-2" mode="M218">
      <xsl:apply-templates select="*" mode="M218"/>
   </xsl:template>
   <!--PATTERN teipm-model-paramList-2-->
   <!--RULE -->
   <xsl:template match="tei:param[parent::tei:model/@behaviour='anchor']"
                 priority="1000"
                 mode="M219">

		<!--ASSERT error-->
      <xsl:choose>
         <xsl:when test="@name='id'"/>
         <xsl:otherwise>
            <xsl:message>
          Parameter name '<xsl:text/>
               <xsl:value-of select="@name"/>
               <xsl:text/>'  (on <xsl:text/>
               <xsl:value-of select="ancestor::tei:elementSpec/@ident"/>
               <xsl:text/>) not allowed.
          Must  be  drawn from the list: id (@name='id' / error)</xsl:message>
         </xsl:otherwise>
      </xsl:choose>
      <xsl:apply-templates select="*" mode="M219"/>
   </xsl:template>
   <xsl:template match="text()" priority="-1" mode="M219"/>
   <xsl:template match="@*|node()" priority="-2" mode="M219">
      <xsl:apply-templates select="*" mode="M219"/>
   </xsl:template>
   <!--PATTERN teipm-model-paramList-3-->
   <!--RULE -->
   <xsl:template match="tei:param[parent::tei:model/@behaviour='block']"
                 priority="1000"
                 mode="M220">

		<!--ASSERT error-->
      <xsl:choose>
         <xsl:when test="@name='content'"/>
         <xsl:otherwise>
            <xsl:message>
          Parameter name '<xsl:text/>
               <xsl:value-of select="@name"/>
               <xsl:text/>'  (on <xsl:text/>
               <xsl:value-of select="ancestor::tei:elementSpec/@ident"/>
               <xsl:text/>) not allowed.
          Must  be  drawn from the list: content (@name='content' / error)</xsl:message>
         </xsl:otherwise>
      </xsl:choose>
      <xsl:apply-templates select="*" mode="M220"/>
   </xsl:template>
   <xsl:template match="text()" priority="-1" mode="M220"/>
   <xsl:template match="@*|node()" priority="-2" mode="M220">
      <xsl:apply-templates select="*" mode="M220"/>
   </xsl:template>
   <!--PATTERN teipm-model-paramList-4-->
   <!--RULE -->
   <xsl:template match="tei:param[parent::tei:model/@behaviour='body']"
                 priority="1000"
                 mode="M221">

		<!--ASSERT error-->
      <xsl:choose>
         <xsl:when test="@name='content'"/>
         <xsl:otherwise>
            <xsl:message>
          Parameter name '<xsl:text/>
               <xsl:value-of select="@name"/>
               <xsl:text/>'  (on <xsl:text/>
               <xsl:value-of select="ancestor::tei:elementSpec/@ident"/>
               <xsl:text/>) not allowed.
          Must  be  drawn from the list: content (@name='content' / error)</xsl:message>
         </xsl:otherwise>
      </xsl:choose>
      <xsl:apply-templates select="*" mode="M221"/>
   </xsl:template>
   <xsl:template match="text()" priority="-1" mode="M221"/>
   <xsl:template match="@*|node()" priority="-2" mode="M221">
      <xsl:apply-templates select="*" mode="M221"/>
   </xsl:template>
   <!--PATTERN teipm-model-paramList-5-->
   <!--RULE -->
   <xsl:template match="tei:param[parent::tei:model/@behaviour='break']"
                 priority="1000"
                 mode="M222">

		<!--ASSERT error-->
      <xsl:choose>
         <xsl:when test="@name='type'   or  @name='label'"/>
         <xsl:otherwise>
            <xsl:message>
          Parameter name '<xsl:text/>
               <xsl:value-of select="@name"/>
               <xsl:text/>'  (on <xsl:text/>
               <xsl:value-of select="ancestor::tei:elementSpec/@ident"/>
               <xsl:text/>) not allowed.
          Must  be  drawn from the list: type, label (@name='type' or @name='label' / error)</xsl:message>
         </xsl:otherwise>
      </xsl:choose>
      <xsl:apply-templates select="*" mode="M222"/>
   </xsl:template>
   <xsl:template match="text()" priority="-1" mode="M222"/>
   <xsl:template match="@*|node()" priority="-2" mode="M222">
      <xsl:apply-templates select="*" mode="M222"/>
   </xsl:template>
   <!--PATTERN teipm-model-paramList-6-->
   <!--RULE -->
   <xsl:template match="tei:param[parent::tei:model/@behaviour='cell']"
                 priority="1000"
                 mode="M223">

		<!--ASSERT error-->
      <xsl:choose>
         <xsl:when test="@name='content'"/>
         <xsl:otherwise>
            <xsl:message>
          Parameter name '<xsl:text/>
               <xsl:value-of select="@name"/>
               <xsl:text/>'  (on <xsl:text/>
               <xsl:value-of select="ancestor::tei:elementSpec/@ident"/>
               <xsl:text/>) not allowed.
          Must  be  drawn from the list: content (@name='content' / error)</xsl:message>
         </xsl:otherwise>
      </xsl:choose>
      <xsl:apply-templates select="*" mode="M223"/>
   </xsl:template>
   <xsl:template match="text()" priority="-1" mode="M223"/>
   <xsl:template match="@*|node()" priority="-2" mode="M223">
      <xsl:apply-templates select="*" mode="M223"/>
   </xsl:template>
   <!--PATTERN teipm-model-paramList-7-->
   <!--RULE -->
   <xsl:template match="tei:param[parent::tei:model/@behaviour='cit']"
                 priority="1000"
                 mode="M224">

		<!--ASSERT error-->
      <xsl:choose>
         <xsl:when test="@name='content'   or  @name='source'"/>
         <xsl:otherwise>
            <xsl:message>
          Parameter name '<xsl:text/>
               <xsl:value-of select="@name"/>
               <xsl:text/>'  (on <xsl:text/>
               <xsl:value-of select="ancestor::tei:elementSpec/@ident"/>
               <xsl:text/>) not allowed.
          Must  be  drawn from the list: content, source (@name='content' or @name='source' / error)</xsl:message>
         </xsl:otherwise>
      </xsl:choose>
      <xsl:apply-templates select="*" mode="M224"/>
   </xsl:template>
   <xsl:template match="text()" priority="-1" mode="M224"/>
   <xsl:template match="@*|node()" priority="-2" mode="M224">
      <xsl:apply-templates select="*" mode="M224"/>
   </xsl:template>
   <!--PATTERN teipm-model-paramList-8-->
   <!--RULE -->
   <xsl:template match="tei:param[parent::tei:model/@behaviour='document']"
                 priority="1000"
                 mode="M225">

		<!--ASSERT error-->
      <xsl:choose>
         <xsl:when test="@name='content'"/>
         <xsl:otherwise>
            <xsl:message>
          Parameter name '<xsl:text/>
               <xsl:value-of select="@name"/>
               <xsl:text/>'  (on <xsl:text/>
               <xsl:value-of select="ancestor::tei:elementSpec/@ident"/>
               <xsl:text/>) not allowed.
          Must  be  drawn from the list: content (@name='content' / error)</xsl:message>
         </xsl:otherwise>
      </xsl:choose>
      <xsl:apply-templates select="*" mode="M225"/>
   </xsl:template>
   <xsl:template match="text()" priority="-1" mode="M225"/>
   <xsl:template match="@*|node()" priority="-2" mode="M225">
      <xsl:apply-templates select="*" mode="M225"/>
   </xsl:template>
   <!--PATTERN teipm-model-paramList-9-->
   <!--RULE -->
   <xsl:template match="tei:param[parent::tei:model/@behaviour='figure']"
                 priority="1000"
                 mode="M226">

		<!--ASSERT error-->
      <xsl:choose>
         <xsl:when test="@name='title'"/>
         <xsl:otherwise>
            <xsl:message>
          Parameter name '<xsl:text/>
               <xsl:value-of select="@name"/>
               <xsl:text/>'  (on <xsl:text/>
               <xsl:value-of select="ancestor::tei:elementSpec/@ident"/>
               <xsl:text/>) not allowed.
          Must  be  drawn from the list: title (@name='title' / error)</xsl:message>
         </xsl:otherwise>
      </xsl:choose>
      <xsl:apply-templates select="*" mode="M226"/>
   </xsl:template>
   <xsl:template match="text()" priority="-1" mode="M226"/>
   <xsl:template match="@*|node()" priority="-2" mode="M226">
      <xsl:apply-templates select="*" mode="M226"/>
   </xsl:template>
   <!--PATTERN teipm-model-paramList-10-->
   <!--RULE -->
   <xsl:template match="tei:param[parent::tei:model/@behaviour='glyph']"
                 priority="1000"
                 mode="M227">

		<!--ASSERT error-->
      <xsl:choose>
         <xsl:when test="@name='uri'"/>
         <xsl:otherwise>
            <xsl:message>
          Parameter name '<xsl:text/>
               <xsl:value-of select="@name"/>
               <xsl:text/>'  (on <xsl:text/>
               <xsl:value-of select="ancestor::tei:elementSpec/@ident"/>
               <xsl:text/>) not allowed.
          Must  be  drawn from the list: uri (@name='uri' / error)</xsl:message>
         </xsl:otherwise>
      </xsl:choose>
      <xsl:apply-templates select="*" mode="M227"/>
   </xsl:template>
   <xsl:template match="text()" priority="-1" mode="M227"/>
   <xsl:template match="@*|node()" priority="-2" mode="M227">
      <xsl:apply-templates select="*" mode="M227"/>
   </xsl:template>
   <!--PATTERN teipm-model-paramList-11-->
   <!--RULE -->
   <xsl:template match="tei:param[parent::tei:model/@behaviour='graphic']"
                 priority="1000"
                 mode="M228">

		<!--ASSERT error-->
      <xsl:choose>
         <xsl:when test="@name='url'   or  @name='width'   or  @name='height'   or  @name='scale'   or  @name='title'"/>
         <xsl:otherwise>
            <xsl:message>
          Parameter name '<xsl:text/>
               <xsl:value-of select="@name"/>
               <xsl:text/>'  (on <xsl:text/>
               <xsl:value-of select="ancestor::tei:elementSpec/@ident"/>
               <xsl:text/>) not allowed.
          Must  be  drawn from the list: url, width, height, scale, title (@name='url' or @name='width' or @name='height' or @name='scale' or @name='title' / error)</xsl:message>
         </xsl:otherwise>
      </xsl:choose>
      <xsl:apply-templates select="*" mode="M228"/>
   </xsl:template>
   <xsl:template match="text()" priority="-1" mode="M228"/>
   <xsl:template match="@*|node()" priority="-2" mode="M228">
      <xsl:apply-templates select="*" mode="M228"/>
   </xsl:template>
   <!--PATTERN teipm-model-paramList-12-->
   <!--RULE -->
   <xsl:template match="tei:param[parent::tei:model/@behaviour='heading']"
                 priority="1000"
                 mode="M229">

		<!--ASSERT error-->
      <xsl:choose>
         <xsl:when test="@name='content'   or  @name='level'"/>
         <xsl:otherwise>
            <xsl:message>
          Parameter name '<xsl:text/>
               <xsl:value-of select="@name"/>
               <xsl:text/>'  (on <xsl:text/>
               <xsl:value-of select="ancestor::tei:elementSpec/@ident"/>
               <xsl:text/>) not allowed.
          Must  be  drawn from the list: content, level (@name='content' or @name='level' / error)</xsl:message>
         </xsl:otherwise>
      </xsl:choose>
      <xsl:apply-templates select="*" mode="M229"/>
   </xsl:template>
   <xsl:template match="text()" priority="-1" mode="M229"/>
   <xsl:template match="@*|node()" priority="-2" mode="M229">
      <xsl:apply-templates select="*" mode="M229"/>
   </xsl:template>
   <!--PATTERN teipm-model-paramList-13-->
   <!--RULE -->
   <xsl:template match="tei:param[parent::tei:model/@behaviour='index']"
                 priority="1000"
                 mode="M230">

		<!--ASSERT error-->
      <xsl:choose>
         <xsl:when test="@name='type'"/>
         <xsl:otherwise>
            <xsl:message>
          Parameter name '<xsl:text/>
               <xsl:value-of select="@name"/>
               <xsl:text/>'  (on <xsl:text/>
               <xsl:value-of select="ancestor::tei:elementSpec/@ident"/>
               <xsl:text/>) not allowed.
          Must  be  drawn from the list: type (@name='type' / error)</xsl:message>
         </xsl:otherwise>
      </xsl:choose>
      <xsl:apply-templates select="*" mode="M230"/>
   </xsl:template>
   <xsl:template match="text()" priority="-1" mode="M230"/>
   <xsl:template match="@*|node()" priority="-2" mode="M230">
      <xsl:apply-templates select="*" mode="M230"/>
   </xsl:template>
   <!--PATTERN teipm-model-paramList-14-->
   <!--RULE -->
   <xsl:template match="tei:param[parent::tei:model/@behaviour='inline']"
                 priority="1000"
                 mode="M231">

		<!--ASSERT error-->
      <xsl:choose>
         <xsl:when test="@name='content'   or  @name='label'"/>
         <xsl:otherwise>
            <xsl:message>
          Parameter name '<xsl:text/>
               <xsl:value-of select="@name"/>
               <xsl:text/>'  (on <xsl:text/>
               <xsl:value-of select="ancestor::tei:elementSpec/@ident"/>
               <xsl:text/>) not allowed.
          Must  be  drawn from the list: content, label (@name='content' or @name='label' / error)</xsl:message>
         </xsl:otherwise>
      </xsl:choose>
      <xsl:apply-templates select="*" mode="M231"/>
   </xsl:template>
   <xsl:template match="text()" priority="-1" mode="M231"/>
   <xsl:template match="@*|node()" priority="-2" mode="M231">
      <xsl:apply-templates select="*" mode="M231"/>
   </xsl:template>
   <!--PATTERN teipm-model-paramList-15-->
   <!--RULE -->
   <xsl:template match="tei:param[parent::tei:model/@behaviour='link']"
                 priority="1000"
                 mode="M232">

		<!--ASSERT error-->
      <xsl:choose>
         <xsl:when test="@name='content'   or  @name='uri'"/>
         <xsl:otherwise>
            <xsl:message>
          Parameter name '<xsl:text/>
               <xsl:value-of select="@name"/>
               <xsl:text/>'  (on <xsl:text/>
               <xsl:value-of select="ancestor::tei:elementSpec/@ident"/>
               <xsl:text/>) not allowed.
          Must  be  drawn from the list: content, uri (@name='content' or @name='uri' / error)</xsl:message>
         </xsl:otherwise>
      </xsl:choose>
      <xsl:apply-templates select="*" mode="M232"/>
   </xsl:template>
   <xsl:template match="text()" priority="-1" mode="M232"/>
   <xsl:template match="@*|node()" priority="-2" mode="M232">
      <xsl:apply-templates select="*" mode="M232"/>
   </xsl:template>
   <!--PATTERN teipm-model-paramList-16-->
   <!--RULE -->
   <xsl:template match="tei:param[parent::tei:model/@behaviour='list']"
                 priority="1000"
                 mode="M233">

		<!--ASSERT error-->
      <xsl:choose>
         <xsl:when test="@name='content'"/>
         <xsl:otherwise>
            <xsl:message>
          Parameter name '<xsl:text/>
               <xsl:value-of select="@name"/>
               <xsl:text/>'  (on <xsl:text/>
               <xsl:value-of select="ancestor::tei:elementSpec/@ident"/>
               <xsl:text/>) not allowed.
          Must  be  drawn from the list: content (@name='content' / error)</xsl:message>
         </xsl:otherwise>
      </xsl:choose>
      <xsl:apply-templates select="*" mode="M233"/>
   </xsl:template>
   <xsl:template match="text()" priority="-1" mode="M233"/>
   <xsl:template match="@*|node()" priority="-2" mode="M233">
      <xsl:apply-templates select="*" mode="M233"/>
   </xsl:template>
   <!--PATTERN teipm-model-paramList-17-->
   <!--RULE -->
   <xsl:template match="tei:param[parent::tei:model/@behaviour='listItem']"
                 priority="1000"
                 mode="M234">

		<!--ASSERT error-->
      <xsl:choose>
         <xsl:when test="@name='content'"/>
         <xsl:otherwise>
            <xsl:message>
          Parameter name '<xsl:text/>
               <xsl:value-of select="@name"/>
               <xsl:text/>'  (on <xsl:text/>
               <xsl:value-of select="ancestor::tei:elementSpec/@ident"/>
               <xsl:text/>) not allowed.
          Must  be  drawn from the list: content (@name='content' / error)</xsl:message>
         </xsl:otherwise>
      </xsl:choose>
      <xsl:apply-templates select="*" mode="M234"/>
   </xsl:template>
   <xsl:template match="text()" priority="-1" mode="M234"/>
   <xsl:template match="@*|node()" priority="-2" mode="M234">
      <xsl:apply-templates select="*" mode="M234"/>
   </xsl:template>
   <!--PATTERN teipm-model-paramList-18-->
   <!--RULE -->
   <xsl:template match="tei:param[parent::tei:model/@behaviour='metadata']"
                 priority="1000"
                 mode="M235">

		<!--ASSERT error-->
      <xsl:choose>
         <xsl:when test="@name='content'"/>
         <xsl:otherwise>
            <xsl:message>
          Parameter name '<xsl:text/>
               <xsl:value-of select="@name"/>
               <xsl:text/>'  (on <xsl:text/>
               <xsl:value-of select="ancestor::tei:elementSpec/@ident"/>
               <xsl:text/>) not allowed.
          Must  be  drawn from the list: content (@name='content' / error)</xsl:message>
         </xsl:otherwise>
      </xsl:choose>
      <xsl:apply-templates select="*" mode="M235"/>
   </xsl:template>
   <xsl:template match="text()" priority="-1" mode="M235"/>
   <xsl:template match="@*|node()" priority="-2" mode="M235">
      <xsl:apply-templates select="*" mode="M235"/>
   </xsl:template>
   <!--PATTERN teipm-model-paramList-19-->
   <!--RULE -->
   <xsl:template match="tei:param[parent::tei:model/@behaviour='note']"
                 priority="1000"
                 mode="M236">

		<!--ASSERT error-->
      <xsl:choose>
         <xsl:when test="@name='content'   or  @name='place'   or  @name='label'"/>
         <xsl:otherwise>
            <xsl:message>
          Parameter name '<xsl:text/>
               <xsl:value-of select="@name"/>
               <xsl:text/>'  (on <xsl:text/>
               <xsl:value-of select="ancestor::tei:elementSpec/@ident"/>
               <xsl:text/>) not allowed.
          Must  be  drawn from the list: content, place, label (@name='content' or @name='place' or @name='label' / error)</xsl:message>
         </xsl:otherwise>
      </xsl:choose>
      <xsl:apply-templates select="*" mode="M236"/>
   </xsl:template>
   <xsl:template match="text()" priority="-1" mode="M236"/>
   <xsl:template match="@*|node()" priority="-2" mode="M236">
      <xsl:apply-templates select="*" mode="M236"/>
   </xsl:template>
   <!--PATTERN teipm-model-paramList-20-->
   <!--RULE -->
   <xsl:template match="tei:param[parent::tei:model/@behaviour='paragraph']"
                 priority="1000"
                 mode="M237">

		<!--ASSERT error-->
      <xsl:choose>
         <xsl:when test="@name='content'"/>
         <xsl:otherwise>
            <xsl:message>
          Parameter name '<xsl:text/>
               <xsl:value-of select="@name"/>
               <xsl:text/>'  (on <xsl:text/>
               <xsl:value-of select="ancestor::tei:elementSpec/@ident"/>
               <xsl:text/>) not allowed.
          Must  be  drawn from the list: content (@name='content' / error)</xsl:message>
         </xsl:otherwise>
      </xsl:choose>
      <xsl:apply-templates select="*" mode="M237"/>
   </xsl:template>
   <xsl:template match="text()" priority="-1" mode="M237"/>
   <xsl:template match="@*|node()" priority="-2" mode="M237">
      <xsl:apply-templates select="*" mode="M237"/>
   </xsl:template>
   <!--PATTERN teipm-model-paramList-21-->
   <!--RULE -->
   <xsl:template match="tei:param[parent::tei:model/@behaviour='row']"
                 priority="1000"
                 mode="M238">

		<!--ASSERT error-->
      <xsl:choose>
         <xsl:when test="@name='content'"/>
         <xsl:otherwise>
            <xsl:message>
          Parameter name '<xsl:text/>
               <xsl:value-of select="@name"/>
               <xsl:text/>'  (on <xsl:text/>
               <xsl:value-of select="ancestor::tei:elementSpec/@ident"/>
               <xsl:text/>) not allowed.
          Must  be  drawn from the list: content (@name='content' / error)</xsl:message>
         </xsl:otherwise>
      </xsl:choose>
      <xsl:apply-templates select="*" mode="M238"/>
   </xsl:template>
   <xsl:template match="text()" priority="-1" mode="M238"/>
   <xsl:template match="@*|node()" priority="-2" mode="M238">
      <xsl:apply-templates select="*" mode="M238"/>
   </xsl:template>
   <!--PATTERN teipm-model-paramList-22-->
   <!--RULE -->
   <xsl:template match="tei:param[parent::tei:model/@behaviour='section']"
                 priority="1000"
                 mode="M239">

		<!--ASSERT error-->
      <xsl:choose>
         <xsl:when test="@name='content'"/>
         <xsl:otherwise>
            <xsl:message>
          Parameter name '<xsl:text/>
               <xsl:value-of select="@name"/>
               <xsl:text/>'  (on <xsl:text/>
               <xsl:value-of select="ancestor::tei:elementSpec/@ident"/>
               <xsl:text/>) not allowed.
          Must  be  drawn from the list: content (@name='content' / error)</xsl:message>
         </xsl:otherwise>
      </xsl:choose>
      <xsl:apply-templates select="*" mode="M239"/>
   </xsl:template>
   <xsl:template match="text()" priority="-1" mode="M239"/>
   <xsl:template match="@*|node()" priority="-2" mode="M239">
      <xsl:apply-templates select="*" mode="M239"/>
   </xsl:template>
   <!--PATTERN teipm-model-paramList-23-->
   <!--RULE -->
   <xsl:template match="tei:param[parent::tei:model/@behaviour='table']"
                 priority="1000"
                 mode="M240">

		<!--ASSERT error-->
      <xsl:choose>
         <xsl:when test="@name='content'"/>
         <xsl:otherwise>
            <xsl:message>
          Parameter name '<xsl:text/>
               <xsl:value-of select="@name"/>
               <xsl:text/>'  (on <xsl:text/>
               <xsl:value-of select="ancestor::tei:elementSpec/@ident"/>
               <xsl:text/>) not allowed.
          Must  be  drawn from the list: content (@name='content' / error)</xsl:message>
         </xsl:otherwise>
      </xsl:choose>
      <xsl:apply-templates select="*" mode="M240"/>
   </xsl:template>
   <xsl:template match="text()" priority="-1" mode="M240"/>
   <xsl:template match="@*|node()" priority="-2" mode="M240">
      <xsl:apply-templates select="*" mode="M240"/>
   </xsl:template>
   <!--PATTERN teipm-model-paramList-24-->
   <!--RULE -->
   <xsl:template match="tei:param[parent::tei:model/@behaviour='text']"
                 priority="1000"
                 mode="M241">

		<!--ASSERT error-->
      <xsl:choose>
         <xsl:when test="@name='content'"/>
         <xsl:otherwise>
            <xsl:message>
          Parameter name '<xsl:text/>
               <xsl:value-of select="@name"/>
               <xsl:text/>'  (on <xsl:text/>
               <xsl:value-of select="ancestor::tei:elementSpec/@ident"/>
               <xsl:text/>) not allowed.
          Must  be  drawn from the list: content (@name='content' / error)</xsl:message>
         </xsl:otherwise>
      </xsl:choose>
      <xsl:apply-templates select="*" mode="M241"/>
   </xsl:template>
   <xsl:template match="text()" priority="-1" mode="M241"/>
   <xsl:template match="@*|node()" priority="-2" mode="M241">
      <xsl:apply-templates select="*" mode="M241"/>
   </xsl:template>
   <!--PATTERN teipm-model-paramList-25-->
   <!--RULE -->
   <xsl:template match="tei:param[parent::tei:model/@behaviour='title']"
                 priority="1000"
                 mode="M242">

		<!--ASSERT error-->
      <xsl:choose>
         <xsl:when test="@name='content'"/>
         <xsl:otherwise>
            <xsl:message>
          Parameter name '<xsl:text/>
               <xsl:value-of select="@name"/>
               <xsl:text/>'  (on <xsl:text/>
               <xsl:value-of select="ancestor::tei:elementSpec/@ident"/>
               <xsl:text/>) not allowed.
          Must  be  drawn from the list: content (@name='content' / error)</xsl:message>
         </xsl:otherwise>
      </xsl:choose>
      <xsl:apply-templates select="*" mode="M242"/>
   </xsl:template>
   <xsl:template match="text()" priority="-1" mode="M242"/>
   <xsl:template match="@*|node()" priority="-2" mode="M242">
      <xsl:apply-templates select="*" mode="M242"/>
   </xsl:template>
</xsl:stylesheet>
