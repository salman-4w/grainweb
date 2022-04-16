module Acts
  module ExtJS
    module Grid
      def self.included(base)
        base.extend ClassMethods
      end

      module ClassMethods
        def acts_as_grid(*args)
          include InstanceMethods
          extend ClassMethods
        end
      end
      
      module InstanceMethods
        def to_grid_hash(grid_key = nil)
          @hash_for_grid ||= self.class.grid_mapping_for(grid_key).inject({}) do |result, mapping|
            # split method.with.dots to different method names and call one by one
            result[mapping[:grid_id] || mapping[:method]] = mapping[:method].split(".").inject(self) {|obj, method| obj = obj.try(method) }
            result
          end.merge(:id => self.id)
        end
        
        def empty_grid_cell
          ''
        end
      end
      
      module ClassMethods
        %w{ mapping filters editors}.each do |name|
          define_method "grid_#{name}_for" do |*args|
            key = args.shift
            method_name = "grid_#{name}_for_#{key}"
            (key && self.respond_to?(method_name)) ? self.send(method_name) : self.send("grid_#{name}")
          end
        end

        def grid_mapping
          {}
        end

        def grid_filters
          {}
        end

        def grid_editors
          nil
        end
      end
    end
  end
end
