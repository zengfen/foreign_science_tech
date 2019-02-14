class InformationExcel
	attr_accessor :file_path,:sheet_name,:column_size,:file_dir
	attr_accessor :modelclass,:countries

	def initialize(opt={})
		@file_path = opt[:file_path]
		@sheet_name = opt[:sheet_name]
		@column_size = opt[:column_size] || default_column_size
		@countries = init_countries
	end

	def media_info_from_excel
		@modelclass = 'MediaInfo'
		msg = {}
		begin
			msg = parse_excel_transaction
		rescue Exception => e
			return {type:'error',message:e.message}
		end
		return msg
	end

	def govern_info_from_excel
		@modelclass = 'GovernmentInfo'
		msg = {}
		begin
			msg = parse_excel_transaction
		rescue Exception => e
			return {type:'error',message:e.message}
		end		
		return msg
	end

	def parse_excel_transaction
		begin
			xlsx = Roo::Spreadsheet.open(file_path) 
		rescue Exception => e
			return {type:'error',message: e.message}
		end		

		msg = {}
		i = 0 # 读取的行数
		head = [] # 表头
		n = column_size # 读取的列数
		ActiveRecord::Base.transaction do
			xlsx.sheet(sheet_name).each_row_streaming(pad_cells:true) do |row|
				i += 1
				if i == 1
					n.times do |ii|
						head << row[ii].to_s
					end
					head.delete(nil)
					column_size = head.size
					n = head.size					
					next
				end

				query = {} # 当次循环的参数
				n.times do |ii|
					query[head[ii].to_sym] = row[ii].to_s rescue ''
				end

				query_values = query.values.uniq
				query_values.delete(nil)
				next if query_values.size == 1 # 跳过空行		
				
				msg = parse_row(query)
				if msg[:type] == 'error'
					raise ActiveRecord::Rollback ,msg[:message]
				end			
			end
		end
		return msg if msg[:type] == 'error'
		return {type:'success',message:'导入成功'}		
	end

	def parse_row(query)
		return {type:'success',message:'跳过空行',query:query} if query[:site].blank?

		k = Object.const_get modelclass	
		new_data = k.where({domain:query[:domain],en_name:query[:en_name],ch_name:query[:ch_name]}).first
		return {type:'success',message:'该网站已存在',query:query} unless new_data.blank?	
		
		unless query[:country_code].blank?
			query[:country_code] = countries[query[:country_code]]
			return {type:'error',message:'国家不能为空',query:query} if query[:country_code].blank?			
		end

		new_data = k.new(query)
		unless new_data.save
			return {type:'error',message:new_data.errors.full_messages.to_sentence,query:query}
		end
		return {type:'success',message:'添加成功',query:query}
	end

	def init_countries
		data = {}
    File.open("#{Rails.root.to_s}/public/countrys/countrys.json","r").readlines.each do |line|
      doc = JSON.parse(line)
      data.merge!({doc['cname']=>doc['country_code']})
    end	
    return data	
	end

	def countries_json
		data = {}
    File.open("#{Rails.root.to_s}/public/countrys/countrys.json","r").readlines.each do |line|
      doc = JSON.parse(line)
      data.merge!({doc['country_code']=>doc['cname']})
    end	
    return data			
	end

	def default_column_size
		return 10
	end

	def update_hav_infos
		begin
			xlsx = Roo::Spreadsheet.open(file_path) 
		rescue Exception => e
			return {type:'error',message: e.message}
		end		

		msg = {}
		i = 0 # 读取的行数
		head = [] # 表头
		n = column_size # 读取的列数
		ActiveRecord::Base.transaction do
			xlsx.sheet(sheet_name).each_row_streaming(pad_cells:true) do |row|
				i += 1
				if i == 1
					n.times do |ii|
						head << row[ii].to_s
					end
					head.delete(nil)
					column_size = head.size
					n = head.size					
					next
				end

				query = {} # 当次循环的参数
				n.times do |ii|
					query[head[ii].to_sym] = row[ii].to_s rescue ''
				end

				query_values = query.values.uniq
				query_values.delete(nil)
				next if query_values.size == 1 # 跳过空行		
				next if query[:hav_infos].blank?
				data = []
				data += MediaInfo.where({domain:query[:domain]}).to_a
				data += GovernmentInfo.where({domain:query[:domain]}).to_a
				data.each do |x|
					if query[:hav_infos] == '是'
						x.update({hav_infos:1})
					else
						x.update({hav_infos:0})
					end 
				end			
			end
		end
		return {type:'success',message:'更新结束'}		
	end
end