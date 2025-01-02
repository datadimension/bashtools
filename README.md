bashtools are various functions to help with various terminal systems

This projects is different in that it is not a web project, more its compiled into a user directory to be used for bash_profile
therefore it should be stored outside of the www development directory.

Edits should be pushed with bash-push.

Changes are made simply with bash-pull which pulls from git and recompiles and restarts bash

some commands require sudo priviledge, but now are not seperated, similar to windows requiring Admin permission

initialise with:

cd ~/;rm -r bashtools;git clone git@github.com:datadimension/bashtools.git;
source ~/bashtools/bash_modules/bash-.sh;
bash-install;


