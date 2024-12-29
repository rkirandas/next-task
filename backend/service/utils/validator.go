package utils

import (
	"fmt"
	"reflect"
	"strconv"
	"strings"
)

type validatorResponse struct {
	requiredFail  bool
	maxLengthFail int64
	omitField     bool
}

// RequestValidator validates the request body.
// Returns validation error message and fields to omit (combined string) on sql parameter creation.
// Fields omitted are decided based on minvalue, for example userid is not required
// and default go value for int is 0, it will be omitted.
// Checks are done for types that are currently used only.
// Request body validation
// For numeric types - required:"any" minValue:"number"
// For string/slices/array type - required:"any"
// Field Omit :
// For numeric types - minValue:"number"
// For string type - maxlength: "number"
func RequestValidator(body any, fieldsOmit *[]string) string {
	var validationMsg strings.Builder
	for i := range reflect.TypeOf(body).NumField() {
		paramType := reflect.TypeOf(body).Field(i)
		paramVal := reflect.ValueOf(body).Field(i).Interface()

		validator := validate(&paramType, &paramVal)
		if validator.requiredFail {
			validationMsg.WriteString(fmt.Sprintf("Required %s.\n", paramType.Name))
			continue
		}
		if validator.maxLengthFail > 0 {
			validationMsg.WriteString(fmt.Sprintf("%s Exceeded %d characters.\n",
				paramType.Name, validator.maxLengthFail))
			continue
		}
		if validator.omitField {
			*fieldsOmit = append(*fieldsOmit, paramType.Name)
		}
	}
	return validationMsg.String()

}

func validate(paramType *reflect.StructField,
	paramVal *any,
) validatorResponse {
	var maxLength int64
	var minValue int64

	if paramType.Tag.Get(MaxLength_Tag) != "" {
		maxLength, _ = strconv.ParseInt(paramType.Tag.Get(MaxLength_Tag), 10, 32)
	}
	if paramType.Tag.Get(MinValue_Tag) != "" {
		minValue, _ = strconv.ParseInt(paramType.Tag.Get(MinValue_Tag), 10, 64)
	}
	switch paramType.Type.Kind() {
	case reflect.String:
		paramValStr := strings.TrimSpace(fmt.Sprint(*paramVal))
		if int64(len(paramValStr)) <= maxLength {
			maxLength = 0
		}

		return validatorResponse{
			requiredFail:  paramType.Tag.Get(Required_Tag) != "" && len(paramValStr) == 0,
			omitField:     len(paramValStr) == 0,
			maxLengthFail: maxLength,
		}
	case reflect.Int16,
		reflect.Int32,
		reflect.Int64:
		if paramType.Tag.Get(MinValue_Tag) != "" {
			paramValInt, _ := strconv.ParseInt(fmt.Sprint(*paramVal), 10, 64)
			if paramValInt < minValue {
				return validatorResponse{
					omitField:    true,
					requiredFail: paramType.Tag.Get(Required_Tag) != "",
				}
			}
		}
	case reflect.Slice,
		reflect.Array:
		len := reflect.ValueOf(*paramVal).Len()
		return validatorResponse{
			requiredFail: paramType.Tag.Get(Required_Tag) != "" && len == 0,
			omitField:    len == 0,
		}
	}

	return validatorResponse{}
}
