require_relative './api_helper'

module ExercismAPI
  module Routes
    class Legacy < Core
      get '/' do
        require_key
        "OK"
      end
    end
  end
end

class ApiTest < MiniTest::Unit::TestCase
  include Rack::Test::Methods
  include AppTestHelper
  include DBCleaner

  def app
    ExercismAPI::App
  end

  def alice
    @alice ||= User.create(username: 'alice', github_id: 1)
  end

  def test_require_user_tells_guest_401
    get '/'
    assert_equal 401, last_response.status
    assert_equal "You must be logged in to access this feature. Please double-check your API key.", JSON.parse(last_response.body)['error']
  end

  def test_require_user_accepts_api_key
    get '/', key: alice.key
    assert_equal 200, last_response.status
    assert_equal "OK", last_response.body
  end

  def test_does_not_blow_up_if_no_such_user_key
    get '/', key: "123"
    assert_equal 401, last_response.status
    assert_equal "You must be logged in to access this feature. Please double-check your API key.", JSON.parse(last_response.body)['error']
  end
end

