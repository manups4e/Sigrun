echo Current working directory is: %cd%
xcopy /Y /E "..\CompiledLibs\Debug\MenuExample.net.dll" "<your_output_folder>"
xcopy /Y /E "..\CompiledLibs\Debug\Sigrun.dll" "<your_output_folder>"
echo Done!
