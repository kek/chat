require 'eventmachine'
require 'evma_httpserver'

class WebPageServer < EM::Connection
  include EM::HttpServer

  def initialize
    @start_html = open("start.html").read
    @unknown_page = open("404.html").read
  end

  def post_init
    super
    no_environment_strings
  end

  def process_http_request
    #   @http_protocol
    #   @http_request_method
    #   @http_cookie
    #   @http_if_none_match
    #   @http_content_type
    #   @http_path_info
    #   @http_request_uri
    #   @http_query_string
    #   @http_post_content
    #   @http_headers

    puts "#{@http_request_method} #{@http_request_uri}"

    response = EM::DelegatedHttpResponse.new(self)

    if @http_request_uri == "/"
      response.status = 200
      response.content_type "text/html; charset=utf-8"
      response.content = start_html
    elsif @http_request_uri == "/login" && @http_request_method == "POST"
      response.status = 200
      response.content_type 'text/plain'
      response.content = "Logging in"
    else
      response.status = 404
      response.content_type 'text/html; charset=utf-8'
      response.content = unknown_page
    end

    response.send_response
  end

  private

  attr_reader :start_html, :unknown_page
end
