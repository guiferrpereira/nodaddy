## change_nameservers

### Domain specific nameserver configs
Need to have domain specific nameserver configurations. IE, domain1 gets ns1, ns2, and domain2 gets, ns1_prime, ns2_prime.

#### Approach
Running the ruby script operates by using one or more __Batch__ objects. Therefore, when the batch object is loaded, the script should load settings stored in CSV files into mongoid to make them accessible.

1) Setting files shall be stored in ````config/settings````.

2) Name domain setting files like this, ````domains_*.csv````.

3) Doamin setting CSV files need to have headers in order to define "schema" mapping for CSV import into mongoid doc objects. (max of 4 nameservers).

	domain, ns1, ns2, ns3, ns4
		
4) CSV file doamins will be loaded into mongodb as __DomainConfig__.


## transfer

### Approach

#### unlock domain
Unlock domain.  
Save __unlocked__ state to __Domain__ object.

#### authorization code
Send the email to go daddy noted email account.  
Save __auth_code_waiting__ state to __Domain__ object.

#### get auth code from email
Log into email account,  
Check inbox (and inbox only) for go daddy emails,  
Search go daddy specific emails for __auth_code_waiting__ domain names,  
Save auth code to domain mode,  
Save status.

#### OpenSRS 
Complete transfer for unlocked + auth_code_have domains.

<br>
<br>
## GUI.
Add this later?