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
func GenerateToken(payload string) (string, error) {
	signature, err := getSignature(payload)
	if err != nil {
		return "", err
	}

	token := fmt.Sprintf("%s.%s", payload, base64.StdEncoding.EncodeToString(signature))
	return token, nil
}

// VerifyToken validates the token
func VerifyToken(token string) (string, error) {
	parts := strings.Split(token, ".")
	if len(parts) != 2 {
		return "", errors.New("invalid token format")
	}

	encodedSignature, payload := parts[0], parts[1]
	signature, err := base64.StdEncoding.DecodeString(encodedSignature)
	if err != nil {
		return "", err
	}

	expectedSignature, err := getSignature(payload)
	if err != nil {
		return "", err
	}

	if !hmac.Equal(signature, expectedSignature) {
		return "", errors.New("invalid token signature")
	}
	return payload, nil
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
