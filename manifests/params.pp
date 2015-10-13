# === Class: mysql_backup::params
#
class mysql_backup::params {

  case $::osfamily {
    'RedHat': {
      $mysql_client_package = 'mariadb'
    }
    'Debian': {
      $mysql_client_package = 'mysql-client'
    }
    default: {
      fail("mysql_backup: Your operating system ${::osfamily} is not supported")
    }
  }

}
