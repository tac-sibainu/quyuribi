# -*- coding: utf-8 -*-

require 'rubygems'
require 'igo-ruby'
require 'net/http'
require 'twitter'
require 'uri'

class String
    def is_mention?
        match(/^@\w+\s*/)
    end
    def remove_uri
        str = self
        str = str.gsub(/^\.?(\s*@\w+)+/, '') # 文頭のIDを削除
        str = str.gsub(/(RT|QT)\s*@?\w+.*$/, '') # RT/QT以降を削除
        str = str.gsub(/http:\/\/\S+/, '') # URIを削除
        str = str.gsub(/\s+/, ' ').strip
    end
    def stringify
        str = self
        str = str.gsub(/<a\s.*?>(.*?)<\/a>/, '\1') # a要素を置換
        str = str.gsub(/<br\s?\/>/, "\n") # br要素を置換
    end
end

module TwitterBot
    BEGIN_DELIMITER = '__BEGIN__'
    END_DELIMITER = '__END__'
    IGO_DIC_DIRECTORY = 'ipadic' # 辞書ファイルがあるディレクトリを指定
    class Crawler
        def initialize(bot_screen_name, src_screen_name)
            @bot_screen_name = bot_screen_name
            @src_screen_name = src_screen_name
            @replied_users = Array.new
            @markov = Markov.new
            @markov_mention = Markov.new
            @splitter = Splitter.new
        end
        def
            http_query(method, uri_str, query)
            uri = URI.parse(uri_str)
            query_string = query.map{|k,v| URI.encode(k) + "=" + URI.encode(v) }.join('&')
            Net::HTTP.start(uri.host, uri.port) {|http|
                if method == 'get'
                    query_string = '?' + query_string unless query_string.empty?
                    http.get(uri.path + query_string)
                    else
                    http.post(uri.path, query_string)
                end
            }
        end
        def get_favorited_tweets
            
            response = http_query('get', "http://favstar.fm/users/#{@src_screen_name}/recent", {})
            matches = response.body.scan(/<p class='fs-tweet-text'>(.*?)<\/p>/m)
            matches.flatten.map {|match| match.stringify }
        end
        def get_best_tweets
            response = http_query('get', "http://favstar.fm/users/#{@src_screen_name}", {})
            matches = response.body.scan(/<p class='fs-tweet-text'>(.*?)<\/p>/m)
            matches.flatten.map {|match| match.stringify }
        end

        def build_tweet()
            counter = 0
            while counter <= 10 do
                result = @markov.build.join('')
                return result if result.size <= 140 # 140文字以内なら採用
                counter += 1
            end
                raise StandardError.new('retry limit is exceeded')
            end
            def build_reply(screen_name)
                counter = 0
                while counter <= 0 do
                    result = @markov_mention.build.join('')
                    result = "@#{screen_name} #{result}"
                    return result if result.size <= 140 # 140文字以内なら採用
                    counter += 1
                end
                    raise StandardError.new('retry limit is exceeded')
                end
                def study
                    
                    Twitter.user_timeline(@src_screen_name, {
                                          "count" => 1000,
                                          }).each {|status|
                        formatted = status.text.remove_uri
                        words = @splitter.split(formatted)
                        if status.text.is_mention?
                            @markov_mention.study(words)
                            else
                            @markov.study(words)
                        end
                        puts "study: #{formatted}"
                    }
                end
                def reply_to_mentions
                    # reply済リストを取得
                    Twitter.user_timeline(@bot_screen_name).each {|status|
                        screen_name = status.in_reply_to_screen_name
                        @replied_users << screen_name if screen_name
                    }
                    # reply
                    Twitter.mentions.each {|status|
                        screen_name = status.user.screen_name
                        next if status.created_at < Time.now - 3600 * 24 # 24時間以上前なら除外
                        next if @replied_users.include?(screen_name) # reply済リストに含まれるなら除外
                        next if screen_name == @bot_screen_name # 自分自身なら除外
                        result = build_reply(screen_name)
                        Twitter.update(result, {
                                       "in_reply_to_status_id" => status.id,
                                       })
                        @replied_users << screen_name # reply済リストに入れる
                        puts "reply: #{result}"
                        
                    }
                end
                
                def tweet
                    # ランダムにモード決定
                    #  random_value = rand
                    #  if random_value < 0.9
                        # tweet using markov
                        result = build_tweet
                        Twitter.update(result)
                        puts "tweet(markov): #{result}"
                        #elsif random_value < 0.8
                        # tweet using favstar-best
                        #result = get_best_tweets.choice.remove_uri
                        #Twitter.update(result)
                        #puts "tweet(best): #{result}"
                        #else
                        # tweet using favstar-recent
                        # result = get_favorited_tweets.choice.remove_uri
                        #Twitter.update(result)
                        #puts "tweet(recent): #{result}"
                        # end
                end
                
            end
            
            
            
            class Splitter
            
            def initialize()
                @tagger = Igo::Tagger.new(IGO_DIC_DIRECTORY)
            end
            def split(str)
                array = Array.new
                array << BEGIN_DELIMITER
                array += @tagger.wakati(str)
                array << END_DELIMITER
                array
            end
        end
        
        
        class Markov
            
            def initialize()
                @table = Array.new
                
            end
            def study(words)
                return if words.size < 3
                for i in 0..(words.size - 3) do
                    @table << [words[i], words[i + 1], words[i + 2]]
                    
                end
                end
                def search1(key)
                    array = Array.new
                    @table.each {|row|
                        array << row[1] if row[0] == key
                        
                    }
                    array.shuffle!
                    array.choice
                end
                def search2(key1, key2)
                    array = Array.new
                    @table.each {|row|
                        array << row[2] if row[0] == key1 && row[1] == key2
                    }
                                        array.shuffle!
                    array.choice
                    
                end
                def build
                    array = Array.new
                    # puts array
                    key1 = BEGIN_DELIMITER
                    key2 = search1(key1)
                    while key2 != END_DELIMITER do
                        array << key2
                        key3 = search2(key1, key2)
                        key1 = key2
                        key2 = key3
                    end
                        array
                    end
                end
            end