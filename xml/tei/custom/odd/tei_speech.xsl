<?xml version="1.0" encoding="UTF-8" standalone="yes"?>
<xsl:stylesheet xmlns:iso="http://purl.oclc.org/dsdl/schematron"
                xmlns:rna="http://relaxng.org/ns/compatibility/annotations/1.0"
                xmlns:rng="http://relaxng.org/ns/structure/1.0"
                xmlns:saxon="http://saxon.sf.net/"
                xmlns:sch="http://purl.oclc.org/dsdl/schematron"
                xmlns:sch1x="http://www.ascc.net/xml/schematron"
                xmlns:schold="http://www.ascc.net/xml/schematron"
                xmlns:tei="http://www.tei-c.org/ns/1.0"
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
      <xsl:apply-templates select="/" mode="M7"/>
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
   </xsl:template>
   <!--SCHEMATRON PATTERNS-->
   <!--PATTERN schematron-constraint-tei_speech-att.datable.w3c-att-datable-w3c-when-1-->
   <!--RULE -->
   <xsl:template match="tei:*[@when]" priority="1000" mode="M7">

		<!--REPORT nonfatal-->
      <xsl:if test="@notBefore|@notAfter|@from|@to">
         <xsl:message>The @when attribute cannot be used with any other att.datable.w3c attributes. (@notBefore|@notAfter|@from|@to / nonfatal)</xsl:message>
      </xsl:if>
      <xsl:apply-templates select="*" mode="M7"/>
   </xsl:template>
   <xsl:template match="text()" priority="-1" mode="M7"/>
   <xsl:template match="@*|node()" priority="-2" mode="M7">
      <xsl:apply-templates select="*" mode="M7"/>
   </xsl:template>
   <!--PATTERN schematron-constraint-tei_speech-att.datable.w3c-att-datable-w3c-from-2-->
   <!--RULE -->
   <xsl:template match="tei:*[@from]" priority="1000" mode="M8">

		<!--REPORT nonfatal-->
      <xsl:if test="@notBefore">
         <xsl:message>The @from and @notBefore attributes cannot be used together. (@notBefore / nonfatal)</xsl:message>
      </xsl:if>
      <xsl:apply-templates select="*" mode="M8"/>
   </xsl:template>
   <xsl:template match="text()" priority="-1" mode="M8"/>
   <xsl:template match="@*|node()" priority="-2" mode="M8">
      <xsl:apply-templates select="*" mode="M8"/>
   </xsl:template>
   <!--PATTERN schematron-constraint-tei_speech-att.datable.w3c-att-datable-w3c-to-3-->
   <!--RULE -->
   <xsl:template match="tei:*[@to]" priority="1000" mode="M9">

		<!--REPORT nonfatal-->
      <xsl:if test="@notAfter">
         <xsl:message>The @to and @notAfter attributes cannot be used together. (@notAfter / nonfatal)</xsl:message>
      </xsl:if>
      <xsl:apply-templates select="*" mode="M9"/>
   </xsl:template>
   <xsl:template match="text()" priority="-1" mode="M9"/>
   <xsl:template match="@*|node()" priority="-2" mode="M9">
      <xsl:apply-templates select="*" mode="M9"/>
   </xsl:template>
   <!--PATTERN schematron-constraint-tei_speech-att.global.source-source-only_1_ODD_source-4-->
   <!--RULE -->
   <xsl:template match="tei:*[@source]" priority="1000" mode="M10">
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
      <xsl:apply-templates select="*" mode="M10"/>
   </xsl:template>
   <xsl:template match="text()" priority="-1" mode="M10"/>
   <xsl:template match="@*|node()" priority="-2" mode="M10">
      <xsl:apply-templates select="*" mode="M10"/>
   </xsl:template>
   <!--PATTERN schematron-constraint-tei_speech-att.measurement-att-measurement-unitRef-5-->
   <!--RULE -->
   <xsl:template match="tei:*[@unitRef]" priority="1000" mode="M11">

		<!--REPORT info-->
      <xsl:if test="@unit">
         <xsl:message>The @unit attribute may be unnecessary when @unitRef is present. (@unit / info)</xsl:message>
      </xsl:if>
      <xsl:apply-templates select="*" mode="M11"/>
   </xsl:template>
   <xsl:template match="text()" priority="-1" mode="M11"/>
   <xsl:template match="@*|node()" priority="-2" mode="M11">
      <xsl:apply-templates select="*" mode="M11"/>
   </xsl:template>
   <!--PATTERN schematron-constraint-tei_speech-att.typed-subtypeTyped-6-->
   <!--RULE -->
   <xsl:template match="tei:*[@subtype]" priority="1000" mode="M12">

		<!--ASSERT -->
      <xsl:choose>
         <xsl:when test="@type"/>
         <xsl:otherwise>
            <xsl:message>The <xsl:text/>
               <xsl:value-of select="name(.)"/>
               <xsl:text/> element should not be categorized in detail with @subtype unless also categorized in general with @type (@type)</xsl:message>
         </xsl:otherwise>
      </xsl:choose>
      <xsl:apply-templates select="*" mode="M12"/>
   </xsl:template>
   <xsl:template match="text()" priority="-1" mode="M12"/>
   <xsl:template match="@*|node()" priority="-2" mode="M12">
      <xsl:apply-templates select="*" mode="M12"/>
   </xsl:template>
   <!--PATTERN schematron-constraint-tei_speech-att.pointing-targetLang-targetLang-7-->
   <!--RULE -->
   <xsl:template match="tei:*[not(self::tei:schemaSpec)][@targetLang]"
                 priority="1000"
                 mode="M13">

		<!--ASSERT -->
      <xsl:choose>
         <xsl:when test="@target"/>
         <xsl:otherwise>
            <xsl:message>@targetLang should only be used on <xsl:text/>
               <xsl:value-of select="name(.)"/>
               <xsl:text/> if @target is specified. (@target)</xsl:message>
         </xsl:otherwise>
      </xsl:choose>
      <xsl:apply-templates select="*" mode="M13"/>
   </xsl:template>
   <xsl:template match="text()" priority="-1" mode="M13"/>
   <xsl:template match="@*|node()" priority="-2" mode="M13">
      <xsl:apply-templates select="*" mode="M13"/>
   </xsl:template>
   <!--PATTERN schematron-constraint-tei_speech-att.spanning-spanTo-spanTo-points-to-following-8-->
   <!--RULE -->
   <xsl:template match="tei:*[@spanTo]" priority="1000" mode="M14">

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
      <xsl:apply-templates select="*" mode="M14"/>
   </xsl:template>
   <xsl:template match="text()" priority="-1" mode="M14"/>
   <xsl:template match="@*|node()" priority="-2" mode="M14">
      <xsl:apply-templates select="*" mode="M14"/>
   </xsl:template>
   <!--PATTERN schematron-constraint-tei_speech-att.styleDef-schemeVersion-schemeVersionRequiresScheme-9-->
   <!--RULE -->
   <xsl:template match="tei:*[@schemeVersion]" priority="1000" mode="M15">

		<!--ASSERT -->
      <xsl:choose>
         <xsl:when test="@scheme and not(@scheme = 'free')"/>
         <xsl:otherwise>
            <xsl:message>
              @schemeVersion can only be used if @scheme is specified.
             (@scheme and not(@scheme = 'free'))</xsl:message>
         </xsl:otherwise>
      </xsl:choose>
      <xsl:apply-templates select="*" mode="M15"/>
   </xsl:template>
   <xsl:template match="text()" priority="-1" mode="M15"/>
   <xsl:template match="@*|node()" priority="-2" mode="M15">
      <xsl:apply-templates select="*" mode="M15"/>
   </xsl:template>
   <!--PATTERN schematron-constraint-tei_speech-att.calendarSystem-calendar-calendar-10-->
   <!--RULE -->
   <xsl:template match="tei:*[@calendar]" priority="1000" mode="M16">

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
      <xsl:apply-templates select="*" mode="M16"/>
   </xsl:template>
   <xsl:template match="text()" priority="-1" mode="M16"/>
   <xsl:template match="@*|node()" priority="-2" mode="M16">
      <xsl:apply-templates select="*" mode="M16"/>
   </xsl:template>
   <!--PATTERN schematron-constraint-tei_speech-p-abstractModel-structure-p-in-ab-or-p-11-->
   <!--RULE -->
   <xsl:template match="tei:p" priority="1000" mode="M17">

		<!--REPORT -->
      <xsl:if test="(ancestor::tei:ab or ancestor::tei:p) and not( ancestor::tei:floatingText |parent::tei:exemplum |parent::tei:item |parent::tei:note |parent::tei:q |parent::tei:quote |parent::tei:remarks |parent::tei:said |parent::tei:sp |parent::tei:stage |parent::tei:cell |parent::tei:figure )">
         <xsl:message>
        Abstract model violation: Paragraphs may not occur inside other paragraphs or ab elements.
       ((ancestor::tei:ab or ancestor::tei:p) and not( ancestor::tei:floatingText |parent::tei:exemplum |parent::tei:item |parent::tei:note |parent::tei:q |parent::tei:quote |parent::tei:remarks |parent::tei:said |parent::tei:sp |parent::tei:stage |parent::tei:cell |parent::tei:figure ))</xsl:message>
      </xsl:if>
      <xsl:apply-templates select="*" mode="M17"/>
   </xsl:template>
   <xsl:template match="text()" priority="-1" mode="M17"/>
   <xsl:template match="@*|node()" priority="-2" mode="M17">
      <xsl:apply-templates select="*" mode="M17"/>
   </xsl:template>
   <!--PATTERN schematron-constraint-tei_speech-p-abstractModel-structure-p-in-l-or-lg-12-->
   <!--RULE -->
   <xsl:template match="tei:p" priority="1000" mode="M18">

		<!--REPORT -->
      <xsl:if test="(ancestor::tei:l or ancestor::tei:lg) and not( ancestor::tei:floatingText |parent::tei:figure |parent::tei:note )">
         <xsl:message>
        Abstract model violation: Lines may not contain higher-level structural elements such as div, p, or ab, unless p is a child of figure or note, or is a descendant of floatingText.
       ((ancestor::tei:l or ancestor::tei:lg) and not( ancestor::tei:floatingText |parent::tei:figure |parent::tei:note ))</xsl:message>
      </xsl:if>
      <xsl:apply-templates select="*" mode="M18"/>
   </xsl:template>
   <xsl:template match="text()" priority="-1" mode="M18"/>
   <xsl:template match="@*|node()" priority="-2" mode="M18">
      <xsl:apply-templates select="*" mode="M18"/>
   </xsl:template>
   <!--PATTERN schematron-constraint-tei_speech-desc-deprecationInfo-only-in-deprecated-13-->
   <!--RULE -->
   <xsl:template match="tei:desc[ @type eq 'deprecationInfo']"
                 priority="1000"
                 mode="M19">

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
      <xsl:apply-templates select="*" mode="M19"/>
   </xsl:template>
   <xsl:template match="text()" priority="-1" mode="M19"/>
   <xsl:template match="@*|node()" priority="-2" mode="M19">
      <xsl:apply-templates select="*" mode="M19"/>
   </xsl:template>
   <!--PATTERN schematron-constraint-tei_speech-rt-target-rt-target-not-span-14-->
   <!--RULE -->
   <xsl:template match="tei:rt/@target" priority="1000" mode="M20">

		<!--REPORT -->
      <xsl:if test="../@from | ../@to">
         <xsl:message>When target= is
            present, neither from= nor to= should be. (../@from | ../@to)</xsl:message>
      </xsl:if>
   </xsl:template>
   <xsl:template match="text()" priority="-1" mode="M20"/>
   <xsl:template match="@*|node()" priority="-2" mode="M20">
      <xsl:apply-templates select="*" mode="M20"/>
   </xsl:template>
   <!--PATTERN schematron-constraint-tei_speech-rt-from-rt-from-15-->
   <!--RULE -->
   <xsl:template match="tei:rt/@from" priority="1000" mode="M21">

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
   <xsl:template match="text()" priority="-1" mode="M21"/>
   <xsl:template match="@*|node()" priority="-2" mode="M21">
      <xsl:apply-templates select="*" mode="M21"/>
   </xsl:template>
   <!--PATTERN schematron-constraint-tei_speech-rt-to-rt-to-16-->
   <!--RULE -->
   <xsl:template match="tei:rt/@to" priority="1000" mode="M22">

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
   <xsl:template match="text()" priority="-1" mode="M22"/>
   <xsl:template match="@*|node()" priority="-2" mode="M22">
      <xsl:apply-templates select="*" mode="M22"/>
   </xsl:template>
   <!--PATTERN schematron-constraint-tei_speech-name-calendar-calendar-check-name-17-->
   <!--RULE -->
   <xsl:template match="tei:*[@calendar]" priority="1000" mode="M23">

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
      <xsl:apply-templates select="*" mode="M23"/>
   </xsl:template>
   <xsl:template match="text()" priority="-1" mode="M23"/>
   <xsl:template match="@*|node()" priority="-2" mode="M23">
      <xsl:apply-templates select="*" mode="M23"/>
   </xsl:template>
   <!--PATTERN schematron-constraint-tei_speech-ptr-ptrAtts-18-->
   <!--RULE -->
   <xsl:template match="tei:ptr" priority="1000" mode="M24">

		<!--REPORT -->
      <xsl:if test="@target and @cRef">
         <xsl:message>Only one of the
