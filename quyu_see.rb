#!/usr/local/bin/ruby
# -*- coding: utf-8 -*-

require 'rubygems'
require 'userstream'
require 'twitter'
require 'pp'
require 'twitterbot'

YOUR_CONSUMER_KEY = 'zligSChuUTebhlXOmXLMGw'
YOUR_CONSUMER_SECRE = 'mYol6uhZkBfsXmVsjUYlzjUDJhvr4fi6HF912IPI'
YOUR_OAUTH_TOKEN = '1397935476-g96kSFncvR7RGSJ0LuHKTnKVa5M5BE3NosIMWpB'
YOUR_OAUTH_TOKEN_SECRET = 'b5Oe5auRCesyDkCfUvB0cHsOvyjMKnVncCbXMI2Jg'

UserStream.configure do |config|
    config.consumer_key = YOUR_CONSUMER_KEY
    config.consumer_secret = YOUR_CONSUMER_SECRE
    config.oauth_token = YOUR_OAUTH_TOKEN
    config.oauth_token_secret = YOUR_OAUTH_TOKEN_SECRET
end

Twitter.configure do |config|
    config.consumer_key = YOUR_CONSUMER_KEY
    config.consumer_secret = YOUR_CONSUMER_SECRE
    config.oauth_token = YOUR_OAUTH_TOKEN
    config.oauth_token_secret = YOUR_OAUTH_TOKEN_SECRET
end

client = UserStream.client

#----------------------------#
counter = 0
# １時間に１ツイートをするために…:00の時にツイートを行う
t = Time.now
if t.min == 0
   while counter < 2
       begin
           bot = TwitterBot::Crawler.new('@Quyu_see', '@hexad_chrome')
           bot.study
           bot.tweet
           bot.reply_to_mentions
           break
       rescue Exception => e
           puts e
           counter += 1
       end
    end
    # sleepをしないとCPU負荷が高い
    sleep 60
    
    else t.min == 30
        while counter < 2
            begin
                bot = TwitterBot::Crawler.new('@Quyu_see', '@hexad_chrome')
                bot.study
                bot.tweet
                bot.reply_to_mentions
                break
                rescue Exception => e
                puts e
                counter += 1
            end
        end
        # sleepをしないとCPU負荷が高い
        sleep 60
end
