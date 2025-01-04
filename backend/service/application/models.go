package application

type Lookup struct {
	Lookup string `json:"lookup"`
	Key    string `json:"key"`
	Value  int32  `json:"value"`
}

type TaskByUser struct {
	UserID    int64 `json:"userid" required:"true" minvalue:"1"`
	PageIndex int   `json:"pageindex"`
	PageSize  int16 `json:"pagesize" minvalue:"10"`
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
	UserID      int64          `json:"userid" minvalue:"1"`
	TaskID      int64          `json:"taskid" minvalue:"1"`
	Title       string         `json:"title" required:"true" maxlength:"50"`
	Description string         `json:"description" maxlength:"500"`
	Status      int16          `json:"status" minvalue:"1"`
	StartTime   int64          `json:"starttime" minvalue:"1"`
	EndTime     int64          `json:"endtime" minvalue:"1"`
	Priority    int16          `json:"priority" required:"true" minvalue:"1"`
	IsArchived  bool           `json:"archived"`
	Tags        []TaskTag_UDTT `json:"tags"`
}

type TaskTags struct {
	TaskID int64 `json:"taskid"`
	TagID  int32 `json:"tagid"`
}

type TaskTag_UDTT struct {
	TagID int32 `json:"tagid"`
}

type NewUserTask struct {
	Tasks []Tasks `json:"tags"`
	Token string  `json:"string"`
}
