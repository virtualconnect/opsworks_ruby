# frozen_string_literal: true
def applications
  if Chef::Config[:solo]
    Chef::Log.warn('This recipe uses search. Chef Solo does not support search.')
  end
  search(:aws_opsworks_app)
end

def rdses
  if Chef::Config[:solo]
    Chef::Log.warn('This recipe uses search. Chef Solo does not support search.')
  end
  search(:aws_opsworks_rds_db_instance)
end

def www_group
  value_for_platform_family(
    'debian' => 'www-data'
  )
end

def create_deploy_dir(application, subdir = '/')
  dir = File.join('/', 'srv', 'www', application['shortname'], subdir)
  directory dir do
    mode '0755'
    recursive true
    owner node['deployer']['user'] || 'root'
    group www_group

    action :create
    not_if { File.directory?(dir) }
  end
  dir
end

def deploy_dir(application)
  create_deploy_dir(application)
end

def every_enabled_application
  node['deploy'].each do |deploy_app_shortname, deploy|
    application = applications.detect { |app| app['shortname'] == deploy_app_shortname }
    next unless application
    deploy = deploy[application['shortname']]
    yield application, deploy
  end
end

def every_enabled_rds
  rdses.each do |rds|
    yield rds
  end
end
