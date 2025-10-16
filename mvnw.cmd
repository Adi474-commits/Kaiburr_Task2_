@echo off
rem Maven wrapper for Windows
setlocal
set SCRIPT_DIR=%~dp0
REM Maven wrapper invocation
set BASEDIR=%~dp0
REM Ensure multiModuleProjectDirectory is set (required by Maven wrapper)
set MAVEN_MULTI=%BASEDIR%.
java -cp "%BASEDIR%\.mvn\wrapper\maven-wrapper.jar" -Dmaven.multiModuleProjectDirectory="%MAVEN_MULTI%" org.apache.maven.wrapper.MavenWrapperMain %*
endlocal
