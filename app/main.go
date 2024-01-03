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

	db, err := database.New()

	if err != nil {
		fmt.Print("ERROR: cannot establish connection", err)
		panic(err)
	}
	database.Migrate(db)

	messageStore := stores.NewMessageStore(db)
	h := handler.NewHandler(messageStore)
	h.RegisterRoutes(e)

	e.Logger.Fatal(e.Start(fmt.Sprintf(":%s", os.Getenv("PORT"))))
}
