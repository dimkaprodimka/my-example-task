package main

import (
    "github.com/labstack/echo/v4"
    "github.com/labstack/echo/v4/middleware"
	"webapp/pkg/config"
)

func main() {
	port := config.GetEnv("PORT", "3000")

    e := echo.New()
    e.Static("/", "public")
    
    e.GET("/", func(c echo.Context) error {
        return c.File("public/views/webapp.html")
    })
    e.Use(middleware.Logger())
    
    e.Start(":" + port)
}
