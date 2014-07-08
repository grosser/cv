require 'rubygems'
require 'yaml'
require 'json'
require 'open-uri'
require 'active_support/core_ext/hash'
require 'action_view'
require 'pdfkit'

module CvHelper
  def url_for(x);x;end

  def clearer
    '<div style="clear:both"></div>'.html_safe
  end

  def projects(*names)
    names.map{|name| link_to_project(name) }.join(', ').html_safe
  end

  def link_to_project(name)
    link_to name, "https://github.com/grosser/#{name}"
  end
end

def repos(username)
  repos = []
  per_page = 100
  page = 1
  loop do
    found = api("/users/#{username}/repos?type=all&page=#{page}&per_page=#{per_page}")
    repos += found
    page += 1
    break if found.size < per_page
  end
  repos
end

def data_from_github(username)
  file_cache('.cached_github_data.json') do
    api("/users/#{username}").merge("repos" => repos(username))
  end
end

def api(path)
  JSON.load(open("https://api.github.com#{path}").read)
end

def file_cache(file)
  if File.exist?(file) and File.mtime(file) > (Time.now - 24*60*60) # fresh ?
    JSON.load(File.read(file))
  else
    uncached = yield
    File.open(file,'w'){|f| f.write JSON.dump(uncached) }
    uncached
  end
end

def render(template, options)
  klass = Class.new(ActionView::Base)
  klass.send(:include, CvHelper)
  view = klass.new
  view.render(options.merge(:file => template))
end

html = render('index.html.erb', :locals => {:data => data_from_github('grosser')})
File.open('index.html','w'){|f| f.write html }
PDFKit.new(html, :page_size => 'A4', :zoom => '3', :print_media_type => true).to_file('cv.pdf')
