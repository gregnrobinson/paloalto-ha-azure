# Palo Alto - Highly Available Architecture

The purpose of this repository is to automate the deployment of the Azure resources required for high availabiltiy of Palo Alto Firewalls. This is the standard architecture deployment for firewalls that take advantage of high availability in Azure. This architecture has become more popular since the introduction of HA Ports on the internal load balancer in Azure. The script handles the loadbalancing, networking and infrasturcture configurations.

![Scheme](https://github.com/gregnrobinson/paloalto-ha-azure/blob/master/Data/pan_ha_architecture.png?raw=true)

Prior to deploying the Palo Alto firewalls in the environment, the account being used for the terraform deployment must run the below Azure CLI command to accept the terms and conditions of the firewall model being used.

```
az vm image accept-terms --urn paloaltonetworks:vmseries1:bundle1:8.1.0
```

# Tools Required for Deployment

## Terraform

### Ubuntu

1. Download terraform for linux 

	```wget https://releases.hashicorp.com/terraform/0.xx.x/terraform_0.xx.x_linux_amd64.zip```

	Note: Replace 0.xx.x with the latest version of Terraform

2. Install unzip

	```sudo apt-get install unzip```

3. Unzip and set path.

	```unzip terraform_0.xx.x_linux_amd64.zip ```
	```sudo mv terraform /usr/local/bin/```


### MacOS

1. Install Homebrew on MacOS

	```/usr/bin/ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"```

1. Download terraform for linux 

	```brew install terraform```


### Windows

1. Download the binary package of terraform here: https://www.terraform.io/downloads.html

2. Copy files from the zip to “c:\terraform” for example. That’s our terraform PATH.

3. The final step is to make sure that the terraform binary is available on the PATH.


## Azure CLI

### MacOS

You can install the CLI by updating your brew repository information, and then running the install command:
```
brew update && brew install azure-cli
```

1. Run the ***login*** command.

```
az login
```

If the CLI can open your default browser, it will do so and load a sign-in page.

Otherwise, you need to open a browser page and follow the instructions on the command line to enter an authorization code after navigating to **https://aka.ms/devicelogin** in your browser.

2. Sign in with your account credentials in the browser.

### Windows

The MSI distributable is used for installing, updating, and uninstalling the az command on Windows. Use the below link to download the installer.

https://aka.ms/installazurecliwindows

You can now run the Azure CLI with the az command from either Windows Command Prompt or PowerShell. PowerShell offers some tab completion features not available from Windows Command Prompt. To sign in, run the az login command.

1. Run the ***login*** command.

```
az login
```

If the CLI can open your default browser, it will do so and load a sign-in page.

Otherwise, you need to open a browser page and follow the instructions on the command line to enter an authorization code after navigating to https://aka.ms/devicelogin in your browser.

2. Sign in with your account credentials in the browser.


# How to Deploy

1. Clone the repository to a local folder

	```git clone git@bitbucket.org:slalom-consulting/paloalto-ha-azure.git```

3. Modify the default value of the ***azurerm_ssh_key_path*** variable with the public key you would like to place on the instances).

	```variable "azurerm_ssh_key_path"         {```  
	```default     = "~/.ssh/id_rsa.pub"```
	```description = "Enter the path of the public key to be uploaded to the Splunk Servers. (Ex. ~/.ssh/publickey.pub)"}```

4. Initialize the terraform directory if this is the first time running terraform within the directory

	```terraform init```

5. Modify the default variables in *main.tf* or create a *.tfvars* file with the variables you wish to change. 

6. Apply the changes to the Azure environment and confirm by typing ***yes***

	```terraform apply```
