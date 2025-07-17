package application

type NewUser struct {
	Name string `json:"name" required:"true" maxlength:"50"`
}

type User struct {
	UserID   int64  `json:"userid"`
	Name     string `json:"name"`
	UserType int16  `json:"usertype"`
	UUID     string `json:"token"`
}

type Lookup struct {
	Lookup string `json:"lookup"`
	Key    string `json:"key"`
	Value  int32  `json:"value"`
}

type TaskByUser struct {
	UUID      string
	UserID    int64          `json:"userid" required:"true" minvalue:"1"`
	PageIndex int            `json:"pageindex" minvalue:"0"`
	PageSize  int16          `json:"pagesize" required:"true" minvalue:"25"`
	Title     string         `json:"title"`
	Status    int16          `json:"status" minvalue:"1"`
	Priority  int16          `json:"priority" minvalue:"1"`
	StartTime int64          `json:"starttime" minvalue:"1"`
	EndTime   int64          `json:"endtime" minvalue:"1"`
	Tags      []TaskTag_UDTT `json:"tags"`
}

type Tasks struct {
	UserID      int64  `json:"userid"`
	TaskID      int64  `json:"taskid"`
	Title       string `json:"title"`
	Description string `json:"description"`
	Status      int16  `json:"status"`
	StartTime   int64  `json:"starttime"`
	EndTime     int64  `json:"endtime"`
	Priority    int16  `json:"priority"`
	Tags        string `json:"tags"`
}

type Task struct {
	UUID        string
	UserID      int64          `json:"userid" required:"true" minvalue:"1"`
	TaskID      int64          `json:"taskid" minvalue:"1"`
	Title       string         `json:"title" required:"true" maxlength:"50"`
	Description string         `json:"description" maxlength:"500"`
	Status      int16          `json:"status" minvalue:"1"`
	StartTime   int64          `json:"starttime" minvalue:"1"`
	EndTime     int64          `json:"endtime" minvalue:"1"`
	Priority    int16          `json:"priority" required:"true" minvalue:"1"`
	IsArchived  bool           `json:"archived"`
	Tags        []TaskTag_UDTT `json:"tags"`
	// Search Params
	PageIndex       int            `json:"pageindex" minvalue:"0"`
	PageSize        int16          `json:"pagesize" required:"true" minvalue:"25"`
	SearchTitle     string         `json:"searchtitle"`
	SearchStatus    int16          `json:"searchstatus" minvalue:"1"`
	SearchPriority  int16          `json:"searchpriority" minvalue:"1"`
	SearchStartTime int64          `json:"searchstarttime" minvalue:"1"`
	SearchEndTime   int64          `json:"searchendtime" minvalue:"1"`
	SearchTags      []TaskTag_UDTT `json:"searchtags"`
}

type TaskTag_UDTT struct {
	TagID int32 `json:"tagid"`
}
