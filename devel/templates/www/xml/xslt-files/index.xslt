<?xml version="1.0" encoding="UTF-8" ?>
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:itunes="http://www.itunes.com/dtds/podcast-1.0.dtd" >
<xsl:output encoding="UTF-8" />
<xsl:template match="/">
<html>
<head>
<title><xsl:value-of select="rss/channel/title"/></title>
<meta http-equiv="Content-Type" content="text/html; charset=UTF-8" />
<link rel="alternate" type="application/rss+xml" title="David Allen Company Master RSS Feed" href="http://www.davidco.com/master_rss.php?usm=1" />
<link rel="stylesheet" href="http://www.davidco.com/css/styles.css" type="text/css" />
<script language="JavaScript" type="text/JavaScript">
<!--
function MM_openBrWindow(theURL,winName,features) { //v2.0
  window.open(theURL,winName,features);
}
//-->
</script>
</head><body bgcolor="#FFFFFF" text="#000000" LINK="#66666" VLINK="#66666" ALINK="#000000" leftmargin="0" topmargin="0" marginwidth="0" marginheight="0">
<div style="width:100%; height:70px; background-image:url('http://www.davidco.com/images/bg_header.gif')" ><img src="http://www.davidco.com/2003_images/header_full.gif" width="800" height="70" /></div>
    <div style="width:100%; height:26px; background-color:#20A63E;" ><img src="http://www.davidco.com/2003_images/header/nav_bar.gif" width="800" height="26" border="0" usemap="#Maptp" /></div>
    <div style="height:1px; width:100%; background-color:#FFFFFF"><img src="/images/spacer.gif" width="10" height="1" /></div>
<map name="Maptp" id="Maptp">
  <area shape="rect" coords="15,4,49,22" href="http://www.davidco.com/index.php" />
  <area shape="rect" coords="214,4,378,22" href="http://www.davidco.com/individuals.php" />
  <area shape="rect" coords="387,6,438,20" href="http://www.davidco.com/products.php" />
  <area shape="rect" coords="449,4,522,22" href="http://www.davidco.com/cart.php" />
  <area shape="rect" coords="534,6,631,23" href="http://www.davidco.com/guide.php" />
  <area shape="rect" coords="645,5,686,21" href="http://www.davidco.com/contact.php" />
  <area shape="rect" coords="698,4,793,21" href="http://www.davidco.com/connect/" />
  <area shape="rect" coords="63,5,210,24" href="http://www.davidco.com/corporate.php" />
</map>
<link href="/css/styles.css" rel="stylesheet" type="text/css" />
<table width="100%" border="0" cellspacing="0" cellpadding="0">
<tr>
    <td bgcolor="#808080">
      <img src="http://www.davidco.com/images/spacer.gif" width="31" height="46" />
      <img src="/images/titles/podcast-head.gif" />
      </td>
  </tr>
  <tr>
    <td><img src="http://www.davidco.com/images/spacer.gif" width="34" height="46" />
    </td>
  </tr>
</table>
<table width="100%" border="0" cellspacing="0" cellpadding="0" bgcolor="#FFFFFF">
  <tr> 
    <td valign="top">
<div style="height:1px; width:100%; background-color:#BEBEBE"><img src="/images/spacer.gif" width="10" height="1" /></div>
      <table width="721" border="0" cellspacing="0" cellpadding="0">
        <tr>
          <td width="446" valign="top">
            <table width="100%" border="0" cellpadding="20" cellspacing="0" class="smallunleaded">
              <tr>
              <td align="center" valign="top">
              <table width="400" border="0" cellspacing="0" cellpadding="0" align="center">
<tr>
<td width="500" valign="top">
<h2 class="titleBrandBlue"><xsl:value-of select="rss/channel/title"/></h2>
<p class="body"><xsl:value-of select="rss/channel/description" /> To add this feed to your favorite RSS news reader or podcast player, choose from the options at the right. Or simply click on any of the news items or podcasts below to read the full story or listen to the audio. </p><p class="body">For a complete summary of company news be sure to also subscribe to the <a href="/master_rss.php" class="greyText">Company Updates</a> RSS feed.</p>

<div style="height:1px; width:100%; background-color:#BEBEBE"><img src="/images/spacer.gif" width="10" height="1" /></div><br />

<xsl:for-each select="rss/channel/item">
      <xsl:variable name="title">
        <xsl:value-of select="title" />
      </xsl:variable>
    <xsl:if test="substring($title, 0, 8)='Podcast'"><a href="{link}"><img src="/images/buttons/podcast.gif" width="32" height="32" style="float: left; border: 0px; padding-left: 5px; padding-right: 5px;" border="0" /></a></xsl:if>
