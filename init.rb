require 'redmine'
require 'dispatcher'
require 'issue_query_patch'

unless Redmine::Plugin.registered_plugins.keys.include?(:redmine_issue_query_operators)
	Redmine::Plugin.register :redmine_issue_query_operators do
	  name 'Issue query operators plugin'
	  author 'Nikita Vasiliev'
	  author_url 'mailto:sharpyfox@gmail.com'
	  description 'Issue query operators plugin for Redmine'
	  version '0.0.1'
    requires_redmine :version_or_higher => '1.3.0'
	end
end

Dispatcher.to_prepare :redmine_issue_query_operators do
  require_dependency 'query'

  unless Query.included_modules.include? IssueQuery::Patches::QueryModelPatch
    Query.send(:include, IssueQuery::Patches::QueryModelPatch)
  end
end
