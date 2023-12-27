package handler

import (
	"app/models"
	"app/utils"
	"net/http"

	"github.com/labstack/echo/v4"
)

func (h *Handler) GetMessage(c echo.Context) error {
	messages, err := h.MessageStore.List()

	if err != nil {
		return c.JSON(http.StatusUnprocessableEntity, utils.NewError(err))
	}

	return c.JSON(http.StatusOK, map[string][]models.Message{"messages": messages})
}

func (h *Handler) Create(c echo.Context) error {
	var message models.Message
	req := &createMessageRequest{}

	if err := req.bind(c, &message); err != nil {
		return c.JSON(http.StatusBadRequest, utils.NewError(err))
	}

	err := h.MessageStore.Create(&message)
	if err != nil {
		return c.JSON(http.StatusUnprocessableEntity, utils.NewError(err))
	}

	return c.JSON(http.StatusCreated, map[string]string{"message": "success"})
}
