require 'colorize'
require 'nokogiri'
require 'open-uri'
require 'open_uri_redirections'

module ShanShan; class Node

    attr_reader :uri

    def initialize(uri:, parent:nil)
      @uri = uri
      @parent = parent
    end

    def get_depth
      @parent ? (@parent.get_depth + 1) : 0
    end

    def children(depth:0)
      # cacheing
      return @children if @children
      # scraping
      begin
        puts @uri.to_s
        STDERR.puts "info: max_depth=#{depth}, current_depth=#{get_depth}, uri=#{@uri}".green
        @children = Nokogiri::HTML(open(@uri, allow_redirections: :all)).css('a').map{ |a|
          begin
            uri = URI.parse(a[:href])
            if uri.hostname.nil? && (uri.path == '' || uri.path == '/')
              next
            elsif uri.scheme == 'mailto' || uri.scheme == 'javascript'
              next
            else

              # [一般処理]
              # もしフラグメントがある場合は除去する。
              uri.fragment = nil if uri.fragment
              # [同ドメイン処理]
              if !uri.hostname
                # p @uri
                # p uri
                STDERR.puts @uri.to_s.red
                STDERR.puts uri.to_s.red
                s = URI.join(URI::Generic.build(scheme:@uri.scheme, host:@uri.host, port:@uri.port), uri.path)
                uri = URI.parse(s.to_s)
              end

              # # ホスト名がない場合は付与する。
              # uri.hostname = @uri.hostname if !uri.hostname
              # # スキーマを付与する。
              # uri.scheme = @uri.scheme if !uri.scheme
              # uri =
              # / がない場合は付ける。
              # if uri.path.strip[0] != '/'
              #   uri.path = '/' + uri.path
              # end

              # require 'pry'
              # binding.pry
              Node.new(uri:uri, parent:self)
            end
          rescue URI::InvalidURIError
            # noop
          end
        }.compact.uniq
      rescue Net::OpenTimeout => e
        # TODO logs
        p e
      rescue => e
        p e
        require 'pry'
        binding.pry
      end
      @timestamp = Time.now
      # spin
      if depth >= get_depth
        @children.each do |child|
          child.children(depth:depth)
        end
      end
      return @children
    end

    def eql?(other)
      self.uri == other.uri
    end

    def hash
      self.uri.hash
    end

end; end
