class Api::V1::QueriesController < ApplicationController
  def create
    query = params['queries']
    return invalid_params unless query && query.is_a?(Hash)
    sql = query['sql']
    return invalid_params unless sql && sql.is_a?(String)
    ast = SQLiterate::QueryParser.new.parse sql
    return invalid_params unless ast

    token = SecureRandom.hex(16)
    seq = Resque.redis.incr('sql:seq')
    id = [token, seq].join '_'

    Resque.enqueue(Query, id, sql)

    href = api_v1_query_url(id)
    rep = {
      queries: {
        id: id,
        href: href,
        sql: sql,
        tables: ast.tables
      }
    }
    response.headers['Location'] = href
    render_api json: rep, status: 201
  end

  def show
    id = params[:id]
    offset = [params[:offset].to_i, 0].max
    limit = [[params[:limit].to_i, 1].max, 10000].min
    query_id = "sql:query:#{id}"

    rows = Resque.redis.lrange(query_id, offset, offset + limit - 1)

    href = api_v1_query_url(id)
    rep = {
      queries: {
        id: id,
        href: href,
        offset: offset,
        limit: limit,
        rows: rows
      }
    }
    render_api json: rep, status: 200
  end
end
