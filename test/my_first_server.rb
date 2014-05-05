require 'active_support/core_ext'
require 'webrick'
require_relative '../lib/rails_lite'

server = WEBrick::HTTPServer.new :Port => 8080

class MyController < ControllerBase
  def show
    session["count"] ||= 0
    session["count"] += 1
    flash[:errors] = "help. i got an error."
    render :errors
  end
end

router = Router.new
router.draw do
  get Regexp.new("^/users$"), MyController, :show
end

server.mount_proc '/' do |req, res|
  route = router.run(req, res)
end


trap('INT') { server.shutdown }

server.start