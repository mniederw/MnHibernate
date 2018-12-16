mn-hibernate
------------

Tiny program to enter hibernate state for windows (DotNetFx20, compatible to 2K,XP,VISTA,W7,W8,W10)
After Installation it is located in toolbar, on desktop and in program menu.
After starting it will enter system to hibernate (=sleep) state with power off.
Note: If hibernation is disabled which can also be detected by not finding hiberfil.sys on system drive 
then it must first be enabled (on vista and up with: powercfg.exe -hibernate on)
otherwise an error message is showed.
Note: On some systems when hibernation is not available it goes to standby mode instead.

License: GPL3, this is freeware.

Files:

- LICENSE_GPL3.txt : Standard License file.

- MnHibernate\* : C# sources.

- Install.ps1 : Menu script to install or uninstall module.

- Binx\MnHibernate.exe, *.sha2 : Built program signed by the author inclusive the sha2 hash file.