<div style="cursor:pointer; cursor:hand;" onClick="location.href='{link}'">
       <div class="greyText"><strong><a href="{link}" rel="bookmark" class="greyText"><xsl:value-of select="title"/></a></strong></div>
      <div class="smallText">
      <xsl:variable name="description">
        <xsl:value-of select="description" />
      </xsl:variable>
        <xsl:value-of select="substring($description, 0, 142)" />
       </div>
</div>
<br />
<div style="height:1px; width:100%; background-color:#BEBEBE"><img src="/images/spacer.gif" width="10" height="1" /></div><br />
</xsl:for-each>
</td>
</tr>
<tr>
<td valign="top" class="body"><br />
</td>
</tr>
</table>
<img src="/images/spacer.gif" width="10" height="20" /></td>
              </tr>
            </table>
        </td>
          <td bgcolor="#BEBEBE" width="1"><img src="/images/spacer.gif" width="1" height="10" /></td>
          <td align="center" valign="top"> 
            <div align="center">
<table width="100%"  border="0" cellspacing="0" cellpadding="6">
<tr>
<td bgcolor="#808080" class="titleWhite" align="center">
Subscribe Now
</td>
</tr>
</table>

			  <table width="100%" border="0" cellspacing="0" cellpadding="15">
			    <tr>
			      <td class="quoteBlue">
                  <p><b>Quick Subscribe</b></p>
                  <p align="center">
                    <a href="itpc://www.davidco.com/podcast.php"><img src="/images/buttons/button-itunes.gif" border="0" alt="Subscribe with iTunes"  /></a><br />
                    <a href="http://fusion.google.com/add?feedurl=http://www.davidco.com/podcast.php"><img src="/images/buttons/button-google.gif" border="0" alt="Subscribe with Google Reader"  /></a><br />
                    <a href="http://add.my.yahoo.com/rss?url=http://www.davidco.com/podcast.php"><img src="/images/buttons/button-myyahoo.gif" border="0" alt="Subscribe with My Yahoo!"  /></a><br />

                    <a href="http://my.msn.com/addtomymsn.armx?id=rss&amp;ut=http://www.davidco.com/podcast.php&amp;ru=http://www.davidco.com/"><img src="/images/buttons/button-msn.gif" border="0" alt="Subscribe With My MSN"  /></a><br />
                    <a href="http://feeds.my.aol.com/?url=http%3A//www.davidco.com/podcast.php"><img src="/images/buttons/button-myaol.gif" border="0" alt="Subscribe With My AOL"  /></a><br />
                    <a href="http://www.newsgator.com/ngs/subscriber/subext.aspx?url=http://www.davidco.com/podcast.php"><img src="/images/buttons/button-newsgator.gif" border="0" alt="Subscribe With Newsgator"  /></a><br />
                    <a href="http://www.bloglines.com/sub/http://www.davidco.com/podcast.php"><img src="/images/buttons/button-bloglines.gif" border="0" alt="Subscribe with Bloglines"  /></a><br />
                    <a href="http://client.pluck.com/pluckit/prompt.aspx?a=http://www.davidco.com/podcast.php"><img src="/images/buttons/button-pluck.gif" border="0" alt="Subscribe with Pluck"  /></a><br />
                    <a href="http://www.pageflakes.com/subscribe.aspx?url=http://www.davidco.com/podcast.php"><img src="/images/buttons/button-pageflakes.gif" border="0" alt="Subscribe with Pageflakes"  /></a><br />
                    </p>
                  <p><b>Other RSS Readers or Podcast Players</b></p>
                  <p>Simply copy and paste the URL currently displayed in your address bar into the "add subscription" dialog box of your favorite news reader or podcast player. </p>
                  <p>Alternatively, some browsers may display an RSS subscription icon (<img src="/images/rss.gif" />) in the top navigation area. Click this icon in your browser now to subscribe to this feed using your browser's built-in RSS reader mechanism.
                  </p>
		          </td>
		      </tr>
		    </table>
          </div>
        </td>
          <td bgcolor="#BEBEBE" width="1"><img src="/images/spacer.gif" width="1" height="10" /></td>
        </tr>
    </table>
  </td>
  </tr>
</table>
<style type="text/css">
<!--
.style1 {
	font-family: Geneva, Arial, Helvetica, sans-serif;
	font-size: xx-small;
}
.style3 {color: #CCCCCC}
-->
</style>
<div style="width:100%; background-image:url('/images/bg_footer.gif') ">
    <div style="width:790; height: 33px;" >
    <img src="/nav/footer_1.gif" width="785" height="33" />
    </div>
    <div style="width:813; height: 23px;" >
        <img src="/nav/footer_2-rss.gif" width="747" height="23" /><a href="/terms_of_use.php"><img src="/nav/footer_3.gif" alt="Terms of use" width="66" height="23" border="0" /></a><br />
    </div>    
    <div style="width:790; height: 36px;" >
        <img src="/nav/footer_bottom-rss.gif" width="900" height="36" />
    </div>    
</div>
</body>
</html>
</xsl:template>
</xsl:stylesheet>
