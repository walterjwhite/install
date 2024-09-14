# install

## Why use shell scripting as an application framework?
Good question, considering that banks, government institutions, and retail operations make heavy use of shell-scripting for mission critical functionality, shell scripts are the next big thing in programming.
Shell has robust exception handling that cannot be matched.
Forget Java, go, rust, or python, the future is shell.

## Installation
Download the appropriate artifact for your platform / architecture:
Ie. for FreeBSD:
https://github.com/walterjwhite/install/blob/master/artifacts/FreeBSD/app-install

> chmod +x app-install

> ./app-install https://github.com/walterjwhite/install
  This will install the 'install' app which includes some other executables.

## Dependencies
This app depends heavily on gnu sed, gnu awk, gnu grep or otherwise gnu coreutils.


## Intent
'Install' is an 'app' to make installing other 'apps', files, platform packages, etc. easily.
It has been built for FreeBSD and Apple primarily with limited support for both Linux and Windows (cygwin / git-bash).
It provides hooks to install packages through the platform-native installers.
It is also designed to allow libraries to be easily reused across 'apps' via import statements:

> import git:install/sed.sh
> import sed.sh

The above statement instructs the installer to inject sed.sh from install 'app'.

The collection of shell scripts in this app do some 'neat' things.
1. support colorized logging
2. support sending emails
3. support sending sms messages (via email gateway)
4. beeping on success / failure, by default, beeps are configured on FreeBSD to notify you of an error, success, or if input is required
5. triggering platform-specific notification
6. validate required configuration, by default, it will warn the user if any items are missing, a missing configuration item may yield unexpected results, earlier versions would produce a runtime error
7. compile programs under /bin into a single shell script such that all external dependencies have been resolved.  Updates to other apps will have no direct impact on this app.


## Usage
As this 'app' is meant to facilitate installing other apps, it is meant to be used as such:

> app-install https://github.com/walterjwhite/search
---
### Limitations and known issues
1. Linux support is untested
2. Windows support is untested
3. add mms support

---
### Future work
1. Add Linux support
2. Add Windows support
