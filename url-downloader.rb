cmd = %x(gem list rest-client)
unless cmd.include?('rest-client')
	puts "第一次运行, 安装组件中..."
	%x(gem install rest-client)
	puts '安装完毕, 按任意键退出后重新运行'
	gets
end

require 'rest-client'
require 'logger'


class NotImageException < Exception
end

def download_img_by_url(url)
	response = RestClient.get(url)
	if response.headers[:content_type].include?('image')
		File.open("image/a.jpg", "wb") { |file|  file.write(response.body)}
	else
		raise NotImageException
	end
end

module Kernel
	alias :std_puts :puts
	def puts(str) 
		$logger.info(str)
		std_puts(str)
	end
end

def init
	$logger = Logger.new('log.txt')
end

def main
	init()
	FileUtils.mkdir 'image' unless Dir.exist?('image')
	begin
		puts "开始处理url文件..."
		count = 0
		image_count = 0
		File.open("./url.txt", "r") do |file|  
			file.each do |url|
				url.chomp!.strip!
				next if url.empty?
				count += 1
				begin
					puts "正在处理第#{count}行: #{url}"
					download_img_by_url(url)
					image_count += 1
				rescue NotImageException => ie
					puts "  行#{count}: 不是图片， 跳过"
				rescue Exception => e
					puts "  行#{count}: 失败: #{e.message}"
				end
			end
		end
		puts "运行完毕, 共处理#{count}个url, 下载图片#{image_count}个. 按任意键退出"
		gets
	rescue Exception => e
		puts "读取url.txt错误:#{e.message}"
	ensure
		$logger.close
	end
end

main()


