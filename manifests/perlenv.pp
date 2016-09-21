# == Class: userportal::perlenv
#
class userportal::perlenv {

  $packages = ['postgresql-devel', 'expat-devel', 'openssl-devel']

  ensure_resource('package', $packages, {'ensure' => 'present'})

  perlbrew { $::userportal::portal_home:
    install_root => $::userportal::portal_home,
    owner        => $::userportal::portal_user,
    group        => $::userportal::portal_group,
    bashrc       => true,
  }

  perlbrew::perl { $::userportal::perl_version:
    target => $::userportal::portal_home,
  }

  perlbrew::cpanm { 'Module::Build':
    target => $::userportal::perl_version,
  }

  perlbrew::cpanm { $::userportal::perlmods_git:
    target     => $::userportal::perl_version,
    check_name => 'SDM::Conf',
    timeout    => 1800,
    require    => [Package['expat-devel'], Package['postgresql-devel']],
  }

  # at least some of the nsa "dbuserapps" require LWP::Protocol::https
  perlbrew::cpanm { 'LWP::Protocol::https':
    target  => $::userportal::perl_version,
    timeout => 900,
    require => Package['openssl-devel'],
  }
}
