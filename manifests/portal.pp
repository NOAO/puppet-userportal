# == Class: userportal::portal
#
class userportal::portal {
  $lockfile = "${::userportal::portal_install_root}/lock"

  vcsrepo { $::userportal::portal_install_root:
    ensure   => present,
    provider => 'git',
    source   => $::userportal::portal_git,
    user     => $::userportal::portal_user,
    owner    => $::userportal::portal_user,
    group    => $::userportal::portal_group,
  } ->
  perlbrew::exec { 'perl Build.PL':
    target  => $::userportal::perl_version,
    cwd     => $::userportal::portal_install_root,
    creates => $lockfile,
    require => [Perlbrew::Cpanm['Module::Build'], Perlbrew::Cpanm[$::userportal::perlmods_git]],
  } ->
  perlbrew::exec { 'Build':
    target  => $::userportal::perl_version,
    cwd     => $::userportal::portal_install_root,
    path    => $::userportal::portal_install_root,
    creates => $lockfile,
  } ->
  perlbrew::exec { 'cpanm --installdeps --notest .':
    target  => $::userportal::perl_version,
    path    => ['/bin', '/usr/bin'],
    cwd     => $::userportal::portal_install_root,
    creates => $lockfile,
    timeout => 900,
  } ->
  file { $lockfile:
    ensure => 'file',
    owner  => $::userportal::portal_user,
    group  => $::userportal::portal_group,
  }

  file { '/etc/init.d/userportal':
    ensure  => 'file',
    owner   => 'root',
    group   => 'root',
    mode    => '0755',
    content => template("${module_name}/userportal.redhat.erb"),
  }

  service { 'userportal':
    ensure     => $::userportal::service_ensure,
    hasstatus  => true,
    hasrestart => true,
    enable     => $::userportal::service_enable,
    require    => [Perlbrew::Exec['cpanm --installdeps --notest .'], File['/etc/init.d/userportal']],
  }
}
