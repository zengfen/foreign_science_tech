var data = {
  #命名规范：驼峰式
  #版本：2.2
  #说明：1、该规范强制约束数据采集、文本处理、图片处理流程的数据格式；
  #      2、各应用系统可以根据需要抽取相关的数据，并写入应用内部数据库；
  #      3、系统集成方建议使用ES和HBase，但是并不强制使用；
  #      4、使用其他存储需要向课题组详细说明硬件资源需求；
  #      5、请各厂商对该规范提出修改意见，以便支撑应用系统正常运行，分为修改和建议调整两类。
  #	  6、根据各厂商反馈，修改社交数据规范
  #      7、所有时间格式如下：yyyyMMddHHmmss,精度不够补0
  #      8、所有地点包含经纬度,格式如下"location":{ "latitude": 39.93211432, "longitude": 116.38816733,"address":""},
  #      9、社交类数据只需在元数据(meta)部分填写类别信息(category:facebook|twitter|weibo|linkedIn)、
  #		 入kafka时间("savedTokafkaAt":"入kafka的时间")、提供商信息(providedBy:""),
  #		 然后在各自部分填写采集内容,即以下部分多选一facebook:{}|twiiter:{}|linkedin:{}|weibo:{}
  #      10、网页类数据则需要填写raw、meta等部分信息，尽量填全
  "uuid": "UUID",

  #原始数据，比如HTML、DOC、PDF等等
  "raw": {
    "url": "URL",
    "dataFormat": "text/html", #使用 mime 类型
    "redirectedUrl": "", #最终跳转的URL
    "dbKey": "rowKey", #为HBase预留
    "innerUrl": "", #内部转换后的URL，当使用某些非结构存储时会自动生成
    "encoding": "utf-8", #原始文件编码格式
    "size": "12345", #原始文件大小（字节）
    #数据，文本类可以保存，其他类型数据不要放在JSON里
    #使用innerUrl或者dbKey字段指向原始数据
    "data": "HTML",
    "others": "其他信息" #可以根据应用的需求进行扩展
  },

  #元数据
  "meta": {
    "category": "news",
    #数据类别，新闻类news、博客类blog、论坛类forum_post、评论类comment、社交类（facebook/twitter/weibo/linkedIn）
    "dataType": ["text"], # 数据类型，文本、图片、语音、视频等等
    "url": "URL",
    "redirectedUrl": "URL", #最终跳转的URL
    "website": "网站名",
    "title": "网页标题",
    "author": "作者",
    "encoding": "编码",
    "publishedAt": "发表时间",
    "fetchedAt": "采集时间",
    "fetchedBy": "采集软件名称_需要规范命名(软件名称_软件版本)",
    "providedBy": "数据采集者 第三方公司名|数据中心|用户",
    #入kafka队列的时间
    "savedTokafkaAt": "入kafka的时间",
    #入库时间
    "savedToHbaseAt": "写入HBase数据库的时间",
    "savedToEsAt": "写入ES数据库的时间",
    "savedToGraphDbAt": "写入图数据库的时间",
    #描述文字、摘要
    "description": "摘要文字|图片、音频、视频描述",

    "others": "" #其他公共元数据

  },

  "news": {
    #新闻类数据
    "title": "新闻标题",
    "url": "URL",
    "author": "作者",
    "reprintedFrom": {#转载
                      "webSite": "网站名称",
                      "url": "URL"
    },
    "content": "新闻内容", #图文混排，content带html标签，不是纯文本 add by gq
    "images": ["图片链接"], #保持顺序，第一个是主要图片
    "website": "网站名",
    "channel": "板块",
    "subChannel": "子板块",
    "other": "" #请各厂商根据需求提出建议
  },

  "blog": {
    #博客类数据
    "title": "博文标题",
    "url": "URL",
    "website": "网站名称",
    "author": "作者",
    "content": "", #图文混排，content带html标签，不是纯文本 add by gq
    "images": ["图片链接"],
    "user": {
      "name": "",
      "profileImage": "",
      "other": ""
    }, #博主信息
    "other": "" #扩展信息
  },

  "forum_post": {
    #论坛类数据，主帖
    "url": "",
    "content": "", #图文混排，content带html标签，不是纯文本 add by gq
    "website": "网站名",
    "author": "作者",
    "images": ["图片链接"],
    "user": {},
    "others": ""
  },

  "comment": {
    #评论类数据
    #forum : 论坛回帖
    #news：新闻评论
    #blog：博客评论
    #others：其他评论
    "type": "forum|news|blog|others",
    "target": {
      #评论的主帖、新闻、博客的URL等信息
      "url": "URL",
      "title": "TITLE",
      "other": "其他信息"
    },
    "content": [
      #评论内容，可将多个评论合并成数组
      {
        "author": "作者",
        "user": {}, #评论人的其他信息，依据网页上可见信息提供
        "content": "评论内容",
        "publishedAt": "评论时间"
      }
    ]
  },

  "facebook": {
    "basic": {
      #用户基本信息:
      "userId": "", #用户ID，facebook id
      "userName": "", #用户名
      "screenName": "", #昵称
      "headUrl": "", #string 头像地址,需要采集到本地，不能只有地址
      "website": "https:#www.facebook.com/100006627934859", #string 个人facebook页面地址
      "about": "Hello \nI'm Brogan", #string 简介信息
      "religion": "", #string  宗教
      "birthday": "", #string  生日
      "politics": "", #string  党派       (预留)
      "interested": "female|male", #string  性取向     (预留)
      "marriedStatus": "", #string  婚姻状况   (已婚、未婚、离异、未知)
      "language": [
        "English", "Chinese"
      ], #string  语言
      "registerEmail": "", #注册邮箱
      "registerPhones": "", #注册手机号
      "email": ["abc@kkk.com", "dcb@kdl.com"], #string 邮箱
      "mobile": "+85258892336", #string 手机号
      "allPhones": [#如果存在多个手机号，按如下格式填充
        {"phoneNumber":
           {
             "displayNumber": "(330) 227-8243", #string 展示号码
             "universalNumber": "+13302278243" #string 通用号码
           },
         "phoneType": "HOME" #string 电话类型
        }
      ],
      "currentCity": "Nanjing, Jiangsu, China", #string 城市名，现居住城市
      "hometown": "Nanjing, Jiangsu, China", #string 城市名，家乡
      "quotes": "aaaaaa\nbbbbbb\ncccccc", #string 座右铭
      #教育情况（起始时间、结束时间、学校名、学校链接、学校图标URL、学位、其他字段、教育情况全文）、居住地、学校、职业等
      "education": [
        {
          "startTime": "", #起始时间
          "endTime": "", #结束时间
          "name": "", #学校名
          "url": "", #学校链接     (预留)
          "degree": "", #学位
          "others": "", #其他字段
          "fullText": "" #教育情况全文
        }
      ],
      #工作情况（起始时间、结束时间、公司名称、公司链接、公司图标链接、职位、工作地点、说明、其他字段（工作情况所有描述信息）
      "work": [
        {
          "startTime": "", #起始时间
          "endTime": "", #结束时间
          "name": "", #公司名称
          "url": "", #公司链接    (预留)
          "position": "", #职位
          "location": "", #工作地点
          "other": "", #其他字段
          "fullText": "" #工作情况全文
        }
      ],
      #除了现居地和家乡，其他居住过的地方(起始时间、结束时间、生活过的地方名称、生活过的地方链接、生活过的地方图标链接、生活过的地方说明)
      "living": [
        {
          "startTime": "", #起始时间
          "endTime": "", #结束时间
          "name": "", #生活过的地方名称
          "other": "", #其他字段
          "fullText": "" #生活情况全文
        }
      ],

    },
    # 家庭成员列表
    "familyMember": [
      {
        "userId": "", # int facebook用户ID
        "userName": "", #string 姓名
        "profileImage": "", #头像
        "relationship": "" #string 家庭关系
      },
    ],
    "friends": [
      #好友列表
      {
        "userId": "", # int facebook用户ID
        "userName": "", #string 姓名
        "profileImage": "", #头像
        "friendTag": [""], #好友标签
      }
    ],
    #关注
    "followerUser": [#被追随人的ID见basic部分
      {
        "userId": "", #追随者ID（用于标定用户与追随者的关系）
        "userName": "", #追随者名称
        "userScreenName": "", #追随者昵称
        "headPhoto": "", #追随者头像内容
      }
    ],
    #粉丝
    "followedUser": [#被追随人的ID见basic部分
      {
        "userId": "", #追随者ID（用于标定用户与追随者的关系）
        "userName": "", #追随者名称
        "userScreenName": "", #追随者昵称
        "headPhoto": "", #追随者头像内容
      }
    ],

    "post": [
      {
        #发布者信息
        "userId": "", #分享者ID（用来进行关联）
        "userScreenName": "", #分享者昵称
        "userName": "", #分享者名称
        #文章信息
        "shareId": "", #分享ID（用来进行分享与用户关联）
        "shareContent": "", #分享内容
        "mediaUrl": [""], #分享的照片/视频URL
        "mentionUsers": [#文章中提及到的Facebook用户
          {
            "userId": "", # int facebook用户ID
            "userName": "", #string 姓名"
          }
        ],
        "shareTime": "", #分享时间
        "location": {#分享位置
                     "latitude": 23.1167,
                     "longitude": 113.25,
                     "address": "Guangzhou,China"
        },
        "likeCount": "", #赞次数
        "replyCount": "", #评论次数
        "forwardCount": "", #转发次数
        "shareType": "", #分享类型
        "visitUrl": "https:#www.facebook.com/100006073219321/posts/1770670999811990", #原文信息URL
        "publishTime": "20160517081236", #发布时间，格式：yyyyMMddHHmmss
        "updatedTime": "20160517081236", #更新时间，格式：yyyyMMddHHmmss
        "tags": [""] #文章的标签
      }
    ],
    #分享的回复信息
    "postReply": [
      {
        "shareId": "", #分享ID （唯一标定回复信息）
        "parentID": "", #回复父ID，用于采集回复的回复
        "replyID": "", #回复ID
        "replyContent": "", #回复内容
        "mediaUrl": "", #回复的视频或图片的URL
        "replyTime": "", #回复时间
        "userId": "", #回复者ID
        "userScreenName": "", #回复者昵称
        "headUrl": "", #回复者头像
      }
    ],
    #分享的点赞信息
    "postLikes": [
      {
        "shareId": "", #分享ID （唯一标定分享内容)
        "userId": "", #点赞者ID（用于标定点赞者与分享的关系）
        "userScreenName": "", #点赞者昵称
        "headUrl": "", #点赞者头像
        "pubTime": "" #点赞时间
      }
    ],
    #群组成员
    "groupsMember": [
      {
        "groupId": "", #群组ID（用于标定群组与群组成员的关系）
        "groupName": "", #群组名称
        "userId": "", #群组成员ID（用于标定群组与群组成员的关系）
        "userName": "", #群组成员名称
        "userScreen": "", #群组成员昵称
        "headUrl": "", #群组成员头像内容
        "createTime": "" #邀请时间
      }
    ],
    #群组内发表的分享
    "groupsPost": [
      {
        "groupId": "", #群组ID（用于标定分享内容与群组的关系）
        "groupName": "", #群组名称
        "shareId": "", #分享ID（用于标定分享内容与分享者的关系）
        "shareContent": "", #分享内容
        "mediaUrl": "", #分享的照片/视频URL
        "shareType": "", #分享类型
        "userId": "", #分享者ID（用于标定分享内容与分享者的关系）
        "userName": "", #分享者名称
        "headUrl": "", #群组成员头像内容
        "createTime": "", #分享时间
        "location": "" #分享位置
      }
    ],
    #点赞
    "like": [#被点赞人的ID见basic部分
      {
        "userId": "", #点赞者ID（用于标定用户与追随者的关系）
        "userName": "", #点赞者名称
        "userScreenName": "", #点赞者昵称
        "headPhoto": "", #点赞者头像内容
      }
    ],
    #活动
    "event": [
      {
        "eventId": "", #活动ID（用于标定活动与创建者的关系）
        "eventName": "", #活动名称
        "userId": "", #创建用户ID（用于标定活动与创建者的关系）
        "userName": "", #创建用户名称
        "userScreenName": "", #创建用户昵称
        "startTime": "", #活动开始日期和时间
        "eventBody": "", #活动内容
        "eventLocation": "" #活动地点
      }
    ],
    #活动成员
    "eventMember": [
      {
        "eventId": "", #活动ID（唯一标定活动）
        "userId": "", #活动成员ID（用于标定活动与成员的关系）
        "userName": "", #成员名称
        "userPhoto": "", #活动成员头像内容
      }
    ],
    #活动分享
    "eventPost": [
      {
        "eventId": "", #分享处的活动ID（用于标定分享与活动的关系）
        "shareId": "", #分享ID（用于标定分享与分享者的关系）
        "shareType": "", #分享类型
        "shareContent": "", #分享内容
        "mediaUrl": "", #分享的照片/视频URL
        "location": "", #分享位置
        "userId": "", #分享者ID（用于标定分享与分享者的关系）
        "userName": "", #分享者名称
        "replyCount": "", #评论次数
        "forwardCount": "", #转发次数
        "likeCount": "", #赞次数
        "createTime": "", #分享时间
      }
    ],

    #签到
    "checkIn": [
      {
        "url": "https:#m.facebook.com/SafewayCampbellCA1293/", #string 地址
        "location": {#经纬度和地址
                     "latitude": 39.93211432,
                     "longitude": 116.38816733,
                     "address": ""
        },
        "checkInTime": "", #签到时间
      }
    ],

    "others": {
      #其他非重要信息，属于预留字段；比如movies,music,videos,book,game,game_score。
      #电影
      "movies": [
        {
          "name": "", #电影名称
          "url": "", #电影链接
          "url_profile_image": "", #封面图片url
          "publish_time": "" #上映时间
        }
      ],
      #音乐
      "music": [
        {
          "name": "", #音乐名称
          "url": "", #音乐链接
          "url_profile_image": "", #封面图片url
          "type": "" #类别名称
        }
      ],
      #视频
      "videos": [
        {
          "name": "", #视频名称
          "url": "", #视频链接
          "url_profile_image": "", #封面图片url
          "length": "" #视频时长
        }
      ],
      #书籍
      "book": [
        {
          "created_time": "2011-09-29T00:38:48+0000",
          "created_t": "1317227928",
          "category": "Book",
          "id": "225289470848610",
          "head_url": "",
          "name": "TRILOG\u00cdA DEL MALAMOR: Hacia el fin del mundo"
        }
      ],
      #游戏
      "game": [
        {
          "created_time": "2016-05-24T12:05:43+0000",
          "created_t": "1464062743",
          "category": "Games/Toys",
          "id": "271730554568",
          "head_url": "",
          "name": "MEXICAN WORD OF THE DAY"
        }
      ],
      #游戏得分
      "game_score": [
        {
          "application": {
            "category": "Games", #string 类别
            "namespace": "despicablememr", #string 游戏子类
            "link": "https:#m.facebook.com/appcenter/despicablememr?fbs=-1", #string游戏链接
            "name": "Despicable Me: Minion Rush", #游戏名
            "id": "134079133419718", #id 游戏id
            "head_url": "",
          },
          "score": 14874, #int 得分
          "user": {
            "name": "Summer  Li",
            "id": "100004123117965"
          }
        }
      ]
    }
  },

  #推特
  "twitter": {
    #用户信息，包含所有公开信息
    "basic": {
      "userId": 4555613712, #int
      "userName": "John Berming", #string    名称
      "userScreenName": "BermingLei", #string    用户昵称
      "headUrl": "http:#pbs.twimg.com/profile_i... ", #string    头像
      "bkgdUrl": "https:#pbs.twimg.com/profile_...", #string    背景图片
      "website": "https:#twitter.com/KwokMiles", #string    个人twitter页面地址
      "description": "Life is good, I like https:#t.co...", #string    简介
      "location": "Hong Kong", #string                    #位置
      "createdAt": "Mon Dec 14 10:36:15 +0000 2015", #string  #加入时间
      "birthday": "", #string 出生日期
      "timelineCount": 50, #int       推文数目
      "friendCount": 28, #int       关注的人数目
      "followerCount": 3, #int       被关注的人数目
      "likeCount": 2, #int       点赞的推文数目
      "phone": "", #电话      （预留）
      "userEmail": "" #用户邮箱  （预留）
    },
    #推文
    "post": [
      {
        "tweetID": "", #推文ID （唯一标定推文）
        "userId": 4555613712, #int 发帖人ID
        "userName": "John Berming", #string    发帖人名称
        "userScreenName": "BermingLei", #string    发帖人昵称
        "content": "", #推文内容
        "mediaUrl": "", #视频或图片的URL
        "location": {#经纬度和地址
                     "latitude": 39.93211432,
                     "longitude": 116.38816733,
                     "address": ""
        }, #地理位置
        "pubTme": "", #发布时间
        "mentionID": [
          {
            "userId": 4555613712, #int 发帖人ID
            "userName": "John Berming", #string    发帖人名称
          }
        ], #MENTIONS列表
        "visitUrl": "https:#twitter.com/KwokMiles/status/925861433384071168", #原文信息URL
      }
    ],
    #推文回复
    "postReply": [
      {
        "tweetId": "", #被回复主推文ID（唯一标定推文）
        "parentId": "", #被回复ID，用于回复的回复。
        "replyId": "", #回复ID
        "replyContent": "", #回复内容
        "mediaUrl": [""], #视频或图片的URL
        "replyTime": "", #回复时间
        "userId": "", #回复者ID（用于标定推文与发布者的关系）
        "userName": "", #回复者名称
        "userScreenName": "",
        "mentionId": [
          {
            "userId": 4555613712, #int 发帖人ID
            "userName": "John Berming", #string    发帖人名称
          }
        ], #MENTIONS列表
      }
    ],
    #推文转发
    "postForward": [
      {
        "tweetId": "", #被转发推文ID （唯一标定推文）
        "forwardContent": "", #转发内容
        "mediaUrl": "", #视频或图片的URL
        "userId": "", #转发者ID（用于标定推文与发布者的关系）
        "userName": "", #转发者名称
        "userScreen": "", #转发者昵称
        "forwardTime": "", #转发时间
        "mentionId": [
          {
            "userId": 4555613712, #int 发帖人ID
            "userName": "John Berming", #string    发帖人名称
          }
        ], #MENTIONS列表
      }
    ],
    #关注人列表
    "follower": [#主userId见basic部分
      {
        "userId": "", #Follower ID，即当前操作者ID（用于标定followeing和操作者的关系）
        "userName": "", #Follower Name，即当前操作者名称
        "userScreen": "", #Follower Screen Name，即当前操作者昵称
        "userPhoto": "", #Following 头像
      }
    ],
    #被关注人列表
    "followedBy": [#主userId见basic部分
      {
        "userId": "", #Followed ID，即当前操作者ID（用于标定follower和操作者的关系）
        "userName": "", #Followed Name，即当前操作者名称
        "userScreen": "", #Followed Screen Name，即当前操作者昵称
        "userPhoto": "", #Follower头像
      }
    ],
    #其他信息
    "others": []
  },

  #领英
  "linkedIn": {
    #用户基本信息
    "user": {
      "userId": "", #用户ID（用于唯一标定用户）
      "userName": "", #用户名称
      "userJob": "", #用户职业
      "userTitle": "", #用户头衔
      "userLocation": "", #用户地址
      "userTrade": "", #用户所属行业
      "userOrgId": "", #用户所属公司ID
      "userOrgName": "", #用户公司
      "userIntroduction": "", #用户简介
      "website": "https:#www.linkedin.com/in/niyunhua/", #string 个人linkedin页面地址
    },
    #用户技能
    "userSkill": [""],
    #用户成就
    "userAchievement": [""],
    #教育经历
    "education": [
      {
        "schoolName": 'Aberystwyth University', # str 学校
        "logo": "http:#m.c.lnkd.licdn.com/media/p/6/005/011/1d9/2353a87.png", # str学校logo
        "degreeName": "BA First Class", # str学位
        "fieldOfStudy": "Film & Television", # str专业
        "startDate": "2006-09", # str入学时间
        "endDate": "2013-02", # str毕业时间
        "score": "", # str成绩
        "activities": "", # str活动社团
        "description": "10 A*-C GCSEs", # str说明
      }
    ],
    #工作经历
    "career": [
      {
        "companyName": '2016-05', # str 公司名称
        "logo ": '', # str公司logo
        "locationName": '英国 伦敦', # str公司位置
        "title": 'Senior Digital Media Coordinator', # str头衔
        "job": 'Senior Digital Media Coordinator', # str职位
        "startDate": '2006-09', # str入职时间
        "endDate": '2013-02', # str 离职时间
        "description": '? Project lead for ITV Essentia…', # str职位描述
        "achievementFile": [""] # str代表作，成就文件

      }
    ],
    #机构信息
    "organization": [
      {
        "orgId": "", #机构ID（用于唯一标定机构）
        "orgName": "", #机构名称
        "orgField": "", #机构领域
        "orgIndustry": "", #机构行业
        "orgSize": "", #机构规模
        "orgIntruduction": "", #机构简介
        "orgWebsite": "", #机构网站
        "orgLocation": "", #机构总部
        "orgType": "" #机构类型
      },

    ],
    #人员机构关系
    "member": [
      {
        "orgId": "", #机构ID（用于标定机构和用户关系）
        "orgName": "", #机构名称
        "userId": "", #用户ID（用于标定机构和用户关系）
        "userName": "", #用户名称
      }
    ],
    #动态发布
    "post": [
      {
        "shareId": "", #动态id（唯一标定动态）
        "shareContent": "", #动态内容
        "userId": "", #发布者ID（用于标定动态和发布者关系）
        "userName": "", #发布者名称
        "shareTime": "", #发布时间
        "likeNum": "", #点赞个数
        "replayNum": "", #评论个数
        "visitUrl": "https:#www.linkedin.com/feed/update/urn:li:activity:6412832624544440320/", #原文信息URL
      }
    ],
    #动态评论
    "comment": [#被评论动态(回复)的作者ID
      {
        "shareId": "", #被评论主动态(回复)的id（用于标定被回复与被回复动态关系）
        "parentId": "", #被回复ID，用于回复的回复。
        "replyId": "", #回复id（唯一标定回复）
        "replyRecontent": "", #回复内容
        "userId": "", #回复者ID（用于标定回复与回复者关系）
        "userName": "", #回复者名称
        "replyTime": "", #回复时间
        "replyLinkNum": "", #回复的点赞数量
        "replyReplyNum": "", #回复的回复数量
      }
    ],
    #关注的人
    "followerMember": [
      {
        "userId": "", #被关注者ID（用于标定被关注者与关注者关系）
        "userName": "", #被关注者名称

      }

    ],
    #关注的机构、学校
    "followOrg": [
      {
        "orgId": "", #机构ID（用于标定被关注机构与关注者关系）
        "orgName": "", #机构名称
      }
    ],

    "others": {}
  },

  #微博，参考twitter
  "weibo": {
    #用户基本信息
    "user": {
      "userId": "", #用户ID（唯一标定用户身份）
      "userName": "", #用户名称
      "address": "", #用户所在地
      "introduction": "", #用户简介
      "birthday": "", #用户生日
      "registerTime": "", #注册时间
      "domain": "", # string 用户的个性化域名
      "gender": "", #用户性别
      "headPortrait": "", #用户头像
      "bloodType": "", #血型
      "blogAddress": "", #博客地址
      "emotionalState": "", #感情状况
      "qq": "", #QQ号
      "email": "", #邮箱
      "MSN": "", #MSN
      "followersCount": "", # int 粉丝数
      "friendsCount": "", # int 关注数
      "weiboCount": "", # int 微博数
      "level": "", #用户等级
      "verified": "", # boolean 是否是微博认证用户，即加V用户，true：是，false：否
      "education": {
        "school": "", #学校名称
        "department": "", #院系名称
        "year": "" #入学年份
      },
      "work": {
        "company": "", #公司名称
        "department": "", #公司部门
      },
      "website": "https:#weibo.com/haoel", #string 个人weibo页面地址

    },
    #关注列表
    "follower": [#主userId见basic部分
      {
        "userId": "", #Follower ID，即当前操作者ID（用于标定followeing和操作者的关系）
        "userName": "", #Follower Name，即当前操作者名称
        "userScreen": "", #Follower Screen Name，即当前操作者昵称
        "userPhoto": "", #Following 头像
      }
    ],
    #粉丝列表
    "followerBy": [#主userId见basic部分
      {
        "userId": "", #Followed ID，即当前操作者ID（用于标定follower和操作者的关系）
        "userName": "", #Followed Name，即当前操作者名称
        "userScreen": "", #Followed Screen Name，即当前操作者昵称
        "userPhoto": "", #Follower头像
      }
    ],
    #微博内容
    "blogPost": [
      "mblogId": "", #微博ID（用于唯一标定微博）
      "mblogContent": "", #微博内容
      "mediaUrl": "", #微博图片、视频链接
      "likeNum": "", #获赞数量
      "forwardNum": "", #转发数量
      "commentNum": "", #评论数量
      "location": {#经纬度和地址
                   "latitude": 39.93211432,
                   "longitude": 116.38816733,
                   "address": ""
      }, #地理位置
      "userId": "", #发布者ID（用于标定微博与发布者的关系）
      "userName": "", #发布者名称
      "pubTime": "", #发布时间
      "visitUrl": "https:#weibo.com/1401880315/Glsyor9wi", #原文信息URL

    ],
    #微博评论
    "reply": [
      {
        "mblogId": "", #被评论微博（或评论）的id（用于标定评论与被评论微博的关系）
        "parentId": "", #被回复ID，用于回复的回复。
        "replyId": "", #评论ID（唯一标定评论）
        "replyContent": "", #评论内容
        "replyLink": "", #评论图片、视频链接
        "userId": "", #评论者id（用于标定评论与评论者的关系）
        "userName": "", #评论者名称
        "pubTime": "", #发布时间
        "likeNum": "", #获赞数量
      }

    ],
    #微博转发
    "forward": [
      {
        "mblogId": "", #被转发微博（或评论）的id（用于标定评论与被评论微博的关系）
        "forwardyId": "", #转发微博ID（唯一标定评论）
        "forwardyContent": "", #转发微博内容
        "mediaUrl": "", #转发微博图片、视频链接
        "userId": "", #转发者id（用于标定评论与评论者的关系）
        "userName": "", #转发者名称
        "pubTime": "", #转发时间
      }

    ],
    "others": []
  },

  #微信公众号
  "weixin_gzh": {
    "user": {}, #用户信息
    "content": "", #内容
    "url": "", #URL
    "images": [], #图片链接
    "others": {} #其他
  },

  #视频数据项
  "video": {
    "url": "",
    "title": "",
    "snap": "缩略图URL",
    "user": {
      "name": "用户ID或昵称"
    },
    "description": "",
    "others": {
      #本项目暂时不包含视频处理引擎抽取的数据
    }
  },

  #语音数据
  "audio": {
    "meta": {
      "url": "URL",
      "title": "文件名",
      "description": "文件简介"
    },
    "others": ""
  },

  #图片数据
  "image": {
    #图片文件抽取的元数据
    "meta": {
      "width": "1080",
      "author": "name", #图片作者
      "capturedBy": "Canon xxx",
      "geo": [12, 34],
      #图片处理引擎提取的信息
      "entities": [
        "person": {
          "count": 2
        },
        "a": {},
        "b": {}
      ]
    }

  },

  #以下是文本处理引擎提取的数据项
  "text": {
    "content": "正文", #可以由采集程序负责抽取, 如果是文档，文本抽取在写hbase之后进行
    "keywords": [
      {
        "name": "关键词1",
        "offset": [12, 34, 56], #可选
        "extractedBy": "xxx" #文本处理引擎名称
      },
      {
        "name": "关键词2",
        "offset": [12, 34, 56], #可选
        "extractedBy": "EngineX" #文本处理引擎名称
      }
    ],
    "emotions": [
      {
        "name": "喜悦",
        "score": 0.4,
        "extractedBy": "EngineY"
      },
      {
        "name": "正向",
        "score": 0.4,
        "extractedBy": "EngineY"
      }
    ],
    "summary": [
      {"text": "abcdefghi", "extractedBy": "EngineX"},
      {"text": "abcdefghijk", "extractedBy": "EngineY"}
    ],
    "classify": ["中国", "经济"], #
    "entities": [
      {
        "name": "实体1",
        "category": "names of persons|organizations|locations, expressions of times|quantities|monetary values| percentages|",
        "indices": [12, 34, 56],
        "_links": {
          "wikidata": "https:#www.wikidata.org/wiki/Q42",
          "wikipedia": "https:#en.wikipedia.org/wiki/China"
        },
        "extractedBy": "EngineX"
      },
      {
        "name": "实体2",
        "category": "locations",
        "indices": [12, 34, 56],
        "_links": {
          "wikidata": "https:#www.wikidata.org/wiki/Q42",
          "wikipedia": "https:#en.wikipedia.org/wiki/China"
        },
        "extractedBy": "EngineY"
      }
    ],
    "entityRelations": [
      {
        "subject|s": "实体1",
        "predicate|p": "关系1",
        "object|o": "实体2",
        "extractedBy": "EngineX"
      },
      {
        "subject": "实体1",
        "predicate": "关系1",
        "object": "实体2",
        "extractedBy": "EngineY"
      }
    ]
  },

  #预留
  "ext": {
    "key1": "value1|{}|[]",
    "key2": "value2|{}|[]"
  }
}
