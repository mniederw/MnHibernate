MnHibernate
------------

Tiny C# program to enter hibernate state for windows (DotNetFx20, compatible to 2K,XP,VISTA,W7,W8,W10).
The binary executable can either be taken by github-repository-releases which contains the signed assembly 
with a strong name by the author inclusive the hash file or can be rebuilt by yourself 
if you have the msbuild tool (for example by Visual Studio 2017) available in your environment path.
After Installation it is located in toolbar, on desktop and in program menu.
After starting it will enter the system to hibernate (=sleep) state with power off.
Note: If hibernation is disabled which can also be detected by not finding hiberfil.sys on system drive 
then it must first be enabled (on vista and up with: powercfg.exe -hibernate on)
otherwise an error message is displayed.
Note: On some systems when hibernation is not available it goes to standby mode instead.

License: GPL3, this is freeware.

Files:

- LICENSE_GPL3.txt : Standard License file.

- MnHibernate\* : C# sources.

- Install.ps1 : Menu script to rebuild it by msbuild, install or uninstall it.

- Binx\MnHibernate.exe : Location of the own built program.
