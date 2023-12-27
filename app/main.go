package main

import (
	"app/database"
	"app/handler"
	"app/server"
	"app/stores"
	"fmt"
	"os"
)

func main() {
	e := server.New()

	db := database.New()
	database.Migrate(db)

	messageStore := stores.NewMessageStore(db)
	h := handler.NewHandler(messageStore)
	h.RegisterRoutes(e)

	e.Logger.Fatal(e.Start(fmt.Sprintf(":%s", os.Getenv("PORT"))))
}
