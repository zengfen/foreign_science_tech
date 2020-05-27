module DataCentersHelper
  def self.base
    {
      "title"=>"标题",
      "desp"=>"正文",
      "created_time"=>"发布时间",
      "created_at"=>"插入时间",
      "updated_at"=>"更新时间",
      "id"=>"ID",
      "oid"=>"原始ID",
      "view_count"=>"查看数",
      "comment_count"=>"评论数",
      "local_created_time" => "当地发布时间",
      "local_start_time"=>"当地开始时间",
      "local_end_time"=>"当地结束时间",
      "repost_count"=>"转发数",
      "like_count"=>"喜欢数",
      "dislike_count"=>"不喜欢数",
      "favourite_count"=>"收藏数",
      "source_url"=>"源链接",
      "lang"=>"语种",
      "images"=>"图片链接",
      "videos"=>"视频链接",
      "links"=>"外链",
      "tags"=>"标签",
      "mentions"=>"提及",
      "user_id"=>"用户ID",
      "user_name"=>"用户名",
      "auto_news_id"=>"数字ID",
      "channel"=>"频道",
      "user_about"=>"用户说明",
      "user_birthday"=>"用户生日",
      "user_category"=>"用户类型",
      "user_category_list"=>"用户类型列表",
      "user_checkins"=>"用户签到数",
      "user_company_overview"=>"用户公司介绍",
      "user_cover"=>"背景图片",
      "user_global_brand_root_id"=>"隶属机构ID",
      "user_description"=>"用户描述",
      "user_founded"=>"成立",
      "user_has_added_app"=>"是否创建了应用",
      "user_is_community_page"=>"是否社区账号",
      "user_is_published"=>"是否公布",
      "user_likes"=>"喜欢人数",
      "user_mission"=>"传播理念",
      "user_parking"=>"地点",
      "user_phone"=>"用户电话",
      "phone" => "电话",
      "email" => "邮箱",
      "created_ts" => "插入时间戳",
      "updated_ts" => "更新时间戳",
      "user_products"=>"拥有产品",
      "user_talking_about_count"=>"交流人数",
      "user_were_here_count"=>"地点数",
      "user_first_name"=>"首名称",
      "user_gender"=>"性别",
      "user_interested_in"=>"取向",
      "user_languages"=>"用户语言",
      "user_last_name"=>"尾名称",
      "user_link"=>"用户链接",
      "user_location"=>"地址信息",
      "user_locale"=>"位置信息",
      "user_relationship_status"=>"情感状态",
      "user_updated_time"=>"更新时间",
      "user_website"=>"个人网址",
      "user_education"=>"教育信息",
      "user_hometown"=>"家乡",
      "user_middle_name"=>"中名称",
      "user_significant_other"=>"家庭成员",
      "user_work"=>"工作信息",
      "user_followers"=>"粉丝人数",
      "post_id"=>"帖子ID",
      "post_oid"=>"帖子原ID",
      "reaction_count"=>"互动数",
      "reaction_type"=>"互动类型",
      "post_type"=>"发布类型",
      "place"=>"地点",
      "link_description"=>"链接内容",
      "user_type"=>"用户类型",
      "user_screen_name"=>"用户唯一标识",
      "user_country"=>"用户国家",
      "user_province"=>"用户省/州",
      "user_city"=>"用户城市",
      "user_street"=>"用户街道",
      "user_lat"=>"用户经度",
      "user_lng"=>"用户纬度",
      "user_lang"=>"用户语言",
      "user_image"=>"用户头像",
      "country"=>"国家",
      "site_categories"=>"目标类型",
      "pos_neg"=>"正负面",
      "pos_neg_score"=>"正负面评分",
      "participant_count"=>"参与计数",
      "entities"=>"实体",
      "retweet_user_id"=>"转发用户ID",
      "lat"=>"经度",
      "lng"=>"纬度",
      "is_retweeted"=>"是否转发",
      "retweeted_status_created_at"=>"转发推文发布时间",
      "retweeted_status_id"=>"转发推文ID",
      "retweeted_status_text"=>"转发推文",
      "retweeted_status_repost_count"=>"转发推文转发数",
      "retweeted_status_like_count"=>"转发推文喜欢数",
      "retweeted_status_lang"=>"转发推文语种",
      "client"=>"客户端",
      "in_reply_to_screen_name"=>"回复人唯一标识",
      "in_reply_to_status_id"=>"回复推文ID",
      "in_reply_to_user_id"=>"回复人ID",
      "retweeted_status_comment_count"=>"转发推文评论数",
      "deleted_at"=>"删除时间",
      "user_created_at"=>"用户创建时间",
      "user_profile_image_url"=>"用户头像图片",
      "user_follower_count"=>"用户粉丝数",
      "user_friend_count"=>"用户关注数",
      "user_listed_count"=>"用户列表数",
      "user_status_count"=>"用户推文数",
      "user_favourite_count"=>"用户收藏数",
      "user_verified"=>"是否验证",
      "user_time_zone"=>"用户时区",
      "user_email"=>"用户E-Mail",
      "user_updated_ts"=>"用户更新时间戳",
      "user_sites"=>"用户网站",
      "site"=>"站点名称",
      "site_cn"=> "站点中文名称",
      "sub_title" => "子标题",
      "author" => "作者",
      "author_ids" => "作者ID列表",
      "file_url" => "文件oss链接",
      "keywords" => "关键词",
      "html_content" => "HTML正文",
      "time_zone" => "时区",
      "files" => "源文件列表",
      "image_url" => "图片oss地址",
      "link_url" => "音频、视频oss地址",
      "site_url"=>"主域名",
      "sub_site_url"=>"全域名",
      "user_screen_name_lower"=>"小写用户标识",
      "location" => "位置",
      "speaker" => "活动发言人",
      "speaker_desp" => "活动发言人描述",
      "start_time" => "开始时间戳",
      "end_time" => "结束时间戳",
      "hosted_name" => "活动主办方",
      "related_program" => "活动相关项目",
      "audios" => "音频链接",
    }
  end

  def self.archon_news
    base.merge({
                 "site"=>"站点名称",
                 "site_url"=>"主域名",
                 "sub_site_url"=>"全域名",
                 "user_name" => "作者",
                 "user_country" => "国家",
    })
  end

  def self.archon_picture
    base.merge({
                 "id" => "帖子ID",
                 "oid" => "帖子原ID",
                 "created_time" => "帖子发布时间",
                 "desp" => "正文",
                 "view_count" => "视频播放量",
                 "comment_count" => "评论数",
                 "like_count" => "喜欢数",
                 "source_url" => "源地址",
                 "images" => "图片链接",
                 "videos" => "视频链接",
                 "user_id" => "用户ID",
                 "user_screen_name" => "用户screen_name",

    })
  end

  def self.archon_picture_comment
    base.merge({
                 "id" => "评论ID MD5",
                 "oid" => "原始评论ID",
                 "created_time" => "发布时间",
                 "desp" => "评论内容",
                 "comment_count" => "回复数",
                 "like_count" => "喜欢数",
                 "user_id" => "用户ID",
                 "user_screen_name" => "用户screen_name",
                 "post_id" => "原文ID MD5",
                 "post_oid" => "原始原文ID",

    })    
  end

  def self.archon_instagram_user
    base.merge({
                 "id" => "用户ID",
                 "screen_name" => "用户screen_name",
                 "full_name" => "用户名称",
                 "desp" => "个人简介",
                 "site" => "个人网站",
                 "follower_count" => "粉丝量",
                 "following_count" => "关注量",
                 "post_count" => "发帖量",
                 "is_business_account" => "是否商家",
                 "business_category" => "业务类型",
                 "business_email" => "email地址",
                 "business_phone" => "联系电话",
                 "business_street" => "街道地址",
                 "business_zip_code" => "邮政编码",
                 "business_city" => "城市",
                 "business_region" => "城市区域",
                 "business_country_code" => "国家编码",
                 "is_verified" => "是否认证",

    })      
  end

  def self.archon_video
    base.merge({
                 "site"=>"频道名称",
                 "channel_view_count"=>"频道播放次数",
                 "channel_subscriber_count"=>"频道订阅数",
                 "channel_video_count"=>"频道视频数",
                 "duration"=>"时长",
                 "user_id"=>"频道ID",
                 "view_count" => "播放量",

    })
  end

  def self.ArchonThinkTankExpert
    base.merge({
                 "name" => "姓名",
                 "title" => "头衔",
                 "desp" => "简介",
                 "location" => "所在地",
                 "area_of_expertise" => "研究领域",
                 "profile_image_url" => "头像原链接",
                 "cv_url" => "简历链接",
                 "education" => "教育背景",
                 "related_topics" => "相关话题",
                 "twitter" => "推特",
                 "linkedin" => "领英",
                 "image_url" => "头像oss链接",
                 "nationalities" => "国籍",
                 "link" => "专家链接",
                 "facebook" => "脸书",
                 "instagram" => "INS",
                 "wikidata" => "维基",
                 "person_type" => "人物类型",
                 "associated_program" => "相关项目",
                 "website" => "个人网站",
    })
  end

  def self.ArchonThinkTankReport
    base.merge({
                 "links" => "音频、视频链接",
    })
  end

  def self.ArchonThinkTankEvent
    base.merge({
                 "links" => "音频、视频链接",
                 "desp" => "活动简介",
    })
  end

  def self.archon_twitter
    base.merge({
                 "id" => "推文ID",
                 "created_time" => "推文发布时间",
                 "title" => "推文标题（正文）",
                 "comment_count" => "评论数",
                 "repost_count" => "转发数",
                 "like_count" => "点赞数",
                 "source_url" => "推文链接",
                 "lang" => "推文语言",
                 "images" => "正文中的图片链接",
                 "videos" => "正文中的视频链接",
                 "links" => "正文中的链接地址",
                 "tags" => "话题(#话题）",
                 "mentions" => "提及(@账号)",
                 "user_id" => "推主ID",
                 "lat" => "纬度",
                 "lng" => "经度",
                 "place" => "地点数组",
                 "is_retweeted" => "是否转发",
                 "retweet_user_id" => "原文作者ID",
                 "retweeted_status_created_at" => "原文发布时间",
                 "retweeted_status_id" => "原文ID",
                 "retweeted_status_text" => "原文内容",
                 "retweeted_status_comment_count" => "原文评论数",
                 "retweeted_status_repost_count" => "原文转发数",
                 "retweeted_status_like_count" => "原文喜欢数",
                 "retweeted_status_lang" => "原文语言",
                 "client" => "发布客户端",
                 "in_reply_to_screen_name" => "评论的原文作者名称",
                 "in_reply_to_status_id" => "评论的原文ID",
                 "in_reply_to_user_id" => "评论的原文作者ID",
    })    
  end

  def self.archon_facebook_post
    base.merge({
                 "id" => "Facebook post ID MD5",
                 "oid" => "原始Facebook post ID",
                 "created_time" => "post发布时间",
                 "desp" => "post内容",
                 "comment_count" => "评论数",
                 "repost_count" => "转发数/分享数",
                 "like_count" => "点赞数/喜欢数",
                 "source_url" => "源链接",
                 "images" => "正文中的图片链接",
                 "links" => "正文中的链接地址或视频文件的链接地址",
                 "reaction_count" => "互动数",
                 "post_type" => "发布的Post类型",
                 "place" => "地点的hash",
                 "link_description" => "链接描述",
                 "user_id" => "用户ID",
                 "user_name" => "用户名",
                 "repost_user_id" => "转发原文作者的ID",
                 "repost_user_name" => "转发原文作者的name",
                 "repost_id" => "转发原文ID",
                 "mentions" => "post提及用户的ID及name 或者 提及话题的ID及话题内容",
    })       
  end


  def chinese_col_name(key,table=nil)
    f = DataCentersHelper.send(table) rescue DataCentersHelper.send("base")

    return f[key].nil? ? key : f[key]

  end

  def show_fields(table=nil)
    return DataCentersHelper.send("#{table}Fields") rescue {}
  end

  def self.archon_facebook_postFields
    fields = {
      1 => {column:'id',color:'',prefix:"",is_url:false},
      2 => {column:'oid',color:'',prefix:"",is_url:false},
      4 => {column:'created_time',color:'',prefix:"",is_url:false},
      5 => {column:'desp',color:'',prefix:"",is_url:false},
      6 => {column:'comment_count',color:'',prefix:"",is_url:false},
      7 => {column:'repost_count',color:'',prefix:"",is_url:false},
      8 => {column:'like_count',color:'',prefix:"",is_url:false},
      9 => {column:'source_url',color:'',prefix:"",is_url:true},
      10 => {column:'images',color:'',prefix:"",is_url:false},
      11 => {column:'links',color:'',prefix:"",is_url:false},
      12 => {column:'reaction_count',color:'',prefix:"",is_url:false},
      13 => {column:'post_type',color:'',prefix:"",is_url:false},
      14 => {column:'place',color:'',prefix:"",is_url:false},
      15 => {column:'link_description',color:'',prefix:"",is_url:false},
      16 => {column:'user_id',color:'',prefix:"",is_url:false},
      17 => {column:'user_name',color:'',prefix:"",is_url:false},
      18 => {column:'repost_user_id',color:'',prefix:"",is_url:false},
      19 => {column:'repost_user_name',color:'',prefix:"",is_url:false},
      20 => {column:'repost_id',color:'',prefix:"",is_url:false},
      21 => {column:'mentions',color:'',prefix:"",is_url:false},
    }     
  end

  def self.archon_twitterFields
    fields = {
      1 => {column:'id',color:'',prefix:"",is_url:false},
      2 => {column:'created_time',color:'',prefix:"",is_url:false},
      3 => {column:'title',color:'',prefix:"",is_url:false},
      4 => {column:'comment_count',color:'',prefix:"",is_url:false},
      5 => {column:'repost_count',color:'',prefix:"",is_url:false},
      6 => {column:'like_count',color:'',prefix:"",is_url:false},
      7 => {column:'source_url',color:'',prefix:"",is_url:true},
      8 => {column:'lang',color:'',prefix:"",is_url:false},
      9 => {column:'images',color:'',prefix:"",is_url:false},
      10 => {column:'videos',color:'',prefix:"",is_url:false},
      11 => {column:'links',color:'',prefix:"",is_url:false},
      12 => {column:'tags',color:'',prefix:"",is_url:false},
      13 => {column:'mentions',color:'',prefix:"",is_url:false},
      14 => {column:'user_id',color:'',prefix:"",is_url:false},
      15 => {column:'lat',color:'',prefix:"",is_url:false},
      16 => {column:'lng',color:'',prefix:"",is_url:false},
      17 => {column:'place',color:'',prefix:"",is_url:false},
      18 => {column:'is_retweeted',color:'',prefix:"",is_url:false},
      19 => {column:'retweet_user_id',color:'',prefix:"",is_url:false},
      20 => {column:'retweeted_status_created_at',color:'',prefix:"",is_url:false},
      21 => {column:'retweeted_status_id',color:'',prefix:"",is_url:false},
      24 => {column:'retweeted_status_text',color:'',prefix:"",is_url:false},
      25 => {column:'retweeted_status_comment_count',color:'',prefix:"",is_url:false},
      22 => {column:'retweeted_status_repost_count',color:'',prefix:"",is_url:false},
      23 => {column:'retweeted_status_like_count',color:'',prefix:"",is_url:false},

      26 => {column:'retweeted_status_lang',color:'',prefix:"",is_url:false},
      27 => {column:'client',color:'',prefix:"",is_url:false},
      28 => {column:'in_reply_to_screen_name',color:'',prefix:"",is_url:false},
      29 => {column:'in_reply_to_status_id',color:'',prefix:"",is_url:false},
      30 => {column:'in_reply_to_user_id',color:'',prefix:"",is_url:false},
    }    
  end

  def self.archon_newsFields
    fields = {
      1 => {column:'id',color:'',prefix:"",is_url:false},
      2 => {column:'title',color:'',prefix:"",is_url:false},
      3 => {column:'sub_title',color:'',prefix:"",is_url:false},
      4 => {column:'site',color:'',prefix:"",is_url:false},
      5 => {column:'site_url',color:'',prefix:"",is_url:false},
      6 => {column:'sub_site_url',color:'',prefix:"",is_url:false},
      7 => {column:'channel',color:'',prefix:"",is_url:false},
      8 => {column:'sub_channel',color:'',prefix:"",is_url:false},
      9 => {column:'info_source',color:'',prefix:"",is_url:false},
      10 => {column:'abstract',color:'',prefix:"",is_url:false},
      11 => {column:'user_name',color:'',prefix:"",is_url:false},
      12 => {column:'tags',color:'',prefix:"",is_url:false},
      13 => {column:'source_url',color:'',prefix:"",is_url:true},
      14 => {column:'created_at',color:'',prefix:"",is_url:true},
      15 => {column:'updated_ts',color:'',prefix:"",is_url:true},
      16 => {column:'local_created_time',color:'',prefix:"",is_url:false},
      17 => {column:'created_time',color:'',prefix:"",is_url:false},
      18 => {column:'time_zone',color:'',prefix:"",is_url:false},
      19 => {column:'user_country',color:'',prefix:"",is_url:false},
      20 => {column:'lang',color:'',prefix:"",is_url:false},
      21 => {column:'images',color:'',prefix:"",is_url:false},
      24 => {column:'audios',color:'',prefix:"",is_url:false},
      25 => {column:'videos',color:'',prefix:"",is_url:false},
      22 => {column:'desp',color:'',prefix:"",is_url:false},
      23 => {column:'html_content',color:'',prefix:"",is_url:false},
    }
  end

  def self.ArchonThinkTankReportFields
    fields = {
      1 => {column:'id',color:'',prefix:"",is_url:false},
      12 => {column:'title',color:'text-danger',prefix:"",is_url:false},
      13 => {column:'sub_title',color:'text-danger',prefix:"",is_url:false},
      2 => {column:'site',color:'',prefix:"",is_url:false},
      3 => {column:'site_cn',color:'',prefix:"",is_url:false},
      32 => {column:'abstract',color:'text-danger',prefix:"",is_url:false},
      18 => {column:'author',color:'text-danger',prefix:"",is_url:false},
      20 => {column:'author_ids',color:'',prefix:"",is_url:false},
      19 => {column:'author_urls',color:'',prefix:"",is_url:false},
      21 => {column:'author_hash',color:'',prefix:"",is_url:false},
      6 => {column:'source_url',color:'',prefix:"*",is_url:true},
      22 => {column:'files',color:'text-danger',prefix:"",is_url:true},
      23 => {column:'file_url',color:'text-danger',prefix:"",is_url:true},
      24 => {column:'images',color:'',prefix:"",is_url:true},
      26 => {column:'links',color:'',prefix:"",is_url:true},
      37 => {column:'audios',color:'',prefix:"",is_url:true},
      38 => {column:'videos',color:'',prefix:"",is_url:true},
      4 => {column:'site_url',color:'',prefix:"",is_url:false},
      5 => {column:'sub_site_url',color:'',prefix:"",is_url:false},
      16 => {column:'keywords',color:'',prefix:"",is_url:false},
      29 => {column:'lang',color:'',prefix:"",is_url:false},
      28 => {column:'country',color:'',prefix:"*",is_url:false},
      7 => {column:'created_at',color:'',prefix:"",is_url:false},
      8 => {column:'updated_at',color:'',prefix:"",is_url:false},
      9 => {column:'created_time',color:'',prefix:"*",is_url:false},
      10 => {column:'local_created_time',color:'',prefix:"*",is_url:false},
      11 => {column:'time_zone',color:'text-danger',prefix:"*",is_url:false},
      25 => {column:'image_url',color:'',prefix:"",is_url:true},
      27 => {column:'link_url',color:'',prefix:"",is_url:true},
      17 => {column:'category',color:'text-danger',prefix:"",is_url:false},
      15 => {column:'topics',color:'text-danger',prefix:"",is_url:false},
      14 => {column:'tags',color:'text-danger',prefix:"",is_url:false},
      35 => {column:'views',color:'',prefix:"",is_url:false},
      36 => {column:'comments',color:'',prefix:"",is_url:false},
      30 => {column:'reference',color:'',prefix:"",is_url:false},
      31 => {column:'mention_country',color:'',prefix:"",is_url:false},
      33 => {column:'desp',color:'text-danger',prefix:"",is_url:false},
      34 => {column:'html_content',color:'text-danger',prefix:"",is_url:false},

    }
  end


  def self.ArchonThinkTankCommentFields
    fields = {
      1 => {column:'id',color:'',prefix:"",is_url:false},
      11 => {column:'title',color:'text-danger',prefix:"*",is_url:false},
      12 => {column:'sub_title',color:'text-danger',prefix:"",is_url:false},
      2 => {column:'site',color:'',prefix:"",is_url:false},
      3 => {column:'site_cn',color:'',prefix:"",is_url:false},
      24 => {column:'abstract',color:'',prefix:"",is_url:false},
      14 => {column:'author',color:'text-danger',prefix:"",is_url:false},
      30 => {column:'author_hash',color:'text-danger',prefix:"",is_url:false},
      6 => {column:'source_url',color:'',prefix:"*",is_url:true},
      29 => {column:'topics',color:'',prefix:"",is_url:false},
      13 => {column:'tags',color:'',prefix:"",is_url:false},
      21 => {column:'country',color:'',prefix:"*",is_url:false},
      22 => {column:'lang',color:'',prefix:"",is_url:false},
      4 => {column:'site_url',color:'',prefix:"",is_url:false},
      5 => {column:'sub_site_url',color:'',prefix:"",is_url:false},
      7 => {column:'created_at',color:'',prefix:"",is_url:false},
      8 => {column:'created_time',color:'',prefix:"*",is_url:false},
      9 => {column:'local_created_time',color:'',prefix:"*",is_url:false},
      10 => {column:'time_zone',color:'text-danger',prefix:"*",is_url:false},
      17 => {column:'images',color:'',prefix:"",is_url:true},
      19 => {column:'links',color:'',prefix:"",is_url:true},
      32 => {column:'audios',color:'',prefix:"",is_url:true},
      33 => {column:'videos',color:'',prefix:"",is_url:true},
      18 => {column:'image_url',color:'',prefix:"",is_url:true},
      20 => {column:'link_url',color:'',prefix:"",is_url:true},
      15 => {column:'files',color:'',prefix:"",is_url:true},
      16 => {column:'file_url',color:'',prefix:"",is_url:true},
      26 => {column:'views',color:'',prefix:"",is_url:false},
      27 => {column:'comments',color:'',prefix:"",is_url:false},
      23 => {column:'reference',color:'',prefix:"",is_url:false},
      25 => {column:'desp',color:'text-danger',prefix:"*",is_url:false},
      28 => {column:'html_content',color:'text-danger',prefix:"*",is_url:false},
    }
  end

  def self.ArchonThinkTankEventFields
    fields = {
      1 => {column:'id',color:'',prefix:"",is_url:false},
      2 => {column:'site',color:'',prefix:"",is_url:false},
      3 => {column:'site_cn',color:'',prefix:"",is_url:false},
      4 => {column:'site_url',color:'',prefix:"",is_url:false},
      5 => {column:'sub_site_url',color:'',prefix:"",is_url:false},
      25 => {column:'country',color:'',prefix:"*",is_url:false},
      13 => {column:'title',color:'text-danger',prefix:"*",is_url:false},
      8 => {column:'start_time',color:'text-danger',prefix:"*",is_url:false},
      9 => {column:'end_time',color:'text-danger',prefix:"*",is_url:false},
      10 => {column:'local_start_time',color:'text-danger',prefix:"*",is_url:false},
      11 => {column:'local_end_time',color:'text-danger',prefix:"*",is_url:false},
      12 => {column:'time_zone',color:'',prefix:"*",is_url:false},
      15 => {column:'location',color:'',prefix:"",is_url:false},
      27 => {column:'desp',color:'text-danger',prefix:"",is_url:false},
      32 => {column:'speaker_hash',color:'',prefix:"",is_url:false},
      18 => {column:'speaker',color:'',prefix:"",is_url:false},
      19 => {column:'speaker_desp',color:'',prefix:"",is_url:false},
      17 => {column:'hosted_name',color:'',prefix:"",is_url:false},
      6 => {column:'source_url',color:'',prefix:"",is_url:true},
      21 => {column:'images',color:'',prefix:"",is_url:true},
      23 => {column:'links',color:'',prefix:"",is_url:true},
      33 => {column:'audios',color:'',prefix:"",is_url:true},
      34 => {column:'videos',color:'',prefix:"",is_url:true},
      22 => {column:'image_url',color:'',prefix:"",is_url:true},
      24 => {column:'link_url',color:'',prefix:"",is_url:true},
      28 => {column:'attachments',color:'',prefix:"",is_url:false},
      20 => {column:'related_program',color:'',prefix:"",is_url:false},
      7 => {column:'created_at',color:'',prefix:"",is_url:false},
      30 => {column:'views',color:'',prefix:"",is_url:false},
      31 => {column:'comments',color:'',prefix:"",is_url:false},
      16 => {column:'sub_type',color:'',prefix:"",is_url:false},
      35 => {column:'topics',color:'',prefix:"",is_url:false},
      14 => {column:'tags',color:'',prefix:"",is_url:false},
      29 => {column:'cooperate_organizers',color:'',prefix:"",is_url:false},
      26 => {column:'lang',color:'',prefix:"",is_url:false},
    }
  end


  def self.ArchonThinkTankExpertFields
    fields = {
      1 => {column:'id',color:'',prefix:"",is_url:false},
      2 => {column:'site',color:'',prefix:"",is_url:false},
      3 => {column:'site_cn',color:'',prefix:"",is_url:false},
      4 => {column:'site_url',color:'',prefix:"",is_url:false},
      5 => {column:'sub_site_url',color:'',prefix:"",is_url:false},
      6 => {column:'created_ts',color:'',prefix:"",is_url:false},
      7 => {column:'updated_ts',color:'',prefix:"",is_url:false},
      8 => {column:'name',color:'text-danger',prefix:"",is_url:false},
      9 => {column:'title',color:'text-danger',prefix:"",is_url:false},
      10 => {column:'desp',color:'text-danger',prefix:"",is_url:false},
      11 => {column:'area_of_expertise',color:'',prefix:"",is_url:false},
      12 => {column:'profile_image_url',color:'',prefix:"",is_url:true},
      13 => {column:'profile_image_oss_url',color:'',prefix:"",is_url:true},
      14 => {column:'cv_url',color:'text-danger',prefix:"",is_url:true},
      15 => {column:'cv_oss_url',color:'text-danger',prefix:"",is_url:true},
      16 => {column:'phone',color:'text-danger',prefix:"",is_url:false},
      17 => {column:'email',color:'text-danger',prefix:"",is_url:false},
      18 => {column:'link',color:'',prefix:"",is_url:true},
      19 => {column:'education',color:'',prefix:"",is_url:false},
      20 => {column:'related_topics',color:'',prefix:"",is_url:false},
      21 => {column:'twitter',color:'',prefix:"",is_url:false},
      22 => {column:'linkedin',color:'',prefix:"",is_url:false},
      23 => {column:'facebook',color:'',prefix:"",is_url:false},
      24 => {column:'instagram',color:'',prefix:"",is_url:false},
      25 => {column:'wikidata',color:'',prefix:"",is_url:false},
      26 => {column:'lang',color:'',prefix:"",is_url:false},
      27 => {column:'country',color:'',prefix:"",is_url:false},
      28 => {column:'location',color:'',prefix:"",is_url:false},
      29 => {column:'person_type',color:'',prefix:"",is_url:false},
      30 => {column:'associated_program',color:'',prefix:"",is_url:false},
      31 => {column:'website',color:'',prefix:"",is_url:false},
      32 => {column:'nationalities',color:'',prefix:"",is_url:false},
    }
  end

  def self.archon_pictureFields
    fields = {
      1 => {column:'id',color:'',prefix:"",is_url:false},
      2 => {column:'oid',color:'',prefix:"",is_url:false},
      3 => {column:'created_time',color:'',prefix:"",is_url:false},
      4 => {column:'desp',color:'',prefix:"",is_url:false},
      5 => {column:'view_count',color:'',prefix:"",is_url:false},
      6 => {column:'comment_count',color:'',prefix:"",is_url:false},
      7 => {column:'like_count',color:'',prefix:"",is_url:false},
      8 => {column:'source_url',color:'',prefix:"",is_url:true},
      9 => {column:'images',color:'',prefix:"",is_url:false},
      10 => {column:'videos',color:'',prefix:"",is_url:false},
      11 => {column:'user_id',color:'',prefix:"",is_url:false},
      12 => {column:'user_screen_name',color:'',prefix:"",is_url:false},
    }
  end

  def self.archon_picture_commentFields
    fields = {
      1 => {column:'id',color:'',prefix:"",is_url:false},
      2 => {column:'oid',color:'',prefix:"",is_url:false},
      3 => {column:'created_time',color:'',prefix:"",is_url:false},
      4 => {column:'desp',color:'',prefix:"",is_url:false},
      5 => {column:'comment_count',color:'',prefix:"",is_url:false},
      6 => {column:'like_count',color:'',prefix:"",is_url:false},
      7 => {column:'user_id',color:'',prefix:"",is_url:false},
      8 => {column:'user_screen_name',color:'',prefix:"",is_url:false},
      9 => {column:'post_id',color:'',prefix:"",is_url:false},
      10 => {column:'post_oid',color:'',prefix:"",is_url:false},
    }    
  end

  def self.archon_place
    base.merge({
                 "name" => "名称",
                 "address_componets" => "地址组件",
                 "formatted_address" => "地址",
                 "formatted_phone_number" => "电话",
                 "geometry" => "地理位置",
                 "icon" => "图标",
                 "international_phone_number" => "国际电话",
                 "scope" => "范围",
                 "alt_ids" => "替代编号",
                 "rating" => "评分",
                 "reference" => "参考",
                 "reviews" => "评论",
                 "types" => "类型",
                 "url" => "url",
                 "vicinity" => "邻近",
                 "website" => "网址",
                 "opening_hours" => "营业时间",
                 "permanently_closed" => "是否永久关闭",
                 "photos" => "图片",
                 "price_level" => "价格水平",
                 "utc_offset" => "utc偏移",
                 "country" => "国家",
               })
  end

  def self.archon_placeFields
    fields = {
      1=>{:column=>"id", :color=>"", :prefix=>"", :is_url=>false},
      2=>{:column=>"address_componets", :color=>"", :prefix=>"", :is_url=>false},
      3=>{:column=>"formatted_address", :color=>"", :prefix=>"", :is_url=>false},
      4=>{:column=>"formatted_phone_number", :color=>"", :prefix=>"", :is_url=>false},
      5=>{:column=>"geometry", :color=>"", :prefix=>"", :is_url=>false},
      6=>{:column=>"icon", :color=>"", :prefix=>"", :is_url=>true},
      7=>{:column=>"international_phone_number", :color=>"", :prefix=>"", :is_url=>false},
      8=>{:column=>"name", :color=>"", :prefix=>"", :is_url=>false},
      9=>{:column=>"scope", :color=>"", :prefix=>"", :is_url=>false},
      10=>{:column=>"alt_ids", :color=>"", :prefix=>"", :is_url=>false},
      11=>{:column=>"rating", :color=>"", :prefix=>"", :is_url=>false},
      12=>{:column=>"reference", :color=>"", :prefix=>"", :is_url=>false},
      13=>{:column=>"reviews", :color=>"", :prefix=>"", :is_url=>false},
      14=>{:column=>"types", :color=>"", :prefix=>"", :is_url=>false},
      15=>{:column=>"url", :color=>"", :prefix=>"", :is_url=>false},
      16=>{:column=>"vicinity", :color=>"", :prefix=>"", :is_url=>false},
      17=>{:column=>"website", :color=>"", :prefix=>"", :is_url=>true},
      18=>{:column=>"opening_hours", :color=>"", :prefix=>"", :is_url=>false},
      19=>{:column=>"permanently_closed", :color=>"", :prefix=>"", :is_url=>false},
      20=>{:column=>"photos", :color=>"", :prefix=>"", :is_url=>false},
      21=>{:column=>"price_level", :color=>"", :prefix=>"", :is_url=>false},
      22=>{:column=>"utc_offset", :color=>"", :prefix=>"", :is_url=>false},
      23=>{:column=>"country", :color=>"", :prefix=>"", :is_url=>false},
    }
  end


  def self.ArchonThinkTankExpertFields
    fields = {
      1 => {column:'id',color:'',prefix:"",is_url:false},
      2 => {column:'site',color:'',prefix:"",is_url:false},
      3 => {column:'site_cn',color:'',prefix:"",is_url:false},
      4 => {column:'site_url',color:'',prefix:"",is_url:false},
      5 => {column:'sub_site_url',color:'',prefix:"",is_url:false},
      6 => {column:'created_ts',color:'',prefix:"",is_url:false},
      7 => {column:'updated_ts',color:'',prefix:"",is_url:false},
      8 => {column:'name',color:'text-danger',prefix:"",is_url:false},
      9 => {column:'title',color:'text-danger',prefix:"",is_url:false},
      10 => {column:'desp',color:'text-danger',prefix:"",is_url:false},
      11 => {column:'area_of_expertise',color:'',prefix:"",is_url:false},
      12 => {column:'profile_image_url',color:'',prefix:"",is_url:true},
      13 => {column:'profile_image_oss_url',color:'',prefix:"",is_url:true},
      14 => {column:'cv_url',color:'text-danger',prefix:"",is_url:true},
      15 => {column:'cv_oss_url',color:'text-danger',prefix:"",is_url:true},
      16 => {column:'phone',color:'text-danger',prefix:"",is_url:false},
      17 => {column:'email',color:'text-danger',prefix:"",is_url:false},
      18 => {column:'link',color:'',prefix:"",is_url:true},
      19 => {column:'education',color:'',prefix:"",is_url:false},
      20 => {column:'related_topics',color:'',prefix:"",is_url:false},
      21 => {column:'twitter',color:'',prefix:"",is_url:false},
      22 => {column:'linkedin',color:'',prefix:"",is_url:false},
      23 => {column:'facebook',color:'',prefix:"",is_url:false},
      24 => {column:'instagram',color:'',prefix:"",is_url:false},
      25 => {column:'wikidata',color:'',prefix:"",is_url:false},
      26 => {column:'lang',color:'',prefix:"",is_url:false},
      27 => {column:'country',color:'',prefix:"",is_url:false},
      28 => {column:'location',color:'',prefix:"",is_url:false},
      29 => {column:'person_type',color:'',prefix:"",is_url:false},
      30 => {column:'associated_program',color:'',prefix:"",is_url:false},
      31 => {column:'website',color:'',prefix:"",is_url:false},
      32 => {column:'nationalities',color:'',prefix:"",is_url:false},
    }
  end


  def self.airport_informationFields
    {
       "number" => "编号",
       "name" => "机场正式名称",
       "aliases" => "俗名",
       "iata_code" => "IATA码",
       "icao_code" => "ICAO码",
       "area" => "所在区域",
       "runway_length" => "跑道长度／数量",
       "administ_district" => "行政区",
       "level" => "等级",
       "registered_address" => "登记地址",
       "desp" => "简介",
     }
  end

  def self.high_speed_rail_stationFields
    {
      "number" => "编号",
      "name" => "站名",
      "en_name" => "英文名称",
      "mileage" => "里程（km）",
      "interchange_route" => "转乘路线",
      "city" => "所在市",
      "area" => "所在区",
      "desp" => "简介",
      "structure" => "构造",
      "operating_issue" => "运营状况",
      "geo_coordinate" => "地理坐标",
      "station_type" => "站体类型",
      "operating_agency" => "运营机构",
      "via_route" => "途经线路",
      "platform" => "站台",
      "station_code" => "车站代码",
      "activation_date" => "启用日期",
      "number_of_passengers" => "乘客数量",
      "rank" => "排行",
      "first_bus" => "首班车",
      "last_bus" => "末班车",
      "platform_configuration" => "月台配置",
    }
  end

  def self.bridge_infomationFields
    {
      "number" => "编号",
      "name" => "名称",
      "bearer_line" => "承载线路",
      "area" => "地区",
      "complete_time" => "落成时间",
      "length" => "全长（米）",
      "bridge_type" => "类型",
      "remark" => "备注",
      "desp" => "简介",
    }
  end

  def self.hospital_infomationFields
    {
      "number" => "编号",
      "name" => "医院名称",
      "found_time" => "创立时间",
      "address" => "医院地址",
      "desp" => "简介",
      "agency_code" => "机构代码",
      "bed_number" => "病床数",
      "purpose" => "宗旨与愿景",
      "organization" => "组织架构",
      "current_dean" => "现任院长",
    }
  end

  def self.school_infomationFields
    {
      "number" => "编号",
      "name" => "学校名称（创校校名）",
      "en_name" => "英文简称",
      "found_time" => "创校年份",
      "address" => "学校地址",
      "acreage" => "校地（公顷）",
      "current_principal" => "现任校长",
      "desp" => "简介",
    }
  end

  def self.archon_linkedin_user
    base.merge({
                 "id" => "ID",
                 "name" => "用户名",
                 "profile_image" => "头像链接",
                 "connections" => "好友数",
                 "sub_desp" => "头衔",
                 "location" => "位置",
                 "desp" => "个人简介",
                 "experience" => "履历信息",
                 "education" => "教育经历",
                 "skills" => "技能",
                 "keyword" => "关键词",
                 "contact" => "个人资料",
                 "nationalities" => "国籍",
                 "is_invalid" => "是否无效",
                 "is_skill_user" => "是否技能使用者",
                 "country" => "国家",
                 "language" => "语言",
                 "project" => "项目",
                 "volunteer_cause" => "volunteer_cause",
                 "certification" => "证书",
                 "honor" => "荣誉",
                 "volunteer_experience" => "志愿者经历",
                 "publication" => "出版物  ",
                 "viewed_people" => "访问人",
                 "follower_count" => "粉丝数",
               })
  end

  def self.archon_linkedin_userFields
    {1=>{:column=>"id", :color=>"", :prefix=>"", :is_url=>false}, 2=>{:column=>"name", :color=>"", :prefix=>"", :is_url=>false}, 3=>{:column=>"profile_image", :color=>"", :prefix=>"", :is_url=>false}, 4=>{:column=>"connections", :color=>"", :prefix=>"", :is_url=>false}, 5=>{:column=>"sub_desp", :color=>"", :prefix=>"", :is_url=>false}, 6=>{:column=>"location", :color=>"", :prefix=>"", :is_url=>false}, 7=>{:column=>"desp", :color=>"", :prefix=>"", :is_url=>false}, 8=>{:column=>"experience", :color=>"", :prefix=>"", :is_url=>false}, 9=>{:column=>"education", :color=>"", :prefix=>"", :is_url=>false}, 10=>{:column=>"skills", :color=>"", :prefix=>"", :is_url=>false}, 11=>{:column=>"keyword", :color=>"", :prefix=>"", :is_url=>false}, 12=>{:column=>"contact", :color=>"", :prefix=>"", :is_url=>false}, 13=>{:column=>"nationalities", :color=>"", :prefix=>"", :is_url=>false}, 14=>{:column=>"is_invalid", :color=>"", :prefix=>"", :is_url=>false}, 15=>{:column=>"is_skill_user", :color=>"", :prefix=>"", :is_url=>false}, 16=>{:column=>"country", :color=>"", :prefix=>"", :is_url=>false}, 17=>{:column=>"language", :color=>"", :prefix=>"", :is_url=>false}, 18=>{:column=>"project", :color=>"", :prefix=>"", :is_url=>false}, 19=>{:column=>"volunteer_cause", :color=>"", :prefix=>"", :is_url=>false}, 20=>{:column=>"certification", :color=>"", :prefix=>"", :is_url=>false}, 21=>{:column=>"honor", :color=>"", :prefix=>"", :is_url=>false}, 22=>{:column=>"volunteer_experience", :color=>"", :prefix=>"", :is_url=>false}, 23=>{:column=>"publication", :color=>"", :prefix=>"", :is_url=>false}, 24=>{:column=>"viewed_people", :color=>"", :prefix=>"", :is_url=>false}, 25=>{:column=>"follower_count", :color=>"", :prefix=>"", :is_url=>false}}
  end





end
