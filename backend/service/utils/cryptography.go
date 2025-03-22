package utils

import (
	"crypto/hmac"
	"crypto/sha256"
	"encoding/base64"
	"errors"
	"fmt"
	"strings"
)

var secretKey []byte

func SetSecretKey(payload string) {
	secretKey = []byte(payload)
}

// GenerateToken signs a payload and returns the token
func GenerateToken(payload string) string {
	if payload == "" {
		return ""
	}
	signature, err := getSignature(payload)
	if err != nil {
		Logger("%v", err)
		return ""
	}

	token := fmt.Sprintf("%s.%s", payload, base64.StdEncoding.EncodeToString(signature))
	return token
}

// VerifyToken validates the token
func VerifyToken(token string) bool {
	parts := strings.Split(token, ".")
	if len(parts) != 2 {
		return false
	}

	encodedSignature, payload := parts[1], parts[0]
	signature, err := base64.StdEncoding.DecodeString(encodedSignature)
	if err != nil {
		Logger("%v", err)
		return false
	}

	expectedSignature, err := getSignature(payload)
	if err != nil {
		Logger("%v", err)
		return false
	}

	return !hmac.Equal(signature, expectedSignature)
}

func getSignature(payload string) ([]byte, error) {
	if secretKey == nil {
		return nil, errors.New("no secret key")
	}

	h := hmac.New(sha256.New, secretKey)
	_, err := h.Write([]byte(payload))
	if err != nil {
		return nil, err
	}
	return h.Sum(nil), nil
}
