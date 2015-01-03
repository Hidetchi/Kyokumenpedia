SITE_NAME = "局面ペディア"
if Rails.env == "production"
  ROOT_PATH = "http://kyokumen.jp"
else
  ROOT_PATH = "http://127.0.0.1:3000"
end
