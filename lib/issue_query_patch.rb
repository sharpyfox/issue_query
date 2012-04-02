module IssueQuery
  module Patches
    module QueryModelPatch
      def self.included(base) # :nodoc:
        base.extend(ClassMethods)
        base.send(:include, InstanceMethods)

        base.class_eval do
          alias_method_chain :sql_for_field, :issue_range          
		  alias_method_chain :available_filters, :issue_range

          class << self            
			alias_method_chain :operators_by_filter_type, :issue_range
            alias_method_chain :operators, :issue_range
          end
        end
      end
      
      module ClassMethods
        def operators_with_issue_range
          o=operators_without_issue_range
          if o[":"].blank?
            o[":"]=:label_issue_list
          end
          o # return
        end

        def operators_by_filter_type_with_issue_range
          o = operators_by_filter_type_without_issue_range
          #unless o[:list_issue].include?(":")            
            o[:list_issue] = ":"
          #end
          o # return
        end
      end
      
      module InstanceMethods	  
		def available_filters_with_issue_range
          f = available_filters_without_issue_range
		  f["id"] = { :type => :list_issue, :order => 15 }          
          f # return
        end

        def get_issue_range_from_string(issue_str)
          format_issue = issue_str.to_s.gsub(/\s+/, '')
		  issue_str.split(",") # return
        end

        def sql_for_field_with_issue_range(field, operator, value, db_table, db_field, is_custom_filter=false)
          sql=case operator
            when ":"
				case type_for(field)
					when :list_issue
						value = get_issue_range_from_string(value.first.strip)
						sql = "#{db_table}.#{db_field} IN (" + value.collect{|val| "'#{connection.quote_string(val)}'"}.join(",") + ")"
					else					
					# IN an empty set
						sql = "1=0"
			end
            else
              sql_for_field_without_issue_range(field, operator, value, db_table, db_field, is_custom_filter)
          end
          sql
        end        
      end
    end

  end
end
