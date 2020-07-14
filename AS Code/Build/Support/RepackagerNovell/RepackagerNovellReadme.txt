This file is a place holder file here so that this folder (RepackagerNovell) can be added to source control.  This folder is required to exist when building the RepackagerNovell setup project because InstallShield tries to create an XML file for the installer class custom action (AdminStudio.Usage.DLL) in this folder.

This is due to an IS limitation/bug.

We were getting by on the main AS build machine because this folder already existed there and the build process did not completely delete the files in the Build folder tree.

But the new AS Japanese build machine does completely delete the entire \Adminstudio\Current tree each time.

-Ajay 9/11/2008