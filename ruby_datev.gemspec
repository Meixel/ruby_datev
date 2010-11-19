# -*- encoding: utf-8 -*-
lib = File.expand_path('../lib/', __FILE__)
$:.unshift lib unless $:.include?(lib)
 
 
Gem::Specification.new do |s|
  s.name                      = "ruby_datev"                                                                        
  s.version                   = '0.0.1'                                                                      
  s.platform                  = Gem::Platform::RUBY                                                                
  s.authors                   = ["Michael Eickenberg  "]                                                                 
  s.email                     = ["michael@cice-online.net"]                                                         
  s.homepage                  = "http://meixel.github.com"                                                        
  s.summary                   = "Ruby gem for DATEV German accounting format"                                
  s.description               = "ruby_datev can read and write DATEV accounting files into and out of hashes"
  
  s.required_rubygems_version = ">= 1.3.6"
 
  s.add_dependency 'ooor'
 
  s.files        =  Dir["**/*"] - 
                    Dir["coverage/**/*"] - 
                    Dir["rdoc/**/*"] - 
                    Dir["doc/**/*"] - 
                    Dir["sdoc/**/*"] - 
                    Dir["rcov/**/*"]
  s.require_path = 'lib'
end