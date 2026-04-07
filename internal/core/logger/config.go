package core_logger

import (
	"fmt"

	"github.com/kelseyhightower/envconfig"
)

type Congig struct {
	Level  string `envconfig:"LEVEL" requred:"true"`
	Folder string `envconfig:"FOLDER" requred:"true"`
}

func NewConfig() (Congig, error) {
	var config Congig

	if err := envconfig.Process("LOGGER", &config); err != nil {
		return Congig{}, fmt.Errorf("process envconfig: %w", err)
	}
	return config, nil
}

func NewConfigMust() Congig {
	congig, err := NewConfig()
	if err != nil {
		err = fmt.Errorf("get Logger congig: %w", err)
		panic(err)
	}
	return congig
}
