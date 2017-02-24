package main

import (
	"gopkg.in/yaml.v2"
	"io/ioutil"
)

type configLog struct {
	File, Level string
}

type Config struct {
	Addr  string
	PProf string
	Cert  string
	Key   string
	Log   configLog
	Auth  struct {
		Username string
		Password string
	}
}

func LoadConfig(filename string) (config *Config, err error) {
	data, err := ioutil.ReadFile(filename)
	if err != nil {
		return
	}
	err = yaml.Unmarshal(data, &config)
	return
}
