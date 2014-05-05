require 'erb'
require 'active_support/inflector'
require 'active_support/core_ext'
require_relative 'params'
require_relative 'session'

class DoubleRenderError < StandardError
end


class ControllerBase
  attr_reader :params, :req, :res

  def initialize(req, res, route_params = {})
    @req, @res = req, res
    @params = Params.new(req, route_params)
  end

  def render_content(content, type)
    raise DoubleRenderError, "You can't render twice." if already_rendered?

    unless @already_built_response
      @res.status = 200
      @res.content_type = type
      @res.body = content
      session.store_session(@res)
      @already_built_response = true
    end
  end

  def already_rendered?
    @already_built_response
  end

  def redirect_to(url)
    raise DoubleRenderError, "You can't render twice." if already_rendered?

    unless @already_built_response
      @res.status = 302
      @res['location'] = url
      session.store_session(@res)
      @already_built_response = true
    end
  end

  def render(template_name)
    raise DoubleRenderError, "You can't render twice." if already_rendered?

    unless already_rendered?
      controller_name = self.class.to_s.underscore
      template_file = File.read("views/#{controller_name}/#{template_name}.html.erb")
      content = ERB.new(template_file).result(binding)
      render_content(content, 'text/html')
      @already_built_response = true
    end
  end

  def session
    @session ||= Session.new(@req)
  end

  def flash
    @flash ||= Flash.new(@req)
  end

  def invoke_action(name)
    self.send(name)
    self.render(name) unless already_rendered?
  end
end
