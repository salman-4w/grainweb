class CommConv < ActiveRecord::Base
  default_scope select([:id, :conv_factor, :unit_id, :comm])

  belongs_to :comm, class_name: "Commodity"

  class << self
    def bushels_conv_factors_map
      unless @bushels_conv_factors_map
        raw_data = CommConv.connection.send(:select_rows, "SELECT cc.Comm, cc.ConvFactor FROM HM.CommConv AS cc " \
          "LEFT JOIN HM.UnitType AS ut ON cc.UnitId = ut.%Id " \
          "WHERE ut.ShortName = 'Bu.' ORDER BY cc.Comm")

        @bushels_conv_factors_map = raw_data.inject({}) do |result, raw|
          result[raw.first] = raw.last
          result
        end
      end
      @bushels_conv_factors_map
    end
  end
end
