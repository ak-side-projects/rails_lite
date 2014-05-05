require 'json'
require 'webrick'

class Session
  def initialize(req)
    req.cookies.each do |cookie|
      if cookie.name == '_rails_lite_app'
        @session_cookie = JSON.parse(cookie.value)
      end
    end

    @session_cookie ||= {}
  end

  def [](key)
    @session_cookie[key]
  end

  def []=(key, val)
    @session_cookie[key] = val
  end

  def store_session(res)
    res.cookies << WEBrick::Cookie.new('_rails_lite_app', @session_cookie.to_json)
  end
end

class Flash
  def initialize(req)

    req.cookies.each do |cookie|
      if cookie.name == '_rails_lite_app'
        @flash_cookie = JSON.parse(cookie.value)
      end
    end

    @flash_cookie ||= {}
  end

  def [](key)
    @flash_cookie[key]
  end

  def []=(key, val)
    @flash_cookie[key] = val
  end
  d
  def now

  end

  def store_flash(res)
    res.cookies << WEBrick::Cookie.new('_rails_lite_app', @flash_cookie.to_json)
  end

end
