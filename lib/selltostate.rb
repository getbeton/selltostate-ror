# Generated from OpenAPI. Do not edit methods by hand.
require "json"
require "net/http"
require "uri"

DEFAULT_BASE_URL = "https://app.selltostate.com"

class AuthError < StandardError
  attr_reader :body
  def initialize(body)
    super("unauthorized")
    @body = body
  end
end

class PaymentError < StandardError
  attr_reader :body, :payment_link, :plan, :machine_payment
  def initialize(body)
    super("payment_required")
    @body = body.is_a?(Hash) ? body : {}
    @payment_link = @body["payment_link"]
    @plan = @body["plan"]
    @machine_payment = @body["machine_payment"]
  end
end

class RateLimitError < StandardError
  attr_reader :body
  def initialize(body)
    super("rate_limited")
    @body = body
  end
end

class SellToState
  attr_reader :base_url, :api_key, :client_id

  def initialize(api_key: nil, client_id: nil, base_url: nil, transport: nil)
    @api_key = api_key.nil? ? ENV["STS_API_KEY"] : api_key
    @client_id = client_id
    raw = base_url || ENV["STS_API_URL"] || DEFAULT_BASE_URL
    @base_url = raw.sub(%r{/+$}, "")
    @transport = transport
  end

  def request(method, path, args, path_params)
    url_path = path.dup
    path_params.each do |name|
      value = args[name] || args[name.to_sym]
      raise ArgumentError, "missing path param: #{name}" if value.nil? || value == ""
      url_path = url_path.sub("{" + name + "}", URI.encode_www_form_component(value.to_s))
    end
    query = []
    args.each do |key, value|
      key = key.to_s
      next if path_params.include?(key) || key == "body" || value.nil? || value == ""
      query << [key, value.to_s]
    end
    url = @base_url + url_path
    url += "?" + URI.encode_www_form(query) unless query.empty?
    headers = { "accept" => "application/json" }
    if @api_key && !@api_key.empty?
      headers["x-api-key"] = @api_key
    elsif @client_id && !@client_id.empty?
      headers["authorization"] = "Bearer client:" + @client_id
    end
    body = nil
    raw_body = args["body"] || args[:body]
    if !raw_body.nil? && method != "GET"
      headers["content-type"] = "application/json"
      body = JSON.generate(raw_body)
    end
    if @transport
      status, text = @transport.call(url, method, headers, body)
    else
      uri = URI(url)
      http = Net::HTTP.new(uri.host, uri.port)
      http.use_ssl = uri.scheme == "https"
      req = Net::HTTP.const_get(method.capitalize).new(uri)
      headers.each { |k, v| req[k] = v }
      req.body = body if body
      res = http.request(req)
      status = res.code.to_i
      text = res.body
    end
    parsed = nil
    if text && !text.empty?
      begin
        parsed = JSON.parse(text)
      rescue JSON::ParserError
        parsed = text
      end
    end
    raise AuthError.new(parsed) if status == 401
    raise PaymentError.new(parsed) if status == 402
    raise RateLimitError.new(parsed) if status == 429
    raise "HTTP #{status}" if status >= 400
    parsed
  end

  def searchAwards(args = {})
    request("GET", "/api/v1/awards", args, [])
  end

  def exportAwardsCsv(args = {})
    request("GET", "/api/v1/awards.csv", args, [])
  end

  def getPrice(args = {})
    request("GET", "/api/v1/price", args, [])
  end

  def payAutonomously(args = {})
    request("POST", "/api/v1/pay", args, [])
  end

  def registerClient(args = {})
    request("POST", "/api/oidc/register", args, [])
  end

  def mcp(args = {})
    request("POST", "/api/mcp", args, [])
  end

  def protectedResourceMetadata(args = {})
    request("GET", "/.well-known/oauth-protected-resource", args, [])
  end

  def authorizationServerMetadata(args = {})
    request("GET", "/.well-known/oauth-authorization-server", args, [])
  end

  def whoami(args = {})
    request("GET", "/api/v1/whoami", args, [])
  end

  def search(args = {})
    request("GET", "/api/v1/search", args, [])
  end

  def listBuyers(args = {})
    request("GET", "/api/v1/buyers", args, [])
  end

  def getBuyer(args = {})
    request("GET", "/api/v1/buyers/{slug}", args, ["slug"])
  end

  def listSuppliers(args = {})
    request("GET", "/api/v1/suppliers", args, [])
  end

  def getSupplier(args = {})
    request("GET", "/api/v1/suppliers/{slug}", args, ["slug"])
  end

  def listSectors(args = {})
    request("GET", "/api/v1/sectors", args, [])
  end

  def getSector(args = {})
    request("GET", "/api/v1/sectors/{slug}", args, ["slug"])
  end

  def getTender(args = {})
    request("GET", "/api/v1/tenders/{id}", args, ["id"])
  end

  def getLists(args = {})
    request("GET", "/api/v1/lists", args, [])
  end

  def createList(args = {})
    request("POST", "/api/v1/lists", args, [])
  end

  def getList(args = {})
    request("GET", "/api/v1/lists/{id}", args, ["id"])
  end

  def renameList(args = {})
    request("PATCH", "/api/v1/lists/{id}", args, ["id"])
  end

  def deleteList(args = {})
    request("DELETE", "/api/v1/lists/{id}", args, ["id"])
  end

  def addToList(args = {})
    request("POST", "/api/v1/lists/{id}/items", args, ["id"])
  end

  def removeFromList(args = {})
    request("DELETE", "/api/v1/lists/{id}/items", args, ["id"])
  end

  def getSavedSearches(args = {})
    request("GET", "/api/v1/saved-searches", args, [])
  end

  def saveSearch(args = {})
    request("POST", "/api/v1/saved-searches", args, [])
  end

  def getSavedSearch(args = {})
    request("GET", "/api/v1/saved-searches/{id}", args, ["id"])
  end

  def renameSavedSearch(args = {})
    request("PATCH", "/api/v1/saved-searches/{id}", args, ["id"])
  end

  def deleteSavedSearch(args = {})
    request("DELETE", "/api/v1/saved-searches/{id}", args, ["id"])
  end
end
