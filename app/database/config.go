package database

import (
	"app/models"
	"fmt"
	"log"
	"os"

	"gorm.io/driver/postgres"
	"gorm.io/gorm"
)

func New() *gorm.DB {
	db, err := gorm.Open(
		postgres.Open(
			fmt.Sprintf(
				"postgres://%s:%s@%s:%s/%s",
				os.Getenv("DB_USER"),
				os.Getenv("DB_PASSWORD"),
				os.Getenv("DB_HOST"),
				os.Getenv("DB_PORT"),
				os.Getenv("DB_NAME"),
			),
		),
		&gorm.Config{},
	)

	if err != nil {
		log.Fatalln(err)
	}

	return db
}

func Migrate(DB *gorm.DB) {
	DB.AutoMigrate(
		&models.Message{},
	)
}
