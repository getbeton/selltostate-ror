require "minitest/autorun"
require_relative "lib/selltostate"

class ClientTest < Minitest::Test
  def test_whoami_header
    seen = {}
    transport = lambda do |url, method, headers, body|
      seen[:url] = url
      seen[:headers] = headers
      seen[:calls] = (seen[:calls] || 0) + 1
      [200, "{}"]
    end
    SellToState.new(api_key: "sts_test", client_id: "nope", transport: transport).whoami
    assert_equal 1, seen[:calls]
    assert_equal DEFAULT_BASE_URL + "/api/v1/whoami", seen[:url]
    assert_equal "sts_test", seen[:headers]["x-api-key"]
    refute seen[:headers].key?("authorization")
  end

  def test_402
    calls = 0
    transport = lambda do |url, method, headers, body|
      calls += 1
      [402, '{"payment_link":"https://pay.example","plan":"data-monthly","machine_payment":{"endpoint":"https://app.selltostate.com/api/v1/pay"}}']
    end
    err = assert_raises(PaymentError) { SellToState.new(api_key: "sts_test", transport: transport).searchAwards }
    assert_equal "https://pay.example", err.payment_link
    assert_equal "data-monthly", err.plan
    assert_equal "https://app.selltostate.com/api/v1/pay", err.machine_payment["endpoint"]
    assert_equal 1, calls
  end
end
