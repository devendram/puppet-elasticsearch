# Elasticsearch manifest
# http://www.elasticsearch.org/
# https://github.com/Aethylred/puppet-elasticsearch

class elasticsearch(
  $version      = "0.19.2",
  $install_root = "/opt"
){
  case $operatingsystem{
    CentOS:{
      class{'elasticsearch::install':
        version       => $version,
        install_root  => $install_root,
        git_package => 'git'
      }
    }
    default:{
      warning{"ElasticSearch ${version} not configured for ${operatingsystem}":}
    }
  }
}

class elasticsearch::install(
  $version      = "0.19.2",
  $install_root = "/opt",
  $git_package = "git-core"
){
  # NOTE: This is not a good way to install something.
  # It would be better to create RPM packages and put them in
  # a repository server
  # https://github.com/tavisto/elasticsearch-rpms
  # ...or use git to clone elasticsearch...

  package{$git_package: ensure => installed}

  exec{'install_elasticsearch':
    require   => Package[$git_package],
    path      => ['/usr/bin'],
    cwd       => $install_root,
    user      => root,
    command   => "git clone git://github.com/elasticsearch/elasticsearch.git elasticsearch&& cd elasticsearch&& git checkout v${version}",
    creates   => "${install_root}/elasticsearch",
  }

  exec{'install_servicewrapper':
    require => Exec['install_elasticsearch'],
    path    => ['/usr/bin','/bin'],
    cwd     => $install_root,
    user    => root,
    command => "git clone git://github.com/elasticsearch/elasticsearch-servicewrapper.git elasticsearch-servicewrapper&& cp -R elasticsearch-servicewrapper/service elasticsearch/bin",
    creates => "${install_root}/elasticsearch-servicewrapper",
  }

  #file{'link_elasticsearch_wrapper':
  #  ensure  => link,
  #  require => Exec['install_servicewrapper'],
  #  owner   => root,
  #  group   => root,
  #  path    => "${install_root}/elasticsearch/bin/service",
  #  target  => "${install_root}/elasticsearch-servicewrapper/service",
  #}

  file{'link_elasticsearch_service':
    ensure  => link,
    require => Exec['install_servicewrapper'],
    owner   => root,
    group   => root,
    path    => '/etc/init.d/elasticsearch',
    target  => "${install_root}/elasticsearch/bin/service/elasticsearch",
  }

  service{'elasticsearch':
    require => File['link_elasticsearch_service'],
    ensure => running,
    enable => true,
    hasstatus => true,
    hasrestart => true,
  }
}
