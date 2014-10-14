# == Class: userportal
#
class userportal(
  $perlmods_git,
  $portal_git,
  $portal_home    = '/home/portal',
  $sdm_envmode    = 'testing',
  $portal_workers = '10',
  $portal_user    = 'portal',
  $portal_group   = 'portal',
  $portal_port    = '5001',
  $portal_logdir  = '/var/log/userportal',
  $perlenv_only   = false,
  $service_ensure = 'running',
  $service_enable = true,
) {
  validate_string($portal_home)
  validate_string($perlmods_git)
  validate_string($portal_git)
  validate_string($sdm_envmode)
  validate_string($portal_workers)
  validate_string($portal_user)
  validate_string($portal_group)
  validate_string($portal_port)
  validate_string($portal_logdir)
  validate_bool($perlenv_only)
  validate_re($service_ensure, '^running$|^stopped$')
  validate_bool($service_enable)
  
  $portal_install_root = "${portal_home}/userportal"
  $perl_version = 'perl-5.20.1'
  $starman_bin = "${portal_home}/perl5/perlbrew/perls/${perl_version}/bin/starman"

  anchor { 'userportal::begin': } ->
  class { 'userportal::perlenv': } ->
  anchor { 'userportal::end': }

  unless $perlenv_only {
    Class['userportal::perlenv'] ->
    class { 'userportal::portal': } ->
    Anchor['userportal::end']
  }
}
