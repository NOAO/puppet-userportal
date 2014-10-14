# == Class: userportal::perlenv
#
class userportal::perlenv {
  ensure_packages(['postgresql-devel', 'expat-devel'])

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
}
