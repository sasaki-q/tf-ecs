package handler

import (
	"app/models"

	"github.com/labstack/echo/v4"
)

type createMessageRequest struct {
	Title string `json:"title" validate:"required"`
}

func (r *createMessageRequest) bind(c echo.Context, message *models.Message) error {
	if err := c.Bind(r); err != nil {
		return err
	}

	if err := c.Validate(r); err != nil {
		return err
	}

	message.Title = r.Title

	return nil
}
