require 'application_helper'
require 'query'

module CustomIssueQuery  
  module Patches      
    module QueryModelPatch
      def self.included(base) # :nodoc:
        base.send(:include, InstanceMethods)

        base.class_eval do
          alias_method_chain :available_filters, :issue_range
        end
      end

      module InstanceMethods
        def available_filters_with_issue_range          
          f = available_filters_without_issue_range
          options = { :type => :text, :order => 15 }
          options[:name] = l("field_id") if Rails::VERSION::MAJOR >= 3
          f["id"] = options
          f # return
        end
        
        def get_issue_range_from_string(issue_str)
          format_issue = issue_str.to_s.gsub(/\s+/, '')
          issue_str.split(",") # return
        end             
    
        def sql_for_id_field(field, operator, value)                                        
          case operator
            when ":", "~"
              value = get_issue_range_from_string(value.first.strip)
              sql = "#{Issue.table_name}.id IN (" + value.collect{|val| "'#{connection.quote_string(val)}'"}.join(",") + ")"
            when "!~"
              value = get_issue_range_from_string(value.first.strip)
              sql = "#{Issue.table_name}.id NOT IN (" + value.collect{|val| "'#{connection.quote_string(val)}'"}.join(",") + ")"
            else                    
              # IN an empty set
              sql = "1=0"
          end         
          
          sql #return
        end     
      end        
    end #module QueryModelPatch
  end #module Patches
end

unless Query.included_modules.include? CustomIssueQuery::Patches::QueryModelPatch  
  Query.send(:include, CustomIssueQuery::Patches::QueryModelPatch)
end
