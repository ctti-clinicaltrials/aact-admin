# How to Deploy AACT Admin

1. [Connect to Duke VPN](#connect-to-duke-vpn)
2. [Run Deploy commmand](#run-deploy-command)


## Connect to Duke VPN

### Option 1 - Using the GUI ###
1. Make sure you have downloaded and installed AnyConnect from Duke 
  - Mac Instructions: https://oit.duke.edu/help/articles/kb0014020
  - Windows Instructions: https://oit.duke.edu/help/articles/kb0016403
1. Connect to the Duke VPN: https://oit.duke.edu/help/articles/kb0028460

### Option 2 - Using the Command Line ###
#### TODO: Instructions on how to install anyconnect in linux

```
/opt/cisco/anyconnect/bin/vpn -s connect portal.duke.edu

# Select Default (0)
 >> Please enter your username and password.
    0) -Default-
    1) Fuqua School of Business
    2) INTL-DUKE
    3) Library Resources Only
    4) Nicholas Internal
    5) PRDN
    6) Protected_Data
    7) Public Safety
  
# Enter Duke username
# Enter Password
# Select 3-SMS to X-XXXX

# You should be connected to the VPN
```


## Run Deploy Command

```bash
# add your ssh key to the ssh-agent so that it can passed to the production server
eval $(ssh-agent)
ssh-add

# start the deployment using capistrano
./deploy production

# enter master to deploy the master branch to production
```
