package server

import (
	"net/http"

	"github.com/go-playground/validator"
	"github.com/labstack/echo/v4"
)

type MyValidator struct {
	validator *validator.Validate
}

func NewValidator() *MyValidator {
	return &MyValidator{validator: validator.New()}
}

func (cv *MyValidator) Validate(i interface{}) error {
	err := cv.validator.Struct(i)
	if err != nil {
		return echo.NewHTTPError(http.StatusBadRequest, err.Error())
	}
	return nil
}
