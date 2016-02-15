<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="2.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:fo="http://www.w3.org/1999/XSL/Format" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:fn="http://www.w3.org/2005/xpath-functions">
<xsl:output method="html" indent="yes"/>
<xsl:template match="/"><xsl:text disable-output-escaping="yes"><![CDATA[<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN" "http://www.w3.org/TR/html4/loose.dtd">]]>&#10;</xsl:text>
<html>
  <head>
    <title>judy's cd list</title>
    <link rel="stylesheet" href="exportindex_item_customlist.css" type="text/css"></link>
  </head>
  <body>
    <table border="1">
      <thead>
        <tr>
          <th class="header">#</th>
          <th class="header">Artist</th>
          <th class="header">Album</th>
          <th class="header">Release</th>
          <th class="header">Label</th>
        </tr>
      </thead>
      <tbody>
        <xsl:apply-templates select=".//musiclist/music"><xsl:sort select="artists/artist[1]/sortname" data-type="text" case-order="lower-first" order="ascending"/></xsl:apply-templates>
      </tbody>
    </table>
  </body>
</html>
</xsl:template>

<xsl:template match="music">
<xsl:variable name="asin">
  <xsl:choose>
    <xsl:when test="links/link[contains(url,'amazon.com/') and contains(url,'ASIN/')]"><xsl:value-of select="substring-before(substring-after(links/link[1]/url,'ASIN/'),'/')"/></xsl:when>
    <xsl:otherwise>#</xsl:otherwise>
  </xsl:choose>
</xsl:variable>
<xsl:variable name="jpeg">
  <xsl:choose>
    <xsl:when test="thumbfilepath"><xsl:value-of select="substring-after(thumbfilepath,'Collector\')"/></xsl:when>
    <xsl:otherwise>#</xsl:otherwise>
  </xsl:choose>
</xsl:variable>
        <tr>
          <xsl:choose>
            <xsl:when test="$jpeg!='#'">
              <td><a><xsl:attribute name="href"><xsl:if test="$asin!='#'"> http://amzn.com/</xsl:if><xsl:value-of select="$asin"/></xsl:attribute><img alt="thumb" src="{$jpeg}" style="max-width:120px;height:auto;"/></a></td>            
            </xsl:when>
            <xsl:when test="$asin!='#'">
              <td><iframe style="width:120px;height:240px;" marginwidth="0" marginheight="0" scrolling="no" frameborder="0" src="http://ws-na.amazon-adsystem.com/widgets/q?ServiceVersion=20070822&amp;OneJS=1&amp;Operation=GetAdHtml&amp;MarketPlace=US&amp;source=ss&amp;ref=ss_til&amp;ad_type=product_link&amp;tracking_id=johnsonfamilyalb&amp;marketplace=amazon&amp;region=US&amp;placement={$asin}&amp;asins={$asin}&amp;linkId=VZU2WOL2R5UUCGJF&amp;show_border=true&amp;link_opens_in_new_window=true"></iframe></td>            
            </xsl:when>
            <xsl:otherwise>
              <td style="width:120px;height:120px">n/a</td>            
            </xsl:otherwise>
          </xsl:choose>
          
          <xsl:choose>
            <xsl:when test="artists/artist/displayname">
              <td class="header"><xsl:apply-templates select="artists/artist"/></td>
            </xsl:when>
            <xsl:when test="details//artists/artist/displayname">
              <td class="header"><xsl:apply-templates select="details//artists/artist"/></td>
            </xsl:when>
            <xsl:otherwise>
              <td class="header">n/a</td>
            </xsl:otherwise>
          </xsl:choose>
          
          <xsl:choose>
            <xsl:when test="title">
              <td class="header"><xsl:apply-templates select="title"/></td>
            </xsl:when>
            <xsl:otherwise>
              <td class="header">n/a</td>
            </xsl:otherwise>
          </xsl:choose>

          <xsl:choose>
            <xsl:when test="releasedate/year/displayname">
              <td class="header"><xsl:apply-templates select="releasedate/year"/></td>
            </xsl:when>
            <xsl:otherwise>
              <td class="header">n/a</td>
            </xsl:otherwise>
          </xsl:choose>

          <xsl:choose>
            <xsl:when test="label/displayname">
              <td class="header"><xsl:apply-templates select="label"/></td>
            </xsl:when>
            <xsl:otherwise>
              <td class="header">n/a</td>
            </xsl:otherwise>
          </xsl:choose>
        </tr>
</xsl:template>

<xsl:template match="artist|label|year"><xsl:value-of select="displayname"/><br/></xsl:template>

</xsl:stylesheet>
