require 'rubygems'
require 'yaml'
require 'open-uri'
require 'active_support/core_ext/hash'
require 'pdfkit'

$LOAD_PATH << 'lib'
require 'standalone_action_view'

GITHUB_USER_DATA = 'http://github.com/api/v1/yaml/grosser'
CACHE = '.cached_github_data.yml'

data = if File.exist?(CACHE)
  File.read(CACHE)
else
  uncached = open(GITHUB_USER_DATA).read
  File.open(CACHE,'w'){|f| f.write uncached }
  uncached
end

data = YAML.load(data)['user'].with_indifferent_access
result = StandaloneActionView.render(File.read('index.html.erb'), :locals => {:data => data})
File.open('index.html','w'){|f| f.write result}

PDFKit.new(result, :page_size => 'A4', :zoom => '3').to_file('cv.pdf')
