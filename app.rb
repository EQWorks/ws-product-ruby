require 'sinatra'
require 'sinatra/json'
require 'pg'

get '/' do
  'Welcome to EQ Works 😎'
end

get '/events/hourly' do
  json query_helper '''
    SELECT date, hour, events
    FROM public.hourly_events
    ORDER BY date, hour
    LIMIT 168;
  '''
end

get '/events/daily' do
  json query_helper '''
    SELECT date, SUM(events) AS events
    FROM public.hourly_events
    GROUP BY date
    ORDER BY date
    LIMIT 7;
  '''
end

get '/stats/hourly' do
  json query_helper '''
    SELECT date, hour, impressions, clicks, revenue
    FROM public.hourly_stats
    ORDER BY date, hour
    LIMIT 168;
  '''
end

get '/stats/daily' do
  json query_helper '''
    SELECT date,
      SUM(impressions) AS impressions,
      SUM(clicks) AS clicks,
      SUM(revenue) AS revenue
    FROM public.hourly_stats
    GROUP BY date
    ORDER BY date
    LIMIT 7;
  '''
end

get '/poi' do
  json query_helper '''
    SELECT *
    FROM public.poi;
  '''
end

def query_helper (query)
  res = []

  begin
    # configs come from standard PostgreSQL env vars
    # https://www.postgresql.org/docs/9.6/static/libpq-envars.html
    conn = PG.connect
    rows = conn.exec query

    rows.each do |row|
      res.push row
    end
  ensure
    conn.close if conn
  end

  res
end
