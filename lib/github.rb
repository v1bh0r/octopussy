require 'faraday'

class Github
  attr_accessor :oauth_token

  def initialize oauth_token
    @oauth_token = oauth_token
    @conn = Faraday.new(:url => 'https://api.github.com')
  end

  def find_in_cache(key)
    CACHE.get key
  end

  def save_in_cache(key, value)
    CACHE.set key, value
  end

  def request(url, options={})
    cache_key = Digest::SHA1.hexdigest("#{@oauth_token}:#{url}:#{options[:params]}:#{options[:headers]}")
    cached_value = find_in_cache cache_key unless options[:skip_cache]

    res = @conn.get do |req|
      req.url url
      if cached_value
        req.headers['If-Modified-Since'] = cached_value[:updated_at]
      end
      req.headers['Authorization'] = "token #{@oauth_token}"

      options[:headers].each_pair do |header, value|
        req.headers[header] = value
      end if options[:headers]

      options[:params].each_pair do |param, value|
        req.params[param] = value
      end if options[:params]
    end

    case res.status
      when 304
        puts 'Sending from cache'
        return cached_value[:response]
      when 200
        puts 'made a hit on github'
        response = JSON.parse res.body, :symbolize_names => true
        updated_at = res.headers['last-modified']
        save_in_cache cache_key, updated_at: updated_at, response: response
        return response
      else
        return nil
    end
  end

  def repos(options = {})
    request '/user/repos', options
  end

  def milestones(project_owner, project_name, options = {})
    request "/repos/#{project_owner}/#{project_name}/milestones", options
  end

  def collaborators(project_owner, project_name, options={})
    request "/repos/#{project_owner}/#{project_name}/collaborators", options
  end
end