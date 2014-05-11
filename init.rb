require 'redmine'

unless Redmine::Plugin.registered_plugins.keys.include?(:issue_query)
  Redmine::Plugin.register :issue_query do
    name 'Issue query operators plugin'
    author 'Nikita Vasiliev'
    author_url 'mailto:sharpyfox@gmail.com'
    description 'Redmine plugin which add filter by issues id'
    version '0.0.3'
    requires_redmine :version_or_higher => '1.3.0'
  end
end

# Including dispatcher.rb in case of Rails 2.x
require 'dispatcher' unless Rails::VERSION::MAJOR >= 3

if Rails::VERSION::MAJOR >= 3
  ActionDispatch::Callbacks.to_prepare do
    require 'issue_query_patch'
  end
else
  Dispatcher.to_prepare :issue_query do    
    require 'issue_query_patch'
  end
end
