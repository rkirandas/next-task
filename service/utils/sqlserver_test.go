package utils

import (
	"database/sql"
	"testing"
)

type fakeTx struct {
	sql.Tx
}

type faketxClient struct {
	fakeTx
}

func (fc *faketxClient) Rollback() error {
	return nil
}

func (fc *faketxClient) Commit() error {
	return nil
}

func (fc *faketxClient) Query(query string, args ...any) (*sql.Rows, error) {
	return nil, nil
}

func TestExecuteSP_Success(t *testing.T) {
	s := &Tran{&faketxClient{}}

	type sp struct {
		name       string
		result     any
		params     any
		fieldsOmit *[]string
		out        SPResult
	}

	tests := []sp{
		{name: "empty_params_empty_result", result: nil, params: nil, fieldsOmit: &[]string{}, out: SPResult{}},
		{name: "valid_params_empty_result", result: nil, params: nil, fieldsOmit: &[]string{}, out: SPResult{}},
	}

	for _, test := range tests {
		t.Helper()
		res, _ := s.ExecuteSP("123", test.result, test.params, test.fieldsOmit)
		if test.out != res {
			t.Fatalf(`TestExecuteSP_Success failure got %v want %v`, res, test.out)
		}
	}

}
