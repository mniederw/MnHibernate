using System;
using System.Collections.Generic;
using System.IO;
using System.Reflection;
using System.Runtime.InteropServices;
using System.Windows.Forms;

[assembly: AssemblyTitle("Mn Hibernate")]
[assembly: AssemblyDescription("Enter system to hibernate (=sleep) state with power off")]
[assembly: AssemblyConfiguration("For .NET FX20 for 2K,XP,VISTA,W7,W8,W10 and up.")]
[assembly: AssemblyCompany("Marc Niederwieser")]
[assembly: AssemblyProduct("MnHibernate")]
[assembly: AssemblyCopyright("© 2010-2018 Marc Niederwieser, Switzerland, marc.niederwieser@gmx.net. GPL3 Freeware!")]
[assembly: AssemblyTrademark("")]
[assembly: AssemblyCulture("")]
[assembly: ComVisible(false)]

[assembly: AssemblyVersion("1.3")]
// 2016-10-24 V1.3 prepared for github
// 2014-03-05 V1.2 minor improvements
// 2012-12-23 V1.1 minor improvements
// 2010-12-31 V1.0 Initial, usage info, check for hibernate file

namespace MnHibernate
{
    internal static class Program
    {
        internal static void Main(String[] args)
        {
            String systemDrive = Path.GetPathRoot(Environment.SystemDirectory); // ex: "C:\"
            String hiberfilSys = systemDrive + "hiberfil.sys"; // ex: "C:\hiberfil.sys"

            // convert  to upper case and leading "/" to "-" if running on windows
            var cmdArgs = new List<String>(args).ConvertAll(i =>
              (i.Substring(0, 1) == "/" && Path.DirectorySeparatorChar != '/' ? "-" + i.Substring(1) : i).ToUpper());

            if (cmdArgs.Exists(i => new List<String> { "-?", "-H", "-HELP" }.Contains(i)))
            {
                MessageBox.Show("Usage: MnHibernate [-?|-h|-help] " + Environment.NewLine
                  + "  Enter system to hibernate (=sleep) state with power off. " + Environment.NewLine
                  + "  Note: If hibernation is disabled which can also be detected by not " + Environment.NewLine
                  + "  finding " + hiberfilSys + " on system drive then it must first be enabled " + Environment.NewLine
                  + "  (on vista and up  with: powercfg.exe -hibernate on ) " + Environment.NewLine
                  + "  otherwise an error message is showed. " + Environment.NewLine
                  + "  Note: On some systems when hibernation is not available it goes to standby mode instead." + Environment.NewLine
                  + "  License: OpenSource GPL3, this is freeware." + Environment.NewLine,
                 "MnHibernate", MessageBoxButtons.OK, MessageBoxIcon.Information);
                return;
            }

            if (!File.Exists(hiberfilSys))
            {
                MessageBox.Show("Not found " + hiberfilSys + " so hibernate mode is not enabled. " + Environment.NewLine
                    + "Please enabled it (on vista and up  with: powercfg.exe -hibernate on )." + Environment.NewLine,
                    "MnHibernate", MessageBoxButtons.OK, MessageBoxIcon.Error);
                return;
            }

            Application.SetSuspendState(PowerState.Hibernate, false, false);
        }
    }
}
