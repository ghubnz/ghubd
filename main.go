package main

import (
	"flag"
	"net/http"
	"os"

	"github.com/mikespook/golib/log"
	"github.com/mikespook/golib/signal"
	"github.com/mikespook/possum"
)

var (
	configFile   string
	mux          = possum.NewServerMux()
	errNoAuth    = possum.NewError(http.StatusUnauthorized, "No authorisation header supplied")
	errWrongAuth = possum.NewError(http.StatusUnauthorized, "Wrong authorisation")
)

func init() {
	flag.StringVar(&configFile, "config", "config.yaml", "Path to the configuration file")
	flag.Parse()
}

func main() {
	if configFile == "" {
		flag.Usage()
		return
	}
	config, err := LoadConfig(configFile)
	if err != nil {
		log.Error(err)
		flag.Usage()
		return
	}
	if err := log.Init(config.Log.File, log.StrToLevel(config.Log.Level), log.DefaultCallDepth); err != nil {
		log.Error(err)
	}

	mux.ErrorHandle = func(err error) {
		log.Error(err)
	}
	mux.PreRequest = func(ctx *possum.Context) error {
		username, password, ok := ctx.Request.BasicAuth()
		if !ok {
			return errNoAuth
		}
		if config.Auth.Username != username || config.Auth.Password != password {
			return errWrongAuth
		}
		return nil
	}
	mux.PostResponse = func(ctx *possum.Context) error {
		log.Debugf("[%d] %s:%s \"%s\"", ctx.Response.Status,
			ctx.Request.RemoteAddr, ctx.Request.Method,
			ctx.Request.URL.String())
		return nil
	}
	if config.PProf != "" {
		log.Messagef("PProf: http://%s%s", config.Addr, config.PProf)
		mux.InitPProf(config.PProf)
	}
	log.Messagef("Addr: %s", config.Addr)
	go func() {
		if err := http.ListenAndServeTLS(config.Addr, config.Cert, config.Key, mux); err != nil {
			log.Error(err)
			if err := signal.Send(os.Getpid(), os.Interrupt); err != nil {
				panic(err)
			}
		}
	}()
	signal.Bind(os.Interrupt, func() uint {
		log.Message("Exit")
		return signal.BreakExit
	})
	signal.Wait()
}
