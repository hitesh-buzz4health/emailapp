json.array!(@histories) do |history|
  json.extract! history, :id, :list, :name, :subject, :cta, :count
  json.url history_url(history, format: :json)
end
