package utils

import (
	"fmt"
	"log"
	"os"
	"path/filepath"
	"strings"
	"sync"
	"time"
)

type FileLogger struct {
	logChan   chan string
	waitGroup sync.WaitGroup
	flushSize int
	file      *os.File
}

var (
	fileLogger *FileLogger
	once       sync.Once
)

// Creates Log File in application residing root directory and ready to write log
func SetupLogFile(projName string) {
	currDir, err := os.Executable()
	if err != nil {
		fmt.Printf("%v", err)
		return
	}
	rootDir := filepath.VolumeName(currDir) + string(filepath.Separator)
	logDir := filepath.Join(rootDir, projName)
	filePath := filepath.Join(logDir, "log.txt")
	if err := os.MkdirAll(logDir, 0750); err != nil {
		fmt.Printf("%v", err)
		return
	}
	if _, err := os.Stat(filePath); os.IsNotExist(err) {
		intro := "LOGS \n----------------------------\n"
		if err := os.WriteFile(filePath, []byte(intro), 0644); err != nil {
			fmt.Printf("%v", err)
			return
		}
	}
	initializeLogger(100, 10*1024, filePath)
}

func initializeLogger(bufferSize, flushSize int, filePath string) {
	once.Do(func() {
		fileLogger = &FileLogger{
			logChan:   make(chan string, bufferSize),
			flushSize: flushSize,
		}

		// Try to open the log file
		file, err := os.OpenFile(filePath, os.O_APPEND|os.O_CREATE|os.O_WRONLY, 0644)
		if err != nil {
			log.Printf("Failed to open log file: %v. Logs will not be written to a file.", err)
			fileLogger.file = nil
		} else {
			fileLogger.file = file
		}

		fileLogger.waitGroup.Add(1)
		go fileLogger.run()
	})
}

func (l *FileLogger) run() {
	if l.file != nil {
		defer l.file.Close()
	}
	defer l.waitGroup.Done()

	var buffer strings.Builder

	for msg := range l.logChan {
		buffer.WriteString(fmt.Sprintf("Logged At %v \n----------------------------\n%s\n----------------------------\n",
			time.Now().Format("2006-01-02 15:04:05"), msg))
		if buffer.Len() >= l.flushSize && l.file != nil {
			if _, err := l.file.WriteString(buffer.String()); err != nil {
				log.Printf("Failed to write to log file: %v\n", err)
			}
			buffer.Reset()
		}
	}

	if buffer.Len() > 0 && l.file != nil {
		if _, err := l.file.WriteString(buffer.String()); err != nil {
			log.Printf("Failed to write to log file: %v\n", err)
		}
	}
}

func (l *FileLogger) fileWriteMessage(msg string) {
	select {
	case l.logChan <- msg:
	default:
		log.Println("Log channel is full. Dropping log:", msg)
	}
}

// Log message in file
func FileLog(msg string) {
	if fileLogger == nil {
		return
	}

	fileLogger.fileWriteMessage(msg)
}

func (l *FileLogger) close() {
	if fileLogger != nil {
		close(l.logChan)
		l.waitGroup.Wait()
	}
}

// Close file logger on application exit
func CloseFileLogger() {
	if fileLogger != nil {
		fileLogger.close()
	}
}
