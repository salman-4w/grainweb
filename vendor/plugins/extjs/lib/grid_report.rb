class GridReport
  attr_reader :title, :filename

  # @grid_title - title used by grid
  # @filter - filter used by grid, will be appended to PDF title
  # @model_mapping - hash with model mapping data
  # @collection - collection of the object grid hashes, collected using to_grid_hash method
  def initialize(grid_title, filter, model_mapping, collection)
    title = grid_title.blank? ? "Grid Content" : grid_title

    @filename = (!filter.blank? && !filter[:status].blank? ? "#{filter[:status]} #{title}" : title).downcase.gsub(" ", "_")
    @filename << '.pdf'

    @title = title
    @title << " (#{filter[:status].capitalize})" if !filter.blank? && !filter[:status].blank?

    # remove "actions" from mapping, because it used for render custom row actions in grid and
    # not need in PDF
    @model_mapping = model_mapping.delete_if { |mapping| mapping[:grid_id] && (mapping[:grid_id] == 'actions' || mapping[:grid_id].starts_with?('link')) }

    @collection = collection
  end

  def table
    @table ||= { :headers => table_headers, :data => table_data }
  end

  private
  def table_headers
    @table_headers ||= @model_mapping.map { |value| value[:title] }
  end

  def table_data
    unless @table_data
      @table_data = []
      @collection.each do |row|
        @table_data << @model_mapping.map do |mapping|
          value_id = mapping[:grid_id] || mapping[:method]
          format_cell_value(row[value_id], mapping[:renderer])
        end
      end

      @table_data << ([""] * @model_mapping.size) if @table_data.empty?
    end
    @table_data
  end

  def format_cell_value(value, renderer)
    return nil unless value

    case renderer
      when 'date' then value.to_s(:report)
      when 'Ext.util.Format.usMoney' then helpers.number_to_currency(value)
      # TODO: implement me
      # when 'time':
      when 'quantity' then helpers.number_with_precision(value, :precision => 2, :delimeter => ',')
      else value
    end
  end

  def helpers
    ActionController::Base.helpers
  end
end
