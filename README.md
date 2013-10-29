puppet-deploy
=============

Overview
--------

The deploy module installs and configures deploy with Puppet.

Reference
---------

Classes:

* [deploy](#class-deploy)
* [deploy::config](#class-deployconfig)
* [deploy::install](#class-deployinstall)

###Class: deploy
This class is used to install and configure deploy.

####`private_key`
The ssh-rsa private key of the deploy user.

####`public_key`
The ssh-rsa public key of the deploy user.

####`version`
The version of deploy to install. Defaults to `latest`

####`groups`
The additional groups to which the deploy user belongs.

###Class: deploy::config
This class is used to configure deploy.

###Class: deploy::install
This class is used to install deploy.
