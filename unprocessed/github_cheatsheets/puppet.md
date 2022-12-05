# (Lack of) Security

PuppetDB stores Puppet catalogs. Puppet catalogs contain all configuration information - including secrets. If you happen to configure passwords or API keys with Puppet (which most people do), then those catalogs will have that information in the UNENCRYPTED! Even if you're using eyaml to encrypted the secrets, the catalog has the unencrypted values. Lock down your PuppetDB servers and look into [node_encrypt](https://github.com/binford2k/binford2k-node_encrypt).

# Puppet Forge Modules

Whenever possible, we should use Puppet Forge modules - even kind of crappy ones - because community supported modules get better over time even when we ignore them. We'd be crazy to say no to free bug fixes and security improvements, right? However, our Production environment doesn't have egress access to the internet, so we have to maintain local git mirrors for all Puppet Forge modules we use. We also want to ensure that any upstream changes to a git repo don't break our Puppet runs. For example, if we were using "v0.0.00001-alpha-dont-use-me" (hey, it happens...) of some module and the upstream git repo dropped that tag, that would break our Puppet runs. To avoid this, we need to refresh our git mirrors in our non-prod environment first so we can catch those kinds of problems before they get to production.

# Useful Links

[Puppet in Docker](https://github.com/puppetlabs/puppet-in-docker)

# Common Commands

## Sign all certificates
    /opt/puppetlabs/bin/puppet cert sign --all

## Show certificate extensions
    # agent
    openssl x509 -text -noout -in $(/opt/puppetlabs/bin/puppet config print hostcert)
    # master
    /opt/puppetlabs/bin/puppet cert print svr100.example.com

## Create a new module or class
    puppet module generate

## Show Hiera info
    # Get YAML on a Puppet agent and send it to the Puppet server.
    sudo facter -p --yaml > facts.yaml
    # On the Puppet master
    hiera -c /etc/puppet/hiera.yaml -y facts.yaml your_dumb_fact

## Show which packages are managed by Puppet
    sudo puppet catalog select --terminus json $(hostname) package
    # Some of these numbers aren't adding up. Not sure why. Probably weird package name issues? I need to look into it.
    # List of packages that Puppet is managing (ensuring installed or absent)
    sudo puppet catalog --terminus json select $(hostname) package | sed -r 's/^Package\[//; s/\]$//;'

## List packages that Puppet is ensuring are installed
    cat <(sudo puppet catalog --terminus json select $(hostname) package | sed -r 's/^Package\[//; s/\]$//;') <(rpm -qa --qf "%{NAME}\n") | sort | uniq -d

## List packages that are not controlled by Puppet
    cat <(cat <(sudo puppet catalog --terminus json select $(hostname) package | sed -r 's/^Package\[//; s/\]$//;') <(rpm -qa --qf "%{NAME}\n") | sort | uniq -d) <(rpm -qa --qf "%{NAME}\n") | sort | uniq -d

## Iterate over an array
This calls arrayDebug 3 times with the array values as parameter.

    define arrayDebug {
      notify { "Item ${name}": }
    }
    
    class array {
      $array = [ 'item1', 'item2', 'item3' ]
      arrayDebug { $array: }
    }

Output:

    Item item1
    Item item2
    Item item3

## Iterate over an array with split

If you need more values per iteration than just one, we could use the split function to create a pseudo Hash:

	define arrayDebug {
	  $value = split($name,',')
	  notify { "Item ${value[0]} has value ${value[1]}": }
	}
	 
	class array {
	  $array = [ 'item1,value1', 'item2,value2', 'item3,value3' ]
	  arrayDebug { $array: }
	}
	
Output:

    Item item1 has value value1
    Item item2 has value value2
    Item item3 has value value3

## Iterate over a hash

The above method with the pseudo Hash functionality does it’s job, but not very nice. It would be much nicer to directly iterate over a Hash. To achieve this, there is this nice function called create_resources:

	define hashDebug($value, $othervalue, $somevalue) {
	  notify { "Item ${name} has value ${value}, othervalue ${othervalue} and somevalue ${somevalue}": }
	}
	 
	class array {
	  $hash = {
	    item1 => { value      => '1',
	               othervalue => 'a',
	               somevalue  => 'jjj' },
	    item2 => { value      => '2',
	               othervalue => 'b' },
	  }
	 
	  $hashDefaults = {
	    $somevalue => 'zzz'
	  }
	 
	  create_resources(hashDebug, $hash, $hashDefaults)
	}
	
This example calls hashDebug two times, passing the Hash item as arguments. The variable $hashDefaults defines default values for missing parameters in the Hash.

Output:

	Item item1 has value 1, othervalue a and somevalue jjj
	Item item1 has value 2, othervalue b and somevalue zzz

## PuppetDB: list nodes that are version 7.4
    curl -s -X GET http://localhost:8080/pdb/query/v4 --data-urlencode 'query=inventory { facts.os.release.major = "7" and facts.os.release.minor = "4"}' | jq -r .[].certname

    curl -s -G 'query=["=", "trusted.extensions.pp_role", "arapi"]' http://localhost:8080/pdb/query/v4/inventory | jq .[].certname
    curl -s -G -d "query=[\"<\",\"report_timestamp\",\"$(date -d '-1 day' +%FT%T.000Z)\"]" http://pdxnppuppetdb01.example.com:8080/pdb/query/v4/nodes | jq .

## PuppetDB: list nodes with a specific class
    curl -s http://localhost:8080/pdb/query/v4/resources/Class/Role::Logstash | jq .[].certname
    curl -s -G http://pdxnppuppetdb01.example.com:8080/pdb/query/v4/resources -d 'query=["extract",["certname"],["=","title","Role::Logstash"]]' | jq .[].certname

## PuppetDB: list all Puppet-managed services on a node
    curl -s -G http://puppetdb:8080/pdb/query/v4/resources -d 'query=["and",["=","certname","servertron.example.com"],["=","type","Service"]]' | jq .[].title

## PuppetDB: list all non-master environments
    curl -s http://localhost:8080/pdb/query/v4/nodes | jq '[.[] | select(.facts_environment != "master") | { certname: .certname, facts_environment: .facts_environment }]'
