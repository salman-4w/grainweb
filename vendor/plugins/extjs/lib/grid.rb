module ExtJS
  module Grid
    def self.included(base)
      base.class_eval do
        extend ClassMethods
        include InstanceMethods
      end
    end

    module ClassMethods
      def grid(*arguments)
        options = arguments.extract_options!

        method_name = options[:method] || 'index'

        define_method method_name do
          # execute before callback
          exec_filter(options[:before])

          model_class_name = options[:class_name] || self.class.name.sub('Controller', '').singularize
          model_class = model_class_name.constantize
          association = options[:association]

          grid_key = options[:grid_for] || controller_name
          grid_filters = model_class.grid_filters_for(grid_key)
          # remove "action links" column if exist, because we don't need it for SQL generation
          grid_mapping = model_class.grid_mapping_for(grid_key).delete_if { |mapping| mapping[:method].match("action") }

          ##### CONDITIONS
          # when exec_filter return nil initialize conditions as empty array
          conditions = exec_filter(options[:global_filter]) || []

          conditions = merge_conditions(conditions, params_to_conditions(params[:filter], grid_filters, model_class.table_name)) unless params[:filter].blank?
          conditions = merge_conditions(conditions, params_to_search_conditions(params[:query], grid_mapping, model_class.table_name)) unless params[:query].blank?

          # TODO: refactor me
          if options[:finder]
            # add custom finder conditions when need
            if options[:finder][:conditions]
              custom_conditions = options[:finder][:conditions].dup

              if conditions.blank?
                conditions = custom_conditions
              else
                # FIXME: move sanitizing into class
                if sanitized_conditions = ActiveRecord::Base.sanitize(custom_conditions)
                  conditions[0] << " AND (#{sanitized_conditions})"
                end
              end
            end
          end

          collection = eval("#{association || model_class_name}").where(conditions)

          ##### DATA LIMITATION
          if options[:finder]
            collection = collection.includes(*options[:finder][:include]) if options[:finder][:include]
            collection = collection.select(options[:finder][:select]) if options[:finder][:select]
          end

          ##### ORDERING
          sort_by = params[:sort]
          sort_field = grid_mapping.find { |mapping| mapping[:grid_id] == sort_by || mapping[:method] == sort_by }[:sql_column]

          # sql column for sort can contains multiple columns separated by comma
          order = sort_field.include?(',') ? sort_field.split(',').map {|el| "#{el.strip} #{params[:dir]}"}.join(',') : "#{sort_field} #{params[:dir]}"

          # remove the default order scope and apply the specified order
          collection = collection.except(:order).order(order)

          ##### LIMIT & OFFSET
          # don't use pager in PDF
          unless request.format.pdf?
            collection = collection.limit(params[:limit].to_i).offset(params[:start].to_i)
          end

          result = {}
          result[:total] = eval("#{association || model_class_name}").where(conditions).count
          result[:data] = collection.map { |obj| obj.to_grid_hash(grid_key) }

          remote_summaries = grid_mapping.find_all { |m| m[:summary_renderer].try(:match, /remoteFull/) }
          unless remote_summaries.empty?
            result[:summaries] = {}
            sum_query = eval("#{association || model_class_name}").where(conditions)
            remote_summaries.each do |item|
              result[:summaries][item[:grid_id] || item[:method]] = sum_query.sum(item[:sql_column])
            end
          end

          respond_to do |format|
            format.html
            format.pdf {
              @report = GridReport.new(params[:title], params[:global_filter], grid_mapping, result[:data])
              prawnto :filename => @report.filename
              render :template => 'shared/grid'
            }
            format.js {
              render :text => result.to_json, :layout => false
            }
          end
        end
      end
    end

    module InstanceMethods
      private
      def exec_filter(filters)
        filters = [filters].compact unless filters.is_a?(Array)
        return nil if filters.empty?

        filters.map do |filter|
          if filter.is_a?(Symbol) || filter.is_a?(String)
            send(filter)
          else
            filter.call
          end
        end.compact.join(" AND ")
      end

      def params_to_conditions(params, grid_filters, table_prefix = nil)
        conditions = ['']

        filter_conditions = []
        params.values.each do |value|
          filter = grid_filters.find { |filter| filter[:grid_id] == value[:field] }

          filter_by = value[:data][:value]

          operation = case value[:data][:comparison]
            when 'gt' then '>'
            when 'lt' then '<'
            else '='
          end

          column_name = table_prefix ? "#{table_prefix}.#{filter[:sql_column]}" : filter[:sql_column]

          case filter[:type]
          when 'string'
            if operation == '='
              filter_conditions << " #{column_name} LIKE ? "
              conditions << "%#{filter_by}%"
            else
              filter_conditions << " (#{column_name} #{operation} ? OR #{column_name} LIKE ?) "
              conditions << filter_by
              conditions << "%#{filter_by}%"
            end
          when 'list'
            #TODO
          when 'date'
            filter_conditions << " #{column_name} #{operation} ? "
            conditions << Date.parse(filter_by)
          else
            filter_conditions << " #{column_name} #{operation} ? "
            conditions << filter_by
          end
        end

        conditions[0] << filter_conditions.join(' AND ')
        conditions
      end

      def params_to_search_conditions(query, grid_mapping, table_prefix = nil)
        conditions = []

        search_for = "%#{params[:query]}%"
        search_by = grid_mapping.map do |hash|
          column_name = table_prefix ? "#{table_prefix}.#{hash[:sql_column]}" : hash[:sql_column]

          if hash[:renderer] == 'date'
            "TO_CHAR(#{column_name},\'MM/DD/YYYY\') LIKE ?"
          else
            "#{column_name} LIKE ?"
          end
        end
        search_by_sql = "(#{search_by.join(' OR ')})"

        conditions[0] = search_by_sql
        search_by.size.times { conditions << search_for }
        conditions
      end

      # merge second conditions array into first and return result
      def merge_conditions(first, second)
        result = first.is_a?(Array) ? first : [first].compact
        (result.empty? || result[0].blank?) ? result[0] = second[0] : result[0] << " AND #{second[0]}"
        result += second[1..second.size]
        result
      end
    end
  end
end
