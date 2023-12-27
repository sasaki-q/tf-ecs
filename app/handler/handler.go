package handler

import (
	"app/stores"

	"github.com/labstack/echo/v4"
)

type Handler struct {
	MessageStore stores.MessageStore
}

func NewHandler(messageStore stores.MessageStore) *Handler {
	return &Handler{
		MessageStore: messageStore,
	}
}

func (h *Handler) RegisterRoutes(e *echo.Echo) {
	r := e.Group("/apis")

	mr := r.Group("/message")
	mr.GET("", h.GetMessage)
	mr.POST("", h.Create)
}