attributes @target and @cRef may be supplied on <xsl:text/>
            <xsl:value-of select="name(.)"/>
            <xsl:text/>. (@target and @cRef)</xsl:message>
      </xsl:if>
      <xsl:apply-templates select="*" mode="M24"/>
   </xsl:template>
   <xsl:template match="text()" priority="-1" mode="M24"/>
   <xsl:template match="@*|node()" priority="-2" mode="M24">
      <xsl:apply-templates select="*" mode="M24"/>
   </xsl:template>
   <!--PATTERN schematron-constraint-tei_speech-ref-refAtts-19-->
   <!--RULE -->
   <xsl:template match="tei:ref" priority="1000" mode="M25">

		<!--REPORT -->
      <xsl:if test="@target and @cRef">
         <xsl:message>Only one of the
	attributes @target' and @cRef' may be supplied on <xsl:text/>
            <xsl:value-of select="name(.)"/>
            <xsl:text/>
          (@target and @cRef)</xsl:message>
      </xsl:if>
      <xsl:apply-templates select="*" mode="M25"/>
   </xsl:template>
   <xsl:template match="text()" priority="-1" mode="M25"/>
   <xsl:template match="@*|node()" priority="-2" mode="M25">
      <xsl:apply-templates select="*" mode="M25"/>
   </xsl:template>
   <!--PATTERN schematron-constraint-tei_speech-list-gloss-list-must-have-labels-20-->
   <!--RULE -->
   <xsl:template match="tei:list[@type='gloss']" priority="1000" mode="M26">

		<!--ASSERT -->
      <xsl:choose>
         <xsl:when test="tei:label"/>
         <xsl:otherwise>
            <xsl:message>The content of a "gloss" list should include a sequence of one or more pairs of a label element followed by an item element (tei:label)</xsl:message>
         </xsl:otherwise>
      </xsl:choose>
      <xsl:apply-templates select="*" mode="M26"/>
   </xsl:template>
   <xsl:template match="text()" priority="-1" mode="M26"/>
   <xsl:template match="@*|node()" priority="-2" mode="M26">
      <xsl:apply-templates select="*" mode="M26"/>
   </xsl:template>
   <!--PATTERN schematron-constraint-tei_speech-author-calendar-calendar-check-author-21-->
   <!--RULE -->
   <xsl:template match="tei:*[@calendar]" priority="1000" mode="M27">

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
      <xsl:apply-templates select="*" mode="M27"/>
   </xsl:template>
   <xsl:template match="text()" priority="-1" mode="M27"/>
   <xsl:template match="@*|node()" priority="-2" mode="M27">
      <xsl:apply-templates select="*" mode="M27"/>
   </xsl:template>
   <!--PATTERN schematron-constraint-tei_speech-editor-calendar-calendar-check-editor-22-->
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
   <!--PATTERN schematron-constraint-tei_speech-resp-calendar-calendar-check-resp-23-->
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
   <!--PATTERN schematron-constraint-tei_speech-title-calendar-calendar-check-title-24-->
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
   <!--PATTERN schematron-constraint-tei_speech-meeting-calendar-calendar-check-meeting-25-->
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
   <!--PATTERN schematron-constraint-tei_speech-relatedItem-targetorcontent1-26-->
   <!--RULE -->
   <xsl:template match="tei:relatedItem" priority="1000" mode="M32">

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
      <xsl:apply-templates select="*" mode="M32"/>
   </xsl:template>
   <xsl:template match="text()" priority="-1" mode="M32"/>
   <xsl:template match="@*|node()" priority="-2" mode="M32">
      <xsl:apply-templates select="*" mode="M32"/>
   </xsl:template>
   <!--PATTERN schematron-constraint-tei_speech-l-abstractModel-structure-l-in-l-27-->
   <!--RULE -->
   <xsl:template match="tei:l" priority="1000" mode="M33">

		<!--REPORT -->
      <xsl:if test="ancestor::tei:l[not(.//tei:note//tei:l[. = current()])]">
         <xsl:message>
        Abstract model violation: Lines may not contain lines or lg elements.
       (ancestor::tei:l[not(.//tei:note//tei:l[. = current()])])</xsl:message>
      </xsl:if>
      <xsl:apply-templates select="*" mode="M33"/>
   </xsl:template>
   <xsl:template match="text()" priority="-1" mode="M33"/>
   <xsl:template match="@*|node()" priority="-2" mode="M33">
      <xsl:apply-templates select="*" mode="M33"/>
   </xsl:template>
   <!--PATTERN schematron-constraint-tei_speech-lg-atleast1oflggapl-28-->
   <!--RULE -->
   <xsl:template match="tei:lg" priority="1000" mode="M34">

		<!--ASSERT -->
      <xsl:choose>
         <xsl:when test="count(descendant::tei:lg|descendant::tei:l|descendant::tei:gap) &gt; 0"/>
         <xsl:otherwise>
            <xsl:message>An lg element
        must contain at least one child l, lg, or gap element. (count(descendant::tei:lg|descendant::tei:l|descendant::tei:gap) &gt; 0)</xsl:message>
         </xsl:otherwise>
      </xsl:choose>
      <xsl:apply-templates select="*" mode="M34"/>
   </xsl:template>
   <xsl:template match="text()" priority="-1" mode="M34"/>
   <xsl:template match="@*|node()" priority="-2" mode="M34">
      <xsl:apply-templates select="*" mode="M34"/>
   </xsl:template>
   <!--PATTERN schematron-constraint-tei_speech-lg-abstractModel-structure-lg-in-l-29-->
   <!--RULE -->
   <xsl:template match="tei:lg" priority="1000" mode="M35">

		<!--REPORT -->
      <xsl:if test="ancestor::tei:l[not(.//tei:note//tei:lg[. = current()])]">
         <xsl:message>
        Abstract model violation: Lines may not contain line groups.
       (ancestor::tei:l[not(.//tei:note//tei:lg[. = current()])])</xsl:message>
      </xsl:if>
      <xsl:apply-templates select="*" mode="M35"/>
   </xsl:template>
   <xsl:template match="text()" priority="-1" mode="M35"/>
   <xsl:template match="@*|node()" priority="-2" mode="M35">
      <xsl:apply-templates select="*" mode="M35"/>
   </xsl:template>
   <!--PATTERN schematron-constraint-tei_speech-sponsor-calendar-calendar-check-sponsor-30-->
   <!--RULE -->
   <xsl:template match="tei:*[@calendar]" priority="1000" mode="M36">

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
      <xsl:apply-templates select="*" mode="M36"/>
   </xsl:template>
   <xsl:template match="text()" priority="-1" mode="M36"/>
   <xsl:template match="@*|node()" priority="-2" mode="M36">
      <xsl:apply-templates select="*" mode="M36"/>
   </xsl:template>
   <!--PATTERN schematron-constraint-tei_speech-funder-calendar-calendar-check-funder-31-->
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
   <!--PATTERN schematron-constraint-tei_speech-principal-calendar-calendar-check-principal-32-->
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
   <!--PATTERN schematron-constraint-tei_speech-idno-calendar-calendar-check-idno-33-->
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
   <!--PATTERN schematron-constraint-tei_speech-licence-calendar-calendar-check-licence-34-->
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
   <!--PATTERN schematron-constraint-tei_speech-quotation-quotationContents-35-->
   <!--RULE -->
   <xsl:template match="tei:quotation" priority="1000" mode="M41">

		<!--REPORT -->
      <xsl:if test="not(@marks) and not (tei:p)">
         <xsl:message>
On <xsl:text/>
            <xsl:value-of select="name(.)"/>
            <xsl:text/>, either the @marks attribute should be used, or a paragraph of description provided (not(@marks) and not (tei:p))</xsl:message>
      </xsl:if>
      <xsl:apply-templates select="*" mode="M41"/>
   </xsl:template>
   <xsl:template match="text()" priority="-1" mode="M41"/>
   <xsl:template match="@*|node()" priority="-2" mode="M41">
      <xsl:apply-templates select="*" mode="M41"/>
   </xsl:template>
   <!--PATTERN schematron-constraint-tei_speech-citeStructure-match-citestructure-outer-match-36-->
   <!--RULE -->
   <xsl:template match="tei:citeStructure[not(parent::tei:citeStructure)]"
                 priority="1000"
                 mode="M42">

		<!--ASSERT -->
      <xsl:choose>
         <xsl:when test="starts-with(@match,'/')"/>
         <xsl:otherwise>
            <xsl:message>An XPath in @match on the outer <xsl:text/>
               <xsl:value-of select="name(.)"/>
               <xsl:text/> must start with '/'. (starts-with(@match,'/'))</xsl:message>
         </xsl:otherwise>
      </xsl:choose>
      <xsl:apply-templates select="*" mode="M42"/>
   </xsl:template>
   <xsl:template match="text()" priority="-1" mode="M42"/>
   <xsl:template match="@*|node()" priority="-2" mode="M42">
      <xsl:apply-templates select="*" mode="M42"/>
   </xsl:template>
   <!--PATTERN schematron-constraint-tei_speech-citeStructure-match-citestructure-inner-match-37-->
   <!--RULE -->
   <xsl:template match="tei:citeStructure[parent::tei:citeStructure]"
                 priority="1000"
                 mode="M43">

		<!--ASSERT -->
      <xsl:choose>
         <xsl:when test="not(starts-with(@match,'/'))"/>
         <xsl:otherwise>
            <xsl:message>An XPath in @match must not start with '/' except on the outer <xsl:text/>
               <xsl:value-of select="name(.)"/>
               <xsl:text/>. (not(starts-with(@match,'/')))</xsl:message>
         </xsl:otherwise>
      </xsl:choose>
      <xsl:apply-templates select="*" mode="M43"/>
   </xsl:template>
   <xsl:template match="text()" priority="-1" mode="M43"/>
   <xsl:template match="@*|node()" priority="-2" mode="M43">
      <xsl:apply-templates select="*" mode="M43"/>
   </xsl:template>
   <!--PATTERN schematron-constraint-tei_speech-unitDecl-calendar-calendar-check-unitDecl-38-->
   <!--RULE -->
   <xsl:template match="tei:*[@calendar]" priority="1000" mode="M44">

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
      <xsl:apply-templates select="*" mode="M44"/>
   </xsl:template>
   <xsl:template match="text()" priority="-1" mode="M44"/>
   <xsl:template match="@*|node()" priority="-2" mode="M44">
      <xsl:apply-templates select="*" mode="M44"/>
   </xsl:template>
   <!--PATTERN schematron-constraint-tei_speech-unitDef-calendar-calendar-check-unitDef-39-->
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
   <!--PATTERN schematron-constraint-tei_speech-conversion-calendar-calendar-check-conversion-40-->
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
   <!--PATTERN schematron-constraint-tei_speech-application-calendar-calendar-check-application-41-->
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
   <!--PATTERN schematron-constraint-tei_speech-creation-calendar-calendar-check-creation-42-->
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
   <!--PATTERN schematron-constraint-tei_speech-change-calendar-calendar-check-change-43-->
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
   <!--PATTERN schematron-constraint-tei_speech-div-abstractModel-structure-div-in-l-or-lg-47-->
   <!--RULE -->
   <xsl:template match="tei:div" priority="1000" mode="M50">

		<!--REPORT -->
      <xsl:if test="(ancestor::tei:l or ancestor::tei:lg) and not(ancestor::tei:floatingText)">
         <xsl:message>
        Abstract model violation: Lines may not contain higher-level structural elements such as div, unless div is a descendant of floatingText.
       ((ancestor::tei:l or ancestor::tei:lg) and not(ancestor::tei:floatingText))</xsl:message>
      </xsl:if>
      <xsl:apply-templates select="*" mode="M50"/>
   </xsl:template>
   <xsl:template match="text()" priority="-1" mode="M50"/>
   <xsl:template match="@*|node()" priority="-2" mode="M50">
      <xsl:apply-templates select="*" mode="M50"/>
   </xsl:template>
   <!--PATTERN schematron-constraint-tei_speech-div-abstractModel-structure-div-in-ab-or-p-48-->
   <!--RULE -->
   <xsl:template match="tei:div" priority="1000" mode="M51">

		<!--REPORT -->
      <xsl:if test="(ancestor::tei:p or ancestor::tei:ab) and not(ancestor::tei:floatingText)">
         <xsl:message>
        Abstract model violation: p and ab may not contain higher-level structural elements such as div, unless div is a descendant of floatingText.
       ((ancestor::tei:p or ancestor::tei:ab) and not(ancestor::tei:floatingText))</xsl:message>
      </xsl:if>
      <xsl:apply-templates select="*" mode="M51"/>
   </xsl:template>
   <xsl:template match="text()" priority="-1" mode="M51"/>
   <xsl:template match="@*|node()" priority="-2" mode="M51">
      <xsl:apply-templates select="*" mode="M51"/>
   </xsl:template>
   <!--PATTERN schematron-constraint-tei_speech-shift-shiftNew-49-->
   <!--RULE -->
   <xsl:template match="tei:shift" priority="1000" mode="M52">

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
      <xsl:apply-templates select="*" mode="M52"/>
   </xsl:template>
   <xsl:template match="text()" priority="-1" mode="M52"/>
   <xsl:template match="@*|node()" priority="-2" mode="M52">
      <xsl:apply-templates select="*" mode="M52"/>
   </xsl:template>
   <!--PATTERN schematron-constraint-tei_speech-orgName-calendar-calendar-check-orgName-50-->
   <!--RULE -->
   <xsl:template match="tei:*[@calendar]" priority="1000" mode="M53">

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
      <xsl:apply-templates select="*" mode="M53"/>
   </xsl:template>
   <xsl:template match="text()" priority="-1" mode="M53"/>
   <xsl:template match="@*|node()" priority="-2" mode="M53">
      <xsl:apply-templates select="*" mode="M53"/>
   </xsl:template>
   <!--PATTERN schematron-constraint-tei_speech-persName-calendar-calendar-check-persName-51-->
   <!--RULE -->
   <xsl:template match="tei:*[@calendar]" priority="1000" mode="M54">

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
      <xsl:apply-templates select="*" mode="M54"/>
   </xsl:template>
   <xsl:template match="text()" priority="-1" mode="M54"/>
   <xsl:template match="@*|node()" priority="-2" mode="M54">
      <xsl:apply-templates select="*" mode="M54"/>
   </xsl:template>
   <!--PATTERN schematron-constraint-tei_speech-placeName-calendar-calendar-check-placeName-52-->
   <!--RULE -->
   <xsl:template match="tei:*[@calendar]" priority="1000" mode="M55">

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
      <xsl:apply-templates select="*" mode="M55"/>
   </xsl:template>
   <xsl:template match="text()" priority="-1" mode="M55"/>
   <xsl:template match="@*|node()" priority="-2" mode="M55">
      <xsl:apply-templates select="*" mode="M55"/>
   </xsl:template>
   <!--PATTERN schematron-constraint-tei_speech-bloc-calendar-calendar-check-bloc-53-->
   <!--RULE -->
   <xsl:template match="tei:*[@calendar]" priority="1000" mode="M56">

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
      <xsl:apply-templates select="*" mode="M56"/>
   </xsl:template>
   <xsl:template match="text()" priority="-1" mode="M56"/>
   <xsl:template match="@*|node()" priority="-2" mode="M56">
      <xsl:apply-templates select="*" mode="M56"/>
   </xsl:template>
   <!--PATTERN schematron-constraint-tei_speech-country-calendar-calendar-check-country-54-->
   <!--RULE -->
   <xsl:template match="tei:*[@calendar]" priority="1000" mode="M57">

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
      <xsl:apply-templates select="*" mode="M57"/>
   </xsl:template>
   <xsl:template match="text()" priority="-1" mode="M57"/>
   <xsl:template match="@*|node()" priority="-2" mode="M57">
      <xsl:apply-templates select="*" mode="M57"/>
   </xsl:template>
   <!--PATTERN schematron-constraint-tei_speech-region-calendar-calendar-check-region-55-->
   <!--RULE -->
   <xsl:template match="tei:*[@calendar]" priority="1000" mode="M58">

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
      <xsl:apply-templates select="*" mode="M58"/>
   </xsl:template>
   <xsl:template match="text()" priority="-1" mode="M58"/>
   <xsl:template match="@*|node()" priority="-2" mode="M58">
      <xsl:apply-templates select="*" mode="M58"/>
   </xsl:template>
   <!--PATTERN schematron-constraint-tei_speech-settlement-calendar-calendar-check-settlement-56-->
   <!--RULE -->
   <xsl:template match="tei:*[@calendar]" priority="1000" mode="M59">

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
      <xsl:apply-templates select="*" mode="M59"/>
   </xsl:template>
   <xsl:template match="text()" priority="-1" mode="M59"/>
   <xsl:template match="@*|node()" priority="-2" mode="M59">
      <xsl:apply-templates select="*" mode="M59"/>
   </xsl:template>
   <!--PATTERN schematron-constraint-tei_speech-district-calendar-calendar-check-district-57-->
   <!--RULE -->
   <xsl:template match="tei:*[@calendar]" priority="1000" mode="M60">

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
      <xsl:apply-templates select="*" mode="M60"/>
   </xsl:template>
   <xsl:template match="text()" priority="-1" mode="M60"/>
   <xsl:template match="@*|node()" priority="-2" mode="M60">
      <xsl:apply-templates select="*" mode="M60"/>
   </xsl:template>
   <!--PATTERN schematron-constraint-tei_speech-offset-calendar-calendar-check-offset-58-->
   <!--RULE -->
   <xsl:template match="tei:*[@calendar]" priority="1000" mode="M61">

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
      <xsl:apply-templates select="*" mode="M61"/>
   </xsl:template>
   <xsl:template match="text()" priority="-1" mode="M61"/>
   <xsl:template match="@*|node()" priority="-2" mode="M61">
      <xsl:apply-templates select="*" mode="M61"/>
   </xsl:template>
   <!--PATTERN schematron-constraint-tei_speech-geogName-calendar-calendar-check-geogName-59-->
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
   <!--PATTERN schematron-constraint-tei_speech-geogFeat-calendar-calendar-check-geogFeat-60-->
   <!--RULE -->
   <xsl:template match="tei:*[@calendar]" priority="1000" mode="M63">

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
      <xsl:apply-templates select="*" mode="M63"/>
   </xsl:template>
   <xsl:template match="text()" priority="-1" mode="M63"/>
   <xsl:template match="@*|node()" priority="-2" mode="M63">
      <xsl:apply-templates select="*" mode="M63"/>
   </xsl:template>
   <!--PATTERN schematron-constraint-tei_speech-affiliation-calendar-calendar-check-affiliation-61-->
   <!--RULE -->
   <xsl:template match="tei:*[@calendar]" priority="1000" mode="M64">

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
      <xsl:apply-templates select="*" mode="M64"/>
   </xsl:template>
   <xsl:template match="text()" priority="-1" mode="M64"/>
   <xsl:template match="@*|node()" priority="-2" mode="M64">
      <xsl:apply-templates select="*" mode="M64"/>
   </xsl:template>
   <!--PATTERN schematron-constraint-tei_speech-age-calendar-calendar-check-age-62-->
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
   <!--PATTERN schematron-constraint-tei_speech-birth-calendar-calendar-check-birth-63-->
   <!--RULE -->
   <xsl:template match="tei:*[@calendar]" priority="1000" mode="M66">

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
      <xsl:apply-templates select="*" mode="M66"/>
   </xsl:template>
   <xsl:template match="text()" priority="-1" mode="M66"/>
   <xsl:template match="@*|node()" priority="-2" mode="M66">
      <xsl:apply-templates select="*" mode="M66"/>
   </xsl:template>
   <!--PATTERN schematron-constraint-tei_speech-climate-calendar-calendar-check-climate-64-->
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
   <!--PATTERN schematron-constraint-tei_speech-death-calendar-calendar-check-death-65-->
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
   <!--PATTERN schematron-constraint-tei_speech-education-calendar-calendar-check-education-66-->
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
   <!--PATTERN schematron-constraint-tei_speech-event-calendar-calendar-check-event-67-->
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
   <!--PATTERN schematron-constraint-tei_speech-faith-calendar-calendar-check-faith-68-->
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
   <!--PATTERN schematron-constraint-tei_speech-floruit-calendar-calendar-check-floruit-69-->
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
   <!--PATTERN schematron-constraint-tei_speech-gender-calendar-calendar-check-gender-70-->
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
   <!--PATTERN schematron-constraint-tei_speech-langKnowledge-calendar-calendar-check-langKnowledge-71-->
   <!--RULE -->
   <xsl:template match="tei:*[@calendar]" priority="1000" mode="M74">

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
      <xsl:apply-templates select="*" mode="M74"/>
   </xsl:template>
   <xsl:template match="text()" priority="-1" mode="M74"/>
   <xsl:template match="@*|node()" priority="-2" mode="M74">
      <xsl:apply-templates select="*" mode="M74"/>
   </xsl:template>
   <!--PATTERN schematron-constraint-tei_speech-langKnown-calendar-calendar-check-langKnown-72-->
   <!--RULE -->
   <xsl:template match="tei:*[@calendar]" priority="1000" mode="M75">

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
      <xsl:apply-templates select="*" mode="M75"/>
   </xsl:template>
   <xsl:template match="text()" priority="-1" mode="M75"/>
   <xsl:template match="@*|node()" priority="-2" mode="M75">
      <xsl:apply-templates select="*" mode="M75"/>
   </xsl:template>
   <!--PATTERN schematron-constraint-tei_speech-location-calendar-calendar-check-location-73-->
   <!--RULE -->
   <xsl:template match="tei:*[@calendar]" priority="1000" mode="M76">

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
      <xsl:apply-templates select="*" mode="M76"/>
   </xsl:template>
   <xsl:template match="text()" priority="-1" mode="M76"/>
   <xsl:template match="@*|node()" priority="-2" mode="M76">
      <xsl:apply-templates select="*" mode="M76"/>
   </xsl:template>
   <!--PATTERN schematron-constraint-tei_speech-nationality-calendar-calendar-check-nationality-74-->
   <!--RULE -->
   <xsl:template match="tei:*[@calendar]" priority="1000" mode="M77">

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
      <xsl:apply-templates select="*" mode="M77"/>
   </xsl:template>
   <xsl:template match="text()" priority="-1" mode="M77"/>
   <xsl:template match="@*|node()" priority="-2" mode="M77">
      <xsl:apply-templates select="*" mode="M77"/>
   </xsl:template>
   <!--PATTERN schematron-constraint-tei_speech-occupation-calendar-calendar-check-occupation-75-->
   <!--RULE -->
   <xsl:template match="tei:*[@calendar]" priority="1000" mode="M78">

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
      <xsl:apply-templates select="*" mode="M78"/>
   </xsl:template>
   <xsl:template match="text()" priority="-1" mode="M78"/>
   <xsl:template match="@*|node()" priority="-2" mode="M78">
      <xsl:apply-templates select="*" mode="M78"/>
   </xsl:template>
   <!--PATTERN schematron-constraint-tei_speech-persPronouns-calendar-calendar-check-persPronouns-76-->
   <!--RULE -->
   <xsl:template match="tei:*[@calendar]" priority="1000" mode="M79">

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
      <xsl:apply-templates select="*" mode="M79"/>
   </xsl:template>
   <xsl:template match="text()" priority="-1" mode="M79"/>
   <xsl:template match="@*|node()" priority="-2" mode="M79">
      <xsl:apply-templates select="*" mode="M79"/>
   </xsl:template>
   <!--PATTERN schematron-constraint-tei_speech-population-calendar-calendar-check-population-77-->
   <!--RULE -->
   <xsl:template match="tei:*[@calendar]" priority="1000" mode="M80">

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
      <xsl:apply-templates select="*" mode="M80"/>
   </xsl:template>
   <xsl:template match="text()" priority="-1" mode="M80"/>
   <xsl:template match="@*|node()" priority="-2" mode="M80">
      <xsl:apply-templates select="*" mode="M80"/>
   </xsl:template>
   <!--PATTERN schematron-constraint-tei_speech-relation-reforkeyorname-78-->
   <!--RULE -->
   <xsl:template match="tei:relation" priority="1000" mode="M81">

		<!--ASSERT -->
      <xsl:choose>
         <xsl:when test="@ref or @key or @name"/>
         <xsl:otherwise>
            <xsl:message>One of the attributes  'name', 'ref' or 'key' must be supplied (@ref or @key or @name)</xsl:message>
         </xsl:otherwise>
      </xsl:choose>
      <xsl:apply-templates select="*" mode="M81"/>
   </xsl:template>
   <xsl:template match="text()" priority="-1" mode="M81"/>
   <xsl:template match="@*|node()" priority="-2" mode="M81">
      <xsl:apply-templates select="*" mode="M81"/>
   </xsl:template>
   <!--PATTERN schematron-constraint-tei_speech-relation-activemutual-79-->
   <!--RULE -->
   <xsl:template match="tei:relation" priority="1000" mode="M82">

		<!--REPORT -->
      <xsl:if test="@active and @mutual">
         <xsl:message>Only one of the attributes @active and @mutual may be supplied (@active and @mutual)</xsl:message>
      </xsl:if>
      <xsl:apply-templates select="*" mode="M82"/>
   </xsl:template>
   <xsl:template match="text()" priority="-1" mode="M82"/>
   <xsl:template match="@*|node()" priority="-2" mode="M82">
      <xsl:apply-templates select="*" mode="M82"/>
   </xsl:template>
   <!--PATTERN schematron-constraint-tei_speech-relation-activepassive-80-->
   <!--RULE -->
   <xsl:template match="tei:relation" priority="1000" mode="M83">

		<!--REPORT -->
      <xsl:if test="@passive and not(@active)">
         <xsl:message>the attribute 'passive' may be supplied only if the attribute 'active' is supplied (@passive and not(@active))</xsl:message>
      </xsl:if>
      <xsl:apply-templates select="*" mode="M83"/>
   </xsl:template>
   <xsl:template match="text()" priority="-1" mode="M83"/>
   <xsl:template match="@*|node()" priority="-2" mode="M83">
      <xsl:apply-templates select="*" mode="M83"/>
   </xsl:template>
   <!--PATTERN schematron-constraint-tei_speech-relation-calendar-calendar-check-relation-81-->
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
   <!--PATTERN schematron-constraint-tei_speech-residence-calendar-calendar-check-residence-82-->
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
   <!--PATTERN schematron-constraint-tei_speech-sex-calendar-calendar-check-sex-83-->
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
   <!--PATTERN schematron-constraint-tei_speech-socecStatus-calendar-calendar-check-socecStatus-84-->
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
   <!--PATTERN schematron-constraint-tei_speech-state-calendar-calendar-check-state-85-->
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
   <!--PATTERN schematron-constraint-tei_speech-terrain-calendar-calendar-check-terrain-86-->
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
   <!--PATTERN schematron-constraint-tei_speech-trait-calendar-calendar-check-trait-87-->
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
   <!--PATTERN schematron-constraint-tei_speech-objectName-calendar-calendar-check-objectName-88-->
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
   <!--PATTERN schematron-constraint-tei_speech-link-linkTargets3-89-->
   <!--RULE -->
   <xsl:template match="tei:link" priority="1000" mode="M92">

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
      <xsl:apply-templates select="*" mode="M92"/>
   </xsl:template>
   <xsl:template match="text()" priority="-1" mode="M92"/>
   <xsl:template match="@*|node()" priority="-2" mode="M92">
      <xsl:apply-templates select="*" mode="M92"/>
   </xsl:template>
   <!--PATTERN schematron-constraint-tei_speech-ab-abstractModel-structure-ab-in-l-or-lg-90-->
   <!--RULE -->
   <xsl:template match="tei:ab" priority="1000" mode="M93">

		<!--REPORT -->
      <xsl:if test="(ancestor::tei:l or ancestor::tei:lg) and not( ancestor::tei:floatingText |parent::tei:figure |parent::tei:note )">
         <xsl:message>
        Abstract model violation: Lines may not contain higher-level divisions such as p or ab, unless ab is a child of figure or note, or is a descendant of floatingText.
       ((ancestor::tei:l or ancestor::tei:lg) and not( ancestor::tei:floatingText |parent::tei:figure |parent::tei:note ))</xsl:message>
      </xsl:if>
      <xsl:apply-templates select="*" mode="M93"/>
   </xsl:template>
   <xsl:template match="text()" priority="-1" mode="M93"/>
   <xsl:template match="@*|node()" priority="-2" mode="M93">
      <xsl:apply-templates select="*" mode="M93"/>
   </xsl:template>
   <!--PATTERN schematron-constraint-tei_speech-join-joinTargets3-91-->
   <!--RULE -->
   <xsl:template match="tei:join" priority="1000" mode="M94">

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
      <xsl:apply-templates select="*" mode="M94"/>
   </xsl:template>
   <xsl:template match="text()" priority="-1" mode="M94"/>
   <xsl:template match="@*|node()" priority="-2" mode="M94">
      <xsl:apply-templates select="*" mode="M94"/>
   </xsl:template>
   <!--PATTERN schematron-constraint-tei_speech-standOff-nested_standOff_should_be_typed-92-->
   <!--RULE -->
   <xsl:template match="tei:standOff" priority="1000" mode="M95">

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
      <xsl:apply-templates select="*" mode="M95"/>
   </xsl:template>
   <xsl:template match="text()" priority="-1" mode="M95"/>
   <xsl:template match="@*|node()" priority="-2" mode="M95">
      <xsl:apply-templates select="*" mode="M95"/>
   </xsl:template>
   <!--PATTERN -->
   <!--RULE -->
   <xsl:template match="tei:name" priority="1000" mode="M96">

		<!--REPORT nonfatal-->
      <xsl:if test="@calendar">
         <xsl:message>WARNING: use of deprecated attribute — @calendar of the name element will be removed from the TEI on 2024-11-11.
                 (@calendar / nonfatal)</xsl:message>
      </xsl:if>
      <xsl:apply-templates select="*" mode="M96"/>
   </xsl:template>
   <xsl:template match="text()" priority="-1" mode="M96"/>
   <xsl:template match="@*|node()" priority="-2" mode="M96">
      <xsl:apply-templates select="*" mode="M96"/>
   </xsl:template>
   <!--PATTERN -->
   <!--RULE -->
   <xsl:template match="tei:author" priority="1000" mode="M97">

		<!--REPORT nonfatal-->
      <xsl:if test="@calendar">
         <xsl:message>WARNING: use of deprecated attribute — @calendar of the author element will be removed from the TEI on 2024-11-11.
                 (@calendar / nonfatal)</xsl:message>
      </xsl:if>
      <xsl:apply-templates select="*" mode="M97"/>
   </xsl:template>
   <xsl:template match="text()" priority="-1" mode="M97"/>
   <xsl:template match="@*|node()" priority="-2" mode="M97">
      <xsl:apply-templates select="*" mode="M97"/>
   </xsl:template>
   <!--PATTERN -->
   <!--RULE -->
   <xsl:template match="tei:editor" priority="1000" mode="M98">

		<!--REPORT nonfatal-->
      <xsl:if test="@calendar">
         <xsl:message>WARNING: use of deprecated attribute — @calendar of the editor element will be removed from the TEI on 2024-11-11.
                 (@calendar / nonfatal)</xsl:message>
      </xsl:if>
      <xsl:apply-templates select="*" mode="M98"/>
   </xsl:template>
   <xsl:template match="text()" priority="-1" mode="M98"/>
   <xsl:template match="@*|node()" priority="-2" mode="M98">
      <xsl:apply-templates select="*" mode="M98"/>
   </xsl:template>
   <!--PATTERN -->
   <!--RULE -->
   <xsl:template match="tei:resp" priority="1000" mode="M99">

		<!--REPORT nonfatal-->
      <xsl:if test="@calendar">
         <xsl:message>WARNING: use of deprecated attribute — @calendar of the resp element will be removed from the TEI on 2024-11-11.
                 (@calendar / nonfatal)</xsl:message>
      </xsl:if>
      <xsl:apply-templates select="*" mode="M99"/>
   </xsl:template>
   <xsl:template match="text()" priority="-1" mode="M99"/>
   <xsl:template match="@*|node()" priority="-2" mode="M99">
      <xsl:apply-templates select="*" mode="M99"/>
   </xsl:template>
   <!--PATTERN -->
   <!--RULE -->
   <xsl:template match="tei:title" priority="1000" mode="M100">

		<!--REPORT nonfatal-->
      <xsl:if test="@calendar">
         <xsl:message>WARNING: use of deprecated attribute — @calendar of the title element will be removed from the TEI on 2024-11-11.
                 (@calendar / nonfatal)</xsl:message>
      </xsl:if>
      <xsl:apply-templates select="*" mode="M100"/>
   </xsl:template>
   <xsl:template match="text()" priority="-1" mode="M100"/>
   <xsl:template match="@*|node()" priority="-2" mode="M100">
      <xsl:apply-templates select="*" mode="M100"/>
   </xsl:template>
   <!--PATTERN -->
   <!--RULE -->
   <xsl:template match="tei:meeting" priority="1000" mode="M101">

		<!--REPORT nonfatal-->
      <xsl:if test="@calendar">
         <xsl:message>WARNING: use of deprecated attribute — @calendar of the meeting element will be removed from the TEI on 2024-11-11.
                 (@calendar / nonfatal)</xsl:message>
      </xsl:if>
      <xsl:apply-templates select="*" mode="M101"/>
   </xsl:template>
   <xsl:template match="text()" priority="-1" mode="M101"/>
   <xsl:template match="@*|node()" priority="-2" mode="M101">
      <xsl:apply-templates select="*" mode="M101"/>
   </xsl:template>
   <!--PATTERN -->
   <!--RULE -->
   <xsl:template match="tei:sponsor" priority="1000" mode="M102">

		<!--REPORT nonfatal-->
      <xsl:if test="@calendar">
         <xsl:message>WARNING: use of deprecated attribute — @calendar of the sponsor element will be removed from the TEI on 2024-11-11.
                 (@calendar / nonfatal)</xsl:message>
      </xsl:if>
      <xsl:apply-templates select="*" mode="M102"/>
   </xsl:template>
   <xsl:template match="text()" priority="-1" mode="M102"/>
   <xsl:template match="@*|node()" priority="-2" mode="M102">
      <xsl:apply-templates select="*" mode="M102"/>
   </xsl:template>
   <!--PATTERN -->
   <!--RULE -->
   <xsl:template match="tei:funder" priority="1000" mode="M103">

		<!--REPORT nonfatal-->
      <xsl:if test="@calendar">
         <xsl:message>WARNING: use of deprecated attribute — @calendar of the funder element will be removed from the TEI on 2024-11-11.
                 (@calendar / nonfatal)</xsl:message>
      </xsl:if>
      <xsl:apply-templates select="*" mode="M103"/>
   </xsl:template>
   <xsl:template match="text()" priority="-1" mode="M103"/>
   <xsl:template match="@*|node()" priority="-2" mode="M103">
      <xsl:apply-templates select="*" mode="M103"/>
   </xsl:template>
   <!--PATTERN -->
   <!--RULE -->
   <xsl:template match="tei:principal" priority="1000" mode="M104">

		<!--REPORT nonfatal-->
      <xsl:if test="@calendar">
         <xsl:message>WARNING: use of deprecated attribute — @calendar of the principal element will be removed from the TEI on 2024-11-11.
                 (@calendar / nonfatal)</xsl:message>
      </xsl:if>
      <xsl:apply-templates select="*" mode="M104"/>
   </xsl:template>
   <xsl:template match="text()" priority="-1" mode="M104"/>
   <xsl:template match="@*|node()" priority="-2" mode="M104">
      <xsl:apply-templates select="*" mode="M104"/>
   </xsl:template>
   <!--PATTERN -->
   <!--RULE -->
   <xsl:template match="tei:idno" priority="1000" mode="M105">

		<!--REPORT nonfatal-->
      <xsl:if test="@calendar">
         <xsl:message>WARNING: use of deprecated attribute — @calendar of the idno element will be removed from the TEI on 2024-11-11.
                 (@calendar / nonfatal)</xsl:message>
      </xsl:if>
      <xsl:apply-templates select="*" mode="M105"/>
   </xsl:template>
   <xsl:template match="text()" priority="-1" mode="M105"/>
   <xsl:template match="@*|node()" priority="-2" mode="M105">
      <xsl:apply-templates select="*" mode="M105"/>
   </xsl:template>
   <!--PATTERN -->
   <!--RULE -->
   <xsl:template match="tei:licence" priority="1000" mode="M106">

		<!--REPORT nonfatal-->
      <xsl:if test="@calendar">
         <xsl:message>WARNING: use of deprecated attribute — @calendar of the licence element will be removed from the TEI on 2024-11-11.
                 (@calendar / nonfatal)</xsl:message>
      </xsl:if>
      <xsl:apply-templates select="*" mode="M106"/>
   </xsl:template>
   <xsl:template match="text()" priority="-1" mode="M106"/>
   <xsl:template match="@*|node()" priority="-2" mode="M106">
      <xsl:apply-templates select="*" mode="M106"/>
   </xsl:template>
   <!--PATTERN -->
   <!--RULE -->
   <xsl:template match="tei:unitDecl" priority="1000" mode="M107">

		<!--REPORT nonfatal-->
      <xsl:if test="@calendar">
         <xsl:message>WARNING: use of deprecated attribute — @calendar of the unitDecl element will be removed from the TEI on 2024-11-11.
                 (@calendar / nonfatal)</xsl:message>
      </xsl:if>
      <xsl:apply-templates select="*" mode="M107"/>
   </xsl:template>
   <xsl:template match="text()" priority="-1" mode="M107"/>
   <xsl:template match="@*|node()" priority="-2" mode="M107">
      <xsl:apply-templates select="*" mode="M107"/>
   </xsl:template>
   <!--PATTERN -->
   <!--RULE -->
   <xsl:template match="tei:unitDef" priority="1000" mode="M108">

		<!--REPORT nonfatal-->
      <xsl:if test="@calendar">
         <xsl:message>WARNING: use of deprecated attribute — @calendar of the unitDef element will be removed from the TEI on 2024-11-11.
                 (@calendar / nonfatal)</xsl:message>
      </xsl:if>
      <xsl:apply-templates select="*" mode="M108"/>
   </xsl:template>
   <xsl:template match="text()" priority="-1" mode="M108"/>
   <xsl:template match="@*|node()" priority="-2" mode="M108">
      <xsl:apply-templates select="*" mode="M108"/>
   </xsl:template>
   <!--PATTERN -->
   <!--RULE -->
   <xsl:template match="tei:conversion" priority="1000" mode="M109">

		<!--REPORT nonfatal-->
      <xsl:if test="@calendar">
         <xsl:message>WARNING: use of deprecated attribute — @calendar of the conversion element will be removed from the TEI on 2024-11-11.
                 (@calendar / nonfatal)</xsl:message>
      </xsl:if>
      <xsl:apply-templates select="*" mode="M109"/>
   </xsl:template>
   <xsl:template match="text()" priority="-1" mode="M109"/>
   <xsl:template match="@*|node()" priority="-2" mode="M109">
      <xsl:apply-templates select="*" mode="M109"/>
   </xsl:template>
   <!--PATTERN -->
   <!--RULE -->
   <xsl:template match="tei:application" priority="1000" mode="M110">

		<!--REPORT nonfatal-->
      <xsl:if test="@calendar">
         <xsl:message>WARNING: use of deprecated attribute — @calendar of the application element will be removed from the TEI on 2024-11-11.
                 (@calendar / nonfatal)</xsl:message>
      </xsl:if>
      <xsl:apply-templates select="*" mode="M110"/>
   </xsl:template>
   <xsl:template match="text()" priority="-1" mode="M110"/>
   <xsl:template match="@*|node()" priority="-2" mode="M110">
      <xsl:apply-templates select="*" mode="M110"/>
   </xsl:template>
   <!--PATTERN -->
   <!--RULE -->
   <xsl:template match="tei:creation" priority="1000" mode="M111">

		<!--REPORT nonfatal-->
      <xsl:if test="@calendar">
         <xsl:message>WARNING: use of deprecated attribute — @calendar of the creation element will be removed from the TEI on 2024-11-11.
                 (@calendar / nonfatal)</xsl:message>
      </xsl:if>
      <xsl:apply-templates select="*" mode="M111"/>
   </xsl:template>
   <xsl:template match="text()" priority="-1" mode="M111"/>
   <xsl:template match="@*|node()" priority="-2" mode="M111">
      <xsl:apply-templates select="*" mode="M111"/>
   </xsl:template>
   <!--PATTERN -->
   <!--RULE -->
   <xsl:template match="tei:change" priority="1000" mode="M112">

		<!--REPORT nonfatal-->
      <xsl:if test="@calendar">
         <xsl:message>WARNING: use of deprecated attribute — @calendar of the change element will be removed from the TEI on 2024-11-11.
                 (@calendar / nonfatal)</xsl:message>
      </xsl:if>
      <xsl:apply-templates select="*" mode="M112"/>
   </xsl:template>
   <xsl:template match="text()" priority="-1" mode="M112"/>
   <xsl:template match="@*|node()" priority="-2" mode="M112">
      <xsl:apply-templates select="*" mode="M112"/>
   </xsl:template>
   <!--PATTERN -->
   <!--RULE -->
   <xsl:template match="tei:orgName" priority="1000" mode="M113">

		<!--REPORT nonfatal-->
      <xsl:if test="@calendar">
         <xsl:message>WARNING: use of deprecated attribute — @calendar of the orgName element will be removed from the TEI on 2024-11-11.
                 (@calendar / nonfatal)</xsl:message>
      </xsl:if>
      <xsl:apply-templates select="*" mode="M113"/>
   </xsl:template>
   <xsl:template match="text()" priority="-1" mode="M113"/>
   <xsl:template match="@*|node()" priority="-2" mode="M113">
      <xsl:apply-templates select="*" mode="M113"/>
   </xsl:template>
   <!--PATTERN -->
   <!--RULE -->
   <xsl:template match="tei:persName" priority="1000" mode="M114">

		<!--REPORT nonfatal-->
      <xsl:if test="@calendar">
         <xsl:message>WARNING: use of deprecated attribute — @calendar of the persName element will be removed from the TEI on 2024-11-11.
                 (@calendar / nonfatal)</xsl:message>
      </xsl:if>
      <xsl:apply-templates select="*" mode="M114"/>
   </xsl:template>
   <xsl:template match="text()" priority="-1" mode="M114"/>
   <xsl:template match="@*|node()" priority="-2" mode="M114">
      <xsl:apply-templates select="*" mode="M114"/>
   </xsl:template>
   <!--PATTERN -->
   <!--RULE -->
   <xsl:template match="tei:placeName" priority="1000" mode="M115">

		<!--REPORT nonfatal-->
      <xsl:if test="@calendar">
         <xsl:message>WARNING: use of deprecated attribute — @calendar of the placeName element will be removed from the TEI on 2024-11-11.
                 (@calendar / nonfatal)</xsl:message>
      </xsl:if>
      <xsl:apply-templates select="*" mode="M115"/>
   </xsl:template>
   <xsl:template match="text()" priority="-1" mode="M115"/>
   <xsl:template match="@*|node()" priority="-2" mode="M115">
      <xsl:apply-templates select="*" mode="M115"/>
   </xsl:template>
   <!--PATTERN -->
   <!--RULE -->
   <xsl:template match="tei:bloc" priority="1000" mode="M116">

		<!--REPORT nonfatal-->
      <xsl:if test="@calendar">
         <xsl:message>WARNING: use of deprecated attribute — @calendar of the bloc element will be removed from the TEI on 2024-11-11.
                 (@calendar / nonfatal)</xsl:message>
      </xsl:if>
      <xsl:apply-templates select="*" mode="M116"/>
   </xsl:template>
   <xsl:template match="text()" priority="-1" mode="M116"/>
   <xsl:template match="@*|node()" priority="-2" mode="M116">
      <xsl:apply-templates select="*" mode="M116"/>
   </xsl:template>
   <!--PATTERN -->
   <!--RULE -->
   <xsl:template match="tei:country" priority="1000" mode="M117">

		<!--REPORT nonfatal-->
      <xsl:if test="@calendar">
         <xsl:message>WARNING: use of deprecated attribute — @calendar of the country element will be removed from the TEI on 2024-11-11.
                 (@calendar / nonfatal)</xsl:message>
      </xsl:if>
      <xsl:apply-templates select="*" mode="M117"/>
   </xsl:template>
   <xsl:template match="text()" priority="-1" mode="M117"/>
   <xsl:template match="@*|node()" priority="-2" mode="M117">
      <xsl:apply-templates select="*" mode="M117"/>
   </xsl:template>
   <!--PATTERN -->
   <!--RULE -->
   <xsl:template match="tei:region" priority="1000" mode="M118">

		<!--REPORT nonfatal-->
      <xsl:if test="@calendar">
         <xsl:message>WARNING: use of deprecated attribute — @calendar of the region element will be removed from the TEI on 2024-11-11.
                 (@calendar / nonfatal)</xsl:message>
      </xsl:if>
      <xsl:apply-templates select="*" mode="M118"/>
   </xsl:template>
   <xsl:template match="text()" priority="-1" mode="M118"/>
   <xsl:template match="@*|node()" priority="-2" mode="M118">
      <xsl:apply-templates select="*" mode="M118"/>
   </xsl:template>
   <!--PATTERN -->
   <!--RULE -->
   <xsl:template match="tei:settlement" priority="1000" mode="M119">

		<!--REPORT nonfatal-->
      <xsl:if test="@calendar">
         <xsl:message>WARNING: use of deprecated attribute — @calendar of the settlement element will be removed from the TEI on 2024-11-11.
                 (@calendar / nonfatal)</xsl:message>
      </xsl:if>
      <xsl:apply-templates select="*" mode="M119"/>
   </xsl:template>
   <xsl:template match="text()" priority="-1" mode="M119"/>
   <xsl:template match="@*|node()" priority="-2" mode="M119">
      <xsl:apply-templates select="*" mode="M119"/>
   </xsl:template>
   <!--PATTERN -->
   <!--RULE -->
   <xsl:template match="tei:district" priority="1000" mode="M120">

		<!--REPORT nonfatal-->
      <xsl:if test="@calendar">
         <xsl:message>WARNING: use of deprecated attribute — @calendar of the district element will be removed from the TEI on 2024-11-11.
                 (@calendar / nonfatal)</xsl:message>
      </xsl:if>
      <xsl:apply-templates select="*" mode="M120"/>
   </xsl:template>
   <xsl:template match="text()" priority="-1" mode="M120"/>
   <xsl:template match="@*|node()" priority="-2" mode="M120">
      <xsl:apply-templates select="*" mode="M120"/>
   </xsl:template>
   <!--PATTERN -->
   <!--RULE -->
   <xsl:template match="tei:offset" priority="1000" mode="M121">

		<!--REPORT nonfatal-->
      <xsl:if test="@calendar">
         <xsl:message>WARNING: use of deprecated attribute — @calendar of the offset element will be removed from the TEI on 2024-11-11.
                 (@calendar / nonfatal)</xsl:message>
      </xsl:if>
      <xsl:apply-templates select="*" mode="M121"/>
   </xsl:template>
   <xsl:template match="text()" priority="-1" mode="M121"/>
   <xsl:template match="@*|node()" priority="-2" mode="M121">
      <xsl:apply-templates select="*" mode="M121"/>
   </xsl:template>
   <!--PATTERN -->
   <!--RULE -->
   <xsl:template match="tei:geogName" priority="1000" mode="M122">

		<!--REPORT nonfatal-->
      <xsl:if test="@calendar">
         <xsl:message>WARNING: use of deprecated attribute — @calendar of the geogName element will be removed from the TEI on 2024-11-11.
                 (@calendar / nonfatal)</xsl:message>
      </xsl:if>
      <xsl:apply-templates select="*" mode="M122"/>
   </xsl:template>
   <xsl:template match="text()" priority="-1" mode="M122"/>
   <xsl:template match="@*|node()" priority="-2" mode="M122">
      <xsl:apply-templates select="*" mode="M122"/>
   </xsl:template>
   <!--PATTERN -->
   <!--RULE -->
   <xsl:template match="tei:geogFeat" priority="1000" mode="M123">

		<!--REPORT nonfatal-->
      <xsl:if test="@calendar">
         <xsl:message>WARNING: use of deprecated attribute — @calendar of the geogFeat element will be removed from the TEI on 2024-11-11.
                 (@calendar / nonfatal)</xsl:message>
      </xsl:if>
      <xsl:apply-templates select="*" mode="M123"/>
   </xsl:template>
   <xsl:template match="text()" priority="-1" mode="M123"/>
   <xsl:template match="@*|node()" priority="-2" mode="M123">
      <xsl:apply-templates select="*" mode="M123"/>
   </xsl:template>
   <!--PATTERN -->
   <!--RULE -->
   <xsl:template match="tei:affiliation" priority="1000" mode="M124">

		<!--REPORT nonfatal-->
      <xsl:if test="@calendar">
         <xsl:message>WARNING: use of deprecated attribute — @calendar of the affiliation element will be removed from the TEI on 2024-11-11.
                 (@calendar / nonfatal)</xsl:message>
      </xsl:if>
      <xsl:apply-templates select="*" mode="M124"/>
   </xsl:template>
   <xsl:template match="text()" priority="-1" mode="M124"/>
   <xsl:template match="@*|node()" priority="-2" mode="M124">
      <xsl:apply-templates select="*" mode="M124"/>
   </xsl:template>
   <!--PATTERN -->
   <!--RULE -->
   <xsl:template match="tei:age" priority="1000" mode="M125">

		<!--REPORT nonfatal-->
      <xsl:if test="@calendar">
         <xsl:message>WARNING: use of deprecated attribute — @calendar of the age element will be removed from the TEI on 2024-11-11.
                 (@calendar / nonfatal)</xsl:message>
      </xsl:if>
      <xsl:apply-templates select="*" mode="M125"/>
   </xsl:template>
   <xsl:template match="text()" priority="-1" mode="M125"/>
   <xsl:template match="@*|node()" priority="-2" mode="M125">
      <xsl:apply-templates select="*" mode="M125"/>
   </xsl:template>
   <!--PATTERN -->
   <!--RULE -->
   <xsl:template match="tei:birth" priority="1000" mode="M126">

		<!--REPORT nonfatal-->
      <xsl:if test="@calendar">
         <xsl:message>WARNING: use of deprecated attribute — @calendar of the birth element will be removed from the TEI on 2024-11-11.
                 (@calendar / nonfatal)</xsl:message>
      </xsl:if>
      <xsl:apply-templates select="*" mode="M126"/>
   </xsl:template>
   <xsl:template match="text()" priority="-1" mode="M126"/>
   <xsl:template match="@*|node()" priority="-2" mode="M126">
      <xsl:apply-templates select="*" mode="M126"/>
   </xsl:template>
   <!--PATTERN -->
   <!--RULE -->
   <xsl:template match="tei:climate" priority="1000" mode="M127">

		<!--REPORT nonfatal-->
      <xsl:if test="@calendar">
         <xsl:message>WARNING: use of deprecated attribute — @calendar of the climate element will be removed from the TEI on 2024-11-11.
                 (@calendar / nonfatal)</xsl:message>
      </xsl:if>
      <xsl:apply-templates select="*" mode="M127"/>
   </xsl:template>
   <xsl:template match="text()" priority="-1" mode="M127"/>
   <xsl:template match="@*|node()" priority="-2" mode="M127">
      <xsl:apply-templates select="*" mode="M127"/>
   </xsl:template>
   <!--PATTERN -->
   <!--RULE -->
   <xsl:template match="tei:death" priority="1000" mode="M128">

		<!--REPORT nonfatal-->
      <xsl:if test="@calendar">
         <xsl:message>WARNING: use of deprecated attribute — @calendar of the death element will be removed from the TEI on 2024-11-11.
                 (@calendar / nonfatal)</xsl:message>
      </xsl:if>
      <xsl:apply-templates select="*" mode="M128"/>
   </xsl:template>
   <xsl:template match="text()" priority="-1" mode="M128"/>
   <xsl:template match="@*|node()" priority="-2" mode="M128">
      <xsl:apply-templates select="*" mode="M128"/>
   </xsl:template>
   <!--PATTERN -->
   <!--RULE -->
   <xsl:template match="tei:education" priority="1000" mode="M129">

		<!--REPORT nonfatal-->
      <xsl:if test="@calendar">
         <xsl:message>WARNING: use of deprecated attribute — @calendar of the education element will be removed from the TEI on 2024-11-11.
                 (@calendar / nonfatal)</xsl:message>
      </xsl:if>
      <xsl:apply-templates select="*" mode="M129"/>
   </xsl:template>
   <xsl:template match="text()" priority="-1" mode="M129"/>
   <xsl:template match="@*|node()" priority="-2" mode="M129">
      <xsl:apply-templates select="*" mode="M129"/>
   </xsl:template>
   <!--PATTERN -->
   <!--RULE -->
   <xsl:template match="tei:event" priority="1000" mode="M130">

		<!--REPORT nonfatal-->
      <xsl:if test="@calendar">
         <xsl:message>WARNING: use of deprecated attribute — @calendar of the event element will be removed from the TEI on 2024-11-11.
                 (@calendar / nonfatal)</xsl:message>
      </xsl:if>
      <xsl:apply-templates select="*" mode="M130"/>
   </xsl:template>
   <xsl:template match="text()" priority="-1" mode="M130"/>
   <xsl:template match="@*|node()" priority="-2" mode="M130">
      <xsl:apply-templates select="*" mode="M130"/>
   </xsl:template>
   <!--PATTERN -->
   <!--RULE -->
   <xsl:template match="tei:faith" priority="1000" mode="M131">

		<!--REPORT nonfatal-->
      <xsl:if test="@calendar">
         <xsl:message>WARNING: use of deprecated attribute — @calendar of the faith element will be removed from the TEI on 2024-11-11.
                 (@calendar / nonfatal)</xsl:message>
      </xsl:if>
      <xsl:apply-templates select="*" mode="M131"/>
   </xsl:template>
   <xsl:template match="text()" priority="-1" mode="M131"/>
   <xsl:template match="@*|node()" priority="-2" mode="M131">
      <xsl:apply-templates select="*" mode="M131"/>
   </xsl:template>
   <!--PATTERN -->
   <!--RULE -->
   <xsl:template match="tei:floruit" priority="1000" mode="M132">

		<!--REPORT nonfatal-->
      <xsl:if test="@calendar">
         <xsl:message>WARNING: use of deprecated attribute — @calendar of the floruit element will be removed from the TEI on 2024-11-11.
                 (@calendar / nonfatal)</xsl:message>
      </xsl:if>
      <xsl:apply-templates select="*" mode="M132"/>
   </xsl:template>
   <xsl:template match="text()" priority="-1" mode="M132"/>
   <xsl:template match="@*|node()" priority="-2" mode="M132">
      <xsl:apply-templates select="*" mode="M132"/>
   </xsl:template>
   <!--PATTERN -->
   <!--RULE -->
   <xsl:template match="tei:gender" priority="1000" mode="M133">

		<!--REPORT nonfatal-->
      <xsl:if test="@calendar">
         <xsl:message>WARNING: use of deprecated attribute — @calendar of the gender element will be removed from the TEI on 2024-11-11.
                 (@calendar / nonfatal)</xsl:message>
      </xsl:if>
      <xsl:apply-templates select="*" mode="M133"/>
   </xsl:template>
   <xsl:template match="text()" priority="-1" mode="M133"/>
   <xsl:template match="@*|node()" priority="-2" mode="M133">
      <xsl:apply-templates select="*" mode="M133"/>
   </xsl:template>
   <!--PATTERN -->
   <!--RULE -->
   <xsl:template match="tei:langKnowledge" priority="1000" mode="M134">

		<!--REPORT nonfatal-->
      <xsl:if test="@calendar">
         <xsl:message>WARNING: use of deprecated attribute — @calendar of the langKnowledge element will be removed from the TEI on 2024-11-11.
                 (@calendar / nonfatal)</xsl:message>
      </xsl:if>
      <xsl:apply-templates select="*" mode="M134"/>
   </xsl:template>
   <xsl:template match="text()" priority="-1" mode="M134"/>
   <xsl:template match="@*|node()" priority="-2" mode="M134">
      <xsl:apply-templates select="*" mode="M134"/>
   </xsl:template>
   <!--PATTERN -->
   <!--RULE -->
   <xsl:template match="tei:langKnown" priority="1000" mode="M135">

		<!--REPORT nonfatal-->
      <xsl:if test="@calendar">
         <xsl:message>WARNING: use of deprecated attribute — @calendar of the langKnown element will be removed from the TEI on 2024-11-11.
                 (@calendar / nonfatal)</xsl:message>
      </xsl:if>
      <xsl:apply-templates select="*" mode="M135"/>
   </xsl:template>
   <xsl:template match="text()" priority="-1" mode="M135"/>
   <xsl:template match="@*|node()" priority="-2" mode="M135">
      <xsl:apply-templates select="*" mode="M135"/>
   </xsl:template>
   <!--PATTERN -->
   <!--RULE -->
   <xsl:template match="tei:location" priority="1000" mode="M136">

		<!--REPORT nonfatal-->
      <xsl:if test="@calendar">
         <xsl:message>WARNING: use of deprecated attribute — @calendar of the location element will be removed from the TEI on 2024-11-11.
                 (@calendar / nonfatal)</xsl:message>
      </xsl:if>
      <xsl:apply-templates select="*" mode="M136"/>
   </xsl:template>
   <xsl:template match="text()" priority="-1" mode="M136"/>
   <xsl:template match="@*|node()" priority="-2" mode="M136">
      <xsl:apply-templates select="*" mode="M136"/>
   </xsl:template>
   <!--PATTERN -->
   <!--RULE -->
   <xsl:template match="tei:nationality" priority="1000" mode="M137">

		<!--REPORT nonfatal-->
      <xsl:if test="@calendar">
         <xsl:message>WARNING: use of deprecated attribute — @calendar of the nationality element will be removed from the TEI on 2024-11-11.
                 (@calendar / nonfatal)</xsl:message>
      </xsl:if>
      <xsl:apply-templates select="*" mode="M137"/>
   </xsl:template>
   <xsl:template match="text()" priority="-1" mode="M137"/>
   <xsl:template match="@*|node()" priority="-2" mode="M137">
      <xsl:apply-templates select="*" mode="M137"/>
   </xsl:template>
   <!--PATTERN -->
   <!--RULE -->
   <xsl:template match="tei:occupation" priority="1000" mode="M138">

		<!--REPORT nonfatal-->
      <xsl:if test="@calendar">
         <xsl:message>WARNING: use of deprecated attribute — @calendar of the occupation element will be removed from the TEI on 2024-11-11.
                 (@calendar / nonfatal)</xsl:message>
      </xsl:if>
      <xsl:apply-templates select="*" mode="M138"/>
   </xsl:template>
   <xsl:template match="text()" priority="-1" mode="M138"/>
   <xsl:template match="@*|node()" priority="-2" mode="M138">
      <xsl:apply-templates select="*" mode="M138"/>
   </xsl:template>
   <!--PATTERN -->
   <!--RULE -->
   <xsl:template match="tei:persPronouns" priority="1000" mode="M139">

		<!--REPORT nonfatal-->
      <xsl:if test="@calendar">
         <xsl:message>WARNING: use of deprecated attribute — @calendar of the persPronouns element will be removed from the TEI on 2024-11-11.
                 (@calendar / nonfatal)</xsl:message>
      </xsl:if>
      <xsl:apply-templates select="*" mode="M139"/>
   </xsl:template>
   <xsl:template match="text()" priority="-1" mode="M139"/>
   <xsl:template match="@*|node()" priority="-2" mode="M139">
      <xsl:apply-templates select="*" mode="M139"/>
   </xsl:template>
   <!--PATTERN -->
   <!--RULE -->
   <xsl:template match="tei:population" priority="1000" mode="M140">

		<!--REPORT nonfatal-->
      <xsl:if test="@calendar">
         <xsl:message>WARNING: use of deprecated attribute — @calendar of the population element will be removed from the TEI on 2024-11-11.
                 (@calendar / nonfatal)</xsl:message>
      </xsl:if>
      <xsl:apply-templates select="*" mode="M140"/>
   </xsl:template>
   <xsl:template match="text()" priority="-1" mode="M140"/>
   <xsl:template match="@*|node()" priority="-2" mode="M140">
      <xsl:apply-templates select="*" mode="M140"/>
   </xsl:template>
   <!--PATTERN -->
   <!--RULE -->
   <xsl:template match="tei:relation" priority="1000" mode="M141">

		<!--REPORT nonfatal-->
      <xsl:if test="@calendar">
         <xsl:message>WARNING: use of deprecated attribute — @calendar of the relation element will be removed from the TEI on 2024-11-11.
                 (@calendar / nonfatal)</xsl:message>
      </xsl:if>
      <xsl:apply-templates select="*" mode="M141"/>
   </xsl:template>
   <xsl:template match="text()" priority="-1" mode="M141"/>
   <xsl:template match="@*|node()" priority="-2" mode="M141">
      <xsl:apply-templates select="*" mode="M141"/>
   </xsl:template>
   <!--PATTERN -->
   <!--RULE -->
   <xsl:template match="tei:residence" priority="1000" mode="M142">

		<!--REPORT nonfatal-->
      <xsl:if test="@calendar">
         <xsl:message>WARNING: use of deprecated attribute — @calendar of the residence element will be removed from the TEI on 2024-11-11.
                 (@calendar / nonfatal)</xsl:message>
      </xsl:if>
      <xsl:apply-templates select="*" mode="M142"/>
   </xsl:template>
   <xsl:template match="text()" priority="-1" mode="M142"/>
   <xsl:template match="@*|node()" priority="-2" mode="M142">
      <xsl:apply-templates select="*" mode="M142"/>
   </xsl:template>
   <!--PATTERN -->
   <!--RULE -->
   <xsl:template match="tei:sex" priority="1000" mode="M143">

		<!--REPORT nonfatal-->
      <xsl:if test="@calendar">
         <xsl:message>WARNING: use of deprecated attribute — @calendar of the sex element will be removed from the TEI on 2024-11-11.
                 (@calendar / nonfatal)</xsl:message>
      </xsl:if>
      <xsl:apply-templates select="*" mode="M143"/>
   </xsl:template>
   <xsl:template match="text()" priority="-1" mode="M143"/>
   <xsl:template match="@*|node()" priority="-2" mode="M143">
      <xsl:apply-templates select="*" mode="M143"/>
   </xsl:template>
   <!--PATTERN -->
   <!--RULE -->
   <xsl:template match="tei:socecStatus" priority="1000" mode="M144">

		<!--REPORT nonfatal-->
      <xsl:if test="@calendar">
         <xsl:message>WARNING: use of deprecated attribute — @calendar of the socecStatus element will be removed from the TEI on 2024-11-11.
                 (@calendar / nonfatal)</xsl:message>
      </xsl:if>
      <xsl:apply-templates select="*" mode="M144"/>
   </xsl:template>
   <xsl:template match="text()" priority="-1" mode="M144"/>
   <xsl:template match="@*|node()" priority="-2" mode="M144">
      <xsl:apply-templates select="*" mode="M144"/>
   </xsl:template>
   <!--PATTERN -->
   <!--RULE -->
   <xsl:template match="tei:state" priority="1000" mode="M145">

		<!--REPORT nonfatal-->
      <xsl:if test="@calendar">
         <xsl:message>WARNING: use of deprecated attribute — @calendar of the state element will be removed from the TEI on 2024-11-11.
                 (@calendar / nonfatal)</xsl:message>
      </xsl:if>
      <xsl:apply-templates select="*" mode="M145"/>
   </xsl:template>
   <xsl:template match="text()" priority="-1" mode="M145"/>
   <xsl:template match="@*|node()" priority="-2" mode="M145">
      <xsl:apply-templates select="*" mode="M145"/>
   </xsl:template>
   <!--PATTERN -->
   <!--RULE -->
   <xsl:template match="tei:terrain" priority="1000" mode="M146">

		<!--REPORT nonfatal-->
      <xsl:if test="@calendar">
         <xsl:message>WARNING: use of deprecated attribute — @calendar of the terrain element will be removed from the TEI on 2024-11-11.
                 (@calendar / nonfatal)</xsl:message>
      </xsl:if>
      <xsl:apply-templates select="*" mode="M146"/>
   </xsl:template>
   <xsl:template match="text()" priority="-1" mode="M146"/>
   <xsl:template match="@*|node()" priority="-2" mode="M146">
      <xsl:apply-templates select="*" mode="M146"/>
   </xsl:template>
   <!--PATTERN -->
   <!--RULE -->
   <xsl:template match="tei:trait" priority="1000" mode="M147">

		<!--REPORT nonfatal-->
      <xsl:if test="@calendar">
         <xsl:message>WARNING: use of deprecated attribute — @calendar of the trait element will be removed from the TEI on 2024-11-11.
                 (@calendar / nonfatal)</xsl:message>
      </xsl:if>
      <xsl:apply-templates select="*" mode="M147"/>
   </xsl:template>
   <xsl:template match="text()" priority="-1" mode="M147"/>
   <xsl:template match="@*|node()" priority="-2" mode="M147">
      <xsl:apply-templates select="*" mode="M147"/>
   </xsl:template>
   <!--PATTERN -->
   <!--RULE -->
   <xsl:template match="tei:objectName" priority="1000" mode="M148">

		<!--REPORT nonfatal-->
      <xsl:if test="@calendar">
         <xsl:message>WARNING: use of deprecated attribute — @calendar of the objectName element will be removed from the TEI on 2024-11-11.
                 (@calendar / nonfatal)</xsl:message>
      </xsl:if>
      <xsl:apply-templates select="*" mode="M148"/>
   </xsl:template>
   <xsl:template match="text()" priority="-1" mode="M148"/>
   <xsl:template match="@*|node()" priority="-2" mode="M148">
      <xsl:apply-templates select="*" mode="M148"/>
   </xsl:template>
</xsl:stylesheet>
