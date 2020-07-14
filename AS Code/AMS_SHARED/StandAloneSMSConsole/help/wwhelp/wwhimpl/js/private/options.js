// Copyright (c) 2001-2003 Quadralay Corporation.  All rights reserved.
//

function  WWHJavaScriptSettings_Object()
{
  this.mHoverText = new WWHJavaScriptSettings_HoverText_Object();

  this.mTabs   = new WWHJavaScriptSettings_Tabs_Object();
  this.mTOC    = new WWHJavaScriptSettings_TOC_Object();
  this.mIndex  = new WWHJavaScriptSettings_Index_Object();
  this.mSearch = new WWHJavaScriptSettings_Search_Object();
}

function  WWHJavaScriptSettings_HoverText_Object()
{
  this.mbEnabled = true;

  this.mFontStyle = "font-family: Tahoma, Verdana, Arial, Helvetica, sans-serif ; font-size: 8pt";

  this.mWidth = 150;

  this.mForegroundColor = "#000000";
  this.mBackgroundColor = "#EDF4FC";
  this.mBorderColor     = "#C2C2C2";
}

function  WWHJavaScriptSettings_Tabs_Object()
{
  this.mFontStyle = "font-family: Tahoma, Verdana, Arial, Helvetica, sans-serif ; font-size: 8pt; font-weight: bold";

  this.mSelectedTabColor       = "#EDF4FC";
  this.mSelectedTabBorderColor = "#EDF4FC";
  this.mSelectedTabTextColor   = "#003399";

  this.mDefaultTabColor       = "#003399";
  this.mDefaultTabBorderColor = "#ffffff";
  this.mDefaultTabTextColor   = "#ffffff";
}

function  WWHJavaScriptSettings_TOC_Object()
{
  this.mbShow = true;

  this.mFontStyle = "font-family: Tahoma, Verdana, Arial, Helvetica, sans-serif ; font-size: 8pt";

  this.mHighlightColor = "#EDF4FC";
  this.mEnabledColor   = "#000000";
  this.mDisabledColor  = "#000000";

  this.mIndent = 17;
}

function  WWHJavaScriptSettings_Index_Object()
{
  this.mbShow = true;

  this.mFontStyle = "font-family: Tahoma, Verdana, Arial, Helvetica, sans-serif ; font-size: 8pt";

  this.mHighlightColor = "#EDF4FC";
  this.mEnabledColor   = "#000000";
  this.mDisabledColor  = "#000000";

  this.mIndent = 17;

  this.mNavigationFontStyle      = "font-family: Tahoma, Verdana, Arial, Helvetica, sans-serif ; font-size: 8pt";
  this.mNavigationCurrentColor   = "black";
  this.mNavigationHighlightColor = "#2657A6";
  this.mNavigationEnabledColor   = "#2657A6";
  this.mNavigationDisabledColor  = "#999999";
}

function  WWHJavaScriptSettings_Index_DisplayOptions(ParamIndexOptions)
{
  ParamIndexOptions.fSetThreshold(500);
  ParamIndexOptions.fSetSeperator(" - ");
}

function  WWHJavaScriptSettings_Search_Object()
{
  this.mbShow = true;

  this.mFontStyle = "font-family: Tahoma, Verdana, Arial, Helvetica, sans-serif ; font-size: 8pt";

  this.mHighlightColor = "#EDF4FC";
  this.mEnabledColor   = "#000000";
  this.mDisabledColor  = "#000000";

  this.mIndent = 17;

  this.mbResultsByBook = true;
  this.mbShowRank      = true;
}
