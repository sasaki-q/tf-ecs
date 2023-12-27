package models

import (
	"gorm.io/gorm"
)

type Message struct {
	gorm.Model

	Title string `gorm:"not null"`
}
