package utils

import (
	"sync"
	"time"
)

const (
	TTL       = 2
	MAX_ITEMS = 10000 // Limit cache size
)

type ResponseCache struct {
	ExpiresAt int64
	Response  []byte
}

type Cache struct {
	sync.RWMutex
	items map[string]ResponseCache
}

var responseCache *Cache

func InitCache() {
	responseCache = &Cache{
		items: make(map[string]ResponseCache),
	}

	// Start cleanup routine
	go responseCache.cleanup()
}

func (c *Cache) cleanup() {
	ticker := time.NewTicker(10 * time.Minute)
	for range ticker.C {
		c.Lock()
		now := time.Now().Unix()
		for key, item := range c.items {
			if now > item.ExpiresAt {
				delete(c.items, key)
			}
		}
		c.Unlock()
	}
}

func SetCache(response []byte, route string) {
	responseCache.Lock()
	defer responseCache.Unlock()

	if len(responseCache.items) >= MAX_ITEMS {
		for k := range responseCache.items {
			delete(responseCache.items, k)
			break
		}
	}

	responseCache.items[route] = ResponseCache{
		ExpiresAt: time.Now().Add(time.Hour * TTL).Unix(),
		Response:  response,
	}
}

func GetCache(route string) []byte {
	responseCache.RLock()
	defer responseCache.RUnlock()

	cache, ok := responseCache.items[route]
	if !ok || time.Now().Unix() > cache.ExpiresAt {
		return nil
	}

	return cache.Response
}
