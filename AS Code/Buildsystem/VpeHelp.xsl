<xsl:stylesheet version="1.0"
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns="http://schemas.microsoft.com/winfx/2006/xaml/presentation"
    xmlns:x="http://schemas.microsoft.com/winfx/2006/xaml"
    xmlns:fc="feature-comparison">
  <xsl:output method="xml" indent="yes" encoding="UTF-8"/>
  <!-- parameters injected by the property grid -->
  <xsl:param name="property" select="'Property'"/>
  <xsl:param name="folder" select="'.'"/>
  <xsl:param name="projecttype" select="''"/>
  <xsl:param name="productedition" select="''"/>

  <!-- Need to preserve certain kinds of whitespace -->
  <xsl:preserve-space elements="codeblock inifile"/>
  
  <!-- SystemColors references -->  
  <xsl:variable name="WindowBrush" select="'{x:Static SystemColors.WindowBrush}'"/>
  <xsl:variable name="WindowFrameBrush" select="'{x:Static SystemColors.WindowFrameBrush}'"/>
  <xsl:variable name="WindowTextBrush" select="'{x:Static SystemColors.WindowTextBrush}'"/>
  <xsl:variable name="HighlightBrush" select="'{x:Static SystemColors.HighlightBrush}'"/>
  <xsl:variable name="HighlightTextBrush" select="'{x:Static SystemColors.HighlightTextBrush}'"/>
  <xsl:variable name="HotTrackBrush" select="'{x:Static SystemColors.HotTrackBrush}'"/>
  <xsl:variable name="GrayTextBrush" select="'{x:Static SystemColors.GrayTextBrush}'"/>
  <xsl:variable name="InfoBrush" select="'{x:Static SystemColors.InfoBrush}'"/>
  <xsl:variable name="InfoTextBrush" select="'{x:Static SystemColors.InfoTextBrush}'"/>
  <xsl:variable name="ControlBrush" select="'{x:Static SystemColors.ControlBrush}'"/>
  <xsl:variable name="ControlTextBrush" select="'{x:Static SystemColors.ControlTextBrush}'"/>
  <xsl:variable name="ControlLightLightBrush" select="'{x:Static SystemColors.ControlLightLightBrush}'"/>
  <xsl:variable name="ControlLightBrush" select="'{x:Static SystemColors.ControlLightBrush}'"/>
  <xsl:variable name="ControlDarkBrush" select="'{x:Static SystemColors.ControlDarkBrush}'"/>
  <xsl:variable name="ControlDarkDarkBrush" select="'{x:Static SystemColors.ControlDarkDarkBrush}'"/>

  <!-- Custom Colors -->
  <xsl:variable name="fgBlue" select="'#005395'"/>
  <xsl:variable name="fgDarkBlue" select="'#005395'"/>
  <xsl:variable name="fgWhite" select="'#ffffff'"/>
  <xsl:variable name="bgWhite" select="'#ffffff'"/>

  <xsl:variable name="fgEdge" select="'#888888'"/>
  <xsl:variable name="bgLocked" select="'#ffffDD'"/>
  
  <xsl:variable name="TableHeader" select="'#0076c7'"/>
  <xsl:variable name="TableHeaderText" select="$fgWhite"/>
  <xsl:variable name="TableFill" select="$WindowBrush"/>
  <xsl:variable name="TableRule" select="'#a1a1a1'"/>
  <xsl:variable name="TableText" select="$WindowTextBrush"/>
  
  <xsl:variable name="Hyperlink" select="$fgBlue"/>
  <xsl:variable name="HyperlinkHot" select="'#7596C9'"/>
  
  <xsl:variable name="AssistantBanner" select="'#343941'"/>
  <xsl:variable name="AssistantBannerText" select="'#ffffff'"/>
  <xsl:variable name="AssistantFill" select="'#e2e2e2'"/>
  <xsl:variable name="AssistantText" select="'#444444'"/>
  <xsl:variable name="SampleBackground" select="$WindowBrush"/> <!--"'#eeeeee'"-->
  <xsl:variable name="SampleBorder" select="$WindowFrameBrush"/><!--"'#888888'"-->
  <xsl:variable name="SampleText" select="$WindowTextBrush"/>
  
  <xsl:variable name="StartPageDarkFill" select="'#eeeeee'"/>
  <xsl:variable name="StartPageTopRule" select="'#dddddd'"/>
  <xsl:variable name="StartPageRule" select="'#888888'"/>
  <xsl:variable name="StartPageLightRule" select="'#aaaaaa'"/>
  <xsl:variable name="StartPagePanel" select="'#cccccc'"/>
  <xsl:variable name="StartPageText" select="'#333333'"/>
  <xsl:variable name="StartPageGradientStart" select="'#586666aa'"/>
  <xsl:variable name="StartPageGradientStop" select="'#009999dd'"/>
  <xsl:variable name="StartPageRecentRule" select="'#b4c8da'"/>

  <xsl:template name="page-resources">
    <!-- Fonts -->
    <Style TargetType="TextBlock">
      <Setter Property="FontFamily" Value="Verdana"/>
      <Setter Property="FontSize" Value="8pt"/>
    </Style>
    <Style TargetType="Hyperlink">
      <Setter Property="Foreground" Value="{$Hyperlink}"/>
      <Style.Triggers>
        <Trigger Property="IsMouseOver" Value="True">
          <Trigger.Setters>
            <Setter Property="Foreground" Value="{$HyperlinkHot}"/>
          </Trigger.Setters>
        </Trigger>
      </Style.Triggers>
    </Style>
  </xsl:template>

  <!-- Our root is the Topic. Handle the title and provide a wrapper for the rest of the body. -->
  <xsl:template match="Topic[StartPage]">
    <Page>
      <xsl:apply-templates/>
    </Page>
  </xsl:template>

  <xsl:template match="Topic[folder]">
    <Page TextBlock.Foreground="{$ControlTextBrush}">
      <Page.Resources>
        <xsl:call-template name="page-resources"/>
      </Page.Resources>
      <Grid Background="{$WindowBrush}" TextBlock.Foreground="{$WindowTextBrush}">
        <!-- Top for folder pages -->
        <Grid.ColumnDefinitions>
          <xsl:if test="folder/@image"><ColumnDefinition Width="100"/></xsl:if>
          <xsl:if test="not(folder/@image)"><ColumnDefinition Width="8"/></xsl:if>
          <ColumnDefinition Width="*"/>
        </Grid.ColumnDefinitions>
        <Grid.RowDefinitions>
          <RowDefinition Height="40"/>
          <xsl:if test="folder/@image"><RowDefinition Height="64"/></xsl:if>
          <xsl:if test="not(folder/@image)"><RowDefinition Height="0"/></xsl:if>
          <RowDefinition Height="*"/>
        </Grid.RowDefinitions>
        <Border Grid.Row="0" Grid.Column="0" Grid.ColumnSpan="3" Background="{$fgBlue}"/>
        <Border Grid.Row="1" Grid.RowSpan="2" Grid.Column="0" Grid.ColumnSpan="2">
          <Image Source="file://{$folder}{folder/@image}" HorizontalAlignment="Right" VerticalAlignment="Bottom"/>
        </Border>
        <Image Grid.Column="0" Grid.Row="0" Grid.RowSpan="2" VerticalAlignment="Top" HorizontalAlignment="Left" Source="file://{$folder}{folder/@icon}"/>
        <TextBlock Grid.Column="1" FontSize="18pt" FontFamily="Trebuchet MS" Foreground="{$fgWhite}" Padding="8,2,8,4" TextWrapping="Wrap" VerticalAlignment="Center">
            <xsl:apply-templates select="folder" mode="show"/>
        </TextBlock>
        <TextBlock Grid.Column="1" Grid.Row="1" Padding="8,8,8,4" FontSize="9pt" TextWrapping="Wrap">
            <xsl:apply-templates select="banner" mode="show"/>
        </TextBlock>
        <ScrollViewer Grid.Column="1" Grid.Row="2" ClipToBounds="True" VerticalScrollBarVisibility="Auto">
          <StackPanel>
            <xsl:apply-templates/>
          </StackPanel>
        </ScrollViewer>
      </Grid>
    </Page>
  </xsl:template>

  <xsl:template match="Topic[assistant]">
    <Page TextBlock.Foreground="{$AssistantText}" TextBlock.FontFamily="Tahoma">
      <Page.Resources>
        <xsl:call-template name="page-resources"/>
      </Page.Resources>
      <Grid Background="{$AssistantFill}">
        <!-- Top for assistant pages -->
        <Grid.RowDefinitions>
          <RowDefinition Height="50"/>
          <RowDefinition Height="*"/>
        </Grid.RowDefinitions>
        <xsl:apply-templates/>
      </Grid>
    </Page>
  </xsl:template>

  <xsl:template match="Topic/assistant">
    <Grid Grid.Row="0" Background="{$AssistantBanner}">
      <Image HorizontalAlignment="Left" Source="file://{$folder}AssistantLeft.jpg"/>
      <Image HorizontalAlignment="Right" Source="file://{$folder}{@icon}" Margin="8,8,8,8"/>
    </Grid>
    <TextBlock Grid.Row="0" FontSize="18pt" FontFamily="Trebuchet MS" Foreground="{$AssistantBannerText}" VerticalAlignment="Center" Padding="16,8,16,8">
      <xsl:apply-templates/>
    </TextBlock>
  </xsl:template>

  <xsl:template match="Topic/body">
    <ScrollViewer Grid.Row="1" ClipToBounds="True" VerticalScrollBarVisibility="Auto">
      <Border Padding="8,8,8,8">
        <StackPanel>
          <xsl:apply-templates/>
        </StackPanel>
      </Border>
    </ScrollViewer>
  </xsl:template>

  <xsl:template match="Topic[not(StartPage) and not(folder) and not(assistant)]">
    <Page>
      <xsl:attribute name="MouseRightButtonUp">ShowContextMenu</xsl:attribute>

      <Page.Resources>
        <xsl:call-template name="page-resources"/>
      </Page.Resources>
      <Grid TextBlock.Foreground="{$ControlTextBrush}">
        <!-- Top banner for root pages -->
        <xsl:if test="banner">
          <xsl:variable name="icon">
            <xsl:choose>
              <xsl:when test="banner/@icon"><xsl:value-of select="banner/@icon"/></xsl:when>
              <xsl:otherwise>helppage.png</xsl:otherwise>
            </xsl:choose>
          </xsl:variable>
          <Grid.ColumnDefinitions>
            <ColumnDefinition Width="*"/>
            <ColumnDefinition Width="24"/>
          </Grid.ColumnDefinitions>
          <Grid.RowDefinitions>
            <RowDefinition Height="18"/>
            <RowDefinition/>
          </Grid.RowDefinitions>
          <TextBlock Grid.Column="0" FontWeight="Bold" Foreground="{$fgWhite}" Background="{$fgBlue}" Padding="4,2,4,2">
            <xsl:apply-templates select="banner" mode="show"/>
          </TextBlock>
          <xsl:if test="$icon"><Border Grid.Column="1" Background="{$fgBlue}"><Image Source="file://{$folder}{$icon}" Width="16" Height="16"/></Border></xsl:if>
        </xsl:if>
        <!-- Below banner -->
        <ScrollViewer ClipToBounds="True" VerticalScrollBarVisibility="Auto">
          <xsl:if test="banner">
            <xsl:attribute name="Grid.Row">1</xsl:attribute>
            <xsl:attribute name="Grid.ColumnSpan">2</xsl:attribute>
          </xsl:if>
          <StackPanel>
            <xsl:if test="banner">
              <xsl:attribute name="Margin">0,4,0,0</xsl:attribute>
            </xsl:if>
            <xsl:apply-templates/>
          </StackPanel>
        </ScrollViewer>
      </Grid>
    </Page>
  </xsl:template>

  <!-- generally suppress the banner, but show it when applied mode="show" -->
  <xsl:template match="banner"/>
  <xsl:template match="banner" mode="show">
    <xsl:apply-templates/>
  </xsl:template>

  <xsl:template match="locked">
    <Border Padding="4,4,4,4" Margin="8,8,12,8" BorderBrush="{$fgBlue}" Background="{$bgLocked}" BorderThickness="2">
    <Grid>
      <Grid.ColumnDefinitions>
        <ColumnDefinition Width="40"/>
        <ColumnDefinition Width="*"/>
      </Grid.ColumnDefinitions>
      <Image Grid.Column="0" Source="file://{$folder}IHelpLimitAnim.gif" Width="35" Height="35"/>
      <TextBlock TextWrapping="Wrap" Padding="8,0,8,0" FontWeight="Bold" FontSize="14" Grid.Column="1">
        <xsl:value-of select="string(.)"/>
        <xsl:if test="not(string(.))">This functionality is unavailable in the InstallShield Limited Edition.</xsl:if>
        <LineBreak/>
        <xsl:text>To evaluate or purchase a full edition of InstallShield, visit the </xsl:text>
        <Hyperlink Tag="link:http://www.installshield.com/visualstudio/upgrade.aspx">InstallShield Web site</Hyperlink>
        <xsl:text>.</xsl:text>
      </TextBlock>
    </Grid>
    </Border>
  </xsl:template>

  <!-- We show the title above, so suppress it when we encounter it. -->
  <xsl:template match="title"/>

  <!-- Project specific sections; project types are represented as one of the following in @is or @not:
        proj-msi proj-direct-msi
        proj-suite-prem and proj-suite-ui (use proj-suite when not differentiating)
        proj-ismsi proj-direct-ismsi
        proj-msm proj-direct-msm proj-dim
        proj-pro proj-obj-pro
        proj-mst proj-msp proj-pcp proj-quickpatch proj-unknown
        proj-express proj-lite proj-windowsce proj-clickonce
        proj-ltd-vs proj-ltd-unknown

       Product edition specific sections; product editions are represented as one of the following in @except or @only:
        ed-prem ed-pro ed-exp ed-dim ed-lim
  -->

  <xsl:template match="when">
    <xsl:if test="not($projecttype)">
      <xsl:apply-templates/>
    </xsl:if>
      <xsl:if test="$projecttype and (not(@not) or not(contains(@not, $projecttype))) and (not(@is) or contains(@is, $projecttype))">
      <xsl:if test="(not(@except) or not(contains(@except, $productedition))) and (not(@only) or contains(@only, $productedition))">
        <xsl:apply-templates/>
      </xsl:if>
    </xsl:if>
  </xsl:template>

  <!-- Headings -->
  <xsl:template match="h1|h2|h3|h4">
    <xsl:variable name="size">
      <xsl:choose>
        <xsl:when test="name() = 'h1'">18</xsl:when>
        <xsl:when test="name() = 'h2'">16</xsl:when>
        <xsl:when test="name() = 'h3'">14</xsl:when>
        <xsl:when test="name() = 'h4'">12</xsl:when>
      </xsl:choose>
    </xsl:variable>
    <xsl:variable name="style">
      <xsl:choose>
        <xsl:when test="name() = 'h1'">Normal</xsl:when>
        <xsl:when test="name() = 'h2'">Normal</xsl:when>
        <xsl:when test="name() = 'h3'">Normal</xsl:when>
        <xsl:when test="name() = 'h4'">Italic</xsl:when>
      </xsl:choose>
    </xsl:variable>

    <TextBlock FontSize="{$size}" FontWeight="Bold" FontStyle="{$style}" TextWrapping="Wrap" Padding="8,8,4,4">
      <xsl:apply-templates/>
    </TextBlock>
  </xsl:template>

  <!-- Render p (paragraph) as a wrapped textblock with vertical padding -->
  <xsl:template match="p">
    <TextBlock TextWrapping="Wrap" Padding="8,4,8,8">
      <xsl:apply-templates/>
    </TextBlock>
  </xsl:template>
  
  <xsl:template match="p" mode="inline">
    <xsl:apply-templates/>
  </xsl:template>

  <!-- Render p (paragraph) within lists without left margin (since lists already have a margin) -->
  <xsl:template match="dl//p|ul//p|ol//p">
    <TextBlock TextWrapping="Wrap" Padding="0,4,4,8">
      <xsl:apply-templates/>
    </TextBlock>
  </xsl:template>

  <!-- Tweak margins on p within table cells -->
  <xsl:template match="cell//p">
    <TextBlock TextWrapping="Wrap" Padding="2,2,2,2">
      <xsl:apply-templates/>
    </TextBlock>
  </xsl:template>

  <!-- Line breaks -->
  <xsl:template match="br">
    <LineBreak/>
  </xsl:template>

  <!-- turn q into left and right double-quotes -->
  <xsl:template match="q">
    &#x201c;<xsl:apply-templates/>&#x201d;
  </xsl:template>

  <!-- turn b into Bold -->
  <xsl:template match="b|strong|property|function|database|example|uielement">
    <Span FontWeight="Bold"><xsl:apply-templates/></Span>
  </xsl:template>

  <!-- turn em, Italic, variables into Italic -->
  <xsl:template match="i|em|variable|filename">
    <Span FontStyle="Italic"><xsl:apply-templates/></Span>
  </xsl:template>

  <!-- turn u into Underline -->
  <xsl:template match="u">
    <Underline><xsl:apply-templates/></Underline>
  </xsl:template>

  <!-- user input -->
  <xsl:template match="input">
    <Span FontFamily="Courier New" FontWeight="Bold"><xsl:apply-templates/></Span>
  </xsl:template>

  <!-- turn literal (lit), code, or directory path, command-line parameter/statement into Courier New font -->
  <xsl:template match="lit|code|directory|commandline">
    <Span FontFamily="Courier New"><xsl:apply-templates/></Span>
  </xsl:template>

  <!-- turn screen output into navy blue Courier New font -->
  <xsl:template match="screenoutput">
    <Span FontFamily="Courier New" Foreground="Navy"><xsl:apply-templates/></Span>
  </xsl:template>

  <!-- Sample Code or .ini file, with optional Copy Code link -->
  <xsl:template match="codeblock|inifile">
    <xsl:if test="@copy and @copy != 'N' ">
      <TextBlock HorizontalAlignment="Right" Padding="4,4,8,4">
        <Hyperlink>
          <Hyperlink.Tag>copy:<xsl:call-template name="replace-clipboard"/></Hyperlink.Tag>
          Copy to Clipboard
        </Hyperlink>
      </TextBlock>
    </xsl:if>
    <Border Background="{$SampleBackground}" BorderThickness="1" BorderBrush="{$SampleBorder}" TextBlock.Foreground="{$SampleText}" Margin="8,0,8,4">
      <TextBlock FontFamily="Courier New" Padding="4,4,4,4" TextWrapping="Wrap">
        <xsl:call-template name="replace-code"/>
      </TextBlock>
    </Border>
  </xsl:template>

  <!-- Definition lists... (render like bullets, with bold and emdash) Suppress dd as it's part of dt -->
  <xsl:template match="dl">
    <Border Padding="34,6,4,10">
      <StackPanel>
        <xsl:apply-templates/>
      </StackPanel>
    </Border>
  </xsl:template>
  <xsl:template match="dl//dt"/>
  <xsl:template match="dl//dd">
    <TextBlock Padding="0,4,4,4" TextWrapping="Wrap">
      <Image Source="file://{$folder}bullethelp.png" Width="5" Height="5" Margin="-11,-2,7,2"
      /><Bold><xsl:value-of select="preceding-sibling::dt[1]"/></Bold>&#x2014;<xsl:apply-templates/>
    </TextBlock>
  </xsl:template>

  <!-- lists, ordered and unordered
       optionally specify attribute ol/@number to control format. Suggested values: 1. A. a. I. i. -->
  <xsl:template match="ol|ul">
    <Grid>
      <Grid.ColumnDefinitions>
        <ColumnDefinition Width="24"/>
        <ColumnDefinition Width="*"/>
      </Grid.ColumnDefinitions>
      <Grid.RowDefinitions>
        <xsl:for-each select="li">
          <RowDefinition/>
        </xsl:for-each>
      </Grid.RowDefinitions>
      <xsl:apply-templates select="li"/>
    </Grid>
  </xsl:template>

  <xsl:template match="li">
    <xsl:variable name="me" select="."/>
    <xsl:if test="parent::ol">
      <xsl:variable name="number">
        <xsl:choose>
          <xsl:when test="../@number"><xsl:value-of select="../@number"/></xsl:when>
          <xsl:when test="count(ancestor::ol) = 1">1.</xsl:when>
          <xsl:when test="count(ancestor::ol) = 2">a.</xsl:when>
          <xsl:when test="count(ancestor::ol) &gt; 2">i.</xsl:when>
        </xsl:choose>
      </xsl:variable>
      <TextBlock Grid.Row="{position() - 1}" Grid.Column="0" Padding="0,4,4,4" HorizontalAlignment="Right">
        <xsl:number format="{$number}"/>
      </TextBlock>
    </xsl:if>
    <StackPanel Grid.Row="{position() - 1}" Grid.Column="1">
      <TextBlock Padding="0,4,4,4" TextWrapping="Wrap">
        <xsl:if test="parent::ul">
          <Image Source="file://{$folder}bullethelp.png" Width="5" Height="5" Margin="-11,-2,7,2"/>
        </xsl:if>
        <xsl:apply-templates/>
      </TextBlock>
      <xsl:apply-templates select="following-sibling::*[not(name() = 'li') and preceding-sibling::li[1] = $me]"/>
    </StackPanel>
  </xsl:template>
  
  <!-- turn help[@topic] into Hyperlink[@Tag]; @image specifies a limited edition placeholder image. -->
  <xsl:template match="help">
    <Hyperlink Tag="help:{@file}:{@topic}">
      <xsl:if test="@image"><xsl:attribute name="TextDecorations"/><Image Source="file://{$folder}{@image}"/></xsl:if>
      <xsl:apply-templates/>
    </Hyperlink>
  </xsl:template>

  <!-- turn link[@href or @action] into Hyperlink[@Tag] -->
  <xsl:template match="link">
    <Hyperlink>
      <xsl:attribute name="Tag">
        <xsl:if test="@href">link:<xsl:value-of select="@href"/></xsl:if>
        <xsl:if test="@action"><xsl:value-of select="@action"/>:<xsl:value-of select="@id"/></xsl:if>
      </xsl:attribute>
      <xsl:apply-templates/>
    </Hyperlink>
  </xsl:template>
  
  <!-- turn button[@action] into Button[@Clicked]; note {@action} must be connected with SetDelegate -->
  <xsl:template match="button[@action]">
    <Button Click="{@action}">
      <xsl:if test="@id"><xsl:attribute name="Tag"><xsl:value-of select="@id"/></xsl:attribute></xsl:if>
      <xsl:if test="@image"><xsl:attribute name="ToolTip"><xsl:apply-templates/></xsl:attribute><Image Source="file://{$folder}{@image}"/></xsl:if>
      <xsl:if test="not(@image)"><xsl:apply-templates/></xsl:if>
    </Button>
  </xsl:template>

  <!-- icon support -->
  <xsl:template match="icon">
    <xsl:choose>
      <xsl:when test="@small">
        <Image Source="file://{$folder}{@small}" Width="16" Height="16"/>
      </xsl:when>
      <xsl:when test="@button">
        <Image Source="file://{$folder}{@button}" Width="24" Height="24"/>
      </xsl:when>
      <xsl:when test="@normal">
        <Image Source="file://{$folder}{@normal}" Width="32" Height="32"/>
      </xsl:when>
    </xsl:choose>
  </xsl:template>

  <xsl:template match="preview[@source]">
    <xsl:variable name="source">
      <xsl:if test="not(contains(@source, ':')) and not(contains(@source, '\\\\'))">
        <xsl:value-of select="$folder"/>
      </xsl:if>
      <xsl:value-of select="@source"/>
    </xsl:variable>
    <Image Source="file://{$source}"/>
  </xsl:template>

  <!-- turn {note|tip|...}[/p] into note|tip|... text with image -->
  <xsl:template match="note|important|edition|tip|bprac|scriptonly|winlogo|procedure|project|warn">
    <!-- options that differ between types -->
    <xsl:variable name="image">
      <xsl:choose>
        <xsl:when test="name() = 'note'">note.png</xsl:when>
        <xsl:when test="name() = 'important'">important.png</xsl:when>
        <xsl:when test="name() = 'edition'">edition.png</xsl:when>
        <xsl:when test="name() = 'tip'">tip.png</xsl:when>
        <xsl:when test="name() = 'bprac'">bestpractice.png</xsl:when>
        <xsl:when test="name() = 'scriptonly'">installscriptonly.png</xsl:when>
        <xsl:when test="name() = 'procedure'">procedure.png</xsl:when>
        <xsl:when test="name() = 'project'">projectspecific.png</xsl:when>
        <xsl:when test="name() = 'warn'">warning.png</xsl:when>
        <xsl:when test="name() = 'winlogo'">logo.png</xsl:when>
      </xsl:choose>
    </xsl:variable>
    <xsl:variable name="caption">
      <xsl:choose>
        <xsl:when test="name() = 'note'">Note</xsl:when>
        <xsl:when test="name() = 'important'">Important</xsl:when>
        <xsl:when test="name() = 'edition'">Edition</xsl:when>
        <xsl:when test="name() = 'tip'">Tip</xsl:when>
        <xsl:when test="name() = 'bprac'">Best Practice</xsl:when>
        <xsl:when test="name() = 'scriptonly'">InstallScript Only</xsl:when>
        <xsl:when test="name() = 'procedure'"><xsl:if test="task"><xsl:value-of select="task/."/></xsl:if><xsl:if test="not(task)">Task</xsl:if></xsl:when>
        <xsl:when test="name() = 'project'">Project</xsl:when>
        <xsl:when test="name() = 'warn'">Caution</xsl:when>
        <xsl:when test="name() = 'winlogo'">Logo</xsl:when>
      </xsl:choose>
    </xsl:variable>

    <Border
        Margin="4,4,4,0"
        Padding="4,0,4,0"
        MinHeight="28"
        Background="{$WindowBrush}"
        TextBlock.Foreground="{$WindowTextBrush}"
        CornerRadius="3">
      <Grid>
        <Grid.ColumnDefinitions>
          <ColumnDefinition Width="20"/>
          <ColumnDefinition Width="*"/>
        </Grid.ColumnDefinitions>
        <Image
            Grid.Column="0"
            Margin="4,4,-4,-4"
            Source="file://{$folder}{$image}"
            Width="20" Height="20"
            VerticalAlignment="Top"/>
        <StackPanel Grid.Column="1" VerticalAlignment="Center">
          <!-- Run caption into the first <p/> or <task/> of text (via mode="inline")-->
          <TextBlock TextWrapping="Wrap" Padding="8,4,8,8">
            <Bold><xsl:value-of select="$caption"/></Bold><xsl:if test="not($caption = task/.)"> &#8226; 
            <xsl:apply-templates select="*[position() = 1]" mode="inline"/></xsl:if>
          </TextBlock>
          <xsl:apply-templates select="*[position() &gt; 1]"/>
        </StackPanel>
      </Grid>
    </Border>
  </xsl:template>

  <xsl:template match="procedure//task" mode="inline"/>
  
  <!-- Tables -->
  <xsl:template match="table">
    <Border Margin="4,4,4,4">
      <Grid Background="{$TableFill}" TextBlock.Foreground="{$TableText}">
        <Grid.ColumnDefinitions>
          <xsl:for-each select="row/header">
            <ColumnDefinition>
              <xsl:if test="@width"><xsl:attribute name="Width"><xsl:value-of select="@width"/></xsl:attribute></xsl:if>
              <xsl:if test="@min"><xsl:attribute name="MinWidth"><xsl:value-of select="@min"/></xsl:attribute></xsl:if>
              <xsl:if test="@max"><xsl:attribute name="MaxWidth"><xsl:value-of select="@max"/></xsl:attribute></xsl:if>
              <xsl:if test="not(@width) and not(@min) and not(@max)"><xsl:attribute name="Width">*</xsl:attribute></xsl:if>
            </ColumnDefinition>
          </xsl:for-each>
        </Grid.ColumnDefinitions>
        <Grid.RowDefinitions>
          <xsl:for-each select="row">
            <RowDefinition/>
          </xsl:for-each>
        </Grid.RowDefinitions>

        <xsl:for-each select="row">
          <xsl:variable name="row" select="position() - 1"/>
          <xsl:for-each select="header">
            <xsl:variable name="col" select="position() - 1"/>
            <Border Background="{$TableHeader}" Grid.Column="{$col}" Grid.Row="{$row}" Padding="4,4,4,4" BorderThickness="0,1,0,1" BorderBrush="{$TableRule}">
              <TextBlock TextWrapping="Wrap" FontWeight="Bold" Foreground="{$TableHeaderText}"><xsl:apply-templates select="."/></TextBlock>
            </Border>
          </xsl:for-each>
          <xsl:for-each select="cell">
            <xsl:variable name="col" select="position() - 1"/>
            <Border Grid.Column="{$col}" Grid.Row="{$row}" Padding="4,2,4,2" BorderThickness="0,0,0,1" BorderBrush="{$TableRule}">
              <StackPanel><xsl:apply-templates/></StackPanel>
            </Border>
          </xsl:for-each>
        </xsl:for-each>
      </Grid>
    </Border>
  </xsl:template>

  <!-- Limited Edition feature comparisons -->
  <xsl:template match="fc:chart">
    <Border Margin="4,4,4,4">
      <Grid>
        <Grid.ColumnDefinitions>
          <ColumnDefinition MinWidth="120"/>
          <xsl:for-each select="fc:edition">
            <ColumnDefinition MinWidth="120"/>
          </xsl:for-each>
        </Grid.ColumnDefinitions>
        <Grid.RowDefinitions>
          <RowDefinition/>
          <RowDefinition/>
          <xsl:for-each select="fc:feature">
            <RowDefinition/>
          </xsl:for-each>
        </Grid.RowDefinitions>

        <!-- Top rows: edition name, description, try it now button -->
        <xsl:for-each select="fc:edition">
          <Border Background="#0071bc" BorderBrush="#ffffff" BorderThickness="0,1,1,1" Grid.Column="{position()}" Grid.Row="0" Padding="10,10,10,10">
            <TextBlock TextWrapping="Wrap" FontSize="12pt" FontWeight="Bold" Foreground="#ffffff" TextAlignment="Center"><xsl:value-of select="@name"/></TextBlock>
          </Border>
          <Border BorderBrush="#e0e0e0" BorderThickness="0,0,1,1" Grid.Column="{position()}" Grid.Row="1" Padding="10,10,10,10">
            <DockPanel>
              <Border DockPanel.Dock="Bottom" Margin="0,16,0,0">
                <TextBlock HorizontalAlignment="Center">
                  <Hyperlink TextDecorations="" Tag="link:{@try}">
                    <Border Padding="15,4,10,4" BorderBrush="#f8c53e" BorderThickness="1" Background="#feca40">
                      <TextBlock FontSize="10pt" Foreground="Black">Try it now <Bold>&#x203a;</Bold></TextBlock>
                    </Border>
                  </Hyperlink>
                </TextBlock>
              </Border>
              <TextBlock TextWrapping="Wrap" FontSize="10pt" Foreground="Black" TextAlignment="Center"><xsl:apply-templates/></TextBlock>
            </DockPanel>
          </Border>
        </xsl:for-each>

        <!-- Header - text is optional, but the border is necessary for graphic renditions -->
        <Border Grid.Row="1" BorderBrush="#e0e0e0" BorderThickness="0,0,1,1">
          <xsl:if test="fc:header">
            <TextBlock Margin="8,4,4,8" FontSize="10pt" FontWeight="Bold" TextWrapping="Wrap" VerticalAlignment="Bottom">
              <xsl:value-of select="fc:header/."/>
            </TextBlock>
          </xsl:if>
        </Border>

        <!-- Rows of features, empty if no attribute, check if empty attribute, value if non-empty attribute -->
        <xsl:for-each select="fc:feature">
          <xsl:variable name="row" select="position() + 1"/>
          <xsl:variable name="feature" select="."/>
          <Border BorderBrush="#e0e0e0" BorderThickness="1,0,1,1" Grid.Column="0" Grid.Row="{$row}" Padding="8,8,8,8">
            <TextBlock TextWrapping="Wrap" Foreground="Black"><xsl:apply-templates/></TextBlock>
          </Border>
          <xsl:for-each select="../fc:edition">
            <xsl:variable name="edition" select="@key"/>
            <Border BorderBrush="#e0e0e0" BorderThickness="0,0,1,1" Grid.Column="{position()}" Grid.Row="{$row}" Padding="4,4,4,4">
              <xsl:for-each select="$feature/@*[name() = $edition]">
                <xsl:if test=". != '' "><TextBlock TextAlignment="Center" FontSize="10pt" FontWeight="Bold" Text="{.}"/></xsl:if>
                <xsl:if test=". = '' "><Image Source="file://{$folder}check.png"/></xsl:if>
              </xsl:for-each>
            </Border>
          </xsl:for-each>
        </xsl:for-each>
      </Grid>
    </Border>
  </xsl:template>

  <!-- root folders... -->
  <xsl:template match="folder"/>
  <xsl:template match="folder" mode="show">
    <xsl:apply-templates/>
  </xsl:template>

  <xsl:template match="view">
    <DockPanel HorizontalAlignment="Stretch" LastChildFill="true" Margin="0,8,20,2">
      <TextBlock DockPanel.Dock="Left" Padding="4,2,4,34">
        <xsl:if test=".//goto/@view"><Hyperlink TextDecorations="" Tag="goto:{.//goto/@view}"><Image Source="file://{$folder}{@icon}"/></Hyperlink></xsl:if>
        <xsl:if test=".//goto/@topic"><Hyperlink TextDecorations="" Tag="help:{.//goto/@file}:{goto/@topic}"><Image Source="file://{$folder}{@icon}"/></Hyperlink></xsl:if>
        <xsl:if test=".//goto/@href"><Hyperlink TextDecorations="" Tag="link:{.//goto/@href}"><Image Source="file://{$folder}{@icon}"/></Hyperlink></xsl:if>
      </TextBlock>
      <StackPanel Orientation="Vertical">
        <xsl:apply-templates/>
      </StackPanel>
    </DockPanel>
  </xsl:template>

  <xsl:template match="view//goto">
    <TextBlock FontWeight="Bold" FontSize="9pt" Margin="0,2,0,0">
      <xsl:if test="@view"><Hyperlink Tag="goto:{@view}"><xsl:apply-templates/></Hyperlink></xsl:if>
      <xsl:if test="@count"><Span FontWeight="Normal">&#xA0;(<Run x:Name="{@count}"/>)</Span></xsl:if>
      <xsl:if test="@topic"><Hyperlink Tag="help:{@file}:{@topic}"><xsl:apply-templates/></Hyperlink></xsl:if>
      <xsl:if test="@href"><Hyperlink Tag="link:{@href}"><xsl:apply-templates/></Hyperlink></xsl:if>
    </TextBlock>
  </xsl:template>

  <xsl:template match="view//p">
    <TextBlock TextWrapping="Wrap" Margin="0,4,0,0">
      <xsl:apply-templates/>
    </TextBlock>
  </xsl:template>

  <xsl:template match="view//help">
    <TextBlock FontStyle="Italic" Margin="0,4,28,0">
      <Hyperlink Tag="help:{@file}:{@topic}"><xsl:apply-templates/></Hyperlink>
    </TextBlock>
  </xsl:template>

  <xsl:template match="seealso">
    <TextBlock Foreground="{$fgBlue}" Padding="0,4,4,4" FontWeight="Bold" FontSize="9pt">See Also</TextBlock>
    <Border BorderBrush="{$fgBlue}" BorderThickness="1" Margin="0,2,8,2"/>
    <xsl:apply-templates/>
  </xsl:template>

  <xsl:template match="seealso//goto">
    <TextBlock Margin="4,4,4,4" FontSize="8pt">
      <Hyperlink TextDecorations="" Tag="goto:{@view}">
        <Image Source="file://{$folder}{@icon}"/>
        <Run TextDecorations="Underline" BaselineAlignment="Center"><xsl:apply-templates/></Run>
      </Hyperlink>
    </TextBlock>
  </xsl:template>

  <!-- Start Page -->
  <xsl:template name="startpage-resources">
    <LinearGradientBrush x:Key="TaskGradient" StartPoint="0,0" EndPoint="0,1">
      <GradientStop Color="{$StartPageLightRule}" Offset="0"/>
      <GradientStop Color="{$fgEdge}" Offset="0.25"/>
      <GradientStop Color="{$StartPageLightRule}" Offset="1"/>
    </LinearGradientBrush>
    <Style TargetType="Hyperlink">
      <Setter Property="Foreground" Value="{$StartPageText}"/>
      <Setter Property="TextDecorations" Value=""/>
      <Style.Triggers>
        <Trigger Property="IsMouseOver" Value="True">
          <Trigger.Setters>
            <Setter Property="Foreground" Value="{$HyperlinkHot}"/>
            <Setter Property="TextDecorations" Value="Underline"/>
          </Trigger.Setters>
        </Trigger>
      </Style.Triggers>
    </Style>
  </xsl:template>

  <xsl:template match="StartPage">
    <Grid TextBlock.FontFamily="Tahoma" VerticalAlignment="Stretch">

      <Grid.Resources>
        <xsl:call-template name="startpage-resources"/>
        <Style TargetType="TextBlock">
          <Setter Property="Foreground" Value="{$StartPageText}"/>
        </Style>
      </Grid.Resources>

      <Grid.ColumnDefinitions>
        <ColumnDefinition MinWidth="150" MaxWidth="197"/>
        <ColumnDefinition Width="2*"/>
        <ColumnDefinition MinWidth="130" MaxWidth="161"/>
      </Grid.ColumnDefinitions>
      <Grid.RowDefinitions>
        <RowDefinition Height="20"/>
        <RowDefinition Height="40"/>
        <RowDefinition Height="20"/>
        <RowDefinition Height="*"/>
      </Grid.RowDefinitions>

      <Border Grid.RowSpan="4" Grid.ColumnSpan="3" Background="{$StartPageDarkFill}"/>
      <Border Grid.RowSpan="4" Grid.ColumnSpan="3" Background="{$StartPagePanel}" BorderBrush="{$StartPageTopRule}" BorderThickness="2,2,2,0" CornerRadius="15,15,0,0" Margin="-3,8,-3,0"/>
      <Border Grid.RowSpan="4" Grid.ColumnSpan="3" Background="{$StartPagePanel}" BorderBrush="{$StartPageRule}" BorderThickness="1,1,1,0" CornerRadius="13,13,0,0" Margin="0,10,0,0"/>

      <Border Grid.Row="0" Grid.RowSpan="2" Grid.Column="1" Grid.ColumnSpan="2" BorderBrush="{$StartPageRule}" BorderThickness="1" CornerRadius="40,0,0,0" Margin="0,0,-1,-1">
        <Border.Background>
          <LinearGradientBrush StartPoint="0,0" EndPoint="0,1">
            <GradientStop Color="{$StartPageGradientStart}" Offset="0"/>
            <GradientStop Color="{$StartPageGradientStop}" Offset="1"/>
          </LinearGradientBrush>
        </Border.Background>
      </Border>
      <StackPanel Grid.Row="1" Grid.Column="1" Orientation="Horizontal" TextBlock.FontSize="23pt" TextBlock.FontFamily="Arial" Margin="40,0,0,0">
        <!-- Hack for better spacing of InstallShield 2016 - we should probably use an image or better yet redesign the start page -->
          <TextBlock Text="I" Margin="0,0,0,0"/>
          <TextBlock Text="n" Margin="-2,0,0,0"/>
          <TextBlock Text="s" Margin="-1,0,0,0"/>
          <TextBlock Text="t" Margin="-1,0,0,0"/>
          <TextBlock Text="a" Margin="-1,0,0,0"/>
          <TextBlock Text="l" Margin="-1,0,0,0"/>
          <TextBlock Text="l" Margin="-1,0,0,0"/>
          <TextBlock Text="S" Margin="-2,0,0,0"/>
          <TextBlock Text="h" Margin="-2,0,0,0"/>
          <TextBlock Text="i" Margin="-2,0,0,0"/>
          <TextBlock Text="e" Margin="-1,0,0,0"/>
          <TextBlock Text="l" Margin="-1,0,0,0"/>
          <TextBlock Text="d" Margin="-1,0,0,0"/>
          <TextBlock Margin="-1,3,0,0"><Run BaselineAlignment="Superscript" FontSize="7pt">&#174;</Run></TextBlock>
          <TextBlock Text="2" Margin="6,0,0,0"/>
          <TextBlock Text="0" Margin="-1,0,0,0"/>
          <TextBlock Text="1" Margin="-1,0,0,0"/>
          <TextBlock Text="6" Margin="-1,0,0,0"/>
      </StackPanel>
      <Border Grid.Row="2" Grid.Column="1" Grid.ColumnSpan="2" Background="{$fgBlue}"/>
      <Border Grid.Row="3" Grid.Column="2" Background="{$StartPagePanel}"/>
      <Border Grid.Row="2" Grid.RowSpan="2" Grid.Column="2" BorderThickness="2,2,0,0" BorderBrush="{$StartPageLightRule}" Margin="0,12,-2,-2" CornerRadius="20,0,0,0"/>

      <StackPanel Grid.Row="2" Grid.RowSpan="3" Grid.Column="0">
        <ScrollViewer x:Name="LogoImage" VerticalScrollBarVisibility="Disabled" Margin="0, 5, 0, 10"/>
        <xsl:apply-templates select="TaskBox"/>
      </StackPanel>

      <Border Grid.Row="3" Grid.Column="1" BorderBrush="{$StartPageRule}" BorderThickness="1,0,0,0">
        <Border Background="{$bgWhite}" BorderBrush="{$StartPagePanel}" BorderThickness="0,0,6,0">
          <StackPanel Grid.Row="3" Grid.Column="1">
            <TextBlock FontSize="36pt" TextAlignment="Right" Margin="0,-10,12,0" Foreground="{$StartPagePanel}">get started</TextBlock>
            <ScrollViewer x:Name="svRecPrjs" VerticalScrollBarVisibility="Auto"/>
            <TextBlock FontSize="8pt" Margin="18,36,18,4" Foreground="{$StartPageText}" TextWrapping="Wrap">
              <Hyperlink Tag="help::IHelpGetStart.htm" FontWeight="Bold">Getting Started</Hyperlink><LineBreak/><LineBreak/>
              Not sure where to begin? Click the <Hyperlink Tag="help::IHelpGetStart.htm">Getting Started</Hyperlink> link to enter the world of installation creation technology using InstallShield.
            </TextBlock>
          </StackPanel>
        </Border>
      </Border>

      <StackPanel Grid.Row="4" Grid.RowSpan="2" Grid.Column="2" Margin="1,0,0,0">
        <xsl:apply-templates select="ResourceBox"/>
      </StackPanel>
    </Grid>
  </xsl:template>

  <!-- intended to be called direct from start page handler, to stuff in svRecPrjs above -->
  <xsl:template match="RecentProjects">
    <Grid>
      <Grid.Resources>
        <xsl:call-template name="startpage-resources"/>
        <Style TargetType="TextBlock">
          <Setter Property="FontSize" Value="8pt"/>
          <Setter Property="Foreground" Value="{$StartPageText}"/>
          <Setter Property="Margin" Value="0,4,0,4"/>
        </Style>
        <Style TargetType="Image">
          <Setter Property="Margin" Value="0,2,0,4"/>
        </Style>
      </Grid.Resources>
      <Grid.ColumnDefinitions>
        <ColumnDefinition Width="18"/>
        <ColumnDefinition Width="23"/>
        <ColumnDefinition Width="4*" MinWidth="100"/>
        <ColumnDefinition Width="2*" MinWidth="50"/>
        <ColumnDefinition Width="3*" MinWidth="50"/>
        <ColumnDefinition Width="18"/>
      </Grid.ColumnDefinitions>
      <Grid.RowDefinitions>
        <RowDefinition Height="auto" MinHeight="30"/>
        <xsl:for-each select="Project">
          <RowDefinition Height="auto" MinHeight="24"/>
        </xsl:for-each>
      </Grid.RowDefinitions>
      <Border Grid.Row="0" Grid.Column="0" Grid.ColumnSpan="6" BorderThickness="0,0,0,2" BorderBrush="{$StartPageRecentRule}"/>
      <TextBlock Grid.Row="0" Grid.Column="1" Grid.ColumnSpan="2" FontSize="14pt" Foreground="{$StartPagePanel}" Padding="0,12,0,2">name</TextBlock>
      <TextBlock Grid.Row="0" Grid.Column="3" FontSize="14pt" Foreground="{$StartPagePanel}" Padding="0,12,0,2">type</TextBlock>
      <TextBlock Grid.Row="0" Grid.Column="4" FontSize="14pt" Foreground="{$StartPagePanel}" Padding="0,12,0,2">modified</TextBlock>
      <xsl:apply-templates select="Project" mode="Recent"/>
    </Grid>
  </xsl:template>

  <xsl:template match="Project" mode="Recent">
    <Border Grid.Row="{position()}" Grid.Column="0" Grid.ColumnSpan="6" BorderThickness="0,0,0,2" BorderBrush="{$StartPageRecentRule}"/>
    <Image Grid.Row="{position()}" Grid.Column="1" Width="16" Height="16" HorizontalAlignment="Left" VerticalAlignment="Top" Margin="0,4,0,4" Source="{@Icon}"/>
    <TextBlock Grid.Row="{position()}" Grid.Column="2" TextWrapping="Wrap" Padding="0,2,4,2">
      <Hyperlink Tag="OpenPrj:{@File}" ToolTip="{@File}"><xsl:value-of select="@Name"/></Hyperlink>
    </TextBlock>
    <TextBlock Grid.Row="{position()}" Grid.Column="3" TextWrapping="Wrap" Padding="0,2,4,2"><xsl:value-of select="@Type"/></TextBlock>
    <TextBlock Grid.Row="{position()}" Grid.Column="4" TextWrapping="NoWrap" Padding="0,2,0,2"><xsl:value-of select="@Modified"/></TextBlock>
  </xsl:template>

  <xsl:template match="StartPage//TaskBox">
    <Border Background="{{StaticResource TaskGradient}}" CornerRadius="9,9,0,0" BorderThickness="2,2,2,0" BorderBrush="{$fgEdge}" Margin="4,16,8,0" Padding="6,4,6,4">
      <xsl:apply-templates select="Title"/>
    </Border>
    <Border BorderThickness="2,0,2,2" CornerRadius="0,0,1,1" BorderBrush="{$fgEdge}" Margin="4,0,8,8">
      <Border Background="{$StartPageDarkFill}" BorderBrush="{$StartPageLightRule}" BorderThickness="2,0,2,2" Padding="4,16,4,16">
        <StackPanel Margin="2">
          <xsl:apply-templates select="Task"/>
        </StackPanel>
      </Border>
    </Border>
  </xsl:template>

  <xsl:template match="TaskBox//Title">
    <TextBlock Foreground="{$fgWhite}" FontWeight="Bold" FontSize="8pt"><xsl:apply-templates/></TextBlock>
  </xsl:template>

  <xsl:template match="TaskBox//Task">
    <xsl:variable name="icon">
      <xsl:if test="@Icon"><xsl:value-of select="@Icon"/></xsl:if>
      <xsl:if test="not(@Icon)">HelpPage.png</xsl:if>
    </xsl:variable>
    <DockPanel Margin="4,4,4,2">
      <xsl:if test="@Cmd='cmdShowCEIP'"><xsl:attribute name="x:Name" namespace="http://schemas.microsoft.com/winfx/2006/xaml">JoinCEIP</xsl:attribute></xsl:if>
      <Image DockPanel.Dock="Left" Source="file://{$folder}{$icon}" Width="16" Height="16" VerticalAlignment="Top"/>

      <TextBlock TextWrapping="Wrap" FontSize="8pt" Margin="4,2,0,2">
        <xsl:choose>
          <xsl:when test="@Cmd">
            <Hyperlink Tag="cmd:{@Cmd}"><xsl:apply-templates/></Hyperlink>
          </xsl:when>
          <xsl:when test="@Browse">
            <Hyperlink Tag="SamplesBrowse:"><xsl:apply-templates/></Hyperlink>
          </xsl:when>
          <xsl:otherwise>
            <xsl:apply-templates/>
          </xsl:otherwise>
        </xsl:choose>
      </TextBlock>
    </DockPanel>
  </xsl:template>

  <xsl:template match="StartPage//ResourceBox">
    <StackPanel Margin="2,20,0,0">
      <xsl:apply-templates/>
    </StackPanel>
  </xsl:template>

  <xsl:template match="ResourceBox//Title">
    <Border Background="{$bgWhite}" Margin="-1,8,0,8" Padding="4,2,4,2"><TextBlock FontWeight="Bold" FontSize="8pt"><xsl:apply-templates/></TextBlock></Border>
  </xsl:template>

  <xsl:template match="ResourceBox//Resource">
    <DockPanel Margin="4,4,4,0">
      <xsl:if test="@Cmd='cmdShowCEIP'"><xsl:attribute name="x:Name" namespace="http://schemas.microsoft.com/winfx/2006/xaml">JoinCEIP</xsl:attribute></xsl:if>
      <Image DockPanel.Dock="Left" Source="file://{$folder}bullethelp.png" Margin="0,7,1,2" Width="5" Height="5" VerticalAlignment="Top"/>
      <TextBlock TextWrapping="Wrap" FontSize="8pt" Margin="4,2,0,2">
        <xsl:choose>
          <xsl:when test="@Cmd">
            <Hyperlink Tag="cmd:{@Cmd}"><xsl:apply-templates/></Hyperlink>
          </xsl:when>
          <xsl:when test="@Browse">
            <Hyperlink Tag="SamplesBrowse:"><xsl:apply-templates/></Hyperlink>
          </xsl:when>
          <xsl:otherwise>
            <xsl:apply-templates/>
          </xsl:otherwise>
        </xsl:choose>
      </TextBlock>
    </DockPanel>
  </xsl:template>

  <!-- functional template - implements replace(s, a, b) -->
  <xsl:template name="replace">
    <xsl:param name="source"/>
    <xsl:param name="from"/>
    <xsl:param name="to"/>
    <xsl:choose>
      <xsl:when test="''"/>
      <xsl:when test="contains($source, $from)">
        <xsl:value-of select="substring-before($source, $from)"/>
        <xsl:copy-of select="$to"/>
        <xsl:call-template name="replace">
          <xsl:with-param name="source" select="substring-after($source, $from)"/>
          <xsl:with-param name="from" select="$from"/>
          <xsl:with-param name="to" select="$to"/>
        </xsl:call-template>
      </xsl:when>
      <xsl:otherwise>
        <xsl:value-of select="$source"/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <!-- functional template - implements multi-replace(s, 'a|b|c', 'd|e|f') -->
  <xsl:template name="multi-replace">
    <xsl:param name="source"/>
    <xsl:param name="fromlist"/>
    <xsl:param name="tolist"/>
    <xsl:param name="sep" select="'|'"/>
    <xsl:choose>
      <xsl:when test="contains($fromlist, $sep)">
        <xsl:variable name="from" select="substring-before($fromlist, $sep)"/>
        <xsl:variable name="to" select="substring-before($tolist, $sep)"/>
        <xsl:variable name="fromrest" select="substring-after($fromlist, $sep)"/>
        <xsl:variable name="torest" select="substring-after($tolist, $sep)"/>
        <xsl:choose>
          <xsl:when test="contains($source, $from)">
            <xsl:call-template name="multi-replace">
              <xsl:with-param name="source" select="substring-before($source, $from)"/>
              <xsl:with-param name="fromlist" select="$fromlist"/>
              <xsl:with-param name="tolist" select="$tolist"/>
              <xsl:with-param name="sep" select="$sep"/>
            </xsl:call-template>
            <xsl:choose>
              <xsl:when test="starts-with($to, '&lt;')">
                <xsl:element name="{substring($to, 2, string-length($to) - 3)}"/>
              </xsl:when>
              <xsl:otherwise>
                <xsl:value-of select="$to"/>
              </xsl:otherwise>
            </xsl:choose>
            <xsl:call-template name="multi-replace">
              <xsl:with-param name="source" select="substring-after($source, $from)"/>
              <xsl:with-param name="fromlist" select="$fromlist"/>
              <xsl:with-param name="tolist" select="$tolist"/>
              <xsl:with-param name="sep" select="$sep"/>
            </xsl:call-template>
          </xsl:when>
          <xsl:otherwise>
            <xsl:call-template name="multi-replace">
              <xsl:with-param name="source" select="$source"/>
              <xsl:with-param name="fromlist" select="$fromrest"/>
              <xsl:with-param name="tolist" select="$torest"/>
              <xsl:with-param name="sep" select="$sep"/>
            </xsl:call-template>
          </xsl:otherwise>
        </xsl:choose>
      </xsl:when>
      <xsl:otherwise>
        <xsl:choose>
          <xsl:when test="contains($source, $fromlist)">
            <xsl:value-of select="substring-before($source, $fromlist)"/>
            <xsl:choose>
              <xsl:when test="starts-with($tolist, '&lt;')">
                <xsl:element name="{substring($tolist, 2, string-length($tolist) - 3)}"/>
              </xsl:when>
              <xsl:otherwise>
                <xsl:value-of select="$tolist"/>
              </xsl:otherwise>
            </xsl:choose>
            <xsl:call-template name="multi-replace">
              <xsl:with-param name="source" select="substring-after($source, $fromlist)"/>
              <xsl:with-param name="fromlist" select="$fromlist"/>
              <xsl:with-param name="tolist" select="$tolist"/>
              <xsl:with-param name="sep" select="$sep"/>
            </xsl:call-template>
          </xsl:when>
          <xsl:otherwise>
            <xsl:value-of select="$source"/>
          </xsl:otherwise>
        </xsl:choose>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <!-- helper; for visible use: replace \n with <LineBreak/> -->
  <xsl:template name="replace-code">
    <xsl:param name="base" select="."/>
    <xsl:call-template name="multi-replace">
      <xsl:with-param name="source" select="$base"/>
      <xsl:with-param name="fromlist" select="'&#13;&#10;|&#32;|&#09;'"/>
      <xsl:with-param name="tolist" select="'&lt;LineBreak/&gt;|&#160;|&#160;&#160;&#160;&#160;'"/>
    </xsl:call-template>
  </xsl:template>

  <!-- helper; for invisible use: replace individual characters -->
  <xsl:template name="replace-clipboard">
    <xsl:param name="base" select="."/>
    <xsl:call-template name="multi-replace">
      <xsl:with-param name="source" select="$base"/>
      <xsl:with-param name="fromlist" select="'%|&#13;&#10;|&#32;|&#09;'"/>
      <xsl:with-param name="tolist" select="'%25|%0D%0A|%20|%09'"/>
    </xsl:call-template>
  </xsl:template>

</xsl:stylesheet>