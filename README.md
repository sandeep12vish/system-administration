# system-administration

## Patch Management process for the OS
Lunix Patch Management
### 1: It's requires root privileges- 
		$sudo su-
### 2. Need to check all packages in the OS
	$ rpm -qa  (query for all packages)
	or 
	$ yum list installed

### 3. From where to get the update
	$cat /etc/os-release

	for particular repository
	$cat /etc/yum.repos.d/redhat-rhui*

### 4 brefore upgrade, need to chech which packages requies to upgrade
	$ yum check-update

	Also perform - Sanity test

	$ yum repolist
	$ yum update

### 5. To ensure system is patched
	$yum check-update

### 6. Reboot the system
	  $reboot
    
### 7. Again verify with the following command 
  $ yum check-update 	 
