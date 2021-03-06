#
#  FBStartupView.rb
#  RailsMailPreview
#
#  Created by Fernando Barajas on 8/28/11.
#  Copyright 2011 Fernando Barajas. All rights reserved.
#

if File.exists?("#{RESOURCE_PATH}/FRBSideView.rb")
require "#{RESOURCE_PATH}/FRBSideView.rb"
elsif File.exists?("#{RESOURCE_PATH}/FRBSideView.rbo")
require "#{RESOURCE_PATH}/FRBSideView.rbo"
end

class FBStartupView < FRBSideView
  attr_accessor :message

  def load_startup_html
    template_path = NSBundle.mainBundle.pathForResource("startup.html", ofType:"erb")
    template = File.open(template_path) {|f| f.read }
    rhtml = ERB.new(template)
    self.loadHTMLString(rhtml.result(binding))
  end

  def render
    self.load_startup_html
    self
  end

  def render_message
    self.message
  end

  def render_stylesheet
    css_path = NSBundle.mainBundle.pathForResource("startup", ofType:"css")
    %Q{<link href="file://#{css_path}" rel="stylesheet" type="text/css" />}
  end
end
