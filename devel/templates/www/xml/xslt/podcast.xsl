<?xml version="1.0" encoding="iso-8859-1"?><!DOCTYPE xsl:stylesheet  [
	<!ENTITY nbsp   "&#160;">
	<!ENTITY copy   "&#169;">
	<!ENTITY reg    "&#174;">
	<!ENTITY trade  "&#8482;">
	<!ENTITY mdash  "&#8212;">
	<!ENTITY ldquo  "&#8220;">
	<!ENTITY rdquo  "&#8221;"> 
	<!ENTITY pound  "&#163;">
	<!ENTITY yen    "&#165;">
	<!ENTITY euro   "&#8364;">
	<!ENTITY quote	"&quot;">
	<!ENTITY return "&#013;">
]>
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:itunes="http://www.itunes.com/dtds/podcast-1.0.dtd" xmlns:aan="http://www.aan.com/rss/rss.dtd">
<xsl:output method="html" encoding="iso-8859-1" doctype-public="-//W3C//DTD XHTML 1.0 Transitional//EN" doctype-system="http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd"/>
<xsl:template match="/">

<html xmlns="http://www.w3.org/1999/xhtml">
<head>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1"/>
<link href="rss.css" rel="stylesheet" type="text/css" media="all" />
<xsl:element name="link">
<xsl:attribute name="rel">alternate</xsl:attribute>
<xsl:attribute name="type">application/rss+xml</xsl:attribute>
<xsl:attribute name="title">RSS</xsl:attribute>
<xsl:attribute name="href"><xsl:value-of select="link"/></xsl:attribute>
</xsl:element>
<title><xsl:value-of select="rss/channel/title"/></title>
</head>
<body>
<div id="content">
<xsl:for-each select="rss/channel">
<table id="feed">
<tr>
	<td valign="top" width="145">
	<div id="head">
		<xsl:element name="img">
		<xsl:attribute name="src"><xsl:value-of select="image/url"/></xsl:attribute>
		<xsl:attribute name="class">logo</xsl:attribute>
		</xsl:element>
	</div>
	</td>
	<td valign="top">
		<span class="title"><xsl:value-of select="title"/></span>
		<br /><br />
		<strong><xsl:value-of select="itunes:subtitle"/></strong>
		
		<p><em><xsl:value-of select="copyright"/></em></p>
		
		<!--<p><xsl:value-of select="rss/channel/generator"/></p>-->
		<p><strong>Last build:</strong>&#160;&#160; <xsl:value-of select="lastBuildDate"/></p>
		<p><xsl:value-of select="description" disable-output-escaping="yes"/></p>
		
        <xsl:choose>
			<xsl:when test="aan:isitunes = 'true'">
				<p>
				<xsl:choose>
					<xsl:when test="aan:iTunes_id != ''">
						<xsl:element name="a"><xsl:attribute name="href">http://www.itunes.com/podcast?id=<xsl:value-of select="aan:iTunes_id"/></xsl:attribute>Subscribe Using iTunes</xsl:element>
					</xsl:when>
					<xsl:otherwise>
						<xsl:element name="a"><xsl:attribute name="href">itpc://<xsl:value-of select="substring(link,8,string-length(link))"/></xsl:attribute>Auto-subscribe Using iTunes</xsl:element>
					</xsl:otherwise>
				</xsl:choose>
				(you must have iTunes installed)</p>
			</xsl:when>
		</xsl:choose>
		
		<p><strong>Manually subscribe to this feed now:</strong></p>
		<xsl:element name="input">
			<xsl:attribute name="type">text</xsl:attribute>
			<xsl:attribute name="size">45</xsl:attribute>
			<xsl:attribute name="value"><xsl:value-of select="link"/></xsl:attribute>
			<xsl:attribute name="onFocus">this.select();</xsl:attribute>
		</xsl:element>
		
        <xsl:choose>
			<xsl:when test="aan:isitunes = 'true'">
				<p><strong>Free podcasting software:</strong></p>
				<p><a href="http://www.apple.com/itunes"><img src="images/getItunes.gif" border="0" /></a>&#160;&#160;
				<a href="http://juicereceiver.sourceforge.net"><img src="images/badge_juice.gif" border="0" /></a>&#160;&#160;
				<a href="http://www.dopplerradio.net"><img src="images/dopplerbutton.gif" border="0" /></a></p>
			</xsl:when>
		</xsl:choose>
        
		<p>
        <xsl:element name="a"><xsl:attribute name="href">mailto:<xsl:value-of select="aan:feedback/aan:email"/></xsl:attribute>General Feedback</xsl:element><br /><br /><xsl:element name="a"><xsl:attribute name="href">mailto:<xsl:value-of select="managingEditor"/></xsl:attribute>Email the Managing Editor</xsl:element><br /><br />
		<xsl:element name="a"><xsl:attribute name="href">mailto:<xsl:value-of select="webMaster"/></xsl:attribute>Email the Feed Developer</xsl:element>
		</p>
	</td>
</tr>
</table>
<table id="list" bgcolor="#FFFFFF">
<xsl:for-each select="item">
<xsl:sort select="position()" data-type="number" order="descending"/>
<xsl:element name="tr">
<xsl:if test="position() mod 2 = 0">
	<xsl:attribute name="bgcolor">#EEF2F3</xsl:attribute>
</xsl:if>
<td valign="top" width="155" align="right"><xsl:element name="a"><xsl:attribute name="href"><xsl:value-of select="guid"/></xsl:attribute>download this now<!--<img src="images/download.jpg" border="0" />--></xsl:element></td>
	<td valign="top">

	<strong><xsl:value-of select="title"/></strong>
    <xsl:if test="position() = 1">
    <span class="new">&#160;&#160;-&#160;&#160;LATEST ISSUE</span>
    </xsl:if>
    <br /><br />
    <p class="itemDescription"><xsl:value-of select="itunes:subtitle"/></p>
	<strong>Published:</strong>&#160;&#160; <xsl:value-of select="pubDate"/><br /><br />
	<p class="itemDescription"><xsl:value-of select="description" disable-output-escaping="no"/></p>
	<!--(<xsl:value-of select="enclosure/@length"/> secs - <xsl:value-of select="enclosure/@type"/>)-->
	<xsl:if test="aan:cme != 0"><p class="itemDescription"><span class="new">NEW CME Opportunity</span>: Listen to this week's Neurology&reg; Podcast and earn 0.5 AMA PRA Category 1 CME Credits&#8482; by answering the multiple-choice questions in the online <a href="http://www.aan.com/elibrary/continuum/index.cfm?event=podcast.selectexam" style="margin-right:3px;">Podcast quiz</a> (Quizzes are available for podcasts posted since January 12, 2010).</p></xsl:if>
	</td>
     
</xsl:element>
</xsl:for-each>

</table>
</xsl:for-each>
</div>
</body>
</html>

</xsl:template>
</xsl:stylesheet>