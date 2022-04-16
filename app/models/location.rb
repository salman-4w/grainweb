class Location < ActiveRecord::Base
  # See: http://www.codeproject.com/dotnet/Zip_code_radius_search.asp
  # Degrees to Radians converstion factor (take inverse for opposite)
  DEGREES_TO_RADIANS = (Math::PI/180).freeze

  MILES_PER_LATITUDE_DEGREE = (69.1).freeze
  EARTH_RADIUS_IN_MILES = 3963
  LATITUDE_DEGREES = (EARTH_RADIUS_IN_MILES / MILES_PER_LATITUDE_DEGREE).freeze

  DEFAULT_RADIUS = 30

  default_scope select([:id, :city, :state, :city_state, :city_st, :latitude,
    :longitude])

  belongs_to :state

  def to_s(format = :short)
    case format
      when :long then city_state
      when :short then city_st
    end
  end

  def coordinates
    [self.latitude, self.longitude]
  end

  class << self
    def find_origins_closest_to(location, radius = DEFAULT_RADIUS)
      lat, lon = location.is_a?(Array) ? location : location.coordinates
      self.select("DISTINCT(Location.%Id), Location.*, #{distance_sql(lat, lon)} AS distance") \
        .joins('LEFT JOIN HM.Contract AS Contract ON Contract.Loc = Location.%Id') \
        .where(["#{distance_sql(lat, lon)} <= ? AND (Contract.ShowOnFrtGrid = 'AW' OR Contract.ShipStart >= ? AND Contract.UnSettle > 0) AND (Contract.Deleted = 0 OR Contract.Deleted IS NULL)", radius, Time.now]) \
        .order('distance ASC')
    end

    def find_origin_by_location(location)
      raise ArgumentError unless location =~ /^(\d+)|(\w+,\s{0,1}\w\w)$/

      if location =~ /^\d+$/
        results = begin
          Ym4r::YahooMaps::BuildingBlock::Geocoding.get zip: location
        rescue
          Geocoding::get(location)
        end
        if !results.empty? && (!results.respond_to?(:status) || (results.respond_to?(:status) && results.status == Geocoding::GEO_SUCCESS))
          result = results[0]
          location = "#{result[:city]}, #{result[:state]}"
        end
      end

      self.joins('LEFT JOIN HM.Contract AS Contract ON Contract.Loc = Location.%Id') \
        .where(["Location.CityState = ? AND (Contract.ShowOnFrtGrid = 'AW' OR Contract.ShipStart >= ? AND Contract.UnSettle > 0) AND (Contract.Deleted = 0 OR Contract.Deleted IS NULL)", location, Time.now])
    end

    def find_origins_for_destination(destination)
      self.joins('LEFT JOIN HM.Contract AS Contract ON Contract.Loc = Location.%Id') \
        .where(["Contract.Cust->Ship_City = ? AND Contract.Cust->Ship_State = ? AND Location.City != ? AND Location.State->Abbrev != ? AND (Contract.ShowOnFrtGrid = 'AW' OR Contract.ShipStart >= ? AND Contract.UnSettle > 0) AND (Contract.Deleted = 0 OR Contract.Deleted IS NULL)", destination.city, destination.state.id, destination.city, destination.state.id, Time.now])
    end

    private

    def distance_sql(latitude, longitude)
      lat_degree_units = MILES_PER_LATITUDE_DEGREE
      lon_degree_units = miles_per_longitude_degree(latitude)
      "({ fn SQRT(POWER(#{lat_degree_units} * ( #{latitude} - Location.latitude),2) + POWER( #{lon_degree_units} * ( #{longitude} - Location.longitude),2)) })"
    end

    def miles_per_longitude_degree(latitude)
      (LATITUDE_DEGREES * Math.cos(latitude * DEGREES_TO_RADIANS)).abs
    end
  end
end
