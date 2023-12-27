package stores

import (
	"app/models"

	"gorm.io/gorm"
)

type MessageStore struct {
	DB *gorm.DB
}

func NewMessageStore(db *gorm.DB) MessageStore {
	return MessageStore{DB: db}
}

func (s *MessageStore) List() ([]models.Message, error) {
	var messages []models.Message
	res := s.DB.Find(&messages)

	return messages, res.Error
}

func (s *MessageStore) Create(message *models.Message) error {
	return s.DB.Create(message).Error
}
