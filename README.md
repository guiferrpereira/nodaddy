# GoDaddyApi

Script loads accounts in ````secure/godaddy_accounts.yml````  



## Development Status  
__done__  Log into godaddy.com  
__done__  Navigate to DNS  
__done__  Get all domains  
__done__  For each domain check DNS records  
__done__  Change old DNS records to new DNS records  



## Installation
Install from GitHub at the moment



## Usage

In order to use script,  
		bundle install
		ruby script.rb

### Configurations
Username, password, DNS configurations are stored in YAML files in the ````/secure```` folder. See ````/secure/example.yml````.  
  
### Output   
Running ````script.rb```` will create a log.txt file with log of script operations. 
If a file already exists named, "log.txt", then log file will be named using a timestamp will be created.




## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
