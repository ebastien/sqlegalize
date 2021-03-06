class Api::V1::EntryController < ApplicationController
  def index
    rep = {
      api: {
        href: api_v1_url,
        links: {
          r_new_query: api_v1_queries_url
        },
        version: 1
      }
    }
    render_api json: rep
  end
end
