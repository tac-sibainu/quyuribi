#/Users/e115764/.rvm/rubies/ruby-1.8.7-p371/bin/ruby
# -*- encoding: utf-8 -*-

require 'rubygems'
require 'igo-ruby'

tagger = Igo::Tagger.new('ipadic')  # 解析用辞書のディレクトリを指定
t = tagger.wakati 'どこで生れたかとんと見当がつかぬ。'
puts t.join(' ')