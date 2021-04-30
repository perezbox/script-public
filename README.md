# Tony's Script Repo
This is my personal script repository where I'll share various tools I use in my daily activities. 

You will find the following files in the repo: 

- install-LAMP-ubuntu20.sh: This script is what I use to kick-start a webserver for a project. It is build for Ubuntu 20.04 LTS, and uses MariaDB and PHP 7.4. 
- install-wordpress.sh: This script was built to be on a one click option to get WordPress set up quickly, helping me from forgetting steps and helping me standardize the steps. 
- vhosts: This is a basic template I use with the install-wordpress.sh script, it was modified so that I can quickly update appropriate sections to fit my naming convention.

##How to use

To use these files, you can clone them locally or copy the contents into their own file on your server. 

Once you copy them into a file locally, verify you can execute them by using chmod:

**e.g.,** 

> $chmod +x install-LAMP-ubuntu20.sh

Then, simply run the script:

**e.g.,** 

> $./install-LAMP-ubuntu20.sh


