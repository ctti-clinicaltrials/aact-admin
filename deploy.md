# How to Deploy AACT Admin

First you need to connect to the Duke VPN. You can connect using *AnyConnect* through the command line or through the GUI

### Using the GUI ###
1. Make sure you have downloaded and installed AnyConnect from Duke 
   a. Mac Instructions: https://oit.duke.edu/help/articles/kb0014020
   b. Windows Instructions: https://oit.duke.edu/help/articles/kb0016403
2. Connect to the Duke VPN: https://oit.duke.edu/help/articles/kb0028460

### Using the Command Line ###
#### TODO: Instructions on how to install anyconnect in linux

Connect to the Duke VPN

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