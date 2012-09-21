# NoDaddy
Ever wish you could automate the GoDaddy UI?  
__Wish no more__  


## Installation
Requires __mongodb__. Install from GitHub

    git clone git@github.com:jjeffus/nodaddy.git
    cd nodaddy
    bundle install

````config/godaddy_accounts.yml```` - add GoDaddy account credentials.  
  
````config/mongoid.yml```` - configure __mongoid__ connection params.  

## Basic Structure
Batches are created for each Session class intance.   

1) __Session#new__ connects connects to mongodb via mongoid. The __Session#new__ call indirectly created a __Batch__ object, which was saved the database, and is retrievable via a getter method, batch = __Session#batch__.

2) The __Batch__ object is the primary unit of operation.

3) Each __Batch__ object has a single GoDaddy __Account__ object, which stores username/password.

4) Each __Batch__ has many __Domains__.
  
## Recipes  
#### get_domains    
Get all domains for each account in ````config/godaddy_accounts.yml````. All saved domains will be accessible via the related __Batch__ object.

		bundle exec ruby receipes/get_domains.rb
  
#### change_name_servers
__NOTE:__ requires running get_doamins.rb first.   

Change nameservers for batch of domains. Enter new name servers at top of file.

		bundle exec ruby recipes/get_domains.rb
		bundle exec ruby recipes/change_name_servers.rb  

#### transfer_domains
Coming soon…
  
## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
