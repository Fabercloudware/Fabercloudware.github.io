<?xml version="1.0" encoding="ISO-8859-1"?>
<xsl:stylesheet version="2.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:fn="http://www.w3.org/2005/xpath-functions">
    <xsl:output method="html" version="1.0" encoding="ISO-8859-1" indent="yes"  /> <!-- doctype-public="-//W3C//DTD HTML 4.01 Transitional//EN" doctype-system="http://www.w3.org/TR/html4/loose.dtd" -->
    <xsl:variable name="solution">block</xsl:variable><!-- block & none are expected values -->
    <xsl:variable name="solcell">display:table-cell;border:1px solid black;height:5mm;width:5mm;font-family:monospace;color:black;text-align:center;font-size:100%;padding:0px;margin:0px;</xsl:variable>
    <xsl:variable name="maincell">display:table-cell;border:1px solid black;height:10mm;width:10mm;font-family:monospace;color:black;text-align:left;font-size:67%;padding:0px;margin:0px;</xsl:variable>
    <xsl:template match="/Puzzles/Puzzle">
        <xsl:text disable-output-escaping="yes"><![CDATA[<!DOCTYPE html>]]>&#13;&#10;</xsl:text>
        <html>
            <head>
                <title><xsl:value-of select="Title"/></title>
            </head>
            <body>
                <h2><xsl:value-of select="Title"/></h2>
                <h3>by <xsl:value-of select="Author"/></h3>
                <h5>edited by <xsl:value-of select="Editor"/>, <xsl:value-of select="Publisher"/>, <xsl:value-of select="Date"/></h5>
                <p><xsl:value-of select="Notepad" disable-output-escaping="yes"/></p>
                <div style="display:block;width:28cm">
                    <div style="width:30%;float:left">
                        <div style="width:45%;float:left">
                            <div style="display:block;font-size:12pt;font-family:san-serif;font-weight:bold;">ACROSS</div>
                            <xsl:apply-templates select="Clues/Clue[@Dir='Across']"><xsl:sort data-type="number" select="@Num"/></xsl:apply-templates>
                        </div>
                        <div style="width:45%;float:right">
                              <div style="display:inline;font-size:12pt;font-family:san-serif;font-weight:bold;">DOWN</div>
                              <xsl:apply-templates select="Clues/Clue[@Dir='Down']"><xsl:sort data-type="number" select="@Num"/></xsl:apply-templates>
                        </div>
                    </div>
                  
                    <div style="width:60%;float:right">
                     <div style="display:block;border:1px solid black;width:{Size/Cols*10.262 + 0.262}mm;float:left;">
                        <xsl:for-each select="Grid/Row">
                            <xsl:variable name="pos" select="position()"/>
                            <div style="display:table-row">
                                <xsl:call-template name="MainRow">
                                    <xsl:with-param name="row" select="."/>
                                    <xsl:with-param name="rownum" select="$pos"/>
                                    <xsl:with-param name="col" select="/Puzzles/Puzzle/Size/Cols"/>
                                    <xsl:with-param name="num" select="/Puzzles/Puzzle/Clues/Clue[@Row=$pos and @Col=/Puzzles/Puzzle/Size/Cols][1]/@Num"/>
                                </xsl:call-template>
                            </div>
                        </xsl:for-each>
                     </div>
                    </div>
               </div>
               <div style="display:{$solution};width:24cm;margin-top:50cm">
                 <div style="float:right;border:1px solid black;width:{Size/Cols*5.262 + 0.262}mm;">
                    <xsl:apply-templates select="Grid"/>
                  </div>
                  <div style="display:block;float:right;clear:right"><xsl:apply-templates select=".//Rebus"/></div>
               </div>
            </body>
        </html>    
    </xsl:template>
    <xsl:template match="Clue">
        <div style="display:block">
            <div style="width:18%;float:left;clear:right;"><xsl:value-of select="@Num"/>. </div>
            <div style="float:right;width:80%;"><xsl:value-of select="."/></div>
        </div>
    </xsl:template>
   <xsl:template name="MainRow">
        <xsl:param name="row"/>
        <xsl:param name="rownum"/>
        <xsl:param name="col"/>
        <xsl:param name="num"/>
        <xsl:if test="$col &gt; 1">
            <xsl:call-template name="MainRow">
                <xsl:with-param name="row" select="$row"/>
                <xsl:with-param name="rownum" select="$rownum"/>
                <xsl:with-param name="col" select="$col - 1"/>
                <xsl:with-param name="num" select="/Puzzles/Puzzle/Clues/Clue[@Row=$rownum and @Col=$col - 1][1]/@Num"/>
           </xsl:call-template>
        </xsl:if>
        <xsl:choose>
            <xsl:when test="substring($row,$col,1)='.'">
                <div style="{$maincell}background-color:black;">&#160;</div>
            </xsl:when>
            <xsl:otherwise>
                <div style="{$maincell}background-color:white;"><xsl:value-of select="$num"/>&#160;</div>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>
    <xsl:template match="Grid">
        <xsl:for-each select="Row">
            <div style="display:table-row;">
                <xsl:call-template name="SolutionRow">
                        <xsl:with-param name="row" select="."/>
                        <xsl:with-param name="col" select="count(../Row)"/>
                </xsl:call-template>
            </div>
        </xsl:for-each>
    </xsl:template>
    <xsl:template name="SolutionRow">
        <xsl:param name="row"/>
        <xsl:param name="col"/>
        <xsl:if test="$col &gt; 1">
            <xsl:call-template name="SolutionRow">
                <xsl:with-param name="row" select="$row"/>
                <xsl:with-param name="col" select="$col - 1"/>
            </xsl:call-template>
        </xsl:if>
        <xsl:variable name="letter" select="substring($row,$col,1)"/>
          <xsl:choose>
            <xsl:when test="$letter='.'"><div style="{$solcell}background-color:black;"/></xsl:when>
            <xsl:otherwise><div style="{$solcell}background-color:white;"><xsl:value-of select="$letter"/></div></xsl:otherwise>
          </xsl:choose>
          <xsl:text>&#13;&#10;</xsl:text>
    </xsl:template>
    <xsl:template match="Rebus">
        <div style="display:block"><sup><xsl:value-of select="position()"/></sup> <xsl:value-of select="@Short"/>=<xsl:value-of select="."/> at row:<xsl:value-of select="@Row"/> and col:<xsl:value-of select="@Col"/>    </div>
    </xsl:template>
</xsl:stylesheet>
