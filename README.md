# puppet-elasticsearch
================

Install elasticsearch service

## REQUIREMENTS

* Puppet >=2.6 if using parameterized classes
* Currently supports CentOS6.2 and Amazon Linux AMI release 2012.03  

## Installation

Clone or submodule this repository into:

/etc/puppet/modules/elasticsearch

## Invocation

To install on a node:

include elasticsearch

or with parameters:

class{elasticsearch:
    $version => "0.19.4",
    $install_root => "/opt"
}

## References

* ElasticSearch homepage: http://www.elasticsearch.org/
