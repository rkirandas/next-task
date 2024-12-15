package application

type Lookup struct {
	Lookup string `json:"lookup"`
	Key    string `json:"key"`
	Value  int    `json:"value"`
}

type Task struct {
	TaskId      int64  `json:"taskid"`
	Title       string `json:"title"`
	Description string `json:"description"`
	Status      int16  `json:"status"`
	StartTime   int    `json:"starttime"`
	EndTime     int    `json:"endtime"`
	Priority    int16  `json:"priority"`
}

type AddTask struct {
	UserId int64 `json:"userid"`
	Task
	Tags []int `json:"tags"`
}

type TaskDetail struct {
	Task
	Tags []int `json:"tags"`
}
