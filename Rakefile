desc "remove all 2012* files"
task :clean_simple do 
 `rm -rf 2012*` 
 `rm -rf output.yml` 
 `rm -rf domains.yml`
end

desc "remove all yml files"
task :yml do
  `rm -rf *.yml`
end

task :default => :clean_simple
