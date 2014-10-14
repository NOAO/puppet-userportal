require 'spec_helper'

describe 'userportal' do
  shared_examples_for 'perlenv' do
    ['postgresql-devel', 'expat-devel'].each { |pkg|
      it { should contain_package(pkg) }
    }

    it do
      should contain_perlbrew('/home/portal').with(
        :install_root => '/home/portal',
        :owner        => 'portal',
        :group        => 'portal',
        :bashrc       => true
      )
    end

    it do
      should contain_perlbrew__perl('perl-5.20.1').with(
        :target => '/home/portal'
      )
    end

    it do
      should contain_perlbrew__cpanm('Module::Build').with(
        :target => 'perl-5.20.1'
      )
    end

    it do
      should contain_perlbrew__cpanm('git@example.org:foo/perlmods.git').with(
        :target     => 'perl-5.20.1',
        :check_name => 'SDM::Conf',
        :timeout    => 1800,
      )
    end
    it { should contain_perlbrew__cpanm('git@example.org:foo/perlmods.git').that_requires('Package[postgresql-devel]') }
    it { should contain_perlbrew__cpanm('git@example.org:foo/perlmods.git').that_requires('Package[expat-devel]') }
  end # perlenv

  shared_examples_for 'portal' do
    it do
      should contain_vcsrepo('/home/portal/userportal').with(
        :ensure   => 'present',
        :provider => 'git',
        :source   => 'git@example.org:foo/portal.git',
        :user     => 'portal',
        :owner    => 'portal',
        :group    => 'portal'
      )
    end

    it do
      should contain_perlbrew__exec('perl Build.PL').with(
        :target  => 'perl-5.20.1',
        :cwd     => '/home/portal/userportal',
        :creates => '/home/portal/userportal/lock'
      )
    end
    it { should contain_perlbrew__exec('perl Build.PL').that_requires('Vcsrepo[/home/portal/userportal]') }
    it { should contain_perlbrew__exec('perl Build.PL').that_requires('Perlbrew::Cpanm[Module::Build]') }
    it { should contain_perlbrew__exec('perl Build.PL').that_requires('Perlbrew::Cpanm[git@example.org:foo/perlmods.git]') }

    it do
      should contain_perlbrew__exec('Build').with(
        :target  => 'perl-5.20.1',
        :cwd     => '/home/portal/userportal',
        :path    => '/home/portal/userportal',
        :creates => '/home/portal/userportal/lock'
      )
    end
    it { should contain_perlbrew__exec('Build').that_requires('Perlbrew::Exec[perl Build.PL]') }

    it do
      should contain_perlbrew__exec('cpanm --installdeps --notest .').with(
        :target  => 'perl-5.20.1',
        :path    => ['/bin', '/usr/bin'],
        :cwd     => '/home/portal/userportal',
        :creates => '/home/portal/userportal/lock',
        :timeout => 900,
      )
    end
    it { should contain_perlbrew__exec('cpanm --installdeps --notest .').that_requires('Perlbrew::Exec[Build]') }

    it do
      should contain_file('/home/portal/userportal/lock').with(
        :ensure => 'file',
        :owner  => 'portal',
        :group  => 'portal'
      )
    end

    it do
      should contain_file('/etc/init.d/userportal').with(
        :ensure => 'file',
        :owner  => 'root',
        :group  => 'root',
        :mode   => '0755'
      )
    end

    [
      'SDM_ENVMODE=\'testing\'',
      'STARMAN=\'/home/portal/perl5/perlbrew/perls/perl-5.20.1/bin/starman\'',
      'PORTAL_INSTALL_ROOT=\'/home/portal/userportal\'',
      'PORTAL_WORKERS=\'10\'',
      'PORTAL_USER=\'portal\'',
      'PORTAL_GROUP=\'portal\'',
      'PORTAL_PORT=\'5001\'',
    ].each { |line|
      it { should contain_file('/etc/init.d/userportal').with_content(/#{line}/) }
    }

    it do
      should contain_service('userportal').with(
        :ensure     => 'running',
        :hasstatus  => true,
        :hasrestart => true,
        :enable     => true
      )
    end
    it { should contain_service('userportal').that_requires('Perlbrew::Exec[cpanm --installdeps --notest .]') }
  end # portal

  context 'with defaults for all parameters' do
    let(:params) do
      {
        :perlmods_git => 'git@example.org:foo/perlmods.git',
        :portal_git   => 'git@example.org:foo/portal.git',
      }
    end

    it { should contain_class('userportal::perlenv') }
    it { should contain_class('userportal::portal').that_requires('Class[userportal::perlenv]') }
    it_behaves_like 'perlenv'
    it_behaves_like 'portal'
  end

  context 'perlenv_only =>' do
    context 'false' do
      let(:params) do
        {
          :perlmods_git => 'git@example.org:foo/perlmods.git',
          :portal_git   => 'git@example.org:foo/portal.git',
          :perlenv_only => false,
        }
      end

      it { should contain_class('userportal::perlenv') }
      it { should contain_class('userportal::portal').that_requires('Class[userportal::perlenv]') }
      it_behaves_like 'perlenv'
      it_behaves_like 'portal'
    end

    context 'true' do
      let(:params) do
        {
          :perlmods_git => 'git@example.org:foo/perlmods.git',
          :portal_git   => 'git@example.org:foo/portal.git',
          :perlenv_only => true,
        }
      end

      it { should contain_class('userportal::perlenv') }
      it { should_not contain_class('userportal::portal') }
      it_behaves_like 'perlenv'
    end
  end
end
