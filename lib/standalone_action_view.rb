require 'action_view'

class StandaloneActionView < ActionView::Base
  def self.render(template, options)
    new.render(options.merge(:inline => template))
  end

  def link_to_website(url)
    link_to url, url
  end

  def url_for(x)
    if x.is_a?(Hash)
      '/'
    elsif x.include?('//')
      x
    else
      x
    end
  end

  def clearer
    '<div style="clear:both"></div>'.html_safe
  end

  def projects(*names)
    names.map{|name| link_to_project(name) }.join(', ').html_safe
  end

  def link_to_project(name)
    link_to name, "http://github.com/grosser/#{name}"
  end
end