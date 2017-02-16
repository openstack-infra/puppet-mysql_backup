# == Define: mysql_backup::backup
#
# Arguments determine when backups should be taken, where they should
# be located, and how often they shouled be rotated. The namevar
# of the define must be the name of the database to backup.
# This define assumes that the mysqldump command is installed under
# /usr/bin.
#
define mysql_backup::backup (
  # The parameters below are grouped in violation of style guide
  # to save readable configuration of cron. All other parameters
  # are grouped properly.
  $day           = '*',
  $hour          = '0',
  $minute        = '0',
  $defaults_file = '/etc/mysql/debian.cnf',
  $dest_dir      = '/var/backups/mysql_backups',
  $num_backups   = '30',
  $rotation      = 'daily',
) {
  # Wrap in check as there may be mutliple backup defines backing
  # up to the same dir.
  if ! defined(File[$dest_dir]) {
    file { $dest_dir:
      ensure => directory,
      mode   => '0755',
      owner  => 'root',
      group  => 'root',
    }
  }

  if ! defined(Package['mysql-client']) {
    package { 'mysql-client':
      ensure => present,
    }
  }

  cron { "${name}-backup":
    ensure  => present,
    command => "/usr/bin/mysqldump --defaults-file=${defaults_file} --opt --ignore-table mysql.event --all-databases --single-transaction | gzip -9 > ${dest_dir}/${name}.sql.gz",
    minute  => $minute,
    hour    => $hour,
    weekday => $day,
    require => File[$dest_dir],
  }

  include ::logrotate
  logrotate::file { "${name}-rotate":
    log     => "${dest_dir}/${name}.sql.gz",
    options => [
      'nocompress',
      "rotate ${num_backups}",
      $rotation,
    ],
    require => Cron["${name}-backup"],
  }
}
