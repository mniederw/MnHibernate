
# Do not change the following line, it is a powershell statement and not a comment!
#Requires -Version 3.0
param( [String] $sel )
Set-StrictMode -Version Latest; # Prohibits: refs to uninit vars, including uninit vars in strings; refs to non-existent properties of an object; function calls that use the syntax for calling methods; variable without a name (${}).
$Global:ErrorActionPreference = "Stop";
$PSModuleAutoLoadingPreference = "none"; # disable autoloading modules
trap [Exception] { $Host.UI.WriteErrorLine($_); Read-Host; break; }
function OutInfo                              ( [String] $line ){ Write-Host -ForegroundColor White               $line; }
function OutProgress                          ( [String] $line ){ Write-Host -ForegroundColor DarkGray            $line; }
function OutProgressText                      ( [String] $line ){ Write-Host -ForegroundColor DarkGray -NoNewLine $line; }
function OutQuestion                          ( [String] $line ){ Write-Host -ForegroundColor Cyan     -NoNewline $line; }
function FsEntryMakeTrailingBackslash         ( [String] $fsEntry ){ [String] $result = $fsEntry; if( -not $result.EndsWith("\") ){ $result += "\"; } return [String] $result; }
function FsEntryRemoveTrailingBackslash       ( [String] $fsEntry ){ [String] $result = $fsEntry; if( $result -ne "" ){ while( $result.EndsWith("\") ){ $result = $result.Remove($result.Length-1); } if( $result -eq "" ){ $result = $fsEntry; } } return [String] $result; } # leading backslashes are not removed.
function FsEntryGetFileName                   ( [String] $fsEntry ){ return [String] [System.IO.Path]::GetFileName((FsEntryRemoveTrailingBackslash $fsEntry)); }
function FsEntryGetAbsolutePath               ( [String] $fsEntry ){ return [String] ($ExecutionContext.SessionState.Path.GetUnresolvedProviderPathFromPSPath($fsEntry)); }
function DirExists                            ( [String] $dir ){ try{ return [Boolean] (Test-Path -PathType Container -LiteralPath $dir ); }catch{ throw [Exception] "DirExists($dir) failed because $($_.Exception.Message)"; } }
function DirCreate                            ( [String] $dir ){ New-Item -type directory -Force $dir | Out-Null; } # create dir if it not yet exists,;we do not call OutProgress because is not an important change.
function DirListDirs                          ( [String] $dir ){ return [String[]] (@()+(Get-ChildItem -Force -Directory -Path $dir | ForEach-Object{ $_.FullName })); }
function DirHasFiles                          ( [String] $dir, [String] $filePattern ){ return [Boolean] ((Get-ChildItem -Force -Recurse -File -ErrorAction SilentlyContinue -Path "$dir\$filePattern") -ne $null); }
function ScriptGetTopCaller                   (){ [String] $f = $global:MyInvocation.MyCommand.Definition.Trim(); if( $f -eq "" -or $f -eq "ScriptGetTopCaller" ){ return ""; } if( $f.StartsWith("&") ){ $f = $f.Substring(1,$f.Length-1).Trim(); } if( ($f -match "^\'.+\'$") -or ($f -match "^\`".+\`"$") ){ $f = $f.Substring(1,$f.Length-2); } return [String] $f; } # return empty if called interactive.
function ProcessIsRunningInElevatedAdminMode  (){ return [Boolean] ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator"); }
function ProcessRestartInElevatedAdminMode    (){ if( -not (ProcessIsRunningInElevatedAdminMode) ){ [String[]] $cmd = @( (ScriptGetTopCaller) ) + $sel; OutProgress "Not running in elevated administrator mode so elevate current script and exit: `n  $cmd"; Start-Process -Verb "RunAs" -FilePath "powershell.exe" -ArgumentList "& `"$cmd`" "; [Environment]::Exit("0"); throw [Exception] "Exit done, but it did not work, so it throws now an exception."; } }
function ProcessFindExecutableInPath          ( [String] $exec ){ [Object] $p = (Get-Command $exec -ErrorAction SilentlyContinue); if( $p -eq $null ){ return [String] ""; } return [String] $p.Source; } # return full path or empty if not found
function RebuildProg                          ( [String] $srcProjDir ){
                                                [String] $name = FsEntryGetFileName $srcProjDir;
                                                [String] $sln = "$srcProjDir\$name.sln";
                                                [String] $intermedExe = "$srcProjDir\Bin\Release\$name.exe";
                                                [String] $tarDir = "$srcProjDir\Binx";
                                                OutProgress "RebuildProg `"$tarDir\$name.exe`"";
                                                if( (ProcessFindExecutableInPath "msbuild") -eq "" ){ throw [Exception] "Missing msbuild in path, make sure it can be found in path, usually it is at: `"${Env:programfiles (x86)}\Microsoft Visual Studio\2017\Community\MSBuild\15.0\Bin\amd64\MSBuild.exe`""; }
                                                OutProgress "& `"msbuild`" $sln /nologo /verbosity:minimal /m /target:Clean,Build /p:Configuration=Release /p:Platform=`"Any CPU`"";
                                                <# alternative: /logger:FileLogger,Microsoft.Build.Engine;logfile="$log" #>
                                                & "msbuild" $sln /nologo /verbosity:minimal /m /target:Clean,Build /p:Configuration=Release /p:Platform="Any CPU";
                                                OutProgress "CopyTo `"$tarDir`"";
                                                DirCreate $tarDir; Copy-Item -Force -LiteralPath $intermedExe -Destination $tarDir; 
                                                OutProgress "Clean";
                                                & "msbuild" $sln /nologo /verbosity:normal /m /target:Clean /p:Configuration=Release /p:Platform="Any CPU" /noconsolelogger;
                                              }
function UninstallProg                        ( [String] $tarDir ){ OutProgress "RemoveDir '$tarDir'. "; if( DirExists $tarDir ){ ProcessRestartInElevatedAdminMode; 
                                                Remove-Item -Force -Recurse -LiteralPath $tarDir; } }
function InstallProg                          ( [String] $srcProjDir, [String] $tarParentDir ){
                                                [String] $name = FsEntryGetFileName $srcProjDir;
                                                [String] $exe = "$srcProjDir\Binx\$name.exe";
                                                OutProgress "Copy '$exe' `n  to '$tarParentDir'. ";
                                                ProcessRestartInElevatedAdminMode;
                                                Copy-Item -Force -LiteralPath $exe -Destination $tarParentDir; 
                                              }
[String] $srcProjDir = "$PSScriptRoot\MnHibernate";
[String] $tarDir = "$env:ProgramFiles\MnHibernate";
OutInfo         "Install Menu";
OutInfo         "------------`n";
OutInfo         "  Source Project Dir: `"$srcProjDir`"";
OutInfo         "  Target Install Dir: `"$tarDir`" `n";
OutInfo         "  I = Install. ";
OutInfo         "  N = Uninstall. ";
OutInfo         "  R = Rebuild program by the source, requires msbuild program located in path environment variable. ";
OutInfo         "  Q = Quit. `n";
if( $sel -ne "" ){ OutProgress "Selection: $sel "; }
while( @("I","N","R","Q") -notcontains $sel ){
  OutQuestion "Enter selection case insensitive and press enter: ";
  $sel = (Read-Host);
}
$Global:ArgsForRestartInElevatedAdminMode = $sel; 
if( $sel -eq "N"             ){ UninstallProg $tarDir; }
if( $sel -eq "I"             ){ InstallProg $srcProjDir $tarDir; }
if( $sel -eq "R"             ){ RebuildProg $srcProjDir; }
if( $sel -eq "Q"             ){ OutProgress "Quit."; }
OutQuestion "Finished. Press enter to exit. "; Read-Host;

