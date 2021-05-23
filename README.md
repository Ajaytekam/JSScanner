# JSScanner

You can find the article related to this script here 
https://securityjunky.com/scanning-js-files-for-endpoint-and-secrets/

To install the required tools use
```
bash install.sh
```

**To run the tool use :**  

```shell 
 Usage: jsscanner domain_name [-f] path-to-urls-file [-d] output_directory

domain_name : FQDN with protocol
path-to-urls-file : Line saparated FQDN with protocol
output_directory  : User supplied output directory
Example :
	jsscanner https://www.example.com/
	jsscanner https://www.example.com/ -d ./out
	jsscanner -f hosts.txt
	jsscanner -f hosts.txt -d ./out
```  

* Scanning single domain 

```shell  
jsscanner domain_name

Eg. jsscanner https://www.example.com
```

* Scanning multiple domains 

```shell   
jsscanner -f path-to-urls-file

Eg. jsscanner -f alive.txt
```


Thanks to [@amiralkizaru](https://github.com/amiralkizaru), [@LifeHack3r](https://github.com/LifeHack3r) and [@g33kyshivam](https://github.com/g33kyshivam) for the contribution.
