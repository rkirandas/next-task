package utils

import "time"

const TTL = 2

type ResponseCache struct {
	ExpiresAt int64
	Response  []byte
}

var responseCache map[string]ResponseCache

func InitCache() {
	responseCache = make(map[string]ResponseCache)
}

func SetCache(response []byte, route string) {
	responseCache[route] = ResponseCache{
		ExpiresAt: time.Now().Add(time.Hour * TTL).Unix(),
		Response:  response,
	}
}

func Cache(route string) []byte {
	cache, ok := responseCache[route]
	if !ok || time.Now().Unix() > cache.ExpiresAt {
		return nil
	}

	return cache.Response
}
