package utils

import (
	"fmt"
	"log"
)

// Logger logs the message basically to the terminal,
// but can be extended to write to different places like file, external services
func Logger(msg string, args ...any) {
	msg = fmt.Sprintf(msg, args...)
	log.Println(msg)
}

func WriteLog_File() {

}
