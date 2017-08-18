# install Java Cryptography Extensions
# available from oracle https://www.google.co.uk/search?q=jce+download
# driver_repo = used as part of the download url
# repo_url = main url such as http://download.oracle.com/otn-pub/java/jce/7/
class java::jce (
  $repo_url = 'https://artifactory3-eu1.moneysupermarket.com/artifactory',
  $java_major_version = 7,
  $jdk_path = '/usr/java/default',
  $driver_repo = 'ext-release-local',
) {
  # Requires
  include unzip

  wget::fetch { "${repo_url}/${driver_repo}/oracle/security/UnlimitedJCEPolicyJDK${java_major_version}.zip":
    destination => '/tmp/UnlimitedJCEPolicyJDK.zip',
  } ->
  exec { 'unzip-jce':
    cwd     => "${jdk_path}/jre/lib/security",
    path    => '/bin/:/usr/bin',
    command => 'unzip -jo /tmp/UnlimitedJCEPolicyJDK.zip',
    require => Package['unzip'],
  } ->
  exec { 'chmod-jce-files':
    cwd     => "${jdk_path}/jre/lib/security",
    path    => '/bin/:/usr/bin',
    command => 'chmod 0644 local_policy.jar US_export_policy.jar',
  }
}