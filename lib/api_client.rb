
module ApiClient
  LIMIT = 500
  def get(additional_params = {})
    data = []
    last_result_index = 0
    total = 1
    while(last_result_index < total) do
      batch = get_batch(offset: last_result_index, additional_params: additional_params)
      data.concat(batch["data"])
      total = batch["metadata"]["results"]["total"]
      index = batch["metadata"]["results"]["index"]
      current_item_count = batch["metadata"]["results"]["current_item_count"]
      last_result_index = index + current_item_count
    end
    data
  end
  
  def get_batch(offset: 0, additional_params: {})
    uri = base_uri
    params = base_params.merge({
      :limit => LIMIT,
      :offset => offset
    })
    params.merge!(additional_params)
    uri.query = URI.encode_www_form(params)
    
    res = make_request(uri)
    raise StandardError.new "The API returned a non 200 reponse\n#{res.body}" if res.code.to_i != 200
    JSON.parse(res.body)
  end

  def make_request(uri)
    req = Net::HTTP::Get.new(uri)
    req.basic_auth @options.api_key, @options.api_secret

    Net::HTTP.start(uri.host, uri.port, :use_ssl => true) {|http|
      http.request(req)
    }
  end

  class InvalidResponse < StandardError
  end
end
