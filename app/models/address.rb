class Address < Intersys::Serial::Object
  self.table_name = "AddressClass"

  def to_s(format = :long)
    case format
      when :long then "#{city}, #{state.abbrev if state} #{addr1} #{addr2}"
      when :short then "#{city}, #{state.abbrev if state}"
    end
  end

  # def coordinates
  #   unless @coordinates
  #     unless @location.blank?
  #       @coordinates = location.coordinates
  #     else
  #       results = begin
  #         Ym4r::YahooMaps::BuildingBlock::Geocoding.get street: @addr1, city: @city, state: state.abbrev, zip: @zip
  #       rescue
  #         Geocoding::get("#{@addr1} #{@city}, #{state.abbrev}")
  #       end

  #       if !results.empty? && (!results.respond_to?(:status) || (results.respond_to?(:status) && results.status == Geocoding::GEO_SUCCESS))
  #         @coordinates = results[0].latlon
  #       end
  #     end
  #   end
  #   @coordinates
  # end
end
