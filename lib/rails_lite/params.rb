require 'uri'

class Params
  def initialize(req, route_params = {})
    @params ||= {}
    @params.merge!(parse_www_encoded_form(req.query_string)) if req.query_string
    @params.merge!(parse_www_encoded_form(req.body)) if req.body
    @params.merge!(route_params) if route_params
  end

  def [](key)
    @params[key.to_sym]
  end

  def permit(*keys)
    @permitted_keys_hash ||= {}
    @permitted_keys_hash.merge!(@params.select { |key, val| keys.include?(key) })
  end

  def require(key)
    raise AttributeNotFoundError unless @params.include?(key)
  end

  def permitted?(key)
    @permitted_keys_hash.include?(key)
  end

  def to_s
    @params.to_s
  end

  class AttributeNotFoundError < ArgumentError; end;

  private
  def parse_www_encoded_form(www_encoded_form)
    params = {}

    query = URI.decode_www_form(www_encoded_form)

    query.each do |key1, val1|
      keys = parse_key(key1)
      keys_hash = params

      keys.each_with_index do |key2, idx2|
        if idx2 == (keys.count - 1)
          keys_hash[key2] = val1
        else
          keys_hash[key2] ||= {}
          keys_hash = keys_hash[key2]
        end
      end

      params
    end

    params
  end

  def parse_key(key)
    keys = key.split(/\]\[|\[|\]/)
  end
end
