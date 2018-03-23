#
# need to override jce_url as direct download not permitted
# original download from http://download.oracle.com/otn-pub/java/jce
# link is no good without authentication token,
# goto http://download.oracle.com and search for jce
class java (
  $jce_repo_url        = 'https://artifactory3-eu1.moneysupermarket.com/artifactory',
  $source_url          = 'https://download.oracle.com/otn-pub/java/jdk/7u51-b13',
  $java_major_version  = 7,
  $java_minor_version  = 51,
  $additional_versions = {}
  ) {

  include wget
  # Remove OpenJDK 6
  package {'java-1.6.0-openjdk':
    ensure   => absent,
	provider => yum,
  }

  # Remove OpenJDK 7
  package {'java-1.7.0-openjdk':
    ensure   => absent,
	provider => yum,
  }

  # Remove OpenJDK 8
  package {'java-1.8.0-openjdk':
    ensure   => absent,
	provider => yum,
  }

  # Configure JAVA_HOME globlly.
  file { '/etc/profile.d/java.sh':
    ensure  => file,
    owner   => root,
    group   => root,
    mode    => '0644',
    content => 'export JAVA_HOME=/usr/java/default',
  }

  create_resources ( 'install_version', $additional_versions )
  java::install_version {"${java_major_version}_${java_minor_version}":
    source       => $source_url,
    jce_repo_url => $jce_repo_url,
  }

  file { 'default java':
    ensure  => 'link',
    path    => '/usr/java/default',
    mode    => '0755',
    target  => "/usr/java/jdk1.${java_major_version}.0_${java_minor_version}",
    require => Package["jdk 1.${java_major_version}.0_${java_minor_version}-fcs"],
  }
  $fetch_cert = hiera_hash('java::create_truststore', undef)
  if ($fetch_cert) {
    $_hostname = keys($fetch_cert)
    $_pass = $fetch_cert["${_hostname}"][key]
    $_port = $fetch_cert["${_hostname}"][port]

    class { 'java::createtruststore':
      hostname   => $_hostname,
      port       => $_port,
      passphrase => $_pass,
      require    => File['default java'],
    }
  }

}
