package utils

import "testing"

func fakeSetSecret() {
	SetSecretKey("secret")
}

func TestGenerateToken_Success(t *testing.T) {
	type generateTokenSuccess struct {
		input string
		want  string
	}

	fakeSetSecret()
	tests := []generateTokenSuccess{
		{input: "sdajlkdaksldj", want: "sdajlkdaksldj.7Eb5PsMYvlt4RPQW3NsaNrAY+jVHOwMFlWR+EP8iMzU="},
		{input: "", want: ""},
	}
	for _, test := range tests {
		res := GenerateToken(test.input)
		if test.want != res {
			t.Fatalf(`TestGenerateToken_Success failure got %v want %v`, res, test.want)
		}
	}
}

func TestVerifyToken_Success(t *testing.T) {
	type generateTokenSuccess struct {
		input string
		want  string
	}

	fakeSetSecret()
	tests := []generateTokenSuccess{
		{input: "sdajlkdaksldj", want: "sdajlkdaksldj.7Eb5PsMYvlt4RPQW3NsaNrAY+jVHOwMFlWR+EP8iMzU="},
		{input: "", want: ""},
	}
	for _, test := range tests {
		res := GenerateToken(test.input)
		if test.want != res {
			t.Fatalf(`TestGenerateToken_Success failure got %v want %v`, res, test.want)
		}
	}
}
