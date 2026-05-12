module Billetto
  class Client
    class Error < StandardError; end
    class AuthenticationError < Error; end
    class ServerError < Error; end

    def initialize(access_key: ENV["BILLETTO_ACCESS_KEY_ID"],
                   secret_key: ENV["BILLETTO_SECRET_KEY"],
                   base_url:   ENV["BILLETTO_API_BASE_URL"])
      @access_key = access_key
      @secret_key = secret_key
      @base_url   = base_url
    end

    def public_events(page: 1, per_page: 25)
      response = connection.get("/api/v3/public/events") do |req|
        req.params["page"]     = page
        req.params["per_page"] = per_page
      end

      handle_response(response)
    end

    private

    def connection
      @connection ||= Faraday.new(url: @base_url) do |conn|
        conn.headers["Api-Keypair"] = "#{@access_key}:#{@secret_key}"
        conn.headers["Accept"]      = "application/json"
        conn.request  :retry, max: 2, interval: 0.5
        conn.response :json, content_type: /\bjson$/
        conn.adapter  Faraday.default_adapter
      end
    end

    def handle_response(response)
      case response.status
      when 200..299 then response.body
      when 401, 403 then raise AuthenticationError, "Billetto auth failed (#{response.status})"
      when 500..599 then raise ServerError, "Billetto server error (#{response.status})"
      else
        raise Error, "Unexpected response from Billetto (#{response.status})"
      end
    end
  end
end