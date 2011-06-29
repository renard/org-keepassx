<?xml version="1.0" encoding="UTF-8"?>
<!-- -*- xml -*- -->

<!--
Copyright © 2011 Sebastien Gross <seb•ɑƬ•chezwam•ɖɵʈ•org>

Author: Sebastien Gross <seb•ɑƬ•chezwam•ɖɵʈ•org>
Keywords: 
Created: 2010-11-30
Last changed: 2011-06-29 18:52:38
Licence: WTFPL, grab your copy here: http://sam.zoy.org/wtfpl/


Convert KeePassX database to org file encryptable with org-cryp.

Requirements:
 - keepassx (http://www.keepassx.org/)
 - org-mode (http://orgmode.org/) with org-crypt extension.
 - xsltproc

Howto use:

 - Open a keepassx database
 - Export to KeePassX XML (File / Export to ... / KeePassX XML File)
 - Convert to org file using:
     
     xsltproc -\-stringparam gpgkey KEYID KeepassX.xslt foo.xml > foo.org

-->

<xsl:stylesheet version="1.0"
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform">


  <xsl:variable name='newline'>
    <xsl:text>&#10;</xsl:text>
  </xsl:variable>
  <xsl:param name="gpgkey" />


  <xsl:output method="text" encoding="UTF-8" indent="no"/>
  <xsl:strip-space elements="*"/>

  <xsl:template match="/">
    <xsl:text>#+TITLE: KeepassX import</xsl:text>
    <xsl:value-of select="$newline"/>
    <xsl:text>#+STARTUP: hidestars</xsl:text>
    <xsl:value-of select="$newline"/>
    <xsl:apply-templates select="database"/>
  </xsl:template>


  <xsl:template match="database">
    <xsl:value-of select="$newline"/>
    <xsl:text>* KeepassX database                                 :crypt:</xsl:text>
    <xsl:value-of select="$newline"/>
    <xsl:text>    :PROPERTIES:</xsl:text>
    <xsl:value-of select="$newline"/>
    <xsl:text>    :CRYPTKEY:    </xsl:text>
    <xsl:value-of select="$gpgkey"/>
    <xsl:value-of select="$newline"/>
    <xsl:text>    :END:</xsl:text>
    <xsl:value-of select="$newline"/>

    <xsl:apply-templates select="group">
      <xsl:with-param name="level" select="'**'"/>
    </xsl:apply-templates>

  </xsl:template>

  
  <xsl:template match="group">
    <xsl:param name="level" />
    <xsl:value-of select="$level"/>
    <xsl:text> </xsl:text>
    <xsl:value-of select="title"/>
    <xsl:value-of select="$newline"/>
    <xsl:text>    :PROPERTIES:</xsl:text>
    <xsl:value-of select="$newline"/>
    <xsl:apply-templates select="icon"/>
    <xsl:text>    :END:</xsl:text>
    <xsl:value-of select="$newline"/>

    <!-- Entries -->
    <xsl:apply-templates select="entry">
      <xsl:with-param name="level" select="concat('*', $level)"/>
    </xsl:apply-templates>

    <!-- <xsl:value-of select="$newline"/> -->

    <!-- Loop groups -->
    <xsl:apply-templates select="group">
      <xsl:with-param name="level" select="concat('*', $level)"/>
    </xsl:apply-templates>

  </xsl:template>


  <xsl:template match="entry">
    <xsl:param name="level" />
    <xsl:value-of select="$level"/>

    <xsl:text> </xsl:text>
    <xsl:value-of select="title"/>
    <xsl:value-of select="$newline"/>
    <xsl:apply-templates select="expire"/>

    <xsl:text>    :PROPERTIES:</xsl:text>
    <xsl:value-of select="$newline"/>
    <xsl:apply-templates select="creation"/>
    <xsl:apply-templates select="lastmod"/>
    <xsl:apply-templates select="icon"/>
    <xsl:text>    :END:</xsl:text>
    <xsl:value-of select="$newline"/>


    <xsl:apply-templates select="username"/>
    <xsl:apply-templates select="password"/>
    <xsl:apply-templates select="url"/>
    <xsl:apply-templates select="comment"/>
    <xsl:apply-templates select="bin"/>
  </xsl:template>

  <xsl:template match="expire">
    <xsl:if test=". != ''">
      <xsl:if test=". != 'Never'">
	<xsl:text>    DEADLINE: &lt;</xsl:text>

	<xsl:call-template name="string-replace-all">
	  <xsl:with-param name="text" select="." />
	  <xsl:with-param name="replace" select="'T'" />
	  <xsl:with-param name="by" select="' '" />
	</xsl:call-template>

	<xsl:text>&gt;</xsl:text>
	<xsl:value-of select="$newline"/>
      </xsl:if>
    </xsl:if>
  </xsl:template>

  <xsl:template match="creation">
    <xsl:if test=". != ''">
      <xsl:text>    :CREATION: &lt;</xsl:text>

      <xsl:call-template name="string-replace-all">
	<xsl:with-param name="text" select="." />
	<xsl:with-param name="replace" select="'T'" />
	<xsl:with-param name="by" select="' '" />
      </xsl:call-template>


      <xsl:text>&gt;</xsl:text>
      <xsl:value-of select="$newline"/>
    </xsl:if>
  </xsl:template>

  <xsl:template match="lastmod">
    <xsl:if test=". != ''">
      <xsl:text>    :MODIFICATION: &lt;</xsl:text>

      <xsl:call-template name="string-replace-all">
	<xsl:with-param name="text" select="." />
	<xsl:with-param name="replace" select="'T'" />
	<xsl:with-param name="by" select="' '" />
      </xsl:call-template>

      <xsl:text>&gt;</xsl:text>
      <xsl:value-of select="$newline"/>
    </xsl:if>
  </xsl:template>

  <xsl:template match="icon">
    <xsl:if test=". != ''">
      <xsl:text>    :ICON: </xsl:text>
      <xsl:value-of select="."/>
      <xsl:value-of select="$newline"/>
    </xsl:if>
  </xsl:template>


  <xsl:template match="username">
    <xsl:if test=". != ''">
      <xsl:text> - Username: </xsl:text>
      <xsl:value-of select="."/>
      <xsl:value-of select="$newline"/>
    </xsl:if>
  </xsl:template>

  <xsl:template match="password">
    <xsl:if test=". != ''">
      <xsl:text> - Password: </xsl:text>
      <xsl:value-of select="."/>
      <xsl:value-of select="$newline"/>
    </xsl:if>
  </xsl:template>

  <xsl:template match="url">
    <xsl:if test=". != ''">
      <xsl:text> - Url: </xsl:text>
      <xsl:value-of select="."/>
      <xsl:value-of select="$newline"/>
    </xsl:if>
  </xsl:template>

  <xsl:template match="comment">
    <xsl:if test=". != ''">
      <xsl:value-of select="$newline"/>
      <xsl:text>#+BEGIN_COMMENT</xsl:text>
      <xsl:value-of select="$newline"/>

 
      <xsl:variable name='full-comment'>
	<xsl:value-of select="." disable-output-escaping="yes" />
      </xsl:variable>
     

      <xsl:call-template name="string-replace-all">
	<xsl:with-param name="text" select="$full-comment" />
	<xsl:with-param name="replace" select="'&lt;br/&gt;'" />
	<xsl:with-param name="by" select="$newline" />
      </xsl:call-template>

      <xsl:value-of select="$newline"/>
      <xsl:text>#+END_COMMENT</xsl:text>
      <xsl:value-of select="$newline"/>
      <xsl:value-of select="$newline"/>
    </xsl:if>
  </xsl:template>

  <xsl:template match="bin">
    <xsl:if test=". != ''">
      <xsl:value-of select="$newline"/>
      <xsl:text>#+BEGIN_BIN</xsl:text>
      <xsl:text> </xsl:text>
      <xsl:value-of select="../bindesc"/>
      <xsl:value-of select="$newline"/>
      <xsl:value-of select="."/>
      <xsl:value-of select="$newline"/>
      <xsl:text>#+END_BIN</xsl:text>
      <xsl:value-of select="$newline"/>
      <xsl:value-of select="$newline"/>
    </xsl:if>
  </xsl:template>



  <xsl:template name="string-replace-all">
    <xsl:param name="text" />
    <xsl:param name="replace" />
    <xsl:param name="by" />
    <xsl:choose>
      <xsl:when test="contains($text, $replace)">
        <xsl:value-of select="substring-before($text,$replace)" />
        <xsl:value-of select="$by" />
        <xsl:call-template name="string-replace-all">
          <xsl:with-param name="text"
			  select="substring-after($text,$replace)" />
          <xsl:with-param name="replace" select="$replace" />
          <xsl:with-param name="by" select="$by" />
        </xsl:call-template>
      </xsl:when>
      <xsl:otherwise>
        <xsl:value-of select="$text" />
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>
  
</xsl:stylesheet>

