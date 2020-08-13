del ..\..\*.txt
del /F "C:\AdminStudio\DailyBuildResult\buildError.txt"
del /F "C:\Documents and Settings\ReleaseEngineer.MACROVISION\p4tickets.txt"
del /F "C:\Documents and Settings\ReleaseEngineer.MACROVISION\p4tickets.txt"
ant -l "C:\AdminStudio\DailyBuildResult\dailybuildlog.txt" -k getBuildNumber clean_and_get all buildsuccessmail buildfailedmail binarisfailedmail
